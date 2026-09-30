// `bsly update`: compare the deck's firmware with the latest GitHub releases and
// install new UF2s through the chips' USB bootloaders.
//
// The RP2350 reboots into its bootloader on `bootsel`, the probe (RP2040) on
// CMSIS-DAP vendor command 0x9F. Firmware older than that needs the button:
// SW2 held while plugging USB in, which puts *both* chips in their bootloaders.
// Either way the chip shows up as a USB drive and the UF2 is copied onto it.

use std::io::Write;
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};

use anyhow::{bail, Context, Result};
use colored::Colorize;
use nusb::{DeviceInfo, MaybeFuture};

use crate::device::{self, Control, Deck};
use crate::error::CliError;
use crate::github::{self, Release};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Chip {
    Rp2350,
    Probe,
}

impl Chip {
    pub fn name(self) -> &'static str {
        match self {
            Chip::Rp2350 => "rp2350",
            Chip::Probe => "probe",
        }
    }
    fn repo(self) -> &'static str {
        match self {
            Chip::Rp2350 => "bugslayer-deck-firmware",
            Chip::Probe => "bugslayer-probe-firmware",
        }
    }
    fn asset_prefix(self) -> &'static str {
        match self {
            Chip::Rp2350 => "bugslayer-rp2350-",
            Chip::Probe => "bugslayer-probe-",
        }
    }
    /// `Board-ID:` in the bootloader drive's INFO_UF2.TXT, and its volume label.
    fn board_id(self) -> &'static str {
        match self {
            Chip::Rp2350 => "RP2350",
            Chip::Probe => "RPI-RP2",
        }
    }
}

pub struct Options {
    pub chips: Vec<Chip>,
    pub check: bool,
    /// Install this tag instead of the latest release (one chip).
    pub tag: Option<String>,
    /// Install this UF2 instead of a release (one chip).
    pub file: Option<PathBuf>,
    pub prerelease: bool,
    /// Reinstall even when the installed version is current.
    pub force: bool,
    pub yes: bool,
}

/// What the deck runs: `None` when the chip cannot say (probe firmware from
/// before versions were reported, or the chip is not reachable).
struct Installed {
    rp2350: Option<String>,
    probe: Option<String>,
}

fn rp2350_version(deck: &Deck) -> Result<String> {
    let mut ctl = Control::open(deck, false)?;
    let ver = device::kv(&ctl.command("ver")?);
    ver.get("rp2350").cloned().ok_or_else(|| anyhow::anyhow!("no rp2350= in the `ver` reply"))
}

/// One CMSIS-DAP command on whichever of the probe's interfaces is free.
fn probe_command(probe: &DeviceInfo, cmd: &[u8]) -> Result<Vec<u8>> {
    let dev = probe.open().wait().context("opening the probe")?;
    for itf in 0..4 {
        if let Ok(intf) = dev.claim_interface(itf).wait() {
            return crate::swo::dap(&intf, cmd);
        }
    }
    bail!(CliError::Connection("every CMSIS-DAP interface of the probe is in use".into()))
}

/// DAP_Info ID 9, the product firmware version. Empty on firmware from before
/// the split into bugslayer-probe-firmware.
pub fn probe_version(probe: &DeviceInfo) -> Result<Option<String>> {
    let r = probe_command(probe, &[0x00, 0x09])?;
    let len = *r.get(1).unwrap_or(&0) as usize;
    if len == 0 || r.len() < 2 + len {
        return Ok(None);
    }
    Ok(Some(String::from_utf8_lossy(&r[2..2 + len]).trim_end_matches('\0').to_string()))
}

/// A `git describe` build between releases: `0.8.0-3-gabc1234[-dirty]`.
fn is_dev_build(v: &str) -> bool {
    v.contains("-g") || v.ends_with("-dirty")
}

/// Whether `latest` should replace `installed`.
fn outdated(installed: Option<&str>, latest: &semver::Version) -> bool {
    match installed.map(|v| semver::Version::parse(v)) {
        None => true,
        Some(Err(_)) => true,
        Some(Ok(v)) => v < *latest && !is_dev_build(installed.unwrap()),
    }
}

fn describe(installed: Option<&str>) -> String {
    match installed {
        None => "unknown (older than the first release)".into(),
        Some(v) if is_dev_build(v) => format!("{} (development build)", v),
        Some(v) => v.to_string(),
    }
}

pub fn run(deck: Option<&Deck>, opts: &Options, non_interactive: bool) -> Result<()> {
    if (opts.tag.is_some() || opts.file.is_some()) && opts.chips.len() != 1 {
        bail!(CliError::Rejected("--version and --file need one chip: `bsly update rp2350` or `bsly update probe`".into()));
    }

    let installed = Installed {
        rp2350: deck.and_then(|d| rp2350_version(d).ok()),
        probe: deck.and_then(|d| d.probe.as_ref()).and_then(|p| probe_version(p).ok().flatten()),
    };

    // What to install, per chip: (release or file name, UF2 bytes).
    let mut plan: Vec<(Chip, String, Vec<u8>)> = Vec::new();
    for &chip in &opts.chips {
        let have = match chip {
            Chip::Rp2350 => installed.rp2350.as_deref(),
            Chip::Probe => installed.probe.as_deref(),
        };
        if let Some(path) = &opts.file {
            let data = std::fs::read(path).with_context(|| format!("reading {}", path.display()))?;
            plan.push((chip, path.display().to_string(), data));
            continue;
        }
        let release: Option<Release> = match &opts.tag {
            Some(t) => Some(github::release_by_tag(chip.repo(), t)?),
            None => github::latest(chip.repo(), opts.prerelease)?,
        };
        let Some(release) = release else {
            println!("{:<8}installed {}, no release on GitHub yet", chip.name(), describe(have));
            continue;
        };
        let latest = release.version().context("release tag is not a version")?;
        let stale = outdated(have, &latest);
        let deck_missing = deck.is_none() || (chip == Chip::Probe && deck.and_then(|d| d.probe.as_ref()).is_none());
        let what = if deck_missing {
            "not connected".yellow().to_string()
        } else if stale {
            format!("-> {}", release.tag_name).green().bold().to_string()
        } else {
            "up to date".into()
        };
        println!("{:<8}installed {}, latest {}  {}", chip.name(), describe(have), release.tag_name, what);
        if opts.check || (!stale && !opts.force && opts.tag.is_none() && !deck_missing) {
            continue;
        }
        let asset = release
            .asset(chip.asset_prefix(), ".uf2")
            .ok_or_else(|| CliError::NotFound(format!("a {}*.uf2 in release {}", chip.asset_prefix(), release.tag_name)))?;
        eprintln!("{} {} ({} kB)", "download".green(), asset.name, asset.size / 1024);
        plan.push((chip, release.tag_name.clone(), github::download(chip.repo(), asset)?));
    }
    if opts.check || plan.is_empty() {
        return Ok(());
    }

    if !opts.yes {
        crate::require_arg(non_interactive, "--yes: installs firmware")?;
        let list: Vec<String> = plan.iter().map(|(c, v, _)| format!("{} {}", c.name(), v)).collect();
        if !inquire::Confirm::new(&format!("Install {}?", list.join(", "))).with_default(true).prompt()? {
            return Ok(());
        }
    }

    // The probe first: if it needs the button, that puts the RP2350 in its
    // bootloader too, and the RP2350's copy then needs no second press.
    plan.sort_by_key(|(c, _, _)| *c != Chip::Probe);
    let serial = deck.map(|d| d.serial.clone());
    let probe_serial = deck.and_then(|d| d.probe.as_ref()).and_then(|p| p.serial_number().map(String::from));
    for (chip, version, uf2) in &plan {
        install(deck, *chip, uf2)?;
        verify(serial.as_deref(), probe_serial.as_deref(), *chip, version)?;
    }
    if find_drive(Chip::Rp2350).is_some() {
        println!("{} the RP2350 is still in its bootloader (SW2); replug the deck's USB to start it", "note:".yellow());
    }
    Ok(())
}

/// Get `chip` into its bootloader, copy the UF2 and wait for the drive to go.
fn install(deck: Option<&Deck>, chip: Chip, uf2: &[u8]) -> Result<()> {
    let drive = match find_drive(chip) {
        Some(d) => d, // already in the bootloader (e.g. after the button)
        None => {
            let asked = match (chip, deck) {
                (Chip::Rp2350, Some(d)) => {
                    let mut ctl = Control::open(d, false)?;
                    ctl.command("bootsel")?.starts_with("bootsel ok")
                }
                (Chip::Probe, Some(Deck { probe: Some(p), .. })) => probe_command(p, &[0x9F]).is_ok(),
                _ => false,
            };
            let rebooted = if asked { wait_for_drive(chip, Duration::from_secs(8)) } else { None };
            match rebooted {
                Some(d) => d,
                None => {
                    // Firmware from before the reboot commands. Nothing to
                    // type, only a button to press, so this works in scripts too.
                    println!(
                        "The {} cannot reboot into its bootloader by itself.\n  \
                         Unplug the deck's USB, hold {}, plug USB back in, then release {}.",
                        chip.name(),
                        "SW2".bold(),
                        "SW2".bold()
                    );
                    wait_for_drive(chip, Duration::from_secs(180))
                        .ok_or_else(|| CliError::Timeout(format!("no {} drive appeared", chip.board_id())))?
                }
            }
        }
    };

    eprintln!("{} {} -> {}", "copy".green(), chip.name(), drive.display());
    let target = drive.join(format!("bugslayer-{}.uf2", chip.name()));
    let copied = (|| -> std::io::Result<()> {
        let mut f = std::fs::File::create(&target)?;
        f.write_all(uf2)?;
        f.sync_all()
    })();
    // The chip reboots as soon as the last block lands, so the drive can vanish
    // before sync_all returns: only an error while the drive is still there counts.
    let t0 = Instant::now();
    while drive.join("INFO_UF2.TXT").exists() {
        if t0.elapsed() > Duration::from_secs(20) {
            copied.with_context(|| format!("writing {}", target.display()))?;
            bail!(CliError::Timeout(format!("{} is still there after the copy", drive.display())));
        }
        std::thread::sleep(Duration::from_millis(200));
    }
    Ok(())
}

/// After the chip restarts: check that it runs `version` (a release tag;
/// anything else, e.g. a file name, is only checked for coming back).
fn verify(serial: Option<&str>, probe_serial: Option<&str>, chip: Chip, version: &str) -> Result<()> {
    let want = version;
    let is_tag = semver::Version::parse(version).is_ok();
    let t0 = Instant::now();
    loop {
        let got = match chip {
            Chip::Rp2350 => device::list_decks()?
                .into_iter()
                .find(|d| serial.is_none_or(|s| d.serial == s))
                .filter(|d| d.port.is_some())
                .and_then(|d| rp2350_version(&d).ok()),
            // Found directly: the RP2350 may still be in its bootloader.
            Chip::Probe => device::list_devices()?
                .into_iter()
                .find(|d| {
                    d.vendor_id() == device::VID
                        && d.product_id() == device::PID_PROBE
                        && probe_serial.is_none_or(|s| d.serial_number() == Some(s))
                })
                .and_then(|p| probe_version(&p).ok().flatten()),
        };
        match got {
            Some(v) if v == want || !is_tag => {
                println!("{} {} runs {}", "done".green().bold(), chip.name(), v);
                return Ok(());
            }
            Some(v) if t0.elapsed() > Duration::from_secs(5) => {
                bail!(CliError::Rejected(format!("{} came back with {}, not {}", chip.name(), v, want)))
            }
            _ if t0.elapsed() > Duration::from_secs(20) => {
                bail!(CliError::Timeout(format!("{} did not come back on USB within 20 s", chip.name())))
            }
            _ => std::thread::sleep(Duration::from_millis(300)),
        }
    }
}

fn wait_for_drive(chip: Chip, timeout: Duration) -> Option<PathBuf> {
    let t0 = Instant::now();
    let mut mount_tried = false;
    while t0.elapsed() < timeout {
        if let Some(d) = find_drive(chip) {
            return Some(d);
        }
        // Linux without an automounter: ask udisks, as a desktop would.
        if !mount_tried && cfg!(target_os = "linux") {
            let dev = Path::new("/dev/disk/by-label").join(chip.board_id());
            if dev.exists() {
                mount_tried = true;
                let _ = std::process::Command::new("udisksctl")
                    .args(["mount", "--no-user-interaction", "-b"])
                    .arg(&dev)
                    .output();
            }
        }
        std::thread::sleep(Duration::from_millis(250));
    }
    None
}

/// A mounted UF2 bootloader drive whose INFO_UF2.TXT names `chip`'s board.
fn find_drive(chip: Chip) -> Option<PathBuf> {
    let want = format!("Board-ID: {}", chip.board_id());
    mount_points().into_iter().find(|m| {
        std::fs::read_to_string(m.join("INFO_UF2.TXT"))
            .map(|t| t.lines().any(|l| l.trim() == want))
            .unwrap_or(false)
    })
}

fn mount_points() -> Vec<PathBuf> {
    if cfg!(target_os = "linux") {
        // Field 2 of /proc/mounts, with spaces escaped as \040.
        std::fs::read_to_string("/proc/mounts")
            .unwrap_or_default()
            .lines()
            .filter_map(|l| l.split(' ').nth(1))
            .map(|p| PathBuf::from(p.replace("\\040", " ")))
            .collect()
    } else if cfg!(target_os = "macos") {
        std::fs::read_dir("/Volumes").map(|r| r.flatten().map(|e| e.path()).collect()).unwrap_or_default()
    } else {
        ('D'..='Z').map(|c| PathBuf::from(format!("{}:\\", c))).collect()
    }
}

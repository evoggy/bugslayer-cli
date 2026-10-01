// `bscli update`: compare the deck's firmware with the latest GitHub releases and
// install new UF2s through the chips' USB bootloaders (bugslayer::update does
// the work; this is the talking).
//
// The RP2350 reboots into its bootloader on `bootsel`, the probe (RP2040) on
// CMSIS-DAP vendor command 0x9F. Firmware older than that needs the button:
// SW2 held while plugging USB in, which puts *both* chips in their bootloaders.
// Either way the chip shows up as a USB drive and the UF2 is copied onto it.

use std::path::PathBuf;

use anyhow::{bail, Context, Result};
use colored::Colorize;

pub use bugslayer::update::{probe_version, Chip};
use bugslayer::update::{self, describe, Note};

use crate::device::Deck;
use crate::error::CliError;

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

pub fn run(deck: Option<&Deck>, opts: &Options, non_interactive: bool) -> Result<()> {
    if (opts.tag.is_some() || opts.file.is_some()) && opts.chips.len() != 1 {
        bail!(CliError::Rejected("--version and --file need one chip: `bscli update rp2350` or `bscli update probe`".into()));
    }

    // What to install, per chip: (release or file name, UF2 bytes).
    let mut plan: Vec<(Chip, String, Vec<u8>)> = Vec::new();
    for &chip in &opts.chips {
        if let Some(path) = &opts.file {
            let data = std::fs::read(path).with_context(|| format!("reading {}", path.display()))?;
            plan.push((chip, path.display().to_string(), data));
            continue;
        }
        let st = update::status(deck, chip, opts.tag.as_deref(), opts.prerelease)?;
        let have = st.installed.as_deref();
        let Some(release) = st.release else {
            println!("{:<8}installed {}, no release on GitHub yet", chip.name(), describe(have));
            continue;
        };
        let what = if st.missing {
            "not connected".yellow().to_string()
        } else if st.stale {
            format!("-> {}", release.tag_name).green().bold().to_string()
        } else {
            "up to date".into()
        };
        println!("{:<8}installed {}, latest {}  {}", chip.name(), describe(have), release.tag_name, what);
        if opts.check || (!st.stale && !opts.force && opts.tag.is_none() && !st.missing) {
            continue;
        }
        let asset = update::uf2_asset(chip, &release)?;
        eprintln!("{} {} ({} kB)", "download".green(), asset.name, asset.size / 1024);
        plan.push((chip, release.tag_name.clone(), update::download(chip, &release)?));
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
        update::install(deck, *chip, uf2, |n| match n {
            // Nothing to type, only a button to press, so this works in scripts too.
            Note::PressButton(chip) => println!(
                "The {} cannot reboot into its bootloader by itself.\n  \
                 Unplug the deck's USB, hold {}, plug USB back in, then release {}.",
                chip.name(),
                "SW2".bold(),
                "SW2".bold()
            ),
            Note::Copying(chip, drive) => eprintln!("{} {} -> {}", "copy".green(), chip.name(), drive.display()),
        })?;
        let v = update::verify(serial.as_deref(), probe_serial.as_deref(), *chip, version)?;
        println!("{} {} runs {}", "done".green().bold(), chip.name(), v);
    }
    if update::rp2350_in_bootloader() {
        println!("{} the RP2350 is still in its bootloader (SW2); replug the deck's USB to start it", "note:".yellow());
    }
    Ok(())
}

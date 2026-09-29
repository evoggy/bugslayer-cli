// bsly: command-line client for the Bugslayer deck.

mod capture;
mod console;
mod device;
mod error;
mod sigrok;
mod spi;
mod stream;

use std::io::{IsTerminal, Write};
use std::time::Duration;

use anyhow::{bail, Result};
use clap::{Args, CommandFactory, Parser, Subcommand, ValueEnum, ValueHint};
use colored::Colorize;
use inquire::Select;
use serde::{Deserialize, Serialize};

use device::{Control, Deck};
use error::CliError;

include!("cli.rs");

const CONFIG_APP: &str = "bugslayer-cli";

#[derive(Debug, Default, Clone, Serialize, Deserialize)]
struct Config {
    /// Serial of the deck `bsly select` picked, used when several are connected.
    selected: Option<String>,
}

fn store_config(config: &Config) {
    if let Err(e) = confy::store(CONFIG_APP, None, config) {
        eprintln!("Could not save settings: {}", e);
    }
}

/// Bail with `CliError::MissingArg` when the caller would otherwise hit an
/// interactive prompt but the CLI is running non-interactively.
pub fn require_arg(non_interactive: bool, missing_arg: &str) -> Result<()> {
    if non_interactive {
        bail!(CliError::MissingArg(format!("{} (running non-interactively, so no prompt)", missing_arg)));
    }
    Ok(())
}

/// Pick one of `options` with a prompt, or fail naming `arg` when
/// non-interactive.
fn choose<T: Copy>(non_interactive: bool, arg: &str, prompt: &str, options: &[(T, &str)]) -> Result<T> {
    require_arg(non_interactive, arg)?;
    let labels: Vec<&str> = options.iter().map(|o| o.1).collect();
    let pick = Select::new(prompt, labels.clone()).prompt()?;
    Ok(options[labels.iter().position(|l| *l == pick).unwrap()].0)
}

fn on_off(s: OnOff) -> &'static str {
    match s {
        OnOff::On => "on",
        OnOff::Off => "off",
    }
}

/// Redraw `lines()` in place until Ctrl-C.
fn watch(mut lines: impl FnMut() -> Result<Vec<String>>) -> Result<()> {
    let mut drawn = 0;
    loop {
        let out = lines()?;
        let mut so = std::io::stdout().lock();
        if drawn > 0 {
            write!(so, "\x1b[{}A", drawn)?;
        }
        for l in &out {
            writeln!(so, "\x1b[2K{}", l)?;
        }
        so.flush()?;
        drawn = out.len();
        std::thread::sleep(Duration::from_millis(200));
    }
}

fn pins_lines(ctl: &mut Control) -> Result<Vec<String>> {
    let reply = ctl.command("pins")?;
    let kv = device::kv(&reply);
    let mut names = String::new();
    let mut values = String::new();
    for name in stream::CHANNEL_NAMES.iter().copied().chain(["cf_vcc"]) {
        let w = name.len().max(1) + 2;
        names += &format!("{:<w$}", name, w = w);
        let v = kv.get(name).map(String::as_str).unwrap_or("?");
        let cell = format!("{:<w$}", v, w = w);
        values += &match v {
            "1" => cell.green().bold().to_string(),
            "0" => cell.dimmed().to_string(),
            _ => cell.red().to_string(),
        };
    }
    Ok(vec![names.bold().to_string(), values])
}

fn status_lines(ctl: &mut Control) -> Result<Vec<String>> {
    let replies = ctl.query("stat")?;
    let mut kv = std::collections::BTreeMap::new();
    for r in &replies {
        kv.extend(device::kv(r));
    }
    let get = |k: &str| kv.get(k).cloned().unwrap_or_else(|| "?".into());
    let flag = |k: &str| match kv.get(k).map(String::as_str) {
        Some("1") => "yes".green().to_string(),
        Some("0") => "no".to_string(),
        other => other.unwrap_or("?").to_string(),
    };
    let mut out = vec![
        format!("{}", "capture".bold()),
        format!(
            "  armed {}  busy {}  aborted {}  sink {}  spi {}",
            flag("armed"),
            flag("busy"),
            if get("aborted") == "1" { "yes".red().to_string() } else { "no".into() },
            get("sink"),
            flag("spi")
        ),
        format!(
            "  session {}  rate {} Hz  samples {}  spi bytes {}",
            get("session"),
            get("rate"),
            get("samples"),
            get("spi_bytes")
        ),
        format!("  blocks {}  overruns {}  lost {}", get("blocks"), get("overruns"), get("lost")),
        format!("{}", "fx2".bold()),
        format!(
            "  link {}  boot {}  eeprom bytes served {}  ifclk {} Hz",
            if get("fx2") == "up" { "up".green().to_string() } else { get("fx2").yellow().to_string() },
            get("boot"),
            get("eeprom_read"),
            get("ifclk")
        ),
        format!("  sink blocks {}  pipe test {} ({} words)", get("sink_blocks"), get("counter"), get("words")),
        format!("{}", "crazyflie".bold()),
        format!("  VCC present {}", flag("cf_vcc")),
    ];
    // Anything a newer firmware adds still shows up.
    let known = [
        "armed", "busy", "aborted", "sink", "spi", "session", "rate", "samples", "spi_bytes", "blocks",
        "overruns", "lost", "fx2", "sink_blocks", "boot", "eeprom_read", "ifclk", "counter", "words", "cf_vcc",
    ];
    let extra: Vec<String> =
        kv.iter().filter(|(k, _)| !known.contains(&k.as_str())).map(|(k, v)| format!("{}={}", k, v)).collect();
    if !extra.is_empty() {
        out.push(format!("  {}", extra.join("  ")));
    }
    Ok(out)
}

fn fx2_up(ctl: &mut Control, deck: &Deck, line: &str) -> Result<()> {
    println!("{}", ctl.expect_ok(line)?);
    let d = device::wait_fx2(&deck.serial, Duration::from_secs(5))?;
    println!("FX2 enumerated as {:04x}:{:04x}, serial {}", d.vendor_id(), d.product_id(), deck.serial);
    Ok(())
}

// ---- Shell completion support -------------------------------------------

fn emit_completion_script(shell: clap_complete::Shell) {
    let mut cmd = CliArgs::command();
    clap_complete::generate(shell, &mut cmd, "bsly", &mut std::io::stdout());
}

/// Dynamic completion candidates, one per line. Only lists USB devices; never
/// talks to a deck.
fn emit_dynamic_completions(kind: CompletionKind, partial: &str) {
    let candidates: Vec<String> = match kind {
        CompletionKind::Serials => device::list_decks().unwrap_or_default().into_iter().map(|d| d.serial).collect(),
    };
    for c in candidates.iter().filter(|c| c.starts_with(partial)) {
        println!("{}", c);
    }
}

fn main() {
    // Die quietly on a closed pipe (`bsly decode spi x.sr | head`) instead of
    // panicking in println!.
    #[cfg(unix)]
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
    let code = match run() {
        Ok(()) => 0,
        Err(e) => {
            if is_cancelled(&e) {
                std::process::exit(130);
            }
            eprintln!("{} {:#}", "Error:".red().bold(), e);
            if let Some(hint) = error::hint(&e) {
                eprintln!("{} {}", "Hint:".yellow().bold(), hint);
            }
            error::classify_exit_code(&e)
        }
    };
    std::process::exit(code);
}

/// Esc / Ctrl-C at a prompt is the user backing out, not an error.
fn is_cancelled(e: &anyhow::Error) -> bool {
    matches!(
        e.downcast_ref::<inquire::InquireError>(),
        Some(inquire::InquireError::OperationCanceled | inquire::InquireError::OperationInterrupted)
    )
}

fn run() -> Result<()> {
    // The `__complete` helper is dispatched before clap so it never appears in
    // `--help` or the generated completion scripts.
    let argv: Vec<String> = std::env::args().collect();
    if argv.get(1).is_some_and(|a| a == "__complete") {
        if let Some(kind) = argv.get(2).and_then(|s| CompletionKind::from_str(s, false).ok()) {
            emit_dynamic_completions(kind, argv.get(3).map(String::as_str).unwrap_or(""));
        }
        return Ok(());
    }

    let args = CliArgs::parse();
    let non_interactive = args.non_interactive || !std::io::stdin().is_terminal();
    let mut config: Config = confy::load(CONFIG_APP, None).unwrap_or_default();

    // Commands that need no deck.
    match &args.command {
        Commands::Completions { shell } => {
            emit_completion_script(*shell);
            return Ok(());
        }
        Commands::List => return list(&config),
        Commands::Select => {
            let decks = device::list_decks()?;
            if decks.is_empty() {
                bail!(CliError::Connection("no Bugslayer deck found".into()));
            }
            require_arg(non_interactive, "a deck to select")?;
            let labels: Vec<String> = decks.iter().map(device::describe).collect();
            let pick = Select::new("Select the deck to use by default:", labels.clone()).prompt()?;
            let deck = &decks[labels.iter().position(|l| *l == pick).unwrap()];
            config.selected = Some(deck.serial.clone());
            store_config(&config);
            println!("Selected {}", deck.serial);
            return Ok(());
        }
        Commands::Settings { command } => {
            match command {
                SettingsCommands::Show => {
                    println!("Selected deck: {}", config.selected.as_deref().unwrap_or("(none)"));
                    if let Ok(p) = confy::get_configuration_file_path(CONFIG_APP, None) {
                        println!("Settings file: {}", p.display());
                    }
                }
                SettingsCommands::Clear => {
                    config.selected = None;
                    store_config(&config);
                    println!("Cleared the selected deck");
                }
            }
            return Ok(());
        }
        Commands::Decode { command: DecodeCommands::Spi { file, cs } } => {
            let f = sigrok::read(file)?;
            let Some(sck8) = f.sck8 else {
                bail!(CliError::NotFound(format!("{} has no sck8 stream (capture with --spi)", file.display())));
            };
            let d = spi::decode(&sck8, Some((&f.raw16, f.rate_hz as f64)));
            spi::report(&d, 0, true);
            let want = cs.map(|c| c.to_possible_value().unwrap().get_name().to_string());
            for t in d.txns.iter().filter(|t| want.as_ref().is_none_or(|w| &t.cs == w)) {
                println!("{}", spi::format_txn(t));
            }
            return Ok(());
        }
        _ => {}
    }

    let deck = device::find_deck(args.serial.as_deref(), config.selected.as_deref(), non_interactive)?;
    let mut ctl = Control::open(&deck, args.debug)?;

    match &args.command {
        Commands::Info => {
            let ver = device::kv(&ctl.command("ver")?);
            let id = device::kv(&ctl.command("id")?);
            let get = |m: &std::collections::BTreeMap<String, String>, k: &str| m.get(k).cloned().unwrap_or("?".into());
            println!("{:<12}{}", "serial", get(&id, "serial"));
            println!("{:<12}{}", "hardware", get(&ver, "hw"));
            println!("{:<12}{}", "rp2350 fw", get(&ver, "rp2350"));
            println!("{:<12}{} bytes", "fx2 image", get(&ver, "fx2_image"));
            println!("{:<12}{:04x}:{:04x}  {}", "control", device::VID, device::PID_CTRL, deck.port.as_deref().unwrap_or("(no port)"));
            match &deck.fx2 {
                Some(d) => println!("{:<12}{:04x}:{:04x}  {}", "capture", d.vendor_id(), d.product_id(), device::speed_name(d)),
                None => println!("{:<12}{}", "capture", "FX2 down (bsly fx2 up)".yellow()),
            }
            match &deck.probe {
                Some(d) => println!(
                    "{:<12}{:04x}:{:04x}  serial {}",
                    "probe",
                    d.vendor_id(),
                    d.product_id(),
                    d.serial_number().unwrap_or("?")
                ),
                None => println!("{:<12}{}", "probe", "not found".yellow()),
            }
        }
        Commands::Status { watch: w } => {
            if *w {
                watch(|| status_lines(&mut ctl))?;
            }
            for l in status_lines(&mut ctl)? {
                println!("{}", l);
            }
        }
        Commands::Pins { watch: w } => {
            if *w {
                watch(|| pins_lines(&mut ctl))?;
            }
            for l in pins_lines(&mut ctl)? {
                println!("{}", l);
            }
        }
        Commands::Power { rail, state } => {
            let rail = match rail {
                Some(r) => *r,
                None => choose(
                    non_interactive,
                    "<RAIL>",
                    "Which switch?",
                    &[(PowerRail::Vcc, "vcc  expansion-port VCC"), (PowerRail::Vcom, "vcom expansion-port VCOM")],
                )?,
            };
            let state = match state {
                Some(s) => *s,
                None => choose(non_interactive, "<STATE>", "Switch it", &[(OnOff::On, "on"), (OnOff::Off, "off")])?,
            };
            let rail = if rail == PowerRail::Vcc { "vcc" } else { "vcom" };
            println!("{}", ctl.expect_ok(&format!("pwr {} {}", rail, on_off(state)))?);
        }
        Commands::Pull { state } => {
            let state = match state {
                Some(s) => *s,
                None => choose(
                    non_interactive,
                    "<STATE>",
                    "I2C pull-ups (standalone only: never with a Crazyflie in the stack)",
                    &[(OnOff::On, "on   2.2k to VCC"), (OnOff::Off, "off  Hi-Z")],
                )?,
            };
            println!("{}", ctl.expect_ok(&format!("pull {}", on_off(state)))?);
        }
        Commands::Fx2 { command } => {
            let picked;
            let command = match command {
                Some(c) => c,
                None => {
                    picked = choose(
                    non_interactive,
                    "<COMMAND>",
                    "FX2:",
                    &[
                        (0, "status  link and USB state"),
                        (1, "up      boot it and release reset"),
                        (2, "down    hold it in reset"),
                        (3, "reboot  down, then up"),
                        (4, "boot    choose what the emulated EEPROM serves"),
                    ],
                )
                .map(|i| match i {
                    1 => Fx2Commands::Up,
                    2 => Fx2Commands::Down,
                    3 => Fx2Commands::Reboot,
                    4 => Fx2Commands::Boot { mode: None },
                    _ => Fx2Commands::Status,
                })?;
                    &picked
                }
            };
            match command {
                Fx2Commands::Up => fx2_up(&mut ctl, &deck, "fx2 up")?,
                Fx2Commands::Reboot => fx2_up(&mut ctl, &deck, "fx2 reboot")?,
                Fx2Commands::Down => println!("{}", ctl.expect_ok("fx2 down")?),
                Fx2Commands::Boot { mode } => {
                    let mode = match mode {
                        Some(m) => *m,
                        None => choose(
                            non_interactive,
                            "<MODE>",
                            "What should the emulated EEPROM serve at the next up?",
                            &[
                                (Fx2BootMode::C2, "c2   our firmware (default)"),
                                (Fx2BootMode::C0, "c0   our VID/PID only, for fx2tool RAM loads"),
                                (Fx2BootMode::Rom, "rom  nothing: the FX2 boot ROM (04b4:8613)"),
                            ],
                        )?,
                    };
                    let m = mode.to_possible_value().unwrap().get_name().to_string();
                    println!("{}", ctl.expect_ok(&format!("fx2 boot {}", m))?);
                }
                Fx2Commands::Status => {
                    let mut kv = std::collections::BTreeMap::new();
                    for r in ctl.query("stat")? {
                        kv.extend(device::kv(&r));
                    }
                    let get = |k: &str| kv.get(k).cloned().unwrap_or("?".into());
                    println!("link {}  boot {}  ifclk {} Hz", get("fx2"), get("boot"), get("ifclk"));
                    let devs = device::list_devices()?;
                    match &deck.fx2 {
                        Some(d) => println!("usb  {:04x}:{:04x}  serial {}  {}", d.vendor_id(), d.product_id(), deck.serial, device::speed_name(d)),
                        None if devs.iter().any(|d| (d.vendor_id(), d.product_id()) == device::FX2_ROM) => {
                            println!("usb  04b4:8613 (FX2 boot ROM: no firmware loaded)")
                        }
                        None => println!("usb  not enumerated"),
                    }
                }
            }
        }
        Commands::Capture(o) => {
            let sink = match o.sink {
                SinkArg::Usb => capture::Sink::Usb,
                SinkArg::Fx2 => capture::Sink::Fx2,
                SinkArg::Auto if o.rate > capture::USB_MAX_RATE => capture::Sink::Fx2,
                SinkArg::Auto => capture::Sink::Usb,
            };
            if sink == capture::Sink::Usb && o.rate > capture::USB_MAX_RATE {
                eprintln!(
                    "{} Full Speed carries about {} ksps; expect overruns (use --sink fx2)",
                    "note".yellow(),
                    capture::USB_MAX_RATE / 1000
                );
            }
            let opts = capture::Options {
                rate: o.rate,
                duration: o.duration,
                output: o.output.clone(),
                source: match o.source {
                    Source::Pins => "pins",
                    Source::Counter => "counter",
                },
                sink,
                spi: o.spi,
                spi_show: o.spi_show,
                no_overrun: o.no_overrun,
            };
            capture::run(&deck, &mut ctl, &opts, non_interactive)?;
        }
        Commands::Raw { lines } => {
            if lines.is_empty() {
                require_arg(non_interactive, "<LINES>")?;
                console::run(&mut ctl, &deck.serial)?;
            }
            for line in lines {
                println!("{}", format!("> {}", line).dimmed());
                console::print_replies(&mut ctl, line)?;
            }
        }
        Commands::Completions { .. }
        | Commands::List
        | Commands::Select
        | Commands::Settings { .. }
        | Commands::Decode { .. } => unreachable!("handled before connecting"),
    }
    Ok(())
}

fn list(config: &Config) -> Result<()> {
    let decks = device::list_decks()?;
    let devs = device::list_devices()?;
    if decks.is_empty() {
        println!("No Bugslayer deck found");
    }
    for d in &decks {
        let mark = if config.selected.as_deref() == Some(&d.serial) && decks.len() > 1 { "*" } else { " " };
        println!(
            "{} {}  control {}  capture {}  probe {}",
            mark,
            d.serial.bold(),
            d.port.as_deref().unwrap_or("(no port)"),
            if d.fx2.is_some() { "up".green().to_string() } else { "down".yellow().to_string() },
            d.probe.as_ref().and_then(|p| p.serial_number()).unwrap_or("-"),
        );
    }
    let seen = |id: (u16, u16)| devs.iter().filter(|d| (d.vendor_id(), d.product_id()) == id).count();
    if seen(device::FX2_ROM) > 0 {
        println!("  {} an FX2 boot ROM (04b4:8613) is on the bus: an FX2 without firmware", "note".yellow());
    }
    if seen(device::RP2350_BOOTSEL) > 0 {
        println!("  {} an RP2350 in BOOTSEL (2e8a:000f) is on the bus", "note".yellow());
    }
    Ok(())
}

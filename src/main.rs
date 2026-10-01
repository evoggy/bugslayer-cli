// bscli: command-line client for the Bugslayer deck.

mod capture;
mod console;
mod error;
mod swo;
mod uart;
mod update;

// The deck protocol lives in bugslayer-lib, shared with bugslayer-ui.
use bugslayer::{bus, deckctrl, device, sigrok, spi, stream};

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
    /// Serial of the deck `bscli select` picked, used when several are connected.
    selected: Option<String>,
    /// The deck controllers last enumerated behind each Bugslayer, by serial:
    /// their addresses survive until they are reset or lose power.
    #[serde(default)]
    deckctrl: std::collections::BTreeMap<String, Vec<deckctrl::Found>>,
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

/// The deck to use: `--serial` if given, else the only one connected, else the
/// selected one (`bscli select`), else ask.
fn find_deck(serial: Option<&str>, selected: Option<&str>, non_interactive: bool) -> Result<Deck> {
    match device::find_deck(serial, selected)? {
        device::DeckChoice::One(d) => Ok(*d),
        device::DeckChoice::Several(decks) => {
            require_arg(non_interactive, "--serial: several decks are connected")?;
            let labels: Vec<String> = decks.iter().map(device::describe).collect();
            let pick = Select::new("Several decks are connected, which one?", labels.clone()).prompt()?;
            let idx = labels.iter().position(|l| *l == pick).unwrap();
            Ok(decks.into_iter().nth(idx).unwrap())
        }
    }
}

/// Standalone: VCC and VCOM on, asking first when the port is unpowered
/// unless `power`.
fn power_standalone(ctl: &mut Control, st: &bus::PortState, power: bool, non_interactive: bool) -> Result<()> {
    let power = power || !st.unpowered() || confirm_power(non_interactive)?;
    for (tag, msg) in bus::power_standalone(ctl, st, power)? {
        eprintln!("{} {}", tag.green(), msg);
    }
    Ok(())
}

fn confirm_power(non_interactive: bool) -> Result<bool> {
    require_arg(non_interactive, "--power: the expansion port is unpowered")?;
    let yes = inquire::Confirm::new("The expansion port is unpowered. Switch VCC and VCOM on to power the decks?")
        .with_default(true)
        .prompt()?;
    if !yes {
        bail!(CliError::Rejected("the decks need power to answer".into()));
    }
    Ok(true)
}

/// Onto the expansion-port I2C bus (bugslayer::bus::Bus::open), asking before
/// powering an unpowered port.
fn open_bus<'a>(ctl: &'a mut Control, b: &BusArgs, non_interactive: bool) -> Result<bus::Bus<'a>> {
    let mut opts = bus_opts(b);
    if !opts.power {
        // An unpowered port has no Crazyflie on it: the deck would power it.
        if bus::port_state(ctl)?.unpowered() {
            opts.power = confirm_power(non_interactive)?;
        }
    }
    let bus = bus::Bus::open(ctl, &opts)?;
    for (tag, msg) in &bus.notes {
        eprintln!("{} {}", tag.green(), msg);
    }
    Ok(bus)
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
        format!("{}", "expansion port".bold()),
        format!(
            "  VCC present {}  VCOM present {}  switched on by the deck: VCC {}  VCOM {}",
            flag("cf_vcc"),
            flag("vcom"),
            flag("vcc_en"),
            flag("vcom_en")
        ),
        format!(
            "  UART bridge: UART1 {} ({} baud, {} dropped)  UART2 {} ({} baud, {} dropped)",
            get("uart1"),
            get("uart1_baud"),
            get("uart1_dropped"),
            get("uart2"),
            get("uart2_baud"),
            get("uart2_dropped")
        ),
        format!("  TX2/RX2 to {}  held low: {}", get("mux"), get("low")),
        format!(
            "  I2C pull-ups {}  I2C master {}{}",
            flag("pull"),
            get("i2c"),
            if get("i2c") == "on" { format!(" at {} Hz", get("i2c_rate")) } else { String::new() }
        ),
    ];
    // Anything a newer firmware adds still shows up.
    let known = [
        "armed", "busy", "aborted", "sink", "spi", "session", "rate", "samples", "spi_bytes", "blocks",
        "overruns", "lost", "fx2", "sink_blocks", "boot", "eeprom_read", "ifclk", "counter", "words", "cf_vcc",
        "vcc_en", "vcom_en", "vcom", "pull", "i2c", "i2c_rate", "uart1", "uart1_baud", "uart1_dropped",
        "uart2", "uart2_baud", "uart2_dropped", "mux", "low",
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
    clap_complete::generate(shell, &mut cmd, "bscli", &mut std::io::stdout());
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
    // Die quietly on a closed pipe (`bscli decode spi x.sr | head`) instead of
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
            let d = spi::decode(&sck8, Some((&f.raw16 as &dyn spi::Raw16, f.rate_hz as f64)));
            capture::report(&d, 0, true);
            let want = cs.map(|c| c.to_possible_value().unwrap().get_name().to_string());
            for t in d.txns.iter().filter(|t| want.as_ref().is_none_or(|w| &t.cs == w)) {
                println!("{}", spi::format_txn(t));
            }
            return Ok(());
        }
        _ => {}
    }

    // Update works with no deck to talk to, e.g. with the RP2350 already in its
    // bootloader.
    if let Commands::Update(o) = &args.command {
        let deck = find_deck(args.serial.as_deref(), config.selected.as_deref(), non_interactive).ok();
        let chips = match o.chip {
            Some(UpdateChip::Rp2350) => vec![update::Chip::Rp2350],
            Some(UpdateChip::Probe) => vec![update::Chip::Probe],
            None => vec![update::Chip::Probe, update::Chip::Rp2350],
        };
        let opts = update::Options {
            chips,
            check: o.check,
            tag: o.version.clone(),
            file: o.file.clone(),
            prerelease: o.pre,
            force: o.force,
            yes: o.yes,
        };
        return update::run(deck.as_ref(), &opts, non_interactive);
    }

    let deck = find_deck(args.serial.as_deref(), config.selected.as_deref(), non_interactive)?;
    // SWO only needs the probe, not the control channel.
    if let Commands::Swo(o) = &args.command {
        let opts = swo::Options {
            swd: o.swd,
            baud: o.baud,
            ports: o.port.clone(),
            duration: o.duration,
            hex: o.hex,
            raw: o.raw,
            no_swd: o.no_swd,
        };
        return swo::run(&deck, &opts);
    }
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
                None => println!("{:<12}{}", "capture", "FX2 down (bscli fx2 up)".yellow()),
            }
            match &deck.probe {
                Some(d) => {
                    println!(
                        "{:<12}{:04x}:{:04x}  serial {}",
                        "probe",
                        d.vendor_id(),
                        d.product_id(),
                        d.serial_number().unwrap_or("?")
                    );
                    let v = match update::probe_version(d) {
                        Ok(Some(v)) => v,
                        Ok(None) => "unknown (older than the first release)".into(),
                        Err(e) => format!("? ({})", e),
                    };
                    println!("{:<12}{}", "probe fw", v);
                }
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
        Commands::I2c { command } => i2c_command(&mut ctl, command, non_interactive)?,
        Commands::Deckctrl { command } => {
            deckctrl_command(&mut ctl, &deck.serial, &mut config, command, non_interactive)?
        }
        Commands::Uart(o) => {
            let rate = o.rate.unwrap_or_else(|| (o.baud.saturating_mul(16)).max(1_000_000));
            let opts = uart::Options {
                lines: o.line.iter().map(|l| *l as usize).collect(),
                baud: o.baud,
                rate,
                duration: o.duration,
                hex: o.hex,
            };
            uart::run(&deck, &mut ctl, &opts, non_interactive)?;
        }
        Commands::Mux { mode, wait } => {
            let mode = match mode {
                Some(m) => *m,
                None => choose(
                    non_interactive,
                    "<MODE>",
                    "TX2/RX2 on the expansion port:",
                    &[
                        (MuxMode::Uart, "uart  to the deck's UART2 (default)"),
                        (MuxMode::Usb, "usb   to the hub as USB (standalone only)"),
                        (MuxMode::Off, "off   disconnected"),
                    ],
                )?,
            };
            let name = match mode {
                MuxMode::Uart => "uart",
                MuxMode::Usb => "usb",
                MuxMode::Off => "off",
            };
            println!("{}", ctl.expect_ok(&format!("mux {}", name))?);
            if mode == MuxMode::Usb {
                let deadline = std::time::Instant::now() + Duration::from_secs_f64(*wait);
                loop {
                    if let Some(d) = device::exp_usb_device(&deck)? {
                        println!(
                            "USB device on the expansion port: {:04x}:{:04x} {} {}",
                            d.vendor_id(),
                            d.product_id(),
                            d.manufacturer_string().unwrap_or(""),
                            d.product_string().unwrap_or("").bold()
                        );
                        break;
                    }
                    if std::time::Instant::now() > deadline {
                        println!("{} no USB device on the expansion port after {} s", "note:".yellow(), wait);
                        break;
                    }
                    std::thread::sleep(Duration::from_millis(200));
                }
            }
        }
        Commands::Drive { pin, level } => {
            let pin = match pin {
                IoPin::Io1 => "IO_1",
                IoPin::Io2 => "IO_2",
                IoPin::Io3 => "IO_3",
                IoPin::Io4 => "IO_4",
            };
            let level = if *level == DriveLevel::Low { "low" } else { "release" };
            println!("{}", ctl.expect_ok(&format!("drive {} {}", pin, level))?);
        }
        Commands::Bridge(o) => {
            let uarts: &[u8] = match o.uart {
                BridgeUart::Uart1 => &[1],
                BridgeUart::Uart2 => &[2],
                BridgeUart::Both => &[1, 2],
            };
            if o.state == OnOff::On {
                let st = bus::port_state(&mut ctl)?;
                if st.cf_vcc && !st.vcc_en {
                    bail!(CliError::Rejected(
                        "a Crazyflie powers the expansion port and drives TX1/TX2; the bridge is standalone \
                         only (`bscli uart` sniffs without driving)"
                            .into()
                    ));
                }
                power_standalone(&mut ctl, &st, o.power, non_interactive)?;
            }
            for &n in uarts {
                ctl.expect_ok(&format!("uart {} {}", n, on_off(o.state)))?;
                if o.state == OnOff::On {
                    let port = device::uart_port(&deck.serial, n)
                        .unwrap_or_else(|| "(serial port not found; is cdc_acm bound?)".into());
                    println!("UART{} -> {}", n, port.bold());
                } else {
                    println!("UART{} off", n);
                }
            }
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
        | Commands::Decode { .. }
        | Commands::Swo(_)
        | Commands::Update(_) => unreachable!("handled before connecting"),
    }
    Ok(())
}

/// One deck controller: by `--deck`, the only one, or ask.
fn pick_deckctrl<'a>(
    decks: &'a [deckctrl::Found],
    sel: Option<&str>,
    non_interactive: bool,
) -> Result<&'a deckctrl::Found> {
    if let Some(f) = deckctrl::pick(decks, sel)? {
        return Ok(f);
    }
    require_arg(non_interactive, "--deck: several deck controllers answered")?;
    let labels: Vec<String> =
        decks.iter().map(|d| format!("0x{:02x}  {}  rev {}  {}", d.addr, d.name, d.rev, d.cpu_id)).collect();
    let pick = Select::new("Which deck?", labels.clone()).prompt()?;
    Ok(&decks[labels.iter().position(|l| *l == pick).unwrap()])
}

fn gpio_table(dir: u16, value: u16) -> Vec<String> {
    let mut out = vec![format!("{}", format!("{:<6}{:<6}{:<8}{}", "GPIO", "pin", "dir", "level").bold())];
    for (i, pin, out_dir, high) in deckctrl::gpio_rows(dir, value) {
        let level = if high { "high".green().bold().to_string() } else { "low".dimmed().to_string() };
        out.push(format!("{:<6}{:<6}{:<8}{}", i, pin, if out_dir { "out" } else { "in" }, level));
    }
    out
}

fn bus_opts(b: &BusArgs) -> bus::BusOptions {
    bus::BusOptions { rate: b.i2c_rate, force: b.force, power: b.power }
}

fn i2c_command(ctl: &mut Control, command: &I2cCommands, non_interactive: bool) -> Result<()> {
    match command {
        I2cCommands::Recover => {
            let ok = bus::recover(ctl)?;
            println!("{}", if ok { "SDA released".green().to_string() } else { "SDA is still held low".red().to_string() });
        }
        I2cCommands::Scan { bus: b } => {
            let mut bus = open_bus(ctl, b, non_interactive)?;
            let found = bus.scan()?;
            if found.is_empty() {
                println!("No device acknowledged");
            }
            for a in found {
                let what = bus::address_hint(a);
                let what = if what.is_empty() { String::new() } else { format!("  {}", what) };
                println!("0x{:02x}{}", a, what.dimmed());
            }
        }
        I2cCommands::Read { addr, len, reg, bus: b } => {
            if !(1..=512).contains(len) {
                bail!(CliError::Rejected(format!("{} bytes: 1..512 per read", len)));
            }
            let mut bus = open_bus(ctl, b, non_interactive)?;
            let w = reg.as_ref().map_or(&[][..], |r| &r.0[..]);
            let data = bus.xfer_ok(*addr, w, *len)?;
            for l in bugslayer::hexdump(0, &data) {
                println!("{}", l);
            }
        }
        I2cCommands::Write { addr, data, bus: b } => {
            let bytes: Vec<u8> = data.iter().flat_map(|d| d.0.iter().copied()).collect();
            if bytes.len() > 512 {
                bail!(CliError::Rejected(format!("{} bytes: at most 512 per write", bytes.len())));
            }
            let mut bus = open_bus(ctl, b, non_interactive)?;
            bus.xfer_ok(*addr, &bytes, 0)?;
            println!("wrote {} bytes to 0x{:02x}", bytes.len(), addr);
        }
    }
    Ok(())
}

fn print_deckctrl_info(f: &deckctrl::Found, info: &deckctrl::Info) {
    let row = |k: &str, v: String| println!("{:<13}{}", k, v);
    row("address", format!("0x{:02x}", f.addr));
    row("name", info.name.clone());
    row("revision", info.rev.to_string());
    row("vid:pid", format!("0x{:02X}:0x{:02X}", info.vid, info.pid));
    row("firmware", format!("{}.{}", info.fw_major, info.fw_minor));
    row(
        "manufactured",
        info.manufactured.map_or("-".into(), |(y, m, d)| format!("{}-{:02}-{:02}", y, m, d)),
    );
    row("cpu id", f.cpu_id.clone());
    for p in info.problems() {
        row("warning", p.yellow().to_string());
    }
}

fn deckctrl_command(
    ctl: &mut Control,
    serial: &str,
    config: &mut Config,
    command: &DeckctrlCommands,
    non_interactive: bool,
) -> Result<()> {
    let cache = config.deckctrl.get(serial).cloned().unwrap_or_default();
    let save = |config: &mut Config, decks: &[deckctrl::Found]| {
        config.deckctrl.insert(serial.to_string(), decks.to_vec());
        store_config(config);
    };
    match command {
        DeckctrlCommands::Scan { bus: b } => {
            let mut bus = open_bus(ctl, b, non_interactive)?;
            let found = deckctrl::enumerate(&mut bus)?;
            drop(bus);
            if found.is_empty() {
                println!("No deck controller answered");
            }
            for (f, info) in &found {
                let warn = info.as_ref().map(|i| i.problems().join(", ")).unwrap_or("no info page".into());
                println!(
                    "0x{:02x}  {:<15} rev {}  {}  {}",
                    f.addr,
                    f.name,
                    f.rev,
                    f.cpu_id.dimmed(),
                    warn.yellow()
                );
            }
            save(config, &found.into_iter().map(|(f, _)| f).collect::<Vec<_>>());
        }
        DeckctrlCommands::Reset { bus: b } => {
            let mut bus = open_bus(ctl, b, non_interactive)?;
            let any = deckctrl::reset_all(&mut bus)?;
            drop(bus);
            save(config, &[]);
            println!("{}", if any { "Deck controllers reset" } else { "No deck controller answered the reset" });
        }
        DeckctrlCommands::Info { deck: d }
        | DeckctrlCommands::Gpio { deck: d, .. }
        | DeckctrlCommands::Read { deck: d, .. }
        | DeckctrlCommands::Write { deck: d, .. } => {
            let mut bus = open_bus(ctl, &d.bus, non_interactive)?;
            let (decks, fresh) = deckctrl::decks(&mut bus, &cache, false, || {
                eprintln!("{} enumerating deck controllers (resets them)", "deckctrl".cyan())
            })?;
            let f = pick_deckctrl(&decks, d.deck.as_deref(), non_interactive)?.clone();
            match command {
                DeckctrlCommands::Info { .. } => {
                    let info = deckctrl::Info::parse(&deckctrl::read_reg(&mut bus, f.addr, deckctrl::REG_INFO, deckctrl::INFO_LEN)?);
                    print_deckctrl_info(&f, &info);
                    let (dir, value) = deckctrl::gpio_read(&mut bus, f.addr)?;
                    println!();
                    for l in gpio_table(dir, value) {
                        println!("{}", l);
                    }
                }
                DeckctrlCommands::Gpio { command: g, .. } => gpio_command(&mut bus, f.addr, g.as_ref(), non_interactive)?,
                DeckctrlCommands::Read { reg, len, .. } => {
                    let data = deckctrl::read_reg(&mut bus, f.addr, *reg, *len)?;
                    for l in bugslayer::hexdump(*reg as u32, &data) {
                        println!("{}", l);
                    }
                }
                DeckctrlCommands::Write { reg, data, .. } => {
                    let bytes: Vec<u8> = data.iter().flat_map(|b| b.0.iter().copied()).collect();
                    deckctrl::write_reg(&mut bus, f.addr, *reg, &bytes)?;
                    println!("wrote {} bytes at 0x{:04x} on 0x{:02x}", bytes.len(), reg, f.addr);
                }
                _ => unreachable!(),
            }
            drop(bus);
            if fresh {
                save(config, &decks);
            }
        }
    }
    Ok(())
}

fn gpio_command(bus: &mut bus::Bus, addr: u8, command: Option<&GpioCommands>, non_interactive: bool) -> Result<()> {
    let (dir, value) = deckctrl::gpio_read(bus, addr)?;
    let pins = |s: &str| deckctrl::parse_pins(s).map_err(|e| anyhow::Error::new(CliError::Rejected(e)));
    let set = |mask: u16, reg: u16, on: bool| if on { reg | mask } else { reg & !mask };
    let (new_dir, new_value) = match command {
        Some(GpioCommands::Show) => (dir, value),
        Some(GpioCommands::Dir { pins: p, dir: d }) => (set(pins(p)?, dir, *d == Direction::Out), value),
        Some(GpioCommands::Level { pins: p, level }) => (dir, set(pins(p)?, value, *level == Level::High)),
        Some(GpioCommands::Out { pins: p, level }) => {
            let m = pins(p)?;
            (dir | m, set(m, value, *level == Level::High))
        }
        None if non_interactive => (dir, value),
        None => {
            for l in gpio_table(dir, value) {
                println!("{}", l);
            }
            let labels: Vec<String> = deckctrl::GPIO_PINS
                .iter()
                .enumerate()
                .map(|(i, p)| {
                    format!(
                        "{:<3}{:<5}{:<4}{}",
                        i,
                        p,
                        if dir >> i & 1 == 1 { "out" } else { "in" },
                        if value >> i & 1 == 1 { "high" } else { "low" }
                    )
                })
                .collect();
            let picked = inquire::MultiSelect::new("GPIOs to change:", labels.clone()).prompt()?;
            if picked.is_empty() {
                return Ok(());
            }
            let m = picked.iter().map(|p| 1u16 << labels.iter().position(|l| l == p).unwrap()).fold(0, |a, b| a | b);
            let action = choose(
                false,
                "",
                "Make them",
                &[(0, "output, high"), (1, "output, low"), (2, "input")],
            )?;
            match action {
                0 => (dir | m, value | m),
                1 => (dir | m, value & !m),
                _ => (dir & !m, value),
            }
        }
    };
    deckctrl::gpio_set(bus, addr, (dir, value), (new_dir, new_value))?;
    let (dir, value) = deckctrl::gpio_read(bus, addr)?;
    for l in gpio_table(dir, value) {
        println!("{}", l);
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_bytes_and_hex() {
        assert_eq!(parse_byte("0x44"), Ok(0x44));
        assert_eq!(parse_byte("68"), Ok(68));
        assert!(parse_byte("0x144").is_err());
        assert_eq!(parse_hex("1900").unwrap().0, vec![0x19, 0x00]);
        assert_eq!(parse_hex("0x19, 0x00 ab").unwrap().0, vec![0x19, 0x00, 0xab]);
        assert!(parse_hex("190").is_err());
        assert!(parse_hex("zz").is_err());
    }
}

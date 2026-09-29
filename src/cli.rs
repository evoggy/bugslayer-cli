// CLI definition (clap derive tree) for bsly.
//
// This file is `include!`d by both `src/main.rs` (the real binary) and
// `build.rs` (which generates shell-completion scripts from the same command
// tree). It must therefore stay self-contained: NO `use`/`mod` statements (it
// relies on the imports of whichever file includes it) and NO dependency on
// other modules of the crate.

/// Sample rate: plain Hz or with a k/M suffix, e.g. `250000`, `250k`, `16.67M`.
fn parse_rate(s: &str) -> Result<u32, String> {
    let t = s.trim().trim_end_matches("sps").trim_end_matches("Hz").trim();
    let (num, mult) = match t.chars().last() {
        Some('k' | 'K') => (&t[..t.len() - 1], 1e3),
        Some('M') => (&t[..t.len() - 1], 1e6),
        _ => (t, 1.0),
    };
    let v: f64 = num.trim().parse().map_err(|_| format!("'{}' is not a rate (e.g. 250k, 16.67M)", s))?;
    let hz = (v * mult).round();
    if !(1.0..=u32::MAX as f64).contains(&hz) {
        return Err(format!("rate '{}' out of range", s));
    }
    Ok(hz as u32)
}

/// Duration: seconds, or with a ms/s/m suffix, e.g. `5`, `500ms`, `2m`.
fn parse_duration(s: &str) -> Result<std::time::Duration, String> {
    let t = s.trim();
    let (num, mult) = if let Some(n) = t.strip_suffix("ms") {
        (n, 1e-3)
    } else if let Some(n) = t.strip_suffix('s') {
        (n, 1.0)
    } else if let Some(n) = t.strip_suffix('m') {
        (n, 60.0)
    } else {
        (t, 1.0)
    };
    let v: f64 = num.trim().parse().map_err(|_| format!("'{}' is not a duration (e.g. 5, 500ms, 2m)", s))?;
    if !(v > 0.0 && v.is_finite()) {
        return Err(format!("duration '{}' must be positive", s));
    }
    Ok(std::time::Duration::from_secs_f64(v * mult))
}

// "Exit codes:" mirrors clap's default header style (bold + underline).
const HELP_EPILOG: &str = "\x1b[1m\x1b[4mExit codes:\x1b[0m
   0  success
   1  unspecified error
   2  usage / argument error (clap)
  10  connection failure (no deck found, USB or serial error)
  20  resource not found (deck serial, file)
  30  invalid value, or the deck rejected a command
  40  the deck did not reply in time
  50  capture verification failed (loss, sequence gap, bad END totals)
";

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None, after_help = HELP_EPILOG)]
struct CliArgs {
    #[clap(subcommand)]
    command: Commands,

    /// Use the deck with this serial number (instead of the selected one)
    #[clap(short, long, global = true, value_name = "SERIAL")]
    serial: Option<String>,

    /// Disable interactive prompts (auto-set when stdin is not a TTY)
    #[clap(long, global = true)]
    non_interactive: bool,

    /// Print every control-channel line sent and received
    #[clap(short, long, global = true)]
    debug: bool,
}

#[derive(Debug, Subcommand)]
enum Commands {
    /// List connected Bugslayer decks and their USB devices
    List,

    /// Pick which deck to use by default when several are connected
    Select,

    /// Firmware versions, serial number and USB devices of the deck
    Info,

    /// Capture engine and FX2 link status
    Status {
        /// Refresh continuously until Ctrl-C
        #[clap(short, long)]
        watch: bool,
    },

    /// Live level of every expansion-port signal
    Pins {
        /// Refresh continuously until Ctrl-C
        #[clap(short, long)]
        watch: bool,
    },

    /// Switch the deck's high-side power switches (prompts when omitted)
    Power {
        /// Which switch
        #[clap(value_enum)]
        rail: Option<PowerRail>,
        /// On or off
        #[clap(value_enum)]
        state: Option<OnOff>,
    },

    /// I2C pull-ups on the expansion port (standalone only; prompts when omitted)
    Pull {
        #[clap(value_enum)]
        state: Option<OnOff>,
    },

    /// Control the FX2 (CBM9002A) capture pipe (prompts when omitted)
    Fx2 {
        #[clap(subcommand)]
        command: Option<Fx2Commands>,
    },

    /// Record the expansion port: arm, stream, verify and write a sigrok .sr
    Capture(CaptureOptions),

    /// Decode a saved capture
    Decode {
        #[clap(subcommand)]
        command: DecodeCommands,
    },

    /// Send raw control-channel lines; with none, open an interactive console
    Raw {
        /// Command lines, one per argument, e.g. "fx2 up" stat
        lines: Vec<String>,
    },

    /// Local CLI settings
    Settings {
        #[clap(subcommand)]
        command: SettingsCommands,
    },

    /// Generate a shell completion script (printed to stdout)
    Completions {
        /// Shell to generate the completion script for
        #[clap(value_enum)]
        shell: clap_complete::Shell,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum PowerRail {
    /// Expansion-port VCC
    Vcc,
    /// Expansion-port VCOM
    Vcom,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum OnOff {
    On,
    Off,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum Fx2BootMode {
    /// Our firmware (default)
    C2,
    /// Our VID/PID only, for fx2tool RAM loads
    C0,
    /// Silent EEPROM: the FX2 boot ROM (04b4:8613)
    Rom,
}

#[derive(Debug, Subcommand)]
enum Fx2Commands {
    /// Serve the boot image, start IFCLK and release reset
    Up,
    /// Hold the FX2 in reset
    Down,
    /// Down, then up: the FX2 boots again
    Reboot,
    /// What the emulated EEPROM serves at the next up/reboot
    Boot {
        #[clap(value_enum)]
        mode: Option<Fx2BootMode>,
    },
    /// Is the FX2 up and enumerated, and with which serial
    Status,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum Source {
    /// The 16 expansion-port signals
    Pins,
    /// Synthetic counter: sample n == n mod 2^16 (pipe test)
    Counter,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum SinkArg {
    /// The FX2 when the rate needs it (above ~380 ksps), else the RP2350's USB
    Auto,
    /// The RP2350's own Full-Speed USB (up to ~380 ksps)
    Usb,
    /// The FX2 High-Speed pipe (up to ~17 Msps)
    Fx2,
}

#[derive(Debug, Args)]
struct CaptureOptions {
    /// Sample rate (e.g. 250k, 4M, 16.67M); the deck uses 150 MHz / integer
    #[clap(short, long, default_value = "250k", value_parser = parse_rate)]
    rate: u32,

    /// How long to record (e.g. 5, 500ms, 2m); until Ctrl-C when omitted
    #[clap(short = 't', long, value_parser = parse_duration)]
    duration: Option<std::time::Duration>,

    /// sigrok session file to write (opens in PulseView / sigrok-cli)
    #[clap(short, long, value_hint = ValueHint::FilePath)]
    output: Option<std::path::PathBuf>,

    /// What to sample
    #[clap(long, value_enum, default_value = "pins")]
    source: Source,

    /// Which USB pipe carries the data
    #[clap(long, value_enum, default_value = "auto")]
    sink: SinkArg,

    /// Also record the lines at every rising SCK edge (exact SPI at any speed)
    #[clap(long)]
    spi: bool,

    /// Print the first N decoded SPI transactions
    #[clap(long, default_value_t = 10, value_name = "N")]
    spi_show: usize,

    /// Fail (exit 50) if any samples were lost
    #[clap(long)]
    no_overrun: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum ChipSelect {
    #[value(name = "IO_1")]
    Io1,
    #[value(name = "IO_2")]
    Io2,
    #[value(name = "IO_3")]
    Io3,
    #[value(name = "IO_4")]
    Io4,
}

#[derive(Debug, Subcommand)]
enum DecodeCommands {
    /// SPI transactions from a capture made with --spi
    Spi {
        /// The .sr file
        #[clap(value_hint = ValueHint::FilePath)]
        file: std::path::PathBuf,
        /// Only transactions on this chip select
        #[clap(long, value_enum)]
        cs: Option<ChipSelect>,
    },
}

#[derive(Debug, Subcommand)]
enum SettingsCommands {
    /// Show the settings
    Show,
    /// Forget the selected deck
    Clear,
}

#[derive(Debug, Clone, Copy, ValueEnum)]
enum CompletionKind {
    /// Serial numbers of the connected decks (for `--serial`)
    Serials,
}

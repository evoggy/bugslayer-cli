// CLI definition (clap derive tree) for bscli.
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

/// A byte: `0x44`, `68` or `0b1000100`.
fn parse_byte(s: &str) -> Result<u8, String> {
    let t = s.trim();
    let r = if let Some(h) = t.strip_prefix("0x").or_else(|| t.strip_prefix("0X")) {
        u8::from_str_radix(h, 16)
    } else if let Some(b) = t.strip_prefix("0b") {
        u8::from_str_radix(b, 2)
    } else {
        t.parse()
    };
    r.map_err(|_| format!("'{}' is not a byte (e.g. 0x44)", s))
}

/// A 16-bit register address, hex with or without 0x: `1900`, `0x1900`.
fn parse_reg(s: &str) -> Result<u16, String> {
    let t = s.trim();
    let h = t.strip_prefix("0x").or_else(|| t.strip_prefix("0X")).unwrap_or(t);
    u16::from_str_radix(h, 16).map_err(|_| format!("'{}' is not a register address (hex, e.g. 1900)", s))
}

/// Bytes given as hex on the command line.
#[derive(Debug, Clone, PartialEq, Eq)]
struct Bytes(Vec<u8>);

/// Hex bytes, with or without spaces/commas/0x: `1900`, `"19 00"`, `0x19,0x00`.
fn parse_hex(s: &str) -> Result<Bytes, String> {
    let cleaned: String = s
        .split([' ', ',', ':'])
        .map(|t| t.trim_start_matches("0x").trim_start_matches("0X"))
        .collect();
    if cleaned.is_empty() || cleaned.len() % 2 != 0 || !cleaned.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(format!("'{}' is not hex bytes (e.g. 1900 or \"19 00\")", s));
    }
    Ok(Bytes((0..cleaned.len() / 2).map(|i| u8::from_str_radix(&cleaned[2 * i..2 * i + 2], 16).unwrap()).collect()))
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

    /// Raw I2C on the expansion port, with the deck as master
    I2c {
        #[clap(subcommand)]
        command: I2cCommands,
    },

    /// Deck controllers (DeckCtrl) on the expansion-port I2C bus
    Deckctrl {
        #[clap(subcommand)]
        command: DeckctrlCommands,
    },

    /// Print what UART lines on the expansion port carry (sniffed, never driven)
    Uart(UartOptions),

    /// Switch the port's TX2/RX2 between UART2 and USB (the deck's hub port 4, for
    /// decks with a USB MCU there: D- = TX2, D+ = RX2); standalone only
    Mux {
        #[clap(value_enum)]
        mode: Option<MuxMode>,
        /// Seconds to wait for a USB device after switching to usb
        #[clap(long, default_value_t = 5.0)]
        wait: f64,
    },

    /// Hold an IO pin low, e.g. a deck MCU's BOOT line, or release it (open
    /// drain, never driven high; standalone only)
    Drive {
        #[clap(value_enum)]
        pin: IoPin,
        #[clap(value_enum)]
        level: DriveLevel,
    },

    /// Bridge the Crazyflie's UART1/UART2 to a serial port of the deck, with the
    /// deck standing in for the Crazyflie (standalone only)
    Bridge(BridgeOptions),

    /// Check the deck's firmware against the GitHub releases and install
    /// updates through the USB bootloaders (private repos: `gh auth login`)
    Update(UpdateOptions),

    /// Print a target's SWO trace (ITM, e.g. the Crazyflie's DEBUG_PRINT)
    Swo(SwoOptions),

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
enum MuxMode {
    /// TX2/RX2 to the deck's UART2 (power-on default)
    Uart,
    /// TX2/RX2 to the hub's port 4 as USB Full Speed
    Usb,
    /// Disconnected
    Off,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum IoPin {
    #[value(name = "IO_1")]
    Io1,
    #[value(name = "IO_2")]
    Io2,
    #[value(name = "IO_3")]
    Io3,
    #[value(name = "IO_4")]
    Io4,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum DriveLevel {
    Low,
    Release,
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
        /// Only transactions on this chip select. The other IO lines are then
        /// left out of the decode; without it, the lines that change in the
        /// middle of bytes are (e.g. IO_3 on a Flow 3.0, its flash chip select)
        #[clap(long, value_enum)]
        cs: Option<ChipSelect>,
    },
}

/// How to get onto the expansion-port I2C bus.
#[derive(Debug, Args)]
struct BusArgs {
    /// SCL rate (the Crazyflie runs the deck bus at 400 kHz)
    #[clap(long, default_value = "400k", value_parser = parse_rate, value_name = "RATE")]
    i2c_rate: u32,

    /// Switch the port's VCC on without asking if it is unpowered
    #[clap(long)]
    power: bool,

    /// Drive the bus even though a Crazyflie seems to be its master
    #[clap(long)]
    force: bool,
}

#[derive(Debug, Subcommand)]
enum I2cCommands {
    /// List the addresses that acknowledge (skips the DeckCtrl reset/listen
    /// addresses 0x41/0x42, which have side effects)
    Scan {
        #[clap(flatten)]
        bus: BusArgs,
    },
    /// Read bytes, optionally writing a register address first (repeated START)
    Read {
        /// 7-bit address, e.g. 0x44
        #[clap(value_parser = parse_byte)]
        addr: u8,
        /// How many bytes (1-512)
        len: usize,
        /// Bytes to write first, e.g. 1900 for a 16-bit register
        #[clap(long, value_parser = parse_hex, value_name = "HEX")]
        reg: Option<Bytes>,
        #[clap(flatten)]
        bus: BusArgs,
    },
    /// Write bytes
    Write {
        /// 7-bit address, e.g. 0x44
        #[clap(value_parser = parse_byte)]
        addr: u8,
        /// Bytes, e.g. 10 00 ff or 1000ff
        #[clap(value_parser = parse_hex, num_args = 1.., required = true)]
        data: Vec<Bytes>,
        #[clap(flatten)]
        bus: BusArgs,
    },
    /// Clock SCL until a stuck device releases SDA
    Recover,
}

/// Which deck controller, and how to reach the bus.
#[derive(Debug, Args)]
struct DeckArgs {
    /// Address (0x44), index (0), name or CPU ID prefix; asks when several
    #[clap(short = 'D', long, value_name = "DECK")]
    deck: Option<String>,

    #[clap(flatten)]
    bus: BusArgs,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum Direction {
    In,
    Out,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum Level {
    High,
    Low,
}

#[derive(Debug, Subcommand)]
enum DeckctrlCommands {
    /// Enumerate the deck controllers as a Crazyflie does (resets them all)
    Scan {
        #[clap(flatten)]
        bus: BusArgs,
    },
    /// Identification page, CPU ID and GPIO state of one deck
    Info {
        #[clap(flatten)]
        deck: DeckArgs,
    },
    /// Show or set the deck controller's GPIOs (prompts when omitted)
    Gpio {
        #[clap(subcommand)]
        command: Option<GpioCommands>,
        #[clap(flatten)]
        deck: DeckArgs,
    },
    /// Read registers
    Read {
        /// Register address, hex (e.g. 1900)
        #[clap(value_parser = parse_reg)]
        reg: u16,
        /// How many bytes
        len: usize,
        #[clap(flatten)]
        deck: DeckArgs,
    },
    /// Write registers
    Write {
        /// Register address, hex (e.g. 1f00)
        #[clap(value_parser = parse_reg)]
        reg: u16,
        /// Bytes, e.g. de ad be ef or deadbeef
        #[clap(value_parser = parse_hex, num_args = 1.., required = true)]
        data: Vec<Bytes>,
        #[clap(flatten)]
        deck: DeckArgs,
    },
    /// Reset every deck controller to its power-on state
    Reset {
        #[clap(flatten)]
        bus: BusArgs,
    },
}

#[derive(Debug, Subcommand)]
enum GpioCommands {
    /// Direction and level of every GPIO
    Show,
    /// Make GPIOs inputs or outputs
    Dir {
        /// GPIOs: 3, 0,4,12, 0-3, PA4, all
        pins: String,
        #[clap(value_enum)]
        dir: Direction,
    },
    /// Set the output level (takes effect on outputs)
    Level {
        /// GPIOs: 3, 0,4,12, 0-3, PA4, all
        pins: String,
        #[clap(value_enum)]
        level: Level,
    },
    /// Drive GPIOs: set the level, then make them outputs (no glitch)
    Out {
        /// GPIOs: 3, 0,4,12, 0-3, PA4, all
        pins: String,
        #[clap(value_enum)]
        level: Level,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum Signal {
    #[value(name = "IO_1")]
    Io1,
    #[value(name = "IO_2")]
    Io2,
    #[value(name = "IO_3")]
    Io3,
    #[value(name = "IO_4")]
    Io4,
    #[value(name = "MISO")]
    Miso,
    #[value(name = "OW")]
    Ow,
    #[value(name = "SCK")]
    Sck,
    #[value(name = "MOSI")]
    Mosi,
    #[value(name = "WKUP")]
    Wkup,
    #[value(name = "N_IO_1")]
    NIo1,
    #[value(name = "TX2")]
    Tx2,
    #[value(name = "RX2")]
    Rx2,
    #[value(name = "TX1")]
    Tx1,
    #[value(name = "RX1")]
    Rx1,
    #[value(name = "SDA")]
    Sda,
    #[value(name = "SCL")]
    Scl,
}

#[derive(Debug, Args)]
struct UartOptions {
    /// Lines to decode (named as on the Crazyflie: RX1 is what a deck sends
    /// the CF on UART1)
    #[clap(short, long, value_enum, value_delimiter = ',', default_value = "TX1,RX1,TX2,RX2")]
    line: Vec<Signal>,

    /// Baud rate
    #[clap(short, long, default_value_t = 115200)]
    baud: u32,

    /// Sample rate; default 16x the baud rate, at least 1 Msps
    #[clap(short, long, value_parser = parse_rate)]
    rate: Option<u32>,

    /// How long to listen; until Ctrl-C when omitted
    #[clap(short = 't', long, value_parser = parse_duration)]
    duration: Option<std::time::Duration>,

    /// Print bytes as hex instead of text
    #[clap(long)]
    hex: bool,
}

#[derive(Debug, Args)]
struct BridgeOptions {
    /// Which UART
    #[clap(value_enum)]
    uart: BridgeUart,

    /// On or off
    #[clap(value_enum)]
    state: OnOff,

    /// Switch the port's VCC and VCOM on without asking if needed
    #[clap(long)]
    power: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum BridgeUart {
    #[value(name = "1")]
    Uart1,
    #[value(name = "2")]
    Uart2,
    Both,
}

#[derive(Debug, Args)]
struct UpdateOptions {
    /// Which firmware; both when omitted
    #[clap(value_enum)]
    chip: Option<UpdateChip>,

    /// Only show installed and latest versions
    #[clap(long)]
    check: bool,

    /// Install this release instead of the latest, e.g. 0.8.0 (one chip)
    #[clap(long, value_name = "TAG", conflicts_with = "file")]
    version: Option<String>,

    /// Install this UF2 instead of a release (one chip)
    #[clap(long, value_hint = ValueHint::FilePath)]
    file: Option<std::path::PathBuf>,

    /// Consider prereleases too
    #[clap(long)]
    pre: bool,

    /// Reinstall even when the installed version is current
    #[clap(long)]
    force: bool,

    /// Don't ask before installing
    #[clap(short, long)]
    yes: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
enum UpdateChip {
    /// The RP2350 (control, capture; carries the FX2 firmware)
    Rp2350,
    /// The RP2040 debug probe
    Probe,
}

#[derive(Debug, Args)]
struct SwoOptions {
    /// Probe port the target is on: 1 (P1) or 2 (P5); the others have no SWO
    #[clap(long, default_value_t = 1, value_parser = clap::value_parser!(u8).range(1..=2))]
    swd: u8,

    /// SWO baud rate; must match the target's TPIU (the Crazyflie firmware's
    /// CONFIG_DEBUG_PRINT_ON_SWO_BAUDRATE, 2000000 by default)
    #[clap(short, long, default_value_t = 2_000_000)]
    baud: u32,

    /// ITM stimulus ports to print (DEBUG_PRINT is port 0)
    #[clap(short, long, value_delimiter = ',', default_value = "0",
           value_parser = clap::value_parser!(u8).range(0..32))]
    port: Vec<u8>,

    /// How long to listen; until Ctrl-C when omitted
    #[clap(short = 't', long, value_parser = parse_duration)]
    duration: Option<std::time::Duration>,

    /// Print payloads as hex instead of text
    #[clap(long)]
    hex: bool,

    /// Print the raw SWO bytes, without decoding ITM
    #[clap(long)]
    raw: bool,

    /// Do not switch the target's debug port to SWD (SWO is silent in JTAG mode)
    #[clap(long)]
    no_swd: bool,
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

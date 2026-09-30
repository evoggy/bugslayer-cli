// SWO viewer: read the probe's SWO serial port (P1 = the Crazyflie's STM32)
// and decode the ITM packets on it.
//
// The RP2040 probe receives SWO on UART1 and forwards the raw bytes on its
// "SWO ACM0" CDC port, so the host sets the baud rate and decodes ITM here.
// The target's TPIU must be set up for NRZ at the same rate (the Crazyflie
// firmware does it with CONFIG_DEBUG_PRINT_ON_SWO).
//
// Only SWD1 (P1) and SWD2 (P5) have an SWO line; both are UART1 RX, so one at
// a time. DAP vendor commands 0x81/0x82 bind ACM0 to SWO1/SWO2.
//
// The STM32 only drives SWO (PB3, JTDO/TRACESWO) while its SWJ-DP is in SWD
// mode. It powers up in JTAG mode, and OpenOCD switches it back to JTAG when it
// exits, so SWO goes silent after every debug session. The keeper thread
// switches it to SWD through the port's DAP interface at start, whenever a
// debugger releases that port, and when SWO goes quiet (a session can be too
// short to see).

use std::io::{Read, Write};
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::{bail, Context, Result};
use colored::Colorize;

use bugslayer::swo::{keeper, port_name, route, swo_port, Counts, Itm, KeeperEvent, Packet};

use crate::device::Deck;
use crate::error::CliError;

pub struct Options {
    /// Probe port with the target: 1 (P1) or 2 (P5).
    pub swd: u8,
    pub baud: u32,
    /// ITM stimulus ports to print.
    pub ports: Vec<u8>,
    pub duration: Option<Duration>,
    pub hex: bool,
    pub raw: bool,
    pub no_swd: bool,
}

/// The keeper's news, as bsly always printed it.
fn keeper_event(swd: u8, e: KeeperEvent) {
    match e {
        KeeperEvent::CannotOpen(e) => {
            eprintln!("{} cannot open the probe ({}); not switching the target to SWD", "warning:".yellow(), e)
        }
        KeeperEvent::DebuggerReleased => eprintln!(
            "{}",
            format!("(debugger released {}: switching the target back to SWD)", port_name(swd)).dimmed()
        ),
        KeeperEvent::SwitchFailed(e) => eprintln!("{} SWD switch failed: {}", "warning:".yellow(), e),
        KeeperEvent::DebuggerBusy => eprintln!("{}", format!("(a debugger is using {})", port_name(swd)).dimmed()),
        KeeperEvent::CannotClaim(e) => {
            eprintln!("{} cannot claim the probe's {} interface: {}", "warning:".yellow(), port_name(swd), e)
        }
    }
}

/// Prints the selected ports: port writes of one byte as text (or hex),
/// wider writes and non-zero ports as tagged values on their own line.
struct Printer {
    ports: Vec<u8>,
    hex: bool,
    tagged: bool,
    at_line_start: bool,
}

impl Printer {
    fn packet(&mut self, out: &mut impl Write, port: u8, len: u8, value: u32) -> std::io::Result<()> {
        if !self.ports.contains(&port) {
            return Ok(());
        }
        let bytes = &value.to_le_bytes()[..len as usize];
        if self.tagged && (port != 0 || self.hex) {
            if !self.at_line_start {
                writeln!(out)?;
            }
            writeln!(out, "{} {:0w$x}", format!("[p{}]", port).cyan(), value, w = 2 * len as usize)?;
            self.at_line_start = true;
        } else if self.hex {
            for b in bytes {
                write!(out, "{:02x} ", b)?;
            }
        } else {
            out.write_all(bytes)?;
            self.at_line_start = bytes.last() == Some(&b'\n');
        }
        Ok(())
    }
}

pub fn run(deck: &Deck, opts: &Options) -> Result<()> {
    let Some(probe) = deck.probe.clone() else {
        bail!(CliError::Connection(format!("deck {} has no RP2040 probe on USB", deck.serial)));
    };
    let path = swo_port(&probe)?;
    route(&probe, opts.swd)?;
    let mut port = serialport::new(&path, opts.baud)
        .timeout(Duration::from_millis(100))
        .open()
        .with_context(|| format!("opening {}", path))?;

    let stop = Arc::new(AtomicBool::new(false));
    {
        let stop = stop.clone();
        let _ = ctrlc::set_handler(move || stop.store(true, Ordering::Relaxed));
    }
    let swd = opts.swd;
    let start = Instant::now();
    let last_rx = Arc::new(AtomicU64::new(0));
    let keeper = (!opts.no_swd).then(|| {
        let stop = stop.clone();
        let last_rx = last_rx.clone();
        std::thread::spawn(move || keeper(probe, swd, stop, start, last_rx, |e| keeper_event(swd, e)))
    });

    eprintln!(
        "{} {} at {} baud, ITM port{} {}, {}  (Ctrl-C stops)",
        "swo".green().bold(),
        port_name(opts.swd),
        opts.baud,
        if opts.ports.len() == 1 { "" } else { "s" },
        opts.ports.iter().map(|p| p.to_string()).collect::<Vec<_>>().join(","),
        match opts.duration {
            Some(d) => format!("for {:.1} s", d.as_secs_f64()),
            None => "until Ctrl-C".into(),
        }
    );

    let mut itm = Itm::new();
    let mut n = Counts::default();
    let mut printer = Printer {
        tagged: opts.ports.len() > 1 || opts.ports != [0],
        ports: opts.ports.clone(),
        hex: opts.hex,
        at_line_start: true,
    };
    let mut buf = [0u8; 4096];
    let stdout = std::io::stdout();
    while !stop.load(Ordering::Relaxed) && opts.duration.is_none_or(|d| start.elapsed() < d) {
        let len = match port.read(&mut buf) {
            Ok(len) => len,
            Err(e) if e.kind() == std::io::ErrorKind::TimedOut => 0,
            Err(e) => return Err(CliError::Connection(format!("reading {}: {}", path, e)).into()),
        };
        n.bytes += len as u64;
        if len > 0 {
            last_rx.store(start.elapsed().as_millis() as u64, Ordering::Relaxed);
        }
        let mut out = stdout.lock();
        if opts.raw {
            for b in &buf[..len] {
                write!(out, "{:02x} ", b)?;
            }
        } else {
            for &b in &buf[..len] {
                let Some(p) = itm.push(b) else { continue };
                n.packet(&p);
                if let Packet::Stimulus { port, len, value } = p {
                    printer.packet(&mut out, port, len, value)?;
                }
            }
        }
        out.flush()?;
    }
    stop.store(true, Ordering::Relaxed);
    if let Some(k) = keeper {
        let _ = k.join();
    }

    if !printer.at_line_start || opts.raw {
        println!();
    }
    eprintln!(
        "{} {} bytes, {} stimulus packets, {} hardware, {} overflows, {} invalid",
        "swo".green().bold(),
        n.bytes,
        n.stimulus,
        n.hardware,
        n.overflow,
        n.invalid
    );
    if n.invalid > 0 {
        eprintln!(
            "{} invalid ITM headers: is the target's SWO baud rate {}?",
            "warning:".yellow(),
            opts.baud
        );
    }
    if n.bytes == 0 {
        eprintln!(
            "{}",
            "nothing received: is SWO enabled in the target firmware (CONFIG_DEBUG_PRINT_ON_SWO)?".dimmed()
        );
    }
    Ok(())
}

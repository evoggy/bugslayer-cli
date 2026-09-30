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
use nusb::transfer::{Bulk, In, Out};
use nusb::{DeviceInfo, MaybeFuture};

use crate::device::{Deck, PID_PROBE, VID};
use crate::error::CliError;

/// The probe's CMSIS-DAP interfaces: interface n is port SWDn.
const DAP_ITFS: u8 = 4;
/// "SWO ACM0": the CDC port the selected SWO is routed to.
const SWO_CDC_ITF: u8 = 4;
/// DAP vendor command binding ACM0 to SWO1; +1 for SWO2.
const ROUTE_ACM0_SWO1: u8 = 0x81;
/// How often the keeper checks whether a debugger has released the port.
const KEEPER_POLL: Duration = Duration::from_millis(100);
/// A debug session too short to see between polls also leaves the target in
/// JTAG mode, so switch again after this long without SWO data...
const KEEPER_SILENCE: Duration = Duration::from_secs(1);
/// ...but not more often than this while the target stays quiet.
const KEEPER_RETRY: Duration = Duration::from_secs(2);

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

/// One decoded ITM packet.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Packet {
    /// Software source: a write of `len` bytes to stimulus port `port`.
    Stimulus { port: u8, len: u8, value: u32 },
    /// Hardware source (DWT): discriminator `id`.
    Hardware { id: u8, len: u8, value: u32 },
    /// The ITM dropped packets.
    Overflow,
    /// Timestamp and extension packets (not used here).
    Other,
    /// A header byte that is no valid packet (lost sync or wrong baud rate).
    Invalid(u8),
}

#[derive(Debug)]
enum State {
    Header,
    /// Collecting a source packet's payload.
    Payload { hw: bool, addr: u8, len: u8, got: u8, value: u32 },
    /// Skipping continuation bytes (bit 7 set) of a timestamp/extension.
    Continuation,
}

/// Byte-at-a-time ITM packet decoder (ARMv7-M ARM, appendix D4).
pub struct Itm {
    state: State,
    zeros: u32,
}

impl Itm {
    pub fn new() -> Itm {
        Itm { state: State::Header, zeros: 0 }
    }

    pub fn push(&mut self, b: u8) -> Option<Packet> {
        match self.state {
            State::Payload { hw, addr, len, got, value } => {
                let value = value | (b as u32) << (8 * got);
                if got + 1 == len {
                    self.state = State::Header;
                    return Some(if hw {
                        Packet::Hardware { id: addr, len, value }
                    } else {
                        Packet::Stimulus { port: addr, len, value }
                    });
                }
                self.state = State::Payload { hw, addr, len, got: got + 1, value };
                None
            }
            State::Continuation => {
                if b & 0x80 == 0 {
                    self.state = State::Header;
                }
                None
            }
            State::Header => {
                let zeros = std::mem::replace(&mut self.zeros, 0);
                match b {
                    // Synchronization: at least 47 zero bits then a one.
                    0x00 => {
                        self.zeros = zeros + 1;
                        None
                    }
                    0x80 if zeros >= 5 => None,
                    0x70 => Some(Packet::Overflow),
                    _ if b & 0x03 != 0 => {
                        let len = [0, 1, 2, 4][(b & 0x03) as usize];
                        self.state = State::Payload { hw: b & 0x04 != 0, addr: b >> 3, len, got: 0, value: 0 };
                        None
                    }
                    // Local timestamp (xxxx0000), extension (xxxx1x00) and
                    // global timestamp (10x10100) headers.
                    _ if b & 0x0F == 0x00 || b & 0x0B == 0x08 || b == 0x94 || b == 0xB4 => {
                        if b & 0x80 != 0 {
                            self.state = State::Continuation;
                        }
                        Some(Packet::Other)
                    }
                    _ => Some(Packet::Invalid(b)),
                }
            }
        }
    }
}

/// The probe's SWO serial port for this deck.
fn swo_port(probe: &DeviceInfo) -> Result<String> {
    let serial = probe.serial_number().unwrap_or("");
    let ports = serialport::available_ports().unwrap_or_default();
    ports
        .into_iter()
        .find(|p| match &p.port_type {
            serialport::SerialPortType::UsbPort(u) => {
                u.vid == VID
                    && u.pid == PID_PROBE
                    && u.serial_number.as_deref() == Some(serial)
                    && u.interface == Some(SWO_CDC_ITF)
            }
            _ => false,
        })
        .map(|p| p.port_name)
        .ok_or_else(|| {
            CliError::Connection(format!(
                "the probe {} has no SWO serial port (is the cdc_acm driver bound?)",
                serial
            ))
            .into()
        })
}

/// Where port SWDn is on USB.
fn port_name(swd: u8) -> &'static str {
    match swd {
        1 => "SWD1 (P1)",
        _ => "SWD2 (P5)",
    }
}

/// One CMSIS-DAP command/response on an open DAP interface.
pub(crate) fn dap(intf: &nusb::Interface, cmd: &[u8]) -> Result<Vec<u8>> {
    let timeout = Duration::from_millis(500);
    // Interface n has OUT endpoint 0x04 + 2n and IN endpoint 0x85 + 2n.
    let n = intf.interface_number();
    let mut out = intf.endpoint::<Bulk, Out>(0x04 + 2 * n)?;
    out.transfer_blocking(cmd.to_vec().into(), timeout).status?;
    let mut inp = intf.endpoint::<Bulk, In>(0x85 + 2 * n)?;
    let c = inp.transfer_blocking(inp.allocate(512), timeout);
    c.status?;
    let r = c.buffer[..c.actual_len].to_vec();
    if r.first() != Some(&cmd[0]) {
        bail!("CMSIS-DAP command 0x{:02x} got reply {:02x?}", cmd[0], r);
    }
    Ok(r)
}

/// Put the target's SWJ-DP in SWD mode and read DPIDR. Leaves the target
/// running and the probe's pins parked.
fn switch_to_swd(intf: &nusb::Interface) -> Result<u32> {
    let r = dap(intf, &[0x02, 1])?; // DAP_Connect, SWD
    if r.get(1) != Some(&1) {
        bail!("the probe refused to connect in SWD mode");
    }
    let result = (|| {
        dap(intf, &[0x11, 0x40, 0x42, 0x0F, 0x00])?; // DAP_SWJ_Clock 1 MHz
        let reset = [0x12, 56, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];
        dap(intf, &reset)?; // line reset
        dap(intf, &[0x12, 16, 0x9E, 0xE7])?; // JTAG-to-SWD
        dap(intf, &reset)?;
        dap(intf, &[0x12, 8, 0x00])?; // idle
        let r = dap(intf, &[0x05, 0, 1, 0x02])?; // DAP_Transfer: read DPIDR
        if r.len() < 7 || r[1] != 1 || r[2] != 1 {
            bail!("the target did not answer on SWD (ack {:?})", r.get(2));
        }
        Ok(u32::from_le_bytes([r[3], r[4], r[5], r[6]]))
    })();
    let _ = dap(intf, &[0x03]); // DAP_Disconnect: parks the pins
    result
}

/// Route port `swd`'s SWO to ACM0, through that port's DAP interface or,
/// when a debugger holds it, any free one.
fn route(probe: &DeviceInfo, swd: u8) -> Result<()> {
    let dev = probe.open().wait().context("opening the probe")?;
    let order = std::iter::once(swd).chain((0..DAP_ITFS).filter(|&i| i != swd));
    for itf in order {
        if let Ok(intf) = dev.claim_interface(itf).wait() {
            dap(&intf, &[ROUTE_ACM0_SWO1 + swd - 1])?;
            return Ok(());
        }
    }
    bail!(CliError::Connection("every CMSIS-DAP interface of the probe is in use".into()))
}

/// Keeps the target in SWD mode: at start, whenever a debugger that held the
/// port (so could have left it in JTAG mode) lets go of it, and when SWO goes
/// quiet. `last_rx` is when SWO data last arrived, in ms since `t0`.
fn keeper(probe: DeviceInfo, swd: u8, stop: Arc<AtomicBool>, t0: Instant, last_rx: Arc<AtomicU64>) {
    let dev = match probe.open().wait() {
        Ok(d) => d,
        Err(e) => {
            eprintln!("{} cannot open the probe ({}); not switching the target to SWD", "warning:".yellow(), e);
            return;
        }
    };
    let mut need_switch = true;
    let mut busy = false;
    let mut last_switch = t0;
    while !stop.load(Ordering::Relaxed) {
        let quiet = t0.elapsed().saturating_sub(Duration::from_millis(last_rx.load(Ordering::Relaxed)));
        if quiet > KEEPER_SILENCE && last_switch.elapsed() > KEEPER_RETRY {
            need_switch = true;
        }
        match dev.claim_interface(swd).wait() {
            Ok(intf) => {
                if busy {
                    eprintln!(
                        "{}",
                        format!("(debugger released {}: switching the target back to SWD)", port_name(swd)).dimmed()
                    );
                }
                busy = false;
                if need_switch {
                    last_switch = Instant::now();
                    match switch_to_swd(&intf) {
                        Ok(_) => need_switch = false,
                        Err(e) => eprintln!("{} SWD switch failed: {:#}", "warning:".yellow(), e),
                    }
                }
            }
            Err(e) if e.kind() == nusb::ErrorKind::Busy => {
                if !busy {
                    eprintln!("{}", format!("(a debugger is using {})", port_name(swd)).dimmed());
                }
                busy = true;
                need_switch = true;
            }
            Err(e) => {
                eprintln!("{} cannot claim the probe's {} interface: {}", "warning:".yellow(), port_name(swd), e);
                return;
            }
        }
        std::thread::sleep(KEEPER_POLL);
    }
}

#[derive(Default)]
struct Counts {
    bytes: u64,
    stimulus: u64,
    hardware: u64,
    overflow: u64,
    invalid: u64,
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
        std::thread::spawn(move || keeper(probe, swd, stop, start, last_rx))
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
                match itm.push(b) {
                    Some(Packet::Stimulus { port, len, value }) => {
                        n.stimulus += 1;
                        printer.packet(&mut out, port, len, value)?;
                    }
                    Some(Packet::Hardware { .. }) => n.hardware += 1,
                    Some(Packet::Overflow) => n.overflow += 1,
                    // Joining a live stream mid-packet looks like invalid
                    // headers until the first packet decodes.
                    Some(Packet::Invalid(_)) if n.stimulus + n.hardware > 0 => n.invalid += 1,
                    Some(Packet::Invalid(_)) => {}
                    Some(Packet::Other) | None => {}
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

#[cfg(test)]
mod tests {
    use super::*;

    fn decode(bytes: &[u8]) -> Vec<Packet> {
        let mut itm = Itm::new();
        bytes.iter().filter_map(|&b| itm.push(b)).collect()
    }

    #[test]
    fn stimulus_packets_of_each_size() {
        assert_eq!(
            decode(&[0x01, b'H', 0x0A, 0x34, 0x12, 0x0B, 0x78, 0x56, 0x34, 0x12]),
            vec![
                Packet::Stimulus { port: 0, len: 1, value: b'H' as u32 },
                Packet::Stimulus { port: 1, len: 2, value: 0x1234 },
                Packet::Stimulus { port: 1, len: 4, value: 0x1234_5678 },
            ]
        );
    }

    #[test]
    fn sync_overflow_and_hardware() {
        assert_eq!(
            decode(&[0, 0, 0, 0, 0, 0x80, 0x70, 0x0F, 1, 2, 3, 4, 0x01, b'x']),
            vec![
                Packet::Overflow,
                Packet::Hardware { id: 1, len: 4, value: 0x0403_0201 },
                Packet::Stimulus { port: 0, len: 1, value: b'x' as u32 },
            ]
        );
    }

    #[test]
    fn timestamps_skip_their_continuation_bytes() {
        // Local timestamp with two continuation bytes, then a 1-byte write
        // whose payload (0x80) must not be taken for a header.
        assert_eq!(
            decode(&[0xC0, 0x85, 0x01, 0x01, 0x80]),
            vec![Packet::Other, Packet::Stimulus { port: 0, len: 1, value: 0x80 }]
        );
    }

    #[test]
    fn invalid_header() {
        assert_eq!(decode(&[0x04]), vec![Packet::Invalid(0x04)]);
    }
}

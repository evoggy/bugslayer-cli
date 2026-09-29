// Finding a deck and talking to its control plane.
//
// One board is three USB devices behind the on-board hub (docs/protocol.md in
// bugslayer-deck-firmware): the RP2040 probe (DB11), the RP2350 control plane
// (DB12) and the FX2 capture pipe (DB13). The FX2 reports the RP2350's serial,
// which is how the two halves of one deck are paired. The probe has its own
// serial and is paired by hub: it sits on the same hub as the RP2350.

use std::collections::BTreeMap;
use std::io::{BufRead, BufReader, Write};
use std::time::{Duration, Instant};

use anyhow::{bail, Context, Result};
use nusb::{DeviceInfo, MaybeFuture};

use crate::error::CliError;

pub const VID: u16 = 0x35F0;
pub const PID_PROBE: u16 = 0xDB11;
pub const PID_CTRL: u16 = 0xDB12;
pub const PID_FX2: u16 = 0xDB13;
/// The FX2's boot ROM, when no EEPROM answers (`fx2 boot rom`).
pub const FX2_ROM: (u16, u16) = (0x04B4, 0x8613);
/// The RP2350 bootrom in BOOTSEL.
pub const RP2350_BOOTSEL: (u16, u16) = (0x2E8A, 0x000F);

/// One deck, as found on USB.
#[derive(Debug, Clone)]
pub struct Deck {
    pub serial: String,
    /// The control CDC port, e.g. /dev/ttyACM1.
    pub port: Option<String>,
    pub ctrl: DeviceInfo,
    /// The FX2 with this deck's serial, if it is up.
    pub fx2: Option<DeviceInfo>,
    /// The RP2040 probe on the same hub.
    pub probe: Option<DeviceInfo>,
}

impl Deck {
    pub fn port(&self) -> Result<&str> {
        self.port.as_deref().ok_or_else(|| {
            CliError::Connection(format!(
                "deck {} has no control serial port (is the cdc_acm driver bound?)",
                self.serial
            ))
            .into()
        })
    }
}

fn hub_of(d: &DeviceInfo) -> (u8, Vec<u8>) {
    let chain = d.port_chain();
    (d.busnum(), chain[..chain.len().saturating_sub(1)].to_vec())
}

pub fn list_devices() -> Result<Vec<DeviceInfo>> {
    Ok(nusb::list_devices()
        .wait()
        .map_err(|e| CliError::Connection(format!("listing USB devices: {}", e)))?
        .collect())
}

/// Every connected deck, sorted by serial.
pub fn list_decks() -> Result<Vec<Deck>> {
    let devs = list_devices()?;
    let ports = serialport::available_ports().unwrap_or_default();
    let is = |d: &DeviceInfo, pid| d.vendor_id() == VID && d.product_id() == pid;
    let mut decks: Vec<Deck> = devs
        .iter()
        .filter(|d| is(d, PID_CTRL))
        .map(|ctrl| {
            let serial = ctrl.serial_number().unwrap_or("").to_string();
            let port = ports
                .iter()
                .find(|p| match &p.port_type {
                    serialport::SerialPortType::UsbPort(u) => {
                        u.vid == VID && u.pid == PID_CTRL && u.serial_number.as_deref() == Some(&serial)
                    }
                    _ => false,
                })
                .map(|p| p.port_name.clone());
            let fx2 = devs
                .iter()
                .find(|d| is(d, PID_FX2) && d.serial_number() == Some(&serial))
                .cloned();
            let probe = devs
                .iter()
                .find(|d| is(d, PID_PROBE) && hub_of(d) == hub_of(ctrl))
                .cloned();
            Deck { serial, port, ctrl: ctrl.clone(), fx2, probe }
        })
        .collect();
    decks.sort_by(|a, b| a.serial.cmp(&b.serial));
    Ok(decks)
}

/// The deck to use: `--serial` if given, else the only one connected, else the
/// selected one (`bsly select`), else ask.
pub fn find_deck(serial: Option<&str>, selected: Option<&str>, non_interactive: bool) -> Result<Deck> {
    let decks = list_decks()?;
    if let Some(s) = serial {
        return decks
            .into_iter()
            .find(|d| d.serial.eq_ignore_ascii_case(s))
            .ok_or_else(|| CliError::NotFound(format!("no deck with serial {}", s)).into());
    }
    if decks.is_empty() {
        let devs = list_devices()?;
        let seen = |id: (u16, u16)| devs.iter().any(|d| (d.vendor_id(), d.product_id()) == id);
        let why = if seen(RP2350_BOOTSEL) {
            " (an RP2350 is in BOOTSEL: flash the deck firmware)"
        } else {
            ""
        };
        bail!(CliError::Connection(format!(
            "no Bugslayer deck ({:04x}:{:04x}) found{}",
            VID, PID_CTRL, why
        )));
    }
    if decks.len() == 1 {
        return Ok(decks.into_iter().next().unwrap());
    }
    if let Some(sel) = selected {
        if let Some(d) = decks.iter().find(|d| d.serial == sel) {
            return Ok(d.clone());
        }
    }
    crate::require_arg(non_interactive, "--serial: several decks are connected")?;
    let labels: Vec<String> = decks.iter().map(describe).collect();
    let pick = inquire::Select::new("Several decks are connected, which one?", labels.clone())
        .prompt()?;
    let idx = labels.iter().position(|l| *l == pick).unwrap();
    Ok(decks.into_iter().nth(idx).unwrap())
}

pub fn describe(d: &Deck) -> String {
    format!(
        "{}  {}  fx2 {}  probe {}",
        d.serial,
        d.port.as_deref().unwrap_or("(no port)"),
        if d.fx2.is_some() { "up" } else { "down" },
        if d.probe.is_some() { "yes" } else { "no" }
    )
}

pub fn speed_name(d: &DeviceInfo) -> &'static str {
    match d.speed() {
        Some(nusb::Speed::Low) => "Low Speed",
        Some(nusb::Speed::Full) => "Full Speed",
        Some(nusb::Speed::High) => "High Speed",
        Some(nusb::Speed::Super | nusb::Speed::SuperPlus) => "SuperSpeed",
        _ => "",
    }
}

/// The FX2 with `serial`. It only exists once the RP2350 has booted it, and
/// enumerates a moment after `fx2 up`, so wait for it.
pub fn wait_fx2(serial: &str, timeout: Duration) -> Result<DeviceInfo> {
    let deadline = Instant::now() + timeout;
    loop {
        if let Some(d) = list_devices()?
            .into_iter()
            .find(|d| d.vendor_id() == VID && d.product_id() == PID_FX2 && d.serial_number() == Some(serial))
        {
            return Ok(d);
        }
        if Instant::now() > deadline {
            bail!(CliError::Connection(format!(
                "no FX2 ({:04x}:{:04x}) with serial {}; bring it up with `bsly fx2 up`",
                VID, PID_FX2, serial
            )));
        }
        std::thread::sleep(Duration::from_millis(200));
    }
}

/// The ASCII line protocol on the RP2350's CDC interface.
pub struct Control {
    reader: BufReader<Box<dyn serialport::SerialPort>>,
    debug: bool,
}

impl Control {
    pub fn open(deck: &Deck, debug: bool) -> Result<Control> {
        let path = deck.port()?;
        let port = serialport::new(path, 115_200)
            .timeout(Duration::from_millis(20))
            .open()
            .map_err(|e| CliError::Connection(format!("opening {}: {}", path, e)))?;
        Ok(Control { reader: BufReader::new(port), debug })
    }

    fn send(&mut self, line: &str) -> Result<()> {
        if self.debug {
            eprintln!("> {}", line);
        }
        let port = self.reader.get_mut();
        let _ = port.clear(serialport::ClearBuffer::Input);
        port.write_all(format!("{}\n", line).as_bytes())
            .with_context(|| format!("sending '{}'", line))?;
        Ok(())
    }

    fn read_line(&mut self) -> Result<Option<String>> {
        let mut buf = Vec::new();
        match self.reader.read_until(b'\n', &mut buf) {
            Ok(_) => {}
            Err(e) if e.kind() == std::io::ErrorKind::TimedOut => {
                // A partial line stays in `buf`; keep it for the next call.
                if buf.is_empty() {
                    return Ok(None);
                }
                let mut rest = Vec::new();
                let deadline = Instant::now() + Duration::from_millis(200);
                while !buf.ends_with(b"\n") && Instant::now() < deadline {
                    rest.clear();
                    match self.reader.read_until(b'\n', &mut rest) {
                        Ok(_) => buf.extend_from_slice(&rest),
                        Err(e) if e.kind() == std::io::ErrorKind::TimedOut => buf.extend_from_slice(&rest),
                        Err(e) => return Err(e.into()),
                    }
                }
            }
            Err(e) => return Err(CliError::Connection(format!("reading the control port: {}", e)).into()),
        }
        let line = String::from_utf8_lossy(&buf).trim_end_matches(['\r', '\n']).to_string();
        if self.debug {
            eprintln!("< {}", line);
        }
        Ok(Some(line))
    }

    /// Send one command and return its (first, non-empty) reply line.
    pub fn command(&mut self, line: &str) -> Result<String> {
        self.send(line)?;
        let deadline = Instant::now() + Duration::from_secs(2);
        while Instant::now() < deadline {
            if let Some(reply) = self.read_line()? {
                if !reply.trim().is_empty() {
                    return Ok(reply);
                }
            }
        }
        bail!(CliError::Timeout(format!("no reply to '{}'", line)))
    }

    /// Send one command and collect every reply line until the port goes quiet
    /// (`help` and `stat` answer with several lines).
    pub fn query(&mut self, line: &str) -> Result<Vec<String>> {
        self.send(line)?;
        let mut out = Vec::new();
        let deadline = Instant::now() + Duration::from_secs(2);
        let mut last: Option<Instant> = None;
        while Instant::now() < deadline {
            match self.read_line()? {
                Some(reply) => {
                    out.push(reply);
                    last = Some(Instant::now());
                }
                None if last.is_some_and(|t| t.elapsed() > Duration::from_millis(60)) => break,
                None => {}
            }
        }
        if out.is_empty() {
            bail!(CliError::Timeout(format!("no reply to '{}'", line)));
        }
        Ok(out)
    }

    /// Send a command whose reply must be `<first word> ok ...`; a reply of
    /// `err ...` becomes `CliError::Rejected`.
    pub fn expect_ok(&mut self, line: &str) -> Result<String> {
        let reply = self.command(line)?;
        let word = line.split_whitespace().next().unwrap_or("");
        if reply.starts_with(&format!("{} ok", word)) {
            return Ok(reply);
        }
        let msg = reply.strip_prefix("err ").unwrap_or(&reply).to_string();
        bail!(CliError::Rejected(format!("'{}': {}", line, msg)))
    }
}

/// The `key=value` tokens of a reply line.
pub fn kv(line: &str) -> BTreeMap<String, String> {
    line.split_whitespace()
        .filter_map(|t| t.split_once('='))
        .map(|(k, v)| (k.to_string(), v.to_string()))
        .collect()
}

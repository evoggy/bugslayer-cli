// Live UART sniffer: sample the expansion port through the capture pipe and
// decode 8N1 on the host, printing text as it arrives.
//
// Needs no UART in the deck firmware and never drives a pin, so it works both
// standalone and in a Crazyflie stack (where TX1/TX2 are the CF's outputs).

use std::io::Write;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::{Context, Result};
use colored::{Color, Colorize};

use crate::capture::{self, Msg, Sink};
use crate::device::{self, Control, Deck};
use crate::stream::{Event, Verifier, CHANNEL_NAMES};

pub struct Options {
    /// Bits of the raw16 word, i.e. indices into CHANNEL_NAMES.
    pub lines: Vec<usize>,
    pub baud: u32,
    pub rate: u32,
    pub duration: Option<Duration>,
    pub hex: bool,
}

enum State {
    Idle,
    /// In a frame that started (falling edge) at sample `start`; `k` is the
    /// next bit to sample: 0 start, 1..=8 data, 9 stop.
    Frame { start: u64, k: u8, byte: u8, next: u64 },
}

/// One line's 8N1 receiver.
struct Rx {
    bit: usize,
    spb: f64,
    prev: bool,
    state: State,
    bytes: u64,
    framing: u64,
}

impl Rx {
    fn new(bit: usize, spb: f64) -> Rx {
        // Wait for the line to be seen idle (high) before the first start bit.
        Rx { bit, spb, prev: false, state: State::Idle, bytes: 0, framing: 0 }
    }

    fn at(&self, start: u64, k: u8) -> u64 {
        start + ((k as f64 + 0.5) * self.spb) as u64
    }

    /// Feed the sample with index `i`; returns a received byte.
    fn push(&mut self, i: u64, level: bool) -> Option<u8> {
        let mut out = None;
        match self.state {
            State::Idle => {
                if self.prev && !level {
                    self.state = State::Frame { start: i, k: 0, byte: 0, next: self.at(i, 0) };
                }
            }
            State::Frame { start, k, byte, next } if i >= next => match k {
                0 if level => self.state = State::Idle, // a glitch, not a start bit
                0 => self.state = State::Frame { start, k: 1, byte, next: self.at(start, 1) },
                1..=8 => {
                    let byte = byte | (level as u8) << (k - 1);
                    self.state = State::Frame { start, k: k + 1, byte, next: self.at(start, k + 1) };
                }
                _ => {
                    if level {
                        self.bytes += 1;
                        out = Some(byte);
                    } else {
                        self.framing += 1; // wrong baud, or a break
                    }
                    self.state = State::Idle;
                }
            },
            State::Frame { .. } => {}
        }
        self.prev = level;
        out
    }

    /// Samples were lost: drop any frame in flight.
    fn gap(&mut self) {
        self.state = State::Idle;
        self.prev = false;
    }
}

const COLORS: [Color; 4] = [Color::Cyan, Color::Magenta, Color::Yellow, Color::Green];

/// Text output: raw when one line is watched, else line-buffered with the
/// line's name in front.
struct Printer {
    names: Vec<&'static str>,
    pending: Vec<Vec<u8>>,
    last: Vec<Instant>,
    hex: bool,
}

impl Printer {
    fn show(&self, b: u8) -> String {
        match b {
            b'\n' | b'\t' => (b as char).to_string(),
            b'\r' => String::new(),
            0x20..=0x7e => (b as char).to_string(),
            _ => format!("\\x{:02x}", b).dimmed().to_string(),
        }
    }

    fn line(&mut self, idx: usize) {
        let text: String = self.pending[idx].iter().map(|&b| self.show(b)).collect();
        let tag = format!("{:<4}|", self.names[idx]).color(COLORS[idx % COLORS.len()]);
        println!("{} {}", tag, text.trim_end_matches('\n'));
        self.pending[idx].clear();
    }

    fn byte(&mut self, idx: usize, b: u8) {
        self.last[idx] = Instant::now();
        let mut so = std::io::stdout().lock();
        if self.hex {
            let tag = if self.names.len() > 1 { format!("{} ", self.names[idx]) } else { String::new() };
            let _ = writeln!(so, "{}{:02x}", tag.color(COLORS[idx % COLORS.len()]), b);
            return;
        }
        if self.names.len() == 1 {
            let _ = write!(so, "{}", self.show(b));
            let _ = so.flush();
            return;
        }
        drop(so);
        self.pending[idx].push(b);
        if b == b'\n' || self.pending[idx].len() >= 200 {
            self.line(idx);
        }
    }

    /// Print partial lines that have been quiet for a while.
    fn flush_idle(&mut self, after: Duration) {
        for i in 0..self.pending.len() {
            if !self.pending[i].is_empty() && self.last[i].elapsed() > after {
                self.line(i);
            }
        }
    }
}

pub fn run(deck: &Deck, ctl: &mut Control, opts: &Options, non_interactive: bool) -> Result<()> {
    let sink = if opts.rate > capture::USB_MAX_RATE { Sink::Fx2 } else { Sink::Usb };
    let info = capture::sink_device(deck, ctl, sink, non_interactive)?;
    let stop = Arc::new(AtomicBool::new(false));
    {
        let stop = stop.clone();
        let _ = ctrlc::set_handler(move || stop.store(true, Ordering::Relaxed));
    }
    let reader = capture::start_reader(&info, sink)?;
    let reply = ctl.expect_ok(&format!("arm {} pins {}", opts.rate, sink.name()))?;
    let session: u32 = device::kv(&reply)
        .get("session")
        .and_then(|s| s.parse().ok())
        .with_context(|| format!("no session in '{}'", reply))?;

    let names: Vec<&'static str> = opts.lines.iter().map(|&b| CHANNEL_NAMES[b]).collect();
    eprintln!(
        "{} {} at {} baud (8N1), {}  (Ctrl-C stops)",
        "uart".green().bold(),
        names.join(", "),
        opts.baud,
        match opts.duration {
            Some(d) => format!("for {:.1} s", d.as_secs_f64()),
            None => "until Ctrl-C".into(),
        }
    );
    let mut rxs: Vec<Rx> = Vec::new();
    let mut printer =
        Printer { names: names.clone(), pending: vec![Vec::new(); names.len()], last: vec![Instant::now(); names.len()], hex: opts.hex };
    let mut v = Verifier::new(session);
    let mut lost = 0u64;
    let start = Instant::now();

    let mut pump = |v: &mut Verifier, rxs: &mut Vec<Rx>, printer: &mut Printer, wait: Duration| -> bool {
        let Ok(msg) = reader.rx.recv_timeout(wait) else { return false };
        if let Msg::Data(d) = msg {
            v.feed(&d, &mut |e| match e {
                Event::Session(s) => {
                    let spb = s.streams[0].rate() / opts.baud as f64;
                    *rxs = opts.lines.iter().map(|&b| Rx::new(b, spb)).collect();
                    if spb < 4.0 {
                        eprintln!("{} {:.1} samples per bit is too few; raise --rate", "warning".yellow(), spb);
                    }
                }
                Event::Samples { stream: 0, first, data } => {
                    for (j, s) in data.chunks_exact(2).enumerate() {
                        let w = u16::from_le_bytes([s[0], s[1]]);
                        for (idx, rx) in rxs.iter_mut().enumerate() {
                            if let Some(b) = rx.push(first + j as u64, w >> rx.bit & 1 == 1) {
                                printer.byte(idx, b);
                            }
                        }
                    }
                }
                Event::Overrun { stream: 0, lost: n, .. } => {
                    lost += n;
                    rxs.iter_mut().for_each(Rx::gap);
                }
                _ => {}
            });
        }
        true
    };

    while !stop.load(Ordering::Relaxed) && opts.duration.is_none_or(|d| start.elapsed() < d) {
        pump(&mut v, &mut rxs, &mut printer, Duration::from_millis(20));
        printer.flush_idle(Duration::from_millis(300));
    }
    let disarm = ctl.command("disarm");
    let deadline = Instant::now() + Duration::from_secs(3);
    while v.end.is_none() && Instant::now() < deadline {
        pump(&mut v, &mut rxs, &mut printer, Duration::from_millis(20));
    }
    reader.stop.store(true, Ordering::Relaxed);
    while pump(&mut v, &mut rxs, &mut printer, Duration::ZERO) {}
    let _ = reader.thread.join();
    printer.flush_idle(Duration::ZERO);
    disarm?;

    let _ = std::io::stdout().flush();
    eprintln!();
    for rx in &rxs {
        eprintln!(
            "{:<5} {} bytes{}",
            CHANNEL_NAMES[rx.bit],
            rx.bytes,
            if rx.framing > 0 { format!(", {} framing errors (wrong baud?)", rx.framing) } else { String::new() }
        );
    }
    if lost > 0 {
        eprintln!("{} {} samples lost to overruns: bytes in those gaps are missing", "note".yellow(), lost);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Samples of `bytes` sent 8N1 at `spb` samples per bit, idle before and after.
    fn waveform(bytes: &[u8], spb: usize) -> Vec<bool> {
        let mut w = vec![true; 3 * spb];
        for &b in bytes {
            let bits = std::iter::once(false).chain((0..8).map(|i| b >> i & 1 == 1)).chain(std::iter::once(true));
            for bit in bits {
                w.extend(std::iter::repeat_n(bit, spb));
            }
        }
        w.extend(vec![true; 3 * spb]);
        w
    }

    #[test]
    fn decodes_8n1() {
        let msg = b"ESP-ROM:esp32s3\r\n\x00\xff";
        let mut rx = Rx::new(0, 17.36); // 2 Msps at 115200
        let w = waveform(msg, 17);
        let got: Vec<u8> = w.iter().enumerate().filter_map(|(i, &l)| rx.push(i as u64, l)).collect();
        assert_eq!(got, msg);
        assert_eq!(rx.framing, 0);
    }

    #[test]
    fn wrong_baud_gives_framing_errors() {
        let mut rx = Rx::new(0, 17.36 / 4.0);
        let w = waveform(b"\x00\x00\x00", 17);
        for (i, &l) in w.iter().enumerate() {
            rx.push(i as u64, l);
        }
        assert!(rx.framing > 0);
    }
}

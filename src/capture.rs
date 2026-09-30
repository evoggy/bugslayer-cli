// Record the expansion port: arm a session over the control CDC, read the
// block stream from the RP2350's vendor bulk IN (Full Speed, ~380 ksps) or the
// FX2's EP6 (High Speed, ~17 Msps), verify it, and stream it into a sigrok .sr.
//
// USB reading runs on its own thread with a queue of transfers always in
// flight, so verification, compression and disk never stall the pipe: at
// 35 MB/s the FX2's FIFO covers only ~60 us.

use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::{bail, Context, Result};
use colored::Colorize;
use indicatif::{ProgressBar, ProgressStyle};

use crate::device::{self, Control, Deck};
use crate::error::CliError;
use crate::sigrok::SrWriter;
use crate::spi;
use crate::stream::{Event, Verifier, BLOCK_SIZE, CHANNEL_NAMES};

pub use bugslayer::pipe::{start_reader, Msg, Sink, USB_MAX_RATE};

pub struct Options {
    pub rate: u32,
    pub duration: Option<Duration>,
    pub output: Option<PathBuf>,
    pub source: &'static str,
    pub sink: Sink,
    pub spi: bool,
    pub spi_show: usize,
    pub no_overrun: bool,
}

fn human_rate(hz: f64) -> String {
    if hz >= 1e6 {
        format!("{:.4} Msps", hz / 1e6)
    } else if hz >= 1e3 {
        format!("{:.3} ksps", hz / 1e3)
    } else {
        format!("{:.0} sps", hz)
    }
}

/// Collects the streams of a verified session: raw16 into the .sr as it
/// arrives, and into memory only when SPI needs it for timing.
struct Collector {
    output: Option<PathBuf>,
    writer: Option<SrWriter>,
    keep_raw16: bool,
    raw16: Vec<u8>,
    sck8: Vec<u8>,
    raw16_samples: u64,
    rate: f64,
    bytes: u64,
    usb_errors: Vec<String>,
    error: Option<anyhow::Error>,
}

impl Collector {
    fn event(&mut self, e: Event) -> Result<()> {
        match e {
            Event::Session(info) => {
                let s0 = info.streams.first().context("SESSION lists no streams")?;
                self.rate = s0.rate();
                if let Some(path) = &self.output {
                    let names = &CHANNEL_NAMES[..(s0.n_pins as usize).min(16)];
                    self.writer = Some(SrWriter::create(path, self.rate.round() as u64, names)?);
                }
            }
            Event::Samples { stream: 0, data, .. } => {
                self.raw16_samples += (data.len() / 2) as u64;
                if let Some(w) = &mut self.writer {
                    w.push(data)?;
                }
                if self.keep_raw16 {
                    self.raw16.extend_from_slice(data);
                }
            }
            Event::Samples { data, .. } => self.sck8.extend_from_slice(data),
            Event::Overrun { stream: 0, lost, .. } => {
                self.raw16_samples += lost;
                if let Some(w) = &mut self.writer {
                    w.hold(lost)?;
                }
                if self.keep_raw16 {
                    let last: [u8; 2] = self.raw16.len().checked_sub(2).map_or([0, 0], |i| [self.raw16[i], self.raw16[i + 1]]);
                    for _ in 0..lost {
                        self.raw16.extend_from_slice(&last);
                    }
                }
            }
            // Lost SCK edges cannot be filled in; the summary reports them.
            Event::Overrun { .. } => {}
            Event::End(_) => {}
        }
        Ok(())
    }
}

/// The USB device carrying `sink`; offers to bring the FX2 up when it is down.
pub fn sink_device(deck: &Deck, ctl: &mut Control, sink: Sink, non_interactive: bool) -> Result<nusb::DeviceInfo> {
    Ok(match sink {
        Sink::Usb => deck.ctrl.clone(),
        Sink::Fx2 => match &deck.fx2 {
            Some(d) => d.clone(),
            None => {
                crate::require_arg(non_interactive, "a running FX2: bring it up with `bsly fx2 up`")?;
                let up = inquire::Confirm::new("The FX2 is down. Bring it up?").with_default(true).prompt()?;
                if !up {
                    bail!(CliError::Connection("the FX2 sink needs the FX2 up".into()));
                }
                ctl.expect_ok("fx2 up")?;
                device::wait_fx2(&deck.serial, Duration::from_secs(5))?
            }
        },
    })
}

pub fn run(deck: &Deck, ctl: &mut Control, opts: &Options, non_interactive: bool) -> Result<()> {
    let info = sink_device(deck, ctl, opts.sink, non_interactive)?;

    let stop = Arc::new(AtomicBool::new(false));
    {
        let stop = stop.clone();
        // Ctrl-C ends the recording cleanly (disarm, drain, write); a second
        // one while draining is ignored rather than leaving a broken .sr.
        let _ = ctrlc::set_handler(move || stop.store(true, Ordering::Relaxed));
    }

    let reader = start_reader(&info, opts.sink)?;
    let arm = format!(
        "arm {} {} {}{}",
        opts.rate,
        opts.source,
        opts.sink.name(),
        if opts.spi { " spi" } else { "" }
    );
    let reply = ctl.expect_ok(&arm)?;
    let kv = device::kv(&reply);
    let session: u32 = kv
        .get("session")
        .and_then(|s| s.parse().ok())
        .with_context(|| format!("no session in '{}'", reply))?;
    let start = Instant::now();

    let mut v = Verifier::new(session);
    let mut col = Collector {
        output: opts.output.clone(),
        writer: None,
        keep_raw16: opts.spi,
        raw16: Vec::new(),
        sck8: Vec::new(),
        raw16_samples: 0,
        rate: 0.0,
        bytes: 0,
        usb_errors: Vec::new(),
        error: None,
    };

    let until = match opts.duration {
        Some(d) => format!("for {:.1} s", d.as_secs_f64()),
        None => "until Ctrl-C".into(),
    };
    eprintln!(
        "{} session {} via {} at {}, {}",
        "recording".green().bold(),
        session,
        opts.sink.name(),
        kv.get("rate").map_or(opts.rate.to_string(), |r| r.clone()),
        until
    );
    let pb = ProgressBar::new_spinner();
    pb.set_style(ProgressStyle::with_template("{spinner:.cyan} {elapsed_precise} {msg}").unwrap());
    pb.enable_steady_tick(Duration::from_millis(100));

    let pump = |v: &mut Verifier, col: &mut Collector, wait: Duration| -> bool {
        match reader.rx.recv_timeout(wait) {
            Ok(Msg::Data(d)) => {
                col.bytes += d.len() as u64;
                v.feed(&d, &mut |e| {
                    if col.error.is_none() {
                        if let Err(err) = col.event(e) {
                            col.error = Some(err);
                        }
                    }
                });
                true
            }
            Ok(Msg::Error(e)) => {
                if col.usb_errors.len() < 10 {
                    col.usb_errors.push(e);
                }
                true
            }
            Err(_) => false,
        }
    };

    let mut last_tick = Instant::now();
    let status = |v: &Verifier, col: &Collector, t: Duration| {
        let lost = v.lost();
        let mut s = format!(
            "{} samples  {:.1} s of signal  {:.2} MB/s",
            col.raw16_samples,
            if col.rate > 0.0 { col.raw16_samples as f64 / col.rate } else { 0.0 },
            col.bytes as f64 / t.as_secs_f64().max(1e-3) / 1e6
        );
        if !col.sck8.is_empty() {
            s += &format!("  {} SCK edges", col.sck8.len());
        }
        if lost > 0 {
            s += &format!("  {}", format!("{} lost", lost).red());
        }
        s
    };
    while !stop.load(Ordering::Relaxed) && opts.duration.is_none_or(|d| start.elapsed() < d) {
        pump(&mut v, &mut col, Duration::from_millis(20));
        if last_tick.elapsed() > Duration::from_millis(200) {
            pb.set_message(status(&v, &col, start.elapsed()));
            last_tick = Instant::now();
        }
        if col.error.is_some() {
            break;
        }
    }
    let disarm = ctl.command("disarm");

    // The disarm reply does not mean the stream is drained: read until END.
    pb.set_message("draining");
    let deadline = Instant::now() + Duration::from_secs(5);
    while v.end.is_none() && Instant::now() < deadline {
        pump(&mut v, &mut col, Duration::from_millis(20));
    }
    let elapsed = start.elapsed();
    reader.stop.store(true, Ordering::Relaxed);
    while pump(&mut v, &mut col, Duration::from_millis(0)) {}
    let short = reader.thread.join().unwrap_or(0);
    pb.finish_and_clear();
    v.finish();
    let disarm = disarm?;
    println!("{}", disarm);

    // --- summary ---
    let serial_fw = v.info.as_ref().map_or("?".into(), |i| format!("{}  fw {}  hw {}", i.serial, i.fw, i.hw));
    let row = |k: &str, val: String| println!("{:<11}{}", k, val);
    row("device", serial_fw);
    row(
        "session",
        format!("{}  via {}  ({} blocks, {} stale from earlier sessions)", session, opts.sink.name(), v.blocks, v.stale),
    );
    if short > 0 {
        row("flushed", format!("{} bytes of an earlier session's partial block", short));
    }
    if let Some(s0) = v.streams.first() {
        let n = s0.next_sample;
        let rate = s0.desc.rate();
        row(
            "samples",
            format!("{} at {} = {:.3} s  (source {})", n, human_rate(rate), n as f64 / rate.max(1e-9), s0.desc.source),
        );
    }
    if let Some(s1) = v.streams.get(1) {
        row("spi", format!("{} SCK edges", s1.next_sample));
    }
    row("throughput", format!("{:.0} kB/s", v.blocks as f64 * BLOCK_SIZE as f64 / elapsed.as_secs_f64() / 1e3));
    let lost = v.lost();
    let ovr = format!("{} ({} samples lost)", v.overruns(), lost);
    row("overruns", if lost > 0 { ovr.yellow().to_string() } else { ovr });
    for (sid, st) in v.streams.iter().enumerate() {
        for &(first, n) in st.overruns.iter().take(5) {
            let rate = st.desc.rate();
            let at = if rate > 0.0 { format!("{:.4} s", first as f64 / rate) } else { format!("edge #{}", first) };
            row("", format!("stream {}: {} lost from #{} ({})", sid, n, first, at));
        }
    }

    if opts.spi {
        if col.sck8.is_empty() && v.streams.len() < 2 {
            println!("spi        no sck8 stream in this session");
        } else {
            let raw16: Vec<u16> = col.raw16.chunks_exact(2).map(|c| u16::from_le_bytes([c[0], c[1]])).collect();
            let d = spi::decode(&col.sck8, Some((&raw16 as &dyn spi::Raw16, col.rate)));
            report(&d, opts.spi_show, true);
        }
    }

    if let Some(err) = col.error.take() {
        return Err(err.context("writing the capture"));
    }
    if let (Some(w), Some(path)) = (col.writer.take(), &opts.output) {
        if col.rate.fract() != 0.0 {
            row("note", format!("{:.3} Hz is not an integer; the .sr says {} Hz", col.rate, col.rate.round()));
        }
        w.finish(if col.sck8.is_empty() { None } else { Some(&col.sck8) })?;
        row("wrote", path.display().to_string());
    }

    let mut problems: Vec<String> = std::mem::take(&mut col.usb_errors);
    problems.extend(v.errors.iter().cloned());
    if v.error_count > v.errors.len() {
        problems.push(format!("... and {} more", v.error_count - v.errors.len()));
    }
    if !problems.is_empty() {
        println!("\n{}", "FAIL".red().bold());
        for p in &problems {
            println!("  {}", p);
        }
        bail!(CliError::Verification(format!("{} problem(s) in session {}", problems.len(), session)));
    }
    if opts.no_overrun && lost > 0 {
        println!("\n{}", "FAIL (overruns not allowed)".red().bold());
        bail!(CliError::Verification(format!("{} samples lost", lost)));
    }
    println!("\n{}", "PASS".green().bold());
    Ok(())
}

/// SPI summary lines plus the first `show` transactions.
pub fn report(d: &spi::Decoded, show: usize, have_raw: bool) {
    let per: Vec<String> = spi::per_cs(d).iter().map(|(k, n)| format!("{}: {}", k, n)).collect();
    println!("spi txns   {}  {}", d.txns.len(), per.join("  "));
    if have_raw {
        println!(
            "spi check  {} transactions also decoded from raw16: {} identical, {} different",
            d.checked,
            d.checked - d.mismatched,
            d.mismatched
        );
    }
    for n in d.notes.iter().take(5) {
        println!("spi note   {}", n);
    }
    for t in d.txns.iter().take(show) {
        println!("{}", spi::format_txn(t));
    }
}

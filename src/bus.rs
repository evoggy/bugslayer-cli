// The expansion-port I2C bus, with the deck as master.
//
// The firmware only moves bytes (`i2c on|off|xfer|recover`); what is safe to
// do with the bus is decided here. With a Crazyflie in the stack its STM32 is
// the master and the deck must stay off the bus. Standalone, the deck has to
// power the decks (VCC) and pull the bus up itself.

use std::time::Duration;

use anyhow::{bail, Context, Result};
use colored::Colorize;

use crate::device::{self, Control};
use crate::error::CliError;

pub struct BusOptions {
    pub rate: u32,
    /// Drive the bus even though a Crazyflie seems to own it.
    pub force: bool,
    /// Switch VCC on without asking when the port is unpowered.
    pub power: bool,
}

/// Why a transfer did not complete.
#[derive(Debug, PartialEq, Eq)]
pub enum XferError {
    Nak,
    Timeout,
}

pub struct Bus<'a> {
    pub ctl: &'a mut Control,
}

/// What `stat` says about power and the bus.
pub struct PortState {
    pub cf_vcc: bool,
    pub vcc_en: bool,
    pub vcom_en: bool,
    pub pull: bool,
}

pub fn port_state(ctl: &mut Control) -> Result<PortState> {
    let mut kv = std::collections::BTreeMap::new();
    for r in ctl.query("stat")? {
        kv.extend(device::kv(&r));
    }
    if !kv.contains_key("vcc_en") {
        bail!(CliError::Rejected(
            "the deck firmware is too old for I2C (needs rp2350 0.5.0: `i2c`, and power state in `stat`)".into()
        ));
    }
    let on = |k: &str| kv.get(k).map(String::as_str) == Some("1");
    Ok(PortState { cf_vcc: on("cf_vcc"), vcc_en: on("vcc_en"), vcom_en: on("vcom_en"), pull: on("pull") })
}

impl<'a> Bus<'a> {
    /// Make the bus usable: refuse if a Crazyflie is its master, power the
    /// decks and pull the bus up when standalone, and start the I2C master.
    pub fn open(ctl: &'a mut Control, opts: &BusOptions, non_interactive: bool) -> Result<Bus<'a>> {
        let st = port_state(ctl)?;
        // VCC on the port that the deck did not switch on: a Crazyflie.
        let crazyflie = st.cf_vcc && !st.vcc_en;
        if crazyflie && !opts.force {
            bail!(CliError::Rejected(
                "a Crazyflie powers the expansion port, so it is the I2C master there; \
                 remove it, or pass --force to drive the bus anyway"
                    .into()
            ));
        }
        if !st.cf_vcc {
            if !opts.power {
                crate::require_arg(non_interactive, "--power: the expansion port is unpowered")?;
                let yes = inquire::Confirm::new("The expansion port is unpowered. Switch VCC and VCOM on to power the decks?")
                    .with_default(true)
                    .prompt()?;
                if !yes {
                    bail!(CliError::Rejected("the decks need VCC to answer on I2C".into()));
                }
            }
            // Both rails: some decks (Lighthouse) run from VCOM, not VCC.
            ctl.expect_ok("pwr vcc on")?;
            ctl.expect_ok("pwr vcom on")?;
            eprintln!("{} VCC and VCOM switched on", "power".green());
            // Deck controllers need a moment after power-on before they answer.
            std::thread::sleep(Duration::from_millis(150));
        }
        if !crazyflie && !st.pull {
            // The firmware refuses the pull-ups without VCOM: decks that run
            // from VCOM (Lighthouse) would be back-powered through SDA/SCL.
            // VCC may have been switched on by hand, without VCOM.
            if st.cf_vcc && !st.vcom_en {
                ctl.expect_ok("pwr vcom on")?;
                eprintln!("{} VCOM switched on", "power".green());
                std::thread::sleep(Duration::from_millis(150));
            }
            ctl.expect_ok("pull on")?;
            eprintln!("{} I2C pull-ups on", "bus".green());
        }
        ctl.expect_ok(&format!("i2c on {}", opts.rate))?;
        Ok(Bus { ctl })
    }

    /// Write `w`, then read `n` bytes with a repeated START.
    pub fn xfer(&mut self, addr: u8, w: &[u8], n: usize) -> Result<std::result::Result<Vec<u8>, XferError>> {
        let hex = if w.is_empty() { "-".to_string() } else { w.iter().map(|b| format!("{:02x}", b)).collect() };
        let reply = self.ctl.command(&format!("i2c xfer 0x{:02x} {} {}", addr, hex, n))?;
        match reply.as_str() {
            "err i2c nak" => return Ok(Err(XferError::Nak)),
            "err i2c timeout" => return Ok(Err(XferError::Timeout)),
            _ => {}
        }
        let Some(data) = reply.strip_prefix("i2c ok data=") else {
            bail!(CliError::Rejected(format!("i2c xfer: {}", reply.strip_prefix("err ").unwrap_or(&reply))));
        };
        let bytes = (0..data.len() / 2)
            .map(|i| u8::from_str_radix(&data[2 * i..2 * i + 2], 16))
            .collect::<std::result::Result<Vec<u8>, _>>()
            .with_context(|| format!("bad data in '{}'", reply))?;
        if bytes.len() != n {
            bail!("i2c xfer: asked for {} bytes, got {}", n, bytes.len());
        }
        Ok(Ok(bytes))
    }

    /// Like `xfer`, but a NAK or timeout is an error.
    pub fn xfer_ok(&mut self, addr: u8, w: &[u8], n: usize) -> Result<Vec<u8>> {
        match self.xfer(addr, w, n)? {
            Ok(d) => Ok(d),
            Err(XferError::Nak) => bail!(CliError::NotFound(format!("nothing acknowledged at 0x{:02x}", addr))),
            Err(XferError::Timeout) => bail!(CliError::Timeout(format!(
                "I2C transfer to 0x{:02x} (bus held low? try `bsly i2c recover`)",
                addr
            ))),
        }
    }
}

impl Drop for Bus<'_> {
    /// Off the bus again: the pins go back to Hi-Z inputs.
    fn drop(&mut self) {
        let _ = self.ctl.command("i2c off");
    }
}

/// Classic hexdump lines, addresses starting at `base`.
pub fn hexdump(base: u32, data: &[u8]) -> Vec<String> {
    data.chunks(16)
        .enumerate()
        .map(|(i, c)| {
            let hex: Vec<String> = c.iter().map(|b| format!("{:02x}", b)).collect();
            let asc: String = c.iter().map(|&b| if (0x20..0x7f).contains(&b) { b as char } else { '.' }).collect();
            format!("{:04x}  {:<48} {}", base as usize + 16 * i, hex.join(" "), asc)
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_bytes_and_hex() {
        use crate::{parse_byte, parse_hex};
        assert_eq!(parse_byte("0x44"), Ok(0x44));
        assert_eq!(parse_byte("68"), Ok(68));
        assert!(parse_byte("0x144").is_err());
        assert_eq!(parse_hex("1900").unwrap().0, vec![0x19, 0x00]);
        assert_eq!(parse_hex("0x19, 0x00 ab").unwrap().0, vec![0x19, 0x00, 0xab]);
        assert!(parse_hex("190").is_err());
        assert!(parse_hex("zz").is_err());
    }

    #[test]
    fn dumps() {
        let d = hexdump(0x20, b"WiFi camera deck");
        assert_eq!(d, vec!["0020  57 69 46 69 20 63 61 6d 65 72 61 20 64 65 63 6b  WiFi camera deck"]);
    }
}

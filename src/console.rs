// `bsly raw` with no arguments: an interactive console on the control channel,
// with Tab completion of the firmware's command vocabulary and the session's
// history offered on an empty line.

use anyhow::Result;
use colored::Colorize;
use inquire::autocompletion::{Autocomplete, Replacement};
use inquire::{CustomUserError, InquireError, Text};

use crate::device::Control;

/// The words that may follow `words` in a control-channel command. Keep in
/// sync with `handle()` in bugslayer-deck-firmware/rp2350/src/main.c.
fn next_words(words: &[&str]) -> &'static [&'static str] {
    match words {
        [] => &[
            "arm", "clk", "dbg", "disarm", "fx2", "help", "id", "ping", "pins", "prof", "pull", "pwr",
            "stat", "ver",
        ],
        ["fx2"] => &["boot", "down", "reboot", "test", "up"],
        ["fx2", "boot"] => &["c0", "c2", "rom"],
        ["fx2", "test"] => &["start", "stop"],
        ["pwr"] => &["vcc", "vcom"],
        ["pwr", _] => &["off", "on"],
        ["pull"] => &["off", "on"],
        ["arm", _, ..] if words.len() <= 4 => &["counter", "fx2", "pins", "spi", "usb"],
        _ => &[],
    }
}

#[derive(Clone, Default)]
struct Completer {
    history: Vec<String>,
}

impl Completer {
    fn candidates(&self, input: &str) -> Vec<String> {
        if input.trim().is_empty() {
            // Most recent first, without repeats.
            let mut seen = Vec::new();
            for h in self.history.iter().rev() {
                if !seen.contains(h) {
                    seen.push(h.clone());
                }
            }
            seen.truncate(8);
            return seen;
        }
        let ends_with_space = input.ends_with(' ');
        let mut words: Vec<&str> = input.split_whitespace().collect();
        let partial = if ends_with_space { "" } else { words.pop().unwrap_or("") };
        let head = words.join(" ");
        next_words(&words)
            .iter()
            .filter(|w| w.starts_with(partial))
            .map(|w| if head.is_empty() { w.to_string() } else { format!("{} {}", head, w) })
            .collect()
    }
}

impl Autocomplete for Completer {
    fn get_suggestions(&mut self, input: &str) -> Result<Vec<String>, CustomUserError> {
        Ok(self.candidates(input))
    }

    fn get_completion(&mut self, input: &str, highlighted: Option<String>) -> Result<Replacement, CustomUserError> {
        if let Some(h) = highlighted {
            return Ok(Some(format!("{} ", h)));
        }
        let c = self.candidates(input);
        if c.len() == 1 {
            return Ok(Some(format!("{} ", c[0])));
        }
        // Longest common prefix of the candidates.
        let Some(first) = c.first() else { return Ok(None) };
        let n = c.iter().fold(first.len(), |n, s| {
            first.bytes().zip(s.bytes()).take(n).take_while(|(a, b)| a == b).count()
        });
        Ok((n > input.len()).then(|| first[..n].to_string()))
    }
}

pub fn print_replies(ctl: &mut Control, line: &str) -> Result<()> {
    for reply in ctl.query(line)? {
        if reply.starts_with("err") {
            println!("{}", reply.red());
        } else {
            println!("{}", reply);
        }
    }
    Ok(())
}

pub fn run(ctl: &mut Control, serial: &str) -> Result<()> {
    println!(
        "{} {}  (Tab completes, Esc or Ctrl-D quits, `help` lists the firmware's commands)",
        "control console".bold(),
        serial
    );
    let mut completer = Completer::default();
    loop {
        let line = match Text::new("bsly>")
            .with_autocomplete(completer.clone())
            .with_page_size(8)
            .prompt()
        {
            Ok(l) => l,
            Err(InquireError::OperationCanceled | InquireError::OperationInterrupted) => return Ok(()),
            Err(e) => return Err(e.into()),
        };
        let line = line.trim().to_string();
        if line.is_empty() {
            continue;
        }
        if line == "exit" || line == "quit" {
            return Ok(());
        }
        if let Err(e) = print_replies(ctl, &line) {
            println!("{}", format!("{:#}", e).red());
        }
        completer.history.push(line);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn completes_words_in_context() {
        let c = Completer::default();
        assert_eq!(c.candidates("fx"), vec!["fx2"]);
        assert_eq!(c.candidates("fx2 b"), vec!["fx2 boot"]);
        assert_eq!(c.candidates("fx2 boot "), vec!["fx2 boot c0", "fx2 boot c2", "fx2 boot rom"]);
        assert_eq!(c.candidates("pwr vcom o"), vec!["pwr vcom off", "pwr vcom on"]);
        assert!(c.candidates("arm 1000000 f").contains(&"arm 1000000 fx2".to_string()));
        assert!(c.candidates("ping ").is_empty());
    }

    #[test]
    fn tab_extends_to_the_common_prefix() {
        let mut c = Completer::default();
        assert_eq!(c.get_completion("fx2 boot c", None).unwrap(), None);
        assert_eq!(c.get_completion("pi", None).unwrap(), Some("pin".to_string()));
        assert_eq!(c.get_completion("dis", None).unwrap(), Some("disarm ".to_string()));
    }
}

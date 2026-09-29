# bsly: Bugslayer deck CLI

Command-line client for the Bugslayer deck, in the style of `cfcli`: clap
subcommands, prompts (inquire) when an argument is left out, shell completion
generated from the same command tree, and classified exit codes for scripts.

It replaces the bring-up Python tools in `bugslayer-deck-firmware/host/`
(`bslyctl.py`, `bsly.py capture`, `bsly.py spi`). It speaks the same v0
protocol (`docs/protocol.md` there) and writes the same sigrok `.sr` files.

## Install

```
cargo install --path .
```

Access to the deck's USB devices needs the udev rules from
`bugslayer-deck-firmware/host/99-bugslayer-deck.rules`.

Shell completion scripts are generated into `completions/` by every build:

```
# zsh: put _bsly on $fpath, e.g.
cp completions/_bsly ~/.zsh/completions/        # then compinit
# bash
echo "source $PWD/completions/bsly.bash" >> ~/.bashrc
# or print one: bsly completions zsh|bash|fish|powershell
```

Besides subcommands, flags and values, completion offers the serial numbers of
the connected decks for `--serial` (via `bsly __complete serials`, which only
lists USB devices).

## Commands

| Command | What |
|---|---|
| `bsly list` | Connected decks: serial, control port, FX2 up/down, probe on the same hub |
| `bsly select` | Pick the default deck when several are connected (saved) |
| `bsly info` | Firmware versions, serial and the three USB devices |
| `bsly status [-w]` | Capture engine and FX2 link status (`-w` refreshes live) |
| `bsly pins [-w]` | Live level of every expansion-port signal |
| `bsly power [vcc\|vcom] [on\|off]` | High-side switches; prompts for what is left out |
| `bsly pull [on\|off]` | I2C pull-ups (standalone only) |
| `bsly fx2 [up\|down\|reboot\|boot [c2\|c0\|rom]\|status]` | FX2 pipe; `up` waits for it to enumerate |
| `bsly capture` | Record: arm, stream, verify, write `.sr` |
| `bsly decode spi FILE [--cs IO_3]` | SPI transactions from a capture made with `--spi` |
| `bsly raw [LINE...]` | Raw control-channel lines; with none, an interactive console with Tab completion |

### Capture

```
bsly capture -r 250k -t 5 -o boot.sr               # RP2350 USB sink
bsly capture -r 16.67M -t 10 -o boot.sr            # FX2 sink (auto above ~380 ksps)
bsly capture -r 16.67M --spi -o flow.sr            # + SCK-clocked SPI stream, until Ctrl-C
bsly capture --source counter -r 16.67M -t 10 --no-overrun   # pipe test
```

Without `--duration` the recording runs until Ctrl-C, which ends it cleanly:
disarm, drain to `END`, verify, write the file. Samples go into the `.sr` as they
arrive, so a long recording is bounded by disk, not RAM (except with `--spi`,
where raw16 is also kept in memory to time and cross-check the SPI decode).

Every capture is verified as `bsly.py` does it: session ID, SESSION first, no
sequence gaps, sample continuity except where an OVERRUN says so, END totals,
and for `--source counter` every sample equal to its index. Overrun gaps are
filled by holding the last value in the `.sr` (it cannot mark them) and are
listed in the summary. `--no-overrun` turns loss into a failure.

The FX2 is read with 64 transfers of 16 KB always in flight on a separate
thread. Measured on rev A: 35.3 MB/s, 16.67 Msps, zero loss.

## Interactivity

When an argument is left out and stdin is a terminal, `bsly` asks: which deck
if several are connected (and none is selected), which rail and state for
`power`, what to do for `fx2`, whether to bring the FX2 up when a capture needs
it. With `--non-interactive`, or when stdin is not a TTY, it fails instead with
exit code 30 and names the missing argument.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | unspecified error |
| 2 | usage error (clap) |
| 10 | connection failure (no deck, USB or serial error) |
| 20 | not found (deck serial, file) |
| 30 | missing argument when non-interactive, or the deck rejected a command (`err ...`) |
| 40 | the deck did not reply in time |
| 50 | capture verification failed |

## Layout

| File | What |
|---|---|
| `src/cli.rs` | The clap command tree, shared with `build.rs` via `include!` |
| `build.rs` | Generates completion scripts and splices in `completions/addendum.*` |
| `src/device.rs` | Finding decks (DB11/DB12/DB13 pairing), the ASCII control channel |
| `src/stream.rs` | Block format and the session verifier |
| `src/capture.rs` | Reader thread, capture loop, summary |
| `src/sigrok.rs` | Streaming `.sr` writer and reader |
| `src/spi.rs` | sck8 SPI decode, timed and cross-checked against raw16 |
| `src/console.rs` | The interactive `raw` console |

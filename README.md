# bsly: Bugslayer deck CLI

Command-line client for the Bugslayer deck, in the style of `cfcli`: clap
subcommands, prompts (inquire) when an argument is left out, shell completion
generated from the same command tree, and classified exit codes for scripts.

It replaces the bring-up Python tools in `bugslayer-deck-firmware/host/`
(`bslyctl.py`, `bsly.py capture`, `bsly.py spi`). It speaks the same v0
protocol (`docs/protocol.md` there) and writes the same sigrok `.sr` files.

## Install

The deck protocol lives in [bugslayer-lib](../bugslayer-lib) (crate
`bugslayer`, shared with bugslayer-ui), which is expected next to this
repository:

```
git clone git@github.com:evoggy/bugslayer-lib.git ../bugslayer-lib   # once
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
| `bsly i2c scan\|read\|write\|recover` | Raw I2C on the expansion port, the deck as master |
| `bsly deckctrl scan\|info\|gpio\|read\|write\|reset` | Deck controllers (DeckCtrl), enumerated as a Crazyflie does it |
| `bsly uart [-l RX1] [-b 1000000]` | Live UART decode of expansion-port lines (sniffed, never driven) |
| `bsly swo [--swd 1\|2] [-b 2000000] [-p 0,1]` | SWO trace (ITM) of the target on probe port P1 or P5 |
| `bsly update [rp2350\|probe] [--check]` | Compare with the GitHub releases and install updates over USB |
| `bsly raw [LINE...]` | Raw control-channel lines; with none, an interactive console with Tab completion |

### Updating the firmware

```
bsly update --check          # installed vs latest release, per chip
bsly update                  # install whatever is out of date (asks first; -y doesn't)
bsly update rp2350 --version 0.8.0
bsly update probe --file bugslayer-probe-0.1.0.uf2
```

Releases come from `evoggy/bugslayer-deck-firmware` (RP2350, FX2 image inside) and
`evoggy/bugslayer-probe-firmware` (RP2040 probe), tagged `X.Y.Z`. Both are private, so bsly
needs a token: `GITHUB_TOKEN`/`GH_TOKEN`, or a `gh auth login`.

The RP2350 reboots into its USB bootloader on `bootsel` (deck firmware 0.8.0+) and the
probe on CMSIS-DAP vendor command 0x9F (probe firmware 0.1.0+); bsly then copies the UF2
to the `RP2350` / `RPI-RP2` drive and checks the version the chip comes back with. Older
firmware can't reboot itself: bsly asks you to hold SW2 while plugging USB in, which puts
both chips in their bootloaders, and installs the probe first so one press covers both.
On Linux without an automounter, bsly mounts the drive with `udisksctl`.

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

### DeckCtrl and I2C

The firmware only moves bytes (`i2c on|off|xfer|recover`); the DeckCtrl
protocol lives in `src/deckctrl.rs`. Before touching the bus `bsly` checks the
port: if VCC is present but the deck did not switch it on, a Crazyflie is the
master and it refuses (`--force` overrides). Standalone it offers to switch VCC
on (`--power` does it without asking) and turns the I2C pull-ups on. The master
is switched off again after every command, leaving the pins Hi-Z.

```
bsly deckctrl scan                       # reset + enumerate, like the CF (0x44..)
bsly deckctrl info
bsly deckctrl gpio                       # table, then pick pins and what to do
bsly deckctrl gpio out 12 high           # level first, then output: no glitch
bsly deckctrl gpio dir 0-3 in
bsly deckctrl read 1900 12 -D 0x44
bsly i2c read 0x44 32 --reg 0000
```

Enumerated addresses are cached per deck in the settings file. They are checked
by CPU ID before use; only if one no longer answers does `bsly` enumerate again,
which resets every controller (and their GPIO state).

GPIO numbers are DeckCtrl indices as in deck-ctrl-firmware today (0 = PA0 …
12 = PC15). Crazyflie drivers written before crazyflie-firmware 9cf9d86c used
an older numbering.

### UART

`bsly uart` samples the port through the capture pipe (16x the baud rate, at
least 1 Msps; the FX2 when that is above ~380 ksps) and decodes 8N1 on the host.
It prints raw text for one line, or line-prefixed text for several (default:
TX1, RX1, TX2, RX2). The control port is opened shared, so another `bsly` can
power and configure a deck while `bsly uart` listens.

### SWO

`bsly swo` routes the SWO line of probe port `--swd 1` (P1, default: the
Crazyflie's STM32) or `--swd 2` (P5) to the probe's SWO ACM0 port, reads it and
decodes ITM. Only those two ports have an SWO line, and only one is received at
a time. Stimulus port 0 (`DEBUG_PRINT` with the Crazyflie firmware's
`CONFIG_DEBUG_PRINT_ON_SWO`) prints as text, other ports given with `-p` as
`[pN] value` lines. `--hex` and `--raw` show the bytes. The baud rate must match
the target's TPIU (the firmware's `CONFIG_DEBUG_PRINT_ON_SWO_BAUDRATE`).

The STM32 drives SWO only while its debug port is in SWD mode. It powers up in
JTAG mode, and OpenOCD switches it back to JTAG when it exits, so `bsly swo`
switches it to SWD through the selected probe port at start, again each time a
debugger releases that port (polled every 100 ms), and after a second without
SWO data (at most every 2 s: a line reset does not disturb a running target).
Up to about a second of output right after a debug session can be lost.
`--no-swd` leaves the debug port alone.

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
| `src/main.rs` | Commands, prompts and output on top of `bugslayer` |
| `src/capture.rs` | Capture loop and summary (the USB reader is `bugslayer::pipe`) |
| `src/uart.rs` | Live UART printing (the receiver is `bugslayer::uart`) |
| `src/swo.rs` | SWO printing (ITM decoding and the SWD keeper are `bugslayer::swo`) |
| `src/update.rs` | `bsly update` talking (the work is `bugslayer::update`) |
| `src/console.rs` | The interactive `raw` console |
| `src/error.rs` | Exit codes for `CliError` and `bugslayer::Error` |

Device discovery, the control channel, the block format and verifier, `.sr`
files, SPI decoding, the I2C bus, DeckCtrl, SWO and firmware releases are in
bugslayer-lib.

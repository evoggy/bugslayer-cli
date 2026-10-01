# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_bsly_global_optspecs
    string join \n s/serial= non-interactive d/debug h/help V/version
end

function __fish_bsly_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_bsly_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_bsly_using_subcommand
    set -l cmd (__fish_bsly_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c bsly -n "__fish_bsly_needs_command" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_needs_command" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_needs_command" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_needs_command" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_needs_command" -s V -l version -d 'Print version'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "list" -d 'List connected Bugslayer decks and their USB devices'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "select" -d 'Pick which deck to use by default when several are connected'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "info" -d 'Firmware versions, serial number and USB devices of the deck'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "status" -d 'Capture engine and FX2 link status'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "pins" -d 'Live level of every expansion-port signal'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "power" -d 'Switch the deck\'s high-side power switches (prompts when omitted)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "pull" -d 'I2C pull-ups on the expansion port (standalone only; prompts when omitted)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "fx2" -d 'Control the FX2 (CBM9002A) capture pipe (prompts when omitted)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "capture" -d 'Record the expansion port: arm, stream, verify and write a sigrok .sr'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "decode" -d 'Decode a saved capture'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "i2c" -d 'Raw I2C on the expansion port, with the deck as master'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "deckctrl" -d 'Deck controllers (DeckCtrl) on the expansion-port I2C bus'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "uart" -d 'Print what UART lines on the expansion port carry (sniffed, never driven)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "mux" -d 'Switch the port\'s TX2/RX2 between UART2 and USB (the deck\'s hub port 4, for decks with a USB MCU there: D- = TX2, D+ = RX2); standalone only'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "drive" -d 'Hold an IO pin low, e.g. a deck MCU\'s BOOT line, or release it (open drain, never driven high; standalone only)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "bridge" -d 'Bridge the Crazyflie\'s UART1/UART2 to a serial port of the deck, with the deck standing in for the Crazyflie (standalone only)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "update" -d 'Check the deck\'s firmware against the GitHub releases and install updates through the USB bootloaders (private repos: `gh auth login`)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "swo" -d 'Print a target\'s SWO trace (ITM, e.g. the Crazyflie\'s DEBUG_PRINT)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "raw" -d 'Send raw control-channel lines; with none, open an interactive console'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "settings" -d 'Local CLI settings'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "completions" -d 'Generate a shell completion script (printed to stdout)'
complete -c bsly -n "__fish_bsly_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand list" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand list" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand list" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand list" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand select" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand select" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand select" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand select" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand info" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand info" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand info" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand info" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand status" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand status" -s w -l watch -d 'Refresh continuously until Ctrl-C'
complete -c bsly -n "__fish_bsly_using_subcommand status" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand status" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand status" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand pins" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand pins" -s w -l watch -d 'Refresh continuously until Ctrl-C'
complete -c bsly -n "__fish_bsly_using_subcommand pins" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand pins" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand pins" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand power" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand power" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand power" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand power" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c bsly -n "__fish_bsly_using_subcommand pull" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand pull" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand pull" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand pull" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "up" -d 'Serve the boot image, start IFCLK and release reset'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "down" -d 'Hold the FX2 in reset'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "reboot" -d 'Down, then up: the FX2 boots again'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "boot" -d 'What the emulated EEPROM serves at the next up/reboot'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "status" -d 'Is the FX2 up and enumerated, and with which serial'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and not __fish_seen_subcommand_from up down reboot boot status help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from up" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from up" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from up" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from up" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from down" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from down" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from down" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from down" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from reboot" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from reboot" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from reboot" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from reboot" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from boot" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from boot" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from boot" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from boot" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from status" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from status" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from status" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "up" -d 'Serve the boot image, start IFCLK and release reset'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "down" -d 'Hold the FX2 in reset'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "reboot" -d 'Down, then up: the FX2 boots again'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "boot" -d 'What the emulated EEPROM serves at the next up/reboot'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "status" -d 'Is the FX2 up and enumerated, and with which serial'
complete -c bsly -n "__fish_bsly_using_subcommand fx2; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s r -l rate -d 'Sample rate (e.g. 250k, 4M, 16.67M); the deck uses 150 MHz / integer' -r
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s t -l duration -d 'How long to record (e.g. 5, 500ms, 2m); until Ctrl-C when omitted' -r
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s o -l output -d 'sigrok session file to write (opens in PulseView / sigrok-cli)' -r -F
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l source -d 'What to sample' -r -f -a "pins\t'The 16 expansion-port signals'
counter\t'Synthetic counter: sample n == n mod 2^16 (pipe test)'"
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l sink -d 'Which USB pipe carries the data' -r -f -a "auto\t'The FX2 when the rate needs it (above ~380 ksps), else the RP2350\'s USB'
usb\t'The RP2350\'s own Full-Speed USB (up to ~380 ksps)'
fx2\t'The FX2 High-Speed pipe (up to ~17 Msps)'"
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l spi-show -d 'Print the first N decoded SPI transactions' -r
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l spi -d 'Also record the lines at every rising SCK edge (exact SPI at any speed)'
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l no-overrun -d 'Fail (exit 50) if any samples were lost'
complete -c bsly -n "__fish_bsly_using_subcommand capture" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand capture" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -f -a "spi" -d 'SPI transactions from a capture made with --spi'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and not __fish_seen_subcommand_from spi help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from spi" -l cs -d 'Only transactions on this chip select' -r -f -a "IO_1\t''
IO_2\t''
IO_3\t''
IO_4\t''"
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from spi" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from spi" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from spi" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from spi" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from help" -f -a "spi" -d 'SPI transactions from a capture made with --spi'
complete -c bsly -n "__fish_bsly_using_subcommand decode; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -f -a "scan" -d 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -f -a "read" -d 'Read bytes, optionally writing a register address first (repeated START)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -f -a "write" -d 'Write bytes'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -f -a "recover" -d 'Clock SCL until a stuck device releases SDA'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and not __fish_seen_subcommand_from scan read write recover help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from scan" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -l reg -d 'Bytes to write first, e.g. 1900 for a 16-bit register' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from read" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from write" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from recover" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from recover" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from recover" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from recover" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from help" -f -a "scan" -d 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from help" -f -a "read" -d 'Read bytes, optionally writing a register address first (repeated START)'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from help" -f -a "write" -d 'Write bytes'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from help" -f -a "recover" -d 'Clock SCL until a stuck device releases SDA'
complete -c bsly -n "__fish_bsly_using_subcommand i2c; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "scan" -d 'Enumerate the deck controllers as a Crazyflie does (resets them all)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "info" -d 'Identification page, CPU ID and GPIO state of one deck'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "gpio" -d 'Show or set the deck controller\'s GPIOs (prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "read" -d 'Read registers'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "write" -d 'Write registers'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "reset" -d 'Reset every deck controller to its power-on state'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and not __fish_seen_subcommand_from scan info gpio read write reset help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from scan" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -s D -l deck -d 'Address (0x44), index (0), name or CPU ID prefix; asks when several' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from info" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -s D -l deck -d 'Address (0x44), index (0), name or CPU ID prefix; asks when several' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -f -a "show" -d 'Direction and level of every GPIO'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -f -a "dir" -d 'Make GPIOs inputs or outputs'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -f -a "level" -d 'Set the output level (takes effect on outputs)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -f -a "out" -d 'Drive GPIOs: set the level, then make them outputs (no glitch)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from gpio" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -s D -l deck -d 'Address (0x44), index (0), name or CPU ID prefix; asks when several' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from read" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -s D -l deck -d 'Address (0x44), index (0), name or CPU ID prefix; asks when several' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from write" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -l i2c-rate -d 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -l power -d 'Switch the port\'s VCC on without asking if it is unpowered'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -l force -d 'Drive the bus even though a Crazyflie seems to be its master'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from reset" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "scan" -d 'Enumerate the deck controllers as a Crazyflie does (resets them all)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "info" -d 'Identification page, CPU ID and GPIO state of one deck'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "gpio" -d 'Show or set the deck controller\'s GPIOs (prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "read" -d 'Read registers'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "write" -d 'Write registers'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "reset" -d 'Reset every deck controller to its power-on state'
complete -c bsly -n "__fish_bsly_using_subcommand deckctrl; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s l -l line -d 'Lines to decode (named as on the Crazyflie: RX1 is what a deck sends the CF on UART1)' -r -f -a "IO_1\t''
IO_2\t''
IO_3\t''
IO_4\t''
MISO\t''
OW\t''
SCK\t''
MOSI\t''
WKUP\t''
N_IO_1\t''
TX2\t''
RX2\t''
TX1\t''
RX1\t''
SDA\t''
SCL\t''"
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s b -l baud -d 'Baud rate' -r
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s r -l rate -d 'Sample rate; default 16x the baud rate, at least 1 Msps' -r
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s t -l duration -d 'How long to listen; until Ctrl-C when omitted' -r
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand uart" -l hex -d 'Print bytes as hex instead of text'
complete -c bsly -n "__fish_bsly_using_subcommand uart" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand uart" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand mux" -l wait -d 'Seconds to wait for a USB device after switching to usb' -r
complete -c bsly -n "__fish_bsly_using_subcommand mux" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand mux" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand mux" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand mux" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c bsly -n "__fish_bsly_using_subcommand drive" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand drive" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand drive" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand drive" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand bridge" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand bridge" -l power -d 'Switch the port\'s VCC and VCOM on without asking if needed'
complete -c bsly -n "__fish_bsly_using_subcommand bridge" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand bridge" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand bridge" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand update" -l version -d 'Install this release instead of the latest, e.g. 0.8.0 (one chip)' -r
complete -c bsly -n "__fish_bsly_using_subcommand update" -l file -d 'Install this UF2 instead of a release (one chip)' -r -F
complete -c bsly -n "__fish_bsly_using_subcommand update" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand update" -l check -d 'Only show installed and latest versions'
complete -c bsly -n "__fish_bsly_using_subcommand update" -l pre -d 'Consider prereleases too'
complete -c bsly -n "__fish_bsly_using_subcommand update" -l force -d 'Reinstall even when the installed version is current'
complete -c bsly -n "__fish_bsly_using_subcommand update" -s y -l yes -d 'Don\'t ask before installing'
complete -c bsly -n "__fish_bsly_using_subcommand update" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand update" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -l swd -d 'Probe port the target is on: 1 (P1) or 2 (P5); the others have no SWO' -r
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s b -l baud -d 'SWO baud rate; must match the target\'s TPIU (the Crazyflie firmware\'s CONFIG_DEBUG_PRINT_ON_SWO_BAUDRATE, 2000000 by default)' -r
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s p -l port -d 'ITM stimulus ports to print (DEBUG_PRINT is port 0)' -r
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s t -l duration -d 'How long to listen; until Ctrl-C when omitted' -r
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand swo" -l hex -d 'Print payloads as hex instead of text'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -l raw -d 'Print the raw SWO bytes, without decoding ITM'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -l no-swd -d 'Do not switch the target\'s debug port to SWD (SWO is silent in JTAG mode)'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand swo" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand raw" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand raw" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand raw" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand raw" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -f -a "show" -d 'Show the settings'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -f -a "clear" -d 'Forget the selected deck'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and not __fish_seen_subcommand_from show clear help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from show" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from show" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from show" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from show" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from clear" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from clear" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from clear" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from clear" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from help" -f -a "show" -d 'Show the settings'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from help" -f -a "clear" -d 'Forget the selected deck'
complete -c bsly -n "__fish_bsly_using_subcommand settings; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand completions" -s s -l serial -d 'Use the deck with this serial number (instead of the selected one)' -r
complete -c bsly -n "__fish_bsly_using_subcommand completions" -l non-interactive -d 'Disable interactive prompts (auto-set when stdin is not a TTY)'
complete -c bsly -n "__fish_bsly_using_subcommand completions" -s d -l debug -d 'Print every control-channel line sent and received'
complete -c bsly -n "__fish_bsly_using_subcommand completions" -s h -l help -d 'Print help'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "list" -d 'List connected Bugslayer decks and their USB devices'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "select" -d 'Pick which deck to use by default when several are connected'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "info" -d 'Firmware versions, serial number and USB devices of the deck'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "status" -d 'Capture engine and FX2 link status'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "pins" -d 'Live level of every expansion-port signal'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "power" -d 'Switch the deck\'s high-side power switches (prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "pull" -d 'I2C pull-ups on the expansion port (standalone only; prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "fx2" -d 'Control the FX2 (CBM9002A) capture pipe (prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "capture" -d 'Record the expansion port: arm, stream, verify and write a sigrok .sr'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "decode" -d 'Decode a saved capture'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "i2c" -d 'Raw I2C on the expansion port, with the deck as master'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "deckctrl" -d 'Deck controllers (DeckCtrl) on the expansion-port I2C bus'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "uart" -d 'Print what UART lines on the expansion port carry (sniffed, never driven)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "mux" -d 'Switch the port\'s TX2/RX2 between UART2 and USB (the deck\'s hub port 4, for decks with a USB MCU there: D- = TX2, D+ = RX2); standalone only'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "drive" -d 'Hold an IO pin low, e.g. a deck MCU\'s BOOT line, or release it (open drain, never driven high; standalone only)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "bridge" -d 'Bridge the Crazyflie\'s UART1/UART2 to a serial port of the deck, with the deck standing in for the Crazyflie (standalone only)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "update" -d 'Check the deck\'s firmware against the GitHub releases and install updates through the USB bootloaders (private repos: `gh auth login`)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "swo" -d 'Print a target\'s SWO trace (ITM, e.g. the Crazyflie\'s DEBUG_PRINT)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "raw" -d 'Send raw control-channel lines; with none, open an interactive console'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "settings" -d 'Local CLI settings'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "completions" -d 'Generate a shell completion script (printed to stdout)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and not __fish_seen_subcommand_from list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from fx2" -f -a "up" -d 'Serve the boot image, start IFCLK and release reset'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from fx2" -f -a "down" -d 'Hold the FX2 in reset'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from fx2" -f -a "reboot" -d 'Down, then up: the FX2 boots again'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from fx2" -f -a "boot" -d 'What the emulated EEPROM serves at the next up/reboot'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from fx2" -f -a "status" -d 'Is the FX2 up and enumerated, and with which serial'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from decode" -f -a "spi" -d 'SPI transactions from a capture made with --spi'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from i2c" -f -a "scan" -d 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from i2c" -f -a "read" -d 'Read bytes, optionally writing a register address first (repeated START)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from i2c" -f -a "write" -d 'Write bytes'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from i2c" -f -a "recover" -d 'Clock SCL until a stuck device releases SDA'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "scan" -d 'Enumerate the deck controllers as a Crazyflie does (resets them all)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "info" -d 'Identification page, CPU ID and GPIO state of one deck'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "gpio" -d 'Show or set the deck controller\'s GPIOs (prompts when omitted)'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "read" -d 'Read registers'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "write" -d 'Write registers'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from deckctrl" -f -a "reset" -d 'Reset every deck controller to its power-on state'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from settings" -f -a "show" -d 'Show the settings'
complete -c bsly -n "__fish_bsly_using_subcommand help; and __fish_seen_subcommand_from settings" -f -a "clear" -d 'Forget the selected deck'


using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'bsly' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'bsly'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'bsly' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List connected Bugslayer decks and their USB devices')
            [CompletionResult]::new('select', 'select', [CompletionResultType]::ParameterValue, 'Pick which deck to use by default when several are connected')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Firmware versions, serial number and USB devices of the deck')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Capture engine and FX2 link status')
            [CompletionResult]::new('pins', 'pins', [CompletionResultType]::ParameterValue, 'Live level of every expansion-port signal')
            [CompletionResult]::new('power', 'power', [CompletionResultType]::ParameterValue, 'Switch the deck''s high-side power switches (prompts when omitted)')
            [CompletionResult]::new('pull', 'pull', [CompletionResultType]::ParameterValue, 'I2C pull-ups on the expansion port (standalone only; prompts when omitted)')
            [CompletionResult]::new('fx2', 'fx2', [CompletionResultType]::ParameterValue, 'Control the FX2 (CBM9002A) capture pipe (prompts when omitted)')
            [CompletionResult]::new('capture', 'capture', [CompletionResultType]::ParameterValue, 'Record the expansion port: arm, stream, verify and write a sigrok .sr')
            [CompletionResult]::new('decode', 'decode', [CompletionResultType]::ParameterValue, 'Decode a saved capture')
            [CompletionResult]::new('i2c', 'i2c', [CompletionResultType]::ParameterValue, 'Raw I2C on the expansion port, with the deck as master')
            [CompletionResult]::new('deckctrl', 'deckctrl', [CompletionResultType]::ParameterValue, 'Deck controllers (DeckCtrl) on the expansion-port I2C bus')
            [CompletionResult]::new('uart', 'uart', [CompletionResultType]::ParameterValue, 'Print what UART lines on the expansion port carry (sniffed, never driven)')
            [CompletionResult]::new('mux', 'mux', [CompletionResultType]::ParameterValue, 'Switch the port''s TX2/RX2 between UART2 and USB (the deck''s hub port 4, for decks with a USB MCU there: D- = TX2, D+ = RX2); standalone only')
            [CompletionResult]::new('drive', 'drive', [CompletionResultType]::ParameterValue, 'Hold an IO pin low, e.g. a deck MCU''s BOOT line, or release it (open drain, never driven high; standalone only)')
            [CompletionResult]::new('bridge', 'bridge', [CompletionResultType]::ParameterValue, 'Bridge the Crazyflie''s UART1/UART2 to a serial port of the deck, with the deck standing in for the Crazyflie (standalone only)')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Check the deck''s firmware against the GitHub releases and install updates through the USB bootloaders (private repos: `gh auth login`)')
            [CompletionResult]::new('swo', 'swo', [CompletionResultType]::ParameterValue, 'Print a target''s SWO trace (ITM, e.g. the Crazyflie''s DEBUG_PRINT)')
            [CompletionResult]::new('raw', 'raw', [CompletionResultType]::ParameterValue, 'Send raw control-channel lines; with none, open an interactive console')
            [CompletionResult]::new('settings', 'settings', [CompletionResultType]::ParameterValue, 'Local CLI settings')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate a shell completion script (printed to stdout)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;list' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;select' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;info' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;status' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('-w', '-w', [CompletionResultType]::ParameterName, 'Refresh continuously until Ctrl-C')
            [CompletionResult]::new('--watch', '--watch', [CompletionResultType]::ParameterName, 'Refresh continuously until Ctrl-C')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;pins' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('-w', '-w', [CompletionResultType]::ParameterName, 'Refresh continuously until Ctrl-C')
            [CompletionResult]::new('--watch', '--watch', [CompletionResultType]::ParameterName, 'Refresh continuously until Ctrl-C')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;power' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'bsly;pull' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;fx2' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('up', 'up', [CompletionResultType]::ParameterValue, 'Serve the boot image, start IFCLK and release reset')
            [CompletionResult]::new('down', 'down', [CompletionResultType]::ParameterValue, 'Hold the FX2 in reset')
            [CompletionResult]::new('reboot', 'reboot', [CompletionResultType]::ParameterValue, 'Down, then up: the FX2 boots again')
            [CompletionResult]::new('boot', 'boot', [CompletionResultType]::ParameterValue, 'What the emulated EEPROM serves at the next up/reboot')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Is the FX2 up and enumerated, and with which serial')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;fx2;up' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;fx2;down' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;fx2;reboot' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;fx2;boot' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'bsly;fx2;status' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;fx2;help' {
            [CompletionResult]::new('up', 'up', [CompletionResultType]::ParameterValue, 'Serve the boot image, start IFCLK and release reset')
            [CompletionResult]::new('down', 'down', [CompletionResultType]::ParameterValue, 'Hold the FX2 in reset')
            [CompletionResult]::new('reboot', 'reboot', [CompletionResultType]::ParameterValue, 'Down, then up: the FX2 boots again')
            [CompletionResult]::new('boot', 'boot', [CompletionResultType]::ParameterValue, 'What the emulated EEPROM serves at the next up/reboot')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Is the FX2 up and enumerated, and with which serial')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;fx2;help;up' {
            break
        }
        'bsly;fx2;help;down' {
            break
        }
        'bsly;fx2;help;reboot' {
            break
        }
        'bsly;fx2;help;boot' {
            break
        }
        'bsly;fx2;help;status' {
            break
        }
        'bsly;fx2;help;help' {
            break
        }
        'bsly;capture' {
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Sample rate (e.g. 250k, 4M, 16.67M); the deck uses 150 MHz / integer')
            [CompletionResult]::new('--rate', '--rate', [CompletionResultType]::ParameterName, 'Sample rate (e.g. 250k, 4M, 16.67M); the deck uses 150 MHz / integer')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'How long to record (e.g. 5, 500ms, 2m); until Ctrl-C when omitted')
            [CompletionResult]::new('--duration', '--duration', [CompletionResultType]::ParameterName, 'How long to record (e.g. 5, 500ms, 2m); until Ctrl-C when omitted')
            [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'sigrok session file to write (opens in PulseView / sigrok-cli)')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'sigrok session file to write (opens in PulseView / sigrok-cli)')
            [CompletionResult]::new('--source', '--source', [CompletionResultType]::ParameterName, 'What to sample')
            [CompletionResult]::new('--sink', '--sink', [CompletionResultType]::ParameterName, 'Which USB pipe carries the data')
            [CompletionResult]::new('--spi-show', '--spi-show', [CompletionResultType]::ParameterName, 'Print the first N decoded SPI transactions')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--spi', '--spi', [CompletionResultType]::ParameterName, 'Also record the lines at every rising SCK edge (exact SPI at any speed)')
            [CompletionResult]::new('--no-overrun', '--no-overrun', [CompletionResultType]::ParameterName, 'Fail (exit 50) if any samples were lost')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'bsly;decode' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('spi', 'spi', [CompletionResultType]::ParameterValue, 'SPI transactions from a capture made with --spi')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;decode;spi' {
            [CompletionResult]::new('--cs', '--cs', [CompletionResultType]::ParameterName, 'Only transactions on this chip select')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;decode;help' {
            [CompletionResult]::new('spi', 'spi', [CompletionResultType]::ParameterValue, 'SPI transactions from a capture made with --spi')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;decode;help;spi' {
            break
        }
        'bsly;decode;help;help' {
            break
        }
        'bsly;i2c' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read bytes, optionally writing a register address first (repeated START)')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write bytes')
            [CompletionResult]::new('recover', 'recover', [CompletionResultType]::ParameterValue, 'Clock SCL until a stuck device releases SDA')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;i2c;scan' {
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;i2c;read' {
            [CompletionResult]::new('--reg', '--reg', [CompletionResultType]::ParameterName, 'Bytes to write first, e.g. 1900 for a 16-bit register')
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;i2c;write' {
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;i2c;recover' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;i2c;help' {
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read bytes, optionally writing a register address first (repeated START)')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write bytes')
            [CompletionResult]::new('recover', 'recover', [CompletionResultType]::ParameterValue, 'Clock SCL until a stuck device releases SDA')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;i2c;help;scan' {
            break
        }
        'bsly;i2c;help;read' {
            break
        }
        'bsly;i2c;help;write' {
            break
        }
        'bsly;i2c;help;recover' {
            break
        }
        'bsly;i2c;help;help' {
            break
        }
        'bsly;deckctrl' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'Enumerate the deck controllers as a Crazyflie does (resets them all)')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Identification page, CPU ID and GPIO state of one deck')
            [CompletionResult]::new('gpio', 'gpio', [CompletionResultType]::ParameterValue, 'Show or set the deck controller''s GPIOs (prompts when omitted)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read registers')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write registers')
            [CompletionResult]::new('reset', 'reset', [CompletionResultType]::ParameterValue, 'Reset every deck controller to its power-on state')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;deckctrl;scan' {
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;info' {
            [CompletionResult]::new('-D', '-D ', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--deck', '--deck', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;gpio' {
            [CompletionResult]::new('-D', '-D ', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--deck', '--deck', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Direction and level of every GPIO')
            [CompletionResult]::new('dir', 'dir', [CompletionResultType]::ParameterValue, 'Make GPIOs inputs or outputs')
            [CompletionResult]::new('level', 'level', [CompletionResultType]::ParameterValue, 'Set the output level (takes effect on outputs)')
            [CompletionResult]::new('out', 'out', [CompletionResultType]::ParameterValue, 'Drive GPIOs: set the level, then make them outputs (no glitch)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;deckctrl;gpio;show' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;gpio;dir' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;gpio;level' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;gpio;out' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;gpio;help' {
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Direction and level of every GPIO')
            [CompletionResult]::new('dir', 'dir', [CompletionResultType]::ParameterValue, 'Make GPIOs inputs or outputs')
            [CompletionResult]::new('level', 'level', [CompletionResultType]::ParameterValue, 'Set the output level (takes effect on outputs)')
            [CompletionResult]::new('out', 'out', [CompletionResultType]::ParameterValue, 'Drive GPIOs: set the level, then make them outputs (no glitch)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;deckctrl;gpio;help;show' {
            break
        }
        'bsly;deckctrl;gpio;help;dir' {
            break
        }
        'bsly;deckctrl;gpio;help;level' {
            break
        }
        'bsly;deckctrl;gpio;help;out' {
            break
        }
        'bsly;deckctrl;gpio;help;help' {
            break
        }
        'bsly;deckctrl;read' {
            [CompletionResult]::new('-D', '-D ', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--deck', '--deck', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;write' {
            [CompletionResult]::new('-D', '-D ', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--deck', '--deck', [CompletionResultType]::ParameterName, 'Address (0x44), index (0), name or CPU ID prefix; asks when several')
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;reset' {
            [CompletionResult]::new('--i2c-rate', '--i2c-rate', [CompletionResultType]::ParameterName, 'SCL rate (the Crazyflie runs the deck bus at 400 kHz)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC on without asking if it is unpowered')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Drive the bus even though a Crazyflie seems to be its master')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;deckctrl;help' {
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'Enumerate the deck controllers as a Crazyflie does (resets them all)')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Identification page, CPU ID and GPIO state of one deck')
            [CompletionResult]::new('gpio', 'gpio', [CompletionResultType]::ParameterValue, 'Show or set the deck controller''s GPIOs (prompts when omitted)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read registers')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write registers')
            [CompletionResult]::new('reset', 'reset', [CompletionResultType]::ParameterValue, 'Reset every deck controller to its power-on state')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;deckctrl;help;scan' {
            break
        }
        'bsly;deckctrl;help;info' {
            break
        }
        'bsly;deckctrl;help;gpio' {
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Direction and level of every GPIO')
            [CompletionResult]::new('dir', 'dir', [CompletionResultType]::ParameterValue, 'Make GPIOs inputs or outputs')
            [CompletionResult]::new('level', 'level', [CompletionResultType]::ParameterValue, 'Set the output level (takes effect on outputs)')
            [CompletionResult]::new('out', 'out', [CompletionResultType]::ParameterValue, 'Drive GPIOs: set the level, then make them outputs (no glitch)')
            break
        }
        'bsly;deckctrl;help;gpio;show' {
            break
        }
        'bsly;deckctrl;help;gpio;dir' {
            break
        }
        'bsly;deckctrl;help;gpio;level' {
            break
        }
        'bsly;deckctrl;help;gpio;out' {
            break
        }
        'bsly;deckctrl;help;read' {
            break
        }
        'bsly;deckctrl;help;write' {
            break
        }
        'bsly;deckctrl;help;reset' {
            break
        }
        'bsly;deckctrl;help;help' {
            break
        }
        'bsly;uart' {
            [CompletionResult]::new('-l', '-l', [CompletionResultType]::ParameterName, 'Lines to decode (named as on the Crazyflie: RX1 is what a deck sends the CF on UART1)')
            [CompletionResult]::new('--line', '--line', [CompletionResultType]::ParameterName, 'Lines to decode (named as on the Crazyflie: RX1 is what a deck sends the CF on UART1)')
            [CompletionResult]::new('-b', '-b', [CompletionResultType]::ParameterName, 'Baud rate')
            [CompletionResult]::new('--baud', '--baud', [CompletionResultType]::ParameterName, 'Baud rate')
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Sample rate; default 16x the baud rate, at least 1 Msps')
            [CompletionResult]::new('--rate', '--rate', [CompletionResultType]::ParameterName, 'Sample rate; default 16x the baud rate, at least 1 Msps')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'How long to listen; until Ctrl-C when omitted')
            [CompletionResult]::new('--duration', '--duration', [CompletionResultType]::ParameterName, 'How long to listen; until Ctrl-C when omitted')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--hex', '--hex', [CompletionResultType]::ParameterName, 'Print bytes as hex instead of text')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;mux' {
            [CompletionResult]::new('--wait', '--wait', [CompletionResultType]::ParameterName, 'Seconds to wait for a USB device after switching to usb')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'bsly;drive' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;bridge' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--power', '--power', [CompletionResultType]::ParameterName, 'Switch the port''s VCC and VCOM on without asking if needed')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;update' {
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Install this release instead of the latest, e.g. 0.8.0 (one chip)')
            [CompletionResult]::new('--file', '--file', [CompletionResultType]::ParameterName, 'Install this UF2 instead of a release (one chip)')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--check', '--check', [CompletionResultType]::ParameterName, 'Only show installed and latest versions')
            [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Consider prereleases too')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Reinstall even when the installed version is current')
            [CompletionResult]::new('-y', '-y', [CompletionResultType]::ParameterName, 'Don''t ask before installing')
            [CompletionResult]::new('--yes', '--yes', [CompletionResultType]::ParameterName, 'Don''t ask before installing')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'bsly;swo' {
            [CompletionResult]::new('--swd', '--swd', [CompletionResultType]::ParameterName, 'Probe port the target is on: 1 (P1) or 2 (P5); the others have no SWO')
            [CompletionResult]::new('-b', '-b', [CompletionResultType]::ParameterName, 'SWO baud rate; must match the target''s TPIU (the Crazyflie firmware''s CONFIG_DEBUG_PRINT_ON_SWO_BAUDRATE, 2000000 by default)')
            [CompletionResult]::new('--baud', '--baud', [CompletionResultType]::ParameterName, 'SWO baud rate; must match the target''s TPIU (the Crazyflie firmware''s CONFIG_DEBUG_PRINT_ON_SWO_BAUDRATE, 2000000 by default)')
            [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'ITM stimulus ports to print (DEBUG_PRINT is port 0)')
            [CompletionResult]::new('--port', '--port', [CompletionResultType]::ParameterName, 'ITM stimulus ports to print (DEBUG_PRINT is port 0)')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'How long to listen; until Ctrl-C when omitted')
            [CompletionResult]::new('--duration', '--duration', [CompletionResultType]::ParameterName, 'How long to listen; until Ctrl-C when omitted')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--hex', '--hex', [CompletionResultType]::ParameterName, 'Print payloads as hex instead of text')
            [CompletionResult]::new('--raw', '--raw', [CompletionResultType]::ParameterName, 'Print the raw SWO bytes, without decoding ITM')
            [CompletionResult]::new('--no-swd', '--no-swd', [CompletionResultType]::ParameterName, 'Do not switch the target''s debug port to SWD (SWO is silent in JTAG mode)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;raw' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;settings' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the settings')
            [CompletionResult]::new('clear', 'clear', [CompletionResultType]::ParameterValue, 'Forget the selected deck')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;settings;show' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;settings;clear' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;settings;help' {
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the settings')
            [CompletionResult]::new('clear', 'clear', [CompletionResultType]::ParameterValue, 'Forget the selected deck')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;settings;help;show' {
            break
        }
        'bsly;settings;help;clear' {
            break
        }
        'bsly;settings;help;help' {
            break
        }
        'bsly;completions' {
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--serial', '--serial', [CompletionResultType]::ParameterName, 'Use the deck with this serial number (instead of the selected one)')
            [CompletionResult]::new('--non-interactive', '--non-interactive', [CompletionResultType]::ParameterName, 'Disable interactive prompts (auto-set when stdin is not a TTY)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('--debug', '--debug', [CompletionResultType]::ParameterName, 'Print every control-channel line sent and received')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'bsly;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List connected Bugslayer decks and their USB devices')
            [CompletionResult]::new('select', 'select', [CompletionResultType]::ParameterValue, 'Pick which deck to use by default when several are connected')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Firmware versions, serial number and USB devices of the deck')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Capture engine and FX2 link status')
            [CompletionResult]::new('pins', 'pins', [CompletionResultType]::ParameterValue, 'Live level of every expansion-port signal')
            [CompletionResult]::new('power', 'power', [CompletionResultType]::ParameterValue, 'Switch the deck''s high-side power switches (prompts when omitted)')
            [CompletionResult]::new('pull', 'pull', [CompletionResultType]::ParameterValue, 'I2C pull-ups on the expansion port (standalone only; prompts when omitted)')
            [CompletionResult]::new('fx2', 'fx2', [CompletionResultType]::ParameterValue, 'Control the FX2 (CBM9002A) capture pipe (prompts when omitted)')
            [CompletionResult]::new('capture', 'capture', [CompletionResultType]::ParameterValue, 'Record the expansion port: arm, stream, verify and write a sigrok .sr')
            [CompletionResult]::new('decode', 'decode', [CompletionResultType]::ParameterValue, 'Decode a saved capture')
            [CompletionResult]::new('i2c', 'i2c', [CompletionResultType]::ParameterValue, 'Raw I2C on the expansion port, with the deck as master')
            [CompletionResult]::new('deckctrl', 'deckctrl', [CompletionResultType]::ParameterValue, 'Deck controllers (DeckCtrl) on the expansion-port I2C bus')
            [CompletionResult]::new('uart', 'uart', [CompletionResultType]::ParameterValue, 'Print what UART lines on the expansion port carry (sniffed, never driven)')
            [CompletionResult]::new('mux', 'mux', [CompletionResultType]::ParameterValue, 'Switch the port''s TX2/RX2 between UART2 and USB (the deck''s hub port 4, for decks with a USB MCU there: D- = TX2, D+ = RX2); standalone only')
            [CompletionResult]::new('drive', 'drive', [CompletionResultType]::ParameterValue, 'Hold an IO pin low, e.g. a deck MCU''s BOOT line, or release it (open drain, never driven high; standalone only)')
            [CompletionResult]::new('bridge', 'bridge', [CompletionResultType]::ParameterValue, 'Bridge the Crazyflie''s UART1/UART2 to a serial port of the deck, with the deck standing in for the Crazyflie (standalone only)')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Check the deck''s firmware against the GitHub releases and install updates through the USB bootloaders (private repos: `gh auth login`)')
            [CompletionResult]::new('swo', 'swo', [CompletionResultType]::ParameterValue, 'Print a target''s SWO trace (ITM, e.g. the Crazyflie''s DEBUG_PRINT)')
            [CompletionResult]::new('raw', 'raw', [CompletionResultType]::ParameterValue, 'Send raw control-channel lines; with none, open an interactive console')
            [CompletionResult]::new('settings', 'settings', [CompletionResultType]::ParameterValue, 'Local CLI settings')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate a shell completion script (printed to stdout)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'bsly;help;list' {
            break
        }
        'bsly;help;select' {
            break
        }
        'bsly;help;info' {
            break
        }
        'bsly;help;status' {
            break
        }
        'bsly;help;pins' {
            break
        }
        'bsly;help;power' {
            break
        }
        'bsly;help;pull' {
            break
        }
        'bsly;help;fx2' {
            [CompletionResult]::new('up', 'up', [CompletionResultType]::ParameterValue, 'Serve the boot image, start IFCLK and release reset')
            [CompletionResult]::new('down', 'down', [CompletionResultType]::ParameterValue, 'Hold the FX2 in reset')
            [CompletionResult]::new('reboot', 'reboot', [CompletionResultType]::ParameterValue, 'Down, then up: the FX2 boots again')
            [CompletionResult]::new('boot', 'boot', [CompletionResultType]::ParameterValue, 'What the emulated EEPROM serves at the next up/reboot')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Is the FX2 up and enumerated, and with which serial')
            break
        }
        'bsly;help;fx2;up' {
            break
        }
        'bsly;help;fx2;down' {
            break
        }
        'bsly;help;fx2;reboot' {
            break
        }
        'bsly;help;fx2;boot' {
            break
        }
        'bsly;help;fx2;status' {
            break
        }
        'bsly;help;capture' {
            break
        }
        'bsly;help;decode' {
            [CompletionResult]::new('spi', 'spi', [CompletionResultType]::ParameterValue, 'SPI transactions from a capture made with --spi')
            break
        }
        'bsly;help;decode;spi' {
            break
        }
        'bsly;help;i2c' {
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'List the addresses that acknowledge (skips the DeckCtrl reset/listen addresses 0x41/0x42, which have side effects)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read bytes, optionally writing a register address first (repeated START)')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write bytes')
            [CompletionResult]::new('recover', 'recover', [CompletionResultType]::ParameterValue, 'Clock SCL until a stuck device releases SDA')
            break
        }
        'bsly;help;i2c;scan' {
            break
        }
        'bsly;help;i2c;read' {
            break
        }
        'bsly;help;i2c;write' {
            break
        }
        'bsly;help;i2c;recover' {
            break
        }
        'bsly;help;deckctrl' {
            [CompletionResult]::new('scan', 'scan', [CompletionResultType]::ParameterValue, 'Enumerate the deck controllers as a Crazyflie does (resets them all)')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Identification page, CPU ID and GPIO state of one deck')
            [CompletionResult]::new('gpio', 'gpio', [CompletionResultType]::ParameterValue, 'Show or set the deck controller''s GPIOs (prompts when omitted)')
            [CompletionResult]::new('read', 'read', [CompletionResultType]::ParameterValue, 'Read registers')
            [CompletionResult]::new('write', 'write', [CompletionResultType]::ParameterValue, 'Write registers')
            [CompletionResult]::new('reset', 'reset', [CompletionResultType]::ParameterValue, 'Reset every deck controller to its power-on state')
            break
        }
        'bsly;help;deckctrl;scan' {
            break
        }
        'bsly;help;deckctrl;info' {
            break
        }
        'bsly;help;deckctrl;gpio' {
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Direction and level of every GPIO')
            [CompletionResult]::new('dir', 'dir', [CompletionResultType]::ParameterValue, 'Make GPIOs inputs or outputs')
            [CompletionResult]::new('level', 'level', [CompletionResultType]::ParameterValue, 'Set the output level (takes effect on outputs)')
            [CompletionResult]::new('out', 'out', [CompletionResultType]::ParameterValue, 'Drive GPIOs: set the level, then make them outputs (no glitch)')
            break
        }
        'bsly;help;deckctrl;gpio;show' {
            break
        }
        'bsly;help;deckctrl;gpio;dir' {
            break
        }
        'bsly;help;deckctrl;gpio;level' {
            break
        }
        'bsly;help;deckctrl;gpio;out' {
            break
        }
        'bsly;help;deckctrl;read' {
            break
        }
        'bsly;help;deckctrl;write' {
            break
        }
        'bsly;help;deckctrl;reset' {
            break
        }
        'bsly;help;uart' {
            break
        }
        'bsly;help;mux' {
            break
        }
        'bsly;help;drive' {
            break
        }
        'bsly;help;bridge' {
            break
        }
        'bsly;help;update' {
            break
        }
        'bsly;help;swo' {
            break
        }
        'bsly;help;raw' {
            break
        }
        'bsly;help;settings' {
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the settings')
            [CompletionResult]::new('clear', 'clear', [CompletionResultType]::ParameterValue, 'Forget the selected deck')
            break
        }
        'bsly;help;settings;show' {
            break
        }
        'bsly;help;settings;clear' {
            break
        }
        'bsly;help;completions' {
            break
        }
        'bsly;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}

use std::fmt;

/// Classified errors that map to the exit codes the CLI promises its callers
/// (humans and scripts). The exit code is the contract; the message is
/// best-effort and can change.
#[derive(Debug)]
pub enum CliError {
    Connection(String),
    NotFound(String),
    /// A required argument wasn't supplied and the CLI is non-interactive.
    MissingArg(String),
    /// The deck answered a command with `err ...`.
    Rejected(String),
    Verification(String),
}

impl CliError {
    pub fn exit_code(&self) -> i32 {
        match self {
            CliError::Connection(_) => 10,
            CliError::NotFound(_) => 20,
            CliError::MissingArg(_) | CliError::Rejected(_) => 30,
            CliError::Verification(_) => 50,
        }
    }
}

impl fmt::Display for CliError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CliError::Connection(s) => write!(f, "connection error: {}", s),
            CliError::NotFound(s) => write!(f, "not found: {}", s),
            CliError::MissingArg(s) => write!(f, "missing argument: {}", s),
            CliError::Rejected(s) => write!(f, "the deck rejected the command: {}", s),
            CliError::Verification(s) => write!(f, "verification failed: {}", s),
        }
    }
}

impl std::error::Error for CliError {}

/// The exit code for an error the bugslayer library classified.
fn lib_exit_code(e: &bugslayer::Error) -> i32 {
    use bugslayer::Error as E;
    match e {
        E::Connection(_) => 10,
        E::NotFound(_) => 20,
        E::Rejected(_) | E::Unpowered(_) => 30,
        E::Timeout(_) => 40,
        E::Verification(_) => 50,
    }
}

/// The most specific exit code in the error chain; unclassified failures
/// return 1.
pub fn classify_exit_code(err: &anyhow::Error) -> i32 {
    // Downcasting the anyhow error itself finds a `CliError` attached with
    // `.context()`; the chain only exposes anyhow's wrapper type there.
    if let Some(cli) = err.downcast_ref::<CliError>() {
        return cli.exit_code();
    }
    if let Some(e) = bugslayer::error::find(err) {
        return lib_exit_code(e);
    }
    for cause in err.chain() {
        if let Some(cli) = cause.downcast_ref::<CliError>() {
            return cli.exit_code();
        }
        if cause.downcast_ref::<serialport::Error>().is_some()
            || cause.downcast_ref::<nusb::Error>().is_some()
        {
            return 10;
        }
    }
    1
}

/// Extra guidance for failures with a known way out.
pub fn hint(err: &anyhow::Error) -> Option<String> {
    for cause in err.chain() {
        if let Some(e) = cause.downcast_ref::<nusb::Error>() {
            if e.kind() == nusb::ErrorKind::PermissionDenied {
                return Some(
                    "no access to the deck's USB devices; install the udev rules \
                     (udev/70-bugslayer-deck.rules in bugslayer-cli; the bscli .deb installs them)"
                        .to_string(),
                );
            }
            if e.kind() == nusb::ErrorKind::Busy {
                return Some("another program (bsly.py? PulseView?) has the interface claimed".to_string());
            }
        }
    }
    None
}

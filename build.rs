// Generates shell-completion scripts from the same clap command tree as the
// binary, so completions ship with the package. The CLI definition lives in
// `src/cli.rs` and is shared with `main.rs` via `include!`; it is
// self-contained (no `use`/`mod`) so it can be compiled here against the
// build-dependencies declared in Cargo.toml.
//
// Static completion (subcommands, flags, value enums, file paths via
// ValueHint) comes straight from clap_complete. Dynamic values (the serial
// numbers of the connected decks) are added by appending the per-shell
// `completions/addendum.*` glue, which calls `bsly __complete` at runtime.

use clap_complete::{generate_to, Shell};
use std::fs;
use std::path::{Path, PathBuf};

// Fields are never read here (we only build the clap `Command`).
#[allow(dead_code)]
mod cli {
    use clap::{Args, CommandFactory, Parser, Subcommand, ValueEnum, ValueHint};
    include!("src/cli.rs");

    pub fn command() -> clap::Command {
        CliArgs::command()
    }
}

fn append_file(target: &Path, addendum: &Path) {
    if let (Ok(mut base), Ok(extra)) = (fs::read_to_string(target), fs::read_to_string(addendum)) {
        base.push_str(&extra);
        let _ = fs::write(target, base);
    }
}

fn main() {
    println!("cargo:rerun-if-changed=src/cli.rs");
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=completions/addendum.bash");
    println!("cargo:rerun-if-changed=completions/addendum.zsh");

    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let out_dir = manifest.join("completions");
    fs::create_dir_all(&out_dir).expect("create completions dir");

    let mut cmd = cli::command();
    let bin = "bsly";
    for shell in [Shell::Bash, Shell::Zsh, Shell::Fish, Shell::PowerShell] {
        generate_to(shell, &mut cmd, bin, &out_dir).expect("generate completion");
    }

    // bash: wrap the generated function to add dynamic candidates.
    append_file(&out_dir.join("bsly.bash"), &out_dir.join("addendum.bash"));

    // zsh: point the `--serial` action at our helper, and define the helper
    // before clap's autoload self-invocation near the end of the file.
    let zsh_path = out_dir.join("_bsly");
    if let Ok(mut s) = fs::read_to_string(&zsh_path) {
        s = s.replace(":SERIAL:_default", ":SERIAL:_bsly_serials");
        if let Ok(extra) = fs::read_to_string(out_dir.join("addendum.zsh")) {
            match s.find("\n_bsly() {") {
                Some(pos) => s.insert_str(pos + 1, &format!("{}\n", extra.trim_end())),
                None => s.push_str(&extra),
            }
        }
        let _ = fs::write(&zsh_path, s);
    }
}

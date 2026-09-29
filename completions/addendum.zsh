# ---- bsly dynamic completion --------------------------------------------
# Inserted by build.rs into the clap-generated zsh completion, which also
# points the `--serial` action here. `bsly __complete` only lists USB devices
# and never talks to a deck.
_bsly_serials() {
    local -a serials
    serials=(${(f)"$(bsly __complete serials "$PREFIX" 2>/dev/null)"})
    compadd -a serials
}

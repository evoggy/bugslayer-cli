# ---- bscli dynamic completion --------------------------------------------
# Inserted by build.rs into the clap-generated zsh completion, which also
# points the `--serial` action here. `bscli __complete` only lists USB devices
# and never talks to a deck.
_bscli_serials() {
    local -a serials
    serials=(${(f)"$(bscli __complete serials "$PREFIX" 2>/dev/null)"})
    compadd -a serials
}

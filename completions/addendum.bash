
# ---- bscli dynamic completion --------------------------------------------
# Appended by build.rs to the clap-generated bash completion. Adds the serial
# numbers of the connected decks for `--serial`, from `bscli __complete`, which
# only lists USB devices and never talks to a deck.
_bscli_dynamic() {
    _bscli "$@"

    # Drop clap's positional metavar placeholders (e.g. [LINES]...).
    local _c _kept=()
    for _c in "${COMPREPLY[@]}"; do
        case "$_c" in
            '['*']'* | '<'*'>'*) ;;
            *) _kept+=("$_c") ;;
        esac
    done
    COMPREPLY=("${_kept[@]}")

    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ "$prev" == "--serial" || "$prev" == "-s" ]]; then
        local c
        COMPREPLY=()
        while IFS= read -r c; do
            [[ -n "$c" ]] && COMPREPLY+=("$c")
        done < <(bscli __complete serials "$cur" 2>/dev/null)
    fi
}
complete -F _bscli_dynamic -o bashdefault -o default bscli

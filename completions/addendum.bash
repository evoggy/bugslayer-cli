
# ---- bsly dynamic completion --------------------------------------------
# Appended by build.rs to the clap-generated bash completion. Adds the serial
# numbers of the connected decks for `--serial`, from `bsly __complete`, which
# only lists USB devices and never talks to a deck.
_bsly_dynamic() {
    _bsly "$@"

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
        done < <(bsly __complete serials "$cur" 2>/dev/null)
    fi
}
complete -F _bsly_dynamic -o bashdefault -o default bsly

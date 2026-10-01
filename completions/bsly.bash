_bsly() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="bsly"
                ;;
            bsly,bridge)
                cmd="bsly__subcmd__bridge"
                ;;
            bsly,capture)
                cmd="bsly__subcmd__capture"
                ;;
            bsly,completions)
                cmd="bsly__subcmd__completions"
                ;;
            bsly,deckctrl)
                cmd="bsly__subcmd__deckctrl"
                ;;
            bsly,decode)
                cmd="bsly__subcmd__decode"
                ;;
            bsly,drive)
                cmd="bsly__subcmd__drive"
                ;;
            bsly,fx2)
                cmd="bsly__subcmd__fx2"
                ;;
            bsly,help)
                cmd="bsly__subcmd__help"
                ;;
            bsly,i2c)
                cmd="bsly__subcmd__i2c"
                ;;
            bsly,info)
                cmd="bsly__subcmd__info"
                ;;
            bsly,list)
                cmd="bsly__subcmd__list"
                ;;
            bsly,mux)
                cmd="bsly__subcmd__mux"
                ;;
            bsly,pins)
                cmd="bsly__subcmd__pins"
                ;;
            bsly,power)
                cmd="bsly__subcmd__power"
                ;;
            bsly,pull)
                cmd="bsly__subcmd__pull"
                ;;
            bsly,raw)
                cmd="bsly__subcmd__raw"
                ;;
            bsly,select)
                cmd="bsly__subcmd__select"
                ;;
            bsly,settings)
                cmd="bsly__subcmd__settings"
                ;;
            bsly,status)
                cmd="bsly__subcmd__status"
                ;;
            bsly,swo)
                cmd="bsly__subcmd__swo"
                ;;
            bsly,uart)
                cmd="bsly__subcmd__uart"
                ;;
            bsly,update)
                cmd="bsly__subcmd__update"
                ;;
            bsly__subcmd__deckctrl,gpio)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio"
                ;;
            bsly__subcmd__deckctrl,help)
                cmd="bsly__subcmd__deckctrl__subcmd__help"
                ;;
            bsly__subcmd__deckctrl,info)
                cmd="bsly__subcmd__deckctrl__subcmd__info"
                ;;
            bsly__subcmd__deckctrl,read)
                cmd="bsly__subcmd__deckctrl__subcmd__read"
                ;;
            bsly__subcmd__deckctrl,reset)
                cmd="bsly__subcmd__deckctrl__subcmd__reset"
                ;;
            bsly__subcmd__deckctrl,scan)
                cmd="bsly__subcmd__deckctrl__subcmd__scan"
                ;;
            bsly__subcmd__deckctrl,write)
                cmd="bsly__subcmd__deckctrl__subcmd__write"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio,dir)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__dir"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio,help)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio,level)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__level"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio,out)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__out"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio,show)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__show"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help,dir)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__dir"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help,help)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help,level)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__level"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help,out)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__out"
                ;;
            bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help,show)
                cmd="bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__show"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,gpio)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,help)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,info)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__info"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,read)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__read"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,reset)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__reset"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,scan)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__scan"
                ;;
            bsly__subcmd__deckctrl__subcmd__help,write)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__write"
                ;;
            bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio,dir)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__dir"
                ;;
            bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio,level)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__level"
                ;;
            bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio,out)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__out"
                ;;
            bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio,show)
                cmd="bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__show"
                ;;
            bsly__subcmd__decode,help)
                cmd="bsly__subcmd__decode__subcmd__help"
                ;;
            bsly__subcmd__decode,spi)
                cmd="bsly__subcmd__decode__subcmd__spi"
                ;;
            bsly__subcmd__decode__subcmd__help,help)
                cmd="bsly__subcmd__decode__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__decode__subcmd__help,spi)
                cmd="bsly__subcmd__decode__subcmd__help__subcmd__spi"
                ;;
            bsly__subcmd__fx2,boot)
                cmd="bsly__subcmd__fx2__subcmd__boot"
                ;;
            bsly__subcmd__fx2,down)
                cmd="bsly__subcmd__fx2__subcmd__down"
                ;;
            bsly__subcmd__fx2,help)
                cmd="bsly__subcmd__fx2__subcmd__help"
                ;;
            bsly__subcmd__fx2,reboot)
                cmd="bsly__subcmd__fx2__subcmd__reboot"
                ;;
            bsly__subcmd__fx2,status)
                cmd="bsly__subcmd__fx2__subcmd__status"
                ;;
            bsly__subcmd__fx2,up)
                cmd="bsly__subcmd__fx2__subcmd__up"
                ;;
            bsly__subcmd__fx2__subcmd__help,boot)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__boot"
                ;;
            bsly__subcmd__fx2__subcmd__help,down)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__down"
                ;;
            bsly__subcmd__fx2__subcmd__help,help)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__fx2__subcmd__help,reboot)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__reboot"
                ;;
            bsly__subcmd__fx2__subcmd__help,status)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__status"
                ;;
            bsly__subcmd__fx2__subcmd__help,up)
                cmd="bsly__subcmd__fx2__subcmd__help__subcmd__up"
                ;;
            bsly__subcmd__help,bridge)
                cmd="bsly__subcmd__help__subcmd__bridge"
                ;;
            bsly__subcmd__help,capture)
                cmd="bsly__subcmd__help__subcmd__capture"
                ;;
            bsly__subcmd__help,completions)
                cmd="bsly__subcmd__help__subcmd__completions"
                ;;
            bsly__subcmd__help,deckctrl)
                cmd="bsly__subcmd__help__subcmd__deckctrl"
                ;;
            bsly__subcmd__help,decode)
                cmd="bsly__subcmd__help__subcmd__decode"
                ;;
            bsly__subcmd__help,drive)
                cmd="bsly__subcmd__help__subcmd__drive"
                ;;
            bsly__subcmd__help,fx2)
                cmd="bsly__subcmd__help__subcmd__fx2"
                ;;
            bsly__subcmd__help,help)
                cmd="bsly__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__help,i2c)
                cmd="bsly__subcmd__help__subcmd__i2c"
                ;;
            bsly__subcmd__help,info)
                cmd="bsly__subcmd__help__subcmd__info"
                ;;
            bsly__subcmd__help,list)
                cmd="bsly__subcmd__help__subcmd__list"
                ;;
            bsly__subcmd__help,mux)
                cmd="bsly__subcmd__help__subcmd__mux"
                ;;
            bsly__subcmd__help,pins)
                cmd="bsly__subcmd__help__subcmd__pins"
                ;;
            bsly__subcmd__help,power)
                cmd="bsly__subcmd__help__subcmd__power"
                ;;
            bsly__subcmd__help,pull)
                cmd="bsly__subcmd__help__subcmd__pull"
                ;;
            bsly__subcmd__help,raw)
                cmd="bsly__subcmd__help__subcmd__raw"
                ;;
            bsly__subcmd__help,select)
                cmd="bsly__subcmd__help__subcmd__select"
                ;;
            bsly__subcmd__help,settings)
                cmd="bsly__subcmd__help__subcmd__settings"
                ;;
            bsly__subcmd__help,status)
                cmd="bsly__subcmd__help__subcmd__status"
                ;;
            bsly__subcmd__help,swo)
                cmd="bsly__subcmd__help__subcmd__swo"
                ;;
            bsly__subcmd__help,uart)
                cmd="bsly__subcmd__help__subcmd__uart"
                ;;
            bsly__subcmd__help,update)
                cmd="bsly__subcmd__help__subcmd__update"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,gpio)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,info)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__info"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,read)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__read"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,reset)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__reset"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,scan)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__scan"
                ;;
            bsly__subcmd__help__subcmd__deckctrl,write)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__write"
                ;;
            bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio,dir)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__dir"
                ;;
            bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio,level)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__level"
                ;;
            bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio,out)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__out"
                ;;
            bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio,show)
                cmd="bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__show"
                ;;
            bsly__subcmd__help__subcmd__decode,spi)
                cmd="bsly__subcmd__help__subcmd__decode__subcmd__spi"
                ;;
            bsly__subcmd__help__subcmd__fx2,boot)
                cmd="bsly__subcmd__help__subcmd__fx2__subcmd__boot"
                ;;
            bsly__subcmd__help__subcmd__fx2,down)
                cmd="bsly__subcmd__help__subcmd__fx2__subcmd__down"
                ;;
            bsly__subcmd__help__subcmd__fx2,reboot)
                cmd="bsly__subcmd__help__subcmd__fx2__subcmd__reboot"
                ;;
            bsly__subcmd__help__subcmd__fx2,status)
                cmd="bsly__subcmd__help__subcmd__fx2__subcmd__status"
                ;;
            bsly__subcmd__help__subcmd__fx2,up)
                cmd="bsly__subcmd__help__subcmd__fx2__subcmd__up"
                ;;
            bsly__subcmd__help__subcmd__i2c,read)
                cmd="bsly__subcmd__help__subcmd__i2c__subcmd__read"
                ;;
            bsly__subcmd__help__subcmd__i2c,recover)
                cmd="bsly__subcmd__help__subcmd__i2c__subcmd__recover"
                ;;
            bsly__subcmd__help__subcmd__i2c,scan)
                cmd="bsly__subcmd__help__subcmd__i2c__subcmd__scan"
                ;;
            bsly__subcmd__help__subcmd__i2c,write)
                cmd="bsly__subcmd__help__subcmd__i2c__subcmd__write"
                ;;
            bsly__subcmd__help__subcmd__settings,clear)
                cmd="bsly__subcmd__help__subcmd__settings__subcmd__clear"
                ;;
            bsly__subcmd__help__subcmd__settings,show)
                cmd="bsly__subcmd__help__subcmd__settings__subcmd__show"
                ;;
            bsly__subcmd__i2c,help)
                cmd="bsly__subcmd__i2c__subcmd__help"
                ;;
            bsly__subcmd__i2c,read)
                cmd="bsly__subcmd__i2c__subcmd__read"
                ;;
            bsly__subcmd__i2c,recover)
                cmd="bsly__subcmd__i2c__subcmd__recover"
                ;;
            bsly__subcmd__i2c,scan)
                cmd="bsly__subcmd__i2c__subcmd__scan"
                ;;
            bsly__subcmd__i2c,write)
                cmd="bsly__subcmd__i2c__subcmd__write"
                ;;
            bsly__subcmd__i2c__subcmd__help,help)
                cmd="bsly__subcmd__i2c__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__i2c__subcmd__help,read)
                cmd="bsly__subcmd__i2c__subcmd__help__subcmd__read"
                ;;
            bsly__subcmd__i2c__subcmd__help,recover)
                cmd="bsly__subcmd__i2c__subcmd__help__subcmd__recover"
                ;;
            bsly__subcmd__i2c__subcmd__help,scan)
                cmd="bsly__subcmd__i2c__subcmd__help__subcmd__scan"
                ;;
            bsly__subcmd__i2c__subcmd__help,write)
                cmd="bsly__subcmd__i2c__subcmd__help__subcmd__write"
                ;;
            bsly__subcmd__settings,clear)
                cmd="bsly__subcmd__settings__subcmd__clear"
                ;;
            bsly__subcmd__settings,help)
                cmd="bsly__subcmd__settings__subcmd__help"
                ;;
            bsly__subcmd__settings,show)
                cmd="bsly__subcmd__settings__subcmd__show"
                ;;
            bsly__subcmd__settings__subcmd__help,clear)
                cmd="bsly__subcmd__settings__subcmd__help__subcmd__clear"
                ;;
            bsly__subcmd__settings__subcmd__help,help)
                cmd="bsly__subcmd__settings__subcmd__help__subcmd__help"
                ;;
            bsly__subcmd__settings__subcmd__help,show)
                cmd="bsly__subcmd__settings__subcmd__help__subcmd__show"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        bsly)
            opts="-s -d -h -V --serial --non-interactive --debug --help --version list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__bridge)
            opts="-s -d -h --power --serial --non-interactive --debug --help 1 2 both on off"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__capture)
            opts="-r -t -o -s -d -h --rate --duration --output --source --sink --spi --spi-show --no-overrun --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -r)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --duration)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --source)
                    COMPREPLY=($(compgen -W "pins counter" -- "${cur}"))
                    return 0
                    ;;
                --sink)
                    COMPREPLY=($(compgen -W "auto usb fx2" -- "${cur}"))
                    return 0
                    ;;
                --spi-show)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__completions)
            opts="-s -d -h --serial --non-interactive --debug --help bash elvish fish powershell zsh"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl)
            opts="-s -d -h --serial --non-interactive --debug --help scan info gpio read write reset help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio)
            opts="-D -s -d -h --deck --i2c-rate --power --force --serial --non-interactive --debug --help show dir level out help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --deck)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -D)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__dir)
            opts="-s -d -h --serial --non-interactive --debug --help in out"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help)
            opts="show dir level out help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__dir)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__level)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__out)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__help__subcmd__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__level)
            opts="-s -d -h --serial --non-interactive --debug --help high low"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__out)
            opts="-s -d -h --serial --non-interactive --debug --help high low"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__gpio__subcmd__show)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help)
            opts="scan info gpio read write reset help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio)
            opts="show dir level out"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__dir)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__level)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__out)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__gpio__subcmd__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__info)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__read)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__reset)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__help__subcmd__write)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__info)
            opts="-D -s -d -h --deck --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --deck)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -D)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__read)
            opts="-D -s -d -h --deck --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --deck)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -D)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__reset)
            opts="-s -d -h --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__scan)
            opts="-s -d -h --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__deckctrl__subcmd__write)
            opts="-D -s -d -h --deck --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --deck)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -D)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__decode)
            opts="-s -d -h --serial --non-interactive --debug --help spi help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__decode__subcmd__help)
            opts="spi help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__decode__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__decode__subcmd__help__subcmd__spi)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__decode__subcmd__spi)
            opts="-s -d -h --cs --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --cs)
                    COMPREPLY=($(compgen -W "IO_1 IO_2 IO_3 IO_4" -- "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__drive)
            opts="-s -d -h --serial --non-interactive --debug --help IO_1 IO_2 IO_3 IO_4 low release"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2)
            opts="-s -d -h --serial --non-interactive --debug --help up down reboot boot status help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__boot)
            opts="-s -d -h --serial --non-interactive --debug --help c2 c0 rom"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__down)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help)
            opts="up down reboot boot status help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__boot)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__down)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__reboot)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__status)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__help__subcmd__up)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__reboot)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__status)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__fx2__subcmd__up)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help)
            opts="list select info status pins power pull fx2 capture decode i2c deckctrl uart mux drive bridge update swo raw settings completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__bridge)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__capture)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__completions)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl)
            opts="scan info gpio read write reset"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio)
            opts="show dir level out"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__dir)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__level)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__out)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__gpio__subcmd__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__info)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__read)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__reset)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__deckctrl__subcmd__write)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__decode)
            opts="spi"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__decode__subcmd__spi)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__drive)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2)
            opts="up down reboot boot status"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2__subcmd__boot)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2__subcmd__down)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2__subcmd__reboot)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2__subcmd__status)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__fx2__subcmd__up)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__i2c)
            opts="scan read write recover"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__i2c__subcmd__read)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__i2c__subcmd__recover)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__i2c__subcmd__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__i2c__subcmd__write)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__info)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__mux)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__pins)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__power)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__pull)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__raw)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__select)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__settings)
            opts="show clear"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__settings__subcmd__clear)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__settings__subcmd__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__status)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__swo)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__uart)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__help__subcmd__update)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c)
            opts="-s -d -h --serial --non-interactive --debug --help scan read write recover help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help)
            opts="scan read write recover help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help__subcmd__read)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help__subcmd__recover)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help__subcmd__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__help__subcmd__write)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__read)
            opts="-s -d -h --reg --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --reg)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__recover)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__scan)
            opts="-s -d -h --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__i2c__subcmd__write)
            opts="-s -d -h --i2c-rate --power --force --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --i2c-rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__info)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__list)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__mux)
            opts="-s -d -h --wait --serial --non-interactive --debug --help uart usb off"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__pins)
            opts="-w -s -d -h --watch --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__power)
            opts="-s -d -h --serial --non-interactive --debug --help vcc vcom on off"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__pull)
            opts="-s -d -h --serial --non-interactive --debug --help on off"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__raw)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__select)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings)
            opts="-s -d -h --serial --non-interactive --debug --help show clear help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__clear)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__help)
            opts="show clear help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__help__subcmd__clear)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__help__subcmd__show)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__settings__subcmd__show)
            opts="-s -d -h --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__status)
            opts="-w -s -d -h --watch --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__swo)
            opts="-b -p -t -s -d -h --swd --baud --port --duration --hex --raw --no-swd --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --swd)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --baud)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -b)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --port)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -p)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --duration)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__uart)
            opts="-l -b -r -t -s -d -h --line --baud --rate --duration --hex --serial --non-interactive --debug --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --line)
                    COMPREPLY=($(compgen -W "IO_1 IO_2 IO_3 IO_4 MISO OW SCK MOSI WKUP N_IO_1 TX2 RX2 TX1 RX1 SDA SCL" -- "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -W "IO_1 IO_2 IO_3 IO_4 MISO OW SCK MOSI WKUP N_IO_1 TX2 RX2 TX1 RX1 SDA SCL" -- "${cur}"))
                    return 0
                    ;;
                --baud)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -b)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -r)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --duration)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        bsly__subcmd__update)
            opts="-y -s -d -h --check --version --file --pre --force --yes --serial --non-interactive --debug --help rp2350 probe"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --version)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --serial)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _bsly -o nosort -o bashdefault -o default bsly
else
    complete -F _bsly -o bashdefault -o default bsly
fi

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

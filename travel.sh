declare -x TRAVEL_LIST_PATH="$HOME/.travel_list"
shopt -s extglob

_tt ()
{
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    if test -n "${TRAVEL_LIST[${COMP_WORDS[$COMP_CWORD]:-_}]}"; then
        COMPREPLY=( "${TRAVEL_LIST[${COMP_WORDS[$COMP_CWORD]}]}/" )
    elif [[ " ${!TRAVEL_LIST[@]}" =~ " ${COMP_WORDS[$COMP_CWORD]}" ]]; then
        COMPREPLY=( $(compgen -W "${!TRAVEL_LIST[*]}" "${COMP_WORDS[$COMP_CWORD]}" ) )
    fi
}
complete -o nospace -o dirnames -F _tt tt

_ttx ()
{
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    COMPREPLY=( $( compgen -W "${!TRAVEL_LIST[*]}" "${COMP_WORDS[$COMP_CWORD]}" ) )
}
complete -o nospace -F _ttx ttd
complete -o nospace -F _ttx ttr

tt ()
{
    [[ "$1" =~ ^-?-h(elp)?$ ]] && { tth; return 0; }
    test -z "$1" && { cd ~; return 0; }
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    if test -n "${TRAVEL_LIST[$1]}"; then
        cd "${TRAVEL_LIST[$1]}"
    elif test -d "$1"; then
        cd "$1"
    else
        printf '%s\n' "'$1' is neither an alias nor a directory" >&2
        return 1
    fi
}

tta ()
{
    test -n "$1" || { printf '%s\n' "tta requires at least one parameter" >&2; return 1; }
    test -d "$1" || { printf '%s\n' "Path '$1' is not a directory" >&2; return 1; }
    [[ "$1" == '/' ]] && { printf '%s\n' "Path cannot be /" >&2; return 1; }
    [[ "${1:0:1}" =~ ~|/ ]] || { printf '%s\n' "Path cannot be relative" >&2; return 1; }

    local _alias _path=${1%%+(/)}
    _alias="${2:-$_path}"
    _alias="${_alias##*/}"

    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    test -z "${TRAVEL_LIST[$_alias]}" || { printf '%s\n' "Alias '$_alias' is already set" >&2; return 1; }

    TRAVEL_LIST["$_alias"]="${_path/~/$HOME}"
    declare -p TRAVEL_LIST > "$TRAVEL_LIST_PATH"
}

ttd ()
{
    test -n "$1" || { printf '%s\n' "ttd requires at least one parameter" >&2; return 1; }
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    local _alias
    for _alias in "$@"; do
        test -n "${TRAVEL_LIST[$_alias]}" && unset TRAVEL_LIST["$_alias"]
    done

    declare -p TRAVEL_LIST > "$TRAVEL_LIST_PATH"
}

tth ()
{
    seq -s- $(( $( tput cols ) + 1 )) | tr -d '[0-9]'
    cat << ____HELP
Usage:

        tt (PATH|ALIAS)
                Travel to a directory by PATH or by ALIAS

        tta PATH [ALIAS]
                Add a PATH to the list.
                If an ALIAS is not given, the directory name will be used

        ttd ALIAS [... ALIAS]
                Remove an ALIAS from the list

        tth|tt (-h|-help|--help)
                displays this help text

        ttl
                List all stored paths

        ttr ALIAS1 ALIAS2
                Rename ALIAS1 to ALIAS2

Copyright © Ben Pitman
____HELP
    seq -s- $(( $( tput cols ) + 1 )) | tr -d '[0-9]'
}

ttl ()
{
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    local _alias
    for _alias in "${!TRAVEL_LIST[@]}"; do
        printf '%-16s= %s\n' "[$_alias]" "${TRAVEL_LIST[$_alias]}"
    done
}

ttr ()
{
    test -z "$1" -o -z "$2" && { printf '%s\n' "ttr requires two parameters" >&2; return 1; }
    test -s "$TRAVEL_LIST_PATH" && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    test -z "${TRAVEL_LIST[$1]}" && { printf '%s\n' "Alias '$1' is not set" >&2; return 1; }
    test -n "${TRAVEL_LIST[$2]}" && { printf '%s\n' "Alias '$2' is already set" >&2; return 1; }

    TRAVEL_LIST["$2"]="${TRAVEL_LIST[$1]}"
    unset TRAVEL_LIST["$1"]

    declare -p TRAVEL_LIST > "$TRAVEL_LIST_PATH"
}

declare -x TRAVEL_LIST_PATH="$HOME/.travel_list"
shopt -s extglob

_tt ()
{
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    if [[ -n "${TRAVEL_LIST[${COMP_WORDS[$COMP_CWORD]:-_}]}" ]]; then
        COMPREPLY=( "${TRAVEL_LIST[${COMP_WORDS[$COMP_CWORD]}]}/" )
    elif [[ " ${!TRAVEL_LIST[@]}" =~ " ${COMP_WORDS[$COMP_CWORD]}" ]]; then
        COMPREPLY=( $(compgen -W "${!TRAVEL_LIST[*]}" "${COMP_WORDS[$COMP_CWORD]}" ) )
    fi
}
complete -o nospace -o dirnames -F _tt tt

_ttx ()
{
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    COMPREPLY=( $( compgen -W "${!TRAVEL_LIST[*]}" "${COMP_WORDS[$COMP_CWORD]}" ) )
}
complete -o nospace -F _ttx ttd
complete -o nospace -F _ttx ttr

tt ()
{
    [[ -z "$1" ]] && { cd ~; return 0; }
    [[ "$1" =~ ^-?-h(elp)?$ ]] && { tth; return 0; }
    [[ "$1" == "-" ]] && { cd -; return 0; }
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    if [[ -n "${TRAVEL_LIST[$1]}" ]]; then
        cd "${TRAVEL_LIST[$1]}"
    elif [[ -d "$1" ]]; then
        cd "$1"
    else
        printf '%s\n' "'$1' is neither an alias nor a directory" >&2
        return 1
    fi
}

tta ()
{
    [[ -n "$1" ]] || { printf '%s\n' "tta requires at least one parameter" >&2; return 1; }

    local -- alias=
    local -- path=${1//+(\/)/\/} # Remove duplicate slashes

    [[ "${path:0:1}" == "~" ]] && path="${HOME}${path#~}" # Replace leading tilde with $HOME

    if [[ "${path:0:1}" != "/" ]]; then
        path="${PWD%\/}/${path#.\/}" # Add current directory to path if no leading slash
    fi

    local -- collapsed=
    while [[ "$path" =~ /\.\. ]]; do # Path contains \..
        collapsed="$(sed -r 's/[^./]+\/\.\.\/?//g' <<< "$path")" # Remove elements with a trailing \..\?
        [[ "$collapsed" == "$path" ]] && break
        path="$collapsed"
    done
    path="${path/+(\/..)/}" # Remove any occurances of /..
    path="${path%/}" # Remove trailing slash
    path="/${path##/}" # Remove leading slashes
    
    [[ "$path" == "/" ]] && { printf '%s\n' "Path cannot be '/'" >&2; return 1; }
    [[ -d "$path" ]] || { printf '%s\n' "Path '$path' is not a directory" >&2; return 1; }

    alias="${2:-$path}" # Set alias to second param, or path if unset
    alias="${alias##*/}" # Remove everything before and including the last slash
    alias="${alias,,}" # Change to lowercase
    alias="${alias//[^a-z0-9_-]/}" # Remove non-word characters

    [[ -z "$alias" ]] && { printf '%s\n' "Alias '$2' is invalid" >&2; return 1; }
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    [[ -z "${TRAVEL_LIST[$alias]}" ]] || { printf '%s\n' "Alias '$alias' is already set" >&2; return 1; }

    TRAVEL_LIST["$alias"]="$path"
    declare -p TRAVEL_LIST > "$TRAVEL_LIST_PATH"
}

ttd ()
{
    [[ -n "$1" ]] || { printf '%s\n' "ttd requires at least one parameter" >&2; return 1; }
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    local -- alias=

    for alias in "$@"; do
        [[ -n "${TRAVEL_LIST[$alias]}" ]] && unset TRAVEL_LIST["$alias"]
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
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST

    local -- alias=
    for alias in "${!TRAVEL_LIST[@]}"; do
        printf '%-16s= %s\n' "[$alias]" "${TRAVEL_LIST[$alias]}"
    done | sort
}

ttr ()
{
    [[ -z "$1" || -z "$2" ]] && { printf '%s\n' "ttr requires two parameters" >&2; return 1; }
    [[ -s "$TRAVEL_LIST_PATH" ]] && source "$TRAVEL_LIST_PATH" || declare -A TRAVEL_LIST
    [[ -z "${TRAVEL_LIST[$1]}" ]] && { printf '%s\n' "Alias '$1' is not set" >&2; return 1; }

    local -- alias="${2##*/}"
    alias="${alias,,}"
    alias="${alias//[^a-z0-9_-]/}"

    [[ -z "$alias" ]] && { printf '%s\n' "Alias '$2' is invalid" >&2; return 1; }
    [[ -n "${TRAVEL_LIST[$alias]}" ]] && { printf '%s\n' "Alias '$alias' is already set" >&2; return 1; }

    TRAVEL_LIST["$alias"]="${TRAVEL_LIST[$1]}"
    unset TRAVEL_LIST["$1"]

    declare -p TRAVEL_LIST > "$TRAVEL_LIST_PATH"
}

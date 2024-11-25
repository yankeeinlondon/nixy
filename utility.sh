#!/usr/bin/env bash

export RESET='\033[0m'

export GREEN='\033[38;5;2m'
export RED='\033[38;5;1m'
export YELLOW2='\033[38;5;3m'
export BLACK='\033[30m'
export RED='\033[31m'
export GREEN='\033[32m'
export YELLOW='\033[33m'
export BLUE='\033[34m'
export MAGENTA='\033[35m'
export CYAN='\033[36m'
export WHITE='\033[37m'

export BRIGHT_BLACK='\033[90m'
export BRIGHT_RED='\033[91m'
export BRIGHT_GREEN='\033[92m'
export BRIGHT_YELLOW='\033[93m'
export BRIGHT_BLUE='\033[94m'
export BRIGHT_MAGENTA='\033[95m'
export BRIGHT_CYAN='\033[96m'
export BRIGHT_WHITE='\033[97m'

export BOLD='\033[1m'
export NO_BOLD='\033[21m'
export DIM='\033[2m'
export NO_DIM='\033[22m'
export ITALIC='\033[3m'
export NO_ITALIC='\033[23m'
export STRIKE='\033[9m'
export NO_STRIKE='\033[29m'
export REVERSE='\033[7m'
export NO_REVERSE='\033[27m'

export BG_BLACK='\033[40m'
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'
export BG_MAGENTA='\033[45m'
export BG_CYAN='\033[46m'
export BG_WHITE='\033[47m'

export BG_BRIGHT_BLACK='\033[100m'
export BG_BRIGHT_RED='\033[101m'
export BG_BRIGHT_GREEN='\033[102m'
export BG_BRIGHT_YELLOW='\033[103m'
export BG_BRIGHT_BLUE='\033[104m'
export BG_BRIGHT_MAGENTA='\033[105m'
export BG_BRIGHT_CYAN='\033[106m'
export BG_BRIGHT_WHITE='\033[107m'

function text_confirm() {
    local -r question="${1:?text_confirm() did not get the question passed to it}"
    local -r default="${2:-y}"
    local response

    if [[ $(lc "${default}") == "y" ]]; then
        read -rp "${question} (Y/n)" response >/dev/null
    else
        read -rp "${question} (y/N)" response >/dev/null
    fi

    if [[ $(lc "$default") == "y" ]];then
        # local outcome=
        local -i resp
        if [[ $(lc "$response") == "n" ]] || [[ $(lc "$response") == "no" ]]; then
            resp=1
        else
            resp=0
        fi        

        return $resp

    else
        local -i resp
        if [[ $(lc "$response" == "y") ]] || [[ $(lc "$response") == "yes" ]]; then
            resp=0
        else
            resp=1
        fi


        return $resp
    fi
}

# starts_with <look-for> <content>
function starts_with() {
    local -r look_for="${1:?No look-for string provided to starts_with}"
    local -r content="${2:-}"

    if is_empty "${content}"; then
        debug "starts_with" "starts_with(${look_for}, "") was passed empty content so will always return false"
        return 1;
    fi

    if [[ "${content}" == "${content#"$look_for"}" ]]; then
        debug "starts_with" "false (\"${DIM}${look_for}${RESET}\")"
        return 1; # was not present
    else
        debug "starts_with" "true (\"${DIM}${look_for}${RESET}\")"
        return 0; # found "look_for"
    fi
}

# distro_version() <[vmid]>
#
# will try to detect the linux distro's version id and name 
# of the host computer or the <vmid> if specified.
function distro_version() {
    local -r vm_id="$1:-"

    if [[ $(os "$vm_id") == "linux" ]]; then
        if file_exists "/etc/os-release"; then
            local -r id="$(find_in_file "VERSION_ID=" "/etc/os-release")"
            local -r codename="$(find_in_file "VERSION_CODENAME=" "/etc/os-release")"
            echo "${id}/${codename}"
            return 0
        fi
    else
        error "Called distro() on a non-linux OS [$(os "$vm_id")]!"
    fi
}


# strip_after <find> <content>
#
# Strips all characters after finding <find> in content inclusive
# of the <find> text.
#
# Ex: strip_after ":" "hello:world:of:tomorrow" → "hello"
function strip_after() {
    local -r find="${1:?strip_after() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    if is_empty "content"; then
        echo ""
    else 
        echo "${content%%"${find}"*}"
    fi
}

# strip_after_last <find> <content>
#
# Strips all characters after finding the FINAL <find> substring 
# in the content. 
#
# Ex: strip_after_last ":" "hello:world:of:tomorrow" → "hello:world:of"
function strip_after_last() {
    local -r find="${1:?strip_after_last() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    if is_empty "content"; then
        echo ""
    else 
        echo "${content%"${find}"*}"
    fi
}

# strip_before <find> <content>
#
# Retains all the characters after the first instance of <find> is
# found.
#
# Ex: strip_after ":" "hello:world:of:tomorrow" → "world:of:tomorrow"
function strip_before() {
    local -r find="${1:?strip_before() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    echo "${content#*"${find}"}"
}

# strip_before_last <find> <content>
#
# Retains all the characters after the last instance of <find> is
# found.
#
# Ex: strip_after ":" "hello:world:of:tomorrow" → "tomorrow"
function strip_before_last() {
    local -r find="${1:?strip_before_last() requires that a find parameter be passed!}"
    local -r content="${2:-}"

    echo "${content##*"${find}"}"
    
}


# distro() <[vmid]>
#
# will try to detect the linux distro of the host computer
# or the <vmid> if specified.
function distro() {
    local -r vm_id="$1:-"

    if [[ $(os "$vm_id") == "linux" ]]; then
        if file_exists "/etc/os-release"; then
            local -r name="$(find_in_file "ID=" "/etc/os-release")" || "$(find_in_file "NAME=" "/etc/os-release")"
            echo "${name}"
            return 0
        fi
    else
        error "Called distro() on a non-linux OS [$(os "$vm_id")]!"
    fi
}

# os() <[vmid]>
#
# will try to detect the operating system of the host computer
# or a container if a <vmid> is passed in as a parameter.
function os() {
    allow_errors
    local -r vm_id="$1" 2>/dev/null
    local -r os_type=$(lc "${OSTYPE}") || "$(lc "$(uname)")" || "unknown"
    catch_errors

    if is_empty "${vm_id}"; then
        case "$os_type" in
            'linux'*)
                if distro "$vm_id"; then 
                    echo "linux/$(distro "${vm_id}")/$(distro_version "$vm_id")"
                else
                    echo "linux"
                fi
                ;;
            'freebsd'*)
                echo "freebsd"
                ;;
            'windowsnt'*)
                echo "windows"
                ;;
            'darwin'*) 
                echo "macos/$(strip_before "darwin" "${OSTYPE}")"
                ;;
            'sunos'*)
                echo "solaris"
                ;;
            'aix'*) 
                echo "aix"
                ;;
            *) echo "unknown/${os_type}"
            esac
    fi
}

function os_path_delimiter() {
    if starts_with "windows" "$(os)"; then
        echo "\\"
    else
        echo "/"
    fi
}


# error_path()
#
# makes a prettier display of the error path
function error_path() {
    local -r path="$1"
    allow_errors

    if is_empty "$path"; then
        printf "%s" "${ITALIC}${DIM}unknown${RESET}"
    else
        local -r delimiter=$(os_path_delimiter)
        local -r start=$(strip_after_last "$delimiter" "$path")
        local -r end=$(strip_before_last "$delimiter" "$path")

        printf "%s" "${start}/${RED}${end}${RESET}"
    fi

}

function panic() {
    local -r msg="${1:?no message passed to error()!}"
    local -ri code=$(( "${2:-1}" ))
    local -r fn="${3:-${FUNCNAME[1]}}" || echo "unknown"

    log "\n  [${RED}x${RESET}] ${BOLD}ERROR ${DIM}${RED}$code${RESET}${BOLD} →${RESET} ${msg}" 
    log ""
    for i in "${!BASH_SOURCE[@]}"; do
        if ! contains "errors.sh" "${BASH_SOURCE[$i]}"; then
            log "    - ${FUNCNAME[$i]}() ${ITALIC}${DIM}at line${RESET} ${BASH_LINENO[$i-1]} ${ITALIC}${DIM}in${RESET} $(error_path "${BASH_SOURCE[$i]}")"
        fi
    done
    log ""
    exit $code
}

# contains <find> <content>
# 
# given the "content" string, all other parameters passed in
# will be looked for in this content.
function contains() {
    local -r find="${1}"
    local -r content="${2}"

    if is_empty "$find"; then
        error "contains("", ${content}) function did not recieve a FIND string! This is an invalid call!" 1
    fi

    if is_empty "$content"; then
        debug "contains" "contains(${find},"") received empty content so always returns false"
        return 1;
    fi

    if [[ "${content}" =~ ${find} ]]; then
        debug "contains" "found: ${find}"
        return 0 # successful match
    fi

    debug "contains" "not found: ${find}"
    return 1
}

# error <msg>
#
# sends a formatted error message to STDERR
function error() {
    local -r msg="${1:?no message passed to error()!}"
    local -ri code=$(( "${2:-1}" ))
    local -r fn="${3:-${FUNCNAME[1]}}"

    log "\n  [${RED}x${RESET}] ${BOLD}ERROR ${DIM}${RED}$code${RESET}${BOLD} →${RESET} ${msg}" && return $code
}



# error_handler()
#
# Handles error when they are caught
function error_handler() {
    local -r _line_number="$1"

    log ""

    for i in "${!BASH_SOURCE[@]}"; do
        if ! contains "errors.sh" "${BASH_SOURCE[$i]:-unknown}"; then
            log "    - ${FUNCNAME[$i]:-unknown}() ${ITALIC}${DIM}at line${RESET} ${BASH_LINENO[$i-1]:-unknown} ${ITALIC}${DIM}in${RESET} $(error_path "${BASH_SOURCE[$i]:-unknown}")"
        fi
    done
    log ""
}

# catch_errors()
#
# Catches all errors found in a script -- including pipeline errors -- and
# sends them to an error handler to report the error.
function catch_errors() {
    set -Eeuo pipefail
    trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
}

# allow_errors()
#
# Allows for non-zero return-codes to avoid being sent to the error_handler
# and is typically used to temporarily check on an external state from the shell
# where an error might be encountered but which will be handled locally
function allow_errors() {
    set +Eeuo pipefail
    trap - ERR
}


# log
#
# Logs the parameters passed to STDERR
function log() {
    printf "%b\\n" "${*}" >&2
}

# debug <fn> <msg> <...>
# 
# Logs to STDERR when the DEBUG env variable is set
# and not equal to "false".
function debug() {
    local -r DEBUG=$(lc "${DEBUG:-}")
    if [[ "${DEBUG}" != "false" ]]; then
        if (( $# > 1 )); then
            local fn="$1"

            shift
            local regex=""
            local lower_fn="" 
            lower_fn=$(lc "$fn")
            regex="(.*[^a-z]+|^)$lower_fn($|[^a-z]+.*)"

            if [[ "${DEBUG}" == "true" || "${DEBUG}" =~ $regex ]]; then
                log "       ${GREEN}◦${RESET} ${BOLD}${fn}()${RESET} → ${*}"
            fi
        else
            log "       ${GREEN}DEBUG: ${RESET} → ${*}"
        fi
    fi
}


# is_empty() <test>
# 
# tests whether the <test> value passed in is an empty string (or is unset)
# and returns 0 when it is empty and 1 when it is NOT.
function is_empty() {
    if [ -z "$1" ] || [[ "$1" == "" ]]; then
        debug "is_empty(${1})" "was empty, returning 0/true"
        return 0
    else
        debug "is_empty(${1}))" "was NOT empty, returning 1/false"
        return 1
    fi
}


# lc() <str>
#
# converts the passed in <str> to lowercase
function lc() {
    local -r str="${1-}"
    echo "${str}" | tr '[:upper:]' '[:lower:]'
}

function set_env() {
    local -r var="${1}"
    local -r val="${2}"

    if is_empty "$var"; then
        panic "set_env(var,val) called without VAR!"
    fi

    local -r setter=$(printf "\n%s\n" "${var}=${val}")

    eval "$setter"

    # source <<<"${setter}"
    debug "set_env" "set ENV variable '${var}' to '${val}'"
}

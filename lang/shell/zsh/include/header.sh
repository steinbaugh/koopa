#!/usr/bin/env zsh

__koopa_is_installed() { # {{{1
    # """
    # are all of the requested programs installed?
    # @note updated 2021-05-07.
    # """
    local cmd
    [[ "$#" -gt 0 ]] || return 1
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_is_macos() { # {{{1
    # """
    # is the operating system macos?
    # @note updated 2021-06-04.
    # """
    [[ "$#" -eq 0 ]] || return 1
    [[ "$(uname -s)" == 'Darwin' ]]
}

__koopa_print() { # {{{1
    # """
    # print a string.
    # @note updated 2021-05-07.
    # """
    local string
    [[ "$#" -gt 0 ]] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() { # {{{1
    # """
    # Resolve file path.
    # @note Updated 2021-06-04.
    # """
    local readlink x
    [[ "$#" -gt 0 ]] || return 1
    readlink='readlink'
    __koopa_is_macos && readlink='greadlink'
    if ! __koopa_is_installed "$readlink"
    then
        __koopa_warning "Not installed: '${readlink}'."
        __koopa_is_macos && \
            __koopa_warning 'Install Homebrew and GNU coreutils to resolve.'
        return 1
    fi
    x="$("$readlink" -f "$@")"
    [[ -e "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_warning() { # {{{1
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    local string
    [[ "$#" -gt 0 ]] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}



__koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2021-06-04.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [activate]=0
        [checks]=1
        [minimal]=0
        [test]=0
        [verbose]=0
    )
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && dict[activate]="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && dict[checks]="$KOOPA_CHECKS"
    [[ -n "${KOOPA_MINIMAL:-}" ]] && dict[minimal]="$KOOPA_MINIMAL"
    [[ -n "${KOOPA_TEST:-}" ]] && dict[test]="$KOOPA_TEST"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && dict[verbose]="$KOOPA_VERBOSE"
    if [[ "${dict[activate]}" -eq 1 ]] && [[ "${dict[test]}" -eq 0 ]]
    then
        dict[checks]=0
    fi
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        setopt xtrace  # -x
    fi
    if [[ "${dict[checks]}" -eq 1 ]]
    then
        setopt errexit  # -e
        setopt nounset  # -u
        setopt pipefail
        dict[major_version]="$( \
            printf '%s\n' "${ZSH_VERSION:?}" \
            | cut -d '.' -f 1 \
        )"
        if [[ ! "${dict[major_version]}" -ge 5 ]]
        then
            __koopa_warning \
                'Koopa requires Zsh >= 5.' \
                "Current Zsh version: '${ZSH_VERSION:?}'."
            return 1
        fi
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        dict[header_path]="${(%):-%N}"
        if [[ -L "${dict[header_path]}" ]]
        then
            dict[header_path]="$(__koopa_realpath "${dict[header_path]}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${dict[header_path]}")/../../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX:?}/lang/shell/posix/include/header.sh"
    if [[ "${KOOPA_TEST:-0}" -eq 1 ]]
    then
        _koopa_duration_start || return 1
    fi
    if [[ "${dict[activate]}" -eq 1 ]] && [[ "${dict[minimal]}" -eq 0 ]]
    then
        source "${KOOPA_PREFIX:?}/lang/shell/zsh/functions/activate.sh"
        _koopa_activate_zsh_extras
    fi
    if [[ "${dict[test]}" -eq 1 ]]
    then
        _koopa_duration_stop 'zsh' || return 1
    fi
    return 0
}

__koopa_zsh_header

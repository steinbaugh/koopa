#!/usr/bin/env bash

koopa::alpine_install_base() { # {{{1
    # """
    # Install Alpine Linux base system.
    # @note Updated 2021-03-24.
    #
    # Potentially useful flags:
    # > apk add --no-cache --virtual .build-dependencies
    # """
    local dict name_fancy pkgs
    koopa::assert_is_installed apk sudo

    declare -A dict=(
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [upgrade]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            --base-image)
                dict[base]=1
                dict[dev]=0
                dict[extra]=0
                dict[recommended]=0
                dict[upgrade]=0
                shift 1
                ;;
            --full)
                dict[base]=1
                dict[dev]=1
                dict[extra]=1
                dict[recommended]=1
                dict[upgrade]=1
                shift 1
                ;;
            "")
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    name_fancy='Alpine base system'
    koopa::install_start "$name_fancy"
    sudo apk --no-cache update
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        koopa::alert 'Upgrading system.'
        sudo apk --no-cache upgrade
    fi
    # These packages are required to install koopa.
    pkgs=(
        'bash'
        'bc'
        'ca-certificates'
        'coreutils'
        'curl'
        'findutils'
        'git'
        'shadow'
        'sudo'
    )
    # These packages should be included in the Docker base image.
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            'autoconf'
            'bash-completion'
            'binutils'
            'build-base'
            'dpkg'
            'gettext'  # msgfmt
            'man-db'
            'ncurses-dev'  # zsh
            'zsh'
        )
    fi
    # These packages will be installed in the Docker recommended image.
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            # > R-dev
            # > R-doc
            # > fish
            # > pandoc
            # > pandoc-citeproc
            # > texlive
            'R'
            'gettext'
            'mdocml'
            'openssl'
            'tcl'
            'tree'
            'wget'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            'libevent-dev'
            'libffi-dev'
            'libxml2-dev'
            'ncurses-dev'
        )
    fi
    sudo apk --no-cache add "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}


#!/usr/bin/env bash

# NOTE Failing to build on macOS.

koopa::install_emacs() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2021-05-05.
    #
    # Consider defining '--enable-locallisppath' and '--infodir' args.
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local conf_args
    if koopa::is_macos
    then
        conf_args=(
            '--disable-silent-rules'
            '--with-gnutls'
            '--with-modules'
            '--with-xml2'
            '--without-dbus'
            '--without-imagemagick'
            '--without-ns'
            '--without-selinux'
            '--without-x'
        )
    else
        conf_args=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    fi
    koopa::install_gnu_app \
        --name='emacs' \
        --name-fancy='Emacs' \
        "${conf_args[@]}"
        "$@"
}

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::alert_note 'Emacs is not installed.'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa:::update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa:::update_doom_emacs
    else
        koopa::alert_note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}

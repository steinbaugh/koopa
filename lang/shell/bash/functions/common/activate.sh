#!/usr/bin/env bash

koopa::activate_homebrew_pkg_config() { # {{{1
    # """
    # Activate Homebrew pkg-config for install script.
    # @note Updated 2021-05-05.
    # """
    local name opt_prefix pkgconfig
    koopa::assert_has_args "$#"
    koopa::assert_is_installed brew
    opt_prefix="$(koopa::homebrew_prefix)/opt"
    koopa::assert_is_dir "$opt_prefix"
    for name in "$@"
    do
        pkgconfig="${opt_prefix}/${name}/lib/pkgconfig"
        koopa::assert_is_dir "$pkgconfig"
        koopa::alert "Activating pkgconfig at '${pkgconfig}'."
        koopa::add_to_pkg_config_path_start "$pkgconfig"
    done
    return 0
}

koopa::activate_homebrew_opt_prefix() { # {{{1
    # """
    # Activate Homebrew opt prefix.
    # @note Updated 2021-05-06.
    # """
    local name opt_prefix prefix
    koopa::assert_has_args "$#"
    opt_prefix="$(koopa::homebrew_prefix)/opt"
    for name in "$@"
    do
        prefix="${opt_prefix}/${name}"
        koopa::assert_is_dir "$prefix"
        koopa::alert "Activating prefix at '${prefix}'."
        koopa::activate_prefix "$prefix"
    done
    return 0
}

koopa::activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2021-05-06.
    #
    # @examples
    # koopa::activate_opt_prefix proj gdal
    # """
    local name opt_prefix prefix
    koopa::assert_has_args "$#"
    opt_prefix="$(koopa::opt_prefix)"
    for name in "$@"
    do
        prefix="${opt_prefix}/${name}"
        koopa::assert_is_dir "$prefix"
        koopa::alert "Activating prefix at '${prefix}'."
        koopa::activate_prefix "$prefix"
    done
    return 0
}
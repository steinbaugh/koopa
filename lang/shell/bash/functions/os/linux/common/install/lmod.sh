#!/usr/bin/env bash

# FIXME Allow the user to pass in the install prefix here...
koopa::linux_configure_lmod() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2021-04-29.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    local etc_dir init_dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_has_sudo

    prefix="${1:-}"
    [[ -z "$prefix" ]] && prefix="$(koopa::lmod_prefix)"


    # FIXME Rework the init config here??
    init_dir="$(koopa::lmod_prefix)/apps/lmod/lmod/init"
    if [[ ! -d "$init_dir" ]]
    then
        koopa::alert_note "Lmod is not installed at '${init_dir}'."
        return 0
    fi
    etc_dir='/etc/profile.d'
    koopa::alert "Updating Lmod configuration in ${etc_dir}."
    koopa::mkdir -S "$etc_dir"
    # bash, zsh
    koopa::ln -S "${init_dir}/profile" "${etc_dir}/z00_lmod.sh"
    # csh, tcsh
    koopa::ln -S "${init_dir}/cshrc" "${etc_dir}/z00_lmod.csh"
    # fish
    if koopa::is_installed fish
    then
        etc_dir='/etc/fish/conf.d'
        koopa::alert "Updating Fish Lmod configuration in ${etc_dir}."
        koopa::mkdir -S "$etc_dir"
        koopa::ln -S "${init_dir}/profile.fish" "${etc_dir}/z00_lmod.fish"
    fi
    return 0
}

koopa::install_lmod() { # {{{1
    koopa::install_app \
        --name='lmod' \
        --name-fancy='Lmod' \
        --no-link \
        --platform='linux' \
        "$@"
}

# FIXME This failed to detect Lua 5.3.
# To check if it is available for other Lua versions, use --check-oua-versions.

koopa:::linux_install_lmod() { # {{{1
    # """
    # Install Lmod.
    # @note Updated 2021-05-07.
    # """
    set -x
    local apps_dir data_dir file name name2 prefix url version
    koopa::activate_opt_prefix lua luarocks
    koopa::assert_is_installed lua luarocks
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='lmod'
    name2="$(koopa::capitalize "$name")"
    apps_dir="${prefix}/apps"
    data_dir="${prefix}/moduleData"
    # Ensure luarocks dependencies are installed.
    eval "$(luarocks path)"
    luarocks install luaposix luafilesystem
    file="${version}.tar.gz"
    url="https://github.com/TACC/${name2}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    ./configure \
        --prefix="$apps_dir" \
        --with-spiderCacheDir="${data_dir}/cacheDir" \
        --with-updateSystemFn="${data_dir}/system.txt"
    make
    make install
    koopa::linux_configure_lmod "$prefix"
    return 0
}

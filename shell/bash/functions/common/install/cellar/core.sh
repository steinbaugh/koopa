#!/usr/bin/env bash

koopa::find_cellar_version() { # {{{1
    # """
    # Find cellar installation directory.
    # @note Updated 2020-06-30.
    # """
    local name prefix x
    koopa::assert_has_args "$#"
    name="${1:?}"
    prefix="$(koopa::cellar_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
        | sort \
        | tail -n 1 \
    )"
    koopa::assert_is_dir "$x"
    x="$(basename "$x")"
    koopa::print "$x"
    return 0
}

koopa::install_cellar() { # {{{1
    # """
    # Install cellarized application.
    # @note Updated 2020-11-17.
    # """
    local gnu_mirror include_dirs jobs link_args link_cellar make_prefix name \
        name_fancy pass_args prefix reinstall script_name script_path tmp_dir \
        version
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    koopa::is_macos && koopa::assert_is_installed brew
    include_dirs=
    link_cellar=1
    # Disable linking into '/usr/local' for macOS at the moment.
    koopa::is_macos && link_cellar=0
    name_fancy=
    reinstall=0
    script_name=
    version=
    pass_args=()
    while (("$#"))
    do
        case "$1" in
            --cellar-only)
                link_cellar=0
                pass_args+=('--cellar-only')
                shift 1
                ;;
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --name-fancy=*)
                name_fancy="${1#*=}"
                shift 1
                ;;
            --reinstall|--force)
                reinstall=1
                pass_args+=('--reinstall')
                shift 1
                ;;
            --script-name=*)
                script_name="${1#*=}"
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            "")
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "$name_fancy" ]] && name_fancy="$name"
    [[ -z "$script_name" ]] && script_name="$name"
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::cellar_prefix)/${name}/${version}"
    make_prefix="$(koopa::make_prefix)"
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$prefix"
        koopa::remove_broken_symlinks "$make_prefix"
    fi
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name_fancy" "$version" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        # shellcheck disable=SC2034
        gnu_mirror="$(koopa::gnu_mirror)"
        # shellcheck disable=SC2034
        jobs="$(koopa::cpu_count)"
        koopa::cd "$tmp_dir"
        script_path="$(koopa::prefix)/include/cellar/${script_name}.sh"
        koopa::assert_is_file "$script_path"
        # shellcheck source=/dev/null
        . "$script_path" "${pass_args[@]:-}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    if [[ "$link_cellar" -eq 1 ]]
    then
        link_args=(
            "--name=${name}"
            "--version=${version}"
        )
        if [[ -n "$include_dirs" ]]
        then
            link_args+=("--include-dirs=${include_dirs}")
        fi
        koopa::link_cellar "${link_args[@]}"
    fi
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::list_cellar_versions() { # {{{1
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::cellar_prefix)"
    (
        koopa::cd "$prefix"
        ls -1 -- *
    )
    return 0
}
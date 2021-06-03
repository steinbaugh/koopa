#!/usr/bin/env bash

# Run 'koopa install tex-packages' if you hit this warning:
# neither inconsolata.sty nor zi4.sty found: PDF vignettes and package manuals
# will not be rendered optimally

koopa::install_r() { # {{{1
    koopa::install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

koopa:::install_r() { # {{{1
    # """
    # Install R.
    # @note Updated 2021-05-26.
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local brew_opt brew_prefix conf_args file jobs major_version
    local make name name2 prefix r url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    conf_args=(
        "--prefix=${prefix}"
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-x=no'
    )
    if koopa::is_linux
    then
        conf_args+=(
            '--disable-nls'
            '--enable-R-profiling'
            '--with-blas'
            '--with-cairo'
            '--with-jpeglib'
            '--with-lapack'
            '--with-readline'
            '--with-recommended-packages'
            '--with-tcltk'
        )
        # Need to modify BLAS configuration handling specificallly on Debian.
        if ! koopa::is_debian_like
        then
            conf_args+=('--enable-BLAS-shlib')
        fi
    elif koopa::is_macos
    then
        # fxcoudert's gfortran works more reliably than using Homebrew gcc
        # See also:
        # - https://mac.r-project.org
        # - https://github.com/fxcoudert/gfortran-for-macOS/releases
        # - https://developer.r-project.org/Blog/public/2020/11/02/
        #     will-r-work-on-apple-silicon/index.html
        # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
        brew_prefix="$(koopa::homebrew_prefix)"
        brew_opt="${brew_prefix}/opt"
        koopa::activate_homebrew_opt_prefix \
            'gettext' \
            'jpeg' \
            'libpng' \
            'openblas' \
            'pcre2' \
            'pkg-config' \
            'readline' \
            'tcl-tk' \
            'texinfo' \
            'xz'
        koopa::activate_prefix '/usr/local/gfortran'
        koopa::add_to_path_start '/Library/TeX/texbin'
        conf_args+=(
            "--with-blas=-L${brew_opt}/openblas/lib -lopenblas"
            "--with-tcl-config=${brew_opt}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${brew_opt}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    name='r'
    name2="$(koopa::capitalize "$name")"
    major_version="$(koopa::major_version "$version")"
    file="${name2}-${version}.tar.gz"
    url="https://cloud.r-project.org/src/base/${name2}-${major_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    koopa::activate_openjdk
    unset -v R_HOME
    export TZ='America/New_York'
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" check
    "$make" pdf
    "$make" info
    "$make" install
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-05-25.
    # """
    local name_fancy pkg_prefix
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::install_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    koopa::rscript 'installRPackages' "$@"
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-06-03.
    # """
    local name_fancy
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::update_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::rscript 'updateRPackages' "$@" || true
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::update_success "$name_fancy"
    return 0
}

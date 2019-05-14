#!/usr/bin/env bash
set -Eeuxo pipefail

# Vim
# https://github.com/vim/vim

build_dir="/tmp/build/vim"
prefix="/usr/local"
version="8.1.1310"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

echo "Installing vim ${version}."
echo "sudo is required for this script."
sudo -v

# Build dependencies.
sudo yum -y install yum-utils
sudo yum-builddep -y vim

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://github.com/vim/vim/archive/v${version}.tar.gz"
    tar -xzvf "v${version}.tar.gz"
    cd "vim-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    # Skip the unit tests on RedHat. It will install successfully.
    # make test
    sudo make install
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

command -v vim
vim --version

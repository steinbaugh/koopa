#!/bin/sh

# Improve terminal colors.
export CLICOLOR=1
export GREP_OPTIONS="--color=auto"
# `man ls`: see LSCOLORS section for color designators.
# export LSCOLORS="Gxfxcxdxbxegedabagacad"

# Set rsync flags for APFS.
export RSYNC_FLAGS="${RSYNC_FLAGS} --iconv=utf-8,utf-8-mac"

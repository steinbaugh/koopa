#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$MACOS" -eq 1 ]]
then
    echo "en0: $(ipconfig getifaddr en0)"
    echo "en1: $(ipconfig getifaddr en1)"
    echo "en2: $(ipconfig getifaddr en2)"
else
    hostname -I | awk '{print $1}'
fi

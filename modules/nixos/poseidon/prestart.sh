#!/usr/bin/env bash
# Render ~/.zeroclaw/config.toml from a nix-store template, substituting the
# Matrix access token at runtime so it never lives in the world-readable nix
# store.
#
# Args:
#   $1  path to the config.toml template
#   $2  "matrix" if MATRIX_ACCESS_TOKEN should be substituted, anything else
#       to copy the template through unchanged
set -eu

template="$1"
mode="${2:-no-matrix}"

mkdir -p "$HOME/.zeroclaw" "$HOME/.zeroclaw/state"

if [ "$mode" = "matrix" ]; then
    : "${MATRIX_ACCESS_TOKEN:=}"
    sed "s|@MATRIX_ACCESS_TOKEN@|${MATRIX_ACCESS_TOKEN}|g" \
        "$template" > "$HOME/.zeroclaw/config.toml"
else
    cp -f "$template" "$HOME/.zeroclaw/config.toml"
fi

chmod 600 "$HOME/.zeroclaw/config.toml"

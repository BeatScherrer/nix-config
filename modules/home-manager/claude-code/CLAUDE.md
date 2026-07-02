# User Instructions

## Build System

Prefer using `just` command runner when a `justfile` is present in the project. Run `just --list` to see available recipes before using make or manual commands.

## Screenshots

When I refer to "the screenshot" (or just "screenshot") without giving a path, it means the file at `/tmp/screenshot.png`. Read it with the Read tool. Check its modification time first — if it's older than a few minutes it's probably stale (a leftover from a previous capture), so say so and ask me to re-capture rather than analysing the old image.

## Git

Do not prefix commit messages with the ticket number (e.g. `WG-1211#`). A commit hook automatically prepends it based on the branch name.

## Nix Flake Templates

When initializing a new Nix flake, prefer my personal templates from `github:BeatScherrer/nix-flake-templates`. Available templates include `hetzner`, `hetzner-personal`, and `trivial`. Initialize with:

```
nix flake init -t github:BeatScherrer/nix-flake-templates#<template>
```

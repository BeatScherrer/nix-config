#!/usr/bin/env bash

SELECTION=$(find ~/.config/herbstluftwm/layouts -type f -follow -exec basename {} \; | rofi -dmenu -p "Choose a Layout" -i)
herbstclient load "$(cat "${HOME}/.config/herbstluftwm/layouts/${SELECTION}")"

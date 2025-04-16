#!/usr/bin/env sh

killall polybar

# if command -v xrandr; then
#   for m in $(xrandr --query | grep " connected" | cut -d " " -f 1); do
#     MONITOR=$m polybar --reload main &
#   done
# else
#   polybar --reload main &
# fi

polybar --reload main &

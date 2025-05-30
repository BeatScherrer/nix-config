#!/usr/bin/env bash

# a i3-like scratchpad for arbitrary applications.
#
# this lets a new monitor called "scratchpad" appear in from the top into the
# current monitor. There the "scratchpad" will be shown (it will be created if
# it doesn't exist yet). If the monitor already exists it is scrolled out of
# the screen and removed again.
#
# Warning: this uses much resources because herbstclient is forked for each
# animation step.
#
# If a tag name is supplied, this is used instead of the scratchpad

tag="${1:-scratchpad}"
hc() { "${herbstclient_command[@]:-herbstclient}" "$@"; }

mrect=($(hc monitor_rect ""))

width=${mrect[2]}
height=${mrect[3]}

scratchpad_width=$(bc -l <<<"${width} * 0.8")
maximal_scratchpad_width=3000

if [[ $(bc <<<"$scratchpad_width > $maximal_scratchpad_width") == 1 ]]; then
  scratchpad_width="$maximal_scratchpad_width"
fi

scratchpad_height=$(bc -l <<<"$height * 0.8")

scratchpad_x_offset="$(bc <<<"${mrect[0]} + ($width / 2 - $scratchpad_width * 0.5)")"
scratchpad_y_offset="$(bc <<<"${mrect[1]} + ($height / 2 - $scratchpad_height * 0.5)")"

rect=(
  $scratchpad_width
  $scratchpad_height
  $scratchpad_x_offset
  $scratchpad_y_offset
)

hc chain , add "$tag" , set_attr tags.by-name."$tag".at_end true

monitor=scratchpad

exists=false
if ! hc add_monitor $(printf "%dx%d%+d%+d" "${rect[@]}") \
  "$tag" $monitor 2>/dev/null; then
  exists=true
else
  # remember which monitor was focused previously
  hc chain \
    , new_attr string monitors.by-name."$monitor".my_prev_focus \
    , substitute M monitors.focus.index \
    set_attr monitors.by-name."$monitor".my_prev_focus M
fi

show() {
  hc lock
  hc raise_monitor "$monitor"
  hc focus_monitor "$monitor"
  hc unlock
  hc lock_tag "$monitor"
}

hide() {
  # if q3terminal still is focused, then focus the previously focused monitor
  # (that mon which was focused when starting q3terminal)
  hc substitute M monitors.by-name."$monitor".my_prev_focus \
    and + compare monitors.focus.name = "$monitor" \
    + focus_monitor M
  hc remove_monitor "$monitor"
}

[ $exists = true ] && hide || show

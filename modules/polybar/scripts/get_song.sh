#!/usr/bin/env bash

getTitle() {
  local artist
  local title
  local output

  # if spotify is started
  if [ "$(pidof spotify)" ]; then
    # status can be: Playing, Paused or Stopped
    artist="$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null | grep -A 2 -E "artist" | grep -vE "artist" | grep -vE "array" | cut -b 27- | cut -d '"' -f 1 | grep -vE ^$)"
    title="$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null | grep -A 1 -E "title" | grep -vE "title" | cut -b 44- | cut -d '"' -f 1 | grep -vE ^$)"
    output="$title | $artist"
  else
    title="$(playerctl metadata title)"
    artist="$(playerctl metadata artist)"
    output="$title | $artist"
  fi

  local visible_part="${output:0:20}"
  local invisible_part="${output:20}"

  if [[ -n "$invisible_part" ]]; then
    visible_part="${visible_part}..."
  fi

  echo "$visible_part"
}

getTitle "$@"

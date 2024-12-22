#!/usr/bin/env bash

getCoolantTemp() {
  local temp="$(($(cat /sys/class/hwmon/hwmon8/temp1_input) / 1000))"
  echo "$temp"
}

getCoolantTemp

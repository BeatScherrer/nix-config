#!/usr/bin/env bash

getCoolantTemp() {
  local temperature=$(sensors | grep "Coolant temp" | awk '{print $3}' | tr -d '+°C')
  echo "$temperature"
}

getCoolantTemp

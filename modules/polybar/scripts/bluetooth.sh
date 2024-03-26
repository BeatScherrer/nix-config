#!/usr/bin/env bash

getBluetoothInfo(){
  local info="$(bluetoothctl info 2> /dev/null | grep -i name | sed 's/^[ \t]*//')"

  if [[ -n "$info" ]]; then
    extracted_name=${info#Name: }
    echo " ${extracted_name}"
  else
    echo ""
  fi
}

getBluetoothInfo "$@"


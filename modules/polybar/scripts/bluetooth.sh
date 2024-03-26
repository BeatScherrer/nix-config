#!/usr/bin/env bash

getBluetoothInfo(){
  local info="$(bluetoothctl info > /dev/null)"

  if [[ -n "$info" ]]; then
    echo A
  else
    echo ""
  fi
}

getBluetoothInfo "$@"


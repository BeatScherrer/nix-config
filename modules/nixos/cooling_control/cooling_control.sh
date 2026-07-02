#!/usr/bin/env bash
# Coolant-temperature-driven fan controller for the Aquacomputer Octo.
#
# Reads the coolant temperature from lm_sensors and maps it to a fan speed
# using a simple step curve. Runs as a long-lived daemon (see
# cooling_control.nix) and logs every reading to the journal.
set -uo pipefail

DEVICE="Aquacomputer Octo"
FANS=(fan1 fan2 fan3 fan4 fan6)
POLL_INTERVAL=5      # seconds between readings
REASSERT_AFTER=12    # re-push the current speed at least every N polls (~60s)

log() { echo "cooling_control: $*"; }

# Print the coolant temperature in °C (e.g. "34.2"), or nothing if unreadable.
read_temp() {
  sensors 2>/dev/null \
    | awk '/Coolant temp/ { gsub(/[+°C]/, "", $3); print $3; exit }'
}

# Map a temperature to a fan speed percentage.
target_speed() {
  local t=$1
  if   (( $(echo "$t > 40" | bc -l) )); then echo 100
  elif (( $(echo "$t > 38" | bc -l) )); then echo 80
  elif (( $(echo "$t > 35" | bc -l) )); then echo 60
  elif (( $(echo "$t > 33" | bc -l) )); then echo 50
  elif (( $(echo "$t > 30" | bc -l) )); then echo 40
  elif (( $(echo "$t > 25" | bc -l) )); then echo 20
  else                                        echo 10
  fi
}

# Push a speed to every controlled fan. Returns non-zero if any fan failed.
apply_speed() {
  local speed=$1 fan rc=0
  for fan in "${FANS[@]}"; do
    if ! liquidctl --match "$DEVICE" set "$fan" speed "$speed"; then
      log "ERROR: failed to set $fan to ${speed}%"
      rc=1
    fi
  done
  return $rc
}

last_speed=""
polls_since_apply=$REASSERT_AFTER

while :; do
  temp=$(read_temp)

  if [[ "$temp" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    speed=$(target_speed "$temp")
    log "coolant temp ${temp}°C -> fan target ${speed}%"
  else
    # Fail safe: if we cannot read the temperature, run fans at full speed.
    speed=100
    log "WARNING: could not read coolant temperature (got '${temp:-<empty>}'); forcing fans to ${speed}%"
  fi

  if [ "$speed" != "$last_speed" ] || [ "$polls_since_apply" -ge "$REASSERT_AFTER" ]; then
    if apply_speed "$speed"; then
      [ "$speed" != "$last_speed" ] && log "fan speed changed to ${speed}%"
      last_speed=$speed
      polls_since_apply=0
    fi
  fi

  polls_since_apply=$((polls_since_apply + 1))
  sleep "$POLL_INTERVAL"
done

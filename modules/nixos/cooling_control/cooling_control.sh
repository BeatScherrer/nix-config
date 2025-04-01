#!/bin/sh

TEMP=$(sensors | grep "Coolant temp" | awk '{print $3}' | tr -d '+°C')

fan_speed=100

if [ "$(echo "$TEMP > 40" | bc -l)" -eq 1 ]; then
  fan_speed="100"
elif [ "$(echo "$TEMP > 35" | bc -l)" -eq 1 ]; then
  fan_speed="75"
elif [ "$(echo "$TEMP > 30" | bc -l)" -eq 1 ]; then
  fan_speed="30"
elif [ "$(echo "$TEMP > 25" | bc -l)" -eq 1 ]; then
  fan_speed="20"
elif [ "$(echo "$TEMP > 20" | bc -l)" -eq 1 ]; then
  fan_speed="10"
fi

echo "setting fan speed to ${fan_speed}"

liquidctl --match "Aquacomputer Octo" set fan1 speed "$fan_speed"
liquidctl --match "Aquacomputer Octo" set fan2 speed "$fan_speed"
liquidctl --match "Aquacomputer Octo" set fan3 speed "$fan_speed"
liquidctl --match "Aquacomputer Octo" set fan4 speed "$fan_speed"
liquidctl --match "Aquacomputer Octo" set fan6 speed "$fan_speed"

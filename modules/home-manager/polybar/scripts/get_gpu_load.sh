#!/usr/bin/env bash
# Get GPU load percentage from nvidia-smi, radeontop, sysfs, or sensors

# Try nvidia-smi first (NVIDIA)
getNVLoad() {
  local util
  util=$(timeout 2 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
  [[ -n "$util" && "$util" =~ ^[0-9]+$ ]] && { echo "$util"; return 0; }
  return 1
}

# Try radeontop (AMD)
getRadeonLoad() {
  local util
  util=$(timeout 2 radeontop 2>/dev/null | grep "^$(hostname -s)" | head -1 | awk '{print $2}')
  [[ -n "$util" && "$util" =~ ^[0-9]+$ ]] && { echo "$util"; return 0; }
  return 1
}

# Try sysfs gpu_busy_percent (AMD DRM driver)
getSysfsLoad() {
  local val
  for f in /sys/class/drm/card*/device/gpu_busy_percent; do
    val=$(cat "$f" 2>/dev/null)
    [[ -n "$val" && "$val" =~ ^[0-9]+$ ]] && { echo "$val"; return 0; }
  done
  return 1
}

# Try lm_sensors
getSensorLoad() {
  local load
  load=$(timeout 2s sensors 2>/dev/null | grep -i 'gpu load' | head -1 | awk '{print $2}' | tr -d '%')
  [[ -n "$load" && "$load" =~ ^[0-9]+$ ]] && { echo "$load"; return 0; }
  return 1
}

getGPUOutput() {
  getNVLoad || getRadeonLoad || getSysfsLoad || getSensorLoad || echo "N/A"
}

getGPUOutput

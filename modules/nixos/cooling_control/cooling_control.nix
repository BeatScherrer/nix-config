{ pkgs, ... }:
{
  systemd.timers.cooling_control_timer = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "5s";
      Unit = "cooling_control.service";
    };
  };

  # FIXME: thte cooling_control script lacks the environment, i.e. bc
  systemd.services.cooling_control = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    description = "Cooling control service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${./cooling_control.sh}";
    };
    path = with pkgs; [
      coreutils
      gawk
      bc
      liquidctl
      lm_sensors
    ];
  };

}

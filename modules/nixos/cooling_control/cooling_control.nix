{ pkgs, ... }:
{
  systemd.services.cooling_control = {
    enable = true;
    description = "Coolant-temperature-driven fan control";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${./cooling_control.sh}";
      Restart = "on-failure";
      RestartSec = "10s";
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

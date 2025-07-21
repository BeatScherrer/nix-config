{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.docker;
in
{

  options.docker = {
    enable = mkEnableOption "docker";
    nvidia = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableNvidia = true; # NOTE: this is required even though it's deprecated...
    };
    hardware.graphics.enable32Bit = true;
    hardware.nvidia-container-toolkit.enable = mkIf cfg.nvidia hardware.true;

    # FIXME: hard coded user...
    users.users.beat.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

  };

}

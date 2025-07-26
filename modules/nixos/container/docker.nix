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
    };

    # FIXME: hard coded user...
    users.users.beat.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };

}

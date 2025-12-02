{
  lib,
  config,
  pkgs,
  user,
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

    users.users.${user}.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };

}

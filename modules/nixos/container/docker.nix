{ lib, config, pkgs, ... }:
with lib;
let cfg = config.docker;
in {

  options.docker = { enable = mkEnableOption "docker"; };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    # FIXME: hard coded user...
    users.users.beat.extraGroups = [ "docker" ];
  };

}

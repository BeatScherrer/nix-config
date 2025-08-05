{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.podman;
in
{

  options.podman = {
    enable = mkEnableOption "podman";
    nvidia = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      podman-compose
    ];
  };

}

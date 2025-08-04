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

    # WARN: https://discourse.nixos.org/t/nvidia-ctk-shows-gpu-but-podman-doesnt-find-it-for-passthrough/65869
    # podman does not chedck /var/run/cdi but only in /etc/cdi
    environment.etc."cdi/nvidia-container-toolkit.json".source =
      mkIf cfg.nvidia "/run/cdi/nvidia-container-toolkit.json";
  };

}

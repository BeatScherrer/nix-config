# TODO: investigate why podman works on trident but not on legion...

{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.container;
  ContainerEngineMode = types.enum [ "podman" "docker" ];
in {
  imports = [ ./podman.nix ./docker.nix ];

  options.container = {
    enable = mkEnableOption "container";
    containerEngine = mkOption {
      type = ContainerEngineMode;
      default = "podman";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ distrobox ];

    # enable either one imported module or the other
    docker.enable = cfg.containerEngine == "docker";
    podman.enable = cfg.containerEngine == "podman";

    environment.sessionVariables = mkIf (cfg.containerEngine == "docker") {
      DBX_CONTAINER_MANAGER = "docker";
    };
  };
}

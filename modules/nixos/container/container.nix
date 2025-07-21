{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.container;
  ContainerEngineMode = types.enum [
    "podman"
    "docker"
    "both"
  ];
in
{
  imports = [
    ./podman.nix
    ./docker.nix
  ];

  options.container = {
    enable = mkEnableOption "container";
    containerEngine = mkOption {
      type = ContainerEngineMode;
      default = "podman";
    };
    nvidia = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ distrobox ];

    # enable either one imported module or the other
    docker.enable = cfg.containerEngine == "docker" || cfg.containerEngine == "both";
    podman.enable = cfg.containerEngine == "podman" || cfg.containerEngine == "both";

    docker.nvidia = cfg.nvidia;

    environment.sessionVariables =
      mkIf (cfg.containerEngine == "docker" || cfg.containerEngine != "both")
        {
          DBX_CONTAINER_MANAGER = "docker";
        };
  };
}

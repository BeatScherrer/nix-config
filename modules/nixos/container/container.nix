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
    hardware.nvidia-container-toolkit = {
      enable = mkIf cfg.nvidia true;
      extraArgs = [
        "--disable-hook"
        "create-symlinks"
      ];

      package = pkgs.nvidia-container-toolkit.overrideAttrs (old: {
        version = "git";
        src = pkgs.fetchFromGitHub {
          owner = "nvidia";
          repo = "nvidia-container-toolkit";
          rev = "08b3a388e7b1d447e10d4c4d4a71dca29a98a964"; # v1.18.0-rc.2
          hash = "sha256-y81UbNoMfIhl9Rf1H3RTRmGR3pysDtKlApLrIxwou9I=";
        };
        postPatch = ''
          substituteInPlace internal/config/config.go \
            --replace-fail '/usr/bin/nvidia-container-runtime-hook' "$tools/bin/nvidia-container-runtime-hook" \
            --replace-fail '/sbin/ldconfig' '${pkgs.glibc.bin}/sbin/ldconfig'

          # substituteInPlace tools/container/toolkit/toolkit.go \
          #   --replace-fail '/sbin/ldconfig' '${pkgs.glibc.bin}/sbin/ldconfig'

          substituteInPlace cmd/nvidia-cdi-hook/update-ldcache/update-ldcache.go \
            --replace-fail '/sbin/ldconfig' '${pkgs.glibc.bin}/sbin/ldconfig'
        '';
      });
    };

    environment.systemPackages =
      with pkgs;
      [ distrobox ]
      ++ optionals cfg.nvidia [
        config.hardware.nvidia-container-toolkit.package
      ];

    # enable either one imported module or the other
    docker.enable = cfg.containerEngine == "docker" || cfg.containerEngine == "both";
    podman.enable = cfg.containerEngine == "podman" || cfg.containerEngine == "both";
    docker.nvidia = cfg.nvidia;
    podman.nvidia = cfg.nvidia;

    environment.sessionVariables = mkIf (cfg.containerEngine == "docker") {
      DBX_CONTAINER_MANAGER = "docker";
    };
  };
}

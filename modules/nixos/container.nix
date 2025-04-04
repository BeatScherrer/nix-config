{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.container;
  ContainerEngineMode = types.enum [ "podman" "docker" ];
in {

  options.container = {
    enable = mkEnableOption "container";
    containerEngine = mkOption {
      type = ContainerEngineMode;
      default = "podman";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # containers
      containers.enable = true;
      podman = mkIf (cfg.containerEngine == "podman") {
        enable = true;
        dockerCompat = true; # create a `docker` alias
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs;
      [
        distrobox
        # TODO:
        # mkIf (cfg.containerEngine == "podman") [ hello ]
        # mkIf (cfg.containerEngine == "docker") [ docker ]
      ];

    # TODO:
    # environment.sessionVariables = mkIf (cfg.containerEngine == "docker") ({
    #   DBX_CONTAINER_MANAGER = "docker";
    # });

    # TODO:
    # users.users.beat.extraGroups = [
    #   "libvirtd"
    #   "kvm"
    #   (mkIf (cfg.containerEngine == "docker") [ "docker" ])
    # ];
  };
}

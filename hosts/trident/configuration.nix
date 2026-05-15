{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/yubikey.nix
    ../../modules/nixos/sudo.nix
    ../../modules/nixos/default.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/games.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/container/container.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/crypto.nix
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/i3lock.nix
    ../../modules/nixos/ollama.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/teamviewer/teamviewer.nix
    ../../modules/nixos/davinci-resolve.nix
    ../../modules/nixos/printing-3d.nix

    ../../modules/nixos/desktop.nix

    ../../modules/nixos/cooling_control/cooling_control.nix
    ../../modules/nixos/secure-boot.nix

    # work modules
    ../../modules/nixos/mtr/mtr.nix

    # binary cache server
    ../../modules/nixos/harmonia.nix

    # agentic development loop
    ../../modules/nixos/agentic-loop/agentic-loop.nix

    # Poseidon — personal-assistant zeroclaw daemon
    ../../modules/nixos/poseidon/poseidon.nix
  ];

  # custom module options
  # ---------------------------------------------------------------------------
  container = {
    enable = true;
    containerEngine = "docker";
  };
  blender = {
    enable = true;
    gpu = "amd";
  };
  printing-3d.enable = true;
  davinci-resolve = {
    enable = true;
    gpu = "amd";
  };
  harmonia = {
    enable = true;
    port = 8080;
  };
  sops.secrets."openrouter-api-key" = {
    sopsFile = ../../secrets/trident/openrouter-api-key.yaml;
    mode = "0400";
    owner = "agentic";
    group = "agentic";
  };
  sops.secrets."matrix-token" = {
    sopsFile = ../../secrets/trident/matrix-token.yaml;
    mode = "0400";
    owner = "agentic";
    group = "agentic";
  };
  sops.secrets."bitbucket-pat" = {
    sopsFile = ../../secrets/trident/bitbucket-pat.yaml;
    mode = "0400";
    owner = "agentic";
    group = "agentic";
  };
  sops.secrets."github-pat" = {
    sopsFile = ../../secrets/trident/github-pat.yaml;
    mode = "0400";
    owner = "agentic";
    group = "agentic";
  };
  sops.secrets."matrix-poseidon-token" = {
    sopsFile = ../../secrets/trident/matrix-poseidon-token.yaml;
    mode = "0400";
    owner = "poseidon";
    group = "poseidon";
  };
  # Same encrypted yaml as openrouter-api-key (used by agentic-loop), but
  # decrypted to a separate file owned by `poseidon` so the hardened poseidon
  # service can read it without sharing groups with `agentic`.
  sops.secrets."openrouter-api-key-poseidon" = {
    sopsFile = ../../secrets/trident/openrouter-api-key.yaml;
    key = "openrouter-api-key";
    mode = "0400";
    owner = "poseidon";
    group = "poseidon";
    restartUnits = [ "poseidon.service" ];
  };

  agenticLoop = {
    enable = true;
    matrix.homeserverUrl = "https://matrix.shetec.ch";
    matrix.roomId = "!BeDNBxaHRdhpRTVTpi:matrix.org";
    matrix.allowedUsers = [ "@BeatScherrer:matrix.org" ];
    apiKeys.openrouterKeyFile = config.sops.secrets."openrouter-api-key".path;
    apiKeys.matrixTokenFile = config.sops.secrets."matrix-token".path;
    apiKeys.extraEnvFiles = [
      config.sops.secrets."bitbucket-pat".path
      config.sops.secrets."github-pat".path
    ];
    agents = {
      orchestrator = {
        enable = true;
        provider = "openrouter";
        model = "anthropic/claude-sonnet-4";
      };

      planner = {
        enable = true;
        provider = "openrouter";
        model = "anthropic/claude-opus-4";
      };

      coder = {
        enable = true;
        provider = "openrouter";
        model = "anthropic/claude-sonnet-4";
      };
    };
  };

  poseidon = {
    enable = true;
    # Local inference via the trident ollama service (modules/nixos/ollama.nix),
    # which preloads this model. No API key / outbound network needed.
    provider = "ollama";
    model = "qwen3.6:35b-a3b";
    # Read-only host paths bind-mounted into Poseidon's namespace. ACLs are
    # applied so the `poseidon` user can read them. Add more dirs as you find
    # friction.
    bindReadOnlyPaths = [
      "/home/beat/Documents"
    ];
    # Read-write. The Poseidon subfolder lives inside the synology-drive sync
    # root, so anything Poseidon writes is pushed to the NAS by the
    # synology-drive user service. Make sure the synology-drive client is
    # configured to sync ~/SynologyDrive ↔ a dedicated NAS folder.
    bindReadWritePaths = [
      "/home/beat/SynologyDrive/Poseidon"
    ];

    # Matrix integration: leave roomId empty until you've created a separate
    # Matrix account + room. Then fill matrix-poseidon-token.yaml and set
    # roomId here.
    matrix.roomId = "!pLqQKnSGoscMDCgpZJ:matrix.org";
    matrix.allowedUsers = [ "@BeatScherrer:matrix.org" ];
    matrix.accessTokenFile = config.sops.secrets."matrix-poseidon-token".path;
  };

  # Ensure the synology-drive sync root and Poseidon's subfolder exist before
  # the poseidon service tries to bind-mount them. Owned by `beat` so
  # synology-drive (which runs as beat) can manage the contents.
  systemd.tmpfiles.rules = [
    "d /home/beat/SynologyDrive 0755 beat users -"
    "d /home/beat/SynologyDrive/Poseidon 0755 beat users -"
  ];
  # ---------------------------------------------------------------------------

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "trident";

  # Restrict Avahi to LAN interface (avoid advertising Docker bridge IPs)
  services.avahi.allowInterfaces = [ "eno1" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xset}/bin/xset s off         # Disable screen saver
    ${pkgs.xset}/bin/xset -dpms         # Disable DPMS
  '';


  environment.sessionVariables = {
    MAKE_CORES = "30";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

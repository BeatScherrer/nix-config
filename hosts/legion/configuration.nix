# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nixos/yubikey.nix
    ../../modules/nixos/default.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/container/container.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/ssh.nix
    # ../../modules/nixos/ollama.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/davinci-resolve.nix

    ../../modules/nixos/mtr/mtr.nix
  ];

  # Custom options
  #----------------------------------------------------------------------------
  # gpwm session shell: use DankMaterialShell instead of the noctalia default.
  gpwm.shell = "dms";

  # Match T14's layout: start every workspace with a single full-width leaf
  # instead of the upstream 25/50/25 three-column default. The leaf is
  # "vertical" so additional windows stack top-to-bottom, each spanning the
  # full width.
  programs.gpwm.settings = {
    default-layout = "fullwidth";
    layout.fullwidth.leaf = "horizontal";

    # Per-output workspace ownership, modes, and left-to-right placement:
    # EmbeddedDisplayPort-1 (left) | DisplayPort-3 (middle) | HDMIA-1 (right).
    # Once any [output] table exists gpwm requires workspaces 1..9 to be
    # claimed exactly once, so all three connected monitors are declared here.
    # DMS can't set gpwm's mode/position (it only drives niri/hyprland), so
    # configure it declaratively. (Requires a gpwm build with `[output.X]
    # mode` + `relative-to` support.)
    output."EmbeddedDisplayPort-1" = {
      workspaces = [
        7
        8
        9
      ];
      mode = "2560x1600@165";
    };
    output."DisplayPort-3" = {
      workspaces = [
        1
        2
        3
      ];
      mode = "4096x2160@60";
      relative-to.right-of = "EmbeddedDisplayPort-1";
      scale = 1.25;
    };
    output."HDMIA-1" = {
      workspaces = [
        4
        5
        6
      ];
      mode = "2560x1440@75";
      relative-to.right-of = "DisplayPort-3";
    };
  };

  container = {
    enable = true;
    containerEngine = "docker";
    nvidia = true;
  };

  blender = {
    enable = true;
    gpu = "nvidia";
  };

  davinci-resolve = {
    enable = true;
    gpu = "nvidia";
  };
  #----------------------------------------------------------------------------

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  boot.loader.systemd-boot.configurationLimit = 50;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "legion";

  environment.sessionVariables = {
    MAKE_CORES = "12";
    # NVIDIA Wayland support
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Legion-specific display setup (X11 only)
  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.autorandr}/bin/autorandr docked
  # '';

  services.openssh = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

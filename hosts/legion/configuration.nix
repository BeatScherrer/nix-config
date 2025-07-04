# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  ...
}:
let
  system = "x86_64-linux";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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
    ../../modules/nixos/gnome.nix
    # ../../modules/nixos/cosmic.nix
    # ../../modules/nixos/hyprland.nix
    ../../modules/nixos/herbstluftwm.nix

    ../../modules/nixos/mtr/mtr.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Custom options
  #----------------------------------------------------------------------------
  container = {
    enable = true;
    containerEngine = "docker";
  };
  #----------------------------------------------------------------------------

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;

  # # Fix suspend issue
  # systemd.services."systemd-suspend" = {
  #   serviceConfig = {
  #     Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSION=false'';
  #   };
  # };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # TODO: Move to networking module with options
  networking.hostName = "legion";
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  time.timeZone = "Europe/Zurich";

  services.tailscale.enable = true;

  programs.bash.blesh.enable = true;

  nixpkgs.config.allowUnfree = true;

  # TODO:
  environment.sessionVariables = {
    MAKE_CORES = "12";
  };

  # TODO: add this to default packages module
  environment.systemPackages = with pkgs; [
    fd
    vim
    neovim
    wget
    home-manager
    git
    coreutils
    xclip
    usbutils
    lshw
    fwupd
    lm_sensors
    cmake
    clang
    gcc
    gnumake
    envsubst
    rust-bin.stable.latest.default
    pnpm
    inputs.ghostty.packages.${system}.default
    inputs.claude-desktop.packages.${system}.default
    inputs.cursor.packages.${pkgs.system}.default
    lsof
    appimage-run
    mpv
    wireguard-tools

    # network shares
    samba
    cifs-utils

    gnome-keyring
    gnome-online-accounts
    dbus

    pkg-config
  ];

  # TODO: add to fonts module
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    font-awesome
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  system.nssDatabases.hosts = [ "nss-systemd" ];
}

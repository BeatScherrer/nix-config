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
    ../../modules/nixos/gnome.nix
    # ../../modules/nixos/cosmic.nix
    # ../../modules/nixos/hyprland.nix
    ../../modules/nixos/herbstluftwm.nix
    ../../modules/nixos/davinci-resolve.nix

    ../../modules/nixos/mtr/mtr.nix
  ];

  # Custom options
  #----------------------------------------------------------------------------
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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "legion";
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  time.timeZone = "Europe/Zurich";

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    MAKE_CORES = "12";
  };

  # Legion-specific display setup
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.autorandr}/bin/autorandr docked
  '';

  services.openssh = {
    enable = true;
  };

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

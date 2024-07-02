# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../system_modules/printing.nix
    ../../system_modules/herbstluftwm.nix
    ../../system_modules/steam.nix
    ../../system_modules/games.nix
    ../../system_modules/virtualization.nix
    ../../system_modules/sound.nix
    # ../../system_modules/hyprland.nix
    # ../../system_modules/gnome.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # TODO: Move to networking module with options
  networking.hostName = "trident"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  programs.coolercontrol.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.beat = {
    isNormalUser = true;
    description = "Beat Scherrer";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
  };

  programs.zsh.enable = true; # TODO:
  users.defaultUserShell = pkgs.zsh; # TODO:

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "beat" = import ../../home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    libsForQt5.qt5.qtgraphicaleffects # required for sddm
    docker
    liquidctl
    lm_sensors
    cmake
    clang
    gcc
    gnumake

    rustup

    # network shares
    samba
    cifs-utils

    gnome.gnome-keyring
    gnome-online-accounts
    dbus

    debootstrap # schroot
    pv # schroot

    pkg-config
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

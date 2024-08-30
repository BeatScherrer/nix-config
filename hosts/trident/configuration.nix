{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/printing.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/games.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/herbstluftwm.nix
    # ../../modules/nixos/hyprland.nix
    # ../../modules/nixos/gnome.nix
    # ../../modules/nixos/cosmic.nix
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
  networking.hostName = "trident";
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  programs.coolercontrol.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # NOTE: The default GID is 100, which proved to be troublesome when
  # using systemd-nspawn! (cannot bind the user without a private user group)
  users = {
    users.beat = {
      isNormalUser = true;
      description = "Beat Scherrer";
      group = "beat";
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
      ];
    };
    groups = {
      beat = {
        members = [ "beat" ];
        gid = 1000;
      };
    };
  };

  users.defaultUserShell = pkgs.bash;
  # programs.bash.blesh.enable = true;
  environment.variables = {
    TERM = "xterm-256color";
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "beat" = import ../../home-manager/home.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;

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
    docker
    liquidctl
    lm_sensors
    cmake
    clang
    gcc
    gnumake
    envsubst

    # network shares
    samba
    cifs-utils

    gnome-keyring
    gnome-online-accounts
    dbus

    inputs.debootstrapPin.legacyPackages."x86_64-linux".debootstrap # schroot
    pv # schroot
    boost # Required to build schroot
    boost.dev # Required to build schroot
    # schroot # FIXME: overlay?

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

  system.nssDatabases.hosts = [ "nss-systemd" ];

}

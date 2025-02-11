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
    ../../modules/nixos/user.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/games.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/crypto.nix
    ../../modules/nixos/herbstluftwm.nix
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/i3lock.nix
    ../../modules/nixos/ollama.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/teamviewer/teamviewer.nix
    # ../../modules/nixos/hyprland.nix
    # ../../modules/nixos/gnome.nix
    # ../../modules/nixos/cosmic.nix

    # work modules
    ../../modules/nixos/mtr/mtr.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  # list all current system packages in /etc/current-system-packages
  environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
    formatted;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # TODO: Move to networking module with options
  networking.hostName = "trident";
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  services.tailscale.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.coolercontrol.enable = true;
  programs.bash.blesh.enable = true;

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

  # TODO:
  environment.sessionVariables = {
    MAKE_CORES = "30";
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
    liquidctl
    lm_sensors
    cmake
    clang
    gcc
    gnumake
    envsubst
    rust-bin.stable.latest.default
    pnpm
    inputs.ghostty.packages.x86_64-linux.default
    lsof
    appimage-run

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
  system.stateVersion = "23.05"; # Did you read the comment?

  system.nssDatabases.hosts = [ "nss-systemd" ];

}

{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # ../../modules/nixos/hardware/nvidia.nix # NOTE: Enable if not using nixos-hardware
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
    # ../../modules/nixos/ollama.nix # TODO:
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/teamviewer/teamviewer.nix
    ../../modules/nixos/mtr/mtr.nix

    ../../modules/nixos/desktop.nix

    # work modules
    ../../modules/nixos/mtr/mtr.nix
  ];

  # custom module options
  # ---------------------------------------------------------------------------
  container = {
    enable = true;
    nvidia = true;
    containerEngine = "docker";
  };
  # ---------------------------------------------------------------------------

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Zurich";

  networking.hostName = "proart";

  # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xset}/bin/xset s off         # Disable screen saver
    ${pkgs.xorg.xset}/bin/xset -dpms         # Disable DPMS
  '';

  programs.bash.blesh.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
    iio-sensor-proxy
  ];

  # TODO:
  environment.sessionVariables = {
    MAKE_CORES = "30";
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
  system.stateVersion = "23.05"; # Did you read the comment?

  system.nssDatabases.hosts = [ "nss-systemd" ];

}

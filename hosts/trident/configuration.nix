{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
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
    # ../../modules/nixos/ollama.nix # TODO:
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/teamviewer/teamviewer.nix
    ../../modules/nixos/davinci-resolve.nix

    ../../modules/nixos/desktop.nix

    ../../modules/nixos/cooling_control/cooling_control.nix
    ../../modules/nixos/secure-boot.nix

    # work modules
    ../../modules/nixos/mtr/mtr.nix

    # binary cache server
    ../../modules/nixos/harmonia.nix
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
  davinci-resolve = {
    enable = true;
    gpu = "amd";
  };
  harmonia = {
    enable = true;
    # port = 5000;  # default
  };
  # ---------------------------------------------------------------------------

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "trident";

  # Restrict Avahi to LAN interface (avoid advertising Docker bridge IPs)
  services.avahi.allowInterfaces = [ "eno1" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xset}/bin/xset s off         # Disable screen saver
    ${pkgs.xorg.xset}/bin/xset -dpms         # Disable DPMS
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

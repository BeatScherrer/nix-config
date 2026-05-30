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
    # ../../modules/nixos/ollama.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/teamviewer/teamviewer.nix
    ../../modules/nixos/davinci-resolve.nix

    ../../modules/nixos/desktop.nix

    # work modules
    ../../modules/nixos/mtr/mtr.nix
  ];

  # custom module options
  # ---------------------------------------------------------------------------
  # gpwm session shell: use DankMaterialShell instead of the noctalia default.
  gpwm.shell = "dms";

  # T14's 14" screen is too narrow for the upstream 25/50/25 three-column
  # default — start every workspace with a single full-width leaf instead.
  # The leaf is "vertical" so additional windows stack top-to-bottom, each
  # still spanning the full width.
  programs.gpwm.settings = {
    default-layout = "fullwidth";
    layout.fullwidth.leaf = "vertical";
  };

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
  # ---------------------------------------------------------------------------

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "T14";

  services.xserver.videoDrivers = [ "amdgpu" ];

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

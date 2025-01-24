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
    ../../modules/nixos/printing.nix

    ../../modules/nixos/printing.nix
    ../../modules/nixos/herbstluftwm.nix
    ../../modules/nixos/steam.nix
    #../../modules/nixos/hyprland.nix
    #../../modules/nixos/gnome.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: Move to networking module with options
  networking.hostName = "smolboi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # TODO: Move to sound module with options
  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.beat = {
    isNormalUser = true;
    description = "Beat Scherrer";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  programs.zsh.enable = true; # TODO:
  users.defaultUserShell = pkgs.zsh; # TODO:

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "beat" = import ../home-manager/home.nix;
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

    samba
    cifs-utils

    gnome.gnome-keyring
    gnome-online-accounts
    dbus

    debootstrap # schroot
    pv # schroot

    pkg-config
  ];

  # TODO: modularize this
  environment.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
    homeupdate = "home-manager switch --flake ~/.nix";
    nnix = "nvim ~/.nix";
    sourcezsh = "source ~/.zshrc"; # TODO: Where is the rc file placed in nixos?
    config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";

    # personal
    cdsrc = "cd ~/src";
    cdairshow = "cdsrc && cd airshow";
    cdaf = "cdsrc && cd albatros_frontend";
    sc = "sudo SYSTEMD_EDITOR=vim systemctl";
    jc = "sudo journalctl";
    vimf = "nvim $(fzf)";

    # MT-Robot AG
    cdmtr = "cd ~/src";
  };

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [ nerdfonts ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

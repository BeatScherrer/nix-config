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
    # ../../modules/nixos/gnome.nix
    ../../modules/nixos/herbstluftwm.nix
    ../../modules/nixos/user.nix
    # ../../modules/nixos/hyprland.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];

  # add flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-1262150f-e6ad-4dd6-89e6-6db5cda4e267".device = "/dev/disk/by-uuid/1262150f-e6ad-4dd6-89e6-6db5cda4e267";
  boot.initrd.luks.devices."luks-1262150f-e6ad-4dd6-89e6-6db5cda4e267".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # symlink to /bin /usr/bin so scripts are portable
  services.envfs.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;

  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    wireguard-tools
    llvmPackages_16.clang-unwrapped
    alacritty
    vim
    neovim
    coreutils
    git
    xclip
    gnumake
    gcc13
    usbutils
    lshw
    fwupd
    postgresql_15
    nodejs_20
    libsForQt5.qt5.qtgraphicaleffects # required for sddm
    docker
    # TODO: get schroot somehow
    debootstrap # schroot
    pv # schroot

    gnome.gnome-keyring
    gnome-online-accounts
    dbus

    samba
    cifs-utils
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  services.gvfs.enable = true; # required for smb
  security.pam.services.sddm.enableGnomeKeyring = true;

  virtualisation.docker.enable = true;

  # Control light with keys
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 232 ];
        events = [ "key" ];
        command = "/run/wrappers/bin/light -A 10";
      }
      {
        keys = [ 233 ];
        events = [ "key" ];
        command = "/run/wrappers/bin/light -U 10";
      }
    ];
  };
  sound.mediaKeys.enable = true;

  # List services that you want to enable:
  services.fwupd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

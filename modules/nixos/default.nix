{
  pkgs,
  inputs,
  config,
  ...
}:
let
  gitRev =
    if inputs.self ? rev then
      builtins.substring 0 7 inputs.self.rev
    else if inputs.self ? dirtyShortRev then
      inputs.self.dirtyShortRev
    else
      "unknown";
in
{
  imports = [
    ./networking.nix
    ./scripts.nix
    ./sudo.nix
    ./tailscale.nix
    ./sops.nix
    ./anthropic.nix
  ];

  # Common boot configuration (overridden by secure-boot.nix for lanzaboote)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.enableContainers = true;
  boot.supportedFilesystems = [ "nfs" ];

  # gvfs SMB backend so nautilus (and other GIO apps) can browse smb:// shares.
  # Lives here rather than per-WM so every session — gpwm included — gets it.
  services.gvfs.enable = true;

  # fwupd daemon so `fwupdmgr` can pull firmware/BIOS updates from LVFS.
  services.fwupd.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    font-awesome
  ];

  environment.systemPackages = with pkgs; [
    fd
    vim
    neovim
    wget
    home-manager
    git
    git-doc # gitk
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
    ghostty
    claude-desktop
    lsof
    appimage-run
    mpv
    wireguard-tools
    inetutils
    pciutils
    python3
    bun

    # network shares
    samba
    cifs-utils
    nfs-utils
    gnome.gvfs

    gnome-keyring
    gnome-online-accounts
    dbus

    pkg-config

    # GStreamer plugins for media playback (required by many applications)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  programs.bash.blesh = {
    enable = true;
  };

  programs.nix-ld.enable = true;

  system.nixos.label =
    (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
    + config.system.nixos.version
    + "-SHA:${gitRev}";

}

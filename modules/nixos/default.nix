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
    ./tailscale.nix
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
    cursor
    lsof
    appimage-run
    mpv
    wireguard-tools
    inetutils
    pciutils
    python3

    # network shares
    samba
    cifs-utils

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

  system.nixos.label =
    (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
    + config.system.nixos.version
    + "-SHA:${gitRev}";

}

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
    lm_sensors
    cmake
    clang
    gcc
    gnumake
    envsubst
    rust-bin.stable.latest.default
    pnpm
    inputs.ghostty.packages.${pkgs.system}.default
    # FIXME:
    # inputs.claude-desktop.packages.${pkgs.system}.default
    inputs.cursor.packages.${pkgs.system}.default
    lsof
    appimage-run
    mpv
    wireguard-tools
    inetutils
    pciutils

    # network shares
    samba
    cifs-utils

    gnome-keyring
    gnome-online-accounts
    dbus

    pkg-config
  ];

  services.tailscale.enable = true;

  programs.bash.blesh = {
    enable = true;
  };

  system.nixos.label =
    (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
    + config.system.nixos.version
    + "-SHA:${gitRev}";

}

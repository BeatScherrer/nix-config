{ pkgs, inputs, ... }:
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
    inputs.claude-desktop.packages.${pkgs.system}.default
    inputs.cursor.packages.${pkgs.system}.default
    lsof
    appimage-run
    mpv
    wireguard-tools

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

}

{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnome-session
    gnome-tweaks
    gnomeExtensions.pop-shell
    gnome-remote-desktop
    xorg.xev
    xorg.xhost
    xorg.xauth
    xorg.xeyes
    xorg.xinit
  ];

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "compose:ralt";
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager = {
      gdm.enable = true;
      # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset s off         # Disable screen saver
        ${pkgs.xorg.xset}/bin/xset -dpms         # Disable DPMS
      '';
    };
  };

  # RDP
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "${pkgs.gnome-remote-desktop}/bin/gnome-session";
  };
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
}

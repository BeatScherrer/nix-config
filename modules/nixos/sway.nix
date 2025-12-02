{ pkgs, user, ... }:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    mesa
    libGL
    wlr-randr
  ];

  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };

  users.users.${user}.extraGroups = [ "video" ];

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # NOTE: keep this here if we want to use greetd
  # services.greetd = {
  #   enable = true;
  #   settings = rec {
  #     initial_session = {
  #       command = "${pkgs.sway}/bin/sway";
  #       user = "beat";
  #     };
  #     default_seession = initial_session;
  #   };
  # };

  services.displayManager = {
    gdm.enable = true;
    gdm.wayland = true;
  };

  environment.sessionVariables = {
    # hint to electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };
}

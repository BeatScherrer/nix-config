{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.gpwm;
in
{
  imports = [
    inputs.gpwm.nixosModules.gpwm
  ];

  options.gpwm = {
    enable = lib.mkEnableOption "Gravel Pit Window Manager (gpwm), Beat's Rust-based Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    # Upstream module enables programs.gpwm.enable=true, which installs the
    # binary, drops /etc/wayland-sessions/gpwm.desktop (Exec already includes
    # --session-target=gpwm-session.target), brings up dbus + polkit +
    # xdg-portal-wlr, and declares the systemd user `gpwm-session.target`
    # (BindsTo graphical-session.target). Helpers (swaybg, noctalia) get
    # wired through home-manager's gpwm module via WantedBy=gpwm-session.target.
    programs.gpwm.enable = true;

    services.displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
      "input"
      "seat"
    ];

    # gpwm leaves smithay's XkbConfig at Default, so xkbcommon falls back to
    # these env vars for layout/options. services.xserver.xkb.* only affects
    # X11 sessions, hence Compose-on-RAlt has to be wired through here for
    # Wayland.
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "us";
      XKB_DEFAULT_OPTIONS = "compose:ralt";
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      wlr-randr
      brightnessctl
      playerctl
      swaybg
      libnotify
    ];
  };
}

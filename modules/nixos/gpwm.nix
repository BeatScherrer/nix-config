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
    # binary, drops /etc/wayland-sessions/gpwm.desktop, brings up dbus +
    # polkit + xdg-portal-wlr, and declares the systemd user
    # `gpwm-session.target` (BindsTo graphical-session.target). Helpers
    # (swaybg, noctalia) get wired through home-manager's gpwm module via
    # WantedBy=gpwm-session.target.
    programs.gpwm.enable = true;

    # greetd is the canonical entry point: display manager -> wayland-session
    # selector -> the .desktop the gpwm module installed. Skipped here if
    # another display manager (gdm, lightdm) is already configured by the
    # host; this just guarantees gpwm can be selected.
    services.greetd = {
      enable = lib.mkDefault true;
      settings = lib.mkDefault {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd \"gpwm --session-target=gpwm-session.target\"";
          user = "greeter";
        };
      };
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

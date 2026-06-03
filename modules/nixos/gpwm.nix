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

    shell = lib.mkOption {
      type = lib.types.enum [
        "noctalia"
        "dms"
      ];
      default = "noctalia";
      description = ''
        Which Quickshell-based session shell to wire as a gpwm-session helper.
        Selects whether noctalia.enable or dms.enable gets flipped on (system
        services) and which user service the home-manager gpwm module brings
        up against gpwm-session.target.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Upstream module enables programs.gpwm.enable=true, which installs the
    # binary, drops /etc/wayland-sessions/gpwm.desktop (Exec already includes
    # --session-target=gpwm-session.target), brings up dbus + polkit +
    # xdg-portal-wlr, and declares the systemd user `gpwm-session.target`
    # (BindsTo graphical-session.target). Helpers (swaybg, noctalia) get
    # wired through home-manager's gpwm module via WantedBy=gpwm-session.target.
    programs.gpwm.enable = true;

    # Keybindings and per-host `settings` (layouts, per-output workspace
    # assignment) live on the home-manager side now — see
    # modules/home-manager/gpwm/gpwm.nix and each host's home.nix. The upstream
    # hm module writes ~/.config/gpwm/config.toml, which gpwm reads in
    # preference to the /etc/xdg/gpwm/config.toml this module would otherwise
    # write. Leaving keybindings/settings unset here means no /etc config is
    # generated and the user config wins cleanly.

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
      XKB_DEFAULT_LAYOUT = "us,ch";
      XKB_DEFAULT_OPTIONS = "compose:ralt,grp:ctrl_alt_toggle";
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
      wofi
      # Spawn targets for Super+{b,e,f} keybinds — gpwm runs these via PATH.
      librewolf
      thunderbird
      nautilus
    ];
  };
}

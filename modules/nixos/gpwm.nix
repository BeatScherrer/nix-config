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
      # Pin the session so GDM never depends on the per-user AccountsService
      # record (~/.../AccountsService/users/$USER: `Session=`). A stale entry
      # there — e.g. a since-removed `none+herbstluftwm` — makes GDM 50 abort
      # with "Unable to run session" instead of falling back to the only
      # installed session like GDM 49 did. "gpwm" matches gpwm.desktop's basename.
      defaultSession = "gpwm";
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
      # No grp:* layout-toggle option: it would steal Ctrl+Alt (breaking
      # Ctrl+Alt+Fn VT switching). gpwm cycles us↔ch on Ctrl+Alt+Space via its
      # own `cycle-keyboard-layout` keybind instead.
      XKB_DEFAULT_OPTIONS = "compose:ralt";
      # Firefox/Thunderbird default to XWayland (blurry HiDPI, mispositioned
      # popups/dialogs). Opt into native Wayland; gpwm spawns these via PATH.
      MOZ_ENABLE_WAYLAND = "1";
      # Proton games default to XWayland; opt them into Wine's native Wayland
      # driver. Only Proton Experimental / 10+ honor this — older versions
      # silently stay on XWayland. Override per game with
      # `PROTON_ENABLE_WAYLAND=0 %command%` in its Steam launch options.
      PROTON_ENABLE_WAYLAND = "1";
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

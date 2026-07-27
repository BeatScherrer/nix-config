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

    # security.polkit.enable (set by the upstream module) only starts polkitd —
    # it no longer installs the setuid pkexec wrapper, since nixpkgs split that
    # off into security.polkit.enablePkexecWrapper, default false. Without it
    # the only pkexec in PATH is the plain binary from the polkit package, which
    # bails out with "pkexec must be setuid root". Tray apps that escalate that
    # way (tailscale-systray's up/down toggle) need the wrapper.
    security.polkit.enablePkexecWrapper = true;

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

    # gpwm is a bare Wayland compositor with no desktop environment, so nothing
    # ever starts a Secret Service (org.freedesktop.secrets) provider. Anything
    # that stores credentials in the login keyring — MySQL Workbench, browsers,
    # network-manager — then fails with "Could not activate remote peer
    # 'org.freedesktop.secrets': unit failed", because D-Bus on-demand
    # activation can't unlock the keyring without the login password.
    #
    # Enabling gnome-keyring installs the daemon, its D-Bus activation file and
    # the cap_ipc_lock wrapper, and wires the TTY `login` PAM service. GDM
    # graphical logins go through the `gdm-password` PAM stack instead, so
    # enable it there too — pam_gnome_keyring then starts the daemon and
    # unlocks it with the same password at login.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm-password.enableGnomeKeyring = true;

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

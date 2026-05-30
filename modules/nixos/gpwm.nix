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

    # Full keybind set (replaces gpwm's built-in defaults). Reproduces every
    # default and layers on Super+{b,e,f} for librewolf/thunderbird/nautilus;
    # fullscreen moves from Super+f to Super+Shift+m so it pairs with the
    # existing Super+m → toggle-maximize.
    programs.gpwm.keybindings = [
      # Frame / tab navigation
      { mods = [ "super" ]; key = "h"; action = "navigate-left"; }
      { mods = [ "super" ]; key = "j"; action = "navigate-down"; }
      { mods = [ "super" ]; key = "k"; action = "navigate-up"; }
      { mods = [ "super" ]; key = "l"; action = "navigate-right"; }
      { mods = [ "super" "shift" ]; key = "h"; action = "move-left"; }
      { mods = [ "super" "shift" ]; key = "j"; action = "move-down"; }
      { mods = [ "super" "shift" ]; key = "k"; action = "move-up"; }
      { mods = [ "super" "shift" ]; key = "l"; action = "move-right"; }
      { mods = [ "super" ]; key = "Page_Down"; action = "focus-next-tab"; }
      { mods = [ "super" ]; key = "Page_Up"; action = "focus-prev-tab"; }

      # Spawn
      { mods = [ "super" ]; key = "Return"; action = { spawn = "ghostty"; }; }
      { mods = [ "super" ]; key = "space"; action = { spawn = "wofi"; }; }
      { mods = [ "super" ]; key = "b"; action = { spawn = "librewolf"; }; }
      { mods = [ "super" ]; key = "e"; action = { spawn = "thunderbird"; }; }
      { mods = [ "super" ]; key = "f"; action = { spawn = "nautilus"; }; }

      # Window / frame ops
      { mods = [ "super" ]; key = "w"; action = "close"; }
      { mods = [ "super" "shift" ]; key = "w"; action = "remove-frame"; }
      { mods = [ "super" "shift" ]; key = "space"; action = "cycle-layout"; }
      { mods = [ "super" ]; key = "m"; action = "toggle-maximize"; }
      { mods = [ "super" "shift" ]; key = "m"; action = "toggle-fullscreen"; }

      # Frame splits: o splits to the right (new leaf side-by-side), u splits
      # downward (new leaf stacked underneath).
      { mods = [ "super" ]; key = "o"; action = "split-right"; }
      { mods = [ "super" ]; key = "u"; action = "split-down"; }

      # Workspaces 1..9 (switch and move-to)
      { mods = [ "super" ]; key = "1"; action = { workspace = 1; }; }
      { mods = [ "super" ]; key = "2"; action = { workspace = 2; }; }
      { mods = [ "super" ]; key = "3"; action = { workspace = 3; }; }
      { mods = [ "super" ]; key = "4"; action = { workspace = 4; }; }
      { mods = [ "super" ]; key = "5"; action = { workspace = 5; }; }
      { mods = [ "super" ]; key = "6"; action = { workspace = 6; }; }
      { mods = [ "super" ]; key = "7"; action = { workspace = 7; }; }
      { mods = [ "super" ]; key = "8"; action = { workspace = 8; }; }
      { mods = [ "super" ]; key = "9"; action = { workspace = 9; }; }
      { mods = [ "super" "shift" ]; key = "1"; action = { "move-to-workspace" = 1; }; }
      { mods = [ "super" "shift" ]; key = "2"; action = { "move-to-workspace" = 2; }; }
      { mods = [ "super" "shift" ]; key = "3"; action = { "move-to-workspace" = 3; }; }
      { mods = [ "super" "shift" ]; key = "4"; action = { "move-to-workspace" = 4; }; }
      { mods = [ "super" "shift" ]; key = "5"; action = { "move-to-workspace" = 5; }; }
      { mods = [ "super" "shift" ]; key = "6"; action = { "move-to-workspace" = 6; }; }
      { mods = [ "super" "shift" ]; key = "7"; action = { "move-to-workspace" = 7; }; }
      { mods = [ "super" "shift" ]; key = "8"; action = { "move-to-workspace" = 8; }; }
      { mods = [ "super" "shift" ]; key = "9"; action = { "move-to-workspace" = 9; }; }

      # Scratchpad + quit
      { mods = [ "super" ]; key = "minus"; action = "toggle-scratchpad"; }
      { mods = [ "super" "shift" ]; key = "minus"; action = "move-to-scratchpad"; }
      { mods = [ "super" "shift" ]; key = "q"; action = "quit"; }
    ];

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
      wofi
      # Spawn targets for Super+{b,e,f} keybinds — gpwm runs these via PATH.
      librewolf
      thunderbird
      nautilus
    ];
  };
}

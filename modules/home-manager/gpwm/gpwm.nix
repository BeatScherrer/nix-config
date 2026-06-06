{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.gpwm;

  # Super+Space opens the app launcher of whichever shell is active, driven
  # over that shell's IPC; wofi is the fallback when neither shell is selected.
  # Both shell launchers are layer surfaces that declare keyboard
  # interactivity, so gpwm focuses them on open and you can type straight away.
  launcherCmd =
    if cfg.shell == "dms" then
      "dms ipc launcher toggle"
    else if cfg.shell == "noctalia" then
      "noctalia-shell ipc call launcher toggle"
    else
      "wofi";

  # gpwm's spawn action execs the program directly (no shell), so a command
  # with pipes/$() must live in a wrapper script. This is the "pick a window
  # and screenshot it" snippet from gpwm's IPC docs: gpwm msg clients feeds
  # each window's geometry to slurp, and grim captures the chosen region.
  # grim/slurp/jq are pinned via runtimeInputs; gpwm itself is on session PATH.
  screenshotWindow = pkgs.writeShellApplication {
    name = "gpwm-screenshot-window";
    runtimeInputs = with pkgs; [
      grim
      slurp
      jq
    ];
    text = ''
      grim -g "$(gpwm msg clients | jq -r '.[]|"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)" window.png
    '';
  };
in
{
  imports = [
    # Upstream gpwm home-manager module. Provides the `programs.gpwm.*` option
    # namespace (enable/package + the shared keybindings/settings schema) and
    # writes ~/.config/gpwm/config.toml, which gpwm reads in preference to the
    # system-wide /etc/xdg/gpwm/config.toml. Keeping keybindings/settings on the
    # home side means they live in user config; the session itself
    # (display-manager registration, polkit, portals, gpwm-session.target)
    # remains the NixOS module's job.
    inputs.gpwm.homeModules.gpwm
    ../noctalia/noctalia.nix
    ../dms/dms.nix
  ];

  options.gpwm = {
    enable = mkEnableOption "Gravel Pit Window Manager (Beat's Rust Wayland compositor)";

    shell = mkOption {
      type = types.enum [
        "noctalia"
        "dms"
      ];
      default = "noctalia";
      description = ''
        Which Quickshell-based session shell to install and run alongside gpwm.
        Drives noctalia/dms package installation and the corresponding
        systemd user service bound to gpwm-session.target.
      '';
    };

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to wallpaper image. If null, swaybg is not started.";
    };
  };

  config = mkIf cfg.enable {
    noctalia.enable = cfg.shell == "noctalia";
    dms.enable = cfg.shell == "dms";

    # Turn on the upstream home module: it writes ~/.config/gpwm/config.toml
    # from the keybindings below plus any host-specific `programs.gpwm.settings`
    # set in that host's home.nix. `package` stays null (the default) — gpwm is
    # installed system-wide by the NixOS module, so this only manages config.
    programs.gpwm.enable = true;

    programs.gpwm.settings = {
      # Scratchpad overlay height as a fraction (0, 1] of the focused output's
      # usable area — span 90% tall instead of gpwm's 0.8 default. Lives in the
      # [general] TOML table and is hot-reloaded on config save. Shared across
      # every gpwm host; per-host home.nix files can still override width (e.g.
      # trident's narrower 0.45) by merging into the same [general] table.
      general.scratchpad-height = 0.9;

      # Full keybind set (replaces gpwm's built-in defaults). Reproduces every
      # default and layers on Super+{b,e,f} for librewolf/thunderbird/nautilus;
      # fullscreen moves from Super+f to Super+Shift+m so it pairs with the
      # existing Super+m → toggle-maximize.
      keybind = [
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

        # Output (monitor) navigation. super+{y,u,i,o} mirror hjkl one row up:
        # y=left, u=down, i=up, o=right move focus to the adjacent output.
        { mods = [ "super" ]; key = "y"; action = "focus-output-left"; }
        { mods = [ "super" ]; key = "u"; action = "focus-output-down"; }
        { mods = [ "super" ]; key = "i"; action = "focus-output-up"; }
        { mods = [ "super" ]; key = "o"; action = "focus-output-right"; }

        # Spawn
        { mods = [ "super" ]; key = "Return"; action = { spawn = "ghostty"; }; }
        { mods = [ "super" ]; key = "space"; action = { spawn = launcherCmd; }; }
        { mods = [ "super" ]; key = "b"; action = { spawn = "librewolf"; }; }
        { mods = [ "super" ]; key = "e"; action = { spawn = "thunderbird"; }; }
        { mods = [ "super" ]; key = "f"; action = { spawn = "nautilus"; }; }
        { mods = [ "ctrl" "shift" ]; key = "b"; action = { spawn = "${screenshotWindow}/bin/gpwm-screenshot-window"; }; }

        # Window / frame ops. close (super+w) and remove-frame (super+shift+w)
        # mirror herbstluftwm's $Mod-w close. alt+w → remove-frame reproduces
        # herbstluftwm's Mod1-w remove muscle memory (gpwm accepts "alt"/"mod1").
        { mods = [ "super" ]; key = "w"; action = "close"; }
        { mods = [ "super" "shift" ]; key = "w"; action = "remove-frame"; }
        { mods = [ "alt" ]; key = "w"; action = "remove-frame"; }
        { mods = [ "super" "shift" ]; key = "space"; action = "cycle-layout"; }
        { mods = [ "super" ]; key = "m"; action = "toggle-maximize"; }
        { mods = [ "super" "shift" ]; key = "m"; action = "toggle-fullscreen"; }

        # Frame splits: shift+o splits to the right (new leaf side-by-side),
        # shift+u splits downward (new leaf stacked underneath). Moved off
        # super+{o,u} so those keys are free for output navigation above.
        { mods = [ "super" "shift" ]; key = "o"; action = "split-right"; }
        { mods = [ "super" "shift" ]; key = "u"; action = "split-down"; }

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

      # Pointer-button bindings. gpwm's [[mousebind]] schema mirrors [[keybind]]
      # (optional `mods`, a `button` name/code in place of `key`, same actions).
      # The back side-button (evdev 278; "back"/"forward"/"side"/"extra"/"task"
      # or a raw code like "278"/"0x116" are all accepted) opens the window
      # overview. gpwm binds this by default too — listing it makes it explicit
      # and survives any future default change.
      mousebind = [
        { button = "back"; action = "toggle-overview"; }
      ];
    };

    home.packages = with pkgs; [
      wl-clipboard
      grim
      slurp
      wlr-randr
      brightnessctl
      playerctl
      libnotify
      foot
      ghostty
    ];

    # Helpers bound to gpwm-session.target (declared by the system module).
    # gpwm itself starts the target at session bootstrap via the
    # `--session-target=gpwm-session.target` flag baked into greetd's command;
    # `BindsTo` makes these helpers terminate when gpwm exits, `partOf` +
    # `wants` make a manual `systemctl --user stop gpwm-session.target` tear
    # them down cleanly.
    systemd.user.services.swaybg = mkIf (cfg.wallpaper != null) {
      Unit = {
        Description = "Wayland wallpaper daemon";
        PartOf = [ "gpwm-session.target" ];
        BindsTo = [ "gpwm-session.target" ];
        After = [ "gpwm-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${cfg.wallpaper} -m fill";
      };
      Install.WantedBy = [ "gpwm-session.target" ];
    };

    systemd.user.services.noctalia-shell = mkIf (cfg.shell == "noctalia") {
      Unit = {
        Description = "Noctalia shell";
        PartOf = [ "gpwm-session.target" ];
        BindsTo = [ "gpwm-session.target" ];
        After = [ "gpwm-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
      };
      Install.WantedBy = [ "gpwm-session.target" ];
    };

    systemd.user.services.dms-shell = mkIf (cfg.shell == "dms") {
      Unit = {
        Description = "DankMaterialShell";
        PartOf = [ "gpwm-session.target" ];
        BindsTo = [ "gpwm-session.target" ];
        After = [ "gpwm-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.dms-shell}/bin/dms run --session";
      };
      Install.WantedBy = [ "gpwm-session.target" ];
    };
  };
}

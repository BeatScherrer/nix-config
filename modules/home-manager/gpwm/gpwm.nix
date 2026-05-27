{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.gpwm;
in
{
  imports = [
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

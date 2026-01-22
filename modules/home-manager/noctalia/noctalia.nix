{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.noctalia;
in
{
  options.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    settingsFile = lib.mkOption {
      type = lib.types.path;
      default = ./settings.json;
      description = "Path to the noctalia settings.json file. Override per-host for host-specific settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      noctalia-shell
      brightnessctl
      gpu-screen-recorder
      upower
    ];

    # Out-of-store symlink so noctalia can modify settings dynamically
    # while keeping the file version controlled in the repo
    xdg.configFile."noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink cfg.settingsFile;
  };
}

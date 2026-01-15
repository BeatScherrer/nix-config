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
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      noctalia-shell
      brightnessctl
      gpu-screen-recorder
    ];

    # Out-of-store symlink so noctalia can modify settings dynamically
    # while keeping the file version controlled in the repo
    xdg.configFile."noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nix/modules/home-manager/noctalia/settings.json";
  };
}

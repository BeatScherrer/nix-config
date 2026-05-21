{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.mango;
in
{
  imports = [
    ../noctalia/noctalia.nix
    ../rofi/rofi.nix
  ];

  options.mango = {
    enable = mkEnableOption "mango";
  };

  config = mkIf cfg.enable {
    noctalia.enable = true;

    xdg.configFile."mango/config.conf".source =
      config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
      + "/.nix/modules/home-manager/mango/config.conf";

    home.packages = with pkgs; [
      wl-clipboard
      grim
      grimblast
      slurp
      playerctl
      brightnessctl
      rofi
      swaynotificationcenter
    ];
  };
}

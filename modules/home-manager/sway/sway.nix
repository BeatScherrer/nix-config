{ pkgs, config, ... }:
{
  imports = [
    ../waybar/waybar.nix
  ];

  home.file.".config/sway/config".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/sway/config";
}

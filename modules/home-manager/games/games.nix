{ pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    lutris
    heroic
    bottles
    gamescope
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATH = "~/.steam/root/compatibilitytools.d";
  };
}

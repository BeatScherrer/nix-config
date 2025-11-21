{ pkgs, ... }:
{
  programs.steam.enable = true;
  # programs.steam.gamescopeSession.enable = true; # TODO: fix
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-ng
  ];
}

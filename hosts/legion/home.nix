{ ... }:
{
  imports = [
    ../../home-manager/home.nix
  ];

  polybar = {
    enable = true;
    mainMonitor = "DP-2.3";
  };
}

{ ... }:
{
  imports = [
    ../../home-manager/home.nix
  ];

  polybar = {
    enable = true;
    mainMonitor = "DisplayPort-4";
  };
}

{ ... }:
{
  imports = [
    ../../home-manager/home.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  polybar = {
    enable = true;
    mainMonitor = "DP-2.3";
  };
}

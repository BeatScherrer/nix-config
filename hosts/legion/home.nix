{ ... }:
{
  imports = [
    ../../home-manager/home.nix
    ../../modules/home-manager/work/mtr.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  polybar = {
    enable = true;
    mainMonitor = "DP-2.3";
    fallbackMonitor = "DP-4";
    width = "100%";
    offset_x = "0";
  };
}

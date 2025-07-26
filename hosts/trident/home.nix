{ ... }:
{
  imports = [
    ../../home-manager/home.nix
    ../../modules/home-manager/vscode/vscode.nix
    ../../modules/home-manager/work/unlimited-booking/unlimited-booking.nix
    ../../modules/home-manager/work/mtr/mtr.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  polybar = {
    enable = true;
    mainMonitor = "DisplayPort-4";
  };
}

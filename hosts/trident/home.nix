{ ... }:
{
  imports = [
    ../../home-manager/home.nix
    ../../modules/home-manager/vscode/vscode.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  polybar = {
    enable = true;
    mainMonitor = "DisplayPort-2";
  };
}

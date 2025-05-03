{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than +10";

  # list all current system packages in /etc/current-system-packages
  environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
    formatted;

}

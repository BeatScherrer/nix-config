{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
    matchBlocks."*" = { };
  };

  home.file.".ssh/config.d/shetec".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/shetec/shetec.ssh";
}

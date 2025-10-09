{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
  };

  home.file.".ssh/config.d/shetec".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/shetec/shetec.ssh";
}

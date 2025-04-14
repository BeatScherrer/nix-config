{ config, ... }:
{
  # ssh
  programs.ssh.extraConfig = ''
    Include ~/.ssh/config.d/*
  '';

  home.file.".ssh/config.d/mtr".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/ssh/mtr.ssh";
}

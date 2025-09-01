{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    mysql-workbench
    remmina
    freecad
    blender
    claude-code
    tigervnc
  ];

  # FIXME: the resulting ~/.ssh/config ownership gets mapped to nobody:nobody in distrobox...
  # ssh
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
  };

  home.file.".ssh/config.d/mtr".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/mtr/mtr.ssh";
}

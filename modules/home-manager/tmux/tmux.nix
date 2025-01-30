{ config, ... }:
{
  home.file.".tmux.config".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "./nix/modules/home-manager/tmux/tmux.conf";

  programs.tmux = {
    enable = true;
    clock24 = true;
  };
}

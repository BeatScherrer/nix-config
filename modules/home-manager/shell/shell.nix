{ config, lib, ... }:
with lib;
let
  cfg = config.shell;
in
{
  imports = [
    ./bash/bash.nix
    ./zsh/zsh.nix
  ];

  options.shell = {
    enable = mkEnableOption "shell";
    mkOutOfStoreSymlink = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    bash.enable = true;
    zsh.enable = true;

    bash.mkOutOfStoreSymlink = cfg.mkOutOfStoreSymlink;
    zsh.mkOutOfStoreSymlink = cfg.mkOutOfStoreSymlink;

    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
    };
  };

}
{ pkgs, ... }:
let
  aliases = import ./aliases.nix;
in
{
  imports = [
    ./zsh/zsh.nix
    ./bash/bash.nix
  ];

  zsh.mkOutOfStoreSymlink = false;
  bash.mkOutOfStoreSymlink = false;

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    bash = {
      enable = true;
      shellAliases = aliases;
    };
  };
}

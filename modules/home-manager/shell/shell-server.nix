{ pkgs, ... }:
let
  aliases = import ./aliases.nix;
in
{
  # TODO: use the zsh config here also smh without the out of store symlinks

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = aliases;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "history"
        ];
      };
    };

    bash = {
      enable = true;
      shellAliases = aliases;
    };
  };
}

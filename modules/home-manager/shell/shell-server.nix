{ pkgs, ... }:
let
  aliases = import ./aliases.nix;
in
{
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

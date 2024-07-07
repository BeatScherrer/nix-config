{ config, pkgs, ... }:
let
  aliases = import ../aliases.nix;
in
{
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = aliases;
      oh-my-zsh = {
        enable = true;
        #custom = "${pkgs.nur.repos....}" # TODO:
        # theme = "gravel_pit";
        theme = "robbyrussell";
        plugins = [
          "git"
          "npm"
          "history"
          "rust"
        ];
      };
    };
  };
}

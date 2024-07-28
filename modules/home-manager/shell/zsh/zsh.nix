{ ... }:
let
  aliases = import ../aliases.nix;
in
{
  # TODO: custom zsh theme (think about this):
  # - Create a git repo with the custom theme
  # - use the git repo in nix automatically install the theme on configuration with given commit id

  # copy file to the custom oh-my-zsh directory
  home.file = {
    ".zsh_custom/themes" = {
      source = ./oh-my-zsh/themes;
      recursive = true;
    };
  };

  programs = {
    zsh = {
      enable = false;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = aliases;
      oh-my-zsh = {
        enable = true;
        custom = "$HOME/.zsh_custom";
        theme = "gravel_pit";
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

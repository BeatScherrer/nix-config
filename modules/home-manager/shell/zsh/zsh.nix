{ config, ... }:
let
  aliases = import ../aliases.nix;
in
{
  # copy file to the custom oh-my-zsh directory
  home.file = {
    ".zsh_custom/themes" = {
      source = ./oh-my-zsh/themes;
      recursive = true;
    };
  };

  # NOTE: this requires an absolute path... At least this works with mac and linux
  home.file.".zshrcExtra".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/shell/zsh/zshrcExtra";

  programs = {
    zsh = {
      initContent = "source $HOME/.zshrcExtra";
      enable = true;
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

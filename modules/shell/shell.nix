{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./zsh/zsh.nix
  ];

  home.packages = with pkgs; [ oh-my-posh ];

  programs = {
    oh-my-posh = {
      enable = true;
      useTheme = "bubblesextra";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };

}

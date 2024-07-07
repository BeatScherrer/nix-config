{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./zsh/zsh.nix
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };

}

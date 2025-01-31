{ ... }:
{
  imports = [
    ./bash/bash.nix
    ./zsh/zsh.nix
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true; # NOTE: fails on ubuntu22 --> do manually in bashrc
    };
  };

  home.sessionVariables = {
    TERM = "xterm-256color";
  };

}

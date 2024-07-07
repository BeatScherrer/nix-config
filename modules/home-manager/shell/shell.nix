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
      # useTheme = "bubblesextra";
      settings = builtins.fromTOML (
        builtins.unsafeDiscardStringContext (builtins.readFile ./oh-my-posh/themes/gravel_pit.omp.toml)
      );
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };

}

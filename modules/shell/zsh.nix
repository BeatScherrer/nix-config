{ config, pkgs, ... }: {
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        #custom = "${pkgs.nur.repos....}" # TODO:
        # theme = "gravel_pit";
        theme = "robbyrussell";
        plugins = [ "git" "npm" "history" "rust" ];
      };
    };
  };
}

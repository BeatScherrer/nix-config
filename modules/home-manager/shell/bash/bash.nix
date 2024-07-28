{ ... }:
let
  aliases = import ../aliases.nix;
  bashrc = builtins.readFile ./bashrc;
  bashrc_mt = builtins.readFile ./bashrc_mt;
in
{

  programs = {
    bash = {
      enable = true;
      shellAliases = aliases;
      bashrcExtra = ''
        ${bashrc}
        ${bashrc_mt}
      '';
    };
  };

  home.file = {
    # TODO:
    # ".bashrc" = {
    #   source = ./bashrc;
    # };

    ".bashrc_mt" = {
      source = ./bashrc_mt;
    };

    ".oh-my-bash/custom/themes" = {
      source = ./oh-my-bash/themes;
      recursive = true;
    };
  };
}

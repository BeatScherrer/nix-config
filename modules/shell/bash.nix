{ pkgs, ... }:
let
  aliases = import ./aliases.nix;
in
{
  programs.bash = {
    shellAliases = aliases;
  };

  users = {
    defaultUserShell = pkgs.bash;
  };
}

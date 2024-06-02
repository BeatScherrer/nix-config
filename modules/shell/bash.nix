{config, pkgs, ...}:
let
  aliases = {
      nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
      homeupdate = "home-manager switch --flake ~/.nix";
      nnix = "nvim ~/.nix";
  };
in
{
  programs.bash = {
    shellAliases = aliases;
  };

  users = {
    defaultUserShell = pkgs.bash
  };
}

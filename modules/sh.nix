{config, pkgs, ...}:
{
  programs.bash = {
    shellAliases = {
      nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
      homeupdate = "home-manager switch --flake ~/.nix";
      nnix = "nvim ~/.nix";
    };
  };
}

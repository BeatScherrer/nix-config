# FIXME:
# Issues:
# - [ ] installation fails (nix build)
# - [ ] overlay fails (used in main flake, due to this flake failing?)

# NOTE: use `nix develop .#packages.x86_64-linux.default`to develop the derivation

{
  description = "Schroot package flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # TODO: provide overlay
      packages.${system}.default = pkgs.callPackage ./default.nix { };
    };
}

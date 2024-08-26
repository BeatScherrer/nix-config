# FIXME:
# Issues:
# - [ ] installation fails (nix build)
# - [ ] overlay fails (used in main flake, due to this flake failing?)

{
  description = "Schroot package flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        overlay = final: prev: { schroot = prev.pkgs.callPackage ./. { }; };

        # NOTE: use `nix develop .#packages.x86_64-linux.default` to develop this package or comment devShell below
        # When using this shell we do not really need the devshell
        packages.default = pkgs.callPackage ./default.nix { };
      }
    );
}

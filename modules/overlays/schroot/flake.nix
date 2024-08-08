# FIXME:
# Issues:
# - [ ] installation fails (nix build)
# - [ ] overlay fails (used in main flake)

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
        version = "1.6.13-3";
        stdenv = pkgs.stdenv;

        dependencies = with pkgs; [
          boost
          groff
          perl538Packages.Po4a
          groff
          libuuid
          gettext
          doxygen
        ];
      in
      {
        # overlay = final: prev: { schroot = prev.pkgs.callPackage ./. { }; };

        packages.default = import ./default.nix {
          inherit
            pkgs
            version
            stdenv
            dependencies
            ;
        };

        devShell = pkgs.mkShell {
          buildInputs =
            with pkgs;
            dependencies
            ++ [
              cmake
              ninja
            ];
        };
      }
    );
}

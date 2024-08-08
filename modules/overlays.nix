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
        pkgs = nixpkgs.legacyPackages.${system};
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

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
        # overlay = final: prev: { schroot = prev.pkgs.callPackage ./. { }; };

        packages.default = pkgs.callPackage ./default.nix { };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            ninja
            boost
            groff
            perl538Packages.Po4a
            groff
            libuuid
            gettext
            doxygen
            nixd
          ];
        };
      }
    );
}

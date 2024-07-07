# TODO: Make a derivation that packages the provided fonts
# TODO: Use the derivation in the configuration to add the provided fonts to the system

# allow our nixpkgs import to be overridden if desired
{
  pkgs ? import <nixpkgs> { },
}:

# let's write an actual basic derivation
# this uses the standard nixpkgs mkDerivation function
pkgs.stdenv.mkDerivation {

  # name of our derivation
  name = "custom-fonts";

  # sources that will be used for our derivation.
  src = ./fonts;

  # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
  # $src is defined as the location of our `src` attribute above
  installPhase = ''
    # $out is an automatically generated filepath by nix,
    # but it's up to you to make it what you need. We'll create a directory at
    # that filepath, then copy our sources into it.
    mkdir $out
    cp -rv $src/* $out
  '';
}

# allow our nixpkgs import to be overridden if desired
{
  pkgs ? import <nixpkgs> { },
  stdenv,
  version,
  dependencies,
}:
stdenv.mkDerivation {
  name = "schroot";

  src = builtins.fetchGit {
    url = "https://salsa.debian.org/debian/schroot.git";
    ref = "debian/master";
    rev = "59d82cf28a34cc7e91ef86b92333c54266d81789";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
  ];

  buildInputs = dependencies;

  cmakeFlags = [ "-G Ninja" ];

  # FIXME:
  installPhase = ''

  '';

  # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
  # $src is defined as the location of our `src` attribute above
  # installPhase = ''
  #   # $out is an automatically generated filepath by nix,
  #   # but it's up to you to make it what you need. We'll create a directory at
  #   # that filepath, then copy our sources into it.
  #   mkdir $out
  #   cp -rv $src/* $out
  # '';
}
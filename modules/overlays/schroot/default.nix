# FIXME:
# - [ ] Apparently the build step tries to install stuff and alter nix store files

# TODO:
# - [ ] find out where the schroot package is installing in the build step
# - [ ] investigate all the etc file stuff going on

# NOTE: /usr/bin should go to /nix/store/.../bin
# NOTE: /share should go to /nix/store/.../share
# NOTE: /usr/lib should go to /nix/store/.../lib
# NOTE: /usr/lib should go to /nix/store/.../lib
# NOTE: /etc/ ??

# allow our nixpkgs import to be overridden if desired
{
  pkgs ? import <nixpkgs> { },
  stdenv,
}:
stdenv.mkDerivation {
  name = "schroot";

  src = builtins.fetchGit {
    url = "https://salsa.debian.org/debian/schroot.git";
    ref = "debian/master";
    rev = "59d82cf28a34cc7e91ef86b92333c54266d81789";
  };
  # src = /home/beat/src/schroot;

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
  ];

  buildInputs = with pkgs; [
    boost
    groff
    perl538Packages.Po4a
    groff
    libuuid
    gettext
    doxygen
  ];

  cmakeFlags = [ "-G Ninja" ];

  # installPhase = ''
  #   mkdir -p "$out"
  #
  #   echo "ls: $(ls)"
  #   echo "pwd: $(pwd)"
  #
  #   ninja install
  # '';

}

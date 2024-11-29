# FIXME:
# - [ ] Apparently the build step tries to install stuff and alter nix store files

# allow our nixpkgs import to be overridden if desired
{
  pkgs,
  stdenv,
}:
stdenv.mkDerivation {
  name = "schroot";

  src = builtins.fetchGit {
    url = "https://salsa.debian.org/debian/schroot.git";
    ref = "debian/master";
    rev = "59d82cf28a34cc7e91ef86b92333c54266d81789";
  };
  # src = /home/beat/src/schroot; # NOTE: use with `nix build --impure`

  nativeBuildInputs = with pkgs; [
    pkgconfig
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

  phases = [
    "unpackPhase"
    "patchPhase"
    "configurePhase"
    "buildPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out
    make install DESTDIR=$out || echo "failed"
  '';

  configureFlags = [
    "--prefix=$out"
    "--sysconfdir=$out/etc"
    "--localstatedir=$out/var"
  ];

  # cmakeFlags = [ "-G Ninja" ];

}

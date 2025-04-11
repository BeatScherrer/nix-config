{ stdenv, fontconfig, ... }:

stdenv.mkDerivation {
  pname = "custom-fonts";
  version = "1.0";

  src = ./fonts;

  buildInputs = [ fontconfig ];

  installPhase = ''
    mkdir -p $out/share/fonts
    cp -r ${./fonts}/* $out/share/fonts
  '';
}

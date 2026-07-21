{
  stdenv,
  fontconfig,
  lib,
  ...
}:

stdenv.mkDerivation {
  pname = "custom-fonts";
  version = "1.0";

  src = ./fonts;

  buildInputs = lib.optionals (!stdenv.isDarwin) [ fontconfig ];

  installPhase =
    ''
      mkdir -p $out/share/fonts
      cp -r ${./fonts}/* $out/share/fonts
    ''
    + lib.optionalString stdenv.isDarwin ''
      echo "Installing fonts to ~/Library/Fonts..."
      mkdir -p ~/Library/Fonts
      ln -sf $out/share/fonts/* ~/Library/Fonts/
      echo "Fonts linked successfully."
    '';
}

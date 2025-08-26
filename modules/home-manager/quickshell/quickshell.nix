{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.quickshell.packages."x86_64-linux".quickshell
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtimageformats
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qt5.qtpositioning
  ];
}

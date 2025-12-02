{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (quickshell.withModules [
      qt6.qtmultimedia
      qt6.qtwebengine
      qt6.qtnetworkauth # For OAuth authentication
      qt6.qtpositioning
      qt6.qt5compat
      libsForQt5.breeze-icons
    ])
  ];
}

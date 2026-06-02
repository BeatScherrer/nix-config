{ pkgs, config, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.pointerCursor = {
    name = "Nordic-cursors";
    package = pkgs.nordic;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk.enable = true;
  gtk.theme.package = pkgs.nordic;
  gtk.theme.name = "Nordic-darker";
  # Keep legacy behavior: apply the gtk3 theme to gtk4 as well
  # (silences the home-manager >= 26.05 default-change warning).
  gtk.gtk4.theme = config.gtk.theme;

  gtk.iconTheme.package = pkgs.nordic;
  gtk.iconTheme.name = "Nordic-green";

  gtk.cursorTheme = {
    name = "Nordic-cursors";
    package = pkgs.nordic;
  };

  qt.enable = true;
  qt.platformTheme.name = "qtct";
  qt.style.name = "kvantum";
  # qt.style.package = pkgs.adwaita-qt;
}

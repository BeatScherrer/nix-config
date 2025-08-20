{ pkgs, ... }:
{
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

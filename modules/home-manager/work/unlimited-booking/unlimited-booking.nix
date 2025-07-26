{ config, ... }:
{
  home.file.".ssh/config.d/unlimited-booking".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/unlimited-booking/unlimited-booking.ssh";
}

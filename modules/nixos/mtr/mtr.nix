{ pkgs, ... }:
{
  # TODO: how to set the root password?
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
}

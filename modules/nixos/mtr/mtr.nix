{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mysql-workbench
    xmlstarlet
    libxml2
    tailscale
    tailscale-systray
  ];
  services.tailscale.enable = true;

  # Tailscale tray service
  systemd.user.services.tailscale-systray = {
    enable = true;
    description = "Tailscale sys tray";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.tailscale-systray}/bin/tailscale-systray";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    configFile = pkgs.writeText "my.cf" ''
      [mysqld]
      default-time-zone = "+00:00"
      datadir=/var/lib/mysql
      port=3306
    '';
    ensureUsers = [
      {
        name = "root";
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "mtr";
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "backup";
        ensurePermissions = {
          "*.*" = "SELECT, LOCK TABLES";
        };
      }
    ];
  };
}

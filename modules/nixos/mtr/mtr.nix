{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mysql-workbench
    xmlstarlet
    libxml2
    tailscale
    tailscale-systray
    bash-language-server
  ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Tailscale
  systemd.user.services.tailscale-systray = {
    enable = true;
    description = "Tailscale system tray";
    serviceConfig = {
      ExecStart = "${pkgs.bashInteractive}/bin/bash -i -c \"${pkgs.tailscale-systray}/bin/tailscale-systray\"";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # mysql
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

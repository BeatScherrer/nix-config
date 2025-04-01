{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mysql-workbench
    xmlstarlet
    libxml2
    tailscale
    tailscale-systray
    bash-language-server
    neocmakelsp
    pyright
    remmina
    ccache
    freecad
  ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # NOTE: enabling the firewall creates issues with gazebo: see
  # - https://docs.ros.org/en/rolling/How-To-Guides/Installation-Troubleshooting.html#enable-multicast
  # - https://gazebosim.org/docs/latest/troubleshooting/#network-configuration-issue
  networking.firewall.enable = false;

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

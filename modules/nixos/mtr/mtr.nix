{
  pkgs,
  config,
  lib,
  ...
}:
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
    lldb
    blender
    dig
    claude-code
    steam-run
    appimage-run
    # Schroot deps
    schroot
    debootstrap
    pv
  ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # use 'uc-3' to find 'uc-3.mt-robot.com'
  networking.search = [ "mt-robot.com" ];

  # NOTE: enabling the firewall creates issues with gazebo: see
  # - https://docs.ros.org/en/rolling/How-To-Guides/Installation-Troubleshooting.html#enable-multicast
  # - https://gazebosim.org/docs/latest/troubleshooting/#network-configuration-issue
  networking.firewall.enable = false;

  security.pki.certificateFiles = [ ./ca.crt ]; # NOTE: beware of trailing spaces

  # Tailscale
  systemd.user.services.tailscale-systray = {
    enable = true;
    description = "Tailscale system tray";
    serviceConfig = {
      ExecStart = ''${pkgs.bashInteractive}/bin/bash -i -c "${pkgs.tailscale-systray}/bin/tailscale-systray"'';
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

  # required for lldb debugging with neovim
  # WARN: allows any process to trace any other process. This can be a security risk, so ensure you understand the implications before making this change.
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

}

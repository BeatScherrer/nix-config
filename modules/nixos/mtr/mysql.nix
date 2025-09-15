{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mysql-workbench
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    # NOTE: for mysql workbench root use root password authentication
    # FIXME:
    # initialScript = pkgs.writeText "mysql-init" ''
    #   ALTER USER 'mtr'@'localhost' IDENTIFIED BY '5AWcf.0=IR!1';
    #
    #   -- Keep root with unix socket authentication for admin convenience
    #   -- ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket;
    #   ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
    #
    #   FLUSH PRIVILEGES;
    # '';
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

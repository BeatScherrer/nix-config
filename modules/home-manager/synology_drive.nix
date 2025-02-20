{ pkgs, ... }:
{
  home.packages = with pkgs; [
    synology-drive-client
  ];

  systemd.user.services.synology-drive = {
    Unit = {
      Description = "Synology Cloud Sync";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      Environment = "PATH=/run/wrappers/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
      ExecStart = "${pkgs.synology-drive-client}/bin/synology-drive";
      RemainAfterExit = true;
    };

  };

}

{ pkgs, ... }:
{

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # NOTE: The default GID is 100, which proved to be troublesome when
  # using systemd-nspawn! (cannot bind the user without a private user group)
  users = {
    users.beat = {
      isNormalUser = true;
      description = "Beat Scherrer";
      group = "beat";
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
      ];
    };
    groups = {
      beat = {
        members = [ "beat" ];
        gid = 1000;
      };
    };
    defaultUserShell = pkgs.bash;
  };
}

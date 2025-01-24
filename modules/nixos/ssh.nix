{ config, pkgs, ... }:
{
  # WARN: vnc does not find an appropriate Xsession
  # environment.systemPackages = with pkgs; [
  #   tigervnc
  #   xorg.xinit
  # ];

  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.herbstluftwm}/bin/herbstluftwm --locked &";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
}

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    herbstluftwm
    xorg.xev
    gnome.gnome-keyring
    gnome-online-accounts
    gnome.gvfs
    dbus
    blueman
  ];

  services.xserver = {
    resolutions = [
      {
        x = 7680;
        y = 2160;
      }
    ];

    dpi = 140;
    #upscaleDefaultCursor = true;

    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "compose:ralt";

    displayManager = {
      gdm = {
        enable = true;
      };
      session = [
        {
          manage = "desktop";
          name = "herbstluft";
          start = ''
            ${pkgs.herbstluftwm}/bin/herbstluftwm --locked &
            waitPID=$!
          '';
        }
      ];
    };
  };

  services.displayManager.defaultSession = "herbstluft";

  services.gnome = {
    gnome-keyring.enable = true;
    gnome-settings-daemon.enable = true;
    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;
  };
  services.gvfs.enable = true; # required for smb
  services.blueman.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;
}

{config, pkgs, ...}:
{
  services.xserver = {
    enable = true;
    displayManager = {
      sddm = {
        enable = true;
        theme = "${import ../sddm-theme.nix { inherit pkgs; }}";
        enableHidpi = true;
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
      defaultSession = "herbstluft";
    };
  };

  environment.systemPackages = with pkgs; [
    herbstluftwm
    gnome.gnome-keyring
    gnome-online-accounts
    dbus
  ];

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}

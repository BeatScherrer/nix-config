{config, pkgs, ...}:

{
  services.xserver = {
    resolutions = [
      {
        x = 7680;
        y = 2160;
      }
    ];

    dpi = 140;
    upscaleDefaultCursor = true;

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
      defaultSession = "herbstluft";
    };
  };

  environment.systemPackages = with pkgs; [
    herbstluftwm
    xorg.xev
  ];
}

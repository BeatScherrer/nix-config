{config, pkgs, ...}:
{
  services.xserver = {
    dpi = 180;
    upscaleDefaultCursor = true;
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
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
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

}

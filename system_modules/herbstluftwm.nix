{config, pkgs, ...}:
{
  services.xserver = {
    enable = true;
    displayManager = {
      sddm.enable = true;
      sddm.theme = "${import ../sddm-theme.nix { inherit pkgs; }}";
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
}

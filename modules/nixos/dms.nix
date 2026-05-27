{
  config,
  lib,
  ...
}:
let
  cfg = config.dms;
in
{
  options.dms = {
    enable = lib.mkEnableOption "DankMaterialShell (dms-shell)";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.blueman.enable = true;
  };
}

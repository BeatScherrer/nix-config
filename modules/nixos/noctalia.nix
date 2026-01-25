{
  config,
  lib,
  ...
}:
let
  cfg = config.noctalia;
in
{
  options.noctalia = {
    enable = lib.mkEnableOption "noctalia";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}

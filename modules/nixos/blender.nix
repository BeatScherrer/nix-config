{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.blender;
in
{
  options.blender = {
    enable = mkEnableOption "blender";
    gpu = mkOption {
      type = types.enum [
        "none"
        "nvidia"
        "amd"
      ];
      default = "none";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    (lib.mkIf (cfg.gpu == "none") {
      environment.systemPackages = with pkgs; [
        blender
      ];
    })

    (lib.mkIf (cfg.gpu == "nvidia") {
      environment.systemPackages = with pkgs; [
        (blender.override {
          cudaSupport = true;
        })
      ];
    })

    (lib.mkIf (cfg.gpu == "amd") {
      environment.systemPackages = with pkgs; [
        blender-hip
      ];
    })
  ]);

}

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
        blender
        # (blender.override {
        #   cudaSupport = true;
        # })
      ];
    })

    (lib.mkIf (cfg.gpu == "amd") {
      # Scoped override rather than nixpkgs.config.rocmSupport: the global flag
      # flips rocmSupport on for every package that reads it, which drags
      # onnxruntime (and therefore rccl and the ROCm stack) out of the binary
      # cache — and with it librewolf-unwrapped, which depends on onnxruntime.
      environment.systemPackages = [
        (pkgs.blender.override { rocmSupport = true; })
      ];
    })
  ]);

}

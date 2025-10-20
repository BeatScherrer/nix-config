{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.davinci-resolve;
in
{

  options.davinci-resolve = {
    enable = mkEnableOption "davinci-resolve";
    gpu = mkOption {
      type = types.enum [
        "none"
        "nvidia"
        "amd"
      ];
      default = "none";
    };

  };

  # NOTE: https://wiki.nixos.org/wiki/DaVinci_Resolv

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        davinci-resolve
      ];
    }

    (mkIf (cfg.gpu == "none") {
    })

    (mkIf (cfg.gpu == "amd") {
      environment.variables = {
        RUSTICL_ENABLE = "radeonsi";
      };
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa.opencl
        ];
      };
    })

    (mkIf (cfg.gpu == "nvidia") {
      # No special config whatsoever
    })

  ]);
}

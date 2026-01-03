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

  # NOTE: https://wiki.nixos.org/wiki/DaVinci_Resolve

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        davinci-resolve
      ];

      # Enable the convert-for-resolve script
      scripts.convert-for-resolve.enable = true;
    }

    (mkIf (cfg.gpu == "none") {
    })

    (mkIf (cfg.gpu == "amd") {
      hardware = {
        graphics = {
          enable = true;
        };
        amdgpu.opencl.enable = true;
      };
    })

    (mkIf (cfg.gpu == "nvidia") {
      # No special config whatsoever
    })

  ]);
}

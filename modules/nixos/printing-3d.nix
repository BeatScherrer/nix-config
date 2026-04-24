{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.printing-3d;
in
{
  options.printing-3d = {
    enable = mkEnableOption "3D printing and modeling tools";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.permittedInsecurePackages = [
      "snapmaker-luban-4.15.0"
    ];

    environment.systemPackages = with pkgs; [
      orca-slicer
      snapmaker-luban
      freecad
      blender
    ];
  };
}

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
    # snapmaker-luban is marked insecure; its permit lives in the common
    # nixpkgs.config.permittedInsecurePackages list in modules/nixos/default.nix
    # (nixpkgs.config is shallow-merged, so it must be set in one place).

    environment.systemPackages = with pkgs; [
      orca-slicer
      snapmaker-luban
      freecad
      blender
    ];
  };
}

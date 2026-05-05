{ config, lib, pkgs, ... }:
let
  cfg = config.programs.mtr-git;
in
{
  options.programs.mtr-git = {
    enable = lib.mkEnableOption "mtr robot workspace git config";

    email = lib.mkOption {
      type = lib.types.str;
      default = "b.scherrer@mt-robot.com";
      description = "Git email for all mtr robot workspace repositories";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the mtrrobot-specific git config file
    home.file.".gitconfig-mtrobot" = {
      text = ''
        [user]
          email = "${cfg.email}"
      '';
    };

    # Add includeIf to main git config for workspace
    programs.git.extraConfig = ''
      [includeIf "gitdir:/home/beat/src/mtrobot/"]
        path = ${config.home.homeDirectory}/.gitconfig-mtrobot
    '';
  };
}

{ ... }:
{
  security.sudo.extraConfig = ''
    # This allows running arbitrary commands, but so does ALL, and it means
    # different sudoers have their choice of editor respected.
    Defaults:%sudo env_keep += "EDITOR"
    Defaults:%sudo env_keep += "SYSTEMD_EDITOR"
  '';

  # Passwordless sudo for the mtrsys sim-container smoketest + diagnostics, on
  # every NixOS host (this module is pulled in by modules/nixos/default.nix).
  # Claude Code runs as `beat` with no controlling tty, so plain `sudo` can't
  # prompt for a password (FIDO/U2F touch); this lets `just smoketest` and the
  # mtr-sim-container-{smoketest,diagnose} skills create/enter/tear down the
  # nspawn sim containers hands-free.
  # Caveat: `nixos-container run <name> -- <cmd>` runs arbitrary commands as
  # root inside the container, so this is effectively broad root for these two
  # bins — accepted on these personal dev boxes.
  security.sudo.extraRules = [
    {
      users = [ "beat" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-container";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/machinectl";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

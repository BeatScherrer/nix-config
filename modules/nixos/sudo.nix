{ ... }:
{
  security.sudo.extraConfig = ''
    # This allows running arbitrary commands, but so does ALL, and it means
    # different sudoers have their choice of editor respected.
    Defaults:%sudo env_keep += "EDITOR"
    Defaults:%sudo env_keep += "SYSTEMD_EDITOR"
  '';
}

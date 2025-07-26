{ config, ... }:
{
  # FIXME: the resulting ~/.ssh/config ownership gets mapped to nobody:nobody in distrobox...
  # ssh
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
  };
}

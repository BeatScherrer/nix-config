{ config, ... }:
{
  # FIXME: the resulting ~/.ssh/config ownership gets mapped to nobody:nobody in distrobox...
  # ssh
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
}

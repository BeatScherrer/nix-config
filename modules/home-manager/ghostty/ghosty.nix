{ config, ... }:
{
  home.file.".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink ./config;
}

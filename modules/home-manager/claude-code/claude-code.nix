{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    claude-code-acp
  ];
}

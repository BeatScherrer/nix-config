{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  imports = [
    ../../claude-code/claude-code.nix
    ../../opencode/opencode.nix
  ];

  home.packages = with pkgs; [
    pkgs-stable.mysql-workbench
    remmina
    freecad
    # kdePackages.kdenlive # FIXME:
    tigervnc
    unrar-free
    _1password-gui
  ];

  # FIXME: the resulting ~/.ssh/config ownership gets mapped to nobody:nobody in distrobox...
  # ssh
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
    matchBlocks."*" = { };
  };

  home.file.".ssh/config.d/mtr".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/mtr/mtr.ssh";

  home.file.".claude/commands/mtr-diagnose.md".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/mtr/mtr-diagnose.md";

  # MTR-specific git identity for all repos under ~/src/mtrobot.
  # Uses git's includeIf with a gitdir prefix match — this automatically
  # covers every repository at any depth under that directory.
  programs.git.includes = [
    {
      condition = "gitdir:${config.home.homeDirectory}/src/mtrobot/";
      contents = {
        user.email = "b.scherrer@mt-robot.com";
      };
    }
  ];
}

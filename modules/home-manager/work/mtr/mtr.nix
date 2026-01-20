{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  imports = [
    ../../claude-code/claude-code.nix
  ];

  home.packages = with pkgs; [
    pkgs-stable.mysql-workbench
    remmina
    # freecad # FIXME:
    kdePackages.kdenlive
    # tigervnc # FIXME:
    unrar-free
    _1password-gui
  ];

  # FIXME: the resulting ~/.ssh/config ownership gets mapped to nobody:nobody in distrobox...
  # ssh
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.ssh/config.d/*
    '';
  };

  home.file.".ssh/config.d/mtr".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/work/mtr/mtr.ssh";
}

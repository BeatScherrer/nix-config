{ config, pkgs, inputs, modulesPath, ... }:

let
in
{
  imports = [
    # inputs.nix-colors.homeManagerModules.default
    ./modules/alacritty.nix
    ./modules/sh.nix
    ./modules/git.nix
    ./modules/herbstluftwm/herbstluftwm.nix
    ./modules/color-scheme/color-scheme.nix
    ./modules/games/games.nix
    # ./modules/hyprland/hyprland.nix
  ];

  # colorScheme = colorScheme;
  colorScheme = {
    enable = true;
    name = "gravel-pit";
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "beat";
  home.homeDirectory = "/home/beat";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # colorScheme = inputs.nix-colors.colorSchemes.everforest;

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neofetch
    localsend
    telegram-desktop
    signal-desktop
    slack
    zulip
    vscode-fhs
    helix
    bc

    # archives
    zip
    unzip

    # cli utils
    fzf
    ripgrep
    jq
    lazygit
    tldr

    # monitoring
    btop
    iotop
    iftop

    # periphery
    rofi-bluetooth

    # TODO:
    # node stuff
    # nodePackages.angular;

    # basic gui tools
    dbus
    gnome.nautilus
    gnome.gnome-calendar
    gnome.seahorse
    gnome.gnome-calculator
    evolution
    okular
    firefox
    pavucontrol
    font-manager
    blueman
    pika-backup
    libreoffice
    inkscape
    obsidian

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.pointerCursor = {
    name = "Nordic-cursors";
    package = pkgs.nordic;
    size = 32;
    #gtk.enable = true;
    #x11.enable = true;
  };

  gtk.enable = true;
  gtk.theme.package = pkgs.nordic;
  gtk.theme.name = "Nordic-darker";

  gtk.iconTheme.package = pkgs.nordic;
  gtk.iconTheme.name = "Nordic-green";

  gtk.cursorTheme = {
    name = "Nordic-cursors";
    package = pkgs.nordic;
  };

  qt.enable = true;
  qt.platformTheme = "qtct";
  qt.style.name = "kvantum";
  # qt.style.package = pkgs.adwaita-qt;
}

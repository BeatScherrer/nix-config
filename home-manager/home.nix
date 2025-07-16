{ pkgs, lib, ... }:
let
  customFonts = pkgs.callPackage ../modules/home-manager/fonts/fonts.nix { };
in
{
  imports = [
    # inputs.nix-colors.homeManagerModules.default
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/ghostty/ghosty.nix

    ../modules/home-manager/git/git.nix
    ../modules/home-manager/herbstluftwm/herbstluftwm.nix
    ../modules/home-manager/color-scheme/color-scheme.nix
    ../modules/home-manager/games/games.nix
    ../modules/home-manager/shell/shell.nix
    ../modules/home-manager/wallpapers/wallpapers.nix
    ../modules/home-manager/avatars/avatars.nix
    ../modules/home-manager/hyprland/hyprland.nix
    ../modules/home-manager/work/mtr.nix
    ../modules/home-manager/scripts/scripts.nix
    # FIXME:
    # ../modules/home-manager/music_production/music_production.nix
    ../modules/home-manager/synology_drive.nix
    ../modules/home-manager/zellij/zellij.nix
    # FIXME: duplicate option definitions
    # ../modules/home-manager/gnome.nix
  ];

  colorScheme = {
    enable = true;
    name = "gravel-pit";
  };
  # colorScheme = inputs.nix-colors.colorSchemes.everforest;

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
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neofetch
    localsend
    # Messengers
    telegram-desktop
    signal-desktop-bin
    whatsapp-for-linux
    discord
    element-desktop
    slack
    zulip
    # threema-desktop

    spotify

    # Code editors
    helix

    # Compilers / Languages
    gcc
    zig

    # cli utils
    bc
    nmap
    zip
    unzip
    fzf
    ripgrep
    jq
    lazygit
    tldr
    just
    killall
    yt-dlp
    btop
    iotop
    iftop

    # LSP and formatters
    stylua
    lua-language-server
    nixd
    nixfmt-rfc-style
    shfmt
    codespell
    markdownlint-cli
    nodePackages.jsonlint
    biome
    lemminx
    dockerfile-language-server-nodejs
    hadolint
    taplo
    tailwindcss-language-server
    vale
    docker-language-server

    # periphery
    rofi-bluetooth

    # basic GUI tools
    dbus
    nautilus
    gnome-calendar
    seahorse
    gnome-calculator
    gnome-clocks
    thunderbird
    kdePackages.okular
    librewolf
    chromium
    google-chrome
    pavucontrol
    flameshot
    bitwarden-desktop
    obs-studio
    evince
    loupe
    masterpdfeditor

    # font-manager
    pika-backup
    customFonts
    fontconfig
    libreoffice
    inkscape
    gimp
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

  home.file = { };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.pointerCursor = {
    name = "Nordic-cursors";
    package = pkgs.nordic;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
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
  qt.platformTheme.name = "qtct";
  qt.style.name = "kvantum";
  # qt.style.package = pkgs.adwaita-qt;
}

{ config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neofetch
    localsend

    # archives
    zip
    unzip

    # utils
    fzf
    ripgrep
    jq
    lazygit

    # monitoring
    btop
    iotop
    iftop

    # TODO:
    # node stuff
    # nodePackages.angular;

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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/beat/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  gtk.enable = true;
  gtk.cursorTheme.package = pkgs.bibata-cursors;
  gtk.cursorTheme.name = "Bibata-Modern-Ice";

  gtk.theme.package = pkgs.nordic;
  gtk.theme.name = "Nordic";

  gtk.iconTheme.package = pkgs.nordic;
  gtk.iconTheme.name = "Nordic-green";


  qt.enable = true;
  qt.platformTheme = "gtk";
  qt.style.name = "Nordic";
  qt.style.package = pkgs.nordic;

  programs.git = {
      enable = true;
      userName = "BeatScherrer";
      userEmail = "beat.scherrer@gmail.com";
      aliases = {
        co = "checkout";
        ci = "commit";
        st = "status -s";
        br = "branch";
        pl = "pull";
        pa = "pull --recurse-submodules";
        fa = "fetch --all";
        cs = "clone --recursive -b";
        lg = "log -20 --oneline --abbrev-commit --pretty=format:\"%h %ad | %s%d [%an]\" --date=short";
        hist = "log -20 --graph --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        type = "cat-file -t";
        dump = "cat-file -p";
        subup = "submodule update --init --recursive";
        last = "log -1 HEAD";
        unstage = "reset HEAD --";
        mh = "merge -Xignore-space-change -Xrename-threshold=25";
        unpushed = "log --branches --not --remotes --no-walk --decorate --oneline";
      };
      extraConfig = {
        core = {
          editor = "vim";
          hooksPath = "~/.git_hooks";
        };
        merge = {
          tool = "vimdiff";
        };
        mergetool = {
          prompt = false;
          keepBackup = false;
          vimdiff = {
            cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
          };
        };
      };
  };

  # TODO: Use color scheme for alacritty coloring
  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "None";
      font = {
        size = 12;
        normal = {
          family = "JetBrainsMonoNL Nerd Font";
          style = "Light";
        };
      };
      colors = with config.colorScheme.colors; {
        primary = {
          background = "#1d1f21";
          bright_foreground = "#eaeaea";
          dim_foreground = "#828482";
          foreground = "#c5c8c6";
        };
        normal = {
          black = "#282a2e";
          blue = "#5f819d";
          cyan = "#5e8d87";
          green = "#8c9440";
          magenta = "#85678f";
          red = "#a54242";
          white = "#707880";
          yellow = "#de935f";
        };
        bright = {
          black = "#555b65";
          blue = "#81a2be";
          cyan = "#8abeb7";
          green = "#b5bd68";
          magenta = "#b294bb";
          red = "#cc6666";
          white = "#c5c8c6";
          yellow = "#ffeac3";
        };
        cursor = {
          cursor = "CellForeground";
          text = "CellBackground";
        };
      };
    };
  };
}

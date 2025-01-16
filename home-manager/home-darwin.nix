{ pkgs, config, ... }: {
  imports = [
    # inputs.nix-colors.homeManagerModules.default
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/ghostty/ghosty.nix

    ../modules/home-manager/git.nix
    ../modules/home-manager/color-scheme/color-scheme.nix
    # ../modules/home-manager/games/games.nix
    ../modules/home-manager/shell/shell.nix
    ../modules/home-manager/wallpapers/wallpapers.nix
    ../modules/home-manager/avatars/avatars.nix
    ../modules/home-manager/zellij/zellij.nix
  ];

  colorScheme = {
    enable = true;
    name = "gravel-pit";
  };
  # colorScheme = inputs.nix-colors.colorSchemes.everforest;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "beat";

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

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # productivity
    # synology-drive-client
    #
    neofetch
    # # LSP and formatters
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

    # thunderbird
    # firefox

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

  home.sessionVariables = { EDITOR = "nvim"; };
}

{ pkgs, config, ... }:
let
  kanagawa-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "kanagawa";
    publisher = "qufiwefefwoyn";
    version = "1.5.1";
    sha256 = "sha256-AGGioXcK/fjPaFaWk2jqLxovUNR59gwpotcSpGNbj1c=";
  };
  angular-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "ng-template";
    publisher = "Angular";
    version = "20.0.0";
    sha256 = "sha256-87SImzcGbwvf9xtdbD3etqaWe6fMVeCKc+f8qTyFnUA=";
  };
  csdevkit-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "1.20.4";
    sha256 = "sha256-N+p/n427yYzYaIBk3xtoLzItJAE1HsfS0xMQOI3Owa0=";
  };
  biome-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "biome";
    publisher = "biomejs";
    version = "2025.5.40952";
    sha256 = "sha256-km5+KnfNI1QwZ5ao7jaBdvzeiepUHmFa4rMFvmH78aw=";
  };
  vim-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vim";
    publisher = "vscodevim";
    version = "1.29.1";
    sha256 = "sha256-KH/NECEAk3u+LjUov1SJx2O9c+566ABadc2S0KY9/I0=";
  };
  clangd-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-clangd";
    publisher = "llvm-vs-code-extensions";
    version = "0.1.34";
    sha256 = "sha256-aid2m33HNVa27SUjdUQMxuNSTU38Tbh6m3z/S5Hd83A=";
  };
  playwright-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "playwright";
    publisher = "ms-playwright";
    version = "1.1.14";
    sha256 = "sha256-OhXpqP5PX/E2125MZQVOz+kdJybh0D6DV202HL5gjO0=";
  };

in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        usernamehw.errorlens
        kanagawa-vscode
        angular-vscode
        csdevkit-vscode
        biome-vscode
        vim-vscode
        clangd-vscode
        playwright-vscode
        redhat.vscode-xml
      ];

      # NOTE: Do not use the nix declarative config so the config can still be adjusted from inside vscode...
    };
  };

  home.file.".config/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/vscode/settings/user_settings.json";
  home.file.".config/Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/vscode/settings/keybindings.json";
}

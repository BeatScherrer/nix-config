{ pkgs, ... }:
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
    extensions = with pkgs.vscode-extensions; [
      angular-vscode
      kanagawa-vscode
      csdevkit-vscode
      biome-vscode
      vim-vscode
      clangd-vscode
      playwright-vscode
      dracula-theme.theme-dracula
    ];
    userSettings = {
      "workbench.colorTheme" = "Kanagawa";
      "editor.fontSize" = 13;
      "editor.fontFamily" = "'Iosevka Nerd Font','JetBrains Mono'";
      "editor.fontLigatures" = true;
      "terminal.integrated.fontFamily" = "'Iosevka Nerd Font', 'JetBrains Mono'";
      "terminal.integrated.fontSize" = 13;
    };
  };
}

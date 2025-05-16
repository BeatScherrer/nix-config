{ pkgs, ... }:
let
  kanagawa-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "kanagawa";
    publisher = "qufiwefefwoyn";
    version = "1.5.1";
    sha256 = "sha256-AGGioXcK/fjPaFaWk2jqLxovUNR59gwpotcSpGNbj1c=";
  };
  angular-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "Angular Language Service";
    publisher = "ng-template";
    version = "20.0.0";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  cs-dev-kit = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "csdevkit";
    publisher = "ms-dotnettools";
    version = "1.20.4";
    sha256 = "sha256-0000000000000000000000000000000000000000000=";
  };
in
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = [
        angular-vscode
        kanagawa-vscode
      ];
    })
  ];
}

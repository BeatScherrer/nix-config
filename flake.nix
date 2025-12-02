# NOTE:
# - update all inputs: `nix flake update`
# - update single input: `nix flake lock --update-input nixpkgs`
# -

{
  description = "Nixos config flake";

  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixos-hardware.url = "path:/home/beat/src/nixos-hardware";
    # nixpkgs.url = "path:/home/beat/src/nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cursor = {
      url = "github:omarcresp/cursor-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixos-hardware,
      nixpkgs,
      home-manager,
      nixos-cosmic,
      rust-overlay,
      darwin,
      nixgl,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      ghostty,
      claude-desktop,
      cursor,
      lanzaboote,
      quickshell,
      ...
    }@inputs:
    let
      user = "beat";
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # helper to call a function for each system
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      # overlay for flake packages
      flakePackagesOverlay = system: final: prev: {
        ghostty = ghostty.packages.${system}.default;
        claude-desktop = claude-desktop.packages.${system}.default;
        cursor = cursor.packages.${system}.default;
        quickshell = quickshell.packages.${system}.default;
      };
      # helper to call the dev shell for each system
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                nixd
                nixfmt-rfc-style
                neovim
                git
              ];
              shellHook = ''
                export EDITOR=nvim
              '';
            };
        };
    in
    {
      nixosConfigurations = {
        trident = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/trident/configuration.nix
            nixos-cosmic.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./hosts/trident/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            lanzaboote.nixosModules.lanzaboote
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                (flakePackagesOverlay "x86_64-linux")
              ];
            }
          ];
        };
        legion = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/legion/configuration.nix
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [
                  "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                ];
              };
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./hosts/legion/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                (flakePackagesOverlay "x86_64-linux")
              ];
            }
            nixos-cosmic.nixosModules.default
          ];
        };
        proart = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            nixos-hardware.nixosModules.asus-px13
            ./hosts/proart/configuration.nix
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [
                  "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                ];
              };
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./hosts/proart/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                (flakePackagesOverlay "x86_64-linux")
              ];
            }
            nixos-cosmic.nixosModules.default
          ];
        };
      };

      darwinConfigurations = {
        obsidian = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/obsidian/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./home-manager/home-darwin.nix;
              home-manager.backupFileExtension = "backup";
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                enableRosetta = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
              };
            }
          ];
        };
      };

      devShells = forAllSystems devShell;
    };
}

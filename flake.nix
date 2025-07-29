# NOTE:
# - update all inputs: `nix flake update`
# - update single input: `nix flake lock --update-input nixpkgs`
# -

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cursor = {
      url = "github:omarcresp/cursor-flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
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
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/trident/configuration.nix
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [
                  "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                ];
              };
            }
            nixos-cosmic.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./hosts/trident/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            (
              { ... }:
              {
                nixpkgs.overlays = [
                  rust-overlay.overlays.default
                  # ghostty.packages.${system}.default
                ];
              }
            )
            (
              { config, ... }:
              let
                gitRev =
                  if self ? rev then
                    builtins.substring 0 7 self.rev
                  else if self ? dirtyShortRev then
                    self.dirtyShortRev
                  else
                    "unknown";
              in
              {
                system.nixos.label =
                  (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
                  + config.system.nixos.version
                  + "-SHA:${gitRev}";
              }
            )
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
            nixos-cosmic.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${user} = import ./hosts/legion/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              }
            )
            (
              { config, ... }:
              let
                gitRev =
                  if self ? rev then
                    builtins.substring 0 7 self.rev
                  else if self ? dirtyShortRev then
                    self.dirtyShortRev
                  else
                    "unknown";
              in
              {
                system.nixos.label =
                  (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
                  + config.system.nixos.version
                  + "-SHA:${gitRev}";
              }
            )
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

      # TODO: how to use the provided nixpkgs?
      # homeConfigurations = {
      #   ${user} = home-manager.lib.homeManagerConfiguration {
      #     pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      #     modules = [ ./home-manager/home.nix ];
      #     extraSpecialArgs = { inherit inputs user; };
      #   };
      # };

      devShells = forAllSystems devShell;
    };
}

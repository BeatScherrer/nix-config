# NOTE:
# - update all inputs: `nix flake update`
# - update single input: `nix flake lock --update-input nixpkgs`
# -

{
  description = "Nixos config flake";

  inputs = {
    nixos-hardware.url = "github:BeatScherrer/nixos-hardware/master";
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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
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
      lanzaboote,
      quickshell,
      noctalia,
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
      # Desktop environment enum
      desktopEnv = {
        none = "none";
        herbstluftwm = "herbstluftwm";
        gnome = "gnome";
        niri = "niri";
        hyprland = "hyprland";
        hyprland-noctalia = "hyprland-noctalia";
      };
      # helper to call a function for each system
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      # overlay for flake packages
      flakePackagesOverlay = system: final: prev: {
        ghostty = ghostty.packages.${system}.default;
        claude-desktop = claude-desktop.packages.${system}.default;
        quickshell = quickshell.packages.${system}.default;
        noctalia-shell = noctalia.packages.${system}.default;
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
                nixfmt
                neovim
                git
              ];
              shellHook = ''
                export EDITOR=nvim
              '';
            };
        };

      # helper to create NixOS host configurations
      mkHost =
        {
          name,
          system ? "x86_64-linux",
          desktop ? desktopEnv.none,
          extraModules ? [ ],
        }:
        let
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              user
              pkgs-stable
              desktop
              ;
          };
          modules = [
            ./hosts/${name}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  user
                  pkgs-stable
                  desktop
                  ;
              };
              home-manager.users.${user} = import ./hosts/${name}/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
                (flakePackagesOverlay system)
              ];
            }
          ]
          ++ extraModules;
        };

      # cachix config for cosmic desktop
      cosmicCachix = {
        nix.settings = {
          substituters = [ "https://cosmic.cachix.org/" ];
          trusted-public-keys = [
            "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          ];
        };
      };
    in
    {
      nixosConfigurations = {
        trident = mkHost {
          name = "trident";
          desktop = desktopEnv.herbstluftwm;
          extraModules = [
            nixos-cosmic.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        legion = mkHost {
          name = "legion";
          desktop = desktopEnv.herbstluftwm;
          extraModules = [
            cosmicCachix
            nixos-cosmic.nixosModules.default
          ];
        };

        T14 = mkHost {
          name = "T14";
          desktop = desktopEnv.niri;
          extraModules = [
            # NOTE: There is no gen6 t14 module yet
            # nixos-hardware.nixosModules.lenovo.thinkpad.t14.amd.gen5
          ];
        };

        proart = mkHost {
          name = "proart";
          desktop = desktopEnv.gnome;
          extraModules = [
            nixos-hardware.nixosModules.asus-px13
            cosmicCachix
            nixos-cosmic.nixosModules.default
          ];
        };
      };

      darwinConfigurations = {
        obsidian = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/obsidian/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
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

      # Expose home-manager modules for use in other flakes
      homeManagerModules = {
        shell = ./modules/home-manager/shell/shell.nix;
      };
    };
}

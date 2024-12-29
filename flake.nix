# TODO: add nix darwin to this somehow
# - do not import pkgs for x86
# - 
# Resources: https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    debootstrapPin.url = "github:nixos/nixpkgs/9d757ec498666cc1dcc6f2be26db4fd3e1e9ab37";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-cosmic,
      rust-overlay,
      darwin,
      ...
    }@inputs:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux"];
      darwinSystems = [ "aarch64-darwin" ];
    in
    {
      # NOTE: nix uses the hostname entry by default
      nixosConfigurations = {
        smolboi = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/smolboi/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        P1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/P1/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        trident = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
              };
            }
            nixos-cosmic.nixosModules.default
            inputs.home-manager.nixosModules.default
            ./hosts/trident/configuration.nix
            ({ pkgs, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              }
            )
          ];
        };
      };

      # TODO: add macbook config
      darwinConfigurations = {
        obsidian = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
        inherit inputs;
      };
          modules = [
            ./hosts/obsidian/configuration.nix
      ];

        };
      };

      # NOTE: home manager uses the user name entry by default
      homeConfigurations = {
        beat = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [ ./home-manager/home.nix ];
        };
      };

      # TODO: make this system agnostic?
      # devShell = pkgs.mkShell {
      #   buildInputs = with pkgs; [
      #     nixd
      #     nixfmt
      #   ];
      # };
    };
}

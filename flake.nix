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
    # -- Local Overlays --
    # schroot.url = "path:/home/beat/.nix/modules/overlays/schroot";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # overlays = [ schroot.overlay ]; # NOTE: if eventually the schroot overlay works...
      };
    in
    {
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
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/P1/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        trident = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/trident/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
      };

      homeConfigurations = {
        beat = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [ ./home-manager/home.nix ];
        };
      };

        devShell = pkgs.mkShell {
          buildInputs =
            with pkgs;
            dependencies
            ++ [
              nixd
              nixfmt
            ];
        };
    };
}

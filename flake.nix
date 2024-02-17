{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      nixosConfigurations ={
        # NOTE: the "nixos" key corresponds to the hostname
        nixos = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./configuration.nix
              inputs.home-manager.nixosModules.default
            ];
          };
        };

        homeConfigurations = {
          beat = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./home.nix ];
            };
        };

    };
}

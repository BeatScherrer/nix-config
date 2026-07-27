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
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      # NOTE: don't follow our nixpkgs — upstream still references the removed
      # `pkgs.nodePackages.asar` (removed from nixpkgs 2026-03-03). Let it use
      # its own pinned nixpkgs until upstream migrates to `pkgs.asar`.
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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
    dank-material-shell = {
      # Our DankMaterialShell fork (Codeberg). nixpkgs' dms-shell is pinned
      # old (1.4.6) and lacks the compositor-agnostic wlr-output-management
      # apply path, so DMS can't set gpwm's mode/scale. Our fork picks up the
      # newer wlr path (and lets us patch it). Local dev checkout for
      # iteration:
      #   url = "git+file:///home/beat/src/beat/DankMaterialShell";
      # https, not ssh: `sudo nixos-rebuild` fetches inputs as root, which has
      # no Codeberg key.
      url = "git+https://codeberg.org/Stencill/DankMaterialShell.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gpwm = {
      # Local dev checkout. Revert to the Codeberg remote for deploys
      # (https, not ssh — `sudo nixos-rebuild` fetches inputs as root):
      #   url = "git+https://codeberg.org/Stencill/GPWM.git";
      url = "git+file:///home/beat/src/beat/gpwm";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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
      claude-desktop,
      lanzaboote,
      quickshell,
      noctalia,
      dank-material-shell,
      gpwm,
      llm-agents,
      sops-nix,
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
        mango = "mango";
        hyprland = "hyprland";
        hyprland-noctalia = "hyprland-noctalia";
        gpwm = "gpwm";
      };
      # helper to call a function for each system
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      # overlay for flake packages
      flakePackagesOverlay = system: final: prev: {
        claude-desktop = claude-desktop.packages.${system}.default;
        quickshell = quickshell.packages.${system}.default;
        noctalia-shell = noctalia.packages.${system}.default;
        # Override nixpkgs' (old, 1.4.6) dms-shell with our fork's build so
        # DMS speaks the compositor-agnostic wlr-output-management apply path
        # and can set gpwm's mode/scale. Every pkgs.dms-shell consumer (the
        # home module, the dms.service ExecStart) picks this up.
        dms-shell = dank-material-shell.packages.${system}.dms-shell;
        gpwm = gpwm.packages.${system}.default;
        # openldap's test017-syncreplication-refresh is timing-flaky (it
        # relies on fixed sleeps and fails under build-machine load / newer
        # kernels). Disable the check phase. Remove if nixpkgs ships a
        # cached openldap again.
        openldap = prev.openldap.overrideAttrs (_: {
          doCheck = false;
        });
        # nixos-unstable shipped hyprland 0.55.1 but hyprlandPlugins.hy3 is
        # still 0.54.2.1, which fails to build against the new CBox/Vector2D
        # API (nixpkgs#475993). Pin hy3 to upstream tag hl0.55.0 (compatible
        # with hyprland 0.55.1) until nixpkgs catches up; then remove this.
        hyprlandPlugins = prev.hyprlandPlugins // {
          hy3 = prev.hyprlandPlugins.hy3.overrideAttrs (_: {
            version = "0.55.0";
            src = final.fetchFromGitHub {
              owner = "outfoxxed";
              repo = "hy3";
              rev = "a7282db2d7ca336d3c9faa5d10d75fc43eed37aa";
              hash = "sha256-P3wwiIfqo89evW7xzI+wOI/qM1WPZBiiSmGNtBmYeVk=";
            };
          });
        };
        # zeroclaw = llm-agents.packages.${system}.zeroclaw.overrideAttrs (old: {
        #   cargoBuildFeatures = (old.cargoBuildFeatures or [ ]) ++ [ "channel-matrix" ];
        #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.jq ];
        #   # The deep matrix-sdk async types overflow rustc's default
        #   # recursion limit. recursion_limit is per-crate, so it must be set
        #   # on every crate that hits the overflow: the vendored matrix-sdk
        #   # crate root (below, in preBuild) AND zeroclaw's own
        #   # zeroclaw-channels crate, whose src/matrix.rs instantiates those
        #   # types. Remove once numtide/llm-agents.nix ships a matrix-sdk that
        #   # compiles without bumping the limit.
        #   postPatch = (old.postPatch or "") + ''
        #     libFile=crates/zeroclaw-channels/src/lib.rs
        #     if [ -f "$libFile" ] && ! grep -q 'recursion_limit' "$libFile"; then
        #       sed -i '1i #![recursion_limit = "1024"]' "$libFile"
        #     fi
        #   '';
        #   preBuild = (old.preBuild or "") + ''
        #     vendorDir=$(find "$NIX_BUILD_TOP" -maxdepth 3 -type d -name 'matrix-sdk-0.*' | head -n1)
        #     if [ -z "$vendorDir" ]; then
        #       echo "matrix-sdk vendor dir not found under $NIX_BUILD_TOP" >&2
        #       exit 1
        #     fi
        #     libFile="$vendorDir/src/lib.rs"
        #     if ! grep -q 'recursion_limit' "$libFile"; then
        #       sed -i '1i #![recursion_limit = "512"]' "$libFile"
        #       newHash=$(sha256sum "$libFile" | awk '{print $1}')
        #       jq --arg h "$newHash" '.files["src/lib.rs"] = $h' \
        #         "$vendorDir/.cargo-checksum.json" > "$vendorDir/.cargo-checksum.json.new"
        #       mv "$vendorDir/.cargo-checksum.json.new" "$vendorDir/.cargo-checksum.json"
        #     fi
        #   '';
        # });
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
              home-manager.backupCommand = ''
                ${nixpkgs.legacyPackages.${system}.coreutils}/bin/mv "$1" "$1.backup-$(${
                  nixpkgs.legacyPackages.${system}.coreutils
                }/bin/date +%Y%m%d%H%M%S)"
              '';
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
          desktop = desktopEnv.gpwm;
          extraModules = [
            nixos-cosmic.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
          ];
        };

        legion = mkHost {
          name = "legion";
          desktop = desktopEnv.gpwm;
          extraModules = [
            cosmicCachix
            nixos-cosmic.nixosModules.default
          ];
        };

        T14 = mkHost {
          name = "T14";
          desktop = desktopEnv.gpwm;
          extraModules = [
            # NOTE: There is no gen6 t14 module yet
            # nixos-hardware.nixosModules.lenovo.thinkpad.t14.amd.gen5
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
              home-manager.backupCommand = ''
                ${nixpkgs.legacyPackages.aarch64-darwin.coreutils}/bin/mv "$1" "$1.backup-$(${nixpkgs.legacyPackages.aarch64-darwin.coreutils}/bin/date +%Y%m%d%H%M%S)"
              '';
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

      checks.x86_64-linux =
        let
          evalCfg = name: self.nixosConfigurations.${name}.config.system.build.toplevel;
        in
        {
          trident = evalCfg "trident";
          legion = evalCfg "legion";
          T14 = evalCfg "T14";
        };

      # Expose home-manager modules for use in other flakes
      homeManagerModules = {
        shell = ./modules/home-manager/shell/shell.nix;
      };
    };
}

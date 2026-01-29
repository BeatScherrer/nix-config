{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.localCache;
in
{
  options.localCache = {
    enable = mkEnableOption "local Harmonia binary cache substituter";

    url = mkOption {
      type = types.str;
      default = "http://trident.home:5000";
      description = "URL of the home Harmonia binary cache server";
    };

    publicKey = mkOption {
      type = types.str;
      default = "trident-1:U1gVAQMpday/VYNZeae96iBtuI7+3tX6tE5KKeYTk3Y=";
      description = "Public key for the local cache (from cache-pub-key.pem)";
    };
  };

  config = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Binary cache substituters
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://ros.cachix.org"
      ];

      # Local cache as fallback — won't block builds if unreachable
      extra-substituters = lib.optionals cfg.enable [ cfg.url ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      ]
      ++ lib.optionals (cfg.enable && cfg.publicKey != "") [ cfg.publicKey ];

      # Performance optimizations
      max-jobs = "auto";
      cores = 0;

      # Allow wheel group to use substituters
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # garbage collection
    # nix.gc.automatic = true;
    # nix.gc.dates = "daily";
    # nix.gc.options = "--delete-older-than +10";
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;

    # list all current system packages in /etc/current-system-packages
    environment.etc."current-system-packages".text =
      let
        packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
      formatted;
  };
}

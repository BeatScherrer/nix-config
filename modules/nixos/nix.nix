{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.localCache;
  probeFile = "/run/nix-local-cache.conf";
in
{
  options.localCache = {
    enable = mkEnableOption "local Harmonia binary cache substituter";

    url = mkOption {
      type = types.str;
      default = "http://trident.tail46608.ts.net:8080";
      description = "URL of the home Harmonia binary cache server";
    };

    publicKey = mkOption {
      type = types.str;
      default = "trident-1:U1gVAQMpday/VYNZeae96iBtuI7+3tX6tE5KKeYTk3Y=";
      description = "Public key for the local cache (from cache-pub-key.pem)";
    };
  };

  config = {
    # Pull from trident's Harmonia cache by default on every host (incl.
    # trident itself). Override per-host with `localCache.enable = false`.
    localCache.enable = lib.mkDefault true;

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

      # The local cache is *not* listed here. `extra-substituters` is plain
      # concatenation onto `substituters`, so an unreachable entry still
      # produces a stall plus a "unable to download" warning on every query.
      # It is injected at runtime instead, see nix-local-cache-probe below.
      connect-timeout = 1;

      # If a substituter promises a path but dies before delivering it (e.g.
      # the tailnet drops mid-rebuild), build locally instead of aborting.
      fallback = true;

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

    # Pull the local cache in only while it actually answers. `!include` is
    # the optional form — a missing file is skipped silently, so the cache is
    # absent until the first successful probe (and after every reboot, since
    # /run is a tmpfs). Read fresh by every client invocation; as a trusted
    # user your `substituters` are forwarded to the daemon, so no restart is
    # needed for a change to take effect.
    nix.extraOptions = lib.mkIf cfg.enable ''
      !include ${probeFile}
    '';

    systemd.services.nix-local-cache-probe = lib.mkIf cfg.enable {
      description = "Toggle the local Harmonia cache as a substituter based on reachability";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        if ${pkgs.curl}/bin/curl --fail --silent --connect-timeout 2 --max-time 5 \
             -o /dev/null ${lib.escapeShellArg "${cfg.url}/nix-cache-info"}; then
          printf 'extra-substituters = %s\n' ${lib.escapeShellArg cfg.url} > ${probeFile}.new
        else
          : > ${probeFile}.new
        fi
        # Rename so a concurrent rebuild never parses a half-written file.
        mv ${probeFile}.new ${probeFile}
      '';
    };

    systemd.timers.nix-local-cache-probe = lib.mkIf cfg.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15s";
        OnUnitInactiveSec = "2min";
        AccuracySec = "15s";
      };
    };

    # garbage collection: weekly `nh clean all` as root, mirroring the
    # home-manager user timer's policy (`--keep 10 --keep-since 7d`).
    systemd.services.nh-clean = {
      description = "nh clean all";
      serviceConfig.Type = "oneshot";
      script = "${pkgs.nh}/bin/nh clean all --keep 10 --keep-since 7d";
    };
    systemd.timers.nh-clean = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };

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

{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  # Static hosts entries for tailnet devices (since MagicDNS is disabled to
  # avoid clashing with the work/LAN DNS search domains).
  networking.hosts = {
    "100.69.61.47" = [ "trident.ts" "ollama.ts" ];
    "100.108.26.84" = [ "legion.ts" ];
    "100.112.174.21" = [ "mealie.ts" ];
    "100.116.226.66" = [ "wutangnas.ts" ];
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  systemd.user.services.tailscale-systray = {
    enable = true;
    description = "Tailscale system tray";
    serviceConfig = {
      ExecStart = ''${pkgs.bashInteractive}/bin/bash -i -c "${pkgs.tailscale-systray}/bin/tailscale-systray"'';
    };
    wantedBy = [ "graphical-session.target" ];
  };
}

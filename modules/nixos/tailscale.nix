{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

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
    wantedBy = [ "multi-user.target" ];
  };
}

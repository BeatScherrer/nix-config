{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.wireguard.enable = true;

  services.resolved.enable = true;
}

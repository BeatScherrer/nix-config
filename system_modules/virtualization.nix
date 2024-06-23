{ pkgs, ... }:
{

  # Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true; # required for windows wm TPM v2.0
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [ virtio-win ];

  users.users.beat.extraGroups = [
    "docker"
    "libvirtd"
  ];
}

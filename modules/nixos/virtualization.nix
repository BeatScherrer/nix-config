{ pkgs, ... }:
{
  virtualisation = {
    # containers
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # create a `docker` alias
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

    };

    # VM
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
        swtpm.enable = true;
      };
    };
  };

  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    quickemu
    distrobox
  ];

  users.users.beat.extraGroups = [ "libvirtd" ];
}

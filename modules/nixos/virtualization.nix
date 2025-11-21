{ pkgs, ... }:
{
  virtualisation = {
    # VM
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
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
    virtio-win
    win-spice
    quickemu
  ];

  users.users.beat.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}

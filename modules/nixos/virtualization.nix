{ pkgs, user, ... }:
{
  virtualisation = {
    # VM
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
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
    virtiofsd
    quickemu
  ];

  users.users.${user}.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}

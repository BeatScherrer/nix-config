{ pkgs, ... }: {
  virtualisation = {
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
  ];

  users.users.beat.extraGroups = [ "libvirtd" "kvm" ];
}

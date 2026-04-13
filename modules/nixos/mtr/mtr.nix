{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./mysql.nix
    ../blender.nix
  ];

  sops.secrets."smb-mtr" = {
    sopsFile = ../../../secrets/legion/smb-mtr.yaml;
    mode = "0400";
    owner = "root";
  };

  environment.systemPackages = with pkgs; [
    xmlstarlet
    libxml2
    bash-language-server
    neocmakelsp
    pyright
    ccache
    lldb
    dig
    steam-run
    appimage-run
    # Schroot deps
    schroot
    debootstrap
    pv
    # Packaging deps
    fakeroot
    # VirtualGL for remote 3D rendering
    virtualgl
    turbovnc
    wireshark
  ];

  # SMB auto-mount for //files.mt-robot.com/staff
  # Credentials live in secrets/legion/smb-mtr.yaml (sops-encrypted).
  fileSystems."/mnt/mt/files" = {
    device = "//files.mt-robot.com/staff";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets."smb-mtr".path}"
      "uid=1000"
      "gid=100"
      "file_mode=0644"
      "dir_mode=0755"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "_netdev"
    ];
  };

  # NOTE: to forward gui with virtualgl and turbovnc:
  # $ /opt/TurboVNC/bin/vncserver -geometry 1920x1080 -noxstartup
  # $ DISPLAY=:1 VGL_DISPLAY=egl vglrun mt-visualizer-mtl --no-vsync localization/pf_internals.mtl

  # use 'uc-3' to find 'uc-3.mt-robot.com'
  networking.search = [ "mt-robot.com" ];

  # NOTE: enabling the firewall creates issues with gazebo: see
  # - https://docs.ros.org/en/rolling/How-To-Guides/Installation-Troubleshooting.html#enable-multicast
  # - https://gazebosim.org/docs/latest/troubleshooting/#network-configuration-issue
  networking.firewall.enable = false;

  security.pki.certificateFiles = [ ./ca.crt ]; # NOTE: beware of trailing spaces

  # required for lldb debugging with neovim
  # WARN: allows any process to trace any other process. This can be a security risk, so ensure you understand the implications before making this change.
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

}

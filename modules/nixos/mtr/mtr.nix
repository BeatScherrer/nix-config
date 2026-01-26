{
  pkgs,
  ...
}:
{
  imports = [
    ./mysql.nix
    ../blender.nix
  ];

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
  ];

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

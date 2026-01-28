{ pkgs, ... }:
{
  hardware.xpadneo.enable = true;

  boot.initrd.kernelModules = [
    "usbhid"
    "joydev"
    "xpad"
  ];
}

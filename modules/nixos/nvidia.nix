{ pkgs, ... }: {
  # TODO:
  # hardware.nvidia.prime = {
  #   intelBusId = "PCI:";
  # }
  environment.systemPackages = with pkgs; [
    nvidia-docker
    nvidia-podman
    nvidia-settings
  ];

  hardware = {
    graphics = { enable = true; };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = true;
    };
  };
}

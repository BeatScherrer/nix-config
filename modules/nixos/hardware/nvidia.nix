{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  # Early KMS — required for Wayland compositors and GDM Wayland session
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      #
      # PINNED 2026-07-20 — display flicker bisect.
      # The 26.05 -> 26.11 channel bump (gen 248 -> 249, Jul 17) moved kernel
      # 7.0.8 -> 7.1.2 AND nvidia 595.71.05 -> 595.84 together; flicker started
      # after it. This pins the old driver onto the new kernel to separate the
      # two: flicker gone => driver regression, flicker stays => kernel.
      # Hashes are the nixpkgs d233902 (gen 248) `production` block verbatim.
      # To revert: restore `nvidiaPackages.stable`.
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "595.71.05";
        sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
        sha256_aarch64 = "sha256-XzKloS00dFKTd4ATWkTIhm9eG/OzR/Sim6MboNZWPu8=";
        openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
        settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
        persistencedSha256 = "sha256-Z/6IvEEa/XfZ5F5qoSIPvXJLGtscYVqjFxHZaN/M2Ts=";
      };

      # NVIDIA Prime for hybrid AMD iGPU + NVIDIA dGPU (e.g. Legion 5 Pro)
      # Enable if iGPU is active in BIOS (MUX switch set to hybrid mode).
      # Verify amdgpuBusId with: lspci | grep -i vga
      # prime = {
      #   sync.enable = true;  # or offload.enable for power savings
      #   amdgpuBusId = "PCI:6:0:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };
  };

}

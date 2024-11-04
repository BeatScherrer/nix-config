{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui # focusrite control software
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      # TODO: verify for focusrite 4i4
      # "default.clock.rate" = 48000;
      # "default.clock.quantum" = 32;
      # "default.clock.min-quantum" = 32;
      # "default.clock.max-quantum" = 32;
    };
  };

  boot.kernelParams = [ "snd_usb_audio.power_save=0" ];

  # TODO: add user name as input to this module
  users.users.beat.extraGroups = [ "audio" ];
}

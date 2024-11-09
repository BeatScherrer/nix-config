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

  # NOTE: This does only apply to the focusrite 4i4 usb audio interface!
  boot.extraModprobeConfig = "options snd_usb_audio vid=0x1235 pid=0x821a device_setup=1";

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      # TODO: verify for focusrite 4i4
      "default.clock.rate" = 48000;
      # "default.clock.quantum" = 32;
      # "default.clock.min-quantum" = 32;
      # "default.clock.max-quantum" = 32;
    };
  };

  # TODO: add user name as input to this module
  users.users.beat.extraGroups = [ "audio" ];
}

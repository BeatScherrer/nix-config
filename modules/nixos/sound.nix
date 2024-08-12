{ ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # TODO: add user name as input to this module
  users.users.beat.extraGroups = [ "audio" ];
}

{ ... }:
{
  security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa = {
  #     enable = true;
  #     support32Bit = true;
  #   };
  #   pulse.enable = true;
  #   jack.enable = true;
  #   # TODO: fix stuttering
  #   # https://www.reddit.com/r/linux_gaming/comments/11yp7ig/pipewire_audio_stuttering_when_playing_games_or/
  # };
  hardware.pulseaudio.enable = true;

  # TODO: add user name as input to this module
  users.users.beat.extraGroups = [ "audio" ];
}

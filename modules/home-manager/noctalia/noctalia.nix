{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.noctalia;
in
{
  options.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    settingsFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.nix/modules/home-manager/noctalia/settings.json";
      description = "Absolute path to the noctalia settings.json file. Must be a writable filesystem path (not a Nix store path) so noctalia can persist settings changes.";
    };
  };

  # Lock screen crash fix (NVIDIA + Wayland):
  # Quickshell crashes with QSGRenderLoop::handleContextCreationFailure when
  # creating the ext-session-lock-v1 surface. If the lock screen dies on lock,
  # try adding these env vars (in order of preference):
  #   QSG_RHI_BACKEND=opengl    — force Qt scene graph to use OpenGL over Vulkan
  #   QSG_RENDER_LOOP=basic     — use single-threaded render loop as fallback

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      noctalia-shell
      brightnessctl
      gpu-screen-recorder
      upower
    ];

    # Out-of-store symlink so noctalia can modify settings dynamically
    # while keeping the file version controlled in the repo
    xdg.configFile."noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink cfg.settingsFile;
  };
}

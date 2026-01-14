{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.gnomeHome;
in
{
  imports = [ ./rofi/rofi.nix ];

  options.gnomeHome = {
    enable = mkEnableOption "gnome home configuration";
  };

  config = mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = "disabled";
        enabled-extensions = [
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "pop-shell@system76.com"
          "caffeine@patapon.info"
          "hidetopbar@mathieu.bidon.ca"
          "gsconnect@andyholmes.github.io"
        ];
        favorite-apps = [
          "librewolf.desktop"
          "com.mitchellh.ghostty.desktop"
          "thunderbird.desktop"
          "zulip.desktop"
          "signal.desktop"
          "bitwarden.desktop"
        ];
        had-bluetooth-devices-setup = true;
        remember-mount-password = false;
        welcome-dialog-last-shown-version = "42.4";
        last-selected-power-profile = "performance";
      };
      "org/gnome/shell/extensions/hidetopbar" = {
        enable-active-window = false;
        enable-intellihide = false;
      };
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        toolkit-accessibility = true;
      };
      "org/gnome/mutter" = {
        "dynamic-workspaces" = false;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:appmenu";
        num-workspaces = 10;
      };
      "org/gnome/desktop/wm/keybindings" = {
        activate-window-menu = "disabled";
        toggle-message-tray = "disabled";
        close = [ "<Super>q" ];
        maximize = "disabled";
        minimize = [ "<Super>comma" ];
        move-to-monitor-down = "disabled";
        move-to-monitor-left = "disabled";
        move-to-monitor-right = "disabled";
        move-to-monitor-up = "disabled";
        move-to-workspace-down = "disabled";
        move-to-workspace-up = "disabled";
        toggle-maximized = [ "<Super>m" ];
        unmaximize = "disabled";
      };
      "org/gnome/shell/extensions/pop-shell" = {
        focus-right = "disabled";
        tile-by-default = true;
        tile-enter = "disabled";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "ghostty";
        command = "ghostty";
        binding = "<Super>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "kitty ctrl_alt";
        command = "kitty -e tmux";
        binding = "<Ctrl><Alt>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "rofi-rbw";
        command = "rofi-rbw --action copy";
        binding = "<Ctrl><Super>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "rofi launcher";
        command = "rofi -modi drun -show drun";
        binding = "<Super>space";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        name = "librewolf";
        command = "librewolf";
        binding = "<Super>b";
      };
    };
  };
}

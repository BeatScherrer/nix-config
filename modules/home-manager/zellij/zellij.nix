{ pkgs, ... }: {
  home.packages = with pkgs; [ zellij ];

  # TODO: use the kdl file so it can be shared more easily to other distros

  programs.zellij = {
    enable = true;
    enableBashIntegration = false;
    settings = {
      theme = "kanagawa";
      pane_frames = false;
      keybinds = {
        shared = {
          "bind \"Ctrl h\" \"Ctrl Left\"" = { MoveFocus = "Left"; };
          "bind \"Ctrl j\" \"Ctrl Down\"" = { MoveFocus = "Down"; };
          "bind \"Ctrl k\" \"Ctrl Up\"" = { MoveFocus = "Up"; };
          "bind \"Ctrl l\" \"Ctrl Right\"" = { MoveFocus = "Right"; };

          "bind \"Ctrl Shift h\" \"Ctrl Shift Left\"" = { MovePane = "Left"; };
          "bind \"Ctrl Shift j\" \"Ctrl Shift Down\"" = { MovePane = "Down"; };
          "bind \"Ctrl Shift k\" \"Ctrl Shift Up\"" = { MovePane = "Up"; };
          "bind \"Ctrl Shift l\" \"Ctrl Shift Right\"" = {
            MovePane = "Right";
          };
        };
        # shared = {
        #
        # };
      };
    };
  };

}

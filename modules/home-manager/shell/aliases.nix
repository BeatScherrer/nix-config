{
  nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
  nixtest = "sudo nixos-rebuild switch --flake ~/.nix";
  homeupdate = "home-manager switch --flake ~/.nix";
  nnix = "nvim ~/.nix";
  nnvim = "cd ~/.config/nvim";
  cdnix = "cd ~/.nix";
  cdsrc = "cd ~/src";
  cdmtr = "cdsrc && cd mtrobot";
  cdschroot = "cdmtr && cd debian-packages/mt-schroot/usr/bin";
  sourcezsh = "source ~/.zshrc";
  config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
  cdairshow = "cdsrc && cd beat/airshow";
  cdaf = "cdsrc && cd beat/albatros_frontend";
  sc = "sudo SYSTEMD_EDITOR=vim systemctl";
  jc = "sudo journalctl";
  vimf = "nvim $(fzf)";
  cm = "cmake -GNinja";
  mm = "CCACHE_BASEDIR=\${PWD}; echo \"ninja build (CCACHE_BASEDIR set) (MAKE_CORES:\${MAKE_CORES})\"; ninja -j\${MAKE_CORES}";
}

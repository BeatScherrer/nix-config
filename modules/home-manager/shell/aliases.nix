{
  nixupdate = "nh os switch ~/.nix";
  nixupdate-nocache = "nh os switch ~/.nix -- --option extra-substituters '' --option extra-trusted-public-keys ''";
  nixtest = "nh os test ~/.nix";
  nixclean = "nh clean all --keep 10 --keep-since 7d";
  homeupdate = "nh home switch ~/.nix";
  config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
  sc = "sudo SYSTEMD_EDITOR=vim systemctl";
  jc = "sudo journalctl";
  cm = "cmake -GNinja";
  mm = "CCACHE_BASEDIR=\${PWD}; echo \"ninja build (CCACHE_BASEDIR set) (MAKE_CORES:\${MAKE_CORES})\"; ninja -j\${MAKE_CORES}";
  nnix = "nvim ~/.nix";
  sourcebash = "source ~/.bashrc";
  sourcezsh = "source ~/.zshrc";
}

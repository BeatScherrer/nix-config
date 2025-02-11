{
  nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
  nixtest = "sudo nixos-rebuild switch --flake ~/.nix";
  homeupdate = "home-manager switch --flake ~/.nix";
  config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
  sc = "sudo SYSTEMD_EDITOR=vim systemctl";
  jc = "sudo journalctl";
  cm = "cmake -GNinja";
  mm = "CCACHE_BASEDIR=\${PWD}; echo \"ninja build (CCACHE_BASEDIR set) (MAKE_CORES:\${MAKE_CORES})\"; ninja -j\${MAKE_CORES}";
}

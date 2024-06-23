{
  nixupdate = "sudo nixos-rebuild switch --flake ~/.nix";
  nixtest = "sudo nixos-rebuild switch --flake ~/.nix";
  homeupdate = "home-manager switch --flake ~/.nix";
  nnix = "nvim ~/.nix";
  nnvim = "cd ~/.config/nvim";
  cdnix = "cd ~/.nix";
  cdsrc = "cd ~/src";
  sourcezsh = "source ~/.zshrc";
  config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
  cdairshow = "cdsrc && cd airshow";
  cdaf = "cdsrc && cd albatros_frontend";
  sc = "sudo SYSTEMD_EDITOR=vim systemctl";
  jc = "sudo journalctl";
  vimf = "nvim $(fzf)";
}

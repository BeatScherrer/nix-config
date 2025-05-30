{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Beat Scherrer";
    userEmail = "beat.scherrer@gmail.com";
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status -s";
      br = "branch";
      pl = "pull";
      pa = "pull --recurse-submodules";
      fa = "fetch --all";
      cs = "clone --recursive -b";
      lg = ''log -20 --oneline --abbrev-commit --pretty=format:"%h %ad | %s%d [%an]" --date=short'';
      hist = ''log -20 --graph --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'';
      type = "cat-file -t";
      dump = "cat-file -p";
      subup = "submodule update --init --recursive";
      last = "log -1 HEAD";
      unstage = "reset HEAD --";
      mh = "merge -Xignore-space-change -Xrename-threshold=25";
      unpushed = "log --branches --not --remotes --no-walk --decorate --oneline";
    };
    hooks = {
      commit-msg = ./git_hooks/commit-msg;
    };
    extraConfig = {
      core = {
        editor = "vim";
      };
      merge = {
        tool = "vimdiff";
      };
      mergetool = {
        prompt = false;
        keepBackup = false;
        vimdiff = {
          cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        };
      };
      safe = {
        directory = "*";
      };
    };
  };
}

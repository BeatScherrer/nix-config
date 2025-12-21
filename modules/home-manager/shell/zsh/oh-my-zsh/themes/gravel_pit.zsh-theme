# vim:ft=zsh ts=2 sw=2 sts=2
#
# gravel_pit theme for zsh - matching the oh-my-bash version
#
# One line prompt showing the following configurable information:
# OS_LOGO sim_host user@hostname pwd git_branch git_dirty →
#
# The → arrow shows the exit status of the last command:
# - green: 0 exit status
# - red: non-zero exit status

autoload -U colors && colors

### Prompt components

prompt_os() {
  local arch_logo="\uF303"
  local debian_logo="\uF306"
  local ubuntu_logo="\uF31b"
  local nixos_logo="\uF313"
  local apple_logo="\ue711"

  if command -v sw_vers > /dev/null; then
    echo -n "%F{white}$apple_logo %f"
  elif [[ -f /etc/os-release ]]; then
    local os_name
    os_name=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')

    if [[ "$os_name" == "NixOS" ]]; then
      echo -n "%F{blue}$nixos_logo  %f"
    elif [[ "$os_name" == "Ubuntu" ]]; then
      local version_id
      version_id=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
      echo -n "%F{208}$ubuntu_logo $version_id %f"
    elif [[ "$os_name" == "Debian" ]]; then
      echo -n "%F{red}$debian_logo %f"
    elif [[ "$os_name" == "Arch" || "$os_name" == "Arch Linux" ]]; then
      echo -n "%F{blue}$arch_logo %f"
    else
      echo -n "%F{white}$os_name %f"
    fi
  fi
}

prompt_sim_host() {
  if [[ -n "$HOSTCFG" ]]; then
    if command -v xmlstarlet &>/dev/null; then
      local host_type host_id
      host_type=$(xmlstarlet sel -t -v "/config/hostType" "$HOSTCFG")
      host_id=$(xmlstarlet sel -t -v "/config/hostId" "$HOSTCFG")

      case "$host_type" in
        "robot") host_type="r" ;;
        "master") host_type="m" ;;
      esac

      echo -n "%F{cyan}${host_type}-${host_id} %f"
    fi
  fi
}

prompt_user() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    echo -n "%B%F{8}%n%f%b"
  fi
}

prompt_rebel() {
  local rebel_logo="\uf1d0"
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    echo -n "%F{yellow}$rebel_logo %f"
  else
    echo -n "%F{8}$rebel_logo %f"
  fi
}

prompt_host() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    echo -n "%B%F{8}%m %f%b"
  fi
}

prompt_dir() {
  echo -n "%F{blue}%1~ %f"
}

prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    local ref dirty

    # Check if dirty
    local git_status
    git_status=$(command git status -s 2>/dev/null | tail -n 1)
    [[ -n $git_status ]] && dirty=" ●"

    # Get ref
    ref=$(command git symbolic-ref HEAD 2>/dev/null) || \
    ref="➦ $(command git rev-parse --short HEAD 2>/dev/null)"
    ref="${ref#refs/heads/}"

    # Try to abbreviate (extract task from branch name like feature/TASK-123-description)
    local task
    task=$(echo "$ref" | cut -f 2 -d '/' | cut -f 1,2 -d '-')
    if [[ -n "$task" && "$task" != "$ref" ]]; then
      ref="$task"
    fi

    if [[ -n $dirty ]]; then
      echo -n "%F{yellow}${ref}${dirty} %f"
    else
      echo -n "%F{green}${ref} %f"
    fi
  fi
}

prompt_status() {
  if [[ $RETVAL -eq 0 ]]; then
    echo -n "%F{green}→ %f"
  else
    echo -n "%F{red}→ %f"
  fi
}

build_prompt() {
  RETVAL=$?
  prompt_os
  prompt_sim_host
  prompt_user
  prompt_rebel
  prompt_host
  prompt_dir
  prompt_git
  prompt_status
}

PROMPT='$(build_prompt) '

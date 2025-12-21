#! bash oh-my-bash.module
#
# One line prompt showing the following configurable information
# for git:
# time (virtual_env) username@hostname pwd git_char|git_branch git_dirty_status|→
#
# The → arrow shows the exit status of the last command:
# - bold green: 0 exit status
# - bold red: non-zero exit status
#
# Example outside git repo:
# 07:45:05 user@host ~ →
#
# Example inside clean git repo:
# 07:45:05 user@host .oh-my-bash ±|master|→
#
# Example inside dirty git repo:
# 07:45:05 user@host .oh-my-bash ±|master ✗|→
#
# Example with virtual environment:
# 07:45:05 (venv) user@host ~ →
#
# shellcheck disable=SC2034,SC2154

DEBUG=0
debug() {
  if [[ ${DEBUG} -ne 0 ]]; then
    echo >&2 -e "$@"
  fi
}

# SEGMENT_SEPARATOR=''
SEGMENT_SEPARATOR=''
# RIGHT_SEPARATOR=''
RIGHT_SEPARATOR=''
LEFT_SUBSEG=''
RIGHT_SUBSEG=''

text_effect() {
  case "$1" in
  reset) echo 0 ;;
  bold) echo 1 ;;
  underline) echo 4 ;;
  esac
}

fg_color() {
  case "$1" in
  black) echo 30 ;;
  red) echo 31 ;;
  green) echo 32 ;;
  yellow) echo 33 ;;
  blue) echo 34 ;;
  magenta) echo 35 ;;
  cyan) echo 36 ;;
  white) echo 37 ;;
  orange) echo 38\;5\;166 ;;
  gray) echo 90 ;;
  esac
}

bg_color() {
  case "$1" in
  black) echo 40 ;;
  red) echo 41 ;;
  green) echo 42 ;;
  yellow) echo 43 ;;
  blue) echo 44 ;;
  magenta) echo 45 ;;
  cyan) echo 46 ;;
  white) echo 47 ;;
  orange) echo 48\;5\;166 ;;
  esac
}

ansi() {
  local seq
  declare -a mycodes=("${!1}")

  debug "ansi: ${!1} all: $* aka ${mycodes[@]}"

  seq=""
  for ((i = 0; i < ${#mycodes[@]}; i++)); do
    if [[ -n $seq ]]; then
      seq="${seq};"
    fi
    seq="${seq}${mycodes[$i]}"
  done
  debug "ansi debug:" '\\[\\033['"${seq}"'m\\]'
  echo -ne '\[\033['"${seq}"'m\]'
  # PR="$PR\[\033[${seq}m\]"
}

prompt_segment() {
  local bg fg
  declare -a codes

  debug "Prompting $1 $2 $3"

  # if commented out from kruton's original... I'm not clear
  # if it did anything, but it messed up things like
  # prompt_status - Erik 1/14/17

  #    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
  codes=("${codes[@]}" $(text_effect reset))
  #    fi
  if [[ -n $1 ]]; then
    bg=$(bg_color "$1")
    codes=("${codes[@]}" "$bg")
    debug "Added $bg as background to codes"
  fi
  if [[ -n $2 ]]; then
    fg=$(fg_color "$2")
    codes=("${codes[@]}" "$fg")
    debug "Added $fg as foreground to codes"
  fi

  debug "Codes: "
  # declare -p codes

  if [[ $CURRENT_BG != NONE && "$1" != "$CURRENT_BG" ]]; then
    declare -a intermediate=($(fg_color "$CURRENT_BG") $(bg_color "$1"))
    debug "pre prompt " "$(ansi intermediate[@])"
    PR=$(echo -en "$PR$(ansi intermediate[@])$SEGMENT_SEPARATOR")
    debug "post prompt " "$(ansi codes[@])"
    PR=$(echo -en "$PR$(ansi codes[@])")
  else
    debug "no current BG, codes is ${codes[@]}"
    PR=$(echo -en "$PR$(ansi codes[@])")
  fi
  CURRENT_BG=$1
  # echo -en "$3"

  [[ -n $3 ]] && PR=$(echo -en "$PR$3")
}

prompt_right_segment() {
  local bg fg
  declare -a codes

  debug "Prompt right"
  debug "Prompting $1 $2 $3"

  # if commented out from kruton's original... I'm not clear
  # if it did anything, but it messed up things like
  # prompt_status - Erik 1/14/17

  #    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
  codes=("${codes[@]}" $(text_effect reset))
  #    fi
  if [[ -n $1 ]]; then
    bg=$(bg_color "$1")
    codes=("${codes[@]}" $bg)
    debug "Added $bg as background to codes"
  fi
  if [[ -n $2 ]]; then
    codes=("${codes[@]}" "$fg")
    fg=$(fg_color "$2")
    debug "Added $fg as foreground to codes"
  fi

  debug "Right Codes: "
  # declare -p codes

  # right always has a separator
  # if [[ $CURRENT_RBG != NONE && $1 != $CURRENT_RBG ]]; then
  #     $CURRENT_RBG=
  # fi
  declare -a intermediate2=($(fg_color $1) $(bg_color $CURRENT_RBG))
  # PRIGHT="$PRIGHT---"
  debug "pre prompt " "$(ansi intermediate2[@])"
  PRIGHT="$PRIGHT$(ansi intermediate2[@])$RIGHT_SEPARATOR"
  debug "post prompt " "$(ansi codes[@])"
  PRIGHT="$PRIGHT$(ansi codes[@])"
  # else
  #     debug "no current BG, codes is $codes[@]"
  #     PRIGHT="$PRIGHT$(ansi codes[@]) "
  # fi
  CURRENT_RBG=$1
  [[ -n $3 ]] && PRIGHT="$PRIGHT$3"
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    declare -a codes=($(text_effect reset) $(fg_color $CURRENT_BG))
    PR="$PR$(ansi codes[@])$SEGMENT_SEPARATOR"
  fi
  declare -a reset=($(text_effect reset))
  PR="$PR$(ansi reset[@]) "
  CURRENT_BG=''
}

prompt_rebel() {
  local rebel_logo=""
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    prompt_segment default yellow "$rebel_logo "
  else
    prompt_segment default gray "$rebel_logo "
  fi
}

prompt_os() {
  local arch_logo="\uF303"
  local debian_logo="\uF306"
  local ubuntu_logo="\uF31b"
  local nixos_logo="\uF313"

  local os_name
  os_name=$(cat /etc/os-release | grep '^NAME=' | cut -d'=' -f2 | tr -d '"')

  local version_codename
  version_codename=$(cat /etc/os-release | grep '^VERSION_CODENAME=' | cut -d'=' -f2)
  version_id=$(cat /etc/os-release | grep '^VERSION_ID=' | cut -d '=' -f2 | tr -d '"')

  if [[ "$os_name" == "NixOS" && -n $version_codename ]]; then
    # prompt_segment black blue "$nixos_logo $version_codename"
    prompt_segment default blue "$nixos_logo  "
  elif [[ "$os_name" == "Ubuntu" && -n "$version_codename" ]]; then
    # prompt_segment orange white "$ubuntu_logo $version_codename  "
    # prompt_segment default orange "$ubuntu_logo $version_codename "
    prompt_segment default orange "${ubuntu_logo} ${version_id} "
  elif [[ "$os_name" == "Debian" && -n "$version_codename" ]]; then
    prompt_segment orange white "$debian $version_codename  "
  elif [[ "$os_name" == "Arch" || "$os_name" == "Arch Linux" ]]; then
    prompt_segment default blue "$arch_logo "
  else
    prompt_segment white black "fallback: ${os_name} - ${version_codename}"
  fi
}

prompt_context() {
  local user
  user=$(whoami)

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "${_omb_prompt_bold_gray}\u \h"
  fi
}

prompt_schroot() {
  if [[ -n "$SCHROOT_CHROOT_NAME" ]]; then
    prompt_segment default yellow "$SCHROOT_CHROOT_NAME "
  fi
}

prompt_sim_host() {
  if [[ -n "$HOSTCFG" ]]; then
    if command -v xmlstarlet &>/dev/null; then
      local host_type host_id
      host_type=$(xmlstarlet sel -t -v "/config/hostType" "$HOSTCFG")
      host_id=$(xmlstarlet sel -t -v "/config/hostId" "$HOSTCFG")

      case "$host_type" in
      "robot")
        host_type="r"
        ;;
      "master")
        host_type="m"
        ;;
      esac

      prompt_segment default cyan "${host_type}-${host_id} "
    fi
  fi

}

prompt_dir() {
  prompt_segment default blue '\W '
}

git_status_dirty() {
  dirty=$(git status -s 2>/dev/null | tail -n 1)
  [[ -n $dirty ]] && echo " ●"
}

prompt_git() {
  local ref dirty
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    dirty=$(git_status_dirty)
    ref=$(git symbolic-ref HEAD 2>/dev/null) || ref="➦ $(git show-ref --head -s --abbrev | head -n1 2>/dev/null)"
    task=$(git rev-parse --abbrev-ref HEAD | cut -f 2 -d '/' | cut -f 1,2 -d '-')

    # check if can abbreviate the ref
    if [[ -n "$task" ]]; then
      ref="$task"
    fi

    if [[ -n $dirty ]]; then
      prompt_segment default yellow
    else
      prompt_segment default green
    fi
    PR="$PR${ref/refs\/heads\//}$dirty "
  fi
}

prompt_status() {
  if [[ $RETVAL == 0 ]]; then
    prompt_segment default green "→ "
  else
    prompt_segment default red "→ "
  fi
}

build_prompt() {
  # prompt_schroot
  prompt_os
  prompt_sim_host
  prompt_context
  prompt_rebel
  prompt_dir
  prompt_git
  prompt_status
  prompt_end
}

_omb_theme_PROMPT_COMMAND() {
  RETVAL=$?
  PR=""
  PRIGHT=""

  build_prompt

  PS1="$PR"

  # attempt to work around the ansi colors with right aligned
  # local rest='\e[u'
  # local save='\e[s'
  # PRIGHT_stripped=$(sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" <<<"$PRIGHT")
  # PS1="\[${save}\e[${COLUMNS:-$(tput cols)}C\e[${#PS1RHS_stripped}D${PRIGHT}${rest}\]${PR}"
  # PS1=$(printf "%*s\r%s\n\$ " "$(tput cols)" "$PRIGHT" "$PR")
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

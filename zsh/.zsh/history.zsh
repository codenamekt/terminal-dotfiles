# ~/.zsh/history.zsh — managed by Stow from ~/dotfiles/zsh/.zsh/history.zsh
# shellcheck shell=zsh

# Prevent simple "command not found" lines from being saved to history.
# This does not filter commands that exist but exit non-zero, e.g. `git nope`.
zshaddhistory() {
  local line="${1%%$'\n'}"

  # Ignore blank lines and private commands prefixed with a space.
  [[ -z "${line//[[:space:]]/}" ]] && return 1
  [[ "$line" == \ * ]] && return 1

  # Keep multiline commands as-is; parsing them reliably is more intrusive.
  [[ "$line" == *$'\n'* ]] && return 0

  local -a words
  words=("${(@z)line}")
  (( ${#words[@]} )) || return 1

  local cmd="${words[1]}"
  local -i idx=1

  case "${cmd}" in
    command)
      (( ${#words[@]} >= 2 )) || return 0
      cmd="${words[2]}"
      ;;
    sudo|doas)
      (( ${#words[@]} >= 2 )) || return 0
      cmd="${words[2]}"
      ;;
    env)
      idx=2
      while (( idx <= ${#words[@]} )) && [[ "${words[idx]}" == *=* ]]; do
        (( idx++ ))
      done
      (( idx <= ${#words[@]} )) || return 0
      cmd="${words[idx]}"
      ;;
    nice|time|timeout|strace)
      (( ${#words[@]} >= 2 )) || return 0
      cmd="${words[2]}"
      ;;
  esac

  if [[ "${cmd}" == */* ]]; then
    [[ -x "${cmd}" ]] && return 1
    return 0
  fi

  type -- "${cmd}" >/dev/null 2>&1 && return 1
  return 0
}

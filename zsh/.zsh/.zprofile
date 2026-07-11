# ~/.zsh/.zprofile — managed by Stow from ~/dotfiles/zsh/.zsh/.zprofile
# shellcheck shell=zsh

# Login-shell PATH additions. zsh ties the $path array to $PATH.
for dir in "${HOME}/.local/bin" "${HOME}/bin"; do
  if [[ -d "$dir" ]]; then
    path=("$dir" "${(@)path:#$dir}")
  fi
done



#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}"

OMZ_DIR="${DIR}/zsh/.zsh/oh-my-zsh"
OMZ_REPO="https://github.com/ohmyzsh/ohmyzsh.git"

CATPPUCCIN_BAT_THEMES_DIR="${DIR}/bat/.config/bat/themes/catppuccin"
CATPPUCCIN_BAT_REPO="https://github.com/catppuccin/bat.git"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID="${ID}"
  OS_LIKE="${ID_LIKE:-}"
else
  OS_ID="unknown"
  OS_LIKE="unknown"
fi

install_package() {
  local package="$1"
  local cmd="${2:-$package}"
  if command -v "${cmd}" >/dev/null 2>&1; then
    return 0
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    local arch_package="${package}"
    if [[ "${package}" == "fd-find" ]]; then
      arch_package="fd"
    elif [[ "${package}" == "bsdextrautils" ]]; then
      arch_package="util-linux"
    elif [[ "${package}" == "ripgrep" ]]; then
      arch_package="ripgrep"
    fi

    echo "Installing ${arch_package} with pacman…"
    sudo pacman -S --noconfirm "${arch_package}"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "Installing ${package} with apt…"
    sudo apt-get update
    sudo apt-get install -y "${package}"
  else
    echo "Missing ${package}; install it with your system package manager." >&2
    return 1
  fi
}

ensure_bat_command() {
  if command -v bat >/dev/null 2>&1; then
    return 0
  fi

  local batcat_path
  batcat_path="$(command -v batcat 2>/dev/null || true)"
  if [[ -z "${batcat_path}" ]]; then
    echo "batcat was not found after installing bat." >&2
    return 1
  fi

  local link_dir="/usr/local/bin"
  if [[ ! -w "${link_dir}" ]]; then
    link_dir="${HOME}/.local/bin"
  fi

  echo "Creating ${link_dir}/bat symlink to ${batcat_path}…"
  if [[ "${link_dir}" == "/usr/local/bin" ]]; then
    sudo mkdir -p "${link_dir}"
    sudo ln -sf "${batcat_path}" "${link_dir}/bat"
  else
    mkdir -p "${link_dir}"
    ln -sf "${batcat_path}" "${link_dir}/bat"
  fi
}

ensure_fd_command() {
  if command -v fd >/dev/null 2>&1; then
    return 0
  fi

  local fdfind_path
  fdfind_path="$(command -v fdfind 2>/dev/null || true)"
  if [[ -z "${fdfind_path}" ]]; then
    echo "fdfind was not found after installing fd-find." >&2
    return 1
  fi

  local link_dir="/usr/local/bin"
  if [[ ! -w "${link_dir}" ]]; then
    link_dir="${HOME}/.local/bin"
  fi

  echo "Creating ${link_dir}/fd symlink to ${fdfind_path}…"
  if [[ "${link_dir}" == "/usr/local/bin" ]]; then
    sudo mkdir -p "${link_dir}"
    sudo ln -sf "${fdfind_path}" "${link_dir}/fd"
  else
    mkdir -p "${link_dir}"
    ln -sf "${fdfind_path}" "${link_dir}/fd"
  fi
}

install_bat_with_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi

  if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
    echo "Passwordless sudo is not available; falling back to a local bat install." >&2
    return 1
  fi

  echo "Installing bat with apt…"
  sudo apt-get update
  sudo apt-get install -y bat
}

install_bat_local() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for the local bat install fallback." >&2
    return 1
  fi

  local version="${BAT_VERSION:-0.24.0}"
  local arch
  case "$(uname -m)" in
    x86_64|amd64)
      arch="x86_64-unknown-linux-musl"
      ;;
    aarch64|arm64)
      arch="aarch64-unknown-linux-musl"
      ;;
    *)
      echo "Unsupported architecture for local bat install: $(uname -m)" >&2
      return 1
      ;;
  esac

  local asset="bat-v${version}-${arch}.tar.gz"
  local url="https://github.com/sharkdp/bat/releases/download/v${version}/${asset}"
  local tmp
  tmp="$(mktemp -d)"

  echo "Installing bat locally from ${url}…"
  curl -fsSL "${url}" -o "${tmp}/${asset}" || return 1
  tar -xzf "${tmp}/${asset}" -C "${tmp}" || return 1
  mkdir -p "${HOME}/.local/bin"
  install -m 0755 "${tmp}/bat-v${version}-${arch}/bat" "${HOME}/.local/bin/bat" || return 1
  rm -rf "${tmp}"
}

install_bat() {
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    echo "bat is already installed: $(command -v bat 2>/dev/null || command -v batcat)"
    ensure_bat_command
    return 0
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing bat with pacman…"
    sudo pacman -S --noconfirm bat
    return 0
  fi

  if install_bat_with_apt; then
    ensure_bat_command
    return 0
  fi

  install_bat_local
  ensure_bat_command
}

install_zoxide_with_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi

  if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
    echo "Passwordless sudo is not available; falling back to a local zoxide install." >&2
    return 1
  fi

  echo "Installing zoxide with apt…"
  sudo apt-get update
  sudo apt-get install -y zoxide
}

install_zoxide_local() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for the local zoxide install fallback." >&2
    return 1
  fi

  local latest_version
  latest_version="$(curl -fsSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p')"
  local version="${ZOXIDE_VERSION:-${latest_version}}"
  if [[ -z "${version}" ]]; then
    echo "Unable to determine latest zoxide version." >&2
    return 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64|amd64)
      arch="x86_64-unknown-linux-musl"
      ;;
    aarch64|arm64)
      arch="aarch64-unknown-linux-musl"
      ;;
    *)
      echo "Unsupported architecture for local zoxide install: $(uname -m)" >&2
      return 1
      ;;
  esac

  local asset="zoxide-${version}-${arch}.tar.gz"
  local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/${asset}"
  local tmp
  tmp="$(mktemp -d)"

  echo "Installing zoxide locally from ${url}…"
  curl -fsSL "${url}" -o "${tmp}/${asset}" || return 1
  tar -xzf "${tmp}/${asset}" -C "${tmp}" || return 1
  mkdir -p "${HOME}/.local/bin"
  install -m 0755 "${tmp}/zoxide" "${HOME}/.local/bin/zoxide" || return 1
  rm -rf "${tmp}"
}

install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    echo "zoxide is already installed: $(command -v zoxide)"
    return 0
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing zoxide with pacman…"
    sudo pacman -S --noconfirm zoxide
    return 0
  fi

  if install_zoxide_with_apt; then
    return 0
  fi

  install_zoxide_local
}

install_manpager_tools() {
  if command -v col >/dev/null 2>&1; then
    return 0
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing util-linux with pacman…"
    sudo pacman -S --noconfirm util-linux
  else
    install_package bsdextrautils col
  fi
}

install_eza_local() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for the local eza install." >&2
    return 1
  fi

  local latest_version
  latest_version="$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p')"
  local version="${EZA_VERSION:-${latest_version}}"
  if [[ -z "${version}" ]]; then
    echo "Unable to determine latest eza version." >&2
    return 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64|amd64)
      arch="x86_64-unknown-linux-gnu"
      ;;
    aarch64|arm64)
      arch="aarch64-unknown-linux-gnu"
      ;;
    *)
      echo "Unsupported architecture for local eza install: $(uname -m)" >&2
      return 1
      ;;
  esac

  local asset="eza_${arch}.tar.gz"
  local url="https://github.com/eza-community/eza/releases/download/v${version}/${asset}"
  local tmp
  tmp="$(mktemp -d)"

  echo "Installing eza locally from ${url}…"
  curl -fsSL "${url}" -o "${tmp}/${asset}" || return 1
  tar -xzf "${tmp}/${asset}" -C "${tmp}" || return 1
  mkdir -p "${HOME}/.local/bin"
  install -m 0755 "${tmp}/eza" "${HOME}/.local/bin/eza" || return 1
  rm -rf "${tmp}"
}

install_eza() {
  if command -v eza >/dev/null 2>&1; then
    local current_ver
    current_ver="$(eza --version | head -n1 | awk '{print $2}')"
    if [[ "${current_ver}" == v0.2[3-9]* || "${current_ver}" == v0.23* ]]; then
      echo "A modern eza is already installed: ${current_ver}"
      return 0
    fi
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing eza with pacman…"
    sudo pacman -S --noconfirm eza
    return 0
  fi

  install_eza_local
}

install_nvim() {
  if command -v nvim >/dev/null 2>&1 && _nvim_version_ok; then
    echo "Neovim is already installed and new enough: $(nvim --version | head -n1)"
    return 0
  fi

  if command -v nvim >/dev/null 2>&1; then
    echo "Neovim is too old ($(nvim --version | head -n1)), upgrading…"
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing neovim with pacman…"
    sudo pacman -S --noconfirm neovim
    return 0
  fi

  # Try the Neovim unstable PPA (stable PPA doesn't ship neovim for noble).
  if command -v add-apt-repository >/dev/null 2>&1; then
    # Remove the old stable PPA source if present.
    sudo rm -f /etc/apt/sources.list.d/neovim-ppa-ubuntu-stable-noble.sources
    DEBIAN_FRONTEND=noninteractive sudo add-apt-repository -y -n ppa:neovim-ppa/unstable 2>/dev/null &&
      sudo apt-get update -qq &&
      echo "Installing Neovim from PPA…" &&
      sudo apt-get install -y neovim &&
      echo "Neovim upgraded: $(nvim --version | head -n1)" &&
      return 0
  fi

  # Fallback: download the AppImage, retrying a few times.
  local appimage="${HOME}/.local/bin/nvim"
  mkdir -p "${HOME}/.local/bin"
  echo "Downloading Neovim AppImage…"
  for try in 1 2 3; do
    if curl -fsSL --connect-timeout 10 --retry 2 \
      "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" \
      -o "${appimage}" 2>/dev/null; then
      chmod +x "${appimage}"
      echo "Neovim AppImage installed to ${appimage}"
      return 0
    fi
    sleep 2
  done

  # If everything failed, install the apt version (even if old) so nvim is available.
  echo "PPA and AppImage both failed. Falling back to apt (may be older)."
  install_package neovim nvim
}

# Check that Neovim version >= 0.11 (major.minor comparison).
_nvim_version_ok() {
  local ver_str major minor
  ver_str="$(nvim --version | head -n1 | sed 's/^NVIM v//')"
  major="${ver_str%%.*}"
  minor="${ver_str#*.}"
  minor="${minor%%.*}"
  [[ "$major" -gt 0 || ( "$major" -eq 0 && "$minor" -ge 11 ) ]]
}

install_go() {
  if command -v go >/dev/null 2>&1; then
    local ver
    ver="$(go version 2>/dev/null | grep -oP 'go[0-9]+\.[0-9]+' || true)"
    echo "Go is already installed: ${ver}"
    return 0
  fi

  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    echo "Installing go with pacman…"
    sudo pacman -S --noconfirm go
    return 0
  fi

  # Try apt first.
  if command -v apt-get >/dev/null 2>&1; then
    echo "Installing golang-go with apt…"
    sudo apt-get update
    sudo apt-get install -y golang-go
    if command -v go >/dev/null 2>&1; then
      echo "Go installed: $(go version)"
      return 0
    fi
  fi

  # Fallback: download latest from go.dev.
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for Go install fallback." >&2
    return 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; return 1 ;;
  esac

  local version="${GO_VERSION:-1.23.4}"
  local tarball="go${version}.linux-${arch}.tar.gz"
  local url="https://go.dev/dl/${tarball}"

  echo "Downloading Go ${version} from ${url}…"
  curl -fsSL "${url}" | sudo tar -C /usr/local -xz || return 1

  # Symlink so /usr/local/go/bin/go is in PATH.
  if [[ ! -f "/usr/local/bin/go" ]]; then
    sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
  fi

  echo "Go installed: $(go version)"
}

install_node() {
  local version="v22.22.3"
  local arch
  case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture for Node.js: $(uname -m)" >&2; return 1 ;;
  esac

  local node_dir="${HOME}/.local/share/pi-node/node-${version}-linux-${arch}"
  if [[ -d "${node_dir}/bin" ]]; then
    echo "Node.js is already installed at ${node_dir}"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for Node.js install." >&2
    return 1
  fi

  local tarball="node-${version}-linux-${arch}.tar.xz"
  local url="https://nodejs.org/dist/${version}/${tarball}"
  local tmp
  tmp="$(mktemp -d)"

  echo "Downloading Node.js ${version} from ${url}…"
  if curl -fsSL "${url}" -o "${tmp}/${tarball}"; then
    mkdir -p "$(dirname "${node_dir}")"
    tar -xf "${tmp}/${tarball}" -C "$(dirname "${node_dir}")"
    echo "Node.js installed successfully to ${node_dir}"
    rm -rf "${tmp}"
    return 0
  fi

  rm -rf "${tmp}"
  echo "Failed to download Node.js" >&2
  return 1
}

install_bootstrap_tools() {
  install_package git
  install_package stow
  install_package less
  install_zoxide
  install_manpager_tools
  install_bat
  install_package fzf
  install_package ripgrep rg
  if [[ "${OS_ID}" == "arch" || "${OS_LIKE}" == *"arch"* ]]; then
    install_package fd
  else
    if install_package fd-find fdfind; then
      ensure_fd_command
    fi
  fi
  install_eza
  install_nvim
  install_go
  install_node
  install_package tmux
  install_package wl-clipboard wl-copy
}

install_zsh() {
  if command -v zsh >/dev/null 2>&1; then
    echo "Zsh is already installed: $(command -v zsh)"
    return 0
  fi

  install_package zsh

  local zsh_path
  zsh_path="$(command -v zsh)"
  if [[ "${SHELL}" != "${zsh_path}" ]]; then
    echo "Setting default shell to ${zsh_path}…"
    chsh -s "${zsh_path}"
  fi
}

clone_oh_my_zsh() {
  if [[ -d "${OMZ_DIR}/.git" ]]; then
    echo "Oh My Zsh is already cloned at ${OMZ_DIR}"
    return 0
  fi

  if [[ -e "${OMZ_DIR}" ]]; then
    echo "${OMZ_DIR} exists but is not a git clone; refusing to overwrite." >&2
    return 1
  fi

  echo "Cloning Oh My Zsh into ${OMZ_DIR}…"
  git clone --depth 1 "${OMZ_REPO}" "${OMZ_DIR}"
}

clone_catppuccin_bat_themes() {
  if [[ -d "${CATPPUCCIN_BAT_THEMES_DIR}/.git" ]]; then
    echo "Catppuccin bat themes are already cloned at ${CATPPUCCIN_BAT_THEMES_DIR}"
    return 0
  fi

  if [[ -e "${CATPPUCCIN_BAT_THEMES_DIR}" ]]; then
    echo "${CATPPUCCIN_BAT_THEMES_DIR} exists but is not a git clone; refusing to overwrite." >&2
    return 1
  fi

  echo "Cloning Catppuccin bat themes into ${CATPPUCCIN_BAT_THEMES_DIR}…"
  mkdir -p "$(dirname "${CATPPUCCIN_BAT_THEMES_DIR}")"
  git clone --depth 1 "${CATPPUCCIN_BAT_REPO}" "${CATPPUCCIN_BAT_THEMES_DIR}"
}

stow_package() {
  local package="$1"
  if [[ ! -d "${package}" ]]; then
    echo "Skipping ${package}; directory not found."
    return 0
  fi

  echo "Stowing ${package}…"
  stow --dotfiles -t ~ -S "${package}"
}

build_bat_cache() {
  if ! command -v bat >/dev/null 2>&1; then
    return 0
  fi

  if [[ ! -d "${HOME}/.config/bat/themes/catppuccin" ]]; then
    return 0
  fi

  echo "Building bat theme cache…"
  bat cache --build --source "${HOME}/.config/bat/themes/catppuccin"
}

install_tpm() {
  local tpm_dir="${HOME}/.tmux/plugins/tpm"

  if [[ -d "${tpm_dir}/.git" ]]; then
    echo "TPM is already installed at ${tpm_dir}"
    git -C "${tpm_dir}" pull --ff-only || true
  else
    echo "Installing TPM to ${tpm_dir}..."
    mkdir -p "$(dirname "${tpm_dir}")"
    git clone https://github.com/tmux-plugins/tpm "${tpm_dir}"
  fi

  if command -v tmux >/dev/null 2>&1 && [[ -f "${HOME}/.tmux.conf" ]]; then
    echo "Loading tmux config to install plugins..."
    tmux source-file "${HOME}/.tmux.conf" || true
  fi
}

clone_custom_plugins() {
  local plugins_dir="${DIR}/zsh/.zsh/custom/plugins"
  mkdir -p "${plugins_dir}"

  # Clone zsh-autosuggestions
  if [[ ! -d "${plugins_dir}/zsh-autosuggestions/.git" ]]; then
    echo "Cloning zsh-autosuggestions…"
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "${plugins_dir}/zsh-autosuggestions"
  fi

  # Clone zsh-history-substring-search
  if [[ ! -d "${plugins_dir}/zsh-history-substring-search/.git" ]]; then
    echo "Cloning zsh-history-substring-search…"
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search.git "${plugins_dir}/zsh-history-substring-search"
  fi

  # Clone zsh-vi-mode
  if [[ ! -d "${plugins_dir}/zsh-vi-mode/.git" ]]; then
    echo "Cloning zsh-vi-mode…"
    git clone --depth 1 https://github.com/jeffreytse/zsh-vi-mode.git "${plugins_dir}/zsh-vi-mode"
  fi

  # Clone fast-syntax-highlighting
  if [[ ! -d "${plugins_dir}/fast-syntax-highlighting/.git" ]]; then
    echo "Cloning fast-syntax-highlighting…"
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${plugins_dir}/fast-syntax-highlighting"
  fi
}

install_bootstrap_tools
install_zsh
clone_oh_my_zsh
clone_custom_plugins
clone_catppuccin_bat_themes

# Stow all known packages. Run `stow --dotfiles zsh` manually if you only want to refresh Zsh.
for package in tmux zsh bat vim nvim fsh eza pi; do
  stow_package "${package}"
done

build_bat_cache
install_tpm

# Install tmux plugins via TPM
if [[ -f "${HOME}/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  echo "Installing tmux plugins..."
  "${HOME}/.tmux/plugins/tpm/bin/install_plugins" || true
fi

# Force TPM to refresh plugins immediately
if command -v tmux >/dev/null 2>&1; then
  echo "Reloading tmux config..."
  tmux source-file "${HOME}/.tmux.conf" || true
  # Kill the server so TPM can reinitialize on next tmux start.
  tmux kill-server 2>/dev/null || true
fi

if [[ ! -f "${HOME}/.zshenv.local" ]]; then
  echo "export DOTFILES_DIR=\"${DIR}\"" > "${HOME}/.zshenv.local"
elif ! grep -q "DOTFILES_DIR" "${HOME}/.zshenv.local"; then
  echo "export DOTFILES_DIR=\"${DIR}\"" >> "${HOME}/.zshenv.local"
fi

echo "Bootstrap complete."

# My Dotfiles

A minimal, **Stow-based** dotfiles repository.

## What’s inside?

- `tmux/` – `~/.tmux.conf` and related settings.
- `bash/` – `~/.bash_aliases` personal shortcuts for Bash environments.
- `zsh/` – `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, Oh My Zsh customizations, and modular Zsh config.
- `bat/` – `bat` pager configuration using Catppuccin Mocha.
- `vim/` – `~/.vimrc` and Vim plugins.
- `nvim/.config/nvim/` – Neovim configuration built on LazyVim core with modular themes, statusline, and homelab syntax extras.
- `pi/` – Pi coding agent settings and extensions (`settings.json`).
- `fsh/` – `fast-syntax-highlighting` custom theme configs (Catppuccin Mocha).
- `eza/` – `eza` custom theme configurations (Catppuccin Mocha Lavender).
- `bootstrap.sh` – installs system packages, clones Oh My Zsh, and runs Stow for known packages.

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/codenamekt/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the bootstrap script**

   ```bash
   ./bootstrap.sh
   ```

   This script is intended to be idempotent. It will:

   - install `git`, `stow`, `zsh`, `less`, `zoxide`, `bat`, `fzf`, `ripgrep`, `fd`, `eza`, and `neovim` if they are missing on Debian/Ubuntu systems;
   - create a `bat` command symlink when the distro package installs `batcat` instead;
   - set Zsh as the default shell when possible;
   - clone Oh My Zsh into `zsh/oh-my-zsh/` and the Catppuccin `bat` themes;
   - run `stow --dotfiles -S` for `tmux`, `zsh`, `bat`, `vim`, `nvim`, `fsh`, and `eza`;
   - build the `bat` theme cache so Catppuccin Mocha is available.

3. **Refresh Stow for a single package, if needed**

   ```bash
   stow --dotfiles -R zsh
   ```

4. **Reload tmux to apply the new config**

   Inside a running tmux session, press `<prefix> + R` or run:

   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Using Stow directly

Each top-level folder (`tmux/`, `zsh/`, `bat/`, `vim/`, `nvim/`, `fsh/`, `eza/`) is a Stow *package*.

```bash
cd ~/dotfiles
stow --dotfiles */   # or: stow --dotfiles zsh bat vim tmux nvim fsh eza
```

To add a new package:

```bash
mkdir -p newtool
# add config files, e.g. newtool/.config/newtool/config
stow --dotfiles newtool
```

## Zsh + Oh My Zsh layout

The Zsh package is managed by Stow and uses this layout:

```text
zsh/
├── .zshrc                         # main interactive Zsh config
├── .zprofile                      # login-shell PATH setup
├── .zshenv                        # minimal env for all zsh shells
├── oh-my-zsh/                     # cloned by ./bootstrap.sh; ignored by git
├── custom/
│   ├── plugins/
│   │   └── terminal-dotfiles/
│   │       └── terminal-dotfiles.plugin.zsh
│   └── themes/
│       └── mytheme.zsh-theme
└── .zsh/
    ├── aliases.zsh
    ├── completions/
    ├── completions.zsh
    ├── env.zsh
    └── functions.zsh
```

After running `stow --dotfiles zsh`, the important links are:

```text
~/.zshrc            -> ~/terminal-dotfiles/zsh/.zshrc
~/.zprofile         -> ~/terminal-dotfiles/zsh/.zprofile
~/.zshenv           -> ~/terminal-dotfiles/zsh/.zshenv
~/.zsh              -> ~/terminal-dotfiles/zsh/.zsh
~/.zsh/oh-my-zsh    -> ~/terminal-dotfiles/zsh/oh-my-zsh
~/.zsh/custom       -> ~/terminal-dotfiles/zsh/custom
```

The `.zshrc` expects Oh My Zsh at:

```text
~/.zsh/oh-my-zsh/oh-my-zsh.sh
```

If that path is missing, it prints a message asking you to run `./bootstrap.sh`.

### Zsh helper commands

The local `terminal-dotfiles` Oh My Zsh plugin adds a small helper:

```bash
terminal-dotfiles status   # show ~/terminal-dotfiles status
terminal-dotfiles pull     # fast-forward pull ~/terminal-dotfiles
dotfiles stow     # re-apply Stow links for zsh, bat, vim, tmux, nvim, fsh, and eza
dotfiles reload   # alias for `dotfiles stow`
```

### Adding Zsh config

- Put aliases in `zsh/.zsh/aliases.zsh`.
- Put functions in `zsh/.zsh/functions.zsh`.
- Put environment exports in `zsh/.zsh/env.zsh`.
- Put completion path setup in `zsh/.zsh/completions.zsh`.
- Add custom themes under `zsh/custom/themes/`.
- Add custom plugins under `zsh/custom/plugins/<plugin>/<plugin>.plugin.zsh`.

## Neovim

Neovim is built on **[LazyVim](https://www.lazyvim.org/)** (`LazyVim/LazyVim`), providing a curated, high-performance IDE setup managed by [Lazy.nvim](https://github.com/folke/lazy.nvim).

### Architecture & Design
- **LazyVim Core**: LSP, Treesitter, Mason, Which-Key, Snacks, and Git Signs are powered directly by LazyVim core imports, eliminating custom boilerplate.
- **Portability & Dynamic Theming**:
  - **Omarchy Integration**: On Omarchy Linux, Neovim dynamically hooks into Omarchy's system theme changes via `omarchy-theme-hotreload.lua` and `theme.lua`, hot-reloading the active system palette in real time with transparent window support (`plugin/after/transparency.lua`).
  - **Ubuntu / Standalone Linux Fallback**: When deployed on Ubuntu or non-Omarchy systems, `theme.lua` seamlessly falls back to **Catppuccin Mocha** (`catppuccin.lua`), keeping the configuration completely portable.
- **Statusline**: Modular Lualine statusline configured in `lua/plugins/ui.lua`, supporting Zen Mode (`<leader>uz`).
- **Homelab Tools**: Syntax and tooling extras for infrastructure and homelab workflows in `lua/plugins/homelab.lua`:
  - Ansible syntax (`ansible-vim`)
  - Terraform / HCL syntax (`vim-terraform`)
  - PlantUML diagramming syntax (`plantuml-syntax`)
- **Remote Clipboard**: Seamless OSC 52 + Wayland clipboard sharing (`remote_clipboard.lua`) across SSH, tmux, and local desktop.

### Useful LazyVim Keybindings

| Key | Action |
|---|---|
| `<Space><Space>` / `<Space>ff` | Find files |
| `<Space>/` / `<Space>sg` | Live grep project |
| `<Space>e` | Neo-tree file explorer |
| `<Space>,` / `<Space>fb` | Switch buffer |
| `<Space>uz` | Toggle Zen Mode |
| `<Space>xx` | Toggle Trouble diagnostics |
| `<Space>ca` | Code action |
| `<Space>cr` | Rename symbol |
| `[b` / `]b` | Previous / Next buffer |
| `<Space>bd` | Delete / close current buffer |
| `<Space>q` | Quit Neovim |
| `<Space>w` | Save buffer |

## Cheatsheet: Keybindings, Commands, and Aliases

A quick reference guide for the new tools, keybindings, and aliases loaded in this configuration.

### 🛠️ Core Tools
* **`eza`**: Modern replacement for `ls` showing files, directories, icons, and git status.
* **`bat`**: A cat clone with syntax highlighting and Git integration.
* **`fzf`**: Command-line fuzzy finder.
* **`fd`**: Fast and user-friendly alternative to `find`.
* **`rg` (ripgrep)**: Fast line-oriented search tool (replaces `grep`).
* **`zoxide`**: Smart directory jumper that learns your navigation patterns.
* **`lf`**: Terminal file manager. Run `lf` and Zsh will automatically `cd` to your final directory on exit.

### ⌨️ Keybindings
Most keybindings are hooked into `zsh-vi-mode` to ensure compatibility:
* **`Ctrl + R`**: Open `fzf` fuzzy history search.
* **`Ctrl + T`**: Open `fzf` file finder (includes hidden files) with a `bat` preview.
* **`Ctrl + F`**: Open `fzf` file finder *excluding* hidden files with a `bat` preview.
* **`Ctrl + Left` / `Right`**: Move cursor backward/forward word-by-word.
* **`Ctrl + \`**: Toggle autosuggestions on/off.
* **`Up` / `Down` Arrow keys**: Search shell history for commands matching the current typed prefix.

### 📌 Useful Aliases & Shortcuts

| Alias | Command | Description |
|---|---|---|
| `vim` | `nvim` | Open Neovim |
| `cp` | `cp -i` | Safe copy (interactive prompt before overwrite) |
| `mv` | `mv -i` | Safe move (interactive prompt before overwrite) |
| `rm` | `rm -i` | Safe remove (interactive prompt before deletion) |

#### Git Aliases
* **`gs`**: `git status -sb` (short branch status)
* **`ga`**: `git add`
* **`gaa`**: `git add --all`
* **`gc`**: `git commit`
* **`gco`**: `git checkout`
* **`gd`**: `git diff`
* **`gl`**: `git log --oneline --graph --decorate --max-count=20`
* **`gp`**: `git pull --ff-only`
* **`glog`**: `PAGER="less -F -X" git log` (won't clear screen on exit for short logs)
* **`gadog`**: `PAGER="less -F -X" git log --all --decorate --oneline --graph` (graphical history representation)

## Additional notes

- **CPU/RAM icons** in tmux are rendered by the `catppuccin/tmux` plugin using Nerd Font glyphs.
  Make sure your terminal is using a Nerd Font, such as FiraCode Nerd Font, Hack Nerd Font, or JetBrainsMono Nerd Font.
  If you still see `▯?` symbols, install a patched font and select it in your terminal profile.

## License

Feel free to copy / adapt – it’s just my personal configuration.

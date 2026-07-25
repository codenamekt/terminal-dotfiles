# My Dotfiles

A minimal, **Stow-based** dotfiles repository.

## What’s inside?

- `tmux/` – `~/.tmux.conf` and related settings.
- `zsh/` – `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, Oh My Zsh customizations, and modular Zsh config.
- `bat/` – `bat` pager configuration using Catppuccin Mocha.
- `vim/` – `~/.vimrc` and Vim plugins.
- `nvim/.config/nvim/` – Neovim configuration with Lazy.nvim, Catppuccin Mocha, LSP, Treesitter, Telescope, Git helpers, and homelab-oriented syntax extras.
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

Neovim is managed by [Lazy.nvim](https://github.com/folke/lazy.nvim). The first run will clone Lazy, then install the configured plugins under:

```text
~/.local/share/nvim/lazy/
```

The configuration includes:

- **Catppuccin Mocha** as the default colorscheme.
- **LSP + Mason** with servers for Bash, Dockerfile, Go, JSON, Lua, Markdown, Python, TypeScript/JavaScript, and YAML.
- **Treesitter** for syntax highlighting, indentation, and text objects.
- **Telescope** for fuzzy finding, live grep, buffers, symbols, and keymaps.
- **Git helpers** with Gitsigns and Fugitive.
- **Editor niceties** such as Which-Key, Comment, nvim-surround, autopairs, Oil file browser, Noice, Todo comments, Trouble, Lualine, Bufferline, and Zen Mode.
- **Homelab extras** for PlantUML/Markdown diagrams, Terraform, and Ansible-style YAML.

Useful defaults:

| Key | Action |
|---|---|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>fb` | Buffers |
| `<Space>fs` | LSP document symbols |
| `<Space>fw` | LSP workspace symbols |
| `<Space>e` | Oil file explorer |
| `<Space>ghs` | Stage Git hunk |
| `<Space>ghr` | Reset Git hunk |
| `<Space>cf` | Format buffer via LSP |
| `<Space>xx` | Toggle diagnostics in Trouble |

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

### 📌 Useful Aliases

| Alias | Command | Description |
|---|---|---|
| `ls` | `eza --icons` | List files with Nerd Font icons |
| `l` | `eza -F --icons` | List files with type indicators and icons |
| `ll` | `eza -lh --icons --git` | Detailed list with permissions, sizes, and Git status |
| `la` | `eza -lah --icons --git` | Detailed list including hidden files |
| `tree` | `eza --tree --icons` | View directory structure as a tree |
| `cat` | `bat` | View files with syntax highlighting |
| `grep` | `rg --color=auto` | Ripgrep-backed colorized search |
| `diff` | `diff --color=auto` | Colorized diff output |
| `-` | `cd -` | Jump back to the previous directory |
| `..` | `cd ..` | Go up one directory level |
| `...` | `cd ../..` | Go up two directory levels |
| `dstow` | `cd ~/terminal-dotfiles && stow ...` | Re-apply GNU Stow configurations |

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

# Fish package

Fish shell setup that mirrors Omarchy's curated bash defaults and ports the
tmux / herdr layout helpers (tdl, tds, tdlm, tsl, hdl, hds, hdlm, hsl).

## Goals

- Test fish on Omarchy without touching the zsh setup.
- Get fish's built-in autosuggestions, syntax highlighting, history search, and
  abbr-as-you-type out of the box (no plugin manager needed).
- Keep Omarchy's curated aliases (`a`, `c`, `cx`, `cy`, `d`, `r`, `t`, `h`, `ic`,
  …) and its `omarchy-launch-editor --inline` default editor.

## Layout

```
fish/.config/fish/
├── config.fish            # main entry point
├── conf.d/
│   ├── 10-env.fish        # EDITOR, MANPAGER, BAT_THEME, locale
│   ├── 20-omarchy-env.fish# OMARCHY_PATH + PATH
│   ├── 30-aliases.fish    # curated aliases
│   └── 40-tool-inits.fish # mise, starship, zoxide, fzf, try
├── functions/             # auto-loaded as fish functions
│   ├── ff.fish, sff.fish, eff.fish, n.fish, open.fish
│   └── tdl.fish, tds.fish, tdlm.fish, tsl.fish
│   └── hdl.fish, hds.fish, hdlm.fish, hsl.fish
└── completions/
    └── omarchy.fish       # dynamic subcommand completion
```

## Install

```
omarchy pkg add fish
cd ~/Work/terminal-dotfiles
stow --dotfiles -S fish
```

## Try without changing login shell

Just open a fresh terminal and run `fish`. Type `exit` to come back to bash.
Nothing is touched in `/etc/passwd`, so login shells still go to bash (which
still sources your existing omarchy bash config).

## Switch login shell to fish (optional)

After you've lived in fish for a while and decided:

```
chsh -s /usr/bin/fish
```

Then log out and back in for the change to take effect.

## Notes

- `MANPAGER` follows Omarchy defaults (`col -bx | bat -l man -p`) — same as the
  bash setup.
- `EDITOR` defaults to `omarchy-launch-editor --inline` to stay integrated with
  the rest of Omarchy. Override per-shell by setting `EDITOR` before stowing.
- `~/.zshenv` and `~/.zsh/` symlinks are NOT touched by this package. They
  coexist with fish; only zsh itself reads them.

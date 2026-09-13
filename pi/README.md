# Pi Coding Agent Configuration

This package provides configuration for the [pi coding agent](https://github.com/earendil-works/pi-coding-agent).
It is symlinked into `~/.pi/agent/` by GNU Stow so the same setup follows you
across every machine where this dotfiles repo is cloned.

## What This Contains

```
pi/
├── .stow-local-ignore          # excludes README only
└── dot-pi/
    └── agent/
        ├── AGENTS.md           # global agent context (loaded every session)
        ├── settings.json       # pi settings (provider, model, theme)
        ├── models.json         # custom model catalog (Ollama, etc.)
        ├── extensions/
        │   ├── litellm.ts             # headroom provider registration
        │   ├── headroom-retrieve.ts   # headroom MCP/REST tools
        │   └── herdr-agent-state.ts   # managed by herdr (overwritten on update)
        └── themes/
            └── omarchy-system.json    # nord-themed color scheme
```

### `herdr-agent-state.ts` — externally managed

This file is **generated and overwritten** by the `herdr` integration
(`HERDR_INTEGRATION_VERSION` is pinned in the header). When `herdr` updates,
it rewrites this file in place. Expect routine diff churn in this file —
review it, then commit. The pin regenerates on every herdr release.

### Skills

Skills are **not** stowed yet — they live in `~/.pi/agent/skills/` and are
added per-machine as needed. See the rationale in the per-machine section.

## Setup

### 1. Clone & Stow

```bash
git clone https://github.com/codenamekt/terminal-dotfiles.git ~/projects/terminal-dotfiles
cd ~/projects/terminal-dotfiles
stow --dotfiles -t ~ -S pi
```

(`--dotfiles` is essential — it tells Stow to interpret the `dot-pi/`
prefix as `.pi/`, so the package's `dot-pi/agent/` directory maps to
`~/.pi/agent/`.)

`stow --dotfiles` creates symlinks from `~/.pi/agent/` to the files under
`pi/dot-pi/agent/`. Existing local files (e.g. `auth.json`, `sessions/`,
`models-store.json`) are left untouched.

### 2. Set up the Headroom API key

Create `~/.config/headroom/env` (chmod 600) with your API key:

```bash
install -m 600 /dev/null ~/.config/headroom/env
echo 'HEADROOM_API_KEY=your-key-here' >> ~/.config/headroom/env
```

The key can be found in your Headroom proxy config or via your secrets manager.
If you have `LITELLM_MASTER_KEY` set there, the extension picks it up too.

### 3. Install Pi and authenticate

```bash
# If Pi isn't installed:
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Authenticate (writes to ~/.pi/agent/auth.json — per-machine, not stowed):
pi
# then run /login
```

### 4. Reload Pi

Inside Pi, run `/reload` to pick up the new config.

## Per-Machine Requirements

| Item | Where |
|------|-------|
| `HEADROOM_API_KEY` | `~/.config/headroom/env` (chmod 600) |
| Provider credentials | `~/.pi/agent/auth.json` (auto-created on `/login`) |
| Headroom proxy | reachable at `http://codenamekt-nuc:8787` (default URL in `litellm.ts`) |
| `HERDR_*` env vars | set by the `herdr` runner when it launches Pi |

## Syncing Across Machines

This package is safe to sync — no secrets are stored here. The
`~/.config/headroom/env` and `~/.pi/agent/auth.json` files contain
machine-specific secrets and are **excluded** from the dotfiles repo.

When you stand up a new machine:

1. Clone this repo and run `stow --dotfiles -t ~ -S pi` (or just run the
   repo's `bootstrap.sh`, which stows every package).
2. Populate `~/.config/headroom/env`.
3. Run `pi` and `/login`.
4. Run `/reload`.

## Models Available

Configured through the LiteLLM proxy (`litellm.ts`). Default model:
`minimax/minimax-m3`. The provider auto-discovers models from
`http://codenamekt-nuc:8787/v1/models` and falls back to a static list if the
proxy is unreachable.

Local Ollama models are listed in `models.json` (currently: deepseek-r1-llama,
llama3.1, qwen2.5-coder).
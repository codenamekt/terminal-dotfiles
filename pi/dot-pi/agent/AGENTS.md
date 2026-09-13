# Global Pi Coding Agent Context

This file is loaded by Pi on every startup. It applies across all projects and
machines where this dotfiles package is stowed. Keep it short — long context
files eat tokens on every turn.

## Environment

- **OS:** Arch Linux via [Omarchy](https://omarchy.org) (also runs on macOS for
  the laptop — adapt commands accordingly).
- **Shell:** fish (interactive); bash/zsh for portable scripts.
- **Terminal:** Hyprland (Wayland) on the desktop; tmux + OSC 52 clipboard.
- **Editor:** Neovim with LazyVim (Catppuccin Mocha theme).
- **Default provider:** `headroom` (LiteLLM proxy at `http://codenamekt-nuc:8787`).
- **Default model:** `minimax/minimax-m3`.

## Conventions

- Default to `minimax/minimax-m3` unless I ask for something else.
- For shell snippets shown to me, prefer **fish syntax** if interactive and
  **bash syntax** if it's a script to run elsewhere. Don't switch mid-example.
- When writing or editing files, prefer `edit` over `write` whenever the file
  already exists.
- After making changes, run a quick sanity check (lint, type-check, dry run)
  before declaring success — don't trust your own work blindly.
- When I'm working on a project that has its own `AGENTS.md`, follow that one
  first; this file is the fallback.

## Skills available

Installed locally (not stowed yet — see the README for the rationale):

- `omarchy` — Omarchy/Hyprland system config
- `diagnose-crash` — Diagnose application crashes from coredumps
- `davinci-resolve-*` — DaVinci Resolve editing workflows
- `social-video-folder-autocutter` — Multicam social video pipeline
- `social-editor` — Social cut planning
- `devrel-project-template` — Reusable Resolve project template

If a task looks like it matches one of these, **invoke the skill first** with
`/skill:<name>` rather than improvising.

## Secrets & machine-local config

The Pi config in this repo intentionally has **no secrets**. Per-machine values
live outside the dotfiles tree:

| Secret | Location |
|--------|----------|
| `HEADROOM_API_KEY` / `LITELLM_MASTER_KEY` | `~/.config/headroom/env` (chmod 600) |
| Provider credentials (`auth.json`) | `~/.pi/agent/auth.json` (per-machine, 600 perms) |
| Local Ollama URL | hardcoded to `http://localhost:11434/v1` — no secret |

If the headroom provider warns about a missing API key, set
`HEADROOM_API_KEY` in `~/.config/headroom/env` and restart Pi.

## Do not

- Don't commit secrets, even in a "temporary" file. Use the env-file fallback.
- Don't hardcode API keys or tokens as fallbacks in extensions — read from env
  or `~/.config/headroom/env`, and fail loud if missing.
- Don't `cd` into long paths interactively — use `n` (zoxide) or aliases.
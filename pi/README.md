# Pi Coding Agent Configuration

This package provides configuration for the [pi coding agent](https://github.com/earendil-works/pi-coding-agent).

## What This Contains

```
pi/
├── agent/
│   ├── settings.json      # pi settings (provider, model, theme)
│   └── extensions/
│       ├── litellm.ts     # headroom provider configuration
│       └── headroom-retrieve.ts  # headroom retrieval tools
└── README.md
```

## Setup

### 1. Clone & Stow
```bash
git clone https://github.com/codenamekt/terminal-dotfiles.git ~/projects/terminal-dotfiles
cd ~/projects/terminal-dotfiles
stow pi
```

### 2. Set Environment Variable
On each machine, create `~/.zshenv.local` with your Headroom API key:

```bash
cat > ~/.zshenv.local << 'EOF'
# Local environment variables - NOT TRACKED
export HEADROOM_API_KEY="your-headroom-api-key"
EOF
```

The key can be found in your Headroom proxy config or via your secrets manager.

### 3. Reload and Restart pi
```bash
source ~/.zshenv.local
# Restart pi or run /reload
```

## Per-Machine Requirements

- **Environment variable**: `HEADROOM_API_KEY` must be set in `~/.zshenv.local`
- **Headroom proxy**: Must be accessible (default: `http://codenamekt-nuc:8787`)

## Syncing Across Machines

This package is safe to sync - no secrets are stored here. The `~/.zshenv.local` file contains machine-specific secrets and is excluded from the dotfiles repo.

## Models Available

Configured through LiteLLM proxy. Default model: `tobiTradez/minimax-m2.7-highspeed`

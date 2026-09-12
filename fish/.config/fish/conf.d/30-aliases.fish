# 30-aliases.fish — curated aliases ported from /usr/share/omarchy/default/bash/aliases

# File system (eza)
if command -q eza
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
end

# ff (fzf picker with kitty-aware preview) — implemented as function so we can
# branch on $TERM. See functions/ff.fish for the implementation; alias here
# so `which ff` shows the right thing and so it shadows any system `ff`.
alias eff='$EDITOR (ff)'

# cd (zoxide) — implemented as function. See functions/cd.fish.
# open (xdg-open) — implemented as function. See functions/open.fish.

# Directory movement
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools (curated by omarchy)
alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cy='codex --approve-for-me'
alias d='docker'
alias r='rails'
alias h='herdr'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'

# Git
alias g='git'
# Status
alias gs='git status -sb'
alias gst='git status'
# Add
alias ga='git add'
alias gaa='git add --all'
# Commit
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
# Branch
alias gco='git checkout'
alias gcb='git checkout -b'
# Diff
alias gd='git diff'
alias gds='git diff --staged'
# Log
alias gl='git log --oneline --graph --decorate --max-count=20'
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
# Pull
alias gp='git pull --ff-only'

# Unix tool overrides — ported from the legacy zsh/bash aliases.zsh
# Safer destructive operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
# Editors
if command -q nvim
    alias vim='nvim'
end
# Colorizing / better defaults (only override when the replacement exists)
if command -q bat
    alias cat='bat'
end
if command -q rg
    alias grep='rg --color=auto'
end
alias diff='diff --color=auto'
alias df='df -h'
alias mkdir='mkdir -pv'

# Shell functions (these need fish function syntax, not simple alias)
# t  — tmux attach or start
# ic — tdl c
# ix — tdl cx
# icx— tdl c cx
# cx — clear screen then claude
# cd — zoxide wrapper (overrides builtin cd)
# open — xdg-open detached
# ff — fzf picker (TERM-aware)
# sff — scp via fzf
# tdl, tds, tdlm, tsl — tmux dev layouts
# hdl, hds, hdlm, hsl — herdr dev layouts

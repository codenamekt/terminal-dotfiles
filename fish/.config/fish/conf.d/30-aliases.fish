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
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

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

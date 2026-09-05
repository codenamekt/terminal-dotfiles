# ~/.zsh/aliases.zsh — personal aliases
# shellcheck shell=zsh

# Neovim alias
alias vim='nvim'

# Safer destructive operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Git shortcuts
alias gs='git status -sb'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --max-count=20'
alias gp='git pull --ff-only'
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'


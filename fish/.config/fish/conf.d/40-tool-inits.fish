# 40-tool-inits.fish — interactive shell init for mise / starship / zoxide / fzf / try
# Mirrors /usr/share/omarchy/default/bash/init

# mise (tool version manager)
if command -q mise
    mise activate fish | source
end

# Regenerate starship.toml from the current omarchy theme's colors.toml so the
# prompt follows the active theme's palette. Safe to run on every startup —
# the script falls back to omarchy's default and always exits 0.
if command -q omarchy-starship-rebuild
    omarchy-starship-rebuild
end

# starship prompt — only in interactive, non-dumb terminals
if status is-interactive; and test "$TERM" != dumb; and command -q starship
    starship init fish | source
end

# zoxide (smart cd)
if command -q zoxide
    zoxide init fish | source
end

# fzf keybindings and completion (fish has its own keybinding files)
if command -q fzf
    if test -r /usr/share/fzf/completion.fish
        source /usr/share/fzf/completion.fish
    end
    if test -r /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
    end
end

# try (tries workbench, if installed)
# Omarchy's bash version runs `try init` once via eval to set up bash-completion
# hooks; the init output is bash-only syntax and not safe to eval in fish. We
# just delegate to the underlying `try` command; if you need bash completion
# hooks for try, run `try init ~/Work/tries` from a bash shell instead.
if command -q try
    function try
        command try $argv
    end
end

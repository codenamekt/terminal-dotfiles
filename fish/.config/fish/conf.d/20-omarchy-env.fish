# 20-omarchy-env.fish — replicate env-bootstrap logic for fish
# (mirrors /usr/share/omarchy/default/bash/env-bootstrap)

# /etc/omarchy.conf is written by omarchy-dev-link; when absent, default lives at /usr/share/omarchy
if test -f /etc/omarchy.conf
    source /etc/omarchy.conf
    if not set -q OMARCHY_PATH
        set -gx OMARCHY_PATH /usr/share/omarchy
    end
else
    set -gx OMARCHY_PATH /usr/share/omarchy
end

# Only prepend dev path if OMARCHY_PATH was overridden (omarchy dev-link mode)
if test "$OMARCHY_PATH" != /usr/share/omarchy
    fish_add_path -p "$OMARCHY_PATH/bin"
end

# User-level tool paths (mise shims first, then ~/.local/bin)
fish_add_path -p "$HOME/.local/share/mise/shims"
fish_add_path -p "$HOME/.local/bin"

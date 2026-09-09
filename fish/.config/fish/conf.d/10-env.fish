# 10-env.fish — editor / pager / locale / browser
# Mirrors /usr/share/omarchy/default/bash/envs so fish behaves the same as the
# bash setup when those tools are invoked.

# Editor: prefer omarchy's launcher (lets you pick inline editor per-call)
# Falls back to the inherited $EDITOR if you set it elsewhere.
if not set -q EDITOR
    set -gx EDITOR "omarchy-launch-editor --inline"
end
set -gx SUDO_EDITOR "$EDITOR"

# Browser (shell-scoped so xdg-settings still works — same as omarchy bash envs)
if not set -q BROWSER
    set -gx BROWSER "omarchy-launch-browser"
end

# Color man pages with bat
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Bat theme used by omarchy
set -gx BAT_THEME "ansi"

# Locale (mirror omarchy's bash envs so SSH/non-login shells don't fall to C)
if not set -q LANG
    if test -r /etc/locale.conf
        source /etc/locale.conf
    end
    set -gx LANG "C.UTF-8"
end

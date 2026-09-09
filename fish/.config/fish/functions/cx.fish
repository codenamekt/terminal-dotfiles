# cx — clear screen then launch claude (auto-permission)
# Ported from omarchy's bash alias: printf clear-escapes && claude --permission-mode auto

function cx
    printf '\033[2J\033[3J\033[H'
    claude --permission-mode auto $argv
end

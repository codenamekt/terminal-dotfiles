# omarchy completion — dynamic subcommand completion
# Runs `omarchy commands` on each tab to populate the subcommand list.

function __fish_omarchy_no_subcommand
    set -l cmd (commandline -opc)
    set -e cmd[1]
    test -z "$cmd"
end

complete -c omarchy -f
complete -c omarchy -n __fish_omarchy_no_subcommand -a "(omarchy commands 2>/dev/null | string match -rg 1 '^  omarchy ([a-z-]+)' | sort -u)"

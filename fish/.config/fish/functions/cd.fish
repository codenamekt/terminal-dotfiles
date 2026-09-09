# cd — zoxide-aware cd (replaces builtin cd when zoxide is installed)
# Ported from omarchy's bash zd() function.

function cd
    if test (count $argv) -eq 0
        builtin cd ~ || return
    else if test -d "$argv[1]"
        builtin cd "$argv[1]" || return
    else
        if not z $argv
            echo "Error: Directory not found"
            return 1
        end
        printf "\U000F17A9 "
        pwd
    end
end

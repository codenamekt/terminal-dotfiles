# n — neovim shortcut: `n` opens nvim in cwd, `n <file>` opens <file>

function n
    if test (count $argv) -eq 0
        command nvim .
    else
        command nvim $argv
    end
end

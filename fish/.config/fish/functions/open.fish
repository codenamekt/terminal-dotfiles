# open — xdg-open detached from the terminal process tree

function open
    xdg-open $argv >/dev/null 2>&1 &
end

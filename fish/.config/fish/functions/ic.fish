# ic — tdl c (in tmux)
# ix — tdl cx (in tmux)
# icx — tdl c cx (in tmux)
# Defined as functions since they reference tdl which itself is a function.

function ic
    tdl c
end

function ix
    tdl cx
end

function icx
    tdl c cx
end

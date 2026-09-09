# ff — fzf file picker with kitty-aware image preview
# Ported from omarchy's bash alias with the same $TERM branch.

function ff
    if test "$TERM" = xterm-kitty
        fzf --preview 'case $(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'
    else
        fzf --preview 'bat --style=numbers --color=always {}'
    end
end

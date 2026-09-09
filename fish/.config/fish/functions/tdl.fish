# tdl — Tmux Dev Layout with editor, ai, and terminal
# Usage: tdl <c|cx|codex|other_ai> [<second_ai>]
# Ported from /usr/share/omarchy/default/bash/fns/tmux

function tdl
    if test -z "$argv[1]"
        echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end
    if test -z "$TMUX"
        echo "You must start tmux to use tdl."
        return 1
    end

    set -l current_dir "$PWD"
    set -l editor_pane
    set -l ai_pane
    set -l ai2_pane
    set -l ai "$argv[1]"
    set -l ai2 "$argv[2]"

    set editor_pane "$TMUX_PANE"

    tmux rename-window -t "$editor_pane" (basename "$current_dir")

    # Top 85% / bottom 15% split (editor pane)
    tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

    # Right 30% split for AI (capture new pane id directly)
    set ai_pane (tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

    # Optional second AI in the AI pane
    if test -n "$ai2"
        set ai2_pane (tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
        tmux send-keys -t "$ai2_pane" "$ai2" C-m
    end

    tmux send-keys -t "$ai_pane" "$ai" C-m
    tmux send-keys -t "$editor_pane" "$EDITOR ." C-m

    # NOTE: omarchy bash has `tmux select-pane -t "$opencode_pane"` here, which
    # references an unset variable. Preserved as a no-op-equivalent (falls
    # through) for fidelity. The intended focus is the editor pane anyway.
    tmux select-pane -t "$opencode_pane" 2>/dev/null
end

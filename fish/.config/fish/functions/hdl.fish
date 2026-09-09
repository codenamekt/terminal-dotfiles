# hdl — Herdr Dev Layout with editor, ai, and terminal
# Usage: hdl <c|cx|codex|other_ai> [<second_ai>]
# Ported from /usr/share/omarchy/default/bash/fns/herdr

function hdl
    if test -z "$argv[1]"
        echo "Usage: hdl <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end
    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hdl."
        return 1
    end

    set -l current_dir "$PWD"
    set -l editor_pane "$HERDR_PANE_ID"
    set -l ai "$argv[1]"
    set -l ai2 "$argv[2]"
    set -l ai_pane
    set -l ai2_pane

    herdr tab rename "$HERDR_TAB_ID" (basename "$current_dir") >/dev/null

    # Top 85% / bottom 15% split
    _herdr_split "$editor_pane" down 0.85 "$current_dir" >/dev/null

    # Right 30% split for AI
    set ai_pane (_herdr_split "$editor_pane" right 0.7 "$current_dir")

    # Optional second AI in the AI pane
    if test -n "$ai2"
        set ai2_pane (_herdr_split "$ai_pane" down 0.5 "$current_dir")
        herdr pane run "$ai2_pane" "$ai2" >/dev/null
    end

    herdr pane run "$ai_pane" "$ai" >/dev/null
    herdr pane run "$editor_pane" "$EDITOR ." >/dev/null
end

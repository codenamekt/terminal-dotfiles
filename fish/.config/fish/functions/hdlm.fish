# hdlm — multiple hdl tabs, one per subdirectory of cwd
# Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]
# Ported from /usr/share/omarchy/default/bash/fns/herdr

function hdlm
    if test -z "$argv[1]"
        echo "Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end
    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hdlm."
        return 1
    end

    set -l ai "$argv[1]"
    set -l base_dir "$PWD"
    set -l first true

    herdr workspace rename "$HERDR_WORKSPACE_ID" (basename "$base_dir") >/dev/null

    for dir in "$base_dir"/*/
        set -l dirpath (string replace -r '/$' '' "$dir")
        if not test -d "$dirpath"
            continue
        end

        # Build the command string
        set -l hdl_command "hdl $ai"
        if set -q argv[2]
            set hdl_command "$hdl_command $argv[2]"
        end

        if test "$first" = true
            set hdl_command "cd '$dirpath' && $hdl_command"
            herdr pane run "$HERDR_PANE_ID" "$hdl_command" >/dev/null
            set first false
        else
            set -l pane_id (herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$dirpath" --no-focus | jq -r '.result.root_pane.pane_id')
            herdr pane run "$pane_id" "$hdl_command" >/dev/null
        end
    end
end

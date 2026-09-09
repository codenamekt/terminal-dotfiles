# hsl — multi-pane swarm, same command in each pane
# Usage: hsl <pane_count> <command>
# Ported from /usr/share/omarchy/default/bash/fns/herdr

function hsl
    if test -z "$argv[1]"; or test -z "$argv[2]"
        echo "Usage: hsl <pane_count> <command>"
        return 1
    end
    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hsl."
        return 1
    end

    set -l count "$argv[1]"
    set -l cmd "$argv[2]"
    set -l current_dir "$PWD"

    herdr tab rename "$HERDR_TAB_ID" (basename "$current_dir") >/dev/null

    # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
    set -l cols 1
    while test (math "$cols * $cols") -lt "$count"
        set cols (math "$cols + 1")
    end

    # Even columns from splitting the rightmost one off at 1/(n-k+1) each time
    set -l columns "$HERDR_PANE_ID"
    for k in (seq 2 $cols)
        set columns $columns (_herdr_split $columns[-1] right (_herdr_ratio 1 (math "$cols - $k + 2")) "$current_dir")
    end

    # Split each column into its share of rows
    set -l panes
    set -l index 1
    for col in $columns
        set -l rows (math "($count / $cols) + ($index <= ($count % $cols) ? 1 : 0)")
        set panes $panes "$col"
        set -l last "$col"
        for j in (seq 2 $rows)
            set last (_herdr_split "$last" down (_herdr_ratio 1 (math "$rows - $j + 2")) "$current_dir")
            set panes $panes "$last"
        end
        set index (math "$index + 1")
    end

    for pane in $panes
        herdr pane run "$pane" "$cmd" >/dev/null
    end
end

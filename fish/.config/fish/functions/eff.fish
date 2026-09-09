# eff — open the file picked via fzf in $EDITOR
# (alias also defined in conf.d/30-aliases.fish; this file exists so that
# `functions eff` shows the implementation rather than a bare alias.)

function eff
    $EDITOR (ff)
end

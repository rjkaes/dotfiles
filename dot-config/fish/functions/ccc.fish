function ccc
    if test "$TERM_BACKGROUND_COLOR" = dark
        set theme dark-daltonized
    else
        set theme light-daltonized
    end
    jq --arg t $theme '.theme = $t' ~/.claude.json >~/.claude.json.tmp
    and mv ~/.claude.json.tmp ~/.claude.json
    claude $argv
end

function ccc
    if test "$TERM_BACKGROUND_COLOR" = dark
        set theme dark-daltonized
    else
        set theme light-daltonized
    end
    jq --arg t $theme '.theme = $t' ~/.claude.json >~/.claude.json.tmp
    and mv ~/.claude.json.tmp ~/.claude.json

    if set -l idx (contains -i -- --quick $argv)
        set -e argv[$idx]
        claude --model sonnet $argv
    else
        claude $argv
    end
end

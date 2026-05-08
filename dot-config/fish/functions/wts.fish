function wts --description 'Switch git worktree using fzf'
    set -l list (git worktree list)

    set -l branches
    for line in $list
        set -l branch (string match -rg '\[(.+)\]' -- $line)
        if test -n "$branch"
            set -a branches $branch
        end
    end

    set -l selected (printf '%s\n' $branches | fzf)
    test -z "$selected"; and return 0

    for line in $list
        if string match -q "*[$selected]*" -- $line
            cd (string match -rg '^(\S+)' -- $line)
            return
        end
    end
end

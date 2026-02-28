function gwt --description 'Add a git worktree as a sibling of main/'
    argparse --name=gwt 'b/new-branch' -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Usage: gwt [-b] <branch-name> [base-branch]"
        echo "  -b  Create a new branch (default base: main)"
        return 1
    end

    set -l branch $argv[1]
    set -l dir (string replace --all '/' '--' $branch)

    if set -q _flag_b
        set -l base (if test (count $argv) -ge 2; echo $argv[2]; else; echo main; end)
        git worktree add -b $branch ./$dir $base
    else
        git worktree add ./$dir $branch
    end
end

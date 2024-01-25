function git_current_branch
    string replace refs/heads/ "" (git symbolic-ref --quiet HEAD)
end


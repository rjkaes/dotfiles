function gcm --description 'git checkout default branch'
  git switch (git config --get init.defaultBranch)
end

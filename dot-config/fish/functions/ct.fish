function ct --description "Create ctags"
    rg --files -g '!spec/**' -g '!tests?/**' | command ctags --tag-relative -Rf.git/tags --exclude=.git --languages=-css,-scss,-rspec,-javascript -L -
end

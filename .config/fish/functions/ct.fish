function ct --description "Create ctags"
rg --files -g '!spec/**' -g '!tests?/**' | /usr/local/bin/ctags --tag-relative -Rf.git/tags --exclude=.git --languages=-css,-scss,-rspec,-javascript -L -
end

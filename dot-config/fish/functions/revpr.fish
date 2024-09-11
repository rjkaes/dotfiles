function revpr --description "check out a given PR for review"
  gh co $argv[1]
  git reset --mixed main
end

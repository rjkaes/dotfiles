function rubocop-layout
rubocop -c ~/.rubocop.yml -x (find app lib spec -name '*.rb' -print)
end

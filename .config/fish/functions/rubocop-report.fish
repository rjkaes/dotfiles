function rubocop-report
rubocop -c ~/.rubocop.yml --fail-level E --out rubocop.log -S (find app lib -name '*.rb' -print)
end

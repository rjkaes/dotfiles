function vi --wraps=vim --description 'opens nvim'
  if test (count $argv) -eq 0 && test -f TODO
    command nvim TODO;
  else
    command nvim $argv;
  end
end

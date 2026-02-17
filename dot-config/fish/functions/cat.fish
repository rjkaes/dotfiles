function cat --description 'Use bat instead of cat'
    set -l batcat (command -s batcat) (command -s bat)
    command $batcat $argv
end

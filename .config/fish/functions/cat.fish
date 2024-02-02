# Defined in /var/folders/ww/bs7f4sp146z7nj88vgfkltcm0000gn/T//fish.wgxVXM/cat.fish @ line 2
function cat --description 'Use bat instead of cat'
    set -l batcat (command -s batcat) (command -s bat)
    command $batcat --style plain $argv
end

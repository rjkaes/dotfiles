function wt --description 'Create a new cloned git repo and cd into it'
    # `command` reaches past this function to ~/bin/wt; without it the call
    # recurses. The script keeps all progress and errors on stderr, so stdout is
    # just the clone path and it stays visible while being captured here.
    set -l clone_path (command wt $argv)
    or return $status

    cd $clone_path
end


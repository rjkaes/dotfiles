function w
    cd $HOME/src && cd (fd --type d -u  -d 3 '\.git$' | string replace .git/ '' | fzf)
end

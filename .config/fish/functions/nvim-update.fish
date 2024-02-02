function nvim-update
    nvim --headless "+Lazy! sync" +qa
    pushd ~/.vim
    git add lazy-lock.json && git commit -m 'chore(plugins): update' && ggpush
    popd
end

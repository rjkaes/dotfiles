function nvim-update
    nvim --headless "+Lazy! sync" +qa
    pushd ~/.config/nvim/
    git add lazy-lock.json && git commit -m 'chore(plugins): update' && ggpush
    popd
end

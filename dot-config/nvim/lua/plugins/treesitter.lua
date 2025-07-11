require('nvim-treesitter').setup({
    auto_install = true,
    disable = { 'markdown' },
    ensure_installed = { 'lua', 'vim', 'ruby', "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'text', 'mail', 'markdown' },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true,
    },
})

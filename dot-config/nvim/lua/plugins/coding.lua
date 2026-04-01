return {
    -- Surround (replaces vim-surround + vim-repeat)
    {
        'echasnovski/mini.surround',
        version = '*',
        event = 'VeryLazy',
        opts = {
            -- Use vim-surround compatible mappings to avoid conflict with leap.nvim's `s`
            mappings = {
                add = 'ys',
                delete = 'ds',
                find = '',
                find_left = '',
                highlight = '',
                replace = 'cs',
                suffix_last = '',
                suffix_next = '',
            },
        },
    },

    -- Tim Pope essentials
    { 'tpope/vim-eunuch', event = "VeryLazy" },
    { 'tpope/vim-characterize' },
    { 'tpope/vim-abolish', cmd = "Abolish" },
    { 'tpope/vim-unimpaired' },

    -- Auto pairs
    { 'windwp/nvim-autopairs', event = "InsertEnter", config = true },
    { 'windwp/nvim-ts-autotag', event = "InsertEnter", config = true },

    { 'dewyze/vim-tada' },
}

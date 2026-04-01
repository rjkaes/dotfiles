return {
    -- Surround (replaces vim-surround + vim-repeat)
    {
        'echasnovski/mini.surround',
        version = '*',
        event = 'VeryLazy',
        opts = {},
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

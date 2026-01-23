return {
    -- Comment stuff in and out with `gc`
    {
        'numToStr/Comment.nvim',
        dependencies = {'JoosepAlviste/nvim-ts-context-commentstring'},
        opts = {
            pre_hook = function()
                return
                    require("ts_context_commentstring.internal").calculate_commentstring()
            end
        }
    },

    -- A bunch of Tim Pope plugins to make using vim easier
    {'tpope/vim-eunuch', event = "VeryLazy"}, {'tpope/vim-characterize'},
    {'tpope/vim-repeat'}, {'tpope/vim-abolish', cmd = "Abolish"},
    {'tpope/vim-surround'}, {'tpope/vim-unimpaired'}, -- Auto pairs
    {'windwp/nvim-autopairs', event = "InsertEnter", config = true},
    {'windwp/nvim-ts-autotag', event = "InsertEnter", config = true},

    -- { 'cweagans/vim-taskpaper'
    {'dewyze/vim-tada'}
}

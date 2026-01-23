return {
    -- C++
    { 'bfrg/vim-cpp-modern' },
    { 'p00f/clangd_extensions.nvim' },

    -- C#
    { 'nickspoons/vim-cs',          ft = 'cs' },
    {
        "iabdelkareem/csharp.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "Tastyep/structlog.nvim",
        },
    },
    { 'jlcrochet/vim-razor' },
    {
        "GustavEikaas/easy-dotnet.nvim",
        dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
        config = function()
            require("easy-dotnet").setup()
        end
    },

    -- Crystal
    { 'vim-crystal/vim-crystal',               ft = 'crystal' },

    -- HTML
    {
        'AndrewRadev/tagalong.vim',
        init = function()
            vim.g.tagalong_additional_filetypes = { 'razor' }
        end
    },
    { 'mattn/emmet-vim' },

    -- -- Python
    -- Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

    -- Ruby
    { 'tpope/vim-rails' },
    { 'jlcrochet/vim-ruby',             ft = 'ruby' },
    { 'kana/vim-textobj-user' },
    { 'nelstrom/vim-textobj-rubyblock', ft = 'ruby' },

    -- Rust
    'rust-lang/rust.vim',

    {
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        lazy = false, -- This plugin is already lazy
    },


    -- -- Slim Templates
    { 'slim-template/vim-slim', ft = 'slim' },
}

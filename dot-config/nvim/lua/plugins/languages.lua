return {
    -- C++
    { 'bfrg/vim-cpp-modern', ft = { "c", "cpp" } },
    { 'p00f/clangd_extensions.nvim', ft = { "c", "cpp" } },

    -- C#
    { 'nickspoons/vim-cs',          ft = 'cs' },
    {
        "iabdelkareem/csharp.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "Tastyep/structlog.nvim",
        },
        config = function()
            require('csharp').setup({
                lsp = {
                    roslyn = {
                        enable = false,
                    },
                },
            })
        end,
    },
    { 'jlcrochet/vim-razor', ft = { "razor", "cshtml" } },
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
        ft = { "html", "xml", "razor", "erb", "vue", "cshtml" },
        init = function()
            vim.g.tagalong_additional_filetypes = { 'razor' }
        end
    },
    { 'mattn/emmet-vim', ft = { "html", "css", "eruby", "razor", "cshtml" } },

    -- -- Python
    -- Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

    -- Ruby
    { 'tpope/vim-rails', ft = "ruby" },
    { 'jlcrochet/vim-ruby', ft = 'ruby' },
    { 'kana/vim-textobj-user', lazy = true },
    { 'nelstrom/vim-textobj-rubyblock', ft = 'ruby' },

    -- Rust
    { 'rust-lang/rust.vim', ft = "rust" },

    {
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        lazy = false, -- This plugin is already lazy
    },


    -- -- Slim Templates
    { 'slim-template/vim-slim', ft = 'slim' },
}

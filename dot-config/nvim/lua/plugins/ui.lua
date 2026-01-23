return {
    -- colorscheme
    { 'projekt0n/github-nvim-theme', name = 'github-theme', lazy = false, priority = 1000 },

    -- Highlight hex colors, etc.
    {
        "catgoose/nvim-colorizer.lua",
        event = "VeryLazy",
        opts = {
            lazy_load = true,
        },
    },

    { 'HiPhish/rainbow-delimiters.nvim', event = "VeryLazy" },

    -- Highlight TODO, NOTE, etc.
    {
        'folke/todo-comments.nvim',
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        opts = {
            keywords = {
                nocheckin = { icon = " ", color = "error", alt = { "nc" } },
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#E06C75" },
                warning = { "#E5C07B" },
                info = { "#61AFEF" },
                hint = { "DiagnosticHint", "#8A8A8A" },
                -- default = { "Identifier", "#7C3AED" },
                -- test = { "Identifier", "#FF00FF" }
            },
        },
    },

    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        opts = {
            indent = {
                char = '┊',
            },
        },
    },

    -- Useful status updates for LSP
    {
        'j-hui/fidget.nvim',
        event = "VeryLazy",
    },

    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
            else
                -- hide the statusline on the starter page
                vim.o.laststatus = 0
            end
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- Markdown
    {
        "OXY2DEV/markview.nvim",
        ft = "markdown",
        opts = {
            experimental = {
                prefer_nvim = true,
            },
            preview = {
                filetypes = { "markdown" },
                ignore_buftypes = {},
                enable_hybrid_mode = true,
                linewise_hybrid_mode = false,
                edit_range = { 1, 1 },
            },
        },
        priority = 49,
    },

    -- Tabular
    { 'godlygeek/tabular', cmd = 'Tabularize', event = "VeryLazy" },

    -- Distraction free writing
    { 'junegunn/goyo.vim', cmd = 'Goyo',       event = "VeryLazy" },
}

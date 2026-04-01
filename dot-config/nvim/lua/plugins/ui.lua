return {
    -- colorscheme
    { 'projekt0n/github-nvim-theme', name = 'github-theme', lazy = false, priority = 1000 },

    -- Highlight hex colors, etc.
    {
        "catgoose/nvim-colorizer.lua",
        event = "VeryLazy",
        opts = {
            lazy_load = true,
            options = {},
        },
    },

    { 'HiPhish/rainbow-delimiters.nvim', event = "VeryLazy" },

    -- Highlight TODO, NOTE, etc.
    {
        'folke/todo-comments.nvim',
        cmd = { "TodoTrouble" },
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        opts = {
            keywords = {
                nocheckin = { icon = " ", color = "error", alt = { "nc" } },
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#E06C75" },
                warning = { "#E5C07B" },
                info = { "#61AFEF" },
                hint = { "DiagnosticHint", "#8A8A8A" },
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

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            presets = {
                bottom_search = false,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = false,
            },
        }
    },

    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                vim.o.statusline = " "
            else
                vim.o.laststatus = 0
            end
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- Tabular
    { 'godlygeek/tabular', cmd = 'Tabularize', event = "VeryLazy" },
}

return {
    -- Completion
    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = {
            { 'L3MON4D3/LuaSnip', version = 'v2.*' },
        },
        event = 'InsertEnter',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            snippets = { preset = 'luasnip' },
            keymap = {
                preset = 'none',
                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<C-e>'] = { 'hide', 'fallback' },
                ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
            },
            appearance = {
                nerd_font_variant = 'mono',
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            cmdline = {
                enabled = true,
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        config = function(_, opts)
            require('luasnip.loaders.from_lua').load({
                paths = { vim.fn.stdpath("config") .. "/snippets" }
            })
            require('blink.cmp').setup(opts)
        end,
    },

    -- Mason (server installer only, no config bridge needed)
    {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        opts = {},
    },

    -- Native LSP configuration
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            -- Global LSP defaults
            vim.lsp.config('*', {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
            })

            -- Enable servers (configs live in lsp/*.lua)
            vim.lsp.enable({
                'biome',
                'eslint',
                'lua_ls',
                'standardrb',
            })

            -- LSP keymaps (set on attach)
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
                callback = function(args)
                    local buf = args.buf

                    -- Override built-in LSP mappings to use snacks.picker
                    vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end,
                        { buffer = buf, desc = "LSP References" })
                    vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions() end,
                        { buffer = buf, desc = "LSP Definitions" })
                    vim.keymap.set('n', 'gi', function() Snacks.picker.lsp_implementations() end,
                        { buffer = buf, desc = "LSP Implementations" })
                    vim.keymap.set('n', 'gy', function() Snacks.picker.lsp_type_definitions() end,
                        { buffer = buf, desc = "LSP Type Definitions" })
                    vim.keymap.set('n', '<leader>ds', function() Snacks.picker.lsp_symbols() end,
                        { buffer = buf, desc = "Document Symbols" })
                end,
            })

            -- Diagnostic configuration (replaces legacy sign_define)
            vim.diagnostic.config({
                virtual_text = true,
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '',
                        [vim.diagnostic.severity.WARN] = '',
                        [vim.diagnostic.severity.INFO] = '',
                        [vim.diagnostic.severity.HINT] = '',
                    },
                },
                float = {
                    border = 'rounded',
                    source = true,
                },
            })
        end
    },

    -- Lua development (lazydev provides vim API completions)
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },

    -- Diagnostics list
    {
        'folke/trouble.nvim',
        opts = {},
        cmd = 'Trouble',
        keys = {
            { "<leader>x", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
            { "]x",        function() require("trouble").next({ skip_groups = true, jump = true }) end },
            { "[x",        function() require("trouble").previous({ skip_groups = true, jump = true }) end },
        },
    },
}

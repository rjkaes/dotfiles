return {
    -- Formatters
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cF",
                function()
                    require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
        },
        opts = {
            formatters_by_ft = {
                cs = { "csharpier" },
                csx = { "csharpier" },
                html = { "prettier" },
                javascript = { "biome", "prettier", stop_after_first = true },
                json = { "biome", "prettier", stop_after_first = true },
                lua = { "lua-format" },
                ruby = { "standardrb" },
                rust = { "rustfmt" },
                sql = { "sqlfluff", "sql_formatter", stop_after_first = true },
                typescript = { "biome", "prettier", stop_after_first = true },
                typescriptreact = { "biome", "prettier", stop_after_first = true },
                ["_"] = { "trim_whitespace" },
            },
            format_on_save = {
                lsp_fallback = true,
                timeout_ms = 1000,
            },
            formatters = {
                sql_formatter = {
                    prepend_args = { "-l", "tsql", "-c", '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }' },
                },
                sqlfluff = {
                    args = { "fix", "--dialect=tsql", "--exclude-rules=CP02", "-" },
                },
                csharpier = {
                    command = "csharpier",
                    args = { "format", "--write-stdout" },
                },
            },
        },
    },

    -- LSP Zero (Base)
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
        lazy = true,
        config = false,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
            { 'onsails/lspkind.nvim' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-cmdline' },
            { 'saadparwaiz1/cmp_luasnip' },
        },
        config = function()
            local cmp = require('cmp')
            local cmp_format = require('lspkind').cmp_format({
                mode = 'symbol_text',
                maxwidth = 50,
                ellipsis_char = '...',
                show_labelDetails = true,
            })

            require('luasnip.loaders.from_lua').load({ paths = { "~/.config/nvim/snippets" } })

            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif require('luasnip').expand_or_jumpable() then
                            require('luasnip').expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif require('luasnip').jumpable(-1) then
                            require('luasnip').jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                }),
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                formatting = {
                    fields = { 'abbr', 'kind', 'menu' },
                    format = cmp_format,
                },
            })
            
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    },
                    { name = 'path' }
                })
            })

            -- Make it clearly visible which argument we're at.
            local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
            vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, bold = true })
        end
    },

    -- LSP Config
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            -- lsp_attach is where you enable features that only work
            -- if there is a language server active in the file
            local lsp_attach = function(client, bufnr)
                local opts = { buffer = bufnr }

                lsp_zero.default_keymaps(opts)

                -- Dynamic keymaps
                vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr, desc = "LSP References" })
                vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', { buffer = bufnr, desc = "LSP Definitions" })
                vim.keymap.set({ 'n', 'x' }, 'gq', function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end, opts)
            end

            lsp_zero.extend_lspconfig({
                sign_text = {
                    error = '',
                    warn = '',
                    hint = '',
                    info = '',
                },
                lsp_attach = lsp_attach,
                float_border = 'rounded',
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })

            require('mason').setup({})
            require('mason-lspconfig').setup({
                automatic_installation = true,
                ensure_installed = {
                    'biome',
                    'eslint',
                    'lua_ls',
                    'standardrb',
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                }
            })

            -- Setup csharp plugin
            require('csharp').setup({
                lsp = {
                    roslyn = {
                        enable = false,
                    },
                },
            })
        end
    },

    -- Additional lua configuration
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        'folke/trouble.nvim',
        opts = {
            mode = 'document_diagnostics',
        },
        cmd = 'Trouble',
        keys = {
            { "<leader>x", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
            { "]x",        function() require("trouble").next({ skip_groups = true, jump = true }) end },
            { "[x",        function() require("trouble").previous({ skip_groups = true, jump = true }) end },
        },
        config = function(_, opts)
             require("trouble").setup(opts)
             local signs = {
                 Error = '',
                 Warn = '',
                 Hint = '',
                 Info = '',
             }
             for type, icon in pairs(signs) do
                 local hl = "DiagnosticSign" .. type
                 vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
             end
        end
    },
}

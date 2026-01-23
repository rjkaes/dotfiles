return {
    -- Formatters
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        config = function()
            local conform = require("conform");
            local util = require("conform.util");

            -- format microsoft t-sql
            conform.formatters.sql_formatter = {
                prepend_args = { "-l", "tsql", "-c",
                    '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }' },
            }
            conform.formatters.sqlfluff = {
                args = { "fix", "--dialect=tsql", "--exclude-rules=CP02", "-" },
            }
            conform.formatters.csharpier = {
                command = "csharpier",
                args = { "format", "--write-stdout" },
            }

            conform.setup({
                formatters_by_ft = {
                    cs = { "csharpier" },
                    csx = { "csharpier" },
                    html = { "prettier" },
                    javascript = { "biome", "prettier", stop_after_first = true },
                    json = { "biome", "prettier", stop_after_first = true },
                    ruby = { "standardrb" },
                    rust = { "rustfmt" },
                    sql = { "sqlfluff", "sql_formatter", stop_after_first = true },
                    typescript = { "biome", "prettier", stop_after_first = true },
                    typescriptreact = { "biome", "prettier", stop_after_first = true },
                    ["_"] = { "trim_whitespace" },
                },
                -- If this is set, Conform will run the formatter on save.
                -- It will pass the table to conform.format().
                -- This can also be a function that returns the table.
                format_on_save = {
                    -- I recommend these options. See :help conform.format for details.
                    lsp_fallback = true,
                    timeout_ms = 1000,
                },
            });
        end
    },

    -- LSP
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp',                    branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp' },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "saadparwaiz1/cmp_luasnip" },

            { 'hrsh7th/cmp-nvim-lsp',                branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help', branch = 'main' },
            { 'onsails/lspkind.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            local luasnip = require("luasnip")
            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action()

            local lsp_attach = function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })

                local opts = { buffer = bufnr }

                -- reformat buffer using the LSP
                vim.keymap.set({ 'n', 'x' }, 'gq', function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end, opts)
            end

            -- -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo
            local fold_text_document_capabilities = {
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    }
                }
            }

            lsp_zero.extend_lspconfig({
                capabilities = vim.tbl_deep_extend("force", require('cmp_nvim_lsp').default_capabilities(),
                    fold_text_document_capabilities),
                lsp_attach = lsp_attach,
                float_border = 'rounded',
                sign_text = {
                    error = '',
                    warn = '',
                    hint = '',
                    info = '',
                },
            })

            require('mason').setup({})
            require('csharp').setup({
                lsp = {
                    roslyn = {
                        enable = false,
                    },
                },
            })


            require('mason-lspconfig').setup({
                automatic_installation = true,
                ensure_installed = {
                    'biome',
                    'eslint',
                    'lua_ls',
                    'standardrb',
                },
            })

            -- Make sure the snippets are loaded before setting up completion.
            require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets" } })
            luasnip.config.setup({ enable_autosnippets = true })

            lsp_zero.extend_cmp()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            -- use lsp-zero tab completion helper
                            cmp_action.tab_complete()(fallback)
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = "select" })
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                formatting = {
                    expandable_indicator = true,
                    fields = { 'abbr', 'kind', 'menu' },
                    format = require('lspkind').cmp_format({
                        mode = 'symbol_text',
                        maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                    })
                },
                sources = cmp.config.sources(
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                    },
                    {
                        { name = 'path' },
                        { name = 'buffer' },
                    }
                ),
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

            lsp_zero.setup()

            -- Make it clearly visible which argument we're at.
            local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
            vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, bold = true })
        end
    },

    {
        "hrsh7th/nvim-cmp",
        branch = 'main',
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
    },

    -- Additional lua configuration, makes nvim stuff amazing
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
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
            -- Diagnostic signs
            -- https://github.com/folke/trouble.nvim/issues/52
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

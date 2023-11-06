return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp',                    branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },

            { 'hrsh7th/cmp-buffer',                  branch = 'main' },
            { 'hrsh7th/cmp-cmdline',                 branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp',                branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help', branch = 'main' },
            { 'onsails/lspkind.nvim' },

            -- omnisharp
            { 'Hoffs/omnisharp-extended-lsp.nvim' },
        },
        config = function()
            local lsp = require('lsp-zero').preset({})

            lsp.on_attach(function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp.default_keymaps({ buffer = bufnr })

                local opts = { buffer = bufnr }

                vim.keymap.set('n', 'gd', function() require('omnisharp_extended').telescope_lsp_definitions() end, opts)
                vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
                vim.keymap.set('n', 'gS', function() vim.lsp.buf.signature_help() end)
                vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, opts)

                -- reformat buffer using the LSP
                vim.keymap.set({ 'n', 'x' }, 'gq', function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end, opts)
            end)

            lsp.ensure_installed({
                'eslint',
                'lua_ls',
                'omnisharp',
                'standardrb',
                'tsserver',
            })

            lsp.set_sign_icons({
                error = '',
                warn = '',
                hint = '',
                info = '',
            })

            -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo
            lsp.set_server_config({
                capabilities = {
                    textDocument = {
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true
                        }
                    }
                }
            })

            local lsp_config= require("lspconfig")

            -- Configure lua language server for neovim
            lsp_config.lua_ls.setup(lsp.nvim_lua_ls())

            -- dotnet
            lsp_config.omnisharp.setup({
                handlers = {
                    ["textDocument/definition"] = require('omnisharp_extended').handler,
                },
                enable_roslyn_analyzers = true,
                organize_imports_on_format = true,
                enable_import_completion = true,
            })

            -- don't initialize this language server
            -- we will use rust-tools to setup rust_analyzer
            lsp.skip_server_setup({ 'rust_analyzer' })

            lsp.setup()

            -- initialize rust_analyzer with rust-tools
            local rust_tools = require('rust-tools')
            rust_tools.setup({
                server = {
                    cargo = {
                        allFeatures = true,
                    },
                    completion = {
                        postfix = {
                            enable = false,
                        },
                    },
                    on_attach = function(_, bufnr)
                        vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, { buffer = bufnr })
                    end
                }
            })

            -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#regular-tab-complete
            local cmp = require('cmp')
            local cmp_action = require('lsp-zero').cmp_action()

            cmp.setup({
                mapping = {
                    ['<CR>'] = cmp.mapping.confirm({select = true}),
                    ['<Tab>'] = cmp_action.tab_complete(),
                    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
                },
                formatting = {
                    fields = { 'abbr', 'kind', 'menu' },
                    format = require('lspkind').cmp_format({
                        mode = 'symbol_text',
                        maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                    })
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'buffer' },
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
                    }
                })
            })
        end,
    },

    -- Useful status updates for LSP
    {
        'j-hui/fidget.nvim',
        tag = 'legacy',
        opts = {
            window = {
                blend = 0,
            },
        },
    },

    -- Additional lua configuration, makes nvim stuff amazing
    { 'folke/neodev.nvim' },
}

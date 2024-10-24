local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

local lsp_attach = function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })

    local opts = { buffer = bufnr }

    vim.keymap.set('n', 'gd',
        function() require('omnisharp_extended').telescope_lsp_definition({ jump_type = "vsplit" }) end, opts)
    vim.keymap.set('n', 'gr', function() require('omnisharp_extended').telescope_lsp_references() end, opts)
    vim.keymap.set('n', 'gI', function() require('omnisharp_extended').telescope_lsp_implementation() end, opts)
    vim.keymap.set('n', 'gt', function() require('omnisharp_extended').telescope_lsp_type_definition() end, opts)
    vim.keymap.set('n', 'gS', function() vim.lsp.buf.signature_help() end)
    vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', function() vim.lsp.buf.code_action() end, opts)

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
require('mason-lspconfig').setup({
    ensure_installed = {
        'eslint',
        'lua_ls',
        'omnisharp',
        'standardrb',
    },
    handlers = {
        -- this first function is the "default handler"
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,

        -- lua_ls
        lua_ls = function()
            lspconfig.lua_ls.setup({
                on_init = function(client)
                    lsp_zero.nvim_lua_settings(client, {})
                end,
            })
        end,

        -- dotnet
        omnisharp = function()
            lspconfig.omnisharp.setup({
                handlers = {
                    ["textDocument/definition"] = require('omnisharp_extended').handler,
                },
                enable_roslyn_analyzers = true,
                organize_imports_on_format = true,
                enable_import_completion = true,
            })
        end,

        -- biome for javascript
        biome = function()
            lspconfig.biome.setup({})
        end,
    },
})

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

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
    }),
    formatting = {
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
            { name = 'buffer' },
        },
        {
            { name = 'path' },
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

-- Make it clearly visible which argument we're at.
local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, bold = true })

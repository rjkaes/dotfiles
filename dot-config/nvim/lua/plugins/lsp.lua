local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp.default_keymaps({ buffer = bufnr })

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

local lsp_config = require("lspconfig")

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

-- biome for javascript
lsp_config.biome.setup({})

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
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter',
    { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })

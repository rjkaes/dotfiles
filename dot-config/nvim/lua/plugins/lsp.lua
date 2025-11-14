local lsp_zero = require('lsp-zero')
local luasnip = require("luasnip")
local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

local lsp_attach = function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })

    local opts = { buffer = bufnr }

    vim.keymap.set('n', 'gd', function() require('omnisharp_extended').telescope_lsp_definition({ jump_type = "vsplit" }) end, opts)
    vim.keymap.set('n', 'grr', function() require('omnisharp_extended').telescope_lsp_references() end, opts)
    vim.keymap.set('n', 'gri', function() require('omnisharp_extended').telescope_lsp_implementation() end, opts)
    vim.keymap.set('n', 'grt', function() require('omnisharp_extended').telescope_lsp_type_definition() end, opts)

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
        'omnisharp',
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

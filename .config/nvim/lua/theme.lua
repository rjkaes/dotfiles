local api = vim.api

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'modus',
        component_separators = '|',
        section_separators = '',
    },

    sections = {
        lualine_b = {
            'diff',
            {
                'diagnostics',
                sources = { 'nvim_lsp', 'nvim_diagnostic' },
                colored = false,
            },
        },
        lualine_c = {
            {
                'filename',
                path = 1,
                shorten_target = 20,
            },
        },
        lualine_x = { 'encoding', 'filetype' },
    },
})

require("modus-themes").setup({
    style = "auto",
    styles = {
        keywords = { italic = true },
        statements = { bold = true },
        functions = { bold = true },
    },
    on_colors = function(colors)
        colors.cursor = colors.green_intense
    end,
})

-- setup must be called before loading
vim.cmd("colorscheme modus")

-- Dull the mail signature
api.nvim_set_hl(0, 'mailSignature', { link = 'Comment' })

-- Colour neotest
api.nvim_set_hl(0, 'NeotestPassed', { link = 'GitSignsAddLn' })
api.nvim_set_hl(0, 'NeotestFailed', { link = 'GitSignsAddInline' })
api.nvim_set_hl(0, 'NeotestRunning', { link = 'TroubleSignWarning' })

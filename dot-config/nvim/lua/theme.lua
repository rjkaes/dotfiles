local api = vim.api

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'zenwritten',
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

vim.g.zenwritten_colorize_diagnostic_underline_text = true
vim.g.zenwritten_darken_noncurrent_window = true
vim.g.zenwritten_lightness = 'bright'
vim.g.zenwritten_solid_float_border = true
vim.g.zenwritten_solid_line_nr = true
vim.g.zenwritten_vert_split = true
vim.cmd("colorscheme grey")

vim.o.guicursor = ""

-- Dull the mail signature
api.nvim_set_hl(0, 'mailSignature', { link = 'Comment' })

-- Colour neotest
api.nvim_set_hl(0, 'NeotestPassed', { link = 'GitSignsAddLn' })
api.nvim_set_hl(0, 'NeotestFailed', { link = 'GitSignsAddInline' })
api.nvim_set_hl(0, 'NeotestRunning', { link = 'TroubleSignWarning' })

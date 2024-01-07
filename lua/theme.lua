local api = vim.api

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'powerline',
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

require('kanagawa').setup({
    compile = false,
    undercurl = true,
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,
    dimInactive = false,
    terminalColors = true,
    colors = {
        palette = {
            -- Taken from catppuccin latte and lightened by 2%
            lotusWhite0 = "#B2B5C3", -- #d5cea3, hsl(51.6, 37.31%, 73.73%)
            lotusWhite1 = "#C2C6D1", -- #dcd5ac, hsl(51.25, 40.68%, 76.86%)
            lotusWhite2 = "#D3D6DF", -- #e5ddb0, hsl(50.94, 50.48%, 79.41%)
            lotusWhite3 = "#F6F7F9", -- #f2ecbc, hsl(53.33, 67.5%, 84.31%)
            lotusWhite4 = "#ECEFF3", -- #e7dba0, hsl(49.86, 59.66%, 76.67%)
            lotusWhite5 = "#E3E6ED", -- #e4d794, hsl(50.25, 59.7%, 73.73%)
        },
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(_colors)
        return {
            Cursor = { bg = '#52AD70' },
        }
    end,
    background = {
        dark = "dragon",
        light = "lotus"
    },
})

-- setup must be called before loading
vim.cmd("colorscheme kanagawa")

-- Dull the mail signature
api.nvim_set_hl(0, 'mailSignature', { link = 'Comment' })

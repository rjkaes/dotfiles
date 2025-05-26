local api = vim.api
local background = vim.opt.background:get()

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'newpaper-' .. background,
        section_separators = { "", "" },
        component_separators = { "│", "│" }
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
            {
                function()
                    local recording_register = vim.fn.reg_recording()
                    if recording_register == '' then
                        return ''
                    else
                        return 'Recording @' .. recording_register
                    end
                end,
                color = { fg = '#ff9e64', gui = 'bold' },
            },
        },
        lualine_x = { 'encoding', 'filetype' },
    },
})

local themes = {
    light = {
        style = "light",
        saturation = -0.2,
        lightness = 0.1,
    },
    dark = {
        style = "dark",
        saturation = 0.1,
        lightness = -0.2,
    },
}

require("newpaper").setup(themes[background])

vim.o.guicursor = ""

-- Dull the mail signature
api.nvim_set_hl(0, 'mailSignature', { link = 'Comment' })

-- Colour neotest
api.nvim_set_hl(0, 'NeotestPassed', { link = 'GitSignsAddLn' })
api.nvim_set_hl(0, 'NeotestFailed', { link = 'GitSignsAddInline' })
api.nvim_set_hl(0, 'NeotestRunning', { link = 'TroubleSignWarning' })

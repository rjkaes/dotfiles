local api = vim.api
local background = vim.opt.background:get()

if background == "dark" then
    vim.cmd([[colorscheme claude-dark]])
else
    vim.cmd([[colorscheme claude-light]])
end

require('lualine').setup({
    options = {
        theme = "papercolor_" .. background,
        icons_enabled = true,
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

vim.o.guicursor = ""

-- Dull the mail signature
api.nvim_set_hl(0, 'mailSignature', { link = 'Comment' })

-- Colour neotest
api.nvim_set_hl(0, 'NeotestPassed', { link = 'GitSignsAddLn' })
api.nvim_set_hl(0, 'NeotestFailed', { link = 'GitSignsAddInline' })
api.nvim_set_hl(0, 'NeotestRunning', { link = 'TroubleSignWarning' })

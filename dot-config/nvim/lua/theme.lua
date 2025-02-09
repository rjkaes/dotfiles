local api = vim.api
local background = vim.opt.background:get()

---- Colourful Themes

local themes = {
    light = {
        style = "light",
        saturation = -0.2,
        lightness = 0.1,
    },
    dark = {
        style = "dark",
        disable_background = true,
        saturation = 0.1,
        -- lightness = -0.2,
    },
}

-- require("newpaper").setup(themes[background])

-- vim.g.sonokai_style = "maia"
-- vim.g.sonokai_enable_italic = 0
-- vim.g.sonokai_diagnostic_text_highlight = 1
-- vim.g.sonokai_diagnostic_line_highlight = 1
-- vim.g.sonokai_diagnostic_virtual_text = "highlighted"
-- vim.cmd.colorscheme('sonokai')

---- Monochrome themes

if background == "dark" then
    require('no-clown-fiesta').setup({
        styles = {
            comments = { italic = true },
            functions = {},
            keywords = {},
            lsp = { underline = true },
            match_paren = {},
            type = {},
            variables = {},
        },
    })

    vim.cmd("colorscheme no-clown-fiesta")
else
    -- Light
    vim.g.zenwritten = {
        colorize_diagnostic_underline_text = true,
        darken_noncurrent_window = false,
        lightness = 'bright',
        solid_float_border = true,
        solid_line_nr = true,
        vert_split = true,
    }

    vim.cmd("colorscheme zenwritten")
end

require('lualine').setup({
    options = {
        icons_enabled = true,
        -- theme = 'newpaper-' .. background,
        -- theme = "sonokai",
        theme = "zenwritten",
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

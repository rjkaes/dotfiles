-- Make sure these are always loaded regardless of what colorscheme is used.
local dependencies = {
    -- Hightlight hex colors, etc.
    { 'NvChad/nvim-colorizer.lua', name = 'colorizer', lazy = false, config = true },

    -- Add missing LSP colors
    { 'folke/lsp-colors.nvim', name = 'lsp-colors', lazy = false, config = true },
}

return {
    { 'navarasu/onedark.nvim', priority = 1000, dependencies = dependencies },
    { 'rebelot/kanagawa.nvim', priority = 1000, dependencies = dependencies },

    -- Highlight TODO, NOTE, etc.
    {
        'folke/todo-comments.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        opts = {
            keywords = {
                nocheckin = { icon = " ", color = "error", alt = { "nc" } },
            },
        },
    },
}

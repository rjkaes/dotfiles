return {
    -- Replace matchit.vim and matchparen
    { 'andymass/vim-matchup', event = { "BufReadPost", "BufNewFile" } },

    -- Toggle multiple terminals
    {
        'akinsho/toggleterm.nvim',
        event = "VeryLazy",
        opts = {
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]],
            direction = 'vertical',
        }
    },

    -- Undo tree
    { 'mbbill/undotree', cmd = "UndotreeToggle" },
}

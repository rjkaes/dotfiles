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

    {
        url = "https://codeberg.org/andyg/leap.nvim",
        keys = {
            { "s", mode = { "n", "x", "o" }, desc = "Leap" },
            { "S", mode = "n", desc = "Leap from window" },
        },
        config = function()
            vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
            vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')

            require('leap').opts.preview = function (ch0, ch1, ch2)
                return not (
                    ch1:match('%s')
                    or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
                )
            end

            require('leap').opts.equivalence_classes = {
                ' \t\r\n', '([{', ')]}', '\'"'
            }
        end,
    },
}

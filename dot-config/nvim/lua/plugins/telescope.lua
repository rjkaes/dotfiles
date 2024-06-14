local telescope = require('telescope')

telescope.setup({
    defaults = {
        -- These three settings are optional, but recommended.
        prompt_prefix = '',
        entry_prefix = ' ',
        selection_caret = ' ',

        -- This is the important part: without this, Telescope windows will look a
        -- bit odd due to how borders are highlighted.
        layout_strategy = 'grey',
        layout_config = {
            -- The extension supports both "top" and "bottom" for the prompt.
            prompt_position = 'top',

            -- You can adjust these settings to your liking.
            width = 0.6,
            height = 0.5,
            preview_width = 0.6,
        },
    },
    pickers = {
        find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
        },
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = true,
            override_file_sorter = true,
        }
    },
})

pcall(telescope.load_extension('fzy_native'))
pcall(telescope.load_extension('grey'))

vim.keymap.set('n', "<C-p>", require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', "<leader>j", require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', "<leader>f", require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', "<leader>t", "<cmd>Telescope tags<cr>")

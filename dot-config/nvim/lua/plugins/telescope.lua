local telescope = require('telescope')

telescope.setup({
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

vim.keymap.set('n', "<C-p>", require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', "<leader>j", require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', "<leader>f", require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', "<leader>t", "<cmd>Telescope tags<cr>")

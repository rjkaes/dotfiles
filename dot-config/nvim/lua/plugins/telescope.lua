local telescope = require('telescope')
local telescopeConfig = require("telescope.config")
local builtin = require("telescope.builtin")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

telescope.setup({
    defaults = {
        -- `hidden = true` is not supported in text grep commands.
        vimgrep_arguments = vimgrep_arguments,
    },
    pickers = {
        find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
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

vim.keymap.set('n', "<C-p>", builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', "<leader>j", builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', "<leader>f", builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', "<leader>t", "<cmd>Telescope tags<cr>")

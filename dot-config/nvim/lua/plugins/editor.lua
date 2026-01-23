return {
    { 'voldikss/vim-floaterm', lazy = true },

    -- Tree
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = true,
    },

    -- telescope
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-fzy-native.nvim',
        },
        cmd = "Telescope",
        event = "VeryLazy",
        config = function()
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
                    preview = {
                        treesitter = false,
                        hide_on_startup = true,
                    },
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
        end
    },
    'nvim-telescope/telescope-symbols.nvim',

    -- Replace matchit.vim and matchparen
    { 'andymass/vim-matchup' },

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
    { 'mbbill/undotree' },

    {
        'ggandor/leap.nvim',
        lazy = false,
        config = function()
            vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
            vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')

            require('leap').opts.preview = function (ch0, ch1, ch2) 
                return not (
                    ch1:match('%s')
                    or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
                )
            end

            -- Define equivalence classes for brackets and quotes, in addition to
            -- the default whitespace group:
            require('leap').opts.equivalence_classes = {
                ' \t\r\n', '([{', ')]}', '\'"'
            }

        end,
    },
}

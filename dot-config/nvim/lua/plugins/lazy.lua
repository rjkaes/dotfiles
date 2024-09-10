-- Start up the package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Fixes Notify opacity issues
vim.o.termguicolors = true

-- Setup lazy package manager.
require("lazy").setup({
    { 'nvim-lua/popup.nvim',   lazy = true },
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'voldikss/vim-floaterm', lazy = true },

    -- colorscheme
    {
        'rjkaes/newpaper.nvim',
        dependencies = {
            'yorik1984/lualine-theme.nvim',
            'nvim-lualine/lualine.nvim',
        },
        priority = 1000,
        lazy = false
    },

    -- Hightlight hex colors, etc.
    { 'NvChad/nvim-colorizer.lua',       name = 'colorizer',  event = "VeryLazy", config = true },
    -- Add missing LSP colors
    { 'folke/lsp-colors.nvim',           name = 'lsp-colors', event = "VeryLazy", config = true },

    { 'HiPhish/rainbow-delimiters.nvim', event = "VeryLazy" },

    -- Highlight TODO, NOTE, etc.
    {
        'folke/todo-comments.nvim',
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        opts = {
            keywords = {
                nocheckin = { icon = " ", color = "error", alt = { "nc" } },
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "#FBBF24" },
                info = { "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" }
            },
        },
    },

    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            {
                "stevearc/dressing.nvim",
                opts = {},
            },
        },
        opts = {
            strategies = {
                chat = {
                    adapter = "copilot",
                },
                inline = {
                    adapter = "copilot",
                },
                agent = {
                    adapter = "copilot",
                },
            },
        },
    },

    -- AI powered auto-completion
    {
        'Exafunction/codeium.vim',
        event = 'BufEnter',
        config = function()
            vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
            vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end,
                { expr = true, silent = true })
            vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end,
                { expr = true, silent = true })
            vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
        end
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = false,        -- use a classic bottom cmdline for search
                command_palette = true,       -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false,       -- add a border to hover docs and signature help
            },
        }
    },
    {
        "rcarriga/nvim-notify",
        lazy = true,
        opts = {
            render = "compact",
            timeout = 500,
            fps = 10,
            stages = "static",
        },
    },

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

    -- Comment stuff in and out with `gc`
    {
        'numToStr/Comment.nvim',
        dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
        opts = {
            pre_hook = function()
                return
                    require("ts_context_commentstring.internal").calculate_commentstring()
            end
        },
    },

    -- A bunch of Tim Pope plugins to make using vim easier
    { 'tpope/vim-eunuch',      event = "VeryLazy" },
    { 'tpope/vim-characterize' },
    { 'tpope/vim-endwise',     ft = { 'lua', 'elixir', 'ruby', 'crystal', 'sh', 'bash', 'zsh', 'vim', 'c', 'cpp', 'make' } },
    { 'tpope/vim-repeat' },
    { 'tpope/vim-abolish',     cmd = "Abolish" },
    { 'tpope/vim-surround' },
    { 'tpope/vim-unimpaired' },
    {
        'tpope/vim-fugitive',
        event = "VeryLazy",
        dependencies = { 'tpope/vim-rhubarb' },
    },
    { 'tommcdo/vim-fubitive', cmd = "Gbrowse" },

    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        opts = {
            indent = {
                char = '┊',
            },
        },
    },

    -- Make using git nicer
    { 'NeogitOrg/neogit',     event = "VeryLazy", cmd = "Neogit", branch = "master", config = true },
    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    },

    -- Tabular
    { 'godlygeek/tabular', cmd = 'Tabularize', event = "VeryLazy" },

    -- Distraction free writing
    { 'junegunn/goyo.vim', cmd = 'Goyo',       event = "VeryLazy" },

    -- Undo tree
    { 'mbbill/undotree' },

    {
        'ggandor/leap.nvim',
        lazy = false,
        config = function()
            require('leap').add_default_mappings()
        end,
    },

    -- { 'cweagans/vim-taskpaper'
    { 'dewyze/vim-tada' },

    { 'ThePrimeagen/harpoon', branch = 'harpoon2', dependencies = { 'nvim-lua/plenary.nvim' } },

    -- Test runner
    {
        "nvim-neotest/neotest",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "Issafalcon/neotest-dotnet",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-dotnet")({
                        discovery_root = "solution"
                    }),
                }
            })
        end
    },

    -- C++
    { 'bfrg/vim-cpp-modern' },
    { 'p00f/clangd_extensions.nvim' },

    -- C#
    { 'jlcrochet/vim-razor' },
    { 'tmadsen/vim-compiler-plugin-for-dotnet' },

    -- Crystal
    { 'vim-crystal/vim-crystal',               ft = 'crystal' },

    -- HTML
    {
        'AndrewRadev/tagalong.vim',
        init = function()
            vim.g.tagalong_additional_filetypes = { 'razor' }
        end
    },
    { 'mattn/emmet-vim' },

    -- markdown
    -- { 'preservim/vim-markdown' },

    -- -- Python
    -- Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

    -- Ruby
    { 'tpope/vim-rails' },
    { 'jlcrochet/vim-ruby',             ft = 'ruby' },
    { 'kana/vim-textobj-user' },
    { 'nelstrom/vim-textobj-rubyblock', ft = 'ruby' },

    -- Rust
    'rust-lang/rust.vim',

    {
        'simrat39/rust-tools.nvim',
        ft = { 'rust', 'rs' },
        opts = {
            server = {
                settings = {
                    ['rust-analyzer'] = {
                        cargo = {
                            allFeatures = true,
                        },
                        completion = {
                            postfix = {
                                enable = false,
                            },
                        },
                    },
                },
            },

        },
    },

    -- -- Slim Templates
    { 'slim-template/vim-slim', ft = 'slim' },

    -- Formatters
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
    },

    -- LSP
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp',                    branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },

            { 'hrsh7th/cmp-buffer',                  branch = 'main' },
            { 'hrsh7th/cmp-cmdline',                 branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp',                branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help', branch = 'main' },
            { 'onsails/lspkind.nvim' },

            -- omnisharp
            { 'Hoffs/omnisharp-extended-lsp.nvim' },
        },
    },

    -- Useful status updates for LSP
    {
        'j-hui/fidget.nvim',
        event = "VeryLazy",
    },

    -- Additional lua configuration, makes nvim stuff amazing
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
            else
                -- hide the statusline on the starter page
                vim.o.laststatus = 0
            end
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- treesitter
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        event = { "VeryLazy", "BufReadPost", "BufNewFile", "BufWritePre" },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        build = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    },

    -- Additional text objects via treesitter
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = "VeryLazy",
        enabled = true,
    },

    {
        'folke/trouble.nvim',
        opts = {
            mode = 'document_diagnostics',
        },
        cmd = 'Trouble',
    },

    {
        'kevinhwang91/nvim-ufo',
        event = { "VeryLazy", "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = { 'kevinhwang91/promise-async' },
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { 'treesitter', 'indent' }
            end,
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (' 󰁂 %d '):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, 'MoreMsg' })
                return newVirtText
            end,
        },
        init = function()
            -- Using ufo provider need a large value, feel free to decrease the value
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = true

            vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end)
            vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end)
        end,
    },
}, {
    ui = {
        icons = {
            cmd = "⌘",
            config = "🛠️",
            event = "📅",
            ft = "📂",
            init = "⚙️",
            keys = "🗝️",
            plugin = "🔌",
            runtime = "💻",
            source = "📄",
            start = "🚀",
            task = "📌",
        },
    },
})

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
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'voldikss/vim-floaterm' },

    -- theme
    { 'rebelot/kanagawa.nvim', priority = 1000, dependencies =
        -- Hightlight hex colors, etc.
        { 'NvChad/nvim-colorizer.lua', name = 'colorizer', lazy = false, config = true },

        -- Add missing LSP colors
        { 'folke/lsp-colors.nvim', name = 'lsp-colors', lazy = false, config = true },
    },

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

    -- Tree
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },

    -- telescope
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', enabled = vim.fn.executable 'make' == 1 },
        },
    },
    'nvim-telescope/telescope-symbols.nvim',

    -- Replace matchit.vim and matchparen
    { 'andymass/vim-matchup' },

    -- Toggle multiple terminals
    {
        'akinsho/toggleterm.nvim',
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
    { 'numToStr/Comment.nvim', config = true },

    -- A bunch of Tim Pope plugins to make using vim easier
    { 'tpope/vim-eunuch' },
    { 'tpope/vim-characterize' },
    { 'tpope/vim-endwise', ft = { 'lua', 'elixir', 'ruby', 'crystal', 'sh', 'bash', 'zsh', 'vim', 'c', 'cpp', 'make' } },
    { 'tpope/vim-repeat' },
    { 'tpope/vim-abolish' },
    { 'tpope/vim-surround' },
    { 'tpope/vim-unimpaired' },
    { 'kassio/neoterm' },
    {
        'janko-m/vim-test',
        dependencies = {
            'radenling/vim-dispatch-neovim',
            dependencies = { 'tpope/vim-dispatch' },
        },
    },
    {
        'tpope/vim-fugitive',
        dependencies = { 'tpope/vim-rhubarb' },
    },
    { 'tommcdo/vim-fubitive' },

    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {
            indent = {
                char = '┊',
            },
        },
    },

    -- Make using git nicer
    { 'NeogitOrg/neogit', config = true },
    { 'lewis6991/gitsigns.nvim' },

    -- Tabular
    { 'godlygeek/tabular', cmd = 'Tabularize' },

    -- Distraction free writing
    { 'junegunn/goyo.vim', cmd = 'Goyo' },

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

    -- C++
    { 'bfrg/vim-cpp-modern' },
    { 'p00f/clangd_extensions.nvim' },

    -- C#
    { 'jlcrochet/vim-razor' },
    { 'tmadsen/vim-compiler-plugin-for-dotnet' },

    -- Crystal
    { 'vim-crystal/vim-crystal', ft = 'crystal' },

    -- HTML
    {
        'AndrewRadev/tagalong.vim',
        init = function()
            vim.g.tagalong_additional_filetypes = {'razor'}
        end
    },
    { 'mattn/emmet-vim' },

    -- markdown
    { 'preservim/vim-markdown' },

    -- -- Python
    -- Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }

    -- Ruby
    { 'tpope/vim-rails' },
    { 'jlcrochet/vim-ruby' },
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
        -- optional = true,
        opts = {
            formatters_by_ft = {
                cs = { "csharpier" },
                html = { "prettier" },
                javascript = { { "biome", "prettier" } },
                ruby = { "standardrb" },
                rust = { "rustfmt" },
                ["_"] = { "trim_whitespace" },
            },
            formatters = {
                csharpier = {
                    command = "dotnet-csharpier",
                    args = { "--write-stdout" },
                },
            },
        },
    },

    -- LSP
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp',                    branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip', version = "v2.*" },

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
        tag = 'legacy',
        opts = {
            window = {
                blend = 0,
            },
        },
    },

    -- Additional lua configuration, makes nvim stuff amazing
    { 'folke/neodev.nvim' },

    {
        'nvim-lualine/lualine.nvim',
        lazy = false,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- treesitter
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    },

    -- Additional text objects via treesitter
    { 'nvim-treesitter/nvim-treesitter-textobjects' },

    {
        'folke/trouble.nvim',
        opts = {
            mode = 'document_diagnostics',
        },
        cmd = 'TroubleToggle',
    },

    {
        'kevinhwang91/nvim-ufo',
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
                        table.insert(newVirtText, {chunkText, hlGroup})
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, {suffix, 'MoreMsg'})
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

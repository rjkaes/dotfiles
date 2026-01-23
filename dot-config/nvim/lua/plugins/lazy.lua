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
    { 'projekt0n/github-nvim-theme', name = 'github-theme', lazy = false, priority = 1000 },

    -- Highlight hex colors, etc.
    {
        "catgoose/nvim-colorizer.lua",
        event = "VeryLazy",
        opts = {
            lazy_load = true,
        },
    },

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
                error = { "DiagnosticError", "ErrorMsg", "#E06C75" },
                warning = { "#E5C07B" },
                info = { "#61AFEF" },
                hint = { "DiagnosticHint", "#8A8A8A" },
                -- default = { "Identifier", "#7C3AED" },
                -- test = { "Identifier", "#FF00FF" }
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
        config = function()
            require("codecompanion").setup({
                adapters = {
                    http = {
                        opts = {
                            show_defaults = false,
                        },
                        deepseek = function()
                            return require("codecompanion.adapters").extend("ollama", {
                                name = "deekseek",
                                schema = {
                                    model = {
                                        default = "deepseek-coder-v2:16b",
                                    },
                                    num_ctx = {
                                        default = 65536,
                                    },
                                    max_tokens = {
                                        default = 65536,
                                    },
                                    top_p = {
                                        default = 0.95,
                                    },
                                },
                            })
                        end,
                        qwencoder = function()
                            return require("codecompanion.adapters").extend("ollama", {
                                name = "qwencoder",
                                opts = {
                                    stream = true,
                                },
                                schema = {
                                    model = {
                                        default = "qwen3-coder:30b",
                                    },
                                    num_ctx = {
                                        default = 65536,
                                    },
                                    temperature = {
                                        default = 0.2,
                                    },
                                    -- top_p = {
                                    --     default = 0.95,
                                    -- },
                                    max_tokens = {
                                        default = 65536,
                                    },
                                    keep_alive = {
                                        default = '5m',
                                    },
                                },
                            })
                        end,
                    },
                },
                -- strategies = {
                --     chat = {
                --         adapter = "qwencoder",
                --     },
                --     inline = {
                --         adapter = "deepseek",
                --     },
                --     agent = {
                --         adapter = "deepseek",
                --     },
                -- },
                interactions = {
                    chat = {
                        adapter = "gemini_cli",
                    }
                }
            })
        end
    },

    -- {
    --     "folke/noice.nvim",
    --     event = "VeryLazy",
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "rcarriga/nvim-notify",
    --     },
    --     opts = {
    --         lsp = {
    --             -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    --             override = {
    --                 ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
    --                 ["vim.lsp.util.stylize_markdown"] = true,
    --                 ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    --             },
    --         },
    --         -- you can enable a preset for easier configuration
    --         presets = {
    --             bottom_search = false,        -- use a classic bottom cmdline for search
    --             command_palette = true,       -- position the cmdline and popupmenu together
    --             long_message_to_split = true, -- long messages will be sent to a split
    --             inc_rename = false,           -- enables an input dialog for inc-rename.nvim
    --             lsp_doc_border = false,       -- add a border to hover docs and signature help
    --         },
    --     }
    -- },
    -- {
    --     "rcarriga/nvim-notify",
    --     lazy = true,
    --     opts = {
    --         render = "compact",
    --         timeout = 500,
    --         fps = 10,
    --         stages = "static",
    --     },
    -- },

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
        config = function()
            require('gitsigns').setup({
                current_line_blame = false,
                on_attach = function(bufnr)
                    local function map(mode, lhs, rhs, opts)
                        opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
                        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
                    end

                    -- Navigation
                    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
                    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

                    -- Actions
                    map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
                    map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
                    map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
                    map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
                    map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
                    map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
                    map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
                    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
                    map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
                    map('n', '<leader>htb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
                    map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
                    map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
                    map('n', '<leader>htd', '<cmd>Gitsigns toggle_deleted<CR>')

                    -- Text object
                    map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                    map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end,
            })
        end
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
                ' \t\r\n', '([{', ')]}', '\'"`'
            }

        end,
    },

    -- { 'cweagans/vim-taskpaper'
    { 'dewyze/vim-tada' },

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
    { 'nickspoons/vim-cs',          ft = 'cs' },
    {
        "iabdelkareem/csharp.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "Tastyep/structlog.nvim",
        },
    },
    { 'jlcrochet/vim-razor' },
    {
        "GustavEikaas/easy-dotnet.nvim",
        dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
        config = function()
            require("easy-dotnet").setup()
        end
    },

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
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        lazy = false, -- This plugin is already lazy
    },


    -- -- Slim Templates
    { 'slim-template/vim-slim', ft = 'slim' },

    -- Formatters
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        config = function()
            local conform = require("conform");
            local util = require("conform.util");

            -- format microsoft t-sql
            conform.formatters.sql_formatter = {
                prepend_args = { "-l", "tsql", "-c",
                    '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }' },
            }
            conform.formatters.sqlfluff = {
                args = { "fix", "--dialect=tsql", "--exclude-rules=CP02", "-" },
            }
            conform.formatters.csharpier = {
                command = "csharpier",
                args = { "format", "--write-stdout" },
            }

            conform.setup({
                formatters_by_ft = {
                    cs = { "csharpier" },
                    csx = { "csharpier" },
                    html = { "prettier" },
                    javascript = { "biome", "prettier", stop_after_first = true },
                    json = { "biome", "prettier", stop_after_first = true },
                    ruby = { "standardrb" },
                    rust = { "rustfmt" },
                    sql = { "sqlfluff", "sql_formatter", stop_after_first = true },
                    typescript = { "biome", "prettier", stop_after_first = true },
                    typescriptreact = { "biome", "prettier", stop_after_first = true },
                    ["_"] = { "trim_whitespace" },
                },
                -- If this is set, Conform will run the formatter on save.
                -- It will pass the table to conform.format().
                -- This can also be a function that returns the table.
                format_on_save = {
                    -- I recommend these options. See :help conform.format for details.
                    lsp_fallback = true,
                    timeout_ms = 1000,
                },
            });
        end
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

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "saadparwaiz1/cmp_luasnip" },

            { 'hrsh7th/cmp-nvim-lsp',                branch = 'main' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help', branch = 'main' },
            { 'onsails/lspkind.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            local luasnip = require("luasnip")
            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action()

            local lsp_attach = function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })

                local opts = { buffer = bufnr }

                -- reformat buffer using the LSP
                vim.keymap.set({ 'n', 'x' }, 'gq', function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end, opts)
            end

            -- -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo
            local fold_text_document_capabilities = {
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    }
                }
            }

            lsp_zero.extend_lspconfig({
                capabilities = vim.tbl_deep_extend("force", require('cmp_nvim_lsp').default_capabilities(),
                    fold_text_document_capabilities),
                lsp_attach = lsp_attach,
                float_border = 'rounded',
                sign_text = {
                    error = '',
                    warn = '',
                    hint = '',
                    info = '',
                },
            })

            require('mason').setup({})
            require('csharp').setup({
                lsp = {
                    roslyn = {
                        enable = false,
                    },
                },
            })


            require('mason-lspconfig').setup({
                automatic_installation = true,
                ensure_installed = {
                    'biome',
                    'eslint',
                    'lua_ls',
                    'standardrb',
                },
            })

            -- Make sure the snippets are loaded before setting up completion.
            require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/snippets" } })
            luasnip.config.setup({ enable_autosnippets = true })

            lsp_zero.extend_cmp()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            -- use lsp-zero tab completion helper
                            cmp_action.tab_complete()(fallback)
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = "select" })
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                formatting = {
                    expandable_indicator = true,
                    fields = { 'abbr', 'kind', 'menu' },
                    format = require('lspkind').cmp_format({
                        mode = 'symbol_text',
                        maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                    })
                },
                sources = cmp.config.sources(
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                    },
                    {
                        { name = 'path' },
                        { name = 'buffer' },
                    }
                ),
            })

            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    },
                    { name = 'path' }
                })
            })

            lsp_zero.setup()

            -- Make it clearly visible which argument we're at.
            local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
            vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, bold = true })
        end
    },

    {
        "hrsh7th/nvim-cmp",
        branch = 'main',
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
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

    -- Markdown
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        opts = {
            experimental = {
                prefer_nvim = true,
            },
            preview = {
                filetypes = { "markdown" },
                ignore_buftypes = {},
                enable_hybrid_mode = true,
                linewise_hybrid_mode = false,
                edit_range = { 1, 1 },
            },
        },
        priority = 49,
    },

    -- treesitter
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        event = { "VeryLazy", "BufReadPost", "BufNewFile", "BufWritePre" },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        build = function()
            require('nvim-treesitter').update()
        end,
        dependencies = {
            "OXY2DEV/markview.nvim"
        },
        config = function()
            require('nvim-treesitter').setup({
                auto_install = true,
                disable = { 'markdown' },
                ensure_installed = { 'lua', 'vim', 'ruby', "c_sharp", "git_config", "gitcommit", "git_rebase", "gitignore",
                    "gitattributes" },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
            })

            -- Start treesitter if the parser is installed for the filetype when opening.
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local ft = args.match
                    local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
                    if not ok then
                        return
                    end

                    -- Check if parser is actually available
                    local has_parser = #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0
                    if has_parser then
                        pcall(vim.treesitter.start, args.buf, lang)

                        -- Enable folds
                        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    end
                end,
            })
        end
    },

    -- Additional text objects via treesitter
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        event = "VeryLazy",
        enabled = true,
    },

    {
        'folke/trouble.nvim',
        opts = {
            mode = 'document_diagnostics',
        },
        cmd = 'Trouble',
        keys = {
            { "<leader>x", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
            { "]x",        function() require("trouble").next({ skip_groups = true, jump = true }) end },
            { "[x",        function() require("trouble").previous({ skip_groups = true, jump = true }) end },
        },
        config = function(_, opts)
            require("trouble").setup(opts)
            -- Diagnostic signs
            -- https://github.com/folke/trouble.nvim/issues/52
            local signs = {
                Error = '',
                Warn = '',
                Hint = '',
                Info = '',
            }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end
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

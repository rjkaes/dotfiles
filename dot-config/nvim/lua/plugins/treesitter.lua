return {
    -- treesitter
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = function()
            require('nvim-treesitter').update()
        end,
        dependencies = {
            "RRethy/nvim-treesitter-endwise",
        },
        config = function()
            require('nvim-treesitter.configs').setup({
                auto_install = true,
                ensure_installed = { 'lua', 'vim', 'ruby', "c_sharp", "git_config", "gitcommit", "git_rebase", "gitignore",
                    "gitattributes", "yaml" },
                highlight = {
                    enable = true,
                    disable = { 'markdown' },
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
                endwise = {
                    enable = true,
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
                        local ok, err = pcall(vim.treesitter.start, args.buf, lang)
                        if not ok then
                            vim.notify("Treesitter: " .. tostring(err), vim.log.levels.DEBUG)
                            return
                        end

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
        'kevinhwang91/nvim-ufo',
        event = { "BufReadPost", "BufNewFile" },
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
}

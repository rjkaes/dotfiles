-- Treesitter configuration using native Neovim 0.12+ APIs.
-- Parsers and queries are pre-installed in ~/.local/share/nvim/site/.
-- To add a new parser, use :TSInstall <lang> (defined below).

-- Desired parsers; checked at startup and installable via :TSInstall.
local parsers = {
    'bash', 'c_sharp', 'css', 'git_config', 'gitattributes',
    'gitcommit', 'git_rebase', 'gitignore', 'html', 'javascript',
    'json', 'lua', 'markdown', 'markdown_inline', 'python',
    'regex', 'ruby', 'rust', 'sql', 'tsx', 'typescript', 'vim',
    'vimdoc', 'yaml',
}

-- Check for parsers that aren't installed yet and warn once.
vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        local missing = {}
        for _, lang in ipairs(parsers) do
            local ok = pcall(vim.treesitter.language.add, lang)
            if not ok then
                table.insert(missing, lang)
            end
        end
        if #missing > 0 then
            vim.notify(
                'Treesitter parsers not installed: ' .. table.concat(missing, ', ')
                    .. '\nRun :TSInstall <lang> to install.',
                vim.log.levels.WARN
            )
        end
    end,
    once = true,
})

-- :TSInstall <lang> -- clone grammar repo, compile with tree-sitter CLI,
-- and place the .so + queries in the site directory.
vim.api.nvim_create_user_command('TSInstall', function(opts)
    local lang = opts.fargs[1]
    if not lang or lang == '' then
        vim.notify('Usage: :TSInstall <language>', vim.log.levels.ERROR)
        return
    end

    local site = vim.fn.stdpath('data') .. '/site'
    local parser_dir = site .. '/parser'
    local queries_dir = site .. '/queries'
    vim.fn.mkdir(parser_dir, 'p')

    -- Use nvim-treesitter's parser list as a registry for git URLs.
    -- Fallback: assume tree-sitter-<lang> on GitHub.
    local repo = ('https://github.com/tree-sitter/tree-sitter-%s'):format(lang)

    local tmp = vim.fn.tempname()
    vim.notify(('TSInstall: cloning %s...'):format(lang))

    vim.system(
        { 'git', 'clone', '--depth=1', '--single-branch', repo, tmp },
        {},
        vim.schedule_wrap(function(clone_result)
            if clone_result.code ~= 0 then
                vim.notify(
                    ('TSInstall: failed to clone %s\n%s'):format(repo, clone_result.stderr or ''),
                    vim.log.levels.ERROR
                )
                return
            end

            -- Some grammars nest the source under src/, others at root.
            -- tree-sitter build handles this automatically.
            local so_path = ('%s/%s.so'):format(parser_dir, lang)

            vim.notify(('TSInstall: compiling %s...'):format(lang))
            vim.system(
                { 'tree-sitter', 'build', '-o', so_path, tmp },
                {},
                vim.schedule_wrap(function(build_result)
                    if build_result.code ~= 0 then
                        vim.notify(
                            ('TSInstall: build failed for %s\n%s'):format(
                                lang, build_result.stderr or ''
                            ),
                            vim.log.levels.ERROR
                        )
                        return
                    end

                    -- Copy queries if the grammar repo ships them.
                    local src_queries = tmp .. '/queries'
                    if vim.fn.isdirectory(src_queries) == 1 then
                        local dest_queries = queries_dir .. '/' .. lang
                        vim.fn.mkdir(dest_queries, 'p')
                        vim.system({ 'cp', '-R', src_queries .. '/', dest_queries .. '/' })
                    end

                    -- Clean up temp dir.
                    vim.fn.delete(tmp, 'rf')

                    vim.notify(('TSInstall: %s installed successfully.'):format(lang))
                end)
            )
        end)
    )
end, {
    nargs = 1,
    complete = function()
        return parsers
    end,
})

return {
    -- Endwise: auto-insert `end` in Ruby, Lua, etc.
    {
        'RRethy/nvim-treesitter-endwise',
        event = 'InsertEnter',
    },

    -- Textobjects: select/move/swap functions, classes, parameters.
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        event = 'VeryLazy',
    },

    -- Folding with virtual text.
    {
        'kevinhwang91/nvim-ufo',
        event = { 'BufReadPost', 'BufNewFile' },
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
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = true

            vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end)
            vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end)
        end,
    },
}

require('nvim-treesitter').setup({
    auto_install = true,
    disable = { 'markdown' },
    ensure_installed = { 'lua', 'vim', 'ruby', "c_sharp", "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" },
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

return {
    {
        'tpope/vim-fugitive',
        event = "VeryLazy",
        dependencies = { 'tpope/vim-rhubarb' },
    },
    { 'tommcdo/vim-fubitive', cmd = "Gbrowse" },

    {
        'NeogitOrg/neogit',
        event = "VeryLazy",
        cmd = "Neogit",
        branch = "master",
        config = true,
    },

    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        opts = {
            current_line_blame = false,
            on_attach = function(bufnr)
                local gs = require('gitsigns')
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']c', bang = true })
                    else
                        gs.next_hunk()
                    end
                end, "Next hunk")
                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gs.prev_hunk()
                    end
                end, "Previous hunk")

                -- Actions
                map({ 'n', 'v' }, '<leader>hs', function() gs.stage_hunk() end, "Stage hunk")
                map({ 'n', 'v' }, '<leader>hr', function() gs.reset_hunk() end, "Reset hunk")
                map('n', '<leader>hS', function() gs.stage_buffer() end, "Stage buffer")
                map('n', '<leader>hu', function() gs.undo_stage_hunk() end, "Undo stage hunk")
                map('n', '<leader>hR', function() gs.reset_buffer() end, "Reset buffer")
                map('n', '<leader>hp', function() gs.preview_hunk() end, "Preview hunk")
                map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, "Blame line")
                map('n', '<leader>htb', function() gs.toggle_current_line_blame() end, "Toggle line blame")
                map('n', '<leader>hd', function() gs.diffthis() end, "Diff this")
                map('n', '<leader>hD', function() gs.diffthis('~') end, "Diff this (~)")
                map('n', '<leader>htd', function() gs.toggle_deleted() end, "Toggle deleted")

                -- Text object
                map({ 'o', 'x' }, 'ih', function() gs.select_hunk() end, "Select hunk")
            end,
        },
    },
}

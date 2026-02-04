--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Write and quit
vim.keymap.set('n', 'ZZ', ':wq<cr>', { silent = true, desc = "Write and quit" })

-- Quit everything!
vim.keymap.set('n', 'QA', ':qa!<cr>', { desc = "Quit all without saving" })

-- switch to using Perl standard regular expressions
vim.keymap.set({ 'n', 'v' }, '/', '/\\v', { desc = "Search with very magic" })

-- Search results centered please
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = "Next search result (centered)" })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = "Previous search result (centered)" })
vim.keymap.set('n', '*', '*zz', { silent = true, desc = "Search word under cursor (centered)" })
vim.keymap.set('n', '#', '#zz', { silent = true, desc = "Search word under cursor backward (centered)" })
vim.keymap.set('n', 'g*', 'g*zz', { silent = true, desc = "Search partial word (centered)" })

-- open TODO file
vim.keymap.set('n', '<leader>o', ':split TODO<cr>', { silent = true, desc = "Open TODO file" })

-- Move around splits with <c-hjkl>
vim.keymap.set('n', '<c-j>', '<c-w>j', { desc = "Move to split below" })
vim.keymap.set('n', '<c-k>', '<c-w>k', { desc = "Move to split above" })
vim.keymap.set('n', '<c-h>', '<c-w>h', { desc = "Move to split left" })
vim.keymap.set('n', '<c-l>', '<c-w>l', { desc = "Move to split right" })

-- toggle between last two buffers (normally ctrl-shift-6)
vim.keymap.set('n', '<leader><tab>', '<c-^>', { silent = true, desc = "Switch to alternate buffer" })

-- Quickly write the file
vim.keymap.set('n', '<leader>w', ':w<cr>', { silent = true, desc = "Save file" })

-- Clear the search highlighting (use 8 to pair with `*`)
vim.keymap.set('n', '<leader>8', ':nohlsearch<cr>', { silent = true, desc = "Clear search highlighting" })

--  Shortcode to reference current file's path in command line mode.
vim.keymap.set('c', '%%', "expand('%:h').'/'", { expr = true, desc = "Expand to current file's directory" })

--  Copy the visual contents to the system clipboard
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Copy to system clipboard" })

-- Git
vim.keymap.set('n', '<leader>gb', ':Git blame<cr>', { desc = "Git blame" })
vim.keymap.set('n', '<leader>gci', ':Neogit kind=split_above<cr>', { desc = "Open Neogit" })
vim.keymap.set('n', '<leader>gcc', ':Git commit<cr>', { desc = "Git commit" })
vim.keymap.set('n', '<leader>gco', ':Gcheckout<cr>', { desc = "Git checkout" })
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { desc = "Git diff split" })
vim.keymap.set('n', '<leader>gg', ':grep<space>', { desc = "Grep" })
vim.keymap.set('n', '<leader>gm', ':GMove<cr>', { desc = "Git move" })
vim.keymap.set('n', '<leader>gr', ':GRemove<cr>', { desc = "Git remove" })
vim.keymap.set('n', '<leader>gs', ':Git<cr>', { desc = "Git status" })
vim.keymap.set('n', '<leader>gw', ':Gwrite<cr>', { desc = "Git write (stage)" })
vim.keymap.set('n', 'gdh', ':diffget //2<CR>', { desc = "Get diff from left (ours)" })
vim.keymap.set('n', 'gdl', ':diffget //3<CR>', { desc = "Get diff from right (theirs)" })

-- Test runner
vim.keymap.set('n', '<leader>sf', function() require("neotest").run.run(vim.fn.expand("%")) end, { silent = true, desc = "Test current file" })
vim.keymap.set('n', '<leader>ss', function() require("neotest").run.run() end, { silent = true, desc = "Test nearest" })
vim.keymap.set('n', '<leader>sl', function() require("neotest").run.run_last() end, { silent = true, desc = "Run last test" })
vim.keymap.set('n', '<leader>st', function() require("neotest").summary.toggle() end, { silent = true, desc = "Toggle test summary" })

-- Undo tree toggle
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })

-- Jump around between todo style comments
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next({ keywords = { "TODO", "FIXME" } })
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev({ keywords = { "TODO", "FIXME" } })
end, { desc = "Previous todo comment" })

-- Code Companion
vim.keymap.set("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "CodeCompanion actions" })
vim.keymap.set("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "CodeCompanion actions" })
vim.keymap.set("n", "<LocalLeader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true, desc = "Toggle CodeCompanion" })
vim.keymap.set("v", "<LocalLeader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true, desc = "Toggle CodeCompanion" })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionAdd<cr>", { noremap = true, silent = true, desc = "Add to CodeCompanion" })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

vim.keymap.set('n', '<leader>b', function() require("easy-dotnet").build_default_quickfix() end, { desc = "Build .NET project" })

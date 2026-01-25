-- Toggle the quickfix or loclist windows
local function toggle_quickfix()
    local windows = vim.fn.getwininfo()
    local qf_exists = false
    for _, win in pairs(windows) do
        if win["quickfix"] == 1 and win["loclist"] == 0 then
            qf_exists = true
            break
        end
    end
    if qf_exists then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end

local function toggle_loclist()
    local windows = vim.fn.getwininfo()
    local loc_exists = false
    for _, win in pairs(windows) do
        if win["quickfix"] == 1 and win["loclist"] == 1 then
            loc_exists = true
            break
        end
    end
    if loc_exists then
        vim.cmd("lclose")
    else
        vim.cmd("lopen")
    end
end

vim.keymap.set("n", "<leader>q", toggle_quickfix, { silent = true, desc = "Toggle Quickfix" })
vim.keymap.set("n", "<leader>l", toggle_loclist, { silent = true, desc = "Toggle Loclist" })

-- Configure terminal
-- Use Escape to exit back to normal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- To send a normal escape to the underlying application use Ctrl-v Escape
vim.keymap.set("t", "<M-[>", "<Esc>", { desc = "Send Escape" })
vim.keymap.set("t", "<C-v><Esc>", "<Esc>", { desc = "Send Escape" })

-- Change the default color for the terminal cursor to red
vim.api.nvim_set_hl(0, "TermCursor", { ctermfg = "red", fg = "red" })

vim.opt.inccommand = "nosplit"

-- Autocommands
local ft_fugitive_group = vim.api.nvim_create_augroup("ft_fugitive", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = ".git/index",
    group = ft_fugitive_group,
    callback = function()
        vim.opt_local.list = false
    end,
})

local vimrc_ex_group = vim.api.nvim_create_augroup("vimrcEx", { clear = true })

-- Enable breakindent for text files only
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.breakindent = true
    end,
})

-- Disable the numbers in the terminal
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

-- Only show the cursor line in the window with focus
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    pattern = "*",
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

vim.api.nvim_create_autocmd("WinLeave", {
    pattern = "*",
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

-- Make TODO files taskpaper files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "TODO",
    group = vimrc_ex_group,
    callback = function()
        vim.bo.filetype = "tada"
    end,
})

-- Force .slim to use slim filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.slim",
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.filetype = "slim"
    end,
})

-- Use Razor syntax for cshtml files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.cshtml",
    group = vimrc_ex_group,
    callback = function()
        vim.opt_local.filetype = "razor"
    end,
})

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    group = vimrc_ex_group,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Function to show syntax group
vim.api.nvim_create_user_command("SynGroup", function()
    local s = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
    print(vim.fn.synIDattr(s, "name") .. " -> " .. vim.fn.synIDattr(vim.fn.synIDtrans(s), "name"))
end, {})

-- Enable virtual text for diagnostics
vim.diagnostic.config({
    virtual_text = true,
})

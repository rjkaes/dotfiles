-- override defaults set by lazy.vim
vim.opt.pumblend = 0
vim.opt.winblend = 0

-- alwaus enable trule colors
vim.opt.termguicolors = true

-- figure out background color
local read_file = function(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read()
    file:close()
    return content
end

-- Read in the current background mode and set the background theme (default to
-- "light".)  Relies on the environment variable set by `bin/setbg`
local background_color = function()
    -- Use `current_background_mode` when not on MacOS.
    if vim.fn.has('mac') ~= 1 then
        return read_file(vim.fn.expand("$HOME/CloudStation/current_background_mode")) or 'light'
    end

    local dark_mode = vim.fn.system([[
        osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode'
    ]]):gsub('\n', '')

    return dark_mode == 'true' and 'dark' or 'light'
end

vim.opt.background = background_color()

vim.opt.splitkeep = "screen"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.colorcolumn = "+1"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.hlsearch = false
vim.opt.list = true

-- make searches case-sensitive only if they contain upper-case characters
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.inccommand = 'split'

vim.opt.grepprg = "rg --vimgrep $*"
vim.opt.listchars = { tab = '▸ ', nbsp = '¬', extends = '»', precedes = '«', trail = '•' }
vim.opt.scrolloff = 20
vim.opt.shiftwidth = 4
vim.opt.showbreak = '↪ '
vim.opt.softtabstop = 4
vim.opt.spelllang = 'en_ca'
vim.opt.tabstop = 4

vim.opt.winwidth = 83 -- Give enough space for the gutter

-- Enable Cursor highlighting
vim.opt.guicursor:append('a:Cursor/lCursor')

vim.opt.rtp:append { '~/.fzf ' }
vim.opt.tags:append { './.git/tags;' }

-- Turn click-me warnings about swapfiles into discreet little messages
vim.opt.shortmess:append 'A'

-- Ignore a bunch of VCS, swap, and backup files.
vim.opt.wildignore:append { '*.swp', '*.bak' }
vim.opt.wildignore:append { '.hg', '.git', '.svn' }
vim.opt.wildignore:append { '*.spl' }
vim.opt.wildignore:append { '*.sw?' }
vim.opt.wildignore:append({ ".javac", "node_modules", "*.pyc" })
vim.opt.wildignore:append({ ".aux", ".out", ".toc" }) -- LaTeX
vim.opt.wildignore:append({
    ".o", ".obj", ".dll", ".exe", ".so", ".a", ".lib", ".pyc", ".pyo", ".pyd",
    ".swp", ".swo", ".class", ".DS_Store", ".git", ".hg", ".orig"
})

vim.wo.signcolumn = 'yes'

-- Persist the undo tree for each file
vim.opt.undofile = true

vim.opt.breakindent = true

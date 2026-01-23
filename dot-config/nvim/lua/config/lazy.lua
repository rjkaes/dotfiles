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
    { import = "plugins" },
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

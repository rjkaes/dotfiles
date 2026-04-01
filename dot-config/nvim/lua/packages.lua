-- Start up the package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
    performance = {
        rtp = {
            disabled_plugins = {
                "2html_plugin",
                "getscript",
                "getscriptPlugin",
                "logiPat",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "rrhelper",
                "tutor",
                "vimball",
                "vimballPlugin",
            },
        },
    },
})

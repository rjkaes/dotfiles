-- Enable Lua loader for faster startup (caches bytecode)
vim.loader.enable()

require "disable_builtins"
require "globals"
require "keymaps"
require "packages"
require 'options'
require "misc"
require "theme"
require "autocommands"

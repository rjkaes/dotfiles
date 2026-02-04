vim.g.cpp_attributes_highlight = 1

-- Disable netrw in favour of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tada Configuration for TODO list
vim.g.tada_todo_style = 'simple'
vim.g.tada_todo_pane_file = 'TODO'
vim.g.tada_todo_pane_location = 'top'
vim.g.tada_todo_switch_status_mapping = '<C-X>'

vim.g['semshi#always_update_all_highlights'] = true

vim.g['test#preserve_screen'] = 0
vim.g['test#strategy'] = 'dispatch'

-- Run rspec (with bundle exec) but use the "rails" compiler to parse the output
vim.g['test#ruby#bundle_exec'] = 1

vim.g.dispatch_compilers = vim.g.dispatch_compilers or {}
local compilers = vim.g.dispatch_compilers
compilers['bundle exec '] = ''
vim.g.dispatch_compilers = compilers

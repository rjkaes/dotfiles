vim.g.cpp_attributes_highlight = 1

-- Configure netrw to behave mostly like NERDTree
vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_keepdir = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

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

-- TODO: Figure out how to manipulate these tables with lua
vim.cmd[[
if !exists('g:dispatch_compilers')
  let g:dispatch_compilers = {}
endif
let g:dispatch_compilers['bundle exec '] = ''
]]

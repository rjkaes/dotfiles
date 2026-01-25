-- Switch between the cshtml Razor page and the backing (cshtml.cs) file.  Mimics vim-rails.
local function switch_to_razor_page()
    local current_file = vim.fn.expand('%:p')
    if current_file:match('%.cshtml$') then
        vim.cmd.edit(current_file:gsub('%.cshtml$', '.cshtml.cs'))
    elseif current_file:match('%.cshtml%.cs$') then
        vim.cmd.edit(current_file:gsub('%.cshtml%.cs$', '.cshtml'))
    end
end

vim.api.nvim_create_user_command('A', switch_to_razor_page, {})

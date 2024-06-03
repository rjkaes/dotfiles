vim.keymap.set('n', "<leader>x", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>")
vim.keymap.set('n', ']x',
    function() require("trouble").next({ skip_groups = true, jump = true }) end,
    { silent = true })
vim.keymap.set('n', '[x',
    function() require("trouble").previous({ skip_groups = true, jump = true }) end,
    { silent = true })

-- Diagnostic signs
-- https://github.com/folke/trouble.nvim/issues/52
local signs = {
    Error = '',
    Warn = '',
    Hint = '',
    Info = '',
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

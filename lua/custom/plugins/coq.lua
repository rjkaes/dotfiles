return {
    {
        'ms-jpq/coq_nvim',
        branch = 'coq',
        init = function()
            vim.g.coq_settings = {
                auto_start = 'shut-up',
                completion = {
                    always = true,
                },
                keymap = {
                    recommended = false,
                },
                clients = {
                    snippets = {
                        warn = {},
                    },
                },
            }
        end,
    },
}

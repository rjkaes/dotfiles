require("codecompanion").setup({
    adapters = {
        coder = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "coder",
                schema = {
                    model = {
                        default = "qwen2.5-coder:32b-instruct-q5_K_M",
                    },
                    num_ctx = {
                        default = 8192,
                    },
                    -- temperature = {
                    --     default = 0.6,
                    -- },
                    -- top_p = {
                    --     default = 0.95,
                    -- },
                    max_tokens = {
                        default = 8192,
                    },
                },
            })
        end,
    },
    strategies = {
        chat = {
            adapter = "coder",
        },
        inline = {
            adapter = "coder",
        },
        agent = {
            adapter = "coder",
        },
    },
})

require("minuet").setup({
    provider = 'openai_fim_compatible',
    n_completions = 1, -- recommend for local model for resource saving
    context_window = 1024,
    provider_options = {
        openai_fim_compatible = {
            api_key = 'TERM',
            name = 'Ollama',
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:14b-instruct-q4_K_M',
            optional = {
                max_tokens = 256,
                top_p = 0.9,
            },
        },
    },
    virtualtext = {
        auto_trigger_ignore_ft = { 'codecompanion', 'TelescopePrompt' },
        keymap = {
            -- accept whole completion
            accept = '<C-1>',
            -- accept one line
            accept_line = '<C-f>',
            dismiss = '<C-x>',
        },
        show_on_completion_menu = false,
    },
})

vim.keymap.set('n', '<leader>C', ':Minuet virtualtext toggle<CR>')

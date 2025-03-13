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

local function is_on_battery()
    local handle = io.popen("uname")
    local os_name = handle:read("*l")
    handle:close()

    if os_name ~= "Darwin" then
        return false -- Assume not on battery for non-MacOS systems
    end

    handle = io.popen("pmset -g batt | grep 'Battery Power'")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

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
    virtualtext = not is_on_battery() and {
        auto_trigger_ft = { '*' },
        auto_trigger_ignore_ft = { 'codecompanion', 'TelescopePrompt' },
        keymap = {
            -- accept whole completion
            accept = '<C-1>',
            -- accept one line
            accept_line = '<C-f>',
            dismiss = '<C-x>',
        },
        show_on_completion_menu = false,
    } or nil,
})

vim.keymap.set('n', '<leader>C', ':Minuet virtualtext toggle<CR>')

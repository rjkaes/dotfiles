require("codecompanion").setup({
    adapters = {
        deepseekr1 = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "deepseekr1",
                schema = {
                    model = {
                        default = "deepseek-coder-v2:latest",
                    },
                    num_ctx = {
                        default = 4096,
                    },
                    temperature = {
                        default = 0.6,
                    },
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
            adapter = "deepseekr1",
        },
        inline = {
            adapter = "deepseekr1",
        },
        agent = {
            adapter = "deepseekr1",
        },
    },
})

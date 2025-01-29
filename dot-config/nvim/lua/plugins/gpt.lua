require("codecompanion").setup({
    adapters = {
        coder = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "coder",
                schema = {
                    model = {
                        default = "qwen2.5-coder:14b",
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

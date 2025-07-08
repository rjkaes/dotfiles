require("codecompanion").setup({
    adapters = {
        opts = {
            show_defaults = false,
        },
        deepseek = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "deekseek",
                schema = {
                    model = {
                        default = "deepseek-coder-v2:16b",
                    },
                    num_ctx = {
                        default = 40960,
                    },
                    max_tokens = {
                        default = 40960,
                    },
                },
            })
        end,
        qwencoder = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "qwencoder",
                schema = {
                    model = {
                        default = "qwen2.5-coder:32b-instruct-q5_K_M",
                    },
                    num_ctx = {
                        default = 16384,
                    },
                    -- temperature = {
                    --     default = 0.6,
                    -- },
                    -- top_p = {
                    --     default = 0.95,
                    -- },
                    max_tokens = {
                        default = 32768,
                    },
                },
            })
        end,
    },
    strategies = {
        chat = {
            adapter = "deepseek",
        },
        inline = {
            adapter = "deepseek",
        },
        agent = {
            adapter = "deepseek",
        },
    },
})

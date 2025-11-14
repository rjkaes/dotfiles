require("codecompanion").setup({
    adapters = {
        http = {
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
                            default = 65536,
                        },
                        max_tokens = {
                            default = 65536,
                        },
                        top_p = {
                            default = 0.95,
                        },
                    },
                })
            end,
            qwencoder = function()
                return require("codecompanion.adapters").extend("ollama", {
                    name = "qwencoder",
                    opts = {
                        stream = true,
                    },
                    schema = {
                        model = {
                            default = "qwen3-coder:30b",
                        },
                        num_ctx = {
                            default = 65536,
                        },
                        temperature = {
                            default = 0.2,
                        },
                        -- top_p = {
                        --     default = 0.95,
                        -- },
                        max_tokens = {
                            default = 65536,
                        },
                        keep_alive = {
                            default = '5m',
                        },
                    },
                })
            end,
        },
    },
    strategies = {
        chat = {
            adapter = "qwencoder",
        },
        inline = {
            adapter = "deepseek",
        },
        agent = {
            adapter = "deepseek",
        },
    },
})

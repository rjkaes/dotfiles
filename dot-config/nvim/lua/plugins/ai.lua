return {
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            {
                "stevearc/dressing.nvim",
                opts = {},
            },
        },
        config = function()
            local ai = function(name, model)
                return {
                    name = name,
                    opts = {
                        stream = true,
                    },
                    schema = {
                        model = {
                            default = model,
                        },
                        num_ctx = {
                            default = 32768,
                        },
                        temperature = {
                            default = 0.2,
                        },
                        num_predict = {
                            default = -1,
                        },
                        keep_alive = {
                            default = '10m',
                        },
                    }
            }
            end

            require("codecompanion").setup({
                adapters = {
                    http = {
                        qwencoder = function()
                            return require("codecompanion.adapters").extend("ollama", ai("qwencoder", "qwen3-coder:30b"))
                        end,
                        devstral = function()
                            return require("codecompanion.adapters").extend("ollama", ai("devstral", "devstral-small-2:24b"))
                        end,
                    },
                },
                strategies = {
                    chat = {
                        adapter = "qwencoder",
                    },
                    inline = {
                        adapter = "devstral",
                    },
                    agent = {
                        adapter = "devstral",
                    },
                },
            })
        end
    },
}

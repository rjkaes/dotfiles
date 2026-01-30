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
            require("codecompanion").setup({
                adapters = {
                    http = {
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
                                        default = 32768,
                                    },
                                    temperature = {
                                        default = 0.2,
                                    },
                                    num_predict = {
                                        default = -1,
                                    },
                                    keep_alive = {
                                        default = '5m',
                                    },
                                },
                            })
                        end,
                    },
                },
                interactions = {
                    chat = {
                        adapter = "qwencoder",
                    },
                    inline = {
                        adapter = "qwencoder",
                    },
                    agent = {
                        adapter = "qwencoder",
                    },
                },
            })
        end
    },
}

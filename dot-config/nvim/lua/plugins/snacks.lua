return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            picker = { enabled = true },
            explorer = { enabled = true },
            zen = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
                style = "compact",
            },
            input = { enabled = true },
        },
        keys = {
            -- Picker (same bindings as old telescope config)
            { "<C-p>",     function() Snacks.picker.files({ hidden = true, ignored = false }) end, desc = "Find Files" },
            { "<leader>j", function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
            { "<leader>f", function() Snacks.picker.grep({ hidden = true }) end,                   desc = "Live Grep" },
            { "<leader>t", function() Snacks.picker.tags() end,                                    desc = "Tags" },

            -- Explorer
            { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

            -- Zen mode (replaces goyo)
            { "<leader>z", function() Snacks.zen() end,      desc = "Zen Mode" },
        },
    },
}

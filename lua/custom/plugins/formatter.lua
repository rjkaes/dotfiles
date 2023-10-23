return {
    "stevearc/conform.nvim",
    -- optional = true,
    opts = {
        formatters_by_ft = {
            cs = { "csharpier" },
            html = { { "prettierd", "prettier" } },
            javascript = { { "prettierd", "prettier" } },
            ruby = { "standardrb" },
            rust = { "rustfmt" },
            ["_"] = { "trim_whitespace" },
        },
        formatters = {
            csharpier = {
                command = "dotnet-csharpier",
                args = { "--write-stdout" },
            },
        },
    },
}

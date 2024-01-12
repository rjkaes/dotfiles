local conform = require("conform");
local util = require("conform.util");

conform.setup({
    formatters_by_ft = {
        cs = { "csharpier" },
        html = { "prettier" },
        javascript = { { "biome", "prettier" } },
        json = { { "biome", "prettier" } },
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
});

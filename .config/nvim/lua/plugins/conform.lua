local conform = require("conform");
local util = require("conform.util");

-- format microsoft t-sql
conform.formatters.sql_formatter = {
    prepend_args = { "-l", "tsql", "-c", '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }' },
}

conform.setup({
    formatters_by_ft = {
        cs = { "csharpier" },
        html = { "prettier" },
        javascript = { { "biome", "prettier" } },
        json = { { "biome", "prettier" } },
        ruby = { "standardrb" },
        rust = { "rustfmt" },
        sql = { "sql_formatter" },
        ["_"] = { "trim_whitespace" },
    },
});

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
        javascript = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        ruby = { "standardrb" },
        rust = { "rustfmt" },
        sql = { "sql_formatter" },
        ["_"] = { "trim_whitespace" },
    },
    -- If this is set, Conform will run the formatter on save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 1000,
    },
});

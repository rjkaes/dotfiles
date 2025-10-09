local conform = require("conform");
local util = require("conform.util");

-- format microsoft t-sql
conform.formatters.sql_formatter = {
    prepend_args = { "-l", "tsql", "-c", '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }' },
}
conform.formatters.sqlfluff = {
    args = { "fix", "--dialect=tsql", "--exclude-rules=CP02", "-" },
}
conform.formatters.csharpier = {
    command = "csharpier",
    args = { "format", "--write-stdout" },
}

conform.setup({
    formatters_by_ft = {
        cs = { "csharpier" },
        csx = { "csharpier" },
        html = { "prettier" },
        javascript = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        ruby = { "standardrb" },
        rust = { "rustfmt" },
        sql = { "sqlfluff", "sql_formatter", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
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

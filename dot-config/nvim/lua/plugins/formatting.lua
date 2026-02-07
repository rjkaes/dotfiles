return {
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cF",
                function()
                    require("conform").format({
                        formatters = {"injected"},
                        timeout_ms = 3000
                    })
                end,
                mode = {"n", "v"},
                desc = "Format Injected Langs"
            }, {
                "<localleader>f",
                function()
                    require("conform").format({
                        async = false,
                        timeout_ms = 1000,
                        lsp_fallback = true
                    })
                end,
                mode = {"n", "v"},
                desc = "Format file or range"
            }
        },
        init = function()
            -- Wrap conform's formatexpr so that gq falls back to Neovim's
            -- default formatting for filetypes without configured formatters
            -- (e.g. markdown).
            _G.conform_formatexpr = function()
                local dominated_by_catchall = true
                for _, f in ipairs(require("conform").list_formatters()) do
                    if not vim.tbl_contains({"trim_whitespace"}, f.name) then
                        dominated_by_catchall = false
                        break
                    end
                end
                if not dominated_by_catchall then
                    return require("conform").formatexpr()
                end
                -- Only catch-all formatters (e.g. trim_whitespace) are available;
                -- return 1 so Neovim uses its built-in gq text wrapping.
                return 1
            end
            vim.o.formatexpr = "v:lua.conform_formatexpr()"
        end,
        opts = {
            formatters_by_ft = {
                cs = {"csharpier"},
                csx = {"csharpier"},
                html = {"prettier"},
                javascript = {"biome", "prettier", stop_after_first = true},
                json = {"biome", "prettier", stop_after_first = true},
                ruby = {"standardrb"},
                rust = {"rustfmt"},
                sql = {"sqlfluff", "sql_formatter", stop_after_first = true},
                typescript = {"biome", "prettier", stop_after_first = true},
                typescriptreact = {"biome", "prettier", stop_after_first = true},
                ["_"] = {"trim_whitespace"}
            },
            format_on_save = {lsp_fallback = true, timeout_ms = 1000},
            formatters = {
                sql_formatter = {
                    prepend_args = {
                        "-l", "tsql", "-c",
                        '{ "tabWidth": 2, "keywordCase": "upper", "dataTypeCase": "upper", "linesBetweenQueries": 2, "dialect": "transactsql" }'
                    }
                },
                sqlfluff = {
                    args = {
                        "fix", "--dialect=tsql", "--exclude-rules=CP02", "-"
                    }
                },
                csharpier = {
                    command = "csharpier",
                    args = {"format", "--write-stdout"}
                }
            }
        }
    }
}

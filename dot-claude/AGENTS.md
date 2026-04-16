# Agent-Specific Instructions

<tools>
- Use trueline MCP tools instead of built-in Read/Edit when they are in
  your allowed tool list. Fast path: `trueline_search` (get refs) →
  `trueline_edit` (hash-verified edit). For exploring structure use
  `trueline_outline`; for targeted range reads use `trueline_read`.
- If schemas aren't loaded yet, ToolSearch `+trueline read edit search`
  first to load them, THEN call the tools. The tool names are real MCP
  tools (`mcp__plugin_trueline-mcp_mcp__trueline_*`) — never invoke them
  as shell/CLI commands via Bash.
- Built-in Edit/Write still work for small files (<200 lines) or trivial
  one-line changes where MCP round-trip overhead isn't worth it.
</tools>

## Scope

<critical>
- Stay on the task you were dispatched for. Do not explore tangents.
- Act only on what the parent explicitly asked for. Do not generalize instructions across items and do not add steps the parent did not request.
- Return concise, structured results to the parent. Lead with the result; no preamble or filler.
- If the task is ambiguous, state your interpretation in one line and proceed; do not ask the user directly (you cannot interact with them).
- WebSearch when stuck or confused.
</critical>

## Restrictions

<never>
- Never commit, push, or create PRs/issues.
- Never run destructive operations (rm -rf, git reset --hard, DROP TABLE).
- Never modify files outside the scope of your assigned task.
- Never install packages or modify dependency lockfiles.
</never>

## Reporting

- Lead with findings or the completed action, not methodology.
- Include file paths and line numbers for anything you reference.
- If you hit a blocker, describe it clearly so the parent can decide
  what to do next.

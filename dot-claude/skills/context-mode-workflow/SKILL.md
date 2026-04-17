---
name: context-mode-workflow
description: Use when context-mode MCP tools (ctx_batch_execute, ctx_execute, ctx_execute_file, ctx_search, ctx_fetch_and_index, ctx_index, ctx_stats, ctx_doctor) are available. Covers picking ctx over Bash/Read/WebFetch, batch-first gathering, think-in-code, intent for BM25 filtering, search throttling, hook-enforced anti-patterns. Triggers: "ctx", "context-mode", "keep output out of context", "index that", "token savings", "sandbox this".
---

# Context-Mode Workflow

## Core Principle

Raw tool output floods context. Context-mode sandboxes raw data, auto-indexes large output into SQLite FTS5, returns only what you search for. **Program the analysis; don't compute in-context.** One script replaces ten tool calls.

If `ctx_*` unavailable: no-op, use standard Bash/Read/WebFetch.

## Decision Table

| Task | Use | Not |
|------|-----|-----|
| Explore repo / initial gather | `ctx_batch_execute` (commands[]+queries[]) | multi Bash |
| Large output / logs | `ctx_execute` with `intent` | Bash \| grep |
| Process existing file | `ctx_execute_file` (code on `FILE_CONTENT`) | Read for analysis |
| Follow-ups on indexed data | `ctx_search` with `queries[]` | sequential searches |
| Web docs | `ctx_fetch_and_index` → `ctx_search` | WebFetch/curl/wget |
| Add known content to index | `ctx_index` (labeled source) | paste into context |
| Create / edit files | native `Write` / `Edit` | ctx_execute to write |
| git, mkdir, mv, rm, <20-line output | Bash | ctx_execute |

## Rule 1: Batch First

First move on any non-trivial task: ONE `ctx_batch_execute`.

- `commands[]` — `{label, command}`. `label` = FTS5 chunk title; be descriptive.
- `queries[]` — 5–8 queries covering everything. **Only shot**: ctx_search throttles after ~8 calls / 60s.
- One batch replaces ~30 `ctx_execute` + ~10 `ctx_search` calls.

## Rule 2: Think in Code

Output needs filtering/counting/parsing/comparing/joining/transforming → script via `ctx_execute` or `ctx_execute_file`, `console.log` only the answer.

- Node built-ins only (`fs`, `path`, `child_process`). No npm.
- Always `try/catch`. Handle null/undefined.
- Sandbox does the work; context sees a one-line summary.

Anti-example: `Bash cat huge.log` + mental scan. Correct: `ctx_execute_file` with `intent`, emit counts + top N.

## Rule 3: `intent` Parameter

`ctx_execute` / `ctx_execute_file` accept optional `intent` string.

- Output >5KB + `intent` → auto-indexed, returns BM25-ranked sections.
- Output >100KB → always auto-indexed; you get pointer + summary.
- No `intent` + >5KB → raw dump (wasteful).

**Rule:** any ctx_execute that might exceed a few KB → pass `intent`. Cost: one string. Savings: ~95%+.

## Rule 4: Web Workflow

Never WebFetch / curl / wget.

1. `ctx_fetch_and_index({url, source:"descriptive-label"})` — fetches, HTML→markdown, indexes, returns preview. 24h cache; `force:true` bypasses.
2. `ctx_search({queries:[...]})` — extract specifics.

Multi-page docs: fetch each with distinct `source`, then one batched search.

## Rule 5: ctx_execute is Read-Only

`ctx_execute` / `ctx_execute_file` = **analysis, not authorship**. Never use them (or Bash heredocs, `echo >`, `cat <<EOF`) to create/modify files. `Write` for new, `Edit` for changes. Absolute.

## Anti-patterns (hook redirects)

- Bash >20 lines output → `ctx_execute` (with `intent`) or `ctx_batch_execute`.
- `Read` for analysis → `ctx_execute_file`. Read only for files you'll `Edit`.
- `WebFetch` / curl / wget → `ctx_fetch_and_index`.
- Sequential `ctx_search` on same data → one call with `queries[]`.
- Python/Ruby/shell in ctx_execute when JS works — JS has fastest cold-start.
- "Need raw output to decide" → script emits the decision, not the data.

## Diagnostics

`ctx_stats` (savings), `ctx_doctor` (health), `ctx_purge` (destructive; never without explicit confirm).

## Output Policy

Write artifacts to files via `Write`/`Edit`. Return: file path + one-line description. Text under ~500 words. Never paste raw sandbox output — write to file, point user there.

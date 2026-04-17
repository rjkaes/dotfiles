---
name: context-mode-workflow
description: Use when context-mode MCP tools (ctx_batch_execute, ctx_execute, ctx_execute_file, ctx_search, ctx_fetch_and_index, ctx_index, ctx_stats, ctx_doctor) are available in the session — covers picking ctx over Bash/Read/WebFetch for large output, batch-first gathering, the "think in code" mandate, the intent parameter for BM25-filtered output, ctx_search throttling, and the anti-patterns the PreToolUse hook enforces. Also applies when user says "ctx", "context-mode", "keep output out of context", "index that", "token savings", "sandbox this command".
---

# Context-Mode Workflow

## Core Principle

Raw tool output floods the context window. Context-mode keeps raw data in a sandbox, auto-indexes large output into SQLite FTS5, and returns only what you search for. Your job is to **program the analysis, not compute the answer in-context**. One script replaces ten tool calls.

If `ctx_*` tools are not available this skill is a no-op; use standard Bash/Read/WebFetch.

## Decision Table — pick the right tool

| Task | Use | Do NOT use |
|------|-----|------------|
| Explore repo, gather initial info | `ctx_batch_execute` (commands[] + queries[]) | multiple Bash calls |
| Analyze large command output / logs | `ctx_execute` with `intent="..."` | Bash piping to grep |
| Process an existing file | `ctx_execute_file` (path, code on `FILE_CONTENT`) | Read for analysis |
| Follow-up questions on indexed data | `ctx_search` with `queries[]` | sequential search calls |
| Fetch web docs / API reference | `ctx_fetch_and_index` → `ctx_search` | WebFetch, curl, wget |
| Add pre-known content to the index | `ctx_index` (content or path, labeled source) | paste into context |
| Edit / create files | native `Edit` / `Write` | ctx_execute to write |
| git, mkdir, mv, rm, cd, short (<20 line) output | Bash | ctx_execute |

## Rule 1: Batch First

First move on any non-trivial task: ONE `ctx_batch_execute` call.

- `commands[]` — each item `{label, command}`. The `label` becomes the FTS5 chunk title, so make it descriptive (e.g. `"README"`, `"package.json"`, `"Source tree"`, `"Recent commits"`), not generic.
- `queries[]` — 5–8 comprehensive search queries that cover every question you have. **This is your only shot**: ctx_search throttles after ~8 sequential calls in 60s. Dumping raw output back into context to re-read defeats the whole point.
- One batch replaces ~30 `ctx_execute` calls plus ~10 `ctx_search` calls. Use it.

Example shape:

```
ctx_batch_execute({
  commands: [
    { label: "README",        command: "cat README.md" },
    { label: "package.json",  command: "cat package.json" },
    { label: "Source tree",   command: "find src -type f -name '*.ts' | head -200" },
    { label: "Test config",   command: "cat vitest.config.ts 2>/dev/null || cat jest.config.js" },
  ],
  queries: [
    "entry point and main exports",
    "test runner and test command",
    "build and typecheck commands",
    "external dependencies",
    "directory layout of src/",
  ],
})
```

## Rule 2: Think in Code

When output needs filtering, counting, parsing, comparing, joining, or transforming: write a script via `ctx_execute` or `ctx_execute_file` and `console.log` only the answer.

- Node.js built-ins only (`fs`, `path`, `child_process`) — no npm deps.
- Always `try/catch`. Handle `null`/`undefined`.
- Target: the sandbox does the work; your context sees a one-line summary.

Anti-example: running `Bash cat huge.log` then mentally scanning for errors. Correct: `ctx_execute_file({path: "huge.log", language: "javascript", code: "const errs = FILE_CONTENT.split('\\n').filter(l => /ERROR/.test(l)); console.log(errs.length, 'errors'); console.log(errs.slice(0,5).join('\\n'));", intent: "error lines"})`.

## Rule 3: The `intent` Parameter

`ctx_execute` and `ctx_execute_file` take an optional `intent` string.

- Output >5KB with `intent` set → server auto-indexes, returns BM25-ranked matching sections instead of raw dump.
- Output >100KB → always auto-indexed, you get a pointer + brief summary.
- Without `intent`, output >5KB still gets returned raw (wasteful if you only need a slice).

**Rule of thumb:** any ctx_execute whose output might exceed a few KB — pass `intent`. Cost is a single string; savings are ~95%+ on noisy output.

## Rule 4: Web Workflow

Never WebFetch, curl, or wget in this environment.

1. `ctx_fetch_and_index({url, source: "descriptive-label"})` — fetches, converts HTML→markdown, indexes chunks, returns a short preview. 24h cache; pass `force: true` to bypass.
2. `ctx_search({queries: [...]})` — extract specifics from the indexed page.

For multi-page docs: fetch each page with distinct `source` labels, then one batched search.

## Rule 5: ctx_execute is Read-Only

`ctx_execute` / `ctx_execute_file` are for **analysis, not authorship**. Do not use them (or Bash heredocs, `echo >`, `cat <<EOF`) to create or modify project files. Use native `Write` for new files and `Edit` for changes to existing files. This rule is absolute — the sandbox is for reading and computing, the editor tools are for writing.

## Anti-patterns (PreToolUse hook will redirect these)

- Bash command expected to produce >20 lines of output → use `ctx_execute` (with `intent`) or `ctx_batch_execute`.
- `Read` on a file you intend to analyze, not edit → use `ctx_execute_file`. (Read is correct only for files you will `Edit` afterwards — needed to satisfy the Edit tool's read-before-edit check.)
- `WebFetch` or Bash `curl`/`wget` → use `ctx_fetch_and_index`.
- Sequential `ctx_search` calls on the same indexed data → put all queries into one call's `queries[]`.
- Using `ctx_execute` with Python/Ruby/shell etc. when JavaScript would do — JS is the fastest cold-start path in the sandbox.

## Red Flags — stop and re-route

| If you think… | Correct move |
|---------------|--------------|
| "I'll cat this log and skim it" | `ctx_execute_file` with `intent` |
| "Let me grep across these files" | `ctx_batch_execute` with grep commands + search queries |
| "I'll WebFetch the API docs" | `ctx_fetch_and_index` then `ctx_search` |
| "Just a couple sequential searches" | one `ctx_search` with `queries: [...]` |
| "I'll Read this 2000-line JSON" | `ctx_execute_file` to parse + summarize |
| "I'll run five small Bash commands to explore" | one `ctx_batch_execute` |
| "I need to see the raw output to decide next steps" | write a script that emits the decision, not the data |

## Stats & Diagnostics

- `ctx_stats` — session tokens saved, per-tool usage, cache hits. Surface this when the user asks "how much did ctx save".
- `ctx_doctor` — health check (runtimes, hooks, FTS5, plugin registration). Run when ctx tools misbehave or the user asks to diagnose.
- `ctx_purge` — destructive; wipes the knowledge base. Never invoke without explicit user confirmation.

## Output Policy for This Skill

When operating under this skill: write artifacts (code, configs, plans) to files via `Write`/`Edit`. Return only: file path + one-line description. Keep user-facing text under ~500 words. Never paste raw sandbox output back into the conversation — if you need the user to see something from the sandbox, have the sandbox write it to a file and point them there.

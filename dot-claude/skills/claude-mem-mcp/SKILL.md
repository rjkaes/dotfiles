---
name: claude-mem-mcp
description: Router and cheat-sheet for claude-mem MCP tools (prefix mcp__plugin_claude-mem_mcp-search__*). Use when users ask "did we solve this before?", "what did we do last session?", want to explore an unfamiliar codebase token-cheaply, or want to build a focused knowledge corpus from past work. Recognizes the 3-layer memory search pattern, AST-based smart_outline/unfold over Read, and the build→prime→query corpus lifecycle.
---

# claude-mem MCP router

Cheat-sheet for the 11 tools under `mcp__plugin_claude-mem_mcp-search__*`. Groups them into three workflows. For the authoritative in-session refresher, call `__IMPORTANT` once per session.

## When to use

- User references prior sessions ("did we fix this?", "how did we do X?", "last time").
- Exploring unfamiliar code — prefer AST tools over Read.
- Building a durable Q&A brain over filtered history.

## Tool inventory

| Family | Tools |
|---|---|
| Meta | `__IMPORTANT` |
| Memory search (A) | `search`, `timeline`, `get_observations` |
| Code exploration (B) | `smart_search`, `smart_outline`, `smart_unfold` |
| Knowledge agent (C) | `build_corpus`, `list_corpora`, `prime_corpus`, `query_corpus`, `rebuild_corpus`, `reprime_corpus` |

## Workflow A — Memory Search (3-layer, mandatory order)

1. `search(query, limit, project, type, obs_type, dateStart, dateEnd, offset, orderBy)` → index of IDs + titles (~50–100 tok/result).
2. `timeline(anchor=ID | query, depth_before, depth_after, project)` → chronological context.
3. `get_observations(ids=[...])` → full detail. **Batch IDs. Never call without a prior `search`/`timeline` filter.** 10x token savings.

Observation `type` enum: `decision, bugfix, feature, refactor, discovery, change`.

For deeper protocol, defer to plugin skill `claude-mem:mem-search`.

## Workflow B — Code Exploration (AST, token-cheap)

1. `smart_search(query, path, file_pattern, max_results)` → locate symbols across tree.
2. `smart_outline(file_path)` → signatures only, bodies folded. **Prefer over Read for any file >~50 lines.**
3. `smart_unfold(file_path, symbol_name)` → expand one symbol's body.

Rule: outline → unfold beats full-file Read. Typical savings: 3–8K tok vs 12K+.

For deeper protocol, defer to plugin skill `claude-mem:smart-explore`.

## Workflow C — Knowledge Agent (corpus lifecycle)

1. `build_corpus(name, description?, project?, types?, concepts?, files?, query?, dateStart?, dateEnd?, limit?)` → persist filtered slice.
2. `prime_corpus(name)` → loads corpus into a Claude session, returns `session_id`.
3. `query_corpus(name, question)` → conversational Q&A; history accumulates.
4. `list_corpora()` → discover existing corpora before rebuilding.
5. `rebuild_corpus(name)` → refresh data with stored filters. **Does NOT reprime.**
6. `reprime_corpus(name)` → fresh session, clears Q&A drift. Use after rebuild or when drift detected.

Rule: build → prime → query. On stale data or drift: rebuild then reprime.

For deeper protocol, defer to plugin skill `claude-mem:knowledge-agent`.

## Decision table

| Symptom / user cue | Tool |
|---|---|
| "What did we do about X?" | `search` → `timeline` → `get_observations` |
| Tempted to Read a file >50 lines | `smart_outline` first |
| Need one function's body | `smart_unfold` |
| Don't know which file has symbol | `smart_search` |
| Multi-turn Q&A over history | build → prime → `query_corpus` |
| Unknown project name | `search` with no `project`, inspect results |
| Stale corpus / drifted conversation | `rebuild_corpus` → `reprime_corpus` |
| Forgot the workflow | `__IMPORTANT` |

## Anti-patterns

- `get_observations` without a prior `search`/`timeline` filter.
- Reading files >~50 lines instead of `smart_outline`.
- `query_corpus` without `prime_corpus` first.
- `rebuild_corpus` when `reprime_corpus` would suffice (data unchanged, only drift).
- Duplicating a corpus instead of `list_corpora` first.
- Skipping `__IMPORTANT` when protocol feels fuzzy.

## Token economics

3-layer search ≈ 10x cheaper than naive full-dump. Outline+unfold ≈ 3–8K tok vs 12K+ for Read. Primed corpus amortizes build cost across many queries.

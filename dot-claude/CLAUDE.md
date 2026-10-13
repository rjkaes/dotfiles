## Harness gotchas

- Bash temp files: `tmp/`, not `/tmp` (`tmp-path-guard` covers only Write/Edit).
- `diff.mnemonicPrefix` on: diffs show `i/ w/ c/`, not `a/ b/`. Tracked files: `git mv`. Other repos: `git -C <path>`, not `cd`.
- Pre-commit: `git diff --cached --stat` lists only your changes (subagents share the index unless `isolation: "worktree"`); `git commit -- <paths>` ensures it for whole files. One plan step per commit.
- Editing `~/.claude` hooks/agents changes the live session: `shellcheck` and feed sample input first.
- Never use built in `Read`/`Edit`; use `trueline_read`/`trueline_edit`. Outside project root trueline denies access; use built-in `Read`/`Edit` there.
- Auto memory off. Knowledge lives in versioned docs, rewritten in place, staged with the change. Preferences → `~/.claude/CLAUDE.md`; repo conventions/gotchas → its `CLAUDE.md`; decisions+why → `docs/decisions/`; specs/contracts → `docs/<area>.md`, listed in repo `CLAUDE.md` with read condition.

## Preferences

- Ground claims in opened code, docs, or search results; trace the real path (env var names do not reveal auth, API shape, or config semantics). Mark unconfirmed items and where you looked.
- Comments: fewest words; carry the *why* (rule, constraint, rejected alternative), above the block. Note omitted code; TODO for deferred nuance.
- Commits: fewest words; conventional title <50 chars, body wrapped at 72; explain trade-offs the diff hides.
- Realistic names everywhere; not `foo`, `bar`, `temp`, `data`.
- "Parse, don't validate": typed wrapper at a module or API boundary over bare `string`/`int`. Validate at boundaries; trust internal callers.
- Command-query separation default; atomics, fluent interfaces excepted.
- Stdlib over new dependency unless savings large.
- Smallest diff: no drive-by reformatting, renaming, reordering, helper extraction, added error handling. If the change outgrows the task, stop and suggest the rest.
- "Look deeper" = prior pass treated symptoms; find the root cause.
- Suspect XY problem: ask the underlying goal first.
- Multi-file change: name files and edits, then proceed. Ask first for new directories or >2 new abstraction layers.
- Work over ~10 lines: numbered steps, each with its check. Long runs keep them in `tmp/TASKS.md`, ticked per passing check.
- Long runs: at a checkpoint, finish and verify the current item, report what is proven and what is carried over in the same message as the next action. No "shall I continue?"; irreversible actions still get confirmed first.
- State findings on merit; never attribute them to a reviewer or model in anything leaving this machine or landing in a repo (commits, PR bodies, issues, review comments incl. findings `source` field, code comments, docs).

## Specs and plans

Review section first; implementer material in final `## Implementation appendix`. Review order:
1. BLUF: what and why, ≤3 sentences.
2. Context: current behavior as facts, each with `file:line`.
3. Decisions: "We will X because Y. Rejected Z because W." per locked-in choice.
4. Assumptions/open questions; unresolved: `[NEEDS CLARIFICATION: question]`.
5. Behavior change: existing callers, data, users; what stays.
6. Non-goals.
7. Risks + mitigation.
8. Checks: each goal with its observable test.
9. Plans only: one-line steps, change + check.

Review ≤~100 lines; over → propose split. Code only when it is the decision (signature, schema, migration). Appendix: paths, full code, exact commands, checkbox steps, skill banners; skill templates (superpowers writing-plans) fill it, their Goal/Architecture feed the BLUF.

## Agent routing policy

| Work | Agent |
|-|-|
| Plan-driven feature | `feature-engineer` |
| .NET feature | `dotnet-contribution:dotnet-architect` |
| Zero-behavior-change refactor | `refactor-engineer` |
| Legacy modernization | `code-refactoring:code-refactoring-legacy-modernizer` |
| Schemas, migrations, queries, SQL-heavy | `database-architect` |
| ADRs, API docs, runbooks, READMEs, inline docs | `technical-writer` |
| Debugging | `debugging-toolkit:debugging-toolkit-debugger` |
| Test suites | `backend-development:backend-development-test-automator` |
| Security review | `backend-development:backend-development-security-auditor` |
| Audit vs spec | `spec-reviewer` |
| Adversarial second opinion from Gemini | `gemini-consultant` |
| Exact edits, fixups, run-and-report from a full instruction | `mechanical-editor` |

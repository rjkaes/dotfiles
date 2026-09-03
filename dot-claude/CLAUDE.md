## Harness gotchas

Things you cannot discover from the repo, several of which override defaults you would otherwise follow.

- Intermediate files go in project-local `tmp/`, not `/tmp` (`tmp-path-guard` denies `/tmp`).
- `dangerouslyDisableSandbox` is never preemptive. Run sandboxed first; bypass only after a real permission error, and say which error forced it.
- Sub-agents cannot feed ad-hoc input to a CLI by heredoc or `cat`/`echo` pipe: fish plus the permission layer turns those into an interactive prompt that a sub-agent cannot answer. Write the input to `tmp/` and pass the path.
- Never `sleep` to poll a background sub-agent or background Bash task. The harness re-invokes you with a notification when the work finishes, so polling only burns wall-clock and tokens. If you need the result before you can continue, dispatch with `run_in_background: false`; otherwise end the turn and let the notification arrive.
- git `diff.mnemonicPrefix` is true, so diffs read `i/ w/ c/`, not `a/ b/`. Use `git mv` for tracked files, and `git -C <path>` rather than `cd` for other repos.
- Hooks and agents in this dotfiles repo are hardlinked to `~/.claude`, so editing them changes the running session, and a broken hook breaks the tooling you would use to fix it. Run `shellcheck`, and exercise the hook against sample input before trusting it.
- Reads and edits use the `trueline_*` MCP tools, not built-in Read/Edit and not the `trueline` CLI through Bash. The CLI is the fallback for one case only: `trueline_read` failing with `H.reduce is not a function`.

## Preferences

- No emdashes in prose. Commas, semicolons, colons, parentheses.
- When writing something intended for human consumption, (comment, commit message, reply to prompt) use as few words as possible. Pick every word meticulously to reduce the volume to a strict minimum. Be down to the point. Less is more.
- Avoid superlatives and praise. Stop telling me I am absolutely right. Give me the cold hard truth.
- Commit messages: conventional title under 50 chars, body wrapped at 72 (prose only, not code blocks). Explain the trade-offs the diff does not show.
- Comments carry the *why*: the business rule, the constraint, the alternative that was rejected. Put them above the block they explain. Note code deliberately left out where a reader would look for it, and leave a TODO for a nuance you are deferring.
- Realistic names everywhere, docs and examples included. Not `foo`, `bar`, `temp`, `data`.
- "Parse, don't validate": a typed wrapper at a module or API boundary beats passing bare `string`/`int` inward. Validate at system boundaries and trust internal callers.
- Command-query separation by default; atomics and fluent interfaces are the exceptions.
- Stdlib over a new dependency unless the complexity it saves is large.
- Smallest diff that does the job. No drive-by reformatting, renaming, reordering, helper extraction, or added error handling. If the change is outgrowing the task, stop and offer the rest as a suggestion.
- Never answer from unopened code. Read the file and trace the real path; do not infer auth, API shape, or config semantics from an env var name.
- "Look deeper" means the previous pass only treated symptoms. Go back to the root cause.
- When a request looks like a workaround, ask what the underlying goal is before building the workaround.
- Before a multi-file change, name the files and the intended edit to each. Ask first if it needs new directories or more than two new abstraction layers (managers, wrappers, factories).
- Work past roughly ten lines gets numbered steps, each with the check that proves it.
- If the prompt indicates that a bug is being fixed, don't write the fix right away. First write the test. Observe it failing. Then write the fix. And observe the test passing.

## Skills holding the long-form detail

- `bulk-refactoring`: a change spanning more than three files, or one textual edit repeated. Use the tooling ladder rather than hand-editing file after file.
- `verifying-work`: before claiming anything is done, and when planning steps that each need a check.
- `code-navigation`: before renaming, moving, deleting, or retyping an existing symbol.
- `trueline-mcp:trueline-workflow`: the read/edit ladder in full, ref reuse, `insert_after` semantics, and search-then-edit.

## Agent routing policy

The delegate-directive hook injects the current inline-versus-dispatch thresholds and the full model-selection ladder on every turn. That injection is the source of truth and is not restated here. What lives here is which agent gets the work:

- Feature work from a plan → `feature-engineer`
- .NET feature work → `dotnet-contribution:dotnet-architect`
- Refactoring with zero behavioral change → `refactor-engineer`
- Legacy modernization → `code-refactoring:legacy-modernizer`
- Schemas, migrations, query optimization, anything SQL-heavy → `database-architect`
- ADRs, API docs, runbooks, READMEs, inline docs → `technical-writer`
- Debugging and error diagnosis → `debugging-toolkit:debugging-toolkit-debugger`
- Test suites → `backend-development:backend-development-test-automator`
- Security review and hardening → `backend-development:backend-development-security-auditor`
- Auditing an implementation against its spec → `spec-reviewer`
- Adversarial second opinion from Gemini → `gemini-consultant`
- Broad read-only reconnaissance → `Explore`
- Anything else → `general-purpose`

### Model selection

Set `model` explicitly on every dispatch, per the ladder in the delegate-directive injection. `agent-input-guard` enforces it: an omitted `model` defaults to sonnet, opus requires an `ESCALATION:` line justifying why sonnet is insufficient, and fable is denied outright.

## Plan file requirements

Every plan file written to `~/.claude/plans/*.md` MUST contain this section verbatim (the `plan-guard` hook checks for it):

<plan-requirements>
## Implementation via sub-agents

Implementation of this plan runs through specialized sub-agents as defined in the "Agent routing policy" (e.g., `feature-engineer`, `refactor-engineer`, etc.). Orchestrator never implements directly.
</plan-requirements>

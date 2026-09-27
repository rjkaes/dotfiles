## Harness gotchas

Things you cannot discover from the repo, several of which override defaults you would otherwise follow.

- Intermediate files go in project-local `tmp/`, not `/tmp` (`tmp-path-guard` denies `/tmp`).
- git `diff.mnemonicPrefix` is true, so diffs read `i/ w/ c/`, not `a/ b/`. Use `git mv` for tracked files, and `git -C <path>` rather than `cd` for other repos.
- Editing `~/.claude` hooks or agents changes the running session; `shellcheck` and feed the hook sample input before trusting it.
- Project files: read and edit with the `trueline_*` MCP tools, overriding context-mode's native Read/Edit/Write guidance and auto mode's `cat`/`sed` edits. Outside the project root trueline denies access; use built-in Read/Edit there.

## Preferences

- Ground every claim in opened code, fetched docs, or search results. Trace the real path; an env var name does not reveal auth, API shape, or config semantics.
- Comments: fewest words that carry the meaning.
- Blunt: name flaws, disagree when warranted, skip praise and superlatives.
- Commit messages: fewest words; conventional title under 50 chars, body wrapped at 72 (prose only, not code blocks). Explain the trade-offs the diff does not show.
- Comments carry the *why*: the business rule, the constraint, the alternative that was rejected. Put them above the block they explain. Note code deliberately left out where a reader would look for it, and leave a TODO for a nuance you are deferring.
- Realistic names everywhere, docs and examples included. Not `foo`, `bar`, `temp`, `data`.
- "Parse, don't validate": a typed wrapper at a module or API boundary beats passing bare `string`/`int` inward. Validate at system boundaries and trust internal callers.
- Command-query separation by default; atomics and fluent interfaces are the exceptions.
- Stdlib over a new dependency unless the complexity it saves is large.
- Smallest diff that does the job. No drive-by reformatting, renaming, reordering, helper extraction, or added error handling. If the change is outgrowing the task, stop and offer the rest as a suggestion.
- "Look deeper" means the previous pass only treated symptoms. Go back to the root cause.
- Suspect an XY problem? Ask the underlying goal before building the workaround.
- Before a multi-file change, name the files and the intended edit to each. Ask first if it needs new directories or more than two new abstraction layers (managers, wrappers, factories).
- Work past roughly ten lines gets numbered steps, each with the check that proves it.
- Bug fix = red-green: write the failing test, watch it go red, fix, watch it go green.

## Agent routing policy

- Feature work from a plan → `feature-engineer`
- .NET feature work → `dotnet-contribution:dotnet-architect`
- Refactoring with zero behavioral change → `refactor-engineer`
- Legacy modernization → `code-refactoring:code-refactoring-legacy-modernizer`
- Schemas, migrations, query optimization, anything SQL-heavy → `database-architect`
- ADRs, API docs, runbooks, READMEs, inline docs → `technical-writer`
- Debugging and error diagnosis → `debugging-toolkit:debugging-toolkit-debugger`
- Test suites → `backend-development:backend-development-test-automator`
- Security review and hardening → `backend-development:backend-development-security-auditor`
- Auditing an implementation against its spec → `spec-reviewer`
- Adversarial second opinion from Gemini → `gemini-consultant`

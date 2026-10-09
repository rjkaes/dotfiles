## Harness gotchas

Things you cannot discover from the repo, several of which override defaults you would otherwise follow.

- Intermediate files go in project-local `tmp/`, not `/tmp` (`tmp-path-guard` denies `/tmp`).
- git `diff.mnemonicPrefix` is true, so diffs read `i/ w/ c/`, not `a/ b/`. Use `git mv` for tracked files, and `git -C <path>` rather than `cd` for other repos.
- Before committing, `git diff --cached --stat` must list only your changes: subagents share the index unless dispatched with `isolation: "worktree"`. `git commit -- <paths>` guarantees it for whole files. One plan step per commit.
- Editing `~/.claude` hooks or agents changes the running session; `shellcheck` and feed the hook sample input before trusting it.
- Never use built in `Read`/`Edit`.  Use `trueline_read`/`trueline_edit`. Outside the project root trueline denies access; use built-in `Read`/`Edit` there.
- Auto memory is off; durable knowledge lives in version-controlled docs, rewritten in place when the truth changes and staged with the change it describes (`docs-gate` asks once on a code-only commit; an identical retry passes). Your preferences → `~/.claude/CLAUDE.md`; a repo's conventions and gotchas → its `CLAUDE.md`; decisions and their why → `docs/decisions/`; specs and contracts → `docs/<area>.md`, listed in the repo `CLAUDE.md` with the condition for reading it.

## Preferences

- Ground every claim in opened code, fetched docs, or search results. Trace the real path; an env var name does not reveal auth, API shape, or config semantics. Mark what you couldn't confirm and where you looked.
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
- Before a multi-file change, name the files and the intended edit to each, then proceed. Ask first if it needs new directories or more than two new abstraction layers (managers, wrappers, factories).
- Work past roughly ten lines gets numbered steps, each with the check that proves it. Long runs keep them in `tmp/TASKS.md`, ticked as each check passes.
- Bug fix = red-green: write the failing test, watch it go red, fix, watch it go green. Any other task with a done-check: run it first; it must fail. Already passing means the work is done or the check is broken, so stop and report.
- Long runs: at a checkpoint, finish and verify the current item, report what is proven and what is carried over in the same message as the next action. No "shall I continue?"; irreversible actions still get confirmed first.
- Never name Gemini, Antigravity, `ask-gemini`, or `gemini-consultant` in anything that leaves this machine or lands in a repo: commit messages, PR bodies, issues, GitHub or review comments (including a findings `source` field), code comments, docs. State a finding on its own merit; don't attribute it to a reviewer or model. `no-gemini-guard` enforces this.

## Specs and plans

The reader is a developer deciding whether the spec or plan is wrong. The review section comes first. Everything the implementing agent needs goes in a final `## Implementation appendix`.

Review section, in this order:
1. Bottom line (BLUF): what changes and why, three sentences at most.
2. Context: current behavior as checkable facts, each with `file:line`.
3. Decisions: "We will X because Y. Rejected Z because W." One entry for each choice the code will lock in.
4. Assumptions and open questions. Mark each unresolved one `[NEEDS CLARIFICATION: question]`.
5. Behavior change: what changes for existing callers, data and users, and what stays the same.
6. Non-goals: reasonable goals left out on purpose.
7. Risks: what would make this wrong, each with its mitigation.
8. Checks: each goal paired with the observable test that proves it.
9. Plans only: steps, one line each, naming the change and its check.

The review section fits in about 100 lines. Over 100 means the change is too big for one spec, so propose a split. Code appears there only when the code is the decision: a signature, a schema, a migration.

The appendix holds file paths, full code, exact commands, checkbox steps, and skill banners such as "For agentic workers". Skill templates such as superpowers writing-plans fill the appendix. Their Goal and Architecture fields feed the bottom line.

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
- Exact edits, fixups, and run-and-report from a fully written instruction → `mechanical-editor` (pinned to haiku; omit `model`)

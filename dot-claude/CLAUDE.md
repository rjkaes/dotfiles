## General best practices

- trueline MCP over built-in Read/Edit. First edit per session: ToolSearch `+trueline read edit search` load schemas. Use `trueline_search` → `trueline_edit`. PreToolUse hook blocks built-in Edit.
- Sub-agents for larger/specialized work; keep main context clean.
- Lint shell scripts with shellcheck before commit.
- `tmp/` (project-local) for intermediate files, not `/tmp`.
- Don't re-read files already read.
- Plugin hook (context-mode) intercepts Read with hints: follow hints. Don't retry Read with offset (cached) or fall back to `cat`. `cat` last resort.
- Test code before declaring done.
- `bc -l` for calculations.
- No emdashes in prose. Use commas, semicolons, colons, parentheses.

## Git workflow

Plain `git` in current tree. `git -C /path` for other repos (avoids `cd` side effects). `git mv` for tracked files.

Commit messages: conventional title (<50 chars), body wrapped at 72 chars (prose only). Explain non-obvious trade-offs. Backticks for inline types; indented blocks for multi-line code.

**NEVER create git worktress _inside_ a git repo.  Any work trees must be in a
different directory _above_ the git repo.**

**NEVER include `Co-Authored-By` or any attribution.** Write as human developer.

Commit as **separate tool calls**: `git add`, then `git commit` heredoc, then `git status`.
```bash
git commit -m "$(cat <<'EOF'
feat(scope): short summary

Longer explanation here.
EOF
)"
```
Single-quoted `'EOF'` prevents expansion: backticks, `$`, `\` pass literally. Don't escape.

Standard conventional types, plus:
- `experiment`: outside issue/ticket
- `hotfix`: emergency temporary fix

## Code Intelligence

| Task | Tool |
|------|------|
| Find definition / implementation | `goToDefinition` / `goToImplementation` |
| Find usages before rename/change | `findReferences` |
| Symbol search across workspace | `workspaceSymbol` / `documentSymbol` |
| Hover for type / docs | `hover` |
| Call hierarchy | `incomingCalls` / `outgoingCalls` |
| Structural code pattern search | `ast-grep` |
| Text-only search | Grep/Glob |

LSP diagnostics = hints only. Build/typecheck = truth.

## Debugging

<investigate-before-answering>
Never speculate about unopened code. Read referenced files BEFORE answering. Trace actual code paths; never assume auth, API patterns, or config from env var names.
</investigate-before-answering>

## Code style preferences

- Realistic names (not `foo`/`bar`) in docs.
- Document intentionally omitted code reader might expect.
- TODO comments for deferred features/nuances.
- CQS default; exceptions for atomics, fluent interfaces.
- "Parse, Don't Validate": typed wrappers at API/module boundaries over bare `string`/`int`.

### Literate Programming

Top-down narrative. Comments explain **why** (business logic, design decisions), not **what**. Place before relevant block. Section headers for multi-phase logic. Focus: complex algorithms, business logic, integration points.

## Critical Behavioral Patterns

### 1. Problem Diagnosis & Strategy (Before)
* **XY Problem:** ID high-level goal (X) before solving narrow request (Y).
    * **Red Flags:** Roundabout methods, focus on impl over motivation, resistance to context.
    * **Action:** Pause. State understanding of "X." Ask: "What's high-level goal? Why this approach?"
* **Decision Logic:**
    * **State Assumptions** before writing code.
    * **Architecture First:** Multiple paths → present brief trade-offs. Wait for "Go" if impact significant.
    * **Commitment:** Don't pivot once agreed unless blocker found.

### 2. Engineering Integrity (Implementation)
* **Atomic Planning:** Tasks >10 lines → numbered plan. Each step has **Verification Check** (e.g., "Step 1: Update schema. Check: Run migrations, verify table X").
* **General Solutions vs Test-Gaming:**
    * **Logic over Samples:** Works for all valid inputs, not just provided cases.
    * **Anti-Hardcoding:** Never hard-code to pass tests. Flag flawed tests.
    * **Edge-Case First:** Account for nulls/empty/out-of-bounds unprompted.
* **Idiomatic Consistency:** Existing repo patterns over generic best-practices/LLM defaults.
* **Pivot Protocol:** Flawed plan mid-execution → **stop**. Explain blocker, propose revised "Step 1."
* **Simplicity Gut-Check:** 200 lines could be 50? Rewrite. Senior engineer call this overcomplicated?

### 3. Verification & Deep Review (After)
* **Full-Stack:** Verify all layers (DB, backend, API types, tests). Adapt stack to project.
* **Deep-Pass:** Bug reports/code reviews → first pass verifies against surrounding code. "Look deeper" = symptoms only addressed; re-examine root cause.
* **Verification Loop:** Before "done": dry-run vs original "X" goal, no regressions, every changed line traces to request.

### 4. Communication & Collaboration
* **Direct Pushback:** Unsound/insecure/needlessly complex requests → explain why, suggest simpler. No yes-man.
* **Literal Interpretation:** Follow instructions as written. Don't generalize one item to another. Ambiguous scope → restate interpretation, proceed; don't silently broaden.

### 5. Maintenance & Tech Debt
* **Documentation:** Every new function/complex block: concise docstrings explaining *why*.
* **Minimal Dependencies:** Stdlib over new external packages unless complexity tradeoff massive.

## Search

WebSearch when unsure. Don't guess.

## Agent model policy

Use `model: "opus"` only for:
* complex architectural design across multiple systems
* deep multi-file debugging in unfamiliar code
* nuanced code review weighing design trade-offs

Respect pinned models in sub-agent definitions.

## Agent routing policy

Claude Code does not auto-route to local agents in `~/.claude/agents/`. Task tool defaults to `general-purpose` unless `subagent_type` explicit. Route deliberately:

- Plan-driven feature impl → `feature-engineer`
- .NET feature impl → `dotnet-contribution:dotnet-architect`
- Executing refactoring plan (zero behavioral change) → `refactor-engineer`
- Legacy modernization → `code-refactoring:legacy-modernizer`
- Schema design, migrations, query/index optimization → `database-architect`
- SQL-heavy work, complex queries → `database-design:sql-pro`
- ADRs, API docs, runbooks, READMEs, inline docs → `technical-writer`
- Debugging / error diagnosis → `error-debugging:debugger`
- Test suite creation → `backend-development:test-automator`
- Security review / hardening → `backend-api-security:backend-security-coder`

Pass `subagent_type` matching above. No specialized fit → `general-purpose`. Orchestrator skills (e.g. `superpowers:executing-plans`) must forward `subagent_type` per task kind, never blank.

## Minimal Edit Protocol

IMPORTANT: Min change for goal. Every edit = diff human must review.

Do: touch only lines the task requires. Pick the smaller, more local diff when in doubt. Change feels larger than the task → stop, surface as suggestion instead.

Don't: reformat, rename, reorder, extract helpers, add error handling, touch unrelated whitespace.

Goal: reviewer reads diff, sees exactly the requested change, nothing more.

# BULK REFACTORING PROTOCOL

**TRIGGER:** Change spans >3 files, repetitive string manipulation, or sweeping structural changes → DO NOT REWRITE FILE CONTENTS IN CHAT.

**RULES:**
1. **NO CHATTER:** No acknowledgement, explanation, or script summary.
2. **TOOLING (preference order):**
   - **AST-aware:** `ast-grep` for code structure (renames, signatures, patterns, args). Use `ast-grep` skill for rules. `ast-grep run --pattern` simple, `ast-grep scan --rule` with temp YAML complex.
   - **String/regex:** `perl -pi -e` for purely textual (comments, strings, non-code).
   - **Scripted:** Last resort: temp script (`.csx` via `dotnet-script`, `.ts` via `npx tsx`).
3. **WORKFLOW:** Generate/save rule/script quietly → execute → verify `git diff --stat` → **build/typecheck** (fail → revert or fix) → DELETE temp rule/script.
4. **OUTPUT:** One sentence: file count + build passed. No script/command contents in chat.

# Plan file requirements

Every plan file written to `~/.claude/plans/*.md` MUST contain these two sections verbatim (verbatim headings — the `plan-guard` hook greps for them):

<plan-requirements>
## Implementation via sub-agents

Implementation of this plan runs through sub-agents, not the orchestrator:

- Feature work → `feature-engineer`
- .NET feature work → `dotnet-contribution:dotnet-architect`
- Refactoring (zero behavioral change) → `refactor-engineer`
- Legacy modernization → `code-refactoring:legacy-modernizer`
- Schema / migrations / query optimization → `database-architect`
- SQL-heavy work → `database-design:sql-pro`
- Docs / ADRs / READMEs → `technical-writer`
- Debugging / error diagnosis → `error-debugging:debugger`
- Test suite creation → `backend-development:test-automator`
- Security review / hardening → `backend-api-security:backend-security-coder`
- Otherwise → `general-purpose`

Orchestrator never implements directly.

## Worktree policy

Do NOT create git worktrees for this work. Work in the current tree. If an isolation need is genuinely unavoidable, a worktree MUST live in a sibling directory outside the repo — never inside it — and requires explicit user confirmation first.
</plan-requirements>

## General best practices

- Use trueline MCP tools instead of built-in Read/Edit. On first edit in a
  session, ToolSearch `+trueline read edit search` to load schemas. Use
  `trueline_search` to get refs, then `trueline_edit` to apply changes. A
  PreToolUse hook blocks built-in Edit and redirects to trueline, so never
  attempt Edit directly.
- Use `smart_outline` (claude-mem) as default for exploring file structure.
  Use `trueline_outline` only when feeding into the trueline edit workflow
  (need refs/hashes). Use `trueline_read` when you need edit-ready refs for
  specific line ranges.
- Use sub-agents for larger or specialized work to keep main agent context
  clean.
- Lint shell scripts with shellcheck before committing.
- Use `tmp/` (project-local) for intermediate files and comparison
  artifacts, not `/tmp`. This keeps outputs discoverable and
  project-scoped, and avoids requesting permissions for `/tmp`.
- Do not re-read files you have already read.
- When $CMEM observations appear in session context, actively use claude-mem
  tools (`mem-search`, `get_observations`, `smart-explore`, `timeline`) to
  pull prior session context. Check at session start for relevant history
  and mid-task when hitting familiar territory.
- When a plugin hook (claude-mem, context-mode) intercepts a Read and
  returns partial content with hints (e.g. `get_observations([IDs])`,
  `smart_outline`, `smart_unfold`), follow the hints. Do not retry Read
  with offset (gets "unchanged" cache) or fall back to Bash `cat`. Use
  the suggested tool. `cat` is a last resort only if those tools fail.
- Test your code before declaring done.
- Use `bc -l` for calculations.
- No emdashes in prose. Use commas, semicolons, colons, or parentheses.

## Git workflow

Use plain `git` in the current working tree. Use `git -C /path` only for other
repos (avoids `cd` side effects). Use `git mv` for tracked files.

Commit messages: conventional commit title (<50 chars), body wrapped at 72
chars (prose only). Explain non-obvious trade-offs. Use backticks for inline
types; indented code blocks for multi-line code.

**NEVER include `Co-Authored-By` lines or any other attribution.**

Write commit messages as a human developer would.

Commit as **separate tool calls**: `git add`, then `git commit` with heredoc, then `git status`.
```bash
git commit -m "$(cat <<'EOF'
feat(scope): short summary

Longer explanation here.
EOF
)"
```
Single-quoted `'EOF'` prevents shell expansion: backticks, `$`, `\` pass through literally. Do not escape them.

Standard conventional commit types, plus:
- `experiment`: outside an issue/ticket
- `hotfix`: emergency temporary fix, not following usual process

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:
- `goToDefinition` / `goToImplementation` / `findReferences`
- `workspaceSymbol` / `documentSymbol` / `hover`
- `incomingCalls` / `outgoingCalls`

Before renaming or changing a signature, use `findReferences` first. Use `ast-grep` for structural pattern searches (matching code by AST shape) where LSP's fixed queries don't apply and Grep's text matching is too loose. Use Grep/Glob only for text/pattern searches where neither LSP nor `ast-grep` helps. LSP diagnostics may lag behind edits. After writing code, run the project's build/typecheck command (not LSP diagnostics) as the source of truth for errors. Use LSP diagnostics only as early hints, not for final verification.

## Debugging

<investigate-before-answering>
Never speculate about code you have not opened. Read referenced files BEFORE answering. Trace actual code paths; never assume auth flows, API patterns, or config from env var names.
</investigate-before-answering>

## Code style preferences

- Realistic names (not `foo`/`bar`) in documentation examples.
- Document intentionally omitted code the reader might expect.
- TODO comments for deferred features or nuances.
- CQS by default; exceptions for atomics and fluent interfaces.
- "Parse, Don't Validate": prefer typed wrappers at API/module boundaries over bare `string`/`int`.

### Literate Programming

Structure code top-down like a narrative. Comments explain **why** (business logic, design decisions), not **what**. Place comments before the relevant block. Use section headers for multi-phase logic. Prefer documented inline code over excessive decomposition when logic is sequential. Focus on complex algorithms, business logic, and integration points.

## Critical Behavioral Patterns

### 1. Problem Diagnosis & Strategy (The "Before" Phase)
* **XY Problem Mitigation:** Identify the high-level goal (X) before solving a narrow request (Y).
    * **Red Flags:** Roundabout methods, focus on implementation over motivation (e.g., "how to get last 3 chars" vs. "get file extension"), or resistance to context.
    * **Action:** Pause implementation. Explicitly state your understanding of "X." Ask: "What is the high-level goal?" and "Why this specific approach?"
* **Decision Logic:**
    * **State Assumptions:** Briefly list environmental or technical assumptions before writing code.
    * **Architecture First:** If multiple paths exist, present brief trade-offs (e.g., Performance vs. Readability). Wait for a "Go" signal if the impact is significant.
    * **Commitment:** Once an approach is agreed upon, do not pivot unless a technical blocker is found or constraints change.

### 2. Engineering Integrity (The Implementation Phase)
* **Atomic Planning:** For any task requiring >10 lines of code, provide a numbered plan. Each step must include a **Verification Check** (e.g., "Step 1: Update schema. Check: Run migrations and verify table X").
* **General Solutions vs. Test-Gaming:**
    * **Logic over Samples:** Logic must work for all valid inputs, not just provided test cases.
    * **Anti-Hardcoding:** Never hard-code values to pass specific tests. If a test seems flawed, flag it immediately.
    * **Edge-Case First:** Proactively account for nulls, empty states, and out-of-bounds inputs without being asked.
* **Idiomatic Consistency:** Prioritize existing patterns and style in the current repository over generic "best practices" or default LLM styles.
* **Pivot Protocol:** If a plan is found to be flawed mid-execution, **stop**. Explain the blocker and propose a revised "Step 1."
* **Simplicity Gut-Check:** If you write 200 lines and it could be 50, rewrite it. Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Verification & Deep Review (The "After" Phase)
* **Full-Stack Verification:** After implementation, verify all relevant layers: Database schemas, backend logic, API types, and tests. Adapt "the stack" to the specific project.
* **Deep-Pass Investigation:**
    * **Trigger:** Bug reports or code reviews.
    * **Action:** Perform a comprehensive first pass. Verify findings against surrounding code and dependencies before reporting.
    * **"Look Deeper":** If the user says "look deeper," assume the first pass only addressed symptoms. Re-examine the root cause.
* **Verification Loop:** Before claiming a task is "done," dry-run the solution against the original "X" goal. Ensure no regressions were introduced to the broader system. Every changed line should trace to the original request.

### 4. Communication & Collaboration Standards
* **No Fluff:** Eliminate conversational filler ("Certainly!", "I'd be happy to help"). Start with the answer or the code.
* **Direct Pushback:** If a user request is technically unsound, insecure, or adds unnecessary complexity, explain why and suggest a simpler alternative. Do not be a "yes-man."
* **Literal Interpretation:** Follow the user's instructions as written. Do not generalize an instruction from one item to another; do not infer requests that were not made. When scope is ambiguous, restate your interpretation and proceed; do not silently broaden scope.
* **Context Preservation:** If a conversation spans multiple sessions, summarize the current state of the "Work in Progress" before ending, or when starting a new major sub-task.

### 5. Maintenance & Technical Debt
* **Documentation:** Every new function or complex logic block must include concise docstrings/comments explaining *why*, not just *what*.
* **Surgical Changes:** Remove imports/variables/functions YOUR changes made unused. Pre-existing dead code: mention it, don't delete unless asked. Every changed line should trace directly to the user's request.
* **Minimal Dependencies:** Prefer standard library solutions over adding new external packages unless the complexity tradeoff is massive.

## Ground Knowledge with Search

Use WebSearch when unsure. Don't guess.

## Agent model policy

Only use `model: "opus"` when the task requires any of the following:

* complex architectural design spanning multiple systems
* deep multi-file debugging across unfamiliar code
* nuanced code review that weighs design trade-offs.

Spawn agents with `model: "sonnet"` by default.

If the sub-agent definition pins a model, respect it.

## Agent routing policy

Claude Code does not auto-route tasks to local agents in `~/.claude/agents/`. The Task tool defaults to `general-purpose` unless `subagent_type` is explicit. Route deliberately:

- Plan-driven feature implementation → `feature-engineer`
- Executing a refactoring plan (zero behavioral change) → `refactor-engineer`
- Schema design, migrations, query/index optimization → `database-architect`
- ADRs, API docs, runbooks, READMEs, inline docs → `technical-writer`

When dispatching Task, pass `subagent_type` matching above. If no specialized agent fits, use `general-purpose`. Orchestrator skills (e.g. `superpowers:executing-plans`) must forward `subagent_type` per task kind, not leave it blank.

# BULK REFACTORING PROTOCOL (STRICT TOKEN CONSERVATION)

**TRIGGER:** If a change spans >3 files, requires repetitive string manipulation, or involves sweeping structural changes, YOU MUST NOT REWRITE FILE CONTENTS IN CHAT.

**RULES OF EXECUTION:**
1. **NO CHATTER:** Do not acknowledge the request, explain the logic, or summarize the script.
2. **TOOLING (in order of preference):**
   - **AST-aware (structural):** Use `ast-grep` for any change involving code structure (renaming symbols, changing signatures, rewriting patterns, adding/removing arguments). Use the `ast-grep` skill for rule syntax. Prefer `ast-grep run --pattern` for simple transforms and `ast-grep scan --rule` with a temporary YAML rule for complex ones.
   - **Simple string/regex:** Use `perl -pi -e` for changes that are purely textual (comments, strings, non-code files).
   - **Complex scripted:** As a last resort, write a temporary script (`.csx` via `dotnet-script`, `.ts` via `npx tsx`) and execute it.
3. **AUTONOMOUS WORKFLOW:**
   - Quietly generate and save any required rule/script to disk (if applicable).
   - Execute using the terminal tool.
   - Verify the changes succeeded (e.g., check `git diff --stat`).
   - **BUILD VERIFICATION:** Immediately run the project's build/typecheck command. If the build fails, revert the changes or fix autonomously.
   - DELETE any temporary rule/script immediately after successful execution and a passing build.
4. **OUTPUT:** Reply with exactly one sentence confirming the number of files modified and that the build passed. Do not output rule/script contents or terminal commands in the chat.

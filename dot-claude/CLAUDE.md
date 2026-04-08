## General best practices

- Use sub-agents for larger or specialized work to keep main agent context
  clean.
- Lint shell scripts with shellcheck before committing.
- Use `tmp/` (project-local) for intermediate files and comparison
  artifacts, not `/tmp`. This keeps outputs discoverable and
  project-scoped, and avoids requesting permissions for `/tmp`.
- Do not re-read files you have already read.
- Test your code before declaring done.
- Use `bc -l` for calculations.

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

Before renaming or changing a signature, use `findReferences` first. Use Grep/Glob only for text/pattern searches where LSP doesn't help. Check LSP diagnostics after writing code; fix type errors and missing imports immediately.

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
- No emdashes in prose. Use commas, semicolons, colons, or parentheses.

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

### 3. Verification & Deep Review (The "After" Phase)
* **Full-Stack Verification:** After implementation, verify all relevant layers: Database schemas, backend logic, API types, and tests. Adapt "the stack" to the specific project.
* **Deep-Pass Investigation:**
    * **Trigger:** Bug reports or code reviews.
    * **Action:** Perform a comprehensive first pass. Verify findings against surrounding code and dependencies before reporting.
    * **"Look Deeper":** If the user says "look deeper," assume the first pass only addressed symptoms. Re-examine the root cause.
* **Verification Loop:** Before claiming a task is "done," dry-run the solution against the original "X" goal. Ensure no regressions were introduced to the broader system.

### 4. Communication & Collaboration Standards
* **No Fluff:** Eliminate conversational filler ("Certainly!", "I'd be happy to help"). Start with the answer or the code.
* **Direct Pushback:** If a user request is technically unsound, insecure, or adds unnecessary complexity, explain why and suggest a simpler alternative. Do not be a "yes-man."
* **Context Preservation:** If a conversation spans multiple sessions, summarize the current state of the "Work in Progress" before ending, or when starting a new major sub-task.

### 5. Maintenance & Technical Debt
* **Documentation:** Every new function or complex logic block must include concise docstrings/comments explaining *why*, not just *what*.
* **Refactor-as-you-go:** If you encounter messy code in the immediate vicinity of your task, suggest a quick refactor. Do not contribute to technical debt.
* **Minimal Dependencies:** Prefer standard library solutions over adding new external packages unless the complexity tradeoff is massive.

## Ground Knowledge with Search

Use WebSearch when unsure. Don't guess.

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

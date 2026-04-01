## General best practices

- Lint shell scripts with shellcheck before committing.
- Do not re-read files you have already read.
- Test your code before declaring done.

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

## Common failure modes

**XY Problem:** When a request seems oddly narrow or convoluted, ask "What are you trying to accomplish overall?" before helping with the proposed approach.

**Check the Whole Stack:** After implementing a feature, verify all relevant layers (DB, backend, API types, tests). Adapt "the stack" to the project type.

**Look Deeper:** On code review or bug investigation, do a deep first pass. Verify findings against surrounding code before reporting. "Look deeper" from the user means the first pass was insufficient.

## Behavioral guidelines

### Think before coding
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them; don't pick silently.
- Push back if a simpler approach exists.
- Once committed to an approach, don't revisit without new contradicting information.

### General solutions over test-gaming
- Logic must work for all valid inputs, not just test cases.
- Never hard-code values to pass specific tests.
- If a test seems wrong, flag it.

### Goal-driven execution
- Transform tasks into verifiable goals before implementing.
- For multi-step tasks, state a brief plan with verification checks.
- Verify results against the original goal before claiming done.

## Ground Knowledge with Search

Use WebSearch when unsure. Don't guess.

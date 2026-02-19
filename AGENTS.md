## General best practices

- Run shell scripts through shellcheck.

### SESSION.md

While working, if you come across any bugs, missing features, or other
oddities about the implementation, structure, or workflow, **add a
concise description of them to SESSION.md** to defer solving such
incidental tasks until later. You do not need to fix them all straight
away unless they block your progress; writing them down is often
sufficient. **Do not write your accomplishments into this file.**

## Git workflow

Make sure you use git mv to move any files that are already checked into
git.

When writing commit messages, ensure that you explain any non-obvious
trade-offs we've made in the design or implementation.

Wrap any prose (but not code) in the commit message to match git commit
conventions, including the title. Also, follow semantic commit
conventions for the commit title.

When you refer to types or very short code snippets, place them in
backticks. When you have a full line of code or more than one line of
code, put them in indented code blocks.

### Creating commits

To commit, follow these steps as **separate tool calls**:

1. **Stage files** with `git add` (Bash tool).
2. **Commit** with `git commit` using a HEREDOC for the message
   (Bash tool). This is auto-approved via `Bash(git:commit *)` in
   permissions. Example:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat(scope): short summary

   Longer explanation here.
   EOF
   )"
   ```
   **Do not escape backticks** inside the heredoc body. The single-quoted
   `'EOF'` delimiter prevents all shell expansion, so backticks (and `$`,
   `\`, etc.) are passed through literally. Write `` `SomeType` ``, never
   `` \`SomeType\` ``.
3. **Verify** with `git status` (Bash tool).

#### Conventional Commit Types:

| Type | Description |
|------|-------------|
| bugfix | fixing a bug |
| build | changes that affect system compilation or is related to external dependencies; other changes that don't modify src or test |
| chore | updating grunt tasks etc; no production code change |
| ci | changes to CI configuration files and scripts |
| docs | changes to the documentation |
| experiment | experimenting outside of an issue/ticket |
| feature | adding, refactoring or removing a feature |
| hotfix | changing code with a temporary solution and/or without following the usual process (usually because of an emergency) |
| perf | related to backward-compatible performance improvements |
| refactor | code/style changes without changing functionality or fixing bugs |
| style | formatting, missing semi colons, etc; changes that do not affect the meaning of the code |
| test | adding missing tests, refactoring tests; no production code change |

## Debugging

When debugging production issues, ALWAYS read the actual code and
configuration files before proposing a fix. Never assume auth flows, API
patterns, or infrastructure config based on env var names or conventions.
Trace the actual code path first.

## Code style preferences

- Use realistic names in documentation examples.

Document when you have intentionally omitted code that the reader might
otherwise expect to be present.

Add TODO comments for features or nuances that were deemed not important
to add, support, or implement right away.

CQS (Command Query Separation) by default but carve out exceptions for atomics
and fluent interfaces.

"Parse, Don't Validate": parse unstructured input into a structured type.  Be
wary of bare `string`, `int`, etc.  Don't go overboard though.

### Literate Programming

Apply literate programming principles — structure code to read top-down
like a narrative, with comments explaining **why** (business logic, design
decisions) rather than **what** the code obviously does.

- Place explanatory comments immediately before the relevant code block.
- Use section headers for multi-phase logic:
  ```rust
  // ==============================================================================
  // Plugin Configuration Extraction
  // ==============================================================================
  ```
- Prefer clear, documented inline code over excessive function
  decomposition when logic is sequential and context-dependent.
- Focus on complex algorithms, business logic, and integration points.
  Skip obvious wrappers, trivial getters, and well-known patterns.

# Common failure modes when helping

## The XY Problem

When a request seems oddly narrow or convoluted, the user may be asking
about their attempted solution (Y) instead of the underlying problem (X).

**Warning signs:** specific technique without motivation, rejecting
alternatives outright, questions that feel roundabout.

**Response:** Ask "What are you trying to accomplish overall?" and
understand the real problem before helping with the proposed approach.

## Check the Whole Stack

After implementing any feature, verify completeness by checking:

- database constraints/migrations.
- backend validation.
- API spec/types.
- tests.

Do NOT consider a feature done until all layers are covered.

## Know When to Look Deeper

When asked to review code or investigate bugs, do a DEEP first pass. Don't
produce surface-level findings. Check for false positives before reporting -
verify each finding by reading surrounding code. If the user says 'look
deeper', treat it as a signal the first pass was insufficient.

## Behavioral guidelines

These bias toward caution over speed. For trivial tasks, use judgment.

### Think before coding
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.

### Simplicity first
- No features, abstractions, or error handling beyond what was asked.
- If you write 200 lines and it could be 50, rewrite it.

### Surgical changes
- Don't "improve" adjacent code, comments, or formatting.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Every changed line should trace directly to the user's request.

### Goal-driven execution
- Transform tasks into verifiable goals before implementing.
- For multi-step tasks, state a brief plan with verification checks.

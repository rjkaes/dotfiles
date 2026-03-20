## General best practices

- Lint shell scripts with shellcheck before committing.

## Git workflow

<git-directory-handling>
If you are already in the target repository's working tree, run plain
`git` with no directory flags, e.g. `git status`, `git add`, `git commit`.

Use `git -C /path/to/repo` **only** when targeting a repository that is
not the current working directory, as a replacement for
`cd /path/to/repo && git ...`. The `-C` flag changes git's working
directory without affecting the shell's, which avoids side effects on
subsequent commands.
</git-directory-handling>

Make sure you use git mv to move any files that are already checked into
git.

When writing commit messages, ensure that you explain any non-obvious
trade-offs we've made in the design or implementation.

Word-wrap prose (but not code) in commit messages at 72 characters.
Keep the title under 50 characters. Follow conventional commit format
for the title.

When you refer to types or very short code snippets, place them in
backticks. When you have a full line of code or more than one line of
code, put them in indented code blocks.

### Creating commits

**IMPORTANT: Never add `Co-Authored-By` or `Co-authored-by` lines to commit messages.**

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
| fix | fixing a bug |
| build | changes that affect system compilation or is related to external dependencies; other changes that don't modify src or test |
| chore | updating grunt tasks etc; no production code change |
| ci | changes to CI configuration files and scripts |
| docs | changes to the documentation |
| experiment | experimenting outside of an issue/ticket |
| feat | adding, refactoring or removing a feature |
| hotfix | changing code with a temporary solution and/or without following the usual process (usually because of an emergency) |
| perf | related to backward-compatible performance improvements |
| refactor | code/style changes without changing functionality or fixing bugs |
| style | formatting, missing semi colons, etc; changes that do not affect the meaning of the code |
| test | adding missing tests, refactoring tests; no production code change |

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:
- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use
`findReferences` to find all call sites first.

Use Grep/Glob only for text/pattern searches (comments,
strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before
moving on. Fix any type errors or missing imports immediately.

## Tool efficiency

<tool-efficiency>
When multiple independent tool calls are needed (e.g., reading several
files, running unrelated searches), make them all in parallel rather
than sequentially.

Use subagents only when tasks can genuinely run in parallel, require
isolated context, or involve independent workstreams. For simple
lookups, single-file edits, or tasks that need shared context across
steps, work directly rather than delegating.
</tool-efficiency>

## Debugging

<investigate-before-answering>
Never speculate about code you have not opened. If a file is
referenced, read it before answering. Investigate and read relevant
files BEFORE answering questions about the codebase.
</investigate-before-answering>

When debugging production issues, trace the actual code path first.
Never assume auth flows, API patterns, or infrastructure config based
on env var names or conventions.

## Code style preferences

- Use realistic names (not `foo`/`bar`) in documentation examples.

Document when you have intentionally omitted code that the reader might
otherwise expect to be present.

Add TODO comments for features or nuances that were deemed not important
to add, support, or implement right away.

CQS (Command Query Separation) by default but carve out exceptions for atomics
and fluent interfaces.

"Parse, Don't Validate": parse unstructured input into a structured type. Be
wary of bare `string`, `int`, etc. No need to newtype a local loop counter,
but prefer typed wrappers at API and module boundaries.

### Writing style

Do not use emdashes in prose. Use commas, semicolons, colons, or
parentheses instead. Reserve emdashes for cases where no other
punctuation can express the idea clearly.

### Literate Programming

Apply literate programming principles: structure code to read top-down
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

When the project has these layers, check them. Not all projects do;
for a dotfiles repo or a CLI tool, "the whole stack" is different than
for a web app. Adapt accordingly.

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
- If multiple interpretations exist, present them; don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- Once you choose an approach, commit to it. Don't revisit unless new
  information directly contradicts your reasoning.

### Simplicity first
- No features, abstractions, or error handling beyond what was asked.
- If you write 200 lines and it could be 50, rewrite it.
- Prefer editing existing files over creating new ones.
- Don't create helper scripts, utility files, or abstractions for one-off tasks.

### Surgical changes
- Don't "improve" adjacent code, comments, or formatting.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it; don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Every changed line should trace directly to the user's request.
- Clean up any temporary files or scripts created during iteration.

### Confirm before acting on shared state
- Before destructive operations (deleting files/branches, dropping tables,
  `rm -rf`, overwriting uncommitted changes), confirm with the user.
- Before hard-to-reverse operations (`git push --force`, `git reset --hard`,
  amending published commits), confirm with the user.
- Before externally visible actions (pushing code, commenting on PRs/issues,
  sending messages), confirm with the user.
- Local, reversible actions (editing files, running tests) are fine without
  confirmation.

### General solutions over test-gaming
- Implement logic that works for all valid inputs, not just test cases.
- Never hard-code values to make specific tests pass.
- If a test seems wrong, flag it rather than working around it.

### Goal-driven execution
- Transform tasks into verifiable goals before implementing.
- For multi-step tasks, state a brief plan with verification checks.
- Before claiming work is done, verify the result against the original
  goal. Run tests, check types, and confirm the change works.

### Bias toward action
- Implement changes directly; don't just describe or suggest them
  unless asked for a review or opinion.
- When told to fix or change something, do it; don't ask "would you
  like me to make this change?" unless genuinely ambiguous.
- Ask when the *goal* is unclear; act when the goal is clear but the
  *approach* has options.

## Working journal

Use [bd](https://github.com/steveyegge/beads) memories as a working
journal throughout each session. Write entries as you go, not at the
end. **Do not write accomplishments.**

Prefix each memory's `--key` with a category so `bd memories` output
stays scannable:

| Prefix | Use for |
|--------|---------|
| `defer/` | Bugs, missing features, or oddities you noticed but chose not to fix right now. |
| `dead-end/` | Approaches you tried that didn't work, and why. |
| `worked/` | Techniques, tools, or patterns that proved effective for this codebase. |
| `question/` | Uncertainties you couldn't resolve; things needing user input or deeper investigation. |

Examples:
```bash
bd remember "tried lazy-loading wezterm config via \
  wezterm.plugin but it broke hot-reload" \
  --key dead-end/wezterm-lazy-load

bd remember "unclear whether conform.nvim trim_whitespace \
  should apply to markdown files" \
  --key question/conform-trim-md
```

## Ground Knowledge with Search

Use WebSearch to ground your knowledge if you're unsure about something.
Don't guess or make something up: search for the truth.

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

**IMPORTANT!* - **NEVER** use `-C /path` when issuing `git` commands.

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

## Documentation preferences

### Documentation examples

- Use realistic names for types and variables.

## Code style preferences

Document when you have intentionally omitted code that the reader might
otherwise expect to be present.

Add TODO comments for features or nuances that were deemed not important
to add, support, or implement right away.

CQS (Command Query Separation) by default but carve out exceptions for atomics
and fluent interfaces.

"Parse, Don't Validate": parse unstructured input into a structured type.  Be
wary of bare `string`, `int`, etc.  Don't go overboard though.

### Literate Programming

Apply literate programming principles to make code self-documenting and
maintainable across all languages:

#### Core Principles

1. **Explain the Why, Not Just the What**: Focus on business logic, design
   decisions, and reasoning rather than describing what the code obviously
   does.

2. **Top-Down Narrative Flow**: Structure code to read like a story with clear
   sections that build logically:
   ```rust
   // ==============================================================================
   // Plugin Configuration Extraction
   // ==============================================================================

   // First, we extract plugin metadata from Cargo.toml to determine
   // what files we need to build and where to put them.
   ```

3. **Inline Context**: Place explanatory comments immediately before relevant
   code blocks, explaining the purpose and any important considerations:
   ```python
   # Convert timestamps to UTC for consistent comparison across time zones.
   # This prevents edge cases where local time changes affect rebuild detection.
   utc_timestamp = datetime.utcfromtimestamp(file_stat.st_mtime)
   ```

4. **Avoid Over-Abstraction**: Prefer clear, well-documented inline code over
   excessive function decomposition when logic is sequential and
   context-dependent. Functions should serve genuine reusability, not just
   file organization.

5. **Self-Contained When Practical**: Reduce dependencies on external shared
   utilities when the logic is straightforward enough to inline with good
   documentation.

#### Implementation Benefits

- **Maintainability**: Future developers can quickly understand both implementation and design rationale
- **Debugging**: When code fails, documentation helps identify which logical step failed and why
- **Knowledge Transfer**: Code serves as documentation of the problem domain, not just the solution
- **Reduced Cognitive Load**: Readers don't need to mentally reconstruct the author's reasoning

#### When to Apply

Use literate programming for:
- Complex algorithms with multiple phases or decision points
- Code implementing business logic rather than simple plumbing
- Code where the "why" is not immediately obvious from the "what"
- Integration points between systems where context matters

Avoid over-documenting:
- Simple utility functions where intent is clear from the signature
- Trivial getters/setters or obvious wrapper code
- Code that's primarily syntactic sugar over well-known patterns

# Common failure modes when helping

## The XY Problem

The XY problem occurs when someone asks about their attempted solution (Y)
instead of their actual underlying problem (X).

### The Pattern
1. User wants to accomplish goal X
2. User thinks Y is the best approach to solve X
3. User asks specifically about Y, not X
4. Helper becomes confused by the odd/narrow request
5. Time is wasted on suboptimal solutions

### Warning Signs to Watch For
- Focus on a specific technical method without explaining why
- Resistance to providing broader context when asked
- Rejecting alternative approaches outright
- Questions that seem oddly narrow or convoluted
- "How do I get the last 3 characters of a filename?" (when they want file extension)

### How to Avoid It (As Helper)
- **Ask probing questions**: "What are you trying to accomplish overall?"
- **Request context**: "Can you explain the bigger picture?"
- **Challenge assumptions**: "Why do you think this approach will work?"
- **Offer alternatives**: "Have you considered...?"

### Red Flags in User Requests
- Very specific technical questions without motivation
- Unusual or roundabout approaches to common problems
- Dismissal of "why do you want to do that?" questions
- Focus on implementation details before problem definition

### Key Principle
Always try to understand the fundamental problem (X) before helping with the
proposed solution (Y). The user's approach may not be optimal or may indicate
they're solving the wrong problem entirely.

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

## Behavioral guidelines to reduce common LLM coding mistakes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial
tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes,
simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it
work") require constant clarification.

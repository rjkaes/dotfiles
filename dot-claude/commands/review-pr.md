---
description: Comprehensive two-tier PR review with inline GitHub comments
argument-hint: <github-pr-url>
---

Review the pull request at $ARGUMENTS comprehensively using a two-tier approach.

## Step 1: Fetch PR metadata and early eligibility check

Use `gh pr view` to get the PR number, base branch, head SHA, repo owner/name,
and list of changed files. Store these for use in later steps.

**Fail-fast checks** (abort with a message if any fail):
- PR is not a draft and is still open.
- PR has not already received a review from this run.

**Context enrichment** (note for the review body, do not block):
- Check `gh pr checks` for CI status. If CI is failing, flag it later.
- Check if the PR is part of a stack (`gh pr list --head <branch>`) and note
  dependent PRs.

## Step 2: Identify applicable Tier 2 agents

Check the diff to determine which specialized agents apply:

- **silent-failure-hunter**: Always run. Catches swallowed errors, empty catch
  blocks, inappropriate fallbacks, missing error propagation.
- **pr-test-analyzer**: Always run. Identifies critical untested paths, edge
  case gaps, test quality issues.
- **security-auditor**: Run when the diff touches authentication, authorization,
  user input handling, database queries, cookie/session logic, crypto usage, or
  dependency files (`package.json`, `*.csproj`, `requirements.txt`, `go.mod`).
  Grep the diff for: `req.body`, `req.params`, `req.query`, SQL strings, `eval`,
  `innerHTML`, `dangerouslySetInnerHTML`, auth middleware, `jwt`, `bcrypt`,
  `crypto`, `cookie`, `session`, `password`, `secret`, `token`.
- **performance-reviewer**: Run when the diff touches database queries, ORM
  calls, loops over collections, API endpoint handlers, caching logic, or adds
  new dependencies. Grep the diff for: `.find(`, `.query(`, `SELECT`, `INSERT`,
  `.map(`, `.forEach(`, `cache`, `redis`, `paginate`, `limit`, `offset`.
- **architect-reviewer**: Run when the PR changes >10 files or >500 diff lines,
  or introduces new directories/modules/services. Checks layering violations,
  dependency direction, pattern consistency, and abstraction appropriateness.
- **comment-analyzer**: Run when the diff adds or modifies docstrings, JSDoc,
  XML doc comments (`///`), or README/documentation files. Catches stale
  comments, inaccurate parameter descriptions, misleading explanations.
- **type-design-analyzer**: Run only if the diff adds or modifies type/interface
  definitions. Rates encapsulation, invariant expression, enforcement.

## Step 3: Run Tier 1 and Tier 2 in parallel

Tier 1 and Tier 2 are independent. Launch them concurrently.

### Tier 1: Core Review

Use the `/code-review:code-review` skill. This runs 5 parallel Sonnet agents:
1. CLAUDE.md compliance audit
2. Shallow bug scan (changes only, high-signal, ignore linter-catchable issues)
3. Git blame/history context analysis
4. Previous PR comment applicability check
5. Code comment compliance verification

Each finding is scored 0-100 by a Haiku verification agent using this rubric:
- **0**: False positive, doesn't survive scrutiny, or pre-existing issue.
- **25**: Might be real, but unverified. Stylistic issues not in CLAUDE.md.
- **50**: Verified real, but a nitpick or unlikely in practice.
- **75**: Double-checked, very likely real, directly impacts functionality or
  is explicitly called out in CLAUDE.md.
- **100**: Confirmed with evidence, will happen frequently in practice.

Filter at 80+.

### Tier 2: Specialized Dimensions

Launch applicable agents (from Step 2) as **parallel Sonnet sub-agents**. Each
agent receives the full diff and list of changed files.

Each sub-agent must return findings in this exact format:

```
FILE: <path>
LINES: <start>-<end>
TYPE: issue | suggestion | nitpick
CONFIDENCE: <0-100>
DESCRIPTION: <one-line summary>
DETAIL: <explanation and recommended fix>
```

Sub-agents must **only return findings**. They must never run `gh pr comment`,
`gh api`, or any command that posts to the PR.

## Step 4: Score Tier 2 findings

For each Tier 2 finding, launch a **parallel Haiku agent** that takes the
finding, the relevant diff context, and any applicable CLAUDE.md files. The
agent scores the finding using the same 0-100 rubric from Tier 1.

Filter at 80+.

## Step 5: Calibrate and deduplicate

Compare all surviving findings across both tiers using these rules:

**Severity escalation:** When multiple agents flag the same file and overlapping
line range with related concerns, **escalate** rather than discard. Two agents
independently identifying the same area is a stronger signal. Promote
`suggestion` to `issue` or raise the confidence score to the higher value.

**True deduplication:** Only drop a finding if another finding targets the exact
same file, overlapping line range, AND describes the same root cause (not merely
the same location). When in doubt, keep both.

**Grouping:** Organize the final findings list by file path, then by severity
(`issue` > `todo` > `suggestion` > `nitpick`), rather than by source agent.
Source agent attribution is preserved in the comment prefix.

## Step 6: Post the review

Use `gh api` to submit a single pull request review with:

### Inline comments

Every surviving finding becomes an inline review comment attached to the
specific file and line range in the diff. Use **conventional comments** format
for every comment:

- `praise:` -- highlights something positive (leave at least one per review, but never false praise)
- `nitpick:` -- trivial preference-based request, always non-blocking
- `suggestion:` -- proposes an improvement, be explicit on what and why
- `issue:` -- specific problem, pair with a suggestion when possible, blocks merge
- `todo:` -- small, trivial, necessary change (distinguishes from heavier issues/suggestions)
- `question:` -- potential concern you're not sure about, asks author for clarification
- `thought:` -- idea that emerged from reviewing, non-blocking, may inspire follow-up work
- `chore:` -- process task required before merge (link to the process description)
- `note:` -- non-blocking, something the reader should be aware of

Prefix each comment with the source agent in brackets, e.g.:

```
**[silent-failure-hunter]** issue: Error from `fetchUser()` is caught and
silently discarded. This masks auth failures. Propagate or log at warn level.
```

### Review body

The body is a **summary only**. Do not repeat full finding details. Format:

```
### Code review

Reviewed N files. Found X issues, Y suggestions, Z nitpicks.

**Issues:**
- brief description (file:line)
- brief description (file:line)

**Suggestions:**
- brief description (file:line)

Sources: code-review (Tier 1), silent-failure-hunter, pr-test-analyzer [, security-auditor, performance-reviewer, architect-reviewer, comment-analyzer, type-design-analyzer] (Tier 2)
```

Append context lines from Step 1 if applicable:

- If CI is failing: `Warning: CI is currently red. Findings may overlap with build failures.`
- If PR is part of a stack: `Note: This PR is part of a stack: #X -> #Y (this) -> #Z`

If no findings survive filtering, post:

```
### Code review

No issues found. Checked for bugs, CLAUDE.md compliance, silent failures,
test coverage gaps[, security, performance, architecture, comment quality].
```

List only the dimensions that were actually run in the bracket.

### Verdict

Submit as `REQUEST_CHANGES` if any blocking findings (`issue:`, `todo:`,
`chore:`) remain. Otherwise `APPROVE`.

## Step 7: Final eligibility guard

Before posting, re-check with a Haiku agent that the PR is still open, not a
draft, and has not already received a review from this run. If ineligible, do
not post.

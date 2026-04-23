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
- PR has not already received a review from the authenticated viewer
  (`gh pr view <n> --json reviews -q '[.reviews[] | select(.author.login == "<viewer>")] | length'`
  returns 0, where `<viewer>` is resolved via `gh api user -q .login`).

**Context enrichment** (note for the review body, do not block):
- Check `gh pr checks` for CI status. If CI is failing, flag it later.
- Check if the PR is part of a stack (`gh pr list --head <branch>`) and note
  dependent PRs.

**Checkout the PR branch** (after eligibility checks pass, before any diff analysis):
```bash
gh pr checkout <PR-number>
```
This puts the code on disk so agents can read files directly.

## Step 2: Identify applicable Tier 2 agents

Check the diff to determine which specialized agents apply:

- **`pr-review-toolkit:silent-failure-hunter`**: Always run. Catches swallowed errors, empty catch
  blocks, inappropriate fallbacks, missing error propagation.
- **`pr-review-toolkit:pr-test-analyzer`**: Always run. Identifies critical untested paths, edge
  case gaps, test quality issues.
- **`security-scanning:security-auditor`**: Run when the diff touches authentication, authorization,
  user input handling, database queries, cookie/session logic, crypto usage, or
  dependency files (`package.json`, `*.csproj`, `requirements.txt`, `go.mod`).
  Grep the diff for: `req.body`, `req.params`, `req.query`, SQL strings, `eval`,
  `innerHTML`, `dangerouslySetInnerHTML`, auth middleware, `jwt`, `bcrypt`,
  `crypto`, `cookie`, `session`, `password`, `secret`, `token`.
- **`backend-development:performance-engineer`**: Run when the diff touches database queries, ORM
  calls, loops over collections, API endpoint handlers, caching logic, or adds
  new dependencies. Grep the diff for: `.find(`, `.query(`, `SELECT`, `INSERT`,
  `.map(`, `.forEach(`, `cache`, `redis`, `paginate`, `limit`, `offset`.
- **`backend-development:backend-architect`**: Run when the PR changes >10 files or >500 diff lines,
  or introduces new directories/modules/services. Checks layering violations,
  dependency direction, pattern consistency, and abstraction appropriateness.
- **`pr-review-toolkit:comment-analyzer`**: Run when the diff adds or modifies docstrings, JSDoc,
  XML doc comments (`///`), or README/documentation files. Catches stale
  comments, inaccurate parameter descriptions, misleading explanations.
- **`pr-review-toolkit:type-design-analyzer`**: Run only if the diff adds or modifies type/interface
  definitions. Rates encapsulation, invariant expression, enforcement.

## Step 3: Run Tier 1 and Tier 2 in parallel

Tier 1 and Tier 2 are independent. Launch them concurrently.

### Tier 1: Core Review

Precompute the CLAUDE.md file list once (root `CLAUDE.md` plus any `CLAUDE.md`
in directories containing changed files), then launch 5 parallel Task-tool calls
(not Skill tool) with `subagent_type: "general-purpose"` and `model: "sonnet"`.
Pass `$ARGUMENTS` (PR URL), the full PR diff, and the CLAUDE.md file paths to
every agent. Each agent performs one role:

1. Audit the changes for compliance with the CLAUDE.md files.
2. Shallow bug scan of the diff only (high-signal, ignore linter-catchable issues).
3. Read git blame/history of modified code and identify bugs in that context.
4. Read previous PRs that touched these files; flag comments that still apply.
5. Read code comments in modified files; verify the changes comply with that guidance.

Each finding is scored 0-100 by a Haiku verification agent using this rubric:
- **0**: False positive, doesn't survive scrutiny, or pre-existing issue.
- **25**: Might be real, but unverified. Stylistic issues not in CLAUDE.md.
- **50**: Verified real, but a nitpick or unlikely in practice.
- **75**: Double-checked, very likely real, directly impacts functionality or
  is explicitly called out in CLAUDE.md.
- **100**: Confirmed with evidence, will happen frequently in practice.

Filter at 80+.

### Tier 2: Specialized Dimensions

For each applicable agent (from Step 2), call the Task tool with
`subagent_type: "<qualified-name>"` (e.g. `pr-review-toolkit:silent-failure-hunter`),
`model: "sonnet"`, and a prompt containing:

- Full unified diff (from `gh pr diff`).
- List of changed-file paths.
- The required output format (see below).
- The CLAUDE.md file paths (same list precomputed in Tier 1).
- Instruction: only return findings, never run `gh pr comment`, `gh api`, or any
  command that posts to the PR.

Each agent must return findings in this exact format:

```
FILE: <path>
LINES: <start>-<end>
TYPE: issue | suggestion | nitpick
CONFIDENCE: <0-100>
DESCRIPTION: <one-line summary>
DETAIL: <explanation and recommended fix>
```

## Step 4: Score Tier 2 findings

For each Tier 2 finding, call the Task tool with `model: "haiku"` and
`subagent_type: "general-purpose"`. The agent receives: the finding text,
relevant diff context, the applicable CLAUDE.md file paths, and the 0-100
rubric below verbatim. It returns a single score.

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

**TYPE conflicts:** When two agents disagree on `TYPE` for an overlapping finding,
keep the higher severity (`issue` > `todo` > `suggestion` > `nitpick`).

## Step 6: Post the review

Post the review using `gh api` as follows:

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

**Posting procedure:**

1. Resolve the head commit SHA once:
   ```bash
   gh pr view <n> --json headRefOid -q .headRefOid
   ```
2. For each surviving finding, POST to
   `/repos/{owner}/{repo}/pulls/{number}/comments` with:
   ```json
   {
     "body": "**[<agent>]** <conventional-comment>",
     "commit_id": "<head-sha>",
     "path": "<file>",
     "line": <end-line>,
     "side": "RIGHT",
     "start_line": <start-line-if-range>,
     "start_side": "RIGHT"
   }
   ```
   Omit `start_line` and `start_side` for single-line findings. Use `side: "LEFT"`
   only when the finding targets a removed line.
   If a finding's `LINES` range falls outside the diff hunk, GitHub will reject the
   inline comment. In that case, degrade to a non-anchored comment by appending it
   to the review body instead.
3. After all inline comments are posted, submit the review via
   `POST /repos/{owner}/{repo}/pulls/{number}/reviews` with the summary body
   (see below) and `event` set per the verdict rule.

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

Sources: code-review (Tier 1), pr-review-toolkit:silent-failure-hunter, pr-review-toolkit:pr-test-analyzer [, security-scanning:security-auditor, backend-development:performance-engineer, backend-development:backend-architect, pr-review-toolkit:comment-analyzer, pr-review-toolkit:type-design-analyzer] (Tier 2)
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

Before posting, re-check with a Haiku agent (Task tool, `model: "haiku"`,
`subagent_type: "general-purpose"`) that the PR is still open, not a draft,
and has not already received a review from the authenticated viewer
(`gh pr view <n> --json reviews -q '[.reviews[] | select(.author.login == "<viewer>")] | length'`
returns 0, where `<viewer>` is resolved via `gh api user -q .login`). If
ineligible, do not post.

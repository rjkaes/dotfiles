---
description: Comprehensive two-tier PR review with inline GitHub comments
argument-hint: <github-pr-url>
---

Review the pull request at $ARGUMENTS comprehensively using a two-tier approach.

## Step 1: Fetch PR metadata and early eligibility check

Use `gh pr view` to get the PR number, base branch, head SHA, repo owner/name,
and list of changed files. Store the head SHA in `HEAD_SHA`. Store the other
values for use in later steps.

**Fail-fast checks** (abort with a message if any fail):
- PR is not a draft and is still open.
- PR has not already received a review from the authenticated viewer
  (`gh pr view <n> --json reviews -q '[.reviews[] | select(.author.login == "<viewer>")] | length'`
  returns 0, where `<viewer>` is resolved via `gh api user -q .login`).

**Self-review detection:** Resolve the viewer login (`gh api user -q .login`)
and the PR author (`gh pr view <n> --json author -q .author.login`). If they
match, set `SELF_REVIEW=1`. GitHub forbids self-APPROVE and
self-REQUEST_CHANGES; in Step 6 this forces `--event COMMENT` regardless of
finding types. Note this in the review body.

**Context enrichment** (note for the review body, do not block):
- Check `gh pr checks` for CI status. If CI is failing, flag it later.
- Check if the PR is part of a stack (`gh pr list --head <branch>`) and note
  dependent PRs.

**Checkout the PR branch** (after eligibility checks pass, before any diff analysis):
```bash
gh pr checkout <PR-number>
```
This puts the code on disk so agents can read files directly.

Immediately after checkout, generate the diff once and save it. All agents read from this file; the orchestrator never loads the full diff into its own context:
```bash
mkdir -p tmp
git diff origin/<base-branch>...HEAD > tmp/pr-diff.txt
```
Use the base branch retrieved earlier in this step.

## Step 2: Identify applicable Tier 2 agents

Grep `tmp/pr-diff.txt` to determine which specialized agents apply (do not load the full diff into context):

- **`pr-review-toolkit:silent-failure-hunter`**: Always run. Catches swallowed errors, empty catch
  blocks, inappropriate fallbacks, missing error propagation.
- **`pr-review-toolkit:pr-test-analyzer`**: Always run. Identifies critical untested paths, edge
  case gaps, test quality issues.
- **`security-scanning:security-auditor`**: Run when the diff touches authentication, authorization,
  user input handling, database queries, cookie/session logic, crypto usage, or
  dependency files (`package.json`, `*.csproj`, `requirements.txt`, `go.mod`).
  Grep `tmp/pr-diff.txt` for: `req.body`, `req.params`, `req.query`, SQL strings, `eval`,
  `innerHTML`, `dangerouslySetInnerHTML`, auth middleware, `jwt`, `bcrypt`,
  `crypto`, `cookie`, `session`, `password`, `secret`, `token`.
- **`backend-development:performance-engineer`**: Run when the diff touches database queries, ORM
  calls, loops over collections, API endpoint handlers, caching logic, or adds
  new dependencies. Grep `tmp/pr-diff.txt` for: `.find(`, `.query(`, `SELECT`, `INSERT`,
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
in directories containing changed files), then launch 4 parallel Task-tool calls
(not Skill tool) with `subagent_type: "general-purpose"` and `model: "sonnet"`.
Pass `$ARGUMENTS` (PR URL), the path `tmp/pr-diff.txt`, and the CLAUDE.md file paths to
every agent. Each agent reads the diff from that file. Each agent performs one role:

1. Shallow bug scan of the diff only (high-signal, ignore linter-catchable issues).
2. Read git blame/history of modified code and identify bugs in that context.
3. Read previous PRs that touched these files; flag comments that still apply.
4. Read code comments in modified files; verify the changes comply with that guidance.

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

- Path to `tmp/pr-diff.txt` (agents read this file directly; orchestrator does not pass diff inline).
- List of changed-file paths.
- The required output format (see below).
- The CLAUDE.md file paths (same list precomputed in Tier 1).
- Instruction: only return findings, never run `gh pr comment`, `gh api`, or any
  command that posts to the PR.

Each agent must return findings in this exact format:

```
FILE: <path relative to repo root>
LINES: <start>-<end>            # use single number, e.g. "42", for one-line findings
SIDE: RIGHT | LEFT              # default RIGHT; LEFT only for findings on removed lines
TYPE: praise | nitpick | suggestion | issue | todo | question | thought | chore | note
CONFIDENCE: <0-100>             # used for filtering only; NOT sent to the script
SOURCE: <agent qualified name>  # e.g. pr-review-toolkit:silent-failure-hunter
DESCRIPTION: <single-line summary, no newlines>
DETAIL: <multi-line elaboration ok>
```

Blocking types: `issue`, `todo`, `chore`. Non-blocking: `praise`, `nitpick`, `suggestion`, `question`, `thought`, `note`. Tier-1 and Tier-2 agents may emit any of these; Step 5 calibration may promote between types.

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

Post the review using the `gh-pr-review-post` script.

#### Build `tmp/findings.json`

For every surviving finding, emit one JSON object with exactly these keys:

| Source field     | JSON key      | Notes                                                        |
| ---------------- | ------------- | ------------------------------------------------------------ |
| `FILE`           | `file`        | string, required                                             |
| end of `LINES`   | `line`        | integer, required                                            |
| start of `LINES` | `start_line`  | integer, optional; **omit** when start == end                |
| `SIDE`           | `side`        | `"RIGHT"` (default) or `"LEFT"`; omit to default            |
| `TYPE`           | `type`        | one of the 9 conventional types                              |
| `SOURCE`         | `source`      | optional; script auto-prefixes `**[source]**`                |
| `DESCRIPTION`    | `description` | single-line string, required                                 |
| `DETAIL`         | `detail`      | optional, multi-line ok                                      |

**Do not pre-prefix `description` with `[source]` or with `type:`.** The script formats the body as `**[source]** type: description\n\ndetail`. Any manual prefix produces double prefixes.

**Drop `CONFIDENCE`.** It was a filter input; the script does not accept it.

#### Write `tmp/review-body.md`

Create the summary body at `tmp/review-body.md` before invoking the script.

#### Invoke once

```bash
gh-pr-review-post "$ARGUMENTS" \
  --summary tmp/review-body.md \
  --commit-sha "$HEAD_SHA" \
  ${SELF_REVIEW:+--event COMMENT} \
  < tmp/findings.json
```

- `$ARGUMENTS` is the PR URL.
- `$HEAD_SHA` is the head SHA captured in Step 1; pinning prevents comments from drifting if a new commit lands mid-review.
- For a clean PR (zero findings), still write `tmp/findings.json` as `[]` and add `--event APPROVE`:

  ```bash
  echo '[]' > tmp/findings.json
  gh-pr-review-post "$ARGUMENTS" \
    --summary tmp/review-body.md \
    --commit-sha "$HEAD_SHA" \
    --event APPROVE \
    < tmp/findings.json
  ```

- Do **not** call `gh api ...pulls/.../comments` or `...pulls/.../reviews` directly. The script owns posting.

#### Verdict

The script derives the verdict from finding types (REQUEST_CHANGES if any `issue|todo|chore`, APPROVE otherwise). Override with `--event` only for:
- Empty-findings APPROVE (above).
- `SELF_REVIEW=1` from Step 1: pass `--event COMMENT`. GitHub forbids self-APPROVE and self-REQUEST_CHANGES; the script will also auto-downgrade as a safety net.

#### Out-of-hunk fallback

The script appends out-of-hunk findings to the review body and prints a warning to stderr. Treat the warning as informational; do not retry.

## Step 7: Final eligibility guard

Before posting, re-check with a Haiku agent (Task tool, `model: "haiku"`,
`subagent_type: "general-purpose"`) that:

1. The PR is still open and not a draft.
2. The viewer has not already submitted a review:
   `gh pr view <n> --json reviews -q '[.reviews[] | select(.author.login == "<viewer>")] | length'`
   returns 0.
3. **No prior partial run left review comments behind:**
   `gh api --paginate repos/<owner>/<repo>/pulls/<n>/comments --jq '[.[] | select(.user.login == "<viewer>")] | length'`
   returns 0. If >0, abort and ask the user to confirm whether the prior
   partial review should be kept or cleaned up first. Do not auto-delete.
   (The script also enforces this via exit code 2 unless `--allow-duplicate`
   is passed.)

Resolve `<viewer>` via `gh api user -q .login`. If any check fails, do not post.

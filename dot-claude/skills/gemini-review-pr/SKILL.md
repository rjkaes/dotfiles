---
name: gemini-review-pr
description: Use when asked to review a GitHub PR with Gemini, get a second opinion or adversarial review of a pull request or branch diff, or when invoked via /gemini-review-pr <PR-url-or-number>. Supply a PR URL or number and Gemini reviews the full branch diff for security, performance, quality, and correctness.
---

# Gemini Review PR

## Overview

Consult Google Gemini Pro as an adversarial second-opinion reviewer of a GitHub pull request. You supply a PR URL or number; the skill gathers the PR metadata and full branch diff, assembles a combined adversarial-review + security-audit prompt biased at Claude's statistical blind spots, dispatches the `gemini-consultant` subagent, and verifies the findings against the cited code and reports them.

This is the PR-scoped sibling of `consult-gemini`. Where `consult-gemini` reviews an arbitrary file set for an arbitrary question, this skill's input is exactly one PR and the deliverable is exactly a full-diff review.

**Frame it as Gemini *challenging* Claude, not reviewing fresh.** The Claude+Gemini pair covers ~91% of a 5-model debate ceiling because their misses barely overlap — Gemini is stronger on concurrency races, API compatibility, permission/authorization gaps, and structural critique; weaker on deep logic and data-structure lifecycle.

## When to Use

- "review PR 496 with gemini", "gemini review this PR", "second opinion on PR #123"
- `/gemini-review-pr <url-or-number>`
- Before merging a substantial PR, to catch what Claude's own review misses.

**When NOT to use:**
- Reviewing uncommitted working-tree changes with no PR → use `consult-gemini` or a project review skill.
- Small targeted questions Claude can answer alone → answer directly.
- Deep logic bugs / data-structure lifecycle bugs → Claude outperforms Gemini alone; don't burn the call.

## Workflow

This skill owns argument parsing, gathering, prompt assembly, and dispatch. The `gemini-consultant` subagent owns Bash execution, `ask-gemini` invocation, capturing Gemini's stdout verbatim to `tmp/consult-pr-<n>.md`, and extracting its JSON object to `tmp/consult-pr-<n>.json`. The skill appends the full diff and, when the PR head is checked out, the full text of each changed file, so Gemini starts with every hunk and its surrounding code. Each tool call costs a model round trip, and Gemini pages files 60 to 150 lines per `read_file`: on a 15-file PR, inlining plus the template's tool-use rules cut model calls from 43-67 to 5-18 and time from 492-609 s to about 408 s. The rest is thinking: Flash Medium spends 35k to 55k thinking tokens per review (5 to 7 minutes) whatever the scope, so splitting one review into parallel narrower runs does not shorten it (measured: each part took 262-405 s).

### 1. Parse the argument

Accept either form:
- **Full URL:** `https://github.com/<owner>/<repo>/pull/<n>` → extract `<owner>/<repo>` and `<n>`.
- **Bare number** (`496` or `#496`) → use the current repo (`gh repo view --json nameWithOwner -q .nameWithOwner`).

If the argument is empty, ask once for the PR URL or number, then proceed.

### 2. Gather PR metadata + diff

Run (batch these; parallelize the two `gh` calls):

```bash
gh pr view <n> --repo <owner/repo> --json number,title,body,baseRefName,headRefName,headRefOid,additions,deletions,changedFiles,url
gh pr diff <n> --repo <owner/repo> --name-only
```

Then capture the **full unified diff to a temp file** so Gemini reviews exactly the PR's changes regardless of what is checked out locally:

```bash
gh pr diff <n> --repo <owner/repo> > tmp/pr-<n>.diff
```

The `tmp/pr-<n>.diff` file is the authoritative review artifact — it is correct even when the local working tree is on a different branch.

### 3. Decide whether full-file context is available

Compare local HEAD to the PR head:

```bash
git rev-parse HEAD   # vs headRefOid from step 2
```

- **HEAD == headRefOid:** the working tree matches the PR. Inline the changed **source** and test files in step 4 (skip lock files, generated migrations and pure-doc noise), so Gemini reads each hunk with its whole file and spends no tool calls on them.
- **HEAD != headRefOid:** don't list working-tree paths for full reads — they are stale and would mislead Gemini. Feed only `tmp/pr-<n>.diff`. Optionally offer to `gh pr checkout <n>` first (mutates the working tree — confirm with the user before running).

### 4. Assemble the prompt

Fill the template below from the PR metadata. Keep it a single logical prompt string. Write it with the Write tool to `tmp/gemini-pr-<n>-prompt.txt`, then append the diff with one Bash line: `cat tmp/pr-<n>.diff >> tmp/gemini-pr-<n>-prompt.txt`. Over 200 KB of diff, skip the append and keep the template's read-the-file line for `tmp/pr-<n>.diff`; a lock file or generated migration is the usual cause. When HEAD matches the PR head, then append the changed files in one Bash line: `for f in <paths>; do printf '\n=== FILE %s ===\n' "$f"; cat "$f"; done >> tmp/gemini-pr-<n>-prompt.txt`. Stop adding files once their text passes 300 KB, and list the rest as paths in the template's not-inlined line. Name the concrete change (from the PR title/body) so Gemini reviews intent-vs-implementation, not just syntax.

### 5. Dispatch `gemini-consultant`

Use the `Agent` tool with `subagent_type: "gemini-consultant"`. Tell the subagent to `cd` to the project root, send the prompt file `tmp/gemini-pr-<n>-prompt.txt` unchanged (it already holds the diff, and the subagent must not rewrite it), use the slug `pr-<n>`, and run `ask-gemini < tmp/gemini-pr-<n>-prompt.txt` as a **single-line** Bash command — never the prompt inline, never a heredoc (the permission layer prompts on them). The prompt asks for JSON, so the hand-back is `tmp/consult-pr-<n>.json`, its finding count, the verdict, and one `severity file:line claim` line per finding. For a follow-up round on the same PR, tell it to use `--resume latest`.

No Agent tool (you are a sub-agent, or the caller forbids it, as `/triple-review` does): read `~/.claude/agents/gemini-consultant.md` and run its steps yourself, JSON section included.

### 6. Integrate findings

Read records from `tmp/consult-pr-<n>.json` with `jq`; each carries its own evidence and scenario. Verify each finding by opening its `file` and `line` in the saved diff (`tmp/pr-<n>.diff`) and mark it Confirmed, Refuted, or Could not confirm (say where you looked). A caller that wants a findings file, such as `/triple-review`, gets every `.findings` record unchanged plus `dropped`: the refuting line for a Refuted finding, else null. Report in this order: anything needing the user's decision first; then confirmed findings, each with one recommended next step; then the "Could not confirm" list. When presenting, point the user to the JSON file and list each finding's severity, location and claim instead of pasting the whole output. Don't implement unless asked.

## Prompt Template

Fill `<...>` placeholders from PR metadata. The three debate rules and the finding schema are mandatory — they lift Gemini's detection rate and block its known "verdict-first" failure mode.

```
Role: Senior Staff Engineer / Security Architect acting as an ADVERSARIAL reviewer.
Context: Claude Code implemented and self-reviewed PR #<n> "<title>" on <repo>. Summary of the change (from the PR body): <2-4 sentence paraphrase of what the PR does and why>. Your job is to CHALLENGE Claude's conclusions, not duplicate them. Assume Claude is competent on deep logic and data-structure lifecycle; concentrate where Claude is statistically weakest:
  - Concurrency / data races / lock semantics / TOCTOU / ordering assumptions
  - Cross-version / cloud-storage / deprecated-SDK API compatibility
  - Missing permission / authorization / tenant-isolation checks at handler or route boundaries
  - Structural / engineering-standards issues (coupling, layering, naming, base-class design)
  - For DB changes: migration correctness, data loss, reversibility, cascade-delete blast radius, unintended cascade paths, orphaned rows

Rules (mandatory):
  1. Every finding MUST cite file:line or a verbatim code snippet. No claim without a code reference.
  2. Lead with EVIDENCE, conclude with the verdict. Do not open with a verdict and backfill.
  3. If you agree with Claude on a point, explain WHY with the specific supporting code evidence — never bare "agreed".
  4. Distinguish root cause from contributing factor.

Deliverable: one JSON object and nothing else: no code fence, no prose. List findings most-severe first (skip trivial style nits unless they signal a systemic pattern). Keys come in this order, so evidence precedes every conclusion (rule 2) and the overall verdict comes last:

  {"findings": [
    {"category": "security|correctness|concurrency|performance|migration|structure",
     "file": "<path>",
     "line": <integer, or null when no single line applies>,
     "evidence": "<verbatim code, newlines escaped as \n>",
     "scenario": "<attack path or failure scenario: concrete steps to the wrong outcome>",
     "claim": "<one sentence: the defect, marked root cause or contributing factor>",
     "severity": "Critical|High|Medium|Low",
     "fix": "<specific change>"}
  ],
  "verdict": "<ship|block|ship-with-fixes>: <one sentence grounded in the findings>"}

Tool use: every tool call costs a full model round trip (about 5 s, and the whole context is resent each time).
  - Read whole files: call read_file with no StartLine or EndLine. Never page through a file in slices.
  - Decide every file you need first, then request all of them in ONE turn as parallel read_file calls. Make a second round only for a file the first round revealed.
  - Never re-read a file. At most 10 tool calls in total.

Primary artifact: the full unified diff of the PR, below the line "=== PR DIFF ===". It is complete; do not re-read it from disk.
<IF the diff is over 200 KB, use this line in place of the one above and drop the "=== PR DIFF ===" marker:> Primary artifact — read this first with your read_file tool: tmp/pr-<n>.diff (the full unified diff of the PR).
<IF working tree matches the PR head, ALSO append:>
Changed files: their full current contents are appended at the end under "=== FILE <path> ===" headers. Do not read them with read_file: <explicit list of inlined source + test paths, one per line>.
<IF changed files went past the 300 KB budget, ALSO append:> Changed files not inlined. Read one only when a finding depends on code the diff does not show: <paths, one per line>.

=== PR DIFF ===
```

## Quick Reference

| Step | Command / Tool |
|------|----------------|
| Repo of current dir | `gh repo view --json nameWithOwner -q .nameWithOwner` |
| PR metadata | `gh pr view <n> --repo <r> --json number,title,body,baseRefName,headRefName,headRefOid,changedFiles,url` |
| Changed file names | `gh pr diff <n> --repo <r> --name-only` |
| Full diff → artifact | `gh pr diff <n> --repo <r> > tmp/pr-<n>.diff` |
| Working tree matches PR? | `git rev-parse HEAD` == `headRefOid` |
| Dispatch | `Agent(subagent_type: "gemini-consultant", ...)`; no Agent tool: run `~/.claude/agents/gemini-consultant.md` inline |
| Finding count | `jq '.findings \| length' tmp/consult-pr-<n>.json` |
| Follow-up round | subagent runs `ask-gemini --resume latest` |

## Common Mistakes

- **Listing working-tree paths when HEAD ≠ PR head.** Gemini reads stale files and reviews the wrong code. Feed only `tmp/pr-<n>.diff` unless the PR branch is checked out.
- **Inline or heredoc `ask-gemini` prompt.** The template is multiline, so either triggers a permission prompt the subagent cannot answer. Write the prompt to a `tmp/` file and redirect it on stdin.
- **Listing changed files as paths when the PR head is checked out.** Gemini pages each one 60 to 150 lines per call, one call per model round trip. Inline them (step 4); only files outside the change, or past the 300 KB budget, stay as paths.
- **Picking Flash Low or `-e low` for speed.** It skips thinking (0 tokens) and finishes in 12 to 47 s, but on a re-review it returned "ship" while missing 3 of 4 confirmed findings, and on a small PR it missed the one confirmed bug. Flash Medium (the agy default) is the floor; Argon quota is limited.
- **Accepting findings unverified.** Open each cited file:line and mark it Confirmed, Refuted, or Could not confirm (§6).
- **Omitting the change paraphrase.** Without intent, Gemini reviews syntax, not intent-vs-implementation.
- **>3 debate rounds.** Gemini drifts in later rounds; start a fresh session for new scope.

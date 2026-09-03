---
name: gemini-review-pr
description: Use when asked to review a GitHub PR with Gemini, get a second opinion or adversarial review of a pull request or branch diff, or when invoked via /gemini-review-pr <PR-url-or-number>. Supply a PR URL or number and Gemini reviews the full branch diff for security, performance, quality, and correctness.
---

# Gemini Review PR

## Overview

Consult Google Gemini Pro as an adversarial second-opinion reviewer of a GitHub pull request. You supply a PR URL or number; the skill gathers the PR metadata and full branch diff, assembles a combined adversarial-review + security-audit prompt biased at Claude's statistical blind spots, dispatches the `gemini-consultant` subagent, and integrates the findings with proposed actions.

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

This skill owns argument parsing, gathering, prompt assembly, and dispatch. The `gemini-consultant` subagent owns Bash execution, `ask-gemini` invocation, and verbatim relay. File/diff bytes never enter this skill's context — paths are passed to the subagent, which lists them for Gemini to read via its own `read_file` tool.

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

- **HEAD == headRefOid:** the working tree matches the PR. List changed **source** file paths (skip lock files and pure-doc noise; keep tests) so Gemini can read whole files for richer context in addition to the diff.
- **HEAD != headRefOid:** do NOT list working-tree paths for full reads — they are stale and would mislead Gemini. Feed only `tmp/pr-<n>.diff`. Optionally offer to `gh pr checkout <n>` first (mutates the working tree — confirm with the user before running).

### 4. Assemble the prompt

Fill the template below from the PR metadata. Keep it a single logical prompt string. Name the concrete change (from the PR title/body) so Gemini reviews intent-vs-implementation, not just syntax.

### 5. Dispatch `gemini-consultant`

Use the `Agent` tool with `subagent_type: "gemini-consultant"`. Tell the subagent to `cd` to the project root before running `ask-gemini`, and to run `ask-gemini "<question>"` as a **single-line** Bash command (no multiline, no heredoc — fish shell). If the prompt is long, instruct the subagent to write it to `tmp/gemini-pr-<n>-prompt.txt` (Write tool) and run `ask-gemini (cat tmp/gemini-pr-<n>-prompt.txt)`. The subagent relays Gemini's output verbatim. For a follow-up round on the same PR, tell it to use `--resume latest`.

### 6. Integrate findings

Do not relay raw findings without a proposed action, scaled to severity:
- **Critical/Blocking** → explicitly propose creating a sub-task per issue.
- **Single architectural blocker** → offer a design decision or ADR.
- **Batch of medium/minor** → offer to implement directly or fold into a follow-up commit.

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

Deliverable: one record per finding, most-severe first, using exactly this schema (skip trivial style nits unless they signal a systemic pattern):

  ### Finding <n> — <Critical|High|Medium|Low>
  - **Category:** <security|correctness|concurrency|performance|migration|structure>
  - **File/Line:** <path:line>
  - **Evidence:** <code reference; fenced block if multiline>
  - **Attack Path or Failure Scenario:** <concrete steps to the wrong outcome>
  - **Suggested Fix:** <specific change; fenced block if code>

End with a one-paragraph overall verdict (ship / block / ship-with-fixes) grounded in the findings.

Primary artifact — read this first with your read_file tool: tmp/pr-<n>.diff (the full unified diff of the PR).
<IF working tree matches the PR head, ALSO append:>
For deeper context, read these changed source files in full: <explicit list of source + test paths, one per line>.
```

## Quick Reference

| Step | Command / Tool |
|------|----------------|
| Repo of current dir | `gh repo view --json nameWithOwner -q .nameWithOwner` |
| PR metadata | `gh pr view <n> --repo <r> --json number,title,body,baseRefName,headRefName,headRefOid,changedFiles,url` |
| Changed file names | `gh pr diff <n> --repo <r> --name-only` |
| Full diff → artifact | `gh pr diff <n> --repo <r> > tmp/pr-<n>.diff` |
| Working tree matches PR? | `git rev-parse HEAD` == `headRefOid` |
| Dispatch | `Agent(subagent_type: "gemini-consultant", ...)` |
| Follow-up round | subagent runs `ask-gemini --resume latest` |

## Common Mistakes

- **Listing working-tree paths when HEAD ≠ PR head.** Gemini reads stale files and reviews the wrong code. Feed only `tmp/pr-<n>.diff` unless the PR branch is checked out.
- **Multiline / heredoc `ask-gemini` in fish.** Breaks. Single line, or write the prompt to a `tmp/` file and `cat` it.
- **`cat`-ing files into the prompt.** Wastes context and defeats Gemini's `read_file`. Pass paths only.
- **Relaying findings without actions.** Always propose next steps scaled to severity (§6).
- **Omitting the change paraphrase.** Without intent, Gemini reviews syntax, not intent-vs-implementation.
- **>3 debate rounds.** Gemini drifts in later rounds; start a fresh session for new scope.

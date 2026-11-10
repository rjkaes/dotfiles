---
name: gh-pr-review-post
description: Use when posting inline review comments to a GitHub PR - a batch of file/line-anchored findings submitted as one review. Covers the findings JSON schema, verdict derivation, the duplicate guard, and out-of-hunk fallback for the ~/bin/gh-pr-review-post script. Read this instead of hand-rolling `gh api .../pulls/N/comments` calls.
---

# gh-pr-review-post

Posts a whole review (body + every inline comment) in a single
`POST /repos/{owner}/{repo}/pulls/{N}/reviews` call. Do not use
`gh api .../pulls/N/comments` for review findings: each such call spawns its own
orphan review record on the PR.

## Invocation

```bash
gh-pr-review-post <pr-ref> [options] < findings.json
```

`<pr-ref>` is a PR URL, `owner/repo#N`, or a bare `N` (resolved against the
current repo).

Findings arrive on **stdin only**. Write them to a file first:

```bash
gh-pr-review-post 4821 --summary tmp/review-body.md < tmp/findings.json
```

Never heredoc or `echo`-pipe the JSON. The permission layer turns that into an
interactive prompt a sub-agent cannot answer.

## Findings schema

JSON array. Per object:

| key | type | required | meaning |
|---|---|---|---|
| `file` | string | yes | path relative to repo root |
| `line` | integer | yes | end line, 1-based |
| `start_line` | integer | no | start of a multi-line range |
| `side` | string | no | `RIGHT` (default) or `LEFT` for removed lines |
| `type` | string | yes | `praise` `nitpick` `suggestion` `issue` `todo` `question` `thought` `chore` `note` |
| `description` | string | yes | single line; a newline is a hard validation error |
| `detail` | string | no | multi-line elaboration, rendered below the header |

Do not pre-prefix `description` with the type. The script renders
`type: description`; prefixing yourself doubles it.

Example:

```json
[
  {
    "file": "src/billing/invoice_totals.rb",
    "line": 88,
    "start_line": 84,
    "type": "issue",
    "description": "Tax is applied before the volume discount, inflating every tiered invoice",
    "detail": "`apply_tax` runs at line 84 but `apply_discount` at line 91..."
  }
]
```

## Writing the comments

Write for a junior developer. Each comment says what is wrong, why it must
change, and which concept to learn from it.

- `description` states the defect as its effect, in plain words: "Tax is
  applied before the discount, so tiered invoices are overcharged".
- `detail` covers four things, in order:
  1. What the code does now, naming the line or symbol.
  2. Why that breaks: a concrete input, the wrong result, and who sees it.
     "Best practice" with no consequence is not a reason.
  3. The fix. For a few lines on a `RIGHT`-side range, use a
     ```` ```suggestion ```` block; GitHub turns it into a one-click commit
     that replaces `start_line`..`line`.
  4. The general concept by its searchable name (off-by-one, N+1 query,
     race condition), plus an official doc link when one exists.
- Define jargon in a clause on first use.
- `praise` names what works and why, so the pattern gets repeated.
- `question` says what prompted it, so the answer teaches both sides.
- `nitpick` marks itself optional and still gives the reason.
- Skip "just", "simply", "obviously": they tell the reader a gap is their fault.

Example `detail` (rendered as markdown below the header):

```markdown
`apply_tax` (line 84) runs before `apply_discount` (line 91), so tax is
charged on the pre-discount subtotal. A $1,000 order with a $100 volume
discount and 13% tax bills $1,030 (tax on $1,000) instead of $1,017 (tax
on $900).

Fix: call `apply_discount` first, then `apply_tax` on its result.

Background: a discount lowers the taxable base, so tax applies to the
discounted price. When two steps adjust the same amount, their order is
part of the business rule; pin it with a test that asserts one known total.
```

## Verdict

Derived unless `--event` overrides it:

- any `issue` / `todo` / `chore` → `REQUEST_CHANGES`
- findings present, none blocking → `APPROVE`
- empty array → `COMMENT` (requires `--summary` or `--summary-text`)

If the viewer authored the PR, `REQUEST_CHANGES` is auto-downgraded to `COMMENT`
with a note appended to the body; GitHub forbids self-request-changes. Suppress
self-`APPROVE` yourself, the script does not.

## Options

- `--summary FILE` / `--summary-text S` - review body (mutually exclusive)
- `--event APPROVE|REQUEST_CHANGES|COMMENT` - override the derived verdict
- `--commit-sha SHA` - override head SHA
- `--dry-run` - print the payload, hit no network, skip every guard
- `--no-fallback` - fail on out-of-hunk findings instead of demoting them
- `--allow-duplicate` - bypass the prior-comment guard

## Exit codes and their gotchas

**exit 2 - duplicate guard.** The script counts existing review comments by the
viewer on the PR and refuses to post if any exist. This is the recovery path for
a half-posted earlier run. Read the prior comments before overriding; if they are
stale, stop and ask the user whether to delete them; don't reach for `--allow-duplicate`.

**exit 1 with "outside diff hunks".** Only reachable with `--no-fallback`. By
default such findings are silently demoted into an "Out-of-diff findings" section
of the review body, one bullet each, with a warning on stderr. A finding is
in-hunk when its **end** `line` falls inside a hunk on the matching `side`; the
script parses `@@` headers from `/pulls/N/files` to decide. If hunk fetching
fails it proceeds without pre-validation and lets the API arbitrate.

**exit 1 on 422.** Stderr carries mapped hints for self-approve, self-request-changes,
and line-not-in-diff. A line-not-in-diff 422 usually means `--commit-sha` does not
match the PR head.

## Workflow

1. Collect findings, write to `tmp/findings.json` (project-local `tmp/`, not `/tmp`).
2. `--dry-run` first on anything nontrivial; it validates the schema and prints
   the exact payload.
3. Post for real. Non-zero exit means nothing was posted, the submit is atomic.

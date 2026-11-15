---
description: Re-review a PR after fixes. Checks each requested change was made correctly, then runs /triple-review for new issues
argument-hint: <pr-number> [focus note]
---

Re-review PR #$ARGUMENTS after the author's fixes.
Two questions: was each requested change made correctly, and did the fixes add new issues?
Change no code. Post nothing to GitHub.

## 1. Parse the arguments

- The first word of `$ARGUMENTS` is the PR number, `<n>` below. The rest is an optional focus note.
- `<n>` missing or not a number: ask for it once and stop.
- Pass only `<n>` to commands and file names. Extra words break `/triple-review`'s file paths.

## 2. Build the request ledger

Fetch every review thread and review with one GraphQL call:

```shell
gh api graphql -F owner='{owner}' -F repo='{repo}' -F n=<n> -f query='query($owner:String!,$repo:String!,$n:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$n){author{login} headRefOid baseRefName reviewThreads(first:100){nodes{isResolved isOutdated path line originalLine comments(first:50){nodes{author{login} createdAt url body commit{oid} originalCommit{oid}}}}} reviews(first:100){nodes{author{login} state submittedAt url commit{oid} body}}}}}'
```

Also read the PR conversation: `gh api --paginate repos/{owner}/{repo}/issues/<n>/comments`.
The author's replies and any "review response checklist" there name the fix commits.

Write `tmp/rereview-<n>-requests.json`: one JSON array, one object per request, with keys:

- `id`: R1, R2, ... in thread order, then review bodies, then conversation comments.
- `by`: reviewer login. `url`: link to the comment.
- `file`, `line`: from the thread, `originalLine` when `line` is null. Null for a review body.
- `kind`: `change` (a defect or requested edit) or `question`.
- `ask`: the request in one sentence, with its failure case if the reviewer gave one.
- `reviewed_at`: the commit the comment was written against (full oid).
- `author_reply`: what the author says was done, with the commits they name. Null if no reply.
- `thread_resolved`: the thread's `isResolved`, null for non-thread requests.

Requests come from every reviewer except the PR author, bots included.
Skip approvals with an empty body, and comments with no request (thanks, +1).
Run `jq empty` on the file and rewrite it until it passes.

## 3. Map the fix range

The working tree is already a checkout of the PR. Run no `gh pr checkout`.

- Fetch each `reviewed_at` oid: `git fetch origin <full-oid>`. A force-push may have removed it from the branch.
- Reviewed commit present: `git range-diff <base-at-review>..<reviewed_at> origin/<base>..HEAD` shows what changed since the review. `<base-at-review>` is `git merge-base origin/<base> <reviewed_at>`.
  In it, `>` and `!` lines are the fix range. A stacked PR's old base commits show as `<` with no match; they are not fixes.
- Reviewed commit gone: use the commits the author's replies name, matched to current commits by subject.
- Write the fix range (commits and files) to `tmp/rereview-<n>-fixes.md`.

## 4. Run /triple-review with the ledger

Invoke the Skill tool with skill `triple-review`, args `<n>`. Follow it, with these additions:

- Skip its step 1 HEAD check: the working tree is already the PR.
  Still fetch the PR title and body, and paste them into each sub-agent prompt as its step 2 says.
- Each of its three sub-agent prompts also says: "Read `tmp/rereview-<n>-requests.json` and `tmp/rereview-<n>-fixes.md`. For each request, check the current code does what the request asked. Report a request not done, half done, or done in a way that breaks something as a finding, with the request `id` in `claim`. Review the fix commits for new defects as closely as the original diff."
- Add the focus note, if any, to each sub-agent prompt.
- Its step 4 report comes after this command's request table (step 5 below). Keep its numbering and its verdict rules.

## 5. Verify each request yourself

Sub-agent results do not settle a request. For every ledger entry, open the code at HEAD and decide:

- `Resolved`: the code does what was asked, and the reviewer's failure case can no longer happen. Name the test that pins it, or say none does.
- `Partial`: part done. Say which part is missing.
- `Not resolved`: unchanged, or the author's reply claims a fix the code does not contain.
- `Resolved differently`: the author took another route. Say whether it closes the failure case.
- `Answered`: a question with an answer. Check each factual claim in the answer against the code (`file:line`); a claim the code contradicts makes it `Not resolved`.
- `Regressed`: the fix broke something else. This also becomes a numbered finding.

A thread marked resolved on GitHub proves nothing. Check the code.
Where the author cites a test, open it and confirm it asserts the reviewer's failure case.
Where a fix lives in another PR, check that PR is merged into the base and the code is at HEAD.

## 6. Report

1. Request table: `id | by | ask | status | evidence (file:line, commit, test)`, one row per ledger entry.
2. The `/triple-review` report, numbered as it numbers findings. Mark each finding `fix range` when its line is in a commit from `tmp/rereview-<n>-fixes.md`, else `pre-existing`.
3. End with one verdict line:
   - `Verdict: Ship.` when every request is `Resolved`, `Resolved differently` and closed, or `Answered`, and no Must fix finding remains.
   - Otherwise `Verdict: <ids and numbers> first.`, naming the open requests and the findings to fix (`R2, 3 and 5 first.`).

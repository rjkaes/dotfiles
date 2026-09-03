---
description: Split the current work into a set of revieable PRs.
---

Split the current work into the smallest set of independently reviewable PRs,
each safe to merge on its own, and each delivering value to the user whenever
the work allows. Create a git worktree and branch off `main` for each. Stack
only where a dependency is real; otherwise branch from `main`. Any removal of
the code being replaced goes in its own final PR. Show me the proposed split
before creating anything.

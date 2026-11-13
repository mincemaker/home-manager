---
description: Prepare a commit using a lightweight model
model: openai/gpt-6-luna
skill: git-commit
restore: true
---
Prepare a commit for the current changes. $@

Use this two-turn workflow:
1. Review the changes and any required validation evidence before proposing
   the commit. Reuse existing results and accept the user's confirmation of
   build, switch, and real-hardware checks. Ask only about specific missing
   evidence, never because you did not personally perform a check.
   Show the staged diff and proposed commit message, then wait for approval.
2. A reply such as "ok", "ok. commit", or "コミットして" approves that diff
   and message and authorizes git commit in that reply's turn. Do not ask
   for approval or completed validation again. Before committing, check only
   that the staged diff is unchanged and no conflicts or Git operations are
   in progress. If unchanged and clear, commit with the approved message,
   using normal signing and hooks. Do not change files or the index.
   Stop only for changed content, conflicts, an operation in progress, or
   an actual error; state the concrete reason. Never push.

After committing, verify that the recorded diff and message match the
approved content and no target changes remain staged or unstaged.
Report only the commit ID and verification result.

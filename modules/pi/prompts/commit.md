---
description: Prepare a commit using a lightweight model
model: openai/gpt-6-luna
skill: git-commit
restore: true
---
Prepare a commit for the current changes. $@

Do not append generic "not checked", skipped-work, or risk footers, even
if a general style instruction requests them. Report only concrete blockers
or errors relevant to this commit. Missing evidence is not evidence that a
check was not performed; do not claim checks are unnecessary without a basis.

Use this two-turn workflow:
1. Review the changes and any required validation evidence before proposing
   the commit. Reuse existing results and accept the user's confirmation of
   build, switch, and real-hardware checks. Before asking for missing evidence,
   inspect available local state: for Home Manager, compare the current
   configuration's activationPackage.outPath with the active generation.
   A match establishes that its build output is active, not runtime behavior.
   Ask only about evidence still missing, never because you did not personally
   perform a check.
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

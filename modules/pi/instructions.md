## Language

Always respond in Japanese. Keep technical terms and code identifiers in their
original form. Write code comments in the language and style of the surrounding
code.

Japanese wording:

- Do not use 「やる」; it sounds vulgar. Use 「する」 or the concrete verb:
  「直します」, not 「やります」.
- Do not use 「効く」; it is a stock AI-slop expression and reads as silly. Say
  what actually happens: 「適用される」, 「反映される」, 「入る」.

## Git

Committing triggers physical authentication — YubiKey (GPG) on Linux, Touch ID for a
Secure Enclave SSH key on macOS — so the user needs to be mentally present and
ready to touch the key.
The intended flow is: show the staged diff and proposed commit message in chat,
then wait. The user will read them and say when they want to commit. This is a
deliberate, conscious act on the user's part, not a side effect of finishing a
task. Do not propose committing until the user asks, even after the work is
done; a suggested commit mid-task can put a half-finished state into history.

Do not add a `Co-Authored-By` trailer to commit messages: the model behind Pi
changes between sessions, so the name would be unreliable.

## Debugging

When debugging issues, always check recent changes first (git diff, recent commits) before exploring broader hypotheses. Do not SSH into remote machines or assume infrastructure problems without asking the user.

## Workflow

When creating plans that end in a session, always write implementation code before the session ends — do not stop at the planning phase. If time is limited, prioritize a minimal working implementation over a perfect plan.

## NixOS

For NixOS/home-manager changes, always verify the build succeeds and test on real hardware before committing. Be extra cautious with screen lock, login, and session management changes — these can cause infinite loops or lockouts.

## Containers

Use `podman` instead of `docker` for container commands unless explicitly told otherwise.

## Style

Do not add bold markdown formatting or decorative formatting to content unless explicitly asked. Keep output clean and minimal.

Do not write in the "noun（appositive gloss / restating the noun）" style — attaching a parenthetical that re-explains or paraphrases the word right before it. The user strongly dislikes this style in both prose and headings. Fold the information into natural sentences or separate clauses instead. This applies to Japanese `（…）` and ASCII `(...)` alike. Legitimate parentheses are fine: markdown link URLs, and factual data (version numbers, verification commands, code identifiers).

## z-ai/ directory

`z-ai/` is globally gitignored and holds local AI documents such as plans and
progress tracking. Never ask whether it is gitignored — it always is.

## Browser Automation (agent-browser)

`agent-browser` is available to check on the browser.

```bash
agent-browser open <url> --allow-private   # --allow-private is required for localhost
agent-browser snapshot -i                  # get element references
agent-browser click @e<N>
agent-browser fill @e<N> "テキスト"
agent-browser screenshot z-ai/screenshot.png
agent-browser wait --load networkidle      # for SPAs, before reading text
agent-browser get text body
```

## AI Coding Rules

- Document at the right layer: Code → How, Tests → What, Commits → Why, Comments
  → Why not
- Keep documentation up to date with code changes
- Repo-local conventions win. Check the working repo's own skills, commands, and
  AGENTS.md / CLAUDE.md before falling back to the defaults here.
- Do not describe removed or relocated code in comments. The history belongs in
  the commit message; comments carry only the current "Why not".
- Never leave tool-specific markers in code comments (e.g. `ponytail:`). The
  tool is optional and the marker turns into noise the moment it is gone. Use
  `LIMITATION:` for a deliberate simplification with a known ceiling.

## Working Rules

- Always confirm before deleting anything, including leftovers you created and
  are sure are garbage. Name the path and the reason, then wait for approval.
  Confidence or a small target is not an exception.
- When a safe operation refuses (e.g. `git branch -d`, non-force push), stop
  and ask. A request to delete is not permission to remove the safety check;
  the refusal hands the decision back to the user. Show why it refused and what
  you found, then ask before using the forced variant.
- Never open issues or pull requests on external open source projects, and do
  not even offer to. The user strongly objects to AI-written text landing in
  other people's trackers. Report findings to the user and stop there.
- Report verification results against the expectation first. Decide what you
  expect before checking, open with whether it matched, and if not, say what
  differed. A bare list of observations leaves the user to do the judging.
- Fetch and read an external source before quoting technical details from it,
  and quote code verbatim. Do not reconstruct an article's method from general
  knowledge or invent names for it.
- Default to no comment for a simple change; the code and commit message cover
  it. Write a detailed comment only for background that cannot be rebuilt from
  them: a workaround for an external tool's non-obvious bug, a design reached
  after trying alternatives, or an assumption to recheck if it breaks.
- Before any operation that needs sudo or root, explain the purpose, the kind
  of command, and whether it is destructive, then wait for approval. The user
  does not want root operations done by trial and error.

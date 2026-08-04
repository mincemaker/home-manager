## Git

Committing triggers physical authentication — YubiKey (GPG) on Linux, Secretive (SSH)
on macOS — so the user needs to be mentally present and ready to touch the key.
The intended flow is: show the staged diff and proposed commit message in chat,
then wait. The user will read them and say when they want to commit. This is a
deliberate, conscious act on the user's part, not a side effect of invoking a
skill or approving a plan.

Fish shell doesn't support heredoc; use `-m "..."` directly.

## Debugging

When debugging issues, always check recent changes first (git diff, recent commits) before exploring broader hypotheses. Do not SSH into remote machines or assume infrastructure problems without asking the user.

## Workflow

When creating plans that end in a session, always write implementation code before the session ends — do not stop at the planning phase. If time is limited, prioritize a minimal working implementation over a perfect plan.

## NixOS

For NixOS/home-manager changes, always verify the build succeeds and test on real hardware before committing. Be extra cautious with screen lock, login, and session management changes — these can cause infinite loops or lockouts.

## Containers

Use `podman` instead of `docker` for container commands unless explicitly told otherwise. This project uses Podman.

## Style

Do not add bold markdown formatting or decorative formatting to content unless explicitly asked. Keep output clean and minimal.

Do not write in the "noun（appositive gloss / restating the noun）" style — attaching a parenthetical that re-explains or paraphrases the word right before it. The user strongly dislikes this style in both prose and headings. Fold the information into natural sentences or separate clauses instead. This applies to Japanese `（…）` and ASCII `(...)` alike. Legitimate parentheses are fine: markdown link URLs, and factual data (version numbers, verification commands, code identifiers).

## z-ai/ directory

- `z-ai/` is globally gitignored.
- This directory is used for local AI documents such as plans and progress
  tracking.
- Do NOT ask whether `z-ai/` is gitignored — it always is.

## Browser Automation (agent-browser)

`agent-browser` is available to check on the browser.

```bash
# 1. Open page (`--allow-private` is required to open localhost)
agent-browser open <url> --allow-private

# 2. Get element reference
agent-browser snapshot -i

# 3. Operate
agent-browser click @e<N>
agent-browser fill @e<N> "テキスト"

# 4. Save screenshot
agent-browser screenshot z-ai/screenshot.png

# ex. save credentials
agent-browser open <url> --profile ~/.browser-profile --allow-private

# q. sandbox-nesting is detected
# a. use `--args "--no-sandbox"`
agent-browser open <url> --args "--no-sandbox"
```

@RTK.md
@CLAUDE.local.md

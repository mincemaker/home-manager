## Git

Git commit signing varies by platform:

- macOS: Uses Secretive for SSH signing. Run `git commit` directly — Secretive will prompt the user for touch authentication.
- Linux: Uses YubiKey for GPG signing. Never run `git commit` directly. Instead, stage files and prepare the commit message, then instruct the user to run the commit themselves.

The user's shell is fish. fish does not support heredoc (`<<'EOF'`). Always pass commit messages with `-m "..."` directly — multi-line strings work fine inside double quotes in fish.

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

## Research and Exploration

For broad codebase investigation tasks, delegate to the `gemini-explore` sub-agent instead of doing it yourself:

- Broad codebase searches (`**/*.ts`, `grep -r` across the whole project, "where is X implemented?")
- Understanding an unfamiliar module or feature across many files

Do NOT delegate web research (library docs, CVEs, error messages, API references) to `gemini-explore` — Gemini web search is too slow and unreliable. Handle web research directly with WebSearch or WebFetch.

Use direct tools (Bash, Read, Grep) only for targeted lookups — a specific file, a known function name, a single config. If the task would take more than 2-3 lookups, delegate.

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

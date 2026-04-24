## Git

Git commits require YubiKey touch for GPG signing. Never attempt `git commit` with `-S` flag or expect signing to work automatically. Instead, prepare the commit message and stage files, then tell the user to run the commit command themselves.

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

@RTK.md

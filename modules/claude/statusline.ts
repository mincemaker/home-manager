#!/usr/bin/env -S deno run --allow-run --allow-read --allow-write --allow-env
// Claude Code statusline script (Deno)

const ICON = {
  robo: "\u{F06A9}",
  folder: "\u{F4D3}",
  folderChanged: "\u{F0252}",
  gitBranch: "\u{E725}",
  battery: [
    "\u{F008E}", "\u{F007A}", "\u{F007B}", "\u{F007C}", "\u{F007D}",
    "\u{F007F}", "\u{F0080}", "\u{F0081}", "\u{F0082}", "\u{F0083}",
  ],
} as const;

const COLOR = {
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  green: "\x1b[32m",
  reset: "\x1b[0m",
} as const;

function colorByPct(pct: number): string {
  if (pct >= 90) return COLOR.red;
  if (pct >= 70) return COLOR.yellow;
  return COLOR.green;
}

function symbolByPct(pct: number): string {
  const idx = pct >= 95 ? 9 : Math.max(0, Math.floor(pct / 10));
  return ICON.battery[idx];
}

function formatRemaining(resetAt: number | null): string {
  if (resetAt == null) return "-";
  const remaining = resetAt - Math.floor(Date.now() / 1000);
  if (remaining <= 0) return "now";
  if (remaining < 3600) return `${Math.floor(remaining / 60)}m`;
  if (remaining < 86400) return `${Math.floor(remaining / 3600)}h`;
  return `${Math.floor(remaining / 86400)}d`;
}

async function getGitBranch(cwd?: string): Promise<string> {
  const opts = { stderr: "null" as const, stdout: "null" as const, ...(cwd && { cwd }) };
  try {
    const { success } = await new Deno.Command("git", {
      ...opts,
      args: ["rev-parse", "--git-dir"],
    }).output();
    if (!success) return "";

    const pipeOpts = { ...opts, stdout: "piped" as const };
    const branch = new TextDecoder().decode(
      (await new Deno.Command("git", { ...pipeOpts, args: ["branch", "--show-current"] }).output()).stdout,
    ).trim();
    if (branch) return ` | ${ICON.gitBranch} ${branch}`;

    const hash = new TextDecoder().decode(
      (await new Deno.Command("git", { ...pipeOpts, args: ["rev-parse", "--short", "HEAD"] }).output()).stdout,
    ).trim();
    if (hash) return ` | ${ICON.gitBranch} HEAD (${hash})`;
  } catch { /* ignore */ }
  return "";
}

const CACHE_FILE = `${Deno.env.get("HOME") ?? "/tmp"}/.claude/statusline_cache.json`;

async function readCache() {
  try {
    return JSON.parse(await Deno.readTextFile(CACHE_FILE));
  } catch { return {}; }
}

async function writeCache(data: any) {
  try {
    await Deno.writeTextFile(CACHE_FILE, JSON.stringify(data));
  } catch { /* ignore */ }
}

async function readStdin(): Promise<string> {
  const buf = new Uint8Array(1024 * 64);
  const n = await Deno.stdin.read(buf);
  return new TextDecoder().decode(buf.subarray(0, n ?? 0));
}

async function main() {
  const inputRaw = await readStdin();
  if (!inputRaw.trim()) return;

  let input: any;
  try {
    input = JSON.parse(inputRaw);
  } catch { return; }

  const cache = await readCache();

  // Update cache only if new data is present
  const hasRateData = input.rate_limits?.five_hour || input.rate_limits?.seven_day;
  const hasContextData = input.context_window?.used_percentage != null;

  if (hasRateData || hasContextData) {
    const newCache = {
      ...cache,
      ...(hasRateData && { rate_limits: input.rate_limits }),
      ...(hasContextData && { context_window: input.context_window }),
    };
    await writeCache(newCache);
    // Use the newly updated data
    input.rate_limits = input.rate_limits ?? newCache.rate_limits;
    input.context_window = input.context_window ?? newCache.context_window;
  } else {
    // Fallback to cache for all metrics
    input.rate_limits = cache.rate_limits;
    input.context_window = cache.context_window;
  }

  const model = (input.model?.display_name ?? "").replace(/\s*\(1M context\)/, " 1M");
  const effort = input.effort?.level ?? "";
  const modelDisplay = effort ? `${model} ${effort}` : model;
  const currentDir = input.workspace?.current_dir ?? "";
  const projectDir = input.workspace?.project_dir ?? "";

  const ctxPct = Math.floor(input.context_window?.used_percentage ?? 0);
  const fivePct = Math.floor(input.rate_limits?.five_hour?.used_percentage ?? 0);
  const weekPct = Math.floor(input.rate_limits?.seven_day?.used_percentage ?? 0);
  const weekReset = input.rate_limits?.seven_day?.resets_at ?? null;

  const dirName = currentDir.split("/").pop() ?? "";
  const dirSymbol = currentDir !== projectDir ? ICON.folderChanged : ICON.folder;

  const gitBranch = await getGitBranch(currentDir || undefined);
  const weekResetDisplay = formatRemaining(weekReset);

  const R = COLOR.reset;
  const segments = [
    `${ICON.robo} ${modelDisplay}`,
    `${dirSymbol} ${dirName}${gitBranch}`,
    `ctx ${colorByPct(ctxPct)}${symbolByPct(ctxPct)} ${ctxPct}%${R}`,
    `5h ${colorByPct(fivePct)}${symbolByPct(fivePct)} ${fivePct}%${R}`,
    `7d ${colorByPct(weekPct)}${symbolByPct(weekPct)} ${weekPct}%${R} (~${weekResetDisplay})`,
  ];

  console.log(segments.join(" | "));
}

main().catch(() => {});

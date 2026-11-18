import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmodSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

const bin = process.env.AGY_GUARD_BIN;
assert.ok(bin, "AGY_GUARD_BIN must point to the built guard-and-guide-agy");

const shellInput = JSON.stringify({ toolCall: { args: { CommandLine: "ls" } } });

function run(input, fakeGuard) {
	const dir = mkdtempSync(join(tmpdir(), "agy-guard-"));
	if (fakeGuard !== undefined) {
		const path = join(dir, "guard-and-guide");
		writeFileSync(path, `#!/bin/sh\n${fakeGuard}\n`);
		chmodSync(path, 0o755);
	}
	const result = spawnSync(bin, { input, env: { PATH: dir }, encoding: "utf8" });
	return JSON.parse(result.stdout).decision;
}

test("allows when guard-and-guide exits 0 silently", () => {
	assert.equal(run(shellInput, "/bin/cat >/dev/null"), "allow");
});

test("passes through a deny from guard-and-guide", () => {
	assert.equal(run(shellInput, `echo '{"decision":"deny","reason":"x"}'`), "deny");
});

test("denies on broken JSON input", () => {
	assert.equal(run("{not json", "/bin/cat >/dev/null"), "deny");
});

for (const input of ["null", "[]", '{"toolCall":null}', '{"toolCall":{"args":"x"}}']) {
	test(`denies on unexpected input shape ${input}`, () => {
		assert.equal(run(input, "/bin/cat >/dev/null"), "deny");
	});
}

test("denies when CommandLine is missing", () => {
	assert.equal(run(JSON.stringify({ toolCall: { args: { command: "ls" } } }), "/bin/cat >/dev/null"), "deny");
});

test("denies when guard-and-guide is missing", () => {
	assert.equal(run(shellInput), "deny");
});

test("denies when guard-and-guide exits non-zero silently", () => {
	assert.equal(run(shellInput, "exit 1"), "deny");
});

test("denies when guard-and-guide times out", () => {
	assert.equal(run(shellInput, "/bin/sleep 12"), "deny");
});

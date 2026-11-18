import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import test from "node:test";

const rules = process.env.GAG_RULES;
assert.ok(rules, "GAG_RULES must point to a guard-and-guide rules.toml");

function denied(command) {
	const result = spawnSync("guard-and-guide", ["--config", rules], {
		input: JSON.stringify({ tool_name: "Bash", tool_input: { command } }),
		encoding: "utf8",
	});
	return /git push/.test(result.stdout + result.stderr);
}

for (const command of [
	"git push origin main",
	"git push",
	"git -C /tmp/repo push",
	"rtk git push",
	"cd x && git push origin main",
	"git\tpush",
	'git "push" origin main',
	"git 'push'",
]) {
	test(`blocks ${JSON.stringify(command)}`, () => {
		assert.equal(denied(command), true);
	});
}

for (const command of [
	"cat modules/pi/tests/deny-git-push.test.mjs",
	"rg git-push README.md",
	"ls modules/pi/extensions/deny-git-push.ts",
	"git status",
]) {
	test(`allows ${JSON.stringify(command)}`, () => {
		assert.equal(denied(command), false);
	});
}

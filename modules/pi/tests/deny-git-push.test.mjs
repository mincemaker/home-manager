import assert from "node:assert/strict";
import test from "node:test";
import register from "../extensions/deny-git-push.ts";

let handler;
register({
	on(event, callback) {
		assert.equal(event, "tool_call");
		handler = callback;
	},
});

for (const command of [
	"git push origin main",
	"rtk git push origin main",
	"git -C /tmp/repo push",
	"gh repo create owner/repo --public --source=. --push",
	"rtk gh repo create mincemaker/skills --public --source=. --remote=origin --push",
	"gh repo create owner/repo --push --private --source=.",
	["gh repo create owner/repo ", "  --public --source=. --push"].join("\\\n"),
	["rtk gh repo create owner/repo ", "  --public --source=. --push"].join("\\\n"),
	["git pu", "sh origin main"].join("\\\n"),
]) {
	test(`blocks ${command}`, async () => {
		assert.equal((await handler({ toolName: "bash", input: { command } }))?.block, true);
	});
}

for (const command of [
	"git status",
	"rtk gh repo view owner/repo",
	"gh repo create owner/repo --public --source=. --remote=origin",
	["gh repo create owner/repo ", "  --public --source=."].join("\\\n"),
	"gh repo create owner/repo --description=--push",
	"gh repo create owner/repo; echo --push",
]) {
	test(`allows ${command}`, async () => {
		assert.equal(await handler({ toolName: "bash", input: { command } }), undefined);
	});
}

test("does not block file content", async () => {
	assert.equal(await handler({ toolName: "write", input: { path: "README.md", content: "git push" } }), undefined);
});

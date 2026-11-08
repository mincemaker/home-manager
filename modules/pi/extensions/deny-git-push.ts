import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return;

		const command = (event.input.command as string).replace(/\\\n/g, "");
		// LIMITATION: Pattern matching prevents common mistakes, not arbitrary shell bypasses.
		if (
			/\bgit(?:\s+-{1,2}\S+(?:\s+[^\s-]\S*)?)*\s+push\b/.test(command) ||
			/\bgh\s+repo\s+create\b[^\n;&|]*\s--push(?=[\s=;&|]|$)/.test(command)
		)
			return { block: true, reason: "Pushing is denied, including gh repo create --push. The user pushes by themselves; do not retry via another command or offer to push." };
	});
}

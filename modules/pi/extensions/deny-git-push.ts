import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName === "bash" && /\bgit(?:\s+-{1,2}\S+(?:\s+[^\s-]\S*)?)*\s+push\b/.test(event.input.command as string))
			return { block: true, reason: "git push is denied. The user pushes by themselves; do not offer or mention it." };
	});
}

/**
 * Confirm Actions Extension
 *
 * Asks for confirmation before executing destructive tool calls.
 *
 * - `write` / `edit`: always prompted (inherently mutate file content).
 * - `bash`: only prompted when the command matches a destructive pattern.
 *   Benign commands (ls, grep, cat-likes, git status, …) pass through.
 *
 * Choices:
 *   - Allow              → run the tool as-is.
 *   - Allow for session  → run, and auto-approve future calls with the
 *                          same key (bash: exact command string;
 *                          write/edit: target path) for the rest of this
 *                          pi process.
 *   - Yes, but…          → prompt for free text, then BLOCK the call and
 *                          feed the text back to the model as the block
 *                          reason so it can adjust and retry. (pi's
 *                          tool_call hook can only allow or block —
 *                          there is no "allow + inject info".)
 *   - Block              → cancel the call with a generic reason.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Patterns that mark a bash command as destructive. Matched against the
// raw command string; intentionally broad — false positives just mean an
// extra prompt, false negatives mean an unconfirmed mutation.
const DESTRUCTIVE_BASH = [
	/\brm\b/,
	/\brmdir\b/,
	/\bmv\b/,
	/\bdd\b/,
	/\bmkfs\b/,
	/\bshred\b/,
	/\btruncate\b/,
	/\bchmod\b/,
	/\bchown\b/,
	/\bchgrp\b/,
	/\bsudo\b/,
	/\bdoas\b/,
	/\bsu\b\s/,
	/\bkill(all)?\b/,
	/\bpkill\b/,
	/\bsystemctl\s+(start|stop|restart|reload|enable|disable|mask)/,
	/\bservice\s+\S+\s+(start|stop|restart|reload)/,
	/\bmount\b|\bumount\b/,
	/\bnixos-rebuild\b/,
	/\bdarwin-rebuild\b/,
	/\bnix-collect-garbage\b/,
	/\bnix\s+(profile|store|build|run|develop|flake\s+update)/,
	/\bgit\s+(reset|clean|checkout\s+--|restore|rebase|cherry-pick|revert|rm)\b/,
	/\bgit\s+push\b.*\s(-f|--force|--force-with-lease)\b/,
	/\bgit\s+branch\s+-[dD]\b/,
	/\bgit\s+tag\s+-d\b/,
	/\bgit\s+stash\s+(drop|clear|pop)/,
	/\bsed\s+(-[a-zA-Z]*i|--in-place)/,
	/\bfind\b.*-delete\b/,
	/\bfind\b.*-exec\b.*\b(rm|mv|chmod|chown)\b/,
	/\bxargs\b.*\b(rm|mv|chmod|chown)\b/,
	/\b(npm|pnpm|yarn|bun)\s+(publish|unpublish|deprecate)/,
	/\b(npm|pnpm|yarn|bun)\s+(install|i|add|remove|rm|uninstall|update|upgrade)/,
	/\bcargo\s+publish\b/,
	/\bpip\s+(install|uninstall)/,
	/\bdocker\s+(rm|rmi|system\s+prune|volume\s+rm)/,
	/\bpodman\s+(rm|rmi|system\s+prune|volume\s+rm)/,
	/\bcurl\b.*\|\s*(sh|bash|zsh)/,
	/\bwget\b.*\|\s*(sh|bash|zsh)/,
	// Output redirection that overwrites or appends to files.
	/(^|[^>&])>\s*\S/,
	/>>\s*\S/,
	// In-place tee.
	/\btee\b(?!.*--)/,
];

function isDestructiveBash(cmd: string): boolean {
	return DESTRUCTIVE_BASH.some((re) => re.test(cmd));
}

export default function (pi: ExtensionAPI) {
	// Session-scoped allow-list. Key format: `${toolName}:${identity}`
	// where identity is the exact command (bash) or path (write/edit).
	// Lives for the lifetime of the pi process.
	const sessionAllow = new Set<string>();

	pi.on("tool_call", async (event, ctx) => {
		if (!ctx.hasUI) return undefined;

		let summary: string;
		let allowKey: string;

		switch (event.toolName) {
			case "bash": {
				const cmd = event.input.command as string;
				if (!isDestructiveBash(cmd)) return undefined;
				summary = `bash: ${cmd.length > 200 ? cmd.slice(0, 200) + "…" : cmd}`;
				allowKey = `bash:${cmd}`;
				break;
			}
			case "write": {
				const path = event.input.path as string;
				summary = `write: ${path}`;
				allowKey = `write:${path}`;
				break;
			}
			case "edit": {
				const path = event.input.path as string;
				const edits = event.input.edits as unknown[];
				summary = `edit: ${path} (${edits.length} change${edits.length > 1 ? "s" : ""})`;
				allowKey = `edit:${path}`;
				break;
			}
			default:
				return undefined;
		}

		if (sessionAllow.has(allowKey)) return undefined;

		const choice = await ctx.ui.select(summary, [
			"Allow",
			"Allow for session",
			"Yes, but…",
			"Block",
		]);

		if (choice === "Allow") return undefined;

		if (choice === "Allow for session") {
			sessionAllow.add(allowKey);
			return undefined;
		}

		if (choice === "Yes, but…") {
			const note = await ctx.ui.input("Feedback for the model:", "");
			const trimmed = (note ?? "").trim();
			return {
				block: true,
				reason: trimmed
					? `User approved in principle but added guidance — please incorporate and retry: ${trimmed}`
					: "Blocked by user (no note provided)",
			};
		}

		return { block: true, reason: "Blocked by user" };
	});
}

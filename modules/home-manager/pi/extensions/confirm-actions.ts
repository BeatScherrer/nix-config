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
import { promises as fs } from "fs";
import path from "path";

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
	// Output redirection (>, >>, with optional leading fd like 2>) that
	// targets a real file. Skip /dev/null and fd-dups like 2>&1.
	/(?:^|\s)\d?>{1,2}\s*(?!&|\/dev\/null\b)\S/,
	// In-place tee writing to a real file.
	/\btee\b\s+(?!-)\S/,
];

function isDestructiveBash(cmd: string): boolean {
	return DESTRUCTIVE_BASH.some((re) => re.test(cmd));
}

/**
 * Enhanced "Yes, but..." functionality that writes the user's feedback
 * and the proposed changes to a temporary file, making it easier for
 * the model to incorporate the feedback directly.
 */
async function handleYesButWithContext(
	toolName: string,
	path: string,
	edits: unknown[],
	userFeedback: string,
	ctx: any
): Promise<{ block: true; reason: string }> {
	// Create a temporary file with the changes and feedback
	const tempDir = path.join(process.cwd(), ".pi-changes");
	const tempFile = path.join(tempDir, `yesbut_${Date.now()}.txt`);
	
	try {
		// Ensure directory exists
		await fs.mkdir(tempDir, { recursive: true });
		
		// Write detailed context for the model
		const contextContent = `
📝 YES-BUT FEEDBACK CONTEXT
========================================

User Feedback:
${userFeedback}

Proposed Changes:
- Tool: ${toolName}
- File: ${path}
- Edits: ${edits.length} change(s)

Detailed Edits:
${JSON.stringify(edits, null, 2)}

========================================
To incorporate this feedback:
1. Review the user's feedback above
2. Modify the proposed changes accordingly
3. Provide the corrected implementation
`;
		
		await fs.writeFile(tempFile, contextContent, "utf-8");
		
		const relativePath = path.relative(process.cwd(), tempFile);
		
		return {
			block: true,
			reason: `User approved in principle but added guidance — please incorporate and retry: ${userFeedback}. \n\n📄 Detailed context written to: ${relativePath}. Use \\read ${relativePath} to review the full context.`
		};
	} catch (error) {
		return {
			block: true,
			reason: `User approved in principle but added guidance — please incorporate and retry: ${userFeedback}. \n\n⚠️  Could not write context file: ${error}`
		};
	}
}

export default function (pi: ExtensionAPI) {
	// Register command to list yes-but context files
	pi.registerCommand({
		name: "list-yesbut",
		description: "List yes-but context files",
		usage: "list-yesbut",
		async handler(args, ctx) {
			const tempDir = path.join(process.cwd(), ".pi-changes");
			try {
				const files = await fs.readdir(tempDir);
				const yesbutFiles = files.filter(f => f.startsWith("yesbut_") && f.endsWith(".txt"));
				
				if (yesbutFiles.length === 0) {
					return "No yes-but context files found.";
				}
				
				const fileList = yesbutFiles.map(f => `- ${f}`).join("\n");
				return `📋 Yes-But Context Files:\n\n${fileList}\n\nUse \\read-yesbut <file> to view a file.`;
			} catch (error) {
				return "No yes-but context files found.";
			}
		}
	});

	// Register command to read yes-but context files
	pi.registerCommand({
		name: "read-yesbut",
		description: "Read a yes-but context file",
		usage: "read-yesbut <file>",
		async handler(args, ctx) {
			if (!args[0]) {
				return "Usage: \\read-yesbut <file>";
			}
			
			const filePath = path.join(process.cwd(), ".pi-changes", args[0]);
			try {
				const content = await fs.readFile(filePath, "utf-8");
				return `📄 Yes-But Context: ${args[0]}\n\n${content}`;
			} catch (error) {
				return `❌ Could not read file ${args[0]}: ${error}`;
			}
		}
	});
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
			
			if (!trimmed) {
				return { block: true, reason: "Blocked by user (no note provided)" };
			}
			
			// Enhanced handling for file operations
			if ((toolName === "write" || toolName === "edit") && path) {
				const edits = toolName === "edit" ? (event.input.edits as unknown[]) : [];
				return handleYesButWithContext(toolName, path, edits, trimmed, ctx);
			}
			
			// For other tools, use the original format
			return {
				block: true,
				reason: `User approved in principle but added guidance — please incorporate and retry: ${trimmed}`
			};
		}

		return { block: true, reason: "Blocked by user" };
	});
}

/**
 * Side-by-Side Diff Extension
 *
 * Overrides the built-in edit tool renderer to show
 * side-by-side diffs inline instead of the default unified diff.
 * Both sides get full syntax highlighting via highlightCode.
 */

import { createEditToolDefinition, type ExtensionAPI, highlightCode, getLanguageFromPath } from "@mariozechner/pi-coding-agent";
import { Container, Spacer, Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

/**
 * Parse a diff line in pi's format: "+123 content", "-123 content", " 123 content"
 */
function parseDiffLine(line: string): { prefix: string; lineNum: number | null; content: string } | null {
	const match = line.match(/^([+-\s])(\s*\d*)\s(.*)$/);
	if (!match) return null;
	const num = match[2].trim();
	return { prefix: match[1], lineNum: num ? parseInt(num, 10) : null, content: match[3] };
}

function replaceTabs(text: string): string {
	return text.replace(/\t/g, "   ");
}

function padRight(str: string, width: number): string {
	const vw = visibleWidth(str);
	if (vw >= width) return truncateToWidth(str, width);
	return str + " ".repeat(width - vw);
}

/**
 * Reconstruct old and new file lines from the diff, highlight both as
 * full files, and return maps of lineNumber → highlighted content.
 */
function buildHighlightMaps(
	diffText: string,
	lang: string | undefined,
	theme: any,
): { oldHL: Map<number, string>; newHL: Map<number, string> } {
	const oldHL = new Map<number, string>();
	const newHL = new Map<number, string>();

	if (!lang) return { oldHL, newHL };

	// Reconstruct old and new file content from the diff
	const diffLines = diffText.split("\n");
	const oldFileLines: { lineNum: number; content: string }[] = [];
	const newFileLines: { lineNum: number; content: string }[] = [];

	for (const line of diffLines) {
		const p = parseDiffLine(line);
		if (!p || p.lineNum == null) continue;

		if (p.prefix === "-") {
			oldFileLines.push({ lineNum: p.lineNum, content: p.content });
		} else if (p.prefix === "+") {
			newFileLines.push({ lineNum: p.lineNum, content: p.content });
		} else {
			// Context line appears in both files
			oldFileLines.push({ lineNum: p.lineNum, content: p.content });
			newFileLines.push({ lineNum: p.lineNum, content: p.content });
		}
	}

	// Highlight old content as a block
	if (oldFileLines.length > 0) {
		const oldCode = oldFileLines.map((l) => l.content).join("\n");
		try {
			const highlighted = highlightCode(oldCode, lang, theme);
			for (let i = 0; i < oldFileLines.length && i < highlighted.length; i++) {
				oldHL.set(oldFileLines[i].lineNum, replaceTabs(highlighted[i]));
			}
		} catch {}
	}

	// Highlight new content as a block
	if (newFileLines.length > 0) {
		const newCode = newFileLines.map((l) => l.content).join("\n");
		try {
			const highlighted = highlightCode(newCode, lang, theme);
			for (let i = 0; i < newFileLines.length && i < highlighted.length; i++) {
				newHL.set(newFileLines[i].lineNum, replaceTabs(highlighted[i]));
			}
		} catch {}
	}

	return { oldHL, newHL };
}

/**
 * Get available width for the diff, accounting for box padding.
 */
function getAvailableWidth(): number {
	// Terminal width minus padding (1 left + 1 right from the Box wrapper)
	return (process.stdout.columns || 80) - 4;
}

/**
 * Render a unified diff string as side-by-side colored text with syntax highlighting.
 */
function renderSideBySideDiff(
	diffText: string,
	theme: any,
	filePath?: string,
): string {
	const availableWidth = getAvailableWidth();
	const lang = filePath ? (getLanguageFromPath(filePath) ?? undefined) : undefined;
	const { oldHL, newHL } = buildHighlightMaps(diffText, lang, theme);

	const lines = diffText.split("\n");
	const sep = theme.fg("toolDiffContext", " │ ");
	const sepWidth = 3;
	const halfWidth = Math.floor((availableWidth - sepWidth) / 2);

	if (halfWidth < 20) {
		// Too narrow for side-by-side, fall back to unified
		return lines
			.map((line: string) => {
				const p = parseDiffLine(line);
				if (!p) return theme.fg("toolDiffContext", line);
				if (p.prefix === "-") return theme.fg("toolDiffRemoved", line);
				if (p.prefix === "+") return theme.fg("toolDiffAdded", line);
				return theme.fg("toolDiffContext", line);
			})
			.join("\n");
	}

	const result: string[] = [];

	// Header
	const leftHeader = padRight(theme.fg("toolDiffContext", " Old"), halfWidth);
	const rightHeader = padRight(theme.fg("toolDiffContext", " New"), halfWidth);
	result.push(leftHeader + sep + rightHeader);
	result.push(theme.fg("toolDiffContext", "─".repeat(halfWidth) + "─┼─" + "─".repeat(halfWidth)));

	let i = 0;
	while (i < lines.length) {
		const line = lines[i];
		const parsed = parseDiffLine(line);

		if (!parsed) {
			i++;
			continue;
		}

		if (parsed.prefix === "-") {
			// Collect consecutive removed lines
			const removedLines: { lineNum: number | null; content: string }[] = [];
			while (i < lines.length) {
				const p = parseDiffLine(lines[i]);
				if (!p || p.prefix !== "-") break;
				removedLines.push({ lineNum: p.lineNum, content: replaceTabs(p.content) });
				i++;
			}

			// Collect consecutive added lines
			const addedLines: { lineNum: number | null; content: string }[] = [];
			while (i < lines.length) {
				const p = parseDiffLine(lines[i]);
				if (!p || p.prefix !== "+") break;
				addedLines.push({ lineNum: p.lineNum, content: replaceTabs(p.content) });
				i++;
			}

			// Pair up removed/added lines
			const maxLen = Math.max(removedLines.length, addedLines.length);
			for (let j = 0; j < maxLen; j++) {
				const removed = removedLines[j];
				const added = addedLines[j];

				let left: string;
				let right: string;

				if (removed) {
					const ln = removed.lineNum != null ? String(removed.lineNum).padStart(4) : "    ";
					const hlContent = (removed.lineNum != null ? oldHL.get(removed.lineNum) : null) ?? removed.content;
					left = theme.fg("toolDiffRemoved", padRight(`-${ln} ${hlContent}`, halfWidth));
				} else {
					left = padRight("", halfWidth);
				}

				if (added) {
					const ln = added.lineNum != null ? String(added.lineNum).padStart(4) : "    ";
					const hlContent = (added.lineNum != null ? newHL.get(added.lineNum) : null) ?? added.content;
					right = theme.fg("toolDiffAdded", padRight(`+${ln} ${hlContent}`, halfWidth));
				} else {
					right = padRight("", halfWidth);
				}

				result.push(left + sep + right);
			}
		} else if (parsed.prefix === "+") {
			// Standalone added line (no preceding removal)
			const ln = parsed.lineNum != null ? String(parsed.lineNum).padStart(4) : "    ";
			const hlContent = (parsed.lineNum != null ? newHL.get(parsed.lineNum) : null) ?? replaceTabs(parsed.content);
			const left = padRight("", halfWidth);
			const right = theme.fg("toolDiffAdded", padRight(`+${ln} ${hlContent}`, halfWidth));
			result.push(left + sep + right);
			i++;
		} else {
			// Context line — syntax highlighted, shown on both sides
			const ln = parsed.lineNum != null ? String(parsed.lineNum).padStart(4) : "    ";
			const hlContent = (parsed.lineNum != null ? newHL.get(parsed.lineNum) : null) ?? replaceTabs(parsed.content);
			const content = ` ${ln} ${hlContent}`;
			const left = padRight(content, halfWidth);
			const right = padRight(content, halfWidth);
			result.push(left + sep + right);
			i++;
		}
	}

	return result.join("\n");
}

export default function (pi: ExtensionAPI) {
	const editDef = createEditToolDefinition(process.cwd());
	const origEditRenderCall = editDef.renderCall!;
	const origEditRenderResult = editDef.renderResult!;

	pi.registerTool({
		...editDef,
		renderCall(args, theme, context) {
			// Use built-in renderCall for preview computation logic
			const component = origEditRenderCall(args, theme, context);

			const callComponent = context.state.callComponent as any;
			if (callComponent?.preview && !("error" in callComponent.preview)) {
				const diffStr = callComponent.preview.diff;
				if (diffStr) {
					component.clear();

					const pathStr =
						typeof (args as any)?.path === "string"
							? (args as any).path
							: typeof (args as any)?.file_path === "string"
								? (args as any).file_path
								: "...";
					const header = `${theme.fg("toolTitle", theme.bold("edit"))} ${theme.fg("accent", pathStr)}`;
					component.addChild(new Text(header, 0, 0));
					component.addChild(new Spacer(1));

					const sideBySide = renderSideBySideDiff(diffStr, theme, pathStr);
					component.addChild(new Text(sideBySide, 0, 0));
				}
			}

			return component;
		},
		renderResult(result, options, theme, context) {
			const typedResult = result as any;
			const callComponent = context.state.callComponent as any;
			const previewDiff = callComponent?.preview && !("error" in callComponent.preview) ? callComponent.preview.diff : undefined;
			const resultDiff = !context.isError ? typedResult.details?.diff : undefined;

			if (context.isError) {
				return origEditRenderResult(result, options, theme, context);
			}

			const filePath = typeof (context.args as any)?.path === "string" ? (context.args as any).path : undefined;

			// Update call component with final side-by-side diff
			if (callComponent && resultDiff) {
				callComponent.clear();
				const pathStr = filePath ?? "...";
				const headerText = `${theme.fg("toolTitle", theme.bold("edit"))} ${theme.fg("accent", pathStr)}`;
				callComponent.addChild(new Text(headerText, 0, 0));
				callComponent.addChild(new Spacer(1));
				const sideBySide = renderSideBySideDiff(resultDiff, theme, filePath);
				callComponent.addChild(new Text(sideBySide, 0, 0));
			}

			// No separate result component needed
			const component = (context.lastComponent as Container | undefined) ?? new Container();
			component.clear();
			return component;
		},
	});
}

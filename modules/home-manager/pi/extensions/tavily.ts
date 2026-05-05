/**
 * Tavily Search - Web search via the Tavily API (https://tavily.com).
 *
 * Requires TAVILY_API_KEY in the environment.
 *
 * Registers a `tavily_search` tool. Pi's built-in `web_search` (Exa /
 * Perplexity / Gemini) keeps working alongside this; the LLM picks whichever
 * is available.
 */

import { Type } from "@mariozechner/pi-ai";
import { defineTool, type ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface TavilyResult {
	title: string;
	url: string;
	content: string;
	score?: number;
	raw_content?: string | null;
	published_date?: string;
}

interface TavilyResponse {
	answer?: string;
	query: string;
	results: TavilyResult[];
	response_time?: number;
}

const tavilySearchTool = defineTool({
	name: "tavily_search",
	label: "Tavily",
	description:
		"Search the web via Tavily. Returns ranked results with title, URL, snippet, and an optional AI-generated answer. Good for research, fact-checking, and current events. Requires TAVILY_API_KEY.",
	parameters: Type.Object({
		query: Type.String({ description: "Search query" }),
		searchDepth: Type.Optional(
			Type.Union([Type.Literal("basic"), Type.Literal("advanced")], {
				description: "basic = fast/cheap (1 credit), advanced = deeper crawl (2 credits). Default: basic.",
			}),
		),
		maxResults: Type.Optional(
			Type.Number({ description: "Number of results (1-20). Default: 5.", minimum: 1, maximum: 20 }),
		),
		includeAnswer: Type.Optional(
			Type.Boolean({ description: "Include Tavily's synthesized answer. Default: true." }),
		),
		includeRawContent: Type.Optional(
			Type.Boolean({ description: "Include full extracted page content per result. Default: false." }),
		),
		includeDomains: Type.Optional(
			Type.Array(Type.String(), { description: "Restrict to these domains." }),
		),
		excludeDomains: Type.Optional(
			Type.Array(Type.String(), { description: "Exclude these domains." }),
		),
		topic: Type.Optional(
			Type.Union([Type.Literal("general"), Type.Literal("news"), Type.Literal("finance")], {
				description: "Search category. Default: general.",
			}),
		),
		days: Type.Optional(
			Type.Number({ description: "For topic=news: only results from the last N days.", minimum: 1 }),
		),
	}),

	async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
		const apiKey = process.env.TAVILY_API_KEY;
		if (!apiKey) {
			return {
				content: [
					{
						type: "text",
						text: "TAVILY_API_KEY not set. Get a free key at https://tavily.com (1000 searches/month) and export TAVILY_API_KEY.",
					},
				],
				details: { error: "missing_api_key" },
				isError: true,
			};
		}

		const body: Record<string, unknown> = {
			query: params.query,
			search_depth: params.searchDepth ?? "basic",
			max_results: params.maxResults ?? 5,
			include_answer: params.includeAnswer ?? true,
			include_raw_content: params.includeRawContent ?? false,
			topic: params.topic ?? "general",
		};
		if (params.includeDomains?.length) body.include_domains = params.includeDomains;
		if (params.excludeDomains?.length) body.exclude_domains = params.excludeDomains;
		if (params.days != null && body.topic === "news") body.days = params.days;

		let response: Response;
		try {
			response = await fetch("https://api.tavily.com/search", {
				method: "POST",
				signal,
				headers: {
					"Content-Type": "application/json",
					Authorization: `Bearer ${apiKey}`,
				},
				body: JSON.stringify(body),
			});
		} catch (err) {
			const msg = err instanceof Error ? err.message : String(err);
			return {
				content: [{ type: "text", text: `Tavily request failed: ${msg}` }],
				details: { error: "network", message: msg },
				isError: true,
			};
		}

		if (!response.ok) {
			const text = await response.text().catch(() => "");
			return {
				content: [
					{ type: "text", text: `Tavily API error ${response.status}: ${text || response.statusText}` },
				],
				details: { error: "http", status: response.status, body: text },
				isError: true,
			};
		}

		const data = (await response.json()) as TavilyResponse;
		const lines: string[] = [];
		if (data.answer) {
			lines.push("## Answer", data.answer, "");
		}
		lines.push("## Results");
		data.results.forEach((r, i) => {
			lines.push(`### ${i + 1}. ${r.title}`);
			lines.push(r.url);
			if (r.published_date) lines.push(`_Published: ${r.published_date}_`);
			lines.push("", r.content);
			if (r.raw_content) {
				lines.push("", "<raw>", r.raw_content, "</raw>");
			}
			lines.push("");
		});

		return {
			content: [{ type: "text", text: lines.join("\n") }],
			details: {
				query: data.query,
				count: data.results.length,
				responseTime: data.response_time,
				hasAnswer: Boolean(data.answer),
			},
		};
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(tavilySearchTool);
}

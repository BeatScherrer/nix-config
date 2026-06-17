---
name: report
description: Render any report or findings into the standard MT Robot themed HTML (brand red, logo, Arial/Helvetica) so reports from every skill look identical. Use to produce a branded report file from markdown — invoked by other skills (careful-review, deep-research, …) or directly when the user asks for "a report", "themed report", "branded report", "MT Robot report".
---

# Report — MT Robot themed output

When you (or another skill) deliver a **report**, never invent your own styling.
Produce the content as plain markdown, then render it through the shared
generator below. Every report from every skill then looks identical — same font
(Arial/Helvetica), brand red (`#af111d`), logo, and layout.

## How to render

1. Write the report body as **markdown** to a file under `reports/` in the
   current project, e.g. `reports/<name>-<YYYY-MM-DD>.md`. Use only semantic
   markdown — headings, tables, lists, `> blockquotes`, `inline code`, fenced
   code, links. **No inline styles and no raw HTML** (styling is not your job).
2. Render and open it:
   ```bash
   node ~/.claude/skills/report/mt-report --title "<Report Title>" --open reports/<name>-<YYYY-MM-DD>.md
   ```
   This writes `reports/<name>-<YYYY-MM-DD>.html` — a self-contained, branded
   HTML file (CSS + logo embedded, opens offline anywhere) — and launches it.
3. Tell the user the path to the generated `.html`.

If `reports/` is not already git-ignored in the project, add it (these are
generated artifacts).

## The contract (why this exists)

All styling lives in this skill directory — `mt-robot-report.css`,
`template.html`, `mt-robot-logo.svg`. Skills supply **content only**. That
single-source-of-truth is what guarantees a consistent MT Robot look across
reports from different skills. To restyle every report (fonts, colors, logo),
edit the CSS here — never per skill.

## Conventions that get special styling (optional, free if you use them)

- A table cell whose entire content is one of `blocking` / `important` /
  `minor` / `nit` (severity) or `verified` / `likely` / `speculative`
  (confidence) is auto-rendered as a color-coded badge. Use these exact words
  in severity/confidence columns.
- Use `> blockquote` for quoted source code — it renders as a red-accented panel.
- The first-level structure that reads best: `## Scope`, `## Findings` (a table),
  detail paragraphs, `## What looks good`, `## Verdict`. Not required, but it
  keeps reports across skills familiar.

## Generator reference

```
mt-report [--title "T"] [--out file.html] [--open] [input.md]
```
- Reads markdown from `input.md` or stdin.
- Default output: the input path with a `.html` extension, or
  `reports/<slug>-<date>.html` when reading from stdin.
- `--open` launches the result via `xdg-open`.
- Output is self-contained HTML. To get a PDF, open it and use the browser's
  "Save as PDF" — the stylesheet includes print rules for a clean page.

Supported markdown: headings, **bold**, *italic*, `code`, fenced code blocks,
tables (with alignment), ordered/unordered lists, blockquotes, horizontal
rules, and links. Keep reports within this subset.

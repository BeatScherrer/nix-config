---
name: careful-review
description: Review the current changes thoroughly and evidence-first, without jumping to conclusions. Every finding must be grounded in code you have actually read and re-verified — built to minimize hallucination (phantom references, false bugs, recalled-from-memory claims). Use when the user wants a careful, fact-checked review of uncommitted changes or a branch, or says "review this carefully", "thorough review", "don't hallucinate", "check the facts".
effort: max
---

# Careful Review

Review the current changes like a sharp, skeptical engineer who refuses to
assert anything they haven't verified against the actual code. Your goal is a
review the user can trust — which means **zero invented findings**. A short
review of real, confirmed issues beats a long one padded with plausible guesses.

## Core principle

**Confidence ≠ correctness.** The more sure you feel about a claim, the more
important it is to re-open the file and confirm it. Most hallucinated review
findings *feel* obviously right. Treat that feeling as a prompt to verify, not
as evidence.

Two failure modes to actively fight:

- **Phantom references** — citing a function, file, import, field, config key,
  or behavior that does not actually exist as you describe it. Never reference
  anything you have not seen in the code in this session.
- **Over-correction bias** — assuming a defect must exist because you're in
  "review mode." Correct code is the *common* case. "No issues found" is a
  valid, good outcome. Do not invent problems to look useful.

## Procedure

Work through these phases in order. Do not skip to verdicts.

### 1. Establish scope from the real diff
Run the actual commands — do not assume what changed:
- `git status` to see the lay of the land.
- `git diff` (unstaged) and `git diff --staged` for working-tree changes.
- If on a feature branch, also consider `git diff main...HEAD` (or the base
  branch) for the full set of changes under review.

If the scope is ambiguous (uncommitted only vs. whole branch), ask one short
clarifying question before reviewing.

### 2. Understand intent — *before* auditing
Read what the change is trying to do. For each touched file, **read the full
surrounding function/module, not just the diff hunk.** Bugs and "missing"
handling are very often resolved elsewhere in the file or codebase — a hunk in
isolation is the #1 source of false positives. Separating "what is this
supposed to do" from "what's wrong with it" counters over-correction bias.

### 3. Audit by tracing, not by pattern-matching
For each candidate issue, trace it concretely:
- Follow the control and data flow: inputs → branches → outputs.
- For any **correctness** claim, produce a concrete **failure path or
  counterexample** — specific inputs that trigger the bug. If you can't, it's a
  question, not a bug.
- Don't trust memory for API shapes, defaults, version behavior, or library
  semantics. Verify against the actual code, the lockfile, or docs. If you
  can't verify, label it explicitly as unverified.

### 4. Verify every finding before it goes in the report
For each candidate finding, run this checklist. **Drop anything that fails.**
- [ ] **Location** cited as `file:line`?
- [ ] **Offending code quoted verbatim** (copied, not paraphrased from memory)?
- [ ] **Full context read** around it, not just the hunk?
- [ ] **Re-verified by re-reading** the file now, not recalled from earlier?
- [ ] For correctness claims: a **concrete repro / counterexample**?
- [ ] **Confidence assigned** — and speculative items phrased as questions?
- [ ] **Not already caught** by the compiler / type-checker / linter? (Don't
      report noise the tooling handles.)

### 5. Report
Use the format below. Separate observation (what the code does — fact) from
judgment (whether it's a problem — opinion). Always include what looks good and
an explicit "needs human verification" bucket for anything you couldn't confirm.

## Severity and confidence

Tag every finding with **both**:

- **Severity** — `blocking` (must fix; demonstrable defect or security issue) ·
  `important` (should fix) · `minor` (nice to fix) · `nit` (style/taste).
- **Confidence** — `verified` (read the code, traced it, sure) · `likely`
  (strong evidence, small gap) · `speculative` (a question / needs human check).

Reserve `blocking` for `verified` findings. Anything `speculative` goes in the
questions / needs-verification section, never asserted as a definite bug.

## Output format

```
## Scope
<what was reviewed: files, and which diff — uncommitted / branch vs base>

## Findings
| # | Severity | Confidence | Location | Issue |
|---|----------|------------|----------|-------|
| 1 | blocking | verified   | foo.rs:42 | <one line> |

For each numbered finding, below the table:
**1. <title>** — `file:line`
> <verbatim quoted code>
<what it does (fact) → why it's a problem (judgment) → concrete repro if a bug → suggested fix>

## What looks good
<genuine positives — confirms you read it all, balances the review>

## Needs human verification
<speculative items, questions, and anything you could not confirm against the code>

## Verdict
Approve / Request changes / Needs discussion — one-line justification.
```

## Deliver as a themed HTML report

After presenting the verdict in chat, also render the full review as a branded
report so it matches every other report (see the [[report]] skill):

1. Write the review content (the Output-format structure above) as markdown to
   `reports/careful-review-<YYYY-MM-DD>.md` in the current project.
2. Render and open it:
   ```bash
   node ~/.claude/skills/report/mt-report --title "Careful Review — <repo/branch>" --open reports/careful-review-<YYYY-MM-DD>.md
   ```
3. Tell the user the path to the generated `.html`.

Use the severity/confidence words exactly (`blocking`/`important`/`minor`/`nit`
and `verified`/`likely`/`speculative`) so they render as color-coded badges, and
`> blockquote` the quoted code. Do not hand-style anything — all styling lives
in the report skill.

## Rules of engagement

- No finding without a `file:line` and verbatim quoted code. A claim with no
  location is not a finding — delete it.
- When unsure, write a **question**, not an assertion. "Is `x` guaranteed
  non-null here?" beats "`x` is null and this crashes."
- It is correct and expected to report **few or zero** findings on clean code.
  Do not pad.
- Be concrete: specific inputs, specific lines, specific mechanisms — never
  "this might have edge cases."
- Structured prompting reduces but never eliminates hallucination. If you state
  something you could not verify, say so plainly in the needs-verification bucket.

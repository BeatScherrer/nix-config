---
name: write-a-prd
description: Write a Product Requirements Document (PRD) for a feature or product. Use when the user wants to "write a PRD", "create product requirements", "spec out a feature", or "document what we're building". Interviews the user to capture the what and why, then produces a structured, concise PRD saved to a markdown file.
---

# Write a PRD

Produce a sharp, decision-ready Product Requirements Document. A good PRD is
**short, opinionated, and measurable** — it captures the *what* and the *why*,
not the *how*. Resist the urge to specify implementation; that belongs in design
docs and tickets.

Work in two phases: **interview**, then **draft**. Do not skip the interview.

## Phase 1 — Interview

Before writing anything, gather context. If the user has a codebase open and the
feature touches it, explore the relevant code first so your questions are
informed, not generic.

Ask the questions below — but conversationally and in small batches (2–4 at a
time), not as one giant wall. Skip any the user has already answered. Press on
vague answers ("users will like it" is not a success metric).

1. **Problem** — What problem are we solving, and for whom? What's the pain today?
2. **Users** — Who is the primary user/persona? Any secondary users?
3. **Why now** — Why does this matter, and why now? What's the business goal?
4. **Success** — How will we know it worked? What measurable outcome moves?
5. **Scope** — What's explicitly *in*, and what's *out* (non-goals)?
6. **Constraints** — Technical, legal, timeline, or resource constraints?
7. **Dependencies** — What does this rely on or block?

If the user can't answer something, record it as an **Open Question** rather than
inventing an answer.

## Phase 2 — Draft

Write the PRD using the structure below. Keep each section tight — bullets over
paragraphs. Omit sections that genuinely don't apply rather than padding them.

```markdown
# PRD: <Feature / Product Name>

**Author:** <name> · **Status:** Draft · **Last updated:** <date>

## 1. Summary
One paragraph: what we're building and the outcome it drives.

## 2. Problem & Context
The problem, who has it, and evidence it's real. Frame as a
Job-to-be-Done: "When <situation>, I want to <motivation>, so I can <outcome>."

## 3. Goals & Non-Goals
- **Goals:** the specific outcomes this delivers.
- **Non-Goals:** what we are deliberately NOT doing (prevents scope creep).

## 4. Users & Personas
Primary and secondary users, with their relevant context and pain points.

## 5. Requirements
User stories with acceptance criteria, prioritized with MoSCoW:
- **Must have** — ships or it's not viable.
- **Should have** — important but not launch-blocking.
- **Could have** — nice to have if time allows.
- **Won't have (now)** — explicitly deferred.

Each story: "As a <user>, I want <capability> so that <benefit>." with
testable acceptance criteria.

## 6. Success Metrics
Measurable signals tied to the goals (target + how it's measured). Include a
baseline and a target. Avoid vanity metrics.

## 7. Risks & Open Questions
Known risks with mitigations, plus unresolved questions blocking decisions.

## 8. Dependencies & Assumptions
What this relies on, what we're assuming to be true.
```

## Principles

- **Concise beats complete.** A PRD nobody reads is worthless. Cut ruthlessly.
- **Measurable success.** Every goal needs a metric with a number.
- **Explicit non-goals.** Naming what's out of scope is as valuable as what's in.
- **Living document.** Note it should be updated as decisions change.
- **No implementation.** Describe behavior and outcomes, not the solution design.

## Output

Save the PRD to a markdown file. Default to `docs/prd/<feature-slug>.md` (or
`prd-<feature-slug>.md` if there's no docs directory), and tell the user the
path. After writing, offer to refine any section — PRDs improve by iteration.

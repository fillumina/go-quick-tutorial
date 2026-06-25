# Go Quick Tutorial — Editorial Principles

These apply to every document. Hold them throughout without drift.

1. **State the problem before the solution.** Every concept starts with one sentence explaining what it solves or why it exists.
2. **Avoid forward references when possible.** Prefer referencing concepts introduced in the current or previous chapters. Sometimes a forward reference is inevitable — use judgment.
3. **One concept per document, unless they naturally belong together.** Related ideas that reinforce each other can share a document. Do not cram unrelated topics together.
4. **Be complete on fundamentals, selective on advanced topics.** Basic inventories — all types, all declaration forms, all loop variants — must be exhaustive. Selectivity applies to advanced and rarely-used features, not to the basic building blocks of the language.
5. **Examples are focused and purposeful.** Multiple small examples are better than one overloaded example. Each example illustrates exactly one thing. Keep examples concise.
6. **Lead with the common case, put edge cases in asides.** Explain the main, typical behavior first. Nuances and corner cases belong in a brief aside or at the end of the explanation.
7. **No history, no trivia, no philosophy.** Not why Go was designed this way. Not how it compares to other languages. Just what it is and how it works.
8. **No workarounds presented as wisdom.** If a pattern exists to compensate for a language limitation, say so plainly or skip it.
9. **Tone is direct and practical.** No enthusiasm, no apology, no padding. But also not sterile — use natural language and concrete context.
10. **Hints are allowed when they prevent a real misunderstanding.** A hint is a short clarifying note that stops the reader from drawing a wrong conclusion. It is not an opinion, a recommendation, or a best practice.
11. **Be complete and descriptive.** Do not compress explanations to the point where important details are lost. When in doubt, include more detail rather than less.
12. **Structure for browsing, not reading.** Use clear section headings, bold for key terms and syntax, and italics for emphasis. Make the structure scannable.

---

## Style Reference

- **Go Tour** (go.dev/tour): each page covers exactly one idea, minimal prose, code immediately illustrates the point
- **W3Schools Go**: flat structure, one topic per page, definition first then syntax then minimal example

Target density: each document should be around 1000 words. Longer is acceptable when the topic requires it. If a document exceeds ~2000 words, consider splitting it into two parts.

---

## Project Status

**Phase:** Manual review of generated documents. All 30 chapters (01–30) have been generated. Review is ongoing chapter by chapter.

**Completed:** 01–30 generated, 00-index.md created.

**In progress:** Manual review and corrections.

**Pending:** Incorporating excluded items marked for addition in EXCLUDED_REVIEW.md (`internal` packages, `replace` directives, `go.work`, `fallthrough`, `t.Helper()`, `sync/atomic`, constraint interface syntax).

---

## Key Decisions

Track decisions that affect how documents are written or edited. Update this section when a decision is made.

- **context.Value excluded by design** — document 23 mentions its existence but does not cover it; it encourages misuse
- **Error handling (18) placed after control flow, not with functions** — keeps the flow: learn control structures, then learn how errors shape them
- **Range (14) separated from control flow (09)** — range semantics (copy behavior, string iteration) deserve their own focus
- **Panic/recover (11) before data structures** — establishes error model before introducing types that interact with it
- **No per-chapter generation specs** — the editorial principles and 00-index.md coverage summaries are sufficient; the agent should use judgment rather than follow a prescriptive checklist

---

## Active Concerns

Things to watch for during review and edits. Remove items that are resolved.

- Ensure consistency in how examples are formatted across chapters
- Watch for forward references that violate principle #2
- Check that excluded items from EXCLUDED_REVIEW.md marked "Add back" are incorporated where relevant

---

## Maintenance

This file is living context. Update it when:

- A chapter is reviewed and corrected — note what changed and why
- A decision is made that affects future edits
- A pattern or inconsistency is discovered across chapters
- The project phase changes (e.g., from generation to review to final polish)

See **00-index.md** for the full table of contents with per-chapter coverage summaries.

# Go Quick Tutorial

A dense, progressive reference for experienced programmers who need to acquire working Go knowledge fast. Not a tutorial. Not a book. A structured reference that respects the reader's intelligence and time.

The reader already knows how to program. They understand types, memory, concurrency, interfaces, error handling as concepts. They do not need motivation, history, or philosophy. They need to understand Go's specific choices, syntax, and idioms — and nothing else.

---

## Project Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | This file — static project definition and editorial principles |
| `00-index.md` | Reader-facing table of contents with per-chapter coverage summaries |
| `01-*.md` … `30-*.md` | Generated chapter documents |

---

## Editorial Principles

These apply to every document. Hold them throughout without drift.

1. **State the problem before the solution.** Every concept starts with one sentence explaining what it solves or why it exists.
2. **Avoid forward references when possible.** A chapter should prefer referencing concepts, syntax, and features introduced in the current or previous chapters. Do not use syntax the reader has not yet seen (e.g., `for..range`, slice notation `[]Type`, struct literals) in examples or explanations if you can avoid it. If a concept requires something not yet covered, describe it factually without code, or defer the example to the appropriate chapter. Sometimes a forward reference is inevitable — an experienced developer will not object to seeing `[]string` before slices are formally introduced. Use judgment.

**Known exceptions (listed to avoid re-proposing them at each review, not exhaustive):**

- Document 15 mentions struct tags are "read via reflection" before reflection is covered in document 27 — the reference is incidental (the reader doesn't need to understand reflection to use struct tags) and avoids a circular dependency (reflection examples naturally use struct tags).
- Document 19 (Type Definitions and Aliases) references `byte`/`rune` as aliases first introduced in document 05 without foreshadowing — the cross-reference is backward, not forward, and serves as clarification rather than a dependency.

Other forward references are acceptable when inevitable. Use judgment — an experienced developer won't object to seeing a concept before it's formally introduced.

3. **One concept per document, unless they naturally belong together.** Related ideas that reinforce each other can share a document. Do not cram unrelated topics together.
4. **Be complete on fundamentals, selective on advanced topics.** Basic inventories — all types, all declaration forms, all loop variants — must be exhaustive. Omitting `int32` or `uint16` from a type list forces the reader elsewhere for something elementary. Selectivity applies to advanced and rarely-used features, not to the basic building blocks of the language.
5. **Examples are focused and purposeful.** Multiple small examples are better than one overloaded example. Each example illustrates exactly one thing. Use descriptive variable names, but single letters are fine in short, self-explanatory functions (e.g. `func add(x, y int)`). No contrived complexity. Keep examples concise — use judgment, do not exceed what is needed to illustrate the point.
6. **Lead with the common case, put edge cases in asides.** Explain the main, typical behavior first. Nuances and corner cases belong in a brief aside or at the end of the explanation — not omitted, just de-prioritized. The goal is a smooth learning curve, not an artificially simplified language.
7. **No history, no trivia, no philosophy.** Not why Go was designed this way. Not how it compares to other languages. Just what it is and how it works.
8. **No workarounds presented as wisdom.** If a pattern exists to compensate for a language limitation, say so plainly or skip it.
9. **Tone is direct and practical.** No enthusiasm, no apology, no padding. But also not sterile — use natural language and concrete context. The goal is clarity, not clinical detachment.
10. **Hints are allowed when they prevent a real misunderstanding.** A hint is a short clarifying note that stops the reader from drawing a wrong conclusion. It is not an opinion, a recommendation, or a best practice. If a hint would read as advice rather than clarification, omit it.
11. **Be complete and descriptive.** Do not compress explanations to the point where important details are lost. Each concept should be explained thoroughly enough that the reader can use it without needing to consult another source. When in doubt, include more detail rather than less.
12. **Structure for browsing, not reading.** Use clear section headings, bold for key terms and syntax, and italics for emphasis. Make the structure scannable — a reader should be able to find what they need in seconds, not by reading linearly. Lists are good for memorization; prose is better for detailed descriptions. Use judgment to balance conciseness with exhaustiveness. Use formatting to create visual hierarchy and make the content mnemonic.

---

## Style Reference

Inspired by:

- **Go Tour** (go.dev/tour): each page covers exactly one idea, minimal prose, code immediately illustrates the point
- **W3Schools Go**: flat structure, one topic per page, definition first then syntax then minimal example

Target density: each document should be around 1000 words. Longer is acceptable when the topic requires it — do not compress explanations to the point where details are lost. If a document exceeds ~2000 words, consider splitting it into two parts.

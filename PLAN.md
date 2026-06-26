# Improvement Plan

Changes derived from Claude Code review. Organized by priority.

---

## 1. Chapter 21 — Goroutines (expand)

**Problem:** 66 lines, thinnest chapter. Goroutine leak section defers to chapter 23 without showing how. No mention of `runtime.GOMAXPROCS`.

**Changes:**

- Add a concrete goroutine leak example: a goroutine that blocks on a channel receive with no sender, showing the leak
- Show the fix inline using `select` with `ctx.Done()` — don't just defer to chapter 23
- Add a section on `runtime.GOMAXPROCS`: what it controls, default value (`runtime.NumCPU()`), and that most programs never need to change it
- Keep total length under ~2000 words per project conventions

**Target:** ~120-150 lines (roughly double current length)

---

## 2. Chapter 29 — Generics (update outdated info)

**Problem:** Line 85 says `ordered` from `golang.org/x/exp/constraints` is not part of the standard library. Since Go 1.21, `cmp.Ordered` is in stdlib.

**Changes:**

- Replace the `golang.org/x/exp/constraints` reference with `cmp.Ordered` from the standard library
- Update the "Built-in Constraints" table to include `cmp.Ordered` (Go 1.21+)
- Remove the "not part of the standard library" claim

---

## 3. Chapter 02 — Imports (relocate os.Args)

**Status:** ❌ Cancelled — `os.Args` depends on import knowledge, stays in chapter 02.

---

## 4. New Chapter — Structured Logging (slog)

**Problem:** No coverage of `log/slog` (Go 1.21+). The tutorial targets readers who will encounter real Go code where `slog` is the idiomatic logging approach.

**Changes:**

- Create a new chapter (number TBD — fits after chapter 30 or as an appendix)
- Cover: `slog.Info`/`Warn`/`Error`, key-value pairs, `slog.With` for context, `slog.Handler` for output formatting, and the difference from `log.Println`
- Keep it concise — ~500-800 words, focused on reading and using `slog` code, not implementing custom handlers

**Placement options:**
- As chapter 31 (extends the sequence)
- As an appendix (A1-structured-logging.md) alongside chapter 30

---

## 5. Cross-references (add markdown links)

**Problem:** Cross-references between chapters are prose-only ("covered in document 22"). Humans navigating on GitHub can't click through.

**Changes:**

- Globally replace prose references like "document N" or "see chapter N" with markdown links: `[document N](NN-topic.md)` or `[chapter N](NN-topic.md)`
- Scan all 30 chapters for patterns like `document \d+`, `chapter \d+`, `see \d+`

---

## Execution Order

1. ~~Chapter 29 (quick fix — one paragraph)~~ ✅ Done
2. ~~Chapter 02 → Chapter 01 (move content)~~ ❌ Cancelled — depends on import knowledge
3. ~~Chapter 21 (expand — most writing)~~ ✅ Done
4. New slog chapter (new file) — *pending, scope question*
5. Cross-references (global find-and-replace pass) — *pending, low value*

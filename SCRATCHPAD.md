# Scratchpad — Session State

Updated each session. Tracks what's done, what's next, and decisions made.

---

## Current Phase

Manual review of generated documents. All 30 chapters (01–30) have been generated. Review is ongoing chapter by chapter.

---

## Progress

- [x] All 30 chapters generated (01–30)
- [x] 00-index.md created
- [ ] Manual review and corrections (in progress)
- [ ] Incorporate excluded items marked for addition in EXCLUDED_REVIEW.md

---

## Pending Additions

Items from EXCLUDED_REVIEW.md recommended for addition:

- **01:** `internal` packages — visibility concept for `internal/` directories
- **03:** `replace` directives — practical for local dev
- **03:** `go.work` workspace mode — useful for monorepos
- **09:** `fallthrough` keyword — one-line mention
- **20:** `t.Helper()` — one-line mention
- **25:** `sync/atomic` — brief section on lock-free primitives
- **29:** constraint interface syntax — `[T interface{ ~int; Method() }]`

---

## Key Decisions

Decisions that affect how documents are written or edited:

- **context.Value excluded by design** — document 23 mentions its existence but does not cover it; it encourages misuse
- **Error handling (18) placed after control flow, not with functions** — keeps the flow: learn control structures, then learn how errors shape them
- **Range (14) separated from control flow (09)** — range semantics (copy behavior, string iteration) deserve their own focus
- **Panic/recover (11) before data structures** — establishes error model before introducing types that interact with it

---

## Active Concerns

Things to watch for during review and edits:

- Ensure consistency in how examples are formatted across chapters
- Watch for forward references that violate editorial principle #2
- Check that excluded items marked "Add back" are incorporated where relevant

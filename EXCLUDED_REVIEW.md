# Excluded Arguments — Review

Topics that were excluded from the generated documents. Each entry has a recommendation and reasoning to help decide whether to add it back.

---

## 01 — Program Structure

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| (none) | — | `internal` packages and build tags moved to 03 (Packages and Modules). |

## 02 — Imports

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| build tags | Skip | Same as above — advanced topic. |
| cgo imports (`import "C"`) | Skip | Entirely different domain (C interop). Not relevant for learning Go itself. |

## 03 — Packages and Modules

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `internal` packages | **Add back** | Important visibility concept — `internal/` directories restrict imports to siblings and ancestors. One paragraph with an example. Moved from 01. |
| build tags (`//go:build`) | **Add back** | Controls which files are compiled into a package. Brief section showing `//go:build` directive syntax. Moved from 01. |
| `replace` directives | **Add back** | Practical for local development. One example showing `replace old => ./local`. |
| `go.work` workspace mode | **Add back** | Useful for monorepo development. Brief mention with the `go work init` command. |
| module proxies | Skip | Infrastructure concern (proxy.golang.org, GOPROXY env var), not a language feature. |
| publishing modules | Skip | Distribution topic, outside the scope of learning the language. |
| major version suffixes beyond a mention | Skip | Already covered in the generated document. |

## 04 — Standard Library and Help System

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `godoc` server | Skip | Deprecated since Go 1.17, removed in Go 1.23. |

## 05 — Variables and Types

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| (none) | — | Full type inventory was intentionally included. |

## 06 — Constants

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| predeclared constants as a formal category | Skip | `true`, `false`, `nil` are self-evident. Document 30 (Gotchas) covers their shadowability. |

## 07 — Blank Identifier

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| (none) | — | Narrow topic, nothing to exclude. |

## 08 — Operators

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| operator overloading (not supported) | Skip | Stating what Go doesn't have is noise. The reader will discover this when they try. |

## 09 — Control Flow

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `fallthrough` keyword | **Add back** | Exists in the language, appears in real code (e.g., encoding packages). One-line mention that it forces execution into the next case. |
| `select` | Skip | Covered in document 22 (Channels). |
| `for..range` | Skip | Covered in document 14 (Range). |

## 10 — Functions

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| method values | Skip | Covered by the combination of pointers, closures, and receiver semantics. |
| defer cleanup patterns | Skip | Covered in document 24 (Cleanup Patterns). |

## 11 — Panic and Recover

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| using panic for control flow | Skip | Anti-pattern. Not worth teaching. |
| panic in tests | Skip | `t.Fatal` and `testing` package handle test failures. |

## 12 — Arrays and Slices

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| 2D slices | Skip | Advanced pattern, not fundamental. |
| slice tricks | Skip | Too vague, too advanced. |
| unsafe operations on slice headers | Skip | Requires `unsafe` package, covered in document 28. |

## 13 — Maps

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| map internals | Skip | Implementation detail (hash buckets, overflow chains). |
| `sync.Map` | Skip | Covered in document 25 (Sync Package). |
| ordered map patterns | Skip | Workaround pattern, not a language feature. |

## 14 — Range

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| range over channels in depth | Skip | Covered in document 22 (Channels). |

## 15 — Structs

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| promoted field conflicts | **Add back** | Ambiguous selector is a real compile error developers encounter. Added to 15-structs with example. |
| exhaustive tag reference | Skip | Tag formats are package-specific; document the concept, not every tag. |

## 16 — Pointers

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `unsafe.Pointer` | Skip | Covered in document 28 (Unsafe). |
| stack vs heap allocation | Skip | Compiler decision, not programmer-controlled. |
| escape analysis | Skip | Compiler internals. |

## 17 — Interfaces

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `reflect` | Skip | Covered in document 27 (Reflection). |

## 18 — Error Handling

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| (none) | — | Nothing excluded. |

## 19 — Type Definitions and Aliases

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| underlying type beyond a mention | Skip | Advanced concept that matters mainly for generics constraints. |
| type promotion | Skip | Related to embedding, covered in document 15. |

## 20 — Testing

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `t.Helper()` | **Add back** | Appears in real test code. One-line: marks the function as a helper so error messages point to the caller. |
| mocking strategies | Skip | Design pattern, not a language feature. |
| integration test build tags | Skip | Build tags are excluded elsewhere; advanced topic. |

## 21 — Goroutines

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `GOMAXPROCS` | Skip | Runtime tuning, not fundamental. |
| goroutine scheduling internals | Skip | Implementation detail. |
| `runtime.Gosched` | Skip | Rarely needed; the scheduler handles this automatically. |

## 22 — Channels

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| channel of channels | Skip | Advanced pattern, not fundamental. |

## 23 — Context

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `context.Value` and key-value storage | Skip | Already mentioned in the generated document as "not covered by design." |

## 24 — Cleanup Patterns

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| panic/recover | Skip | Covered in document 11. |
| named return values with defer | Skip | Niche pattern, not idiomatic. |
| defer basics | Skip | Covered in document 10. |

## 25 — Sync Package

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `sync.Pool` | Skip | Performance optimization, not fundamental. |
| `sync.Cond` | Skip | Advanced synchronization, rarely used directly. |
| `sync/atomic` | **Add back** | `atomic.Int32`, `atomic.Bool`, etc. are practical lock-free primitives. Brief section showing `atomic.AddInt32` and `atomic.Store`/`Load`. |

## 26 — Init Function

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| init order across packages beyond the basic rule | Skip | Complex and rarely needed explicitly. |
| init in test files | Skip | Niche use case. |

## 27 — Reflection

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| `reflect.MakeFunc` | Skip | Advanced, rarely used. |
| `reflect.New` | Skip | Advanced, rarely used. |
| building generic frameworks with reflection | Skip | Superseded by generics (document 29). |

## 28 — Unsafe

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| detailed pointer arithmetic patterns | Skip | Document is about recognition, not usage. |
| cgo integration details | Skip | Different domain. |

## 29 — Generics

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| constraint interface syntax | **Add back** | `[T interface{ ~int; Method() }]` appears in real code. Brief example showing a constraint with a type set and a method requirement. |
| type inference edge cases | Skip | The compiler handles this; edge cases are noise. |
| `golang.org/x/exp/constraints` | Skip | Superseded by standard library `comparable` and `any`. |

## 30 — Common Gotchas

| Excluded | Recommendation | Reason |
|----------|---------------|--------|
| version-specific behavior beyond Go 1.22 loop variable change | Skip | Moving target; the reader should check release notes. |
| cgo gotchas | Skip | Different domain. |
| race detector internals | Skip | Implementation detail. |

---

## Summary

**10 items recommended for addition:** `internal` packages, build tags, `replace` directives, `go.work` workspace mode, `fallthrough`, `t.Helper()`, `sync/atomic`, constraint interface syntax, and one each for the chapters they belong to.

**30+ items recommended to stay excluded** — either too advanced, too niche, covered elsewhere, or not a language feature.

# Go Quick Tutorial

**A 2-hour complete Go course.**

[PDF version](go-quick-tutorial.pdf)

A fast, dense tutorial for experienced developers who need to learn Go. Not a reference book — you have the docs for that. Not a beginner guide — you already know what a type, a pointer, or a closure is.

Each chapter covers exactly one concept, builds on the previous ones, and moves on. The learning curve is gentle but constant: no padding, no detours, no noise. The structure is designed for memorization — clear sections, bold syntax, focused examples — so you can scan, retain, and move forward.

**Audience:** Proficient developers who understand programming language fundamentals and need Go's specific syntax, choices, and idioms. Fast.

---

## Contents

### Foundations

| # | Topic | Covers |
|---|-------|--------|
| 01 | [Program Structure](01-program-structure.md) | Packages, entry point, exported vs unexported names, semicolons |
| 02 | [Imports](02-imports.md) | Single and grouped imports, aliases, blank and dot imports, unused import errors |
| 03 | [Packages and Modules](03-packages-and-modules.md) | `go.mod`, `go get`, `go build`, `go run`, `go install`, `go vet` |
| 04 | [Standard Library and Help](04-standard-library-and-help.md) | Navigating docs with `go doc`, `pkg.go.dev`, doc-aware comments |

### Types and Values

| # | Topic | Covers |
|---|-------|--------|
| 05 | [Variables and Types](05-variables-and-types.md) | `var`, `:=`, zero values, full numeric type inventory, explicit conversions |
| 06 | [Constants](06-constants.md) | Typed vs untyped constants, `iota`, enumerated types, bitmask flags |
| 07 | [Blank Identifier](07-blank-identifier.md) | Discarding values with `_` across assignments, ranges, imports, type assertions |
| 08 | [Operators](08-operators.md) | Arithmetic, comparison, logic, bitwise, assignment; `++` as a statement |

### Control Flow

| # | Topic | Covers |
|---|-------|--------|
| 09 | [Control Flow](09-control-flow.md) | `if`, `for` (all forms), `range`, `switch`, `break`, `continue`, `goto` |
| 10 | [Functions](10-functions.md) | Signatures, multiple returns, closures, variadic functions, `defer` |
| 11 | [Panic and Recover](11-panic-and-recover.md) | `panic()`, `recover()`, deferred recovery pattern |

### Data Structures

| # | Topic | Covers |
|---|-------|--------|
| 12 | [Arrays and Slices](12-arrays-and-slices.md) | Fixed-size arrays, slices, `make`, `append`, slicing, `len`/`cap`, nil vs empty |
| 13 | [Maps](13-maps.md) | `map[K]V`, `make`, existence checks, `delete`, random iteration order |
| 14 | [Range](14-range.md) | `for..range` over arrays, slices, maps, strings, channels; copy semantics |
| 15 | [Structs](15-structs.md) | Struct definition, methods, value vs pointer receivers, embedding, struct tags |
| 16 | [Pointers](16-pointers.md) | `*T`, `&`, dereferencing, pointer receivers, no pointer arithmetic |
| 17 | [Interfaces](17-interfaces.md) | Method sets, implicit satisfaction, type assertion, type switch, `any` |
| 18 | [Error Handling](18-error-handling.md) | `error` interface, `(result, error)` pattern, wrapping with `%w`, `errors.Is`/`As` |
| 19 | [Type Definitions and Aliases](19-type-definitions-and-aliases.md) | `type Name BaseType` vs `type Alias = BaseType`, adding methods to primitives |

### Testing

| # | Topic | Covers |
|---|-------|--------|
| 20 | [Testing](20-testing.md) | `go test`, table-driven tests, `t.Run`, benchmarks, fuzz testing |

### Concurrency

| # | Topic | Covers |
|---|-------|--------|
| 21 | [Goroutines](21-goroutines.md) | `go` keyword, runtime multiplexing, data races, `-race` flag |
| 22 | [Channels](22-channels.md) | `chan T`, buffered vs unbuffered, `close`, `range`, `select` |
| 23 | [Context](23-context.md) | Cancellation, deadlines, `WithCancel`, `WithTimeout`, `ctx.Done()` |
| 24 | [Cleanup Patterns](24-cleanup-patterns.md) | Open/check/defer pattern, `defer cancel()`, flat error handling |
| 25 | [Sync Package](25-sync-package.md) | `Mutex`, `RWMutex`, `WaitGroup`, `Once`, `sync.Map` |

### Advanced

| # | Topic | Covers |
|---|-------|--------|
| 26 | [Init Function](26-init-function.md) | Automatic initialization, execution order, typical uses |
| 27 | [Reflection](27-reflection.md) | `reflect.TypeOf`, `reflect.ValueOf`, runtime type inspection |
| 28 | [Unsafe](28-unsafe.md) | `unsafe.Pointer`, `Sizeof`, `Offsetof`, when it appears in code |
| 29 | [Generics](29-generics.md) | Type parameters, constraints, generic types, `slices`/`maps` packages |
| 30 | [Logging](30-logging.md) | `log` package, `log/slog` (Go 1.21+), structured logging, key-value attributes, `With`, handlers |
| 31 | [Common Gotchas](31-common-gotchas.md) | `time.Duration` is `int64`, `strings.Builder` not concurrency-safe, JSON unmarshals numbers as `float64`, shadowing predeclared identifiers |

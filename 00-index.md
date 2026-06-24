# Go Quick Tutorial

**A 2-hour complete Go course.**

A fast, dense tutorial for experienced developers who need to learn Go. Not a reference book — you have the docs for that. Not a beginner guide — you already know what a type, a pointer, or a closure is.

Each chapter covers exactly one concept, builds on the previous ones, and moves on. The learning curve is gentle but constant: no padding, no detours, no noise. The structure is designed for memorization — clear sections, bold syntax, focused examples — so you can scan, retain, and move forward.

**Audience:** Proficient developers who understand programming language fundamentals and need Go's specific syntax, choices, and idioms. Fast.

---

## Contents

### Foundations

| # | Topic | Covers |
|---|-------|--------|
| 01 | [Program Structure](01-program-structure.md) | Packages, entry point, exported vs unexported names, `os.Args` |
| 02 | [Imports](02-imports.md) | Single and grouped imports, aliases, blank and dot imports, unused import errors |
| 03 | [Packages and Modules](03-packages-and-modules.md) | `go.mod`, `go get`, `go build`, `go run`, `go install`, `go vet` |
| 04 | [Standard Library and Help](04-standard-library-and-help.md) | Navigating docs with `go doc`, `pkg.go.dev`, doc-aware comments |

### Types and Values

| # | Topic | Covers |
|---|-------|--------|
| 05 | [Variables and Types](05-variables-and-types.md) | `var`, `:=`, zero values, full numeric type inventory, explicit conversions |
| 06 | [Constants](06-constants.md) | Typed vs untyped constants, `iota`, enumerated types, bitmask flags |
| 07 | [Operators](07-operators.md) | Arithmetic, comparison, logic, bitwise, assignment; `++` as a statement |
| 08 | [Blank Identifier](08-blank-identifier.md) | Discarding values with `_` across assignments, ranges, imports, type assertions |

### Control Flow

| # | Topic | Covers |
|---|-------|--------|
| 09 | [Control Flow](09-control-flow.md) | `if`, `for` (all forms), `range`, `switch`, `break`, `continue`, `goto` |
| 10 | [Functions](10-functions.md) | Signatures, multiple returns, closures, variadic functions, `defer` |
| 11 | [Error Handling](11-error-handling.md) | `error` interface, `(result, error)` pattern, wrapping with `%w`, `errors.Is`/`As` |
| 12 | [Panic and Recover](12-panic-and-recover.md) | `panic()`, `recover()`, deferred recovery pattern |

### Data Structures

| # | Topic | Covers |
|---|-------|--------|
| 13 | [Arrays and Slices](13-arrays-and-slices.md) | Fixed-size arrays, slices, `make`, `append`, slicing, `len`/`cap`, nil vs empty |
| 14 | [Maps](14-maps.md) | `map[K]V`, `make`, existence checks, `delete`, random iteration order |
| 15 | [Structs](15-structs.md) | Struct definition, methods, value vs pointer receivers, embedding, struct tags |
| 16 | [Pointers](16-pointers.md) | `*T`, `&`, dereferencing, pointer receivers, no pointer arithmetic |
| 17 | [Interfaces](17-interfaces.md) | Method sets, implicit satisfaction, type assertion, type switch, `any` |
| 18 | [Type Definitions and Aliases](18-type-definitions-and-aliases.md) | `type Name BaseType` vs `type Alias = BaseType`, adding methods to primitives |

### Testing

| # | Topic | Covers |
|---|-------|--------|
| 19 | [Testing](19-testing.md) | `go test`, table-driven tests, `t.Run`, benchmarks, fuzz testing |

### Concurrency

| # | Topic | Covers |
|---|-------|--------|
| 20 | [Goroutines](20-goroutines.md) | `go` keyword, runtime multiplexing, data races, `-race` flag |
| 21 | [Channels](21-channels.md) | `chan T`, buffered vs unbuffered, `close`, `range`, `select` |
| 22 | [Context](22-context.md) | Cancellation, deadlines, `WithCancel`, `WithTimeout`, `ctx.Done()` |
| 23 | [Cleanup Patterns](23-cleanup-patterns.md) | Open/check/defer pattern, `defer cancel()`, flat error handling |
| 24 | [Sync Package](24-sync-package.md) | `Mutex`, `RWMutex`, `WaitGroup`, `Once`, `sync.Map` |

### Advanced

| # | Topic | Covers |
|---|-------|--------|
| 25 | [Init Function](25-init-function.md) | Automatic initialization, execution order, typical uses |
| 26 | [Reflection](26-reflection.md) | `reflect.TypeOf`, `reflect.ValueOf`, runtime type inspection |
| 27 | [Unsafe](27-unsafe.md) | `unsafe.Pointer`, `Sizeof`, `Offsetof`, when it appears in code |
| 28 | [Generics](28-generics.md) | Type parameters, constraints, generic types, `slices`/`maps` packages |
| 29 | [Common Gotchas](29-common-gotchas.md) | Corner cases: slice comparison, nil interfaces, `append` mutation, and more |

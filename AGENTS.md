# Go Reference Document — Generation Plan

## Purpose

A dense, progressive reference for experienced programmers who need to acquire working Go knowledge fast. Not a tutorial. Not a book. A structured reference that respects the reader's intelligence and time.

The reader already knows how to program. They understand types, memory, concurrency, interfaces, error handling as concepts. They do not need motivation, history, or philosophy. They need to understand Go's specific choices, syntax, and idioms — and nothing else.

---

## Editorial Principles

These apply to every document generated from this plan. The generating model must hold these throughout without drift.

1. **State the problem before the solution.** Every concept starts with one sentence explaining what it solves or why it exists.
2. **No forward references.** A concept may only assume knowledge of concepts introduced in earlier documents.
3. **One concept per document.** No tangents.
4. **Be complete on fundamentals, selective on advanced topics.** Basic inventories — all types, all declaration forms, all loop variants — must be exhaustive. Omitting `int32` or `uint16` from a type list forces the reader elsewhere for something elementary. Selectivity applies to advanced and rarely-used features, not to the basic building blocks of the language.
5. **Examples are focused and purposeful.** Multiple small examples are better than one overloaded example. Each example illustrates exactly one thing. Variable names must be descriptive, not single letters. No contrived complexity. Each example should be short enough to read in one glance.
6. **Omit edge cases unless they affect common usage.** If a gotcha only surfaces in unusual code, skip it.
7. **No history, no trivia, no philosophy.** Not why Go was designed this way. Not how it compares to other languages. Just what it is and how it works.
8. **No workarounds presented as wisdom.** If a pattern exists to compensate for a language limitation, say so plainly or skip it.
9. **Tone is neutral and technical.** No enthusiasm. No apology. No padding.
10. **Hints are allowed when they prevent a real misunderstanding.** A hint is a short clarifying note that stops the reader from drawing a wrong conclusion. It is not an opinion, a recommendation, or a best practice. If a hint would read as advice rather than clarification, omit it.

---

## Style Reference

Inspired by:
- **Go Tour** (go.dev/tour): each page covers exactly one idea, minimal prose, code immediately illustrates the point
- **W3Schools Go**: flat structure, one topic per page, definition first then syntax then minimal example

Target density: each document should be readable in 3–5 minutes. Longer means scope creep.

---

## Document List

Each entry includes: title, one-line scope, what to cover, what to explicitly exclude, and any Go-specific notes the generating model must handle correctly.

---

### 01 — Program Structure

**Scope:** How a Go program is organized at the file and package level.

**Cover:**
- Every Go file belongs to a package declared at the top
- `package main` with a `main()` function is the entry point for executables
- Multiple files in the same directory share a package — they are compiled together
- Exported names start with uppercase; unexported names are lowercase — this is the only visibility mechanism in Go; there are no public/private/protected keywords
- Unexported names are visible within the same package across all its files, but not outside
- `os.Args` is a `[]string` containing command-line arguments; `os.Args[0]` is the program name, `os.Args[1:]` are the user-supplied arguments

**Exclude:** build tags, internal packages

**Notes:** Visibility via capitalization is a complete departure from most languages — give it a clear example showing an exported and unexported name side by side. Mention that unexported does not mean private to a single file — the whole package can see it. A small complete program example is useful to anchor the structure. Show a minimal example of reading `os.Args` in a `main` function.

---

### 02 — Imports

**Scope:** How Go imports packages and controls naming.

**Cover:**
- `import "path/to/package"` — single import
- Grouped import block: `import ( "fmt" \n "os" )` — preferred form
- The imported name is the last path element by default: `"net/http"` is used as `http`
- Alias import: `import alias "path/to/package"` — use when names conflict or for clarity
- Blank import: `import _ "package"` — imports for side effects only (e.g. driver registration)
- Dot import: `import . "package"` — imports all exported names into the current namespace; discouraged
- Unused imports are a compile error — the compiler enforces this strictly

**Exclude:** build tags, cgo imports

**Notes:** The unused import compile error is one of the first things that surprises developers — worth a direct mention. Alias imports appear frequently in real code. Blank imports appear in database driver setup and similar patterns — the reader will encounter them. Dot imports are worth mentioning so the reader recognizes them, with a hint that they make code harder to read.

---

### 03 — Packages and Modules

**Scope:** How Go organizes code into packages, manages dependencies, and provides build tooling.

**Cover:**
- A package is a directory of `.go` files sharing the same `package` declaration
- Package naming convention: short, lowercase, no underscores, matches directory name
- A module is a collection of packages with a single `go.mod` file at the root
- `go.mod` declares the module path (used as import prefix), the minimum Go version, and dependencies
- `go get package@version` adds or updates a dependency; version is a git tag in semver format (v1.2.3)
- `go.sum` records cryptographic hashes of downloaded modules — both files must be committed
- `go mod tidy` removes unused dependencies and adds missing ones
- Standard library packages are part of Go itself — no `go get` needed, no `go.mod` entry
- Circular imports between packages are a compile error
- `go build` compiles the current package and its dependencies into a binary (for `main`) or validates (for libraries)
- `go run` compiles and executes a `main` package in one step
- `go install` builds and installs the resulting binary to `GOBIN` (default `~/go/bin`)
- `go vet` runs static analysis to detect likely bugs and suspicious constructs

**Exclude:** module proxies, replace directives, workspace mode, publishing modules, major version suffixes beyond a mention

**Notes:** Show a minimal `go.mod` file as an example. Versioning via git tags is Go's mechanism — state it factually without expanding into its limitations. A hint that `go mod tidy` is the routine maintenance command is useful. Major version suffix (`/v2`) appears in import paths for modules at v2 and above — worth one sentence so the reader recognizes it when encountered. `go run` is the fastest way to test a program; `go build` is for producing distributable binaries.

---

### 04 — Standard Library and Help System

**Scope:** What the Go standard library provides and how to navigate documentation.

**Cover:**
- The standard library is extensive and covers: I/O (`io`, `os`, `bufio`), networking (`net/http`, `net`), encoding (`encoding/json`, `encoding/xml`), string manipulation (`strings`, `strconv`, `unicode`), concurrency primitives (`sync`, `atomic`), time (`time`), file paths (`path/filepath`), testing (`testing`), formatting (`fmt`), and more
- `go doc packagename` prints documentation for a package in the terminal
- `go doc packagename.FunctionName` prints documentation for a specific symbol
- `pkg.go.dev` is the web interface for all Go documentation — standard library and third-party packages
- Reading standard library source code is practical and instructive — it is installed locally with Go

**Exclude:** godoc server, generating documentation for your own packages

**Notes:** This document is a navigation guide, not an API reference. The goal is to give the reader enough orientation to find what they need without guessing. Emphasize that `go doc` works offline and is fast — it is the first tool to reach for. List the standard library areas in a way that gives a mental map without being exhaustive. A hint that the standard library source is readable and locally available is genuinely useful — experienced programmers often find it faster than documentation.

---

### 05 — Variables and Types

**Scope:** How Go declares variables and what basic types exist.

**Cover:**
- `var name type = value` — explicit declaration
- `:=` — short declaration, type inferred, only inside functions
- Go is statically typed; types cannot change after declaration
- Zero values: every type has one (0, false, "", nil) — variables are never uninitialized
- Full numeric type inventory: `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `uintptr`, `float32`, `float64`, `complex64`, `complex128`
- `byte` is an alias for `uint8`; `rune` is an alias for `int32` representing a Unicode code point
- `bool`, `string` — string is an immutable byte sequence, conventionally UTF-8
- Type conversions are always explicit: `int(x)`, `float64(n)` — no implicit coercion

**Exclude:** nothing from the type inventory — list all types completely

**Notes:** Zero values are a real feature, not an accident — worth one sentence of emphasis. The `:=` vs `var` distinction matters practically: `var` works at package level, `:=` does not. A table is the clearest format for the numeric type inventory. `int` is the default integer type and `float64` the default floating-point — worth stating plainly. Constants and iota are covered in the next document.

---

### 06 — Constants

**Scope:** How Go declares constants, the distinction between typed and untyped constants, and how iota enables enumerated types.

**Cover:**
- `const name = value` — compile-time constant; value must be determinable at compile time
- `const name type = value` — typed constant; type is fixed and enforced at assignment
- Untyped constants carry a kind (integer, float, string, bool, rune) and adapt to context — `const Pi = 3.14159` can be assigned to any float type without explicit conversion
- Typed constants behave like typed variables at assignment — they enforce their type strictly
- Grouped `const` blocks: `const ( A = 1 \n B = 2 )`
- `iota` is a counter that resets to 0 at each `const` block and increments by 1 for each constant in the block
- Typed iota enumerations: declare a named integer type, use it as the type for iota constants — the compiler then distinguishes the enumeration type from plain integers
- Expressions with iota: `iota * 2`, `1 << iota` for bitmask flags

**Exclude:** predeclared constants as a formal category

**Notes:** The untyped/typed distinction is the most important and most misunderstood aspect of Go constants — lead with it and show both forms. The typed iota enum pattern needs a complete example: define a named type (`type Direction int`), then a const block using that type with iota — this shows why typing matters (the compiler rejects assigning a plain `int` where a `Direction` is expected). Show a bitmask example with `1 << iota` as a second pattern — it appears frequently in real code for flags.

---

### 07 — Pointers

**Scope:** How pointers work in Go.

**Cover:**
- `*T` is a pointer to a value of type T
- `&variable` takes the address of a variable
- `*pointer` dereferences — reads or writes the value at the address
- Go has no pointer arithmetic
- Passing a pointer allows a function to modify the caller's variable
- Use a pointer receiver when a method needs to mutate the struct or when the struct is large

**Exclude:** unsafe.Pointer (covered in document 27), stack vs heap allocation, escape analysis

**Notes:** Show value-passing vs pointer-passing as two side-by-side examples — this is the clearest way to make the distinction concrete. The no-pointer-arithmetic fact is a one-line hint for C developers. A hint that Go decides stack vs heap allocation automatically (the programmer does not control this) prevents confusion for C/C++ developers.

---

### 08 — Operators

**Scope:** Go's operators for arithmetic, comparison, logic, bitwise operations, and assignment.

**Cover:**
- Arithmetic: `+`, `-`, `*`, `/` (integer division truncates toward zero), `%` (remainder, sign matches dividend)
- Increment and decrement: `i++`, `i--` — statements only, not expressions; cannot use as a value
- Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=` — structs and arrays are comparable field-by-field; slices, maps, and functions are not
- Logical: `&&`, `||`, `!` — short-circuit evaluation
- Bitwise: `&` (and), `|` (or), `^` (xor), `&^` (bit clear), `<<` (left shift), `>>` (right shift)
- Assignment: `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `&^=`, `<<=`, `>>=`
- Operator precedence follows standard C-like rules; parentheses override precedence

**Exclude:** operator overloading (not supported in Go)

**Notes:** The `++` and `--` being statements rather than expressions is a frequent source of porting bugs — show that `x = i++` is a compile error. The `&^` (bit clear) operator is unique to Go — worth a brief example. The `%` operator's sign behavior (matches the dividend, not the divisor) differs from some languages — a hint here prevents a real misunderstanding.

---

### 09 — Blank Identifier

**Scope:** The underscore `_` as a special identifier that discards values.

**Cover:**
- `_` is a predeclared identifier that discards assigned values
- Used in multiple assignment: `value, _ := func()` to ignore the second return value
- Used in range loops: `for _, value := range slice` to ignore the index
- Used in imports: `import _ "package"` for side effects only
- Used in type assertions: `_, ok := value.(Type)` to check type without extracting the value
- Cannot be read from — it is a write-only variable; multiple assignments to `_` in the same scope do not conflict

**Exclude:** nothing — the concept is narrow

**Notes:** The blank identifier appears constantly in real Go code. Show a compact example of each usage pattern. A hint that `_` in the same scope always refers to the discard slot, not to a variable, prevents confusion for developers coming from languages where `_` is a conventional variable name.

---

### 10 — Control Flow

**Scope:** Conditionals, loops, and switches in Go.

**Cover:**
- `if condition { }` — no parentheses around condition; braces are mandatory
- `if init; condition { }` — init statement in if; the init variable is scoped to the if block
- `for` is the only loop construct: `for i := 0; i < n; i++ { }`, `for condition { }` (while equivalent), `for { }` (infinite)
- `for index, value := range collection { }` — iterates arrays, slices, maps, strings, channels
- `switch value { case x: }` — no fallthrough by default; cases do not fall through automatically
- `switch { case condition: }` — switch without a value works as an if-else chain
- `break`, `continue`; labeled break exits a named outer loop

**Exclude:** goto, select (covered with channels), fallthrough keyword beyond a mention

**Notes:** The `if init; condition` pattern appears constantly in real Go code for error checks — show it with its own example. Range over string yields runes (Unicode code points) not bytes — a hint here prevents a real misunderstanding. Each loop form deserves its own small example. Switch cases can match multiple values with a comma: `case "a", "b":` — worth showing.

---

### 11 — Functions

**Scope:** How functions are declared and called in Go.

**Cover:**
- `func name(param type) returnType { }` — basic signature
- Multiple return values: `func divide(a, b float64) (float64, error)` — idiomatic Go
- Named return values: declared in the signature, returned by a bare `return` — mention briefly, not encouraged for clarity
- Functions are first-class values — assignable to variables, passable as arguments
- Closures: a function literal that captures variables from its surrounding scope
- Variadic functions: `func sum(values ...int)` — `values` is a slice inside the function; call with `sum(1, 2, 3)` or `sum(slice...)`

**Exclude:** method values, defer (covered in document 23)

**Notes:** Multiple return values are central to Go's error handling — show a function returning (value, error) and a caller using both. Closures deserve their own small example showing captured variable mutation. The `...` spread syntax for calling variadic functions with a slice is a practical detail worth showing.

---

### 12 — Error Handling

**Scope:** How Go signals and handles errors.

**Cover:**
- `error` is a built-in interface with a single method: `Error() string`
- The convention: functions return `(result, error)` as the last value
- The pattern: `result, err := doSomething(); if err != nil { handle }`
- `errors.New("message")` creates a simple error
- `fmt.Errorf("context: %w", err)` wraps an error with context — `%w` enables unwrapping
- `errors.Is(err, target)` checks if an error anywhere in the chain matches a target value
- Errors are values — no exceptions, no stack unwinding

**Exclude:** custom error types with additional fields, `errors.As`, sentinel errors

**Notes:** Keep the explanation factual. The `%w` wrapping pattern is important for real code — show wrapping and `errors.Is` unwrapping as two separate examples. A hint that wrapping adds context for humans while preserving the original error for programmatic checks clarifies why both exist.

---

### 13 — Panic and Recover

**Scope:** How Go handles abnormal termination and controlled recovery from runtime failures.

**Cover:**
- `panic(value)` stops normal execution and begins unwinding the stack, running deferred functions along the way
- `recover()` inside a deferred function catches a panic and restores normal execution
- Without `recover`, a panic propagates up the call stack and terminates the program with a stack trace
- `panic()` accepts any value, conventionally a string or error
- `recover()` returns `nil` when there is no active panic; non-`nil` when it catches one
- The pattern: `defer func() { if r := recover(); r != nil { handle } }()`

**Exclude:** using panic for control flow, panic in tests beyond a mention

**Notes:** Panic is for truly unexpected conditions — not for normal error handling. The `defer` + `recover` pattern needs a complete example showing the anonymous deferred function. A hint that `recover()` only works inside a deferred function (calling it directly always returns `nil`) prevents a real misunderstanding. A hint that panics from the runtime itself (nil pointer dereference, out-of-bounds slice access) cannot be caught by `recover` in all Go versions — this is a factual limitation worth noting.

---

### 14 — Arrays and Slices

**Scope:** Go's two sequence types and how they relate.

**Cover:**
- Array: fixed size, value type — `[3]int{1, 2, 3}`. Size is part of the type; `[3]int` and `[4]int` are different types.
- Slice: variable-length view over an underlying array — `[]int{1, 2, 3}`. The everyday sequence type.
- `make([]int, length, capacity)` creates a slice with explicit sizing
- `append(slice, value)` adds elements; returns a new slice header (may point to a new array)
- Slicing: `s[1:3]` returns a slice sharing the underlying array — mutations affect the original
- `len(s)` returns element count; `cap(s)` returns the capacity of the underlying array from the slice's start
- `copy(destination, source)` copies elements between slices
- Nil slice vs empty slice: `var s []int` is nil; `s := []int{}` is not — both have length 0

**Exclude:** 2D slices, slice tricks, unsafe operations on slice headers

**Notes:** The shared-underlying-array behavior of sub-slices is a real footgun — show it explicitly with an example that demonstrates mutation propagation. `append` returning a new slice header is also a common source of confusion — a hint that the original variable must be reassigned (`s = append(s, v)`) prevents a real mistake. Arrays are rarely used directly; slices are the practical type.

---

### 15 — Maps

**Scope:** Go's built-in key-value type.

**Cover:**
- `map[KeyType]ValueType` — type syntax
- `make(map[string]int)` — creates a usable map; a nil map (var m map[string]int) panics on write
- `m[key] = value` — set
- `v, ok := m[key]` — get with existence check; without `ok`, a missing key returns the zero value silently
- `delete(m, key)` — remove a key; no error if key absent
- Iterating with `for k, v := range m` — iteration order is intentionally random on every run
- Maps are reference types — passing to a function shares the same underlying map

**Exclude:** map internals, sync.Map, ordered map patterns

**Notes:** The nil map panic is a genuine footgun — show make vs var declaration explicitly. The silent zero-value return for missing keys (without `ok`) is a source of subtle bugs — the two-value form should be shown as the standard approach. The random iteration order is by design and worth stating so readers do not write code that depends on it.

---

### 16 — Structs

**Scope:** Go's composite type for grouping named fields.

**Cover:**
- `type Name struct { Field Type }` — definition
- Initialization with named fields: `Name{Field: value}` — preferred; positional also works
- Field access: `instance.Field`
- Pointer to struct: `&Name{...}` — field access is identical: `p.Field` (Go dereferences automatically)
- Methods: `func (receiver TypeName) MethodName() ReturnType { }` — a function bound to a type
- Value receiver vs pointer receiver: pointer receiver can mutate the struct and avoids copying; use consistently across a type's methods
- Struct embedding: a type included without a field name — its fields and methods are promoted to the outer struct

**Exclude:** struct tags beyond a mention, anonymous structs beyond a mention, promoted field conflicts

**Notes:** Embedding is Go's primary composition mechanism — show a concrete example where an embedded type's method is called directly on the outer struct. Struct tags (e.g. `json:"name"`) appear in real code constantly — one sentence saying they exist and are used for serialization is enough; the reader will encounter them. The automatic pointer dereference for field access is worth a hint for C developers who expect `->`.

---

### 17 — Interfaces

**Scope:** Go's mechanism for defining behavior independent of concrete types.

**Cover:**
- An interface is a set of method signatures: `type Stringer interface { String() string }`
- Any type that implements all methods satisfies the interface — no declaration, no `implements` keyword
- The compiler verifies satisfaction at the point of assignment
- Interfaces are typically small — one or two methods is idiomatic
- The empty interface `any` (alias for `interface{}`) accepts any value — it disables type checking
- Type assertion: `value.(ConcreteType)` — extracts the concrete type; panics if the assertion is wrong
- Safe type assertion: `v, ok := value.(ConcreteType)` — ok is false instead of panicking
- Type switch: `switch v := value.(type) { case int: ... case string: ... }` — dispatch on concrete type

**Exclude:** interface embedding, nil interface vs nil pointer distinction (too subtle here), reflect

**Notes:** The implicit satisfaction model is Go's most distinctive type feature — show a type satisfying an interface without any declaration. Small interfaces are not just style; the standard library is built on them (`io.Reader`, `io.Writer`) — worth one sentence. Type assertion and type switch deserve separate examples. A hint that `any` should be a last resort is factual: once a value is `any`, the compiler cannot check how it is used.

---

### 18 — Type Definitions and Aliases

**Scope:** How Go creates named types from existing types, and how type aliases differ.

**Cover:**
- `type Name BaseType` creates a new distinct type based on an existing type
- A new type has no methods inherited from the base type — they must be defined separately
- `type Alias = BaseType` creates a type alias — completely interchangeable with the base type in all contexts
- Type definitions enable adding methods to primitive types: `type Duration int64` then `func (d Duration) String() string`
- Type aliases are used for renaming without creating a new type — useful for migration and clarity
- Two type definitions based on the same underlying type are still distinct: `type Seconds int` and `type Minutes int` cannot be assigned to each other without explicit conversion

**Exclude:** underlying type beyond a mention, type promotion

**Notes:** The distinction between a type definition (creates a new type) and a type alias (synonym) is the most important point — lead with it and show both side by side. Show a complete example of adding a method to a named type based on `int`. A hint that `byte` and `rune` are aliases (not type definitions) explains why they are interchangeable with `uint8` and `int32`.

---

### 19 — Testing

**Scope:** How Go's built-in testing works.

**Cover:**
- Test files end in `_test.go` — excluded from normal builds automatically
- Test functions: `func TestName(t *testing.T)` — must start with `Test`
- `go test ./...` runs all tests in the module
- `t.Errorf("format", args...)` marks a test failed and continues; `t.Fatalf` marks failed and stops immediately
- Table-driven tests: a slice of structs defining input and expected output, iterated with range — the dominant Go pattern
- `t.Run("caseName", func(t *testing.T) { })` creates a named sub-test for each table row
- `go test -run TestName` runs a specific test by name (supports regex)
- `go test -cover` reports test coverage
- Benchmarks: `func BenchmarkName(b *testing.B)` with `for i := 0; i < b.N; i++`

**Exclude:** t.Helper(), mocking strategies, integration test build tags, fuzz testing

**Notes:** Table-driven tests are the dominant pattern in real Go codebases — show a complete example with a small table, t.Run, and t.Errorf. The fact that no external test framework is needed is worth stating once as a practical fact, not as praise. The testing package covers what most languages need third-party libraries for.

---

### 20 — Goroutines

**Scope:** Go's lightweight concurrency primitive.

**Cover:**
- `go functionCall()` launches a goroutine — the function runs concurrently with the caller
- Goroutines are multiplexed onto OS threads by the Go runtime — not OS threads themselves
- The main goroutine exiting terminates the program immediately, regardless of running goroutines
- Goroutines are cheap — creating thousands is normal
- Data races occur when multiple goroutines access the same memory without coordination
- `go test -race` detects data races at runtime

**Exclude:** GOMAXPROCS, goroutine scheduling internals, runtime.Gosched

**Notes:** Keep this document short and factual — its purpose is to establish the mental model before channels are introduced. Show a simple goroutine launch. A hint that goroutine leaks (goroutines that block forever) accumulate silently and consume memory is worth stating — context (document 22) addresses cancellation. Mention `-race` because it is a practical tool readers will want when reviewing concurrent code.

---

### 21 — Channels

**Scope:** Go's mechanism for passing values between goroutines.

**Cover:**
- `chan T` is a channel that carries values of type T
- `make(chan int)` creates an unbuffered channel; `make(chan int, n)` creates a buffered channel
- `ch <- value` sends; `value := <-ch` receives
- Unbuffered: both send and receive block until the other side is ready — this is the synchronization mechanism
- Buffered: send blocks only when the buffer is full; receive blocks only when empty
- `close(ch)` signals no more values will be sent; subsequent receives return the zero value with ok=false
- `for v := range ch` receives until the channel is closed
- `select { case v := <-ch1: ... case ch2 <- v: ... }` waits on multiple channel operations simultaneously
- `select` with a `default` case is non-blocking — it executes default if no channel is ready

**Exclude:** channel direction types in function signatures beyond a mention, channel of channels

**Notes:** The blocking semantics of unbuffered channels — that both sides must be ready — is the core mental model. Show two goroutines synchronizing through an unbuffered channel as a concrete example. `select` deserves its own example showing timeout with `time.After`. A hint that sending on a closed channel panics (while receiving from a closed channel does not) prevents a real mistake.

---

### 22 — Context

**Scope:** How Go propagates cancellation and deadlines across function call chains.

**Cover:**
- The problem: when a chain of functions performs I/O or blocks, the caller needs a way to cancel the entire chain — context is that mechanism
- `context.Context` is an interface; it is passed as the first argument to any function that may block or do I/O
- `context.Background()` is the root context — used at the entry point of a request or program
- `context.WithCancel(parent)` returns a derived context and a cancel function; calling cancel signals all functions holding that context
- `context.WithTimeout(parent, duration)` cancels automatically after the duration elapses
- `context.WithDeadline(parent, time)` cancels at a specific absolute time
- Check `ctx.Done()` (a channel that closes on cancellation) or `ctx.Err()` inside a function to respond to cancellation
- Convention: `ctx context.Context` is always the first parameter, always named `ctx`

**Exclude:** context.Value and key-value storage — present in the API but rarely appropriate; encourages misuse

**Notes:** The problem statement is the most important part of this document — lead with it before any API. Show WithCancel and WithTimeout as separate examples, each showing the cancel/defer pattern. A hint that forgetting `defer cancel()` leaks resources is factual and important. A hint that context.Value exists but is not covered here (by design) prevents the reader from wondering what was omitted.

---

### 23 — Defer and Cleanup Patterns

**Scope:** How defer works and how it combines with error handling and context for resource cleanup.

**Cover:**
- `defer expression` schedules a call to run when the surrounding function returns, regardless of how it returns
- Deferred calls execute in LIFO order — last deferred runs first
- Arguments to a deferred function are evaluated immediately, not when the deferred call runs
- The canonical resource pattern: open, check error, defer close — in that exact order
- `defer cancel()` placed immediately after `context.WithCancel` or `context.WithTimeout`
- Early return on error is idiomatic — flat code without nesting is preferred over deeply nested error checks

**Exclude:** panic/recover, named return values with defer

**Notes:** This document consolidates patterns from functions (11), errors (12), and context (22) — it should feel like recognition, not new syntax. Show the open/check/defer pattern as a complete realistic example. A hint that defer inside a loop defers until the enclosing function returns, not the loop iteration — this is a genuine footgun that causes resource exhaustion. The argument-evaluation-at-defer-time rule also catches people — show it briefly.

---

### 24 — Sync Package

**Scope:** Go's non-channel concurrency primitives for mutual exclusion and coordination.

**Cover:**
- `sync.Mutex` — mutual exclusion lock; `Lock()` acquires, `Unlock()` releases; not reentrant
- `sync.RWMutex` — read-write lock; `RLock()`/`RUnlock()` for concurrent readers, `Lock()`/`Unlock()` for exclusive writers
- `sync.WaitGroup` — wait for a collection of goroutines to finish; `Add(n)` sets count, `Done()` decrements, `Wait()` blocks until zero
- `sync.Once` — execute a function exactly once across goroutines; `once.Do(func())`
- Use `defer mutex.Unlock()` to ensure unlock runs even if the function panics
- Channels and `sync` primitives solve different problems — channels for communication, `sync` for shared-memory coordination

**Exclude:** `sync.Pool`, `sync.Map`, `sync.Cond`, `sync/atomic` beyond a mention

**Notes:** Show Mutex, RWMutex, and WaitGroup as separate examples. The `defer Unlock()` pattern is critical — show it. A hint that a Mutex is not reentrant (calling `Lock()` twice from the same goroutine deadlocks) prevents a real mistake. A hint that `WaitGroup` methods should not be copied (pass by pointer) prevents a subtle bug.

---

### 25 — Init Function

**Scope:** How Go runs initialization code before `main()`.

**Cover:**
- `func init() { }` runs automatically before `main()`; no parameters, no return values
- Each package may have multiple `init` functions across its files; all run at startup
- Execution order: dependencies first (in import order), then the importing package
- `init` cannot be called explicitly from user code
- Typical uses: registering drivers or plugins, initializing package-level state, validating invariants at startup

**Exclude:** init order across packages beyond the basic rule, init in test files

**Notes:** Show a minimal `init` function that sets up package-level state. A hint that `init` functions make dependencies implicit and harder to trace — they should be used sparingly — is factual, not prescriptive. A hint that circular imports prevent `init` from running at all is a practical consequence of the dependency ordering rule.

---

### 26 — Reflection

**Scope:** How Go programs can inspect and manipulate values and types at runtime.

**Cover:**
- The `reflect` package provides runtime type inspection
- `reflect.TypeOf(value)` returns the dynamic type of a value as a `reflect.Type`
- `reflect.ValueOf(value)` returns a `reflect.Value` that can be inspected and manipulated
- Common use: inspecting struct fields and their tags at runtime (used by `encoding/json` and similar)
- `value.Kind()` returns the underlying kind: Struct, Slice, Map, Ptr, Int, String, etc.
- Setting a value through reflection requires a pointer: `reflect.ValueOf(&x).Elem().Set(...)`
- Reflection bypasses compile-time type checking — errors surface at runtime as panics

**Exclude:** reflect.MakeFunc, reflect.New, building generic frameworks with reflection (superseded by generics for most uses)

**Notes:** The goal of this document is recognition, not mastery. LLM-generated code sometimes uses reflection; the reader needs to understand what they are looking at. Lead with the use case (runtime type inspection for serialization) before the API. A clear hint that reflection errors panic at runtime rather than compile time is the most important safety note. A hint that generics (document 28) have replaced many historical uses of reflection is factual and useful context.

---

### 27 — Unsafe

**Scope:** What the `unsafe` package does and what its presence in code means.

**Cover:**
- `unsafe` is a built-in package that bypasses Go's type system and memory safety guarantees
- `unsafe.Pointer` converts between pointer types that would otherwise be incompatible
- `unsafe.Sizeof(x)` returns the memory size of a value in bytes
- `unsafe.Offsetof(s.Field)` returns a struct field's byte offset
- Code using `unsafe` is not protected by Go's compatibility guarantees — it may break across Go versions
- Legitimate uses are narrow: interoperating with C via cgo, implementing low-level runtime primitives, certain performance-critical data structure operations

**Exclude:** detailed pointer arithmetic patterns, cgo integration details

**Notes:** This document is about recognition and appropriate caution, not usage. The reader is reviewing code — they need to know that `unsafe` in application code is a red flag requiring scrutiny, not a normal tool. State clearly that the name is accurate: it disables the safety guarantees Go otherwise provides. Show what an unsafe pointer conversion looks like so the reader can recognize it. A hint that the standard library itself uses unsafe internally — and that this is categorically different from application code doing so — prevents the wrong conclusion that it must be acceptable if the stdlib does it.

---

### 28 — Generics

**Scope:** Go's type parameter system introduced in Go 1.18.

**Cover:**
- Type parameters allow writing functions and types that work with multiple types without losing type safety
- Function syntax: `func Map[T, U any](slice []T, transform func(T) U) []U`
- Type parameters are listed in square brackets before the function parameters
- Constraints restrict which types are allowed: `[T comparable]` allows types that support `==`; `[T int | float64]` limits to specific types
- `comparable` is a built-in constraint; `any` is the unconstrained form
- Generic types: `type Stack[T any] struct { items []T }`
- Generic methods on types are not supported — only the type definition can be generic; methods use the type's parameter
- The `slices` and `maps` packages in the standard library (Go 1.21+) provide generic utility functions

**Exclude:** constraint interface syntax in depth, type inference edge cases, golang.org/x/exp/constraints (superseded by stdlib)

**Notes:** Be direct that generic methods (methods with their own type parameters independent of the type) are not supported — this differs from most languages with generics and will surprise readers. Show a generic function and a generic type as separate examples. A hint that most application code does not need to define generics — but will use them via the standard library's slices and maps packages — sets accurate expectations.

---

## Generation Instructions for Each Document

Use the following prompt structure when generating each document with a local model:

```
You are writing one section of a Go language reference for experienced programmers.
The reader knows how to program in at least one other language.
They do not need motivation, history, or comparison to other languages.

Topic: [TITLE FROM PLAN]
Scope: [SCOPE LINE]

Rules you must follow without exception:
- Start with one sentence stating what problem this feature solves or why it exists
- Cover only what is listed under "Cover" — nothing more
- Do not mention anything listed under "Exclude"
- Use multiple small focused examples — each illustrates exactly one thing
- Each example must be short enough to read in one glance; use descriptive variable names, never single letters except conventional loop indices
- Write explanation in short dense paragraphs, not bullet points
- Hints are allowed only when they prevent a real misunderstanding — not as advice or recommendations
- Do not use phrases like "it's worth noting", "keep in mind", "importantly", "best practice"
- End when the topic is covered — no summary, no "now you know", no next steps

Additional notes for this topic: [NOTES FROM PLAN]

Write the document now.
```

Adjust the notes field per document. Review each output against the editorial principles at the top of this plan before accepting it.

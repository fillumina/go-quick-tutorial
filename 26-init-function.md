# 26 — Init Function

`func init()` runs automatically before `main()`. It has no parameters and no return values. Each package may have multiple `init` functions across its files; all run at startup.

## Basic Usage

```go
var colors = map[string]int{
    "red": 0,
    "green": 1,
    "blue": 2,
}

func init() {
    colors["yellow"] = 3
    colors["purple"] = 4
}
```

`init` runs after package-level variable initialization and before `main()`. It is used to set up state that cannot be expressed as a simple variable declaration.

## Execution Order

**Within a single file**, `init` functions run top-to-bottom in the order they appear.

**Across files in the same package**, files are processed in lexical (alphabetical) order by filename. For a package with `a.go` containing two `init` functions and `b.go` containing one, the order is: `a.go` init #1, `a.go` init #2, `b.go` init.

**Across packages**, dependencies run first, then the importing package:

```
package A imports package B
```

Execution order: B's variables, B's `init`, A's variables, A's `init`, then `main()`.

Relying on init order is fragile. If correctness depends on a specific sequence, use explicit initialization instead.

## Typical Uses

Registering drivers or plugins:

```go
func init() {
    RegisterDriver("mysql", &MySQLDriver{})
}
```

Initializing package-level state:

```go
var config Config

func init() {
    var err error
    config, err = loadDefaultConfig()
    if err != nil {
        log.Fatalf("failed to load config: %v", err)
    }
}
```

Validating invariants at startup:

```go
func init() {
    if minBufferSize > maxBufferSize {
        log.Fatalf("invalid buffer size configuration")
    }
}
```

## Limitations

`init` cannot be called explicitly from user code. It is the only function name allowed to appear multiple times — a single file may contain several `init` functions, and multiple files in the same package may each define their own. The compiler treats `init` as a special case, collecting all definitions and generating a hidden call sequence. Normal functions must have unique names within a package.

Circular imports prevent `init` from running at all — if package A imports package B and package B imports package A, the compiler rejects the code.

`init` functions make dependencies implicit and harder to trace. Use them sparingly — explicit initialization in `main()` or constructor functions is more testable and easier to reason about.

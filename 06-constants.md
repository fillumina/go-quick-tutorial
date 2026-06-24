# 06 — Constants

Constants provide compile-time values that cannot be changed. Go distinguishes between untyped constants, which adapt to context, and typed constants, which enforce a specific type.

## Declaration

```go
const Pi = 3.14159265358979323846   // untyped constant
const Pi float64 = 3.14159265358979323846   // typed constant
```

A constant's value must be determinable at compile time. Function calls, variables, and runtime expressions cannot be used.

## Untyped vs Typed Constants

Untyped constants carry a kind (integer, float, string, bool, rune) but no fixed type. They adapt to the context in which they are used:

```go
const Pi = 3.14159265358979323846

var a float32 = Pi   // 3.1415927 (float32 precision)
var b float64 = Pi   // 3.141592653589793 (float64 precision)
var c int = Pi       // 3 (truncated to integer)
```

The untyped constant retains full precision until it is assigned to a typed variable. The compiler then rounds or truncates to fit the target type. A `float32` loses precision compared to `float64`. An `int` discards the fractional part entirely.

Typed constants behave like typed variables — they enforce their type strictly:

```go
const Pi float64 = 3.14159265358979323846

var a float32 = Pi   // compile error: cannot use float64 constant as float32
var b float64 = Pi   // OK
```

The untyped form is more flexible. The typed form prevents accidental type mismatches. Use typed constants when the type matters to the API contract.

## Grouped Constants

Multiple constants are grouped in a `const` block:

```go
const (
    Monday    = 1
    Tuesday   = 2
    Wednesday = 3
)
```

Within a grouped block, lines that omit the `= expression` reuse the expression from the previous line. Lines that omit the type inherit the type from the previous line. A single block can mix multiple types — each new type declaration starts a fresh inheritance segment:

```go
const (
    a int = 1    // type: int, value: 1
    b            // type: int (inherited), expression reused, value: 1
    c string = "hello"  // new type: string, value: "hello"
    d            // type: string (inherited), expression reused, value: "hello"
    e float64 = 3.14    // new type: float64, value: 3.14
    f            // type: float64 (inherited), expression reused, value: 3.14
)
```

## Iota

`iota` is a counter that resets to 0 at each `const` declaration and increments by 1 for each constant within that declaration:

```go
const (
    Sunday    = iota  // 0
    Monday            // 1
    Tuesday           // 2
    Wednesday         // 3
    Thursday          // 4
    Friday            // 5
    Saturday          // 6
)
```

Each `const` keyword starts a new declaration. Separate declarations reset `iota` independently:

```go
const Sunday = iota   // 0 (first declaration)
const Monday = iota   // 0 (second declaration, iota resets)
```

### Typed Iota Enumerations

`type Direction int` creates a new distinct type based on `int`. It behaves like `int` for arithmetic and storage, but the compiler treats it as a separate type — a plain `int` cannot be assigned to it without an explicit conversion. Use this pattern to type-safe `iota` constants:

```go
type Direction int

const (
    North Direction = iota
    East
    South
    West
)

func turn(d Direction) {
    // only accepts Direction, not plain int
}

turn(North)   // OK
turn(0)       // compile error: cannot use int as Direction
```

### Iota Expressions

`iota` participates in expressions, incrementing normally within them:

```go
const (
    _  = iota      // 0, skipped with blank identifier
    KB = 1 << (10 * iota)  // 1024
    MB = 1 << (10 * iota)  // 1048576
    GB = 1 << (10 * iota)  // 1073741824
)
```

A common pattern for bitmask flags:

```go
const (
    Read    = 1 << iota  // 1
    Write                // 2
    Execute              // 4
)

permissions := Read | Write   // 3
```

## Untyped Predeclared Constants

Three constants are available without declaration:

```go
true    // untyped bool
false   // untyped bool
nil     // untyped nil (for pointers, slices, maps, channels, functions, interfaces)
```

These are untyped and adapt to context. `nil` is the zero value for reference types and interfaces.

# 05 — Variables and Types

Go declares variables explicitly and infers types from assigned values. Every variable has a type that cannot change after declaration, and every variable is initialized to a zero value — there is no uninitialized state.

## Variable Declaration

Three forms exist for declaring variables:

```go
var name string = "Alice"  // explicit declaration
var name = "Alice"         // type inferred from value
name := "Alice"            // short declaration, inside functions only
```

The `var` form works at package level and inside functions. The `:=` short declaration works only inside functions — it is a compile error at package level.

Multiple variables in one statement:

```go
var (
    host string = "localhost"
    port int    = 8080
)

host, port := "localhost", 8080
```

## Zero Values

Every type has a zero value. Variables are never uninitialized:

```go
var count int       // 0
var ratio float64   // 0.0
var flag bool       // false
var name string     // ""
var ptr *int        // nil
var slice []int     // nil
```

This eliminates a whole class of bugs from reading uninitialized memory. A declared variable is always usable immediately.

## Type System

Go is statically typed. Once a variable's type is set, it cannot change:

```go
var count int = 5
count = 10        // OK, same type
count = "ten"     // compile error
```

Type conversions are always explicit — there is no implicit coercion between types:

```go
var count int = 5
var ratio float64 = float64(count)  // explicit conversion

var count int = 5
ratio := float64(count)             // inferred as float64
```

## Numeric Types

Go provides a full set of integer, floating-point, and complex types. The size of `int`, `uint`, and `uintptr` depends on the architecture (32-bit or 64-bit).

| Type      | Size              | Range / Description                              |
|-----------|-------------------|--------------------------------------------------|
| `int`     | 32 or 64 bits     | Default integer type                             |
| `int8`    | 8 bits            | -128 to 127                                      |
| `int16`   | 16 bits           | -32768 to 32767                                  |
| `int32`   | 32 bits           | -2147483648 to 2147483647                        |
| `int64`   | 64 bits           | -9223372036854775808 to 9223372036854775807      |
| `uint`    | 32 or 64 bits     | Unsigned, architecture-dependent                 |
| `uint8`   | 8 bits            | 0 to 255                                         |
| `uint16`  | 16 bits           | 0 to 65535                                       |
| `uint32`  | 32 bits           | 0 to 4294967295                                  |
| `uint64`  | 64 bits           | 0 to 18446744073709551615                        |
| `uintptr` | 32 or 64 bits     | Large enough to hold a pointer bit pattern       |
| `float32` | 32 bits           | IEEE-754 single precision                        |
| `float64` | 64 bits           | Default floating-point type                      |
| `complex64` | 64 bits        | float32 real + float32 imaginary                 |
| `complex128`| 128 bits        | float64 real + float64 imaginary                 |

`int` is the default integer type. `float64` is the default floating-point type. Use the sized types (`int32`, `uint64`, etc.) when interfacing with fixed-width data formats, network protocols, or when you need guaranteed size across architectures.

`uintptr` is used with the `unsafe` package to perform pointer arithmetic. It holds the bit pattern of a pointer as an unsigned integer, but does not keep the pointed-to value alive — the garbage collector does not track `uintptr` values.

## Aliases

Two aliases appear throughout Go code:

```go
var b byte  // alias for uint8
var r rune  // alias for int32, represents a Unicode code point
```

`byte` is used when working with raw byte data. `rune` is used when iterating over Unicode text.

## Bool

```go
var active bool = true
var active bool = false
```

`bool` values are `true` and `false`. A `bool` cannot be converted from or to any other type — there is no implicit conversion from `0` to `false` or from a non-zero integer to `true`.

## String

```go
var greeting string = "Hello"
var greeting string = `Multi-line
string with "quotes"`
```

A string is an immutable sequence of bytes, conventionally UTF-8 encoded. Once created, a string cannot be modified. String concatenation creates a new string:

```go
full := firstName + " " + lastName
```

Backtick-delimited strings are raw strings — no escape processing occurs, and they can span multiple lines. They are commonly used for regular expressions and SQL queries.

Strings can be indexed to access individual bytes:

```go
s := "Hello"
first := s[0]  // 72, the byte value of 'H'
```

Indexing returns a `byte` (`uint8`), not a character. For Unicode text, use range iteration (covered in document 10), which yields runes.

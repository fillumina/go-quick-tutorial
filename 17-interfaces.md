# 16 — Interfaces

An interface defines a set of method signatures. Any type that implements all methods satisfies the interface — there is no declaration, no `implements` keyword, and no explicit relationship.

## Definition

```go
type Stringer interface {
    String() string
}
```

## Implicit Satisfaction

A type satisfies an interface by implementing its methods. The compiler verifies satisfaction at the point of assignment:

```go
type Circle struct {
    Radius float64
}

func (c Circle) String() string {
    return fmt.Sprintf("circle radius %.2f", c.Radius)
}

var s Stringer = Circle{Radius: 5}  // Circle satisfies Stringer
fmt.Println(s.String())             // circle radius 5.00
```

No declaration links `Circle` to `Stringer`. The match is purely structural.

## Small Interfaces

Interfaces are typically small — one or two methods is idiomatic. The standard library is built on small interfaces like `io.Reader` and `io.Writer`:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}
```

## Interface Embedding

One interface can include another, combining their method sets:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

A type that satisfies `ReadWriter` implements both `Read` and `Write`.

## The Empty Interface

`any` is an alias for `interface{}` — it accepts any value:

```go
var value any = 42
value = "hello"
value = Circle{Radius: 5}
```

Once a value is `any`, the compiler cannot check how it is used. Type information is available only at runtime through type assertions. Use `any` as a last resort.

## Type Assertion

Extract the concrete type from an interface value:

```go
var s Stringer = Circle{Radius: 5}
c := s.(Circle)
fmt.Println(c.Radius)  // 5
```

A wrong assertion panics. The safe form returns a boolean:

```go
c, ok := s.(Circle)
if ok {
    fmt.Println(c.Radius)
}
```

## Type Switch

Dispatch on the concrete type stored in an interface:

```go
func describe(value any) string {
    switch v := value.(type) {
    case int:
        return fmt.Sprintf("int: %d", v)
    case string:
        return fmt.Sprintf("string: %s", v)
    case Circle:
        return fmt.Sprintf("circle: %.2f", v.Radius)
    default:
        return "unknown type"
    }
}
```

The type switch variable `v` has the concrete type within each case.

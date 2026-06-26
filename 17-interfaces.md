# 17 — Interfaces

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

## Method Sets and Receiver Types

A type `T` and its pointer `*T` have different method sets. `*T` includes methods defined with both value and pointer receivers — Go automatically dereferences the pointer when calling a value-receiver method (`(*t).ValueMethod()` becomes `t.ValueMethod()`). `T` only includes methods defined with value receivers, because Go cannot automatically take the address of a non-addressable value.

This matters when satisfying interfaces. If a type mixes receiver types, only `*T` satisfies an interface requiring both:

```go
type T struct{}

func (t T) ValueMethod() {}
func (t *T) PointerMethod() {}

var i interface{ ValueMethod(); PointerMethod() }
i = &T{}  // OK — *T has both methods
i = T{}   // compile error: T does not have PointerMethod
```

The same problem appears when passing values to functions that expect an interface:

```go
func process(i interface{ ValueMethod(); PointerMethod() }) {}

var t T
process(t)   // compile error
process(&t)  // OK
```

**Fix:** pick one receiver type per struct and use it consistently across all methods. If any method needs to mutate the receiver, use pointer receivers for all methods on that type.

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
c := s.(Circle)        // c is of type Circle
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

## Nil Pointer Assigned to Interface Is Not Nil

An interface value is a two-field header: a **pointer** to the underlying data and a **type** describing it. The interface is nil only when **both** fields are nil. Assigning a nil pointer sets the type field, making the interface non-nil:

```go
var ptr *int = nil
var i interface{} = ptr
fmt.Println(i == nil)  // false — type is *int, pointer is nil
```

The same with `any` (the common alias for `interface{}`):

```go
var ptr *int = nil
var i any = ptr
fmt.Println(i == nil)  // false
```

This is a frequent source of bugs when returning errors as interfaces (remember that `error` is an interface):

```go
func f() error {
    var err *os.PathError = nil
    // ... some logic that might set err ...
    return err  // returns non-nil interface even when err is nil
}
```

Return the concrete type directly, or explicitly return `nil`:

```go
if err != nil {
    return err
}
return nil
```

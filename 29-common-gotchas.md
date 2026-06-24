# 29 — Common Gotchas

Corner cases and subtle behaviors that trip up experienced developers. Each entry describes the behavior, why it happens, and a minimal example.

## Time.Duration Is Just Int64

`time.Duration` is `int64` nanoseconds. Arithmetic works, but the type prevents mixing with plain integers:

```go
d := 5 * time.Second
n := int64(d)  // 5000000000, explicit conversion needed
```

## Strings.Builder and Bytes.Buffer Are Not Concurrency-Safe

Do not share `strings.Builder` or `bytes.Buffer` across goroutines:

```go
var buf strings.Builder
go func() { buf.WriteString("a") }()  // data race
go func() { buf.WriteString("b") }()  // data race
```

## Append Can Mutate Another Slice's Backing Array

If the destination has spare capacity, `append` writes into the shared underlying array:

```go
original := []int{1, 2, 3, 4, 5}
sub := original[:2]          // [1 2], capacity 5
sub = append(sub, 99)        // [1 2 99]
fmt.Println(original)        // [1 2 99 4 5], original is modified
```

## Slices Cannot Be Compared With ==

```go
a := []int{1, 2}
b := []int{1, 2}
a == b  // compile error

import "slices"
slices.Equal(a, b)  // true
```

## Sending on a Nil Channel Blocks Forever

```go
var ch chan int
ch <- 1    // blocks forever, does not panic
<-ch       // also blocks forever
```

## Mixing Pointer and Value Receivers Breaks Interface Satisfaction

```go
func (t T) ValueMethod() {}
func (t *T) PointerMethod() {}

var i interface{ ValueMethod(); PointerMethod() }
i = &T{}  // OK, *T satisfies both
i = T{}   // compile error: T does not have PointerMethod
```

## String and []byte Conversion Always Allocates

```go
s := "hello"
b := []byte(s)    // allocates a copy
s2 := string(b)   // allocates a copy
```

There is no zero-copy conversion between strings and byte slices.

## JSON Unmarshaling Numbers as Float64

```go
var data any
json.Unmarshal([]byte(`{"count": 10000000000}`), &data)
// data["count"] is float64, large integers lose precision
```

Use `json.Decoder.UseNumber()` or a typed target struct.

## For Range Creates Copies

```go
numbers := []int{1, 2, 3}
for _, n := range numbers {
    n = n * 2  // modifies the copy, not the slice
}
fmt.Println(numbers)  // [1 2 3], unchanged
```

Mutate via index instead:

```go
for i := range numbers {
    numbers[i] = numbers[i] * 2
}
```

## Struct With Uncomparable Field Cannot Be Map Key

```go
type Config struct {
    Tags []string  // slice is not comparable
}
m := map[Config]string{}  // compile error
```

## Predeclared Identifiers Can Be Shadowed

`true`, `false`, `nil`, and all predeclared types and functions can be shadowed by local declarations:

```go
func check() bool {
    true := false  // legal but flagged by go vet
    return true    // returns false
}

func check() bool {
    int := 5       // legal, not flagged by go vet
    return true
}
```

`go vet` flags shadowing of `true`, `false`, and `nil`. Shadowing the rest is not flagged.

## Nil Pointer Assigned to Interface Is Not Nil

```go
var ptr *int = nil
var i interface{} = ptr
fmt.Println(i == nil)  // false — the interface holds a type (*int) and a nil value
```

The interface value is non-nil because it carries type information. This is a frequent source of bugs when returning errors as interfaces:

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

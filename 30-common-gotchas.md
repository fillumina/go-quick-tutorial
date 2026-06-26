# 30 — Common Gotchas

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

A type `T` and its pointer `*T` have different method sets. `*T` can call **both** pointer-receiver and value-receiver methods — Go automatically dereferences the pointer when calling a value-receiver method (`(*t).ValueMethod()` becomes `t.ValueMethod()`). The reverse is not true: `T` cannot call pointer-receiver methods, because Go cannot automatically take the address of a non-addressable value. Pointer receivers also allow the method to modify the original value, which value receivers cannot do.

When you define methods on the same type using a mix of value and pointer receivers, only `*T` can satisfy an interface that requires both.

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

## String and []byte Conversion Always Allocates

```go
s := "hello"
b := []byte(s)    // allocates a copy
s2 := string(b)   // allocates a copy
```

There is no zero-copy conversion between strings and byte slices.

## JSON Unmarshaling Numbers as Float64

When unmarshaling JSON into an `any` (or `map[string]any`), the `encoding/json` package has no type information to guide it. It decodes **all** JSON numbers as `float64`, regardless of whether they look like integers:

```go
var data any
json.Unmarshal([]byte(`{"count": 10000000000}`), &data)
m := data.(map[string]any)
fmt.Printf("%T\n", m["count"])  // float64, not int
```

`float64` cannot precisely represent integers larger than $2^{53}
$. Values like IDs, timestamps, or large counters silently lose precision:

```go
m["count"].(float64)  // 10000000000 may not equal the original
```

**Two fixes:**

Use a typed struct so the decoder knows the target type:

```go
type Payload struct {
    Count int64 `json:"count"`
}
var p Payload
json.Unmarshal([]byte(`{"count": 10000000000}`), &p)
// p.Count is int64, exact value preserved
```

Or use `json.Decoder.UseNumber()` to decode numbers as `json.Number` (a string-backed type) instead of `float64`:

```go
dec := json.NewDecoder(bytes.NewReader(jsonBytes))
dec.UseNumber()
var data any
dec.Decode(&data)
m := data.(map[string]any)
count, _ := m["count"].(json.Number).Int64()
```

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

All predeclared identifiers can be shadowed by local declarations. Go does not treat them as reserved keywords — they are ordinary identifiers that happen to be in scope by default.

**Predeclared types (20):**

`string`, `bool`, `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `uintptr`, `byte`, `rune`, `float32`, `float64`, `complex64`, `complex128`, `error`, `any`

**Predeclared constants (3):**

`true`, `false`, `nil`

**Predeclared functions (16):**

`append`, `cap`, `close`, `complex`, `copy`, `delete`, `imag`, `len`, `make`, `new`, `panic`, `print`, `println`, `real`, `recover`

Any of these can be shadowed:

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

## Iota Increments Every Line, Even When Unused

`iota` is a per-line counter within a `const` block. It increments regardless of whether it is used:

```go
const (
    A = iota   // 0
    B = iota   // 1
    C = 999    // 999 (iota is 2 here, unused)
    D = iota   // 3, not 2
)
```

## Breaking an Iota Chain With a Different Type

When a line in a `const` block omits `= expression`, it reuses the type and expression from the previous line. If the previous line has a different type, `iota` produces a compile error:

```go
const (
    A = iota     // 0
    B = iota     // 1
    C = "hello"  // untyped string
    D = iota     // compile error: cannot use untyped int 3 as string
)
```

`D` inherits `C`'s type (string) but `iota` produces an untyped int. Writing `= iota` explicitly on every line avoids this.

# 13 — Maps

A map is Go's built-in key-value type. Keys must be comparable (support `==`) — see the Comparable Keys section below. Values can be any type.

## Declaration and Creation

```go
var scores map[string]int    // nil map
scores = make(map[string]int) // usable map
```

A nil map cannot be written to — it panics. It does read, returning the zero value for any key:

```go
var m map[string]int
fmt.Println(m["key"])  // 0, does not panic
m["key"] = 1           // panic: assignment to entry in nil map
```

Initialize with literals:

```go
scores := map[string]int{
    "Alice": 95,
    "Bob":   87,
}
```

## Setting and Getting

```go
scores["Alice"] = 95

value := scores["Alice"]       // 95
value := scores["Missing"]     // 0, silent zero value
```

The two-value form checks for key existence:

```go
value, ok := scores["Alice"]
if ok {
    fmt.Printf("Alice scored %d\n", value)
} else {
    fmt.Println("Alice not found")
}
```

Without the `ok` check, a missing key returns the zero value silently — a source of subtle bugs. The two-value form is the standard approach.

## Deleting

```go
delete(scores, "Bob")
```

`delete` removes the key. It does nothing if the key is absent — no error, no panic.

## Iteration

```go
for name, score := range scores {
    fmt.Printf("%s: %d\n", name, score)
}
```

Iteration order is intentionally random on every run. Do not write code that depends on map iteration order.

## Maps Are Reference Types

Passing a map to a function shares the same underlying map:

```go
func updateScores(m map[string]int) {
    m["Charlie"] = 92
}

scores := map[string]int{"Alice": 95}
updateScores(scores)
fmt.Println(scores)  // map[Alice:95 Charlie:92]
```

Reassigning the map variable inside the function does not affect the caller:

```go
func replaceScores(m map[string]int) {
    m = map[string]int{"New": 100}  // only changes the local variable
}
```

## Comparable Keys

Map keys must be **comparable** — a compile-time type property meaning the type supports `==` and `!=`. This is not a runtime check; the compiler rejects a map declaration if the key type is not comparable.

### Primitive Comparable Types

These built-in types are comparable:

- Integers: `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `uintptr`
- Floats: `float32`, `float64`
- Strings
- Booleans
- Pointers (of any type)
- `complex64`, `complex128`

### Composite Comparable Types

Structs and arrays are comparable **recursively** — the type is comparable only if every component is comparable:

```go
type Config struct {
    Host string
    Port int
}

// OK — all fields are comparable
m := map[Config]bool{
    {Host: "localhost", Port: 8080}: true,
}
```

An array is comparable if its element type is comparable:

```go
// OK — [3]int is comparable because int is comparable
m := map[[3]int]string{
    {1, 2, 3}: "triple",
}
```

Nested structs follow the same rule — every field at every level must be comparable:

```go
type Address struct {
    Street string
    City   string
}

type Person struct {
    Name    string
    Address Address  // OK — Address is comparable (all fields are strings)
}

// OK — Person is comparable
m := map[Person]int{}
```

### Non-Comparable Types

Slices, maps, and functions are **never** comparable. They are reference types — two variables may point to different underlying data with the same contents, and there is no defined semantics for value equality:

```go
map[[]int]string{}    // compile error: []int is not comparable
map[map[int]string]string{} // compile error: map[int]string is not comparable
map[func()]string{}   // compile error: func() is not comparable
```

### Recursive Non-Comparability

A struct containing any non-comparable field is itself non-comparable, even if all other fields are comparable:

```go
type BadKey struct {
    ID   int
    Tags []string  // slice makes the entire struct non-comparable
}

map[BadKey]int{}  // compile error: BadKey is not comparable
```

This rule applies at any nesting depth. A struct that contains another struct that contains a slice is also non-comparable.

### Workaround: Use a Comparable Surrogate

When you need to index by a struct with non-comparable fields, derive a comparable key:

```go
type Item struct {
    ID   int
    Tags []string
}

// Use the ID as the map key instead
items := map[int]*Item{}
items[item.ID] = &item
```

Or use a string representation of the fields you need to match on.

# 13 — Maps

A map is Go's built-in key-value type. Keys must be comparable (support `==`). Values can be any type.

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

Map keys must support `==`. Valid key types include:

- Integers: `int`, `int64`, `uint`, etc.
- Floats: `float32`, `float64`
- Strings
- Booleans
- Pointers
- Arrays
- Structs (if all fields are comparable)

Invalid key types: slices, maps, functions — they do not support `==`.

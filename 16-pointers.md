# 16 — Pointers

Pointers allow functions to modify the caller's variables and avoid copying large values. Go pointers are restricted compared to C — there is no pointer arithmetic, and the runtime manages memory automatically.

## Pointer Basics

`*T` is a pointer to a value of type `T`. The `&` operator takes the address of a variable:

```go
count := 5
ptr := &count   // ptr is *int, points to count
```

Dereference with `*` to read or write the value at the address:

```go
*ptr = 10       // modifies the value count points to
fmt.Println(count)  // 10
```

A pointer variable initialized without a value is `nil`:

```go
var ptr *int    // nil
if ptr != nil {
    fmt.Println(*ptr)
}
```

Dereferencing a `nil` pointer causes a runtime panic.

## No Pointer Arithmetic

Go does not support pointer arithmetic. You cannot increment a pointer, subtract pointers, or use pointers to walk through memory:

```go
ptr++       // compile error
ptr + 1     // compile error
```

This restriction eliminates an entire class of memory safety bugs. For low-level operations, the `unsafe` package (document 27) provides limited capabilities.

## Passing by Value vs Passing by Pointer

Go passes all arguments by value. A function receives a copy of the argument:

```go
func increment(x int) {
    x++   // modifies the copy, not the original
}

count := 5
increment(count)
fmt.Println(count)  // 5, unchanged
```

Passing a pointer allows the function to modify the caller's variable:

```go
func increment(x *int) {
    *x++   // modifies the value at the address
}

count := 5
increment(&count)
fmt.Println(count)  // 6
```

Use value passing when the function does not need to modify the argument. Use pointer passing when modification is needed or when copying the value is expensive (e.g., large structs).

## Pointer Receivers

A method with a pointer receiver can mutate the struct and avoids copying it:

```go
type Counter struct {
    count int
}

func (c *Counter) Increment() {
    c.count++
}

counter := Counter{count: 0}
counter.Increment()   // Go automatically takes address: &counter.Increment()
```

Go handles the address-taking automatically when calling a pointer method on a value. The reverse is also true — calling a value method on a pointer automatically dereferences:

```go
func (c Counter) Value() int {
    return c.count
}

ptr := &Counter{count: 5}
fmt.Println(ptr.Value())  // 5, Go automatically dereferences
```

## Pointers with Structs, Slices, and Maps

### Structs

Structs are value types — assigning or passing a struct copies all fields. Use `&` to get a pointer to a struct:

```go
type Person struct {
    Name string
    Age  int
}

p := &Person{Name: "Alice", Age: 30}
fmt.Println(p.Name)  // Alice
```

Field access syntax is identical for values and pointers. Go automatically dereferences the pointer — there is no `->` operator.

### Slices and Maps

Slices and maps are reference types. They carry an internal pointer to their underlying data. Assigning or passing a slice or map shares that underlying data — no explicit pointer is needed:

```go
original := []int{1, 2, 3}
copy := original
copy[0] = 99
fmt.Println(original[0])  // 99 — shared underlying array
```

The same applies to maps:

```go
m := map[string]int{"a": 1}
n := m
n["a"] = 99
fmt.Println(m["a"])  // 99 — shared underlying map
```

Because they are already reference types, taking a pointer to a slice or map (`*[]int`, `*map[string]int`) is rare. It is only needed when you need to reassign the variable itself (e.g., setting it to `nil` or replacing it with a different slice/map) from within a function.

## Memory Allocation

Go decides automatically whether a variable lives on the stack or the heap. The programmer does not control this decision. There is no `new` operator equivalent to C's `malloc` — the `new` built-in allocates zeroed memory and returns a pointer, but it is rarely used in practice:

```go
ptr := new(int)   // allocates zeroed int, returns *int
*ptr = 10
```

Prefer composite literals with `&` over `new`:

```go
ptr := &Counter{count: 0}   // clearer intent
```

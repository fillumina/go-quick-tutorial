# 28 — Generics

Type parameters allow writing functions and types that work with multiple types without losing type safety. Go added generics in version 1.18.

## Generic Functions

Type parameters are listed in square brackets before the function parameters:

```go
func First[T any](slice []T) T {
    if len(slice) == 0 {
        return *new(T)  // zero value of T
    }
    return slice[0]
}

First([]int{1, 2, 3})           // 1
First([]string{"a", "b", "c"})  // "a"
```

`any` is the unconstrained form — it accepts any type.

## Constraints

Constraints restrict which types are allowed:

```go
func Minimum[T int | float64](a, b T) T {
    if a < b {
        return a
    }
    return b
}

Minimum(3, 5)        // 3
Minimum(1.5, 2.5)    // 1.5
Minimum("a", "b")    // compile error: string not allowed
```

`comparable` is a built-in constraint that allows types that support `==` and `!=`:

```go
func Contains[T comparable](slice []T, target T) bool {
    for _, v := range slice {
        if v == target {
            return true
        }
    }
    return false
}
```

## Generic Types

```go
type Stack[T any] struct {
    items []T
}

func (s *Stack[T]) Push(item T) {
    s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T
        return zero, false
    }
    item := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return item, true
}

stack := &Stack[int]{}
stack.Push(1)
stack.Push(2)
stack.Pop()  // 2, true
```

Methods on generic types use the type's parameter. Generic methods — methods with their own type parameters independent of the type — are not supported in Go.

## Standard Library Generics

The `slices` and `maps` packages (Go 1.21+) provide generic utility functions:

```go
import "slices"

slices.Sort([]int{3, 1, 2})
slices.Contains([]string{"a", "b"}, "b")  // true
slices.ContainsFunc([]int{1, 2, 3}, func(n int) bool { return n > 2 })  // true

import "maps"

maps.Clone(map[string]int{"a": 1, "b": 2})
maps.Equal(map[string]int{"a": 1}, map[string]int{"a": 1})  // true
```

Most application code does not need to define generics — it uses them via the standard library. Defining custom generics is appropriate when the same logic applies to multiple types and type safety matters.

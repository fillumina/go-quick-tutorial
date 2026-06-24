# 09 — Blank Identifier

The underscore `_` is a predeclared identifier that discards values. It is a write-only variable — you can assign to it but cannot read from it.

## Discarding Return Values

Functions that return multiple values often require the caller to handle all of them. The blank identifier discards unwanted returns:

```go
result, err := strconv.Atoi("42")
// use result, handle err

result, _ = strconv.Atoi("not-a-number")
// result is 0, error is discarded
```

## Discarding Loop Index

`for range` returns both an index and a value. Use `_` to ignore the index:

```go
names := []string{"Alice", "Bob", "Carol"}
for _, name := range names {
    fmt.Println(name)
}
```

Conversely, to ignore the value:

```go
for i, _ := range names {
    fmt.Println(i)  // 0, 1, 2
}
```

## Blank Imports

An import with `_` imports a package for its side effects only (typically its `init` function), without using any of its exported names:

```go
import _ "database/sql/driver"
```

This pattern is used for driver registration — the package's `init` function registers itself with a framework, and the importing code never calls the package directly.

## Type Assertions

When checking a type without extracting the value, discard the extracted value with `_`:

```go
var value interface{} = "hello"
_, ok := value.(int)
if !ok {
    fmt.Println("not an int")
}
```

## Multiple Assignments

Multiple assignments to `_` in the same scope do not conflict — `_` always refers to the same discard slot:

```go
_, _ = func1()
_, _ = func2()   // no conflict, both discard to the same slot
```

This differs from languages where `_` is a conventional variable name. In Go, `_` is a language-level discard mechanism, not a variable.

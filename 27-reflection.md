# 27 — Reflection

The `reflect` package provides runtime type inspection. It is used to examine struct fields and their tags, determine types at runtime, and manipulate values dynamically.

## TypeOf and ValueOf

```go
import "reflect"

name := "Alice"
t := reflect.TypeOf(name)    // reflect.Type
v := reflect.ValueOf(name)   // reflect.Value

fmt.Println(t.Kind())  // string
fmt.Println(v.String()) // Alice
```

`TypeOf` returns the dynamic type. `ValueOf` returns a wrapper that can be inspected and manipulated.

## Kind

`value.Kind()` returns the underlying kind: `Struct`, `Slice`, `Map`, `Ptr`, `Int`, `String`, etc. Kind is the base category, not the specific type — both `int` and `int64` have kind `Int`:

```go
type Duration int64
d := Duration(500)
v := reflect.ValueOf(d)
fmt.Println(v.Kind())  // Int (not Duration)
```

## Inspecting Structs

The most common use of reflection — inspecting struct fields and their tags:

```go
type User struct {
    Name  string `json:"name"`
    Age   int    `json:"age,omitempty"`
    Email string `json:"email"`
}

u := User{Name: "Alice", Age: 30, Email: "alice@example.com"}
t := reflect.TypeOf(u)
v := reflect.ValueOf(u)

for i := 0; i < t.NumField(); i++ {
    field := t.Field(i)
    value := v.Field(i)
    tag := field.Tag.Get("json")
    fmt.Printf("%s: %v (json: %s)\n", field.Name, value.Interface(), tag)
}
// Name: Alice (json: name)
// Age: 30 (json: age,omitempty)
// Email: alice@example.com (json: email)
```

This is how `encoding/json` and similar packages work — they read struct tags to control serialization.

## Setting Values

Setting a value through reflection requires a pointer:

```go
count := 5
v := reflect.ValueOf(&count).Elem()
v.SetInt(10)
fmt.Println(count)  // 10
```

`ValueOf(&count)` returns a `reflect.Value` holding a pointer. `Elem()` dereferences it to get the underlying value. `SetInt` modifies the actual variable.

Calling `SetInt` on a non-addressable value (one obtained from `ValueOf(x)` without taking the address) panics.

## Safety

Reflection bypasses compile-time type checking. Errors surface at runtime as panics:

```go
v := reflect.ValueOf("hello")
v.SetInt(42)  // panic: reflect: reflect.SetInt of string
```

Generics (document 28) have replaced many historical uses of reflection. Modern Go code uses reflection primarily for serialization frameworks and frameworks that need to inspect struct tags.

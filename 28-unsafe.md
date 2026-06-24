# 28 — Unsafe

The `unsafe` package bypasses Go's type system and memory safety guarantees. Its presence in application code is a red flag requiring scrutiny.

## What Unsafe Provides

```go
import "unsafe"
```

`unsafe.Pointer` converts between pointer types that would otherwise be incompatible:

```go
var i int = 42
p := (*byte)(unsafe.Pointer(&i))
fmt.Println(*p)  // first byte of the int's memory representation
```

`unsafe.Sizeof(x)` returns the memory size of a value in bytes:

```go
unsafe.Sizeof(int64(0))   // 8
unsafe.Sizeof(true)       // 1
```

`unsafe.Offsetof(s.Field)` returns a struct field's byte offset:

```go
type Point struct {
    X int
    Y int
}
unsafe.Offsetof(Point{}.X)  // 0
unsafe.Offsetof(Point{}.Y)  // 8 (on 64-bit)
```

## Consequences

Code using `unsafe` is not protected by Go's compatibility guarantees. It may break across Go versions, architectures, or compiler updates. The garbage collector does not track `unsafe.Pointer` values — a pointer obtained through `unsafe` does not keep its target alive.

## Legitimate Uses

Legitimate uses are narrow:

- Interoperating with C via cgo
- Implementing low-level runtime primitives
- Certain performance-critical data structure operations

The standard library uses `unsafe` internally for these purposes. This is categorically different from application code using it — the standard library is written by the same team that controls the runtime and can verify safety manually.

## Recognition

When reviewing code, `unsafe` in application logic warrants a careful review of what it is doing and why a safe alternative is not sufficient. Most uses of `unsafe` can be replaced with typed code, reflection, or a redesign.

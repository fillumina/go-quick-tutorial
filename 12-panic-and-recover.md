# 13 — Panic and Recover

Panic stops normal execution and begins unwinding the stack. Recover catches a panic inside a deferred function and restores normal execution. These are for truly unexpected conditions, not for normal error handling.

## Panic

`panic(value)` halts the current function, runs deferred calls, then unwinds to the caller, running its deferred calls, and so on up the stack:

```go
func main() {
    defer fmt.Println("cleanup runs")
    panic("something went wrong")
    fmt.Println("this never runs")
}
// Output:
// cleanup runs
// panic: something went wrong
// [stack trace]
```

`panic()` accepts any value, conventionally a string or error. Without a `recover` anywhere in the call chain, the program terminates with a stack trace.

## Recover

`recover()` inside a deferred function catches a panic and restores normal execution:

```go
func safeCall() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Printf("recovered from: %v\n", r)
        }
    }()

    panic("something went wrong")
    fmt.Println("this never runs")
}

func main() {
    safeCall()
    fmt.Println("execution continues")
}
// Output:
// recovered from: something went wrong
// execution continues
```

`recover()` returns `nil` when there is no active panic. It returns a non-`nil` value only when called inside a deferred function during an active panic. Calling `recover()` directly (not inside a deferred function) always returns `nil`.

## Typical Usage

The defer-recover pattern appears at boundary points — HTTP handlers, goroutine entry points, test runners — where a panic should not crash the entire program:

```go
func handleRequest(w http.ResponseWriter, r *http.Request) {
    defer func() {
        if r := recover(); r != nil {
            http.Error(w, "internal server error", 500)
            log.Printf("panic: %v", r)
        }
    }()

    // request handling that might panic
}
```

## Runtime Panics

Panics from the runtime itself — nil pointer dereference, out-of-bounds slice access, map write on nil map — cannot be caught by `recover` in all Go versions. This is a factual limitation. Application-level panics (explicit `panic()` calls) are reliably recoverable.

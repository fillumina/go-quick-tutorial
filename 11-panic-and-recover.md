# 11 — Panic and Recover

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

## When to Use Panic

Panic is for bugs — conditions that should be impossible if the code is correct. Not for "the world did something unexpected," but for "the code reached a state it shouldn't have." The distinction: can any caller in the chain do something useful with the failure? If yes, return an error. If no, because the condition means the code is wrong, panic.

```go
// A state machine that should never reach this state
switch s.status {
case "pending":
    handlePending(s)
case "done":
    handleDone(s)
default:
    panic(fmt.Sprintf("unreachable state: %s", s.status))
}
```

```go
// A function contract was violated — the caller passed something impossible
func parseToken(t Token) Value {
    if t.Kind == 0 {
        panic("parseToken called with zero Kind — caller bug")
    }
    // ...
}
```

Other examples: a map lookup that must succeed because the key was just inserted; a channel receive that must return a value because the sender is guaranteed to be running; a switch on an enumerated type that falls through all cases. These are not runtime failures — they are signals that a bug exists somewhere in the code.

## When Not to Use Panic

Conditions where the caller has a meaningful response:

- User input is invalid — return an error; the caller can show a message
- A file doesn't exist — return an error; the caller can use a default
- A network request fails — return an error; the caller can retry
- A database query returns no rows — return an empty result

These are not bugs. They are the program interacting with an unpredictable world. Use the `(result, error)` pattern from [document 18](18-error-handling.md).

## Where to Place Recover

Recover does not fix the bug. It contains it. A panic indicates something is wrong in the code — recover's job is to prevent that bug from crashing the entire system while logging enough information to find and fix it.

Place recover only at system boundaries, where you can cleanly terminate the current unit of work without affecting others:

- HTTP handlers — kill the request, return 500, keep the server alive
- Goroutine entry points — let one goroutine die without killing the program
- Test runners — let one test fail without stopping the suite

```go
func handleRequest(w http.ResponseWriter, r *http.Request) {
    defer func() {
        if rec := recover(); rec != nil {
            http.Error(w, "internal server error", 500)
            log.Printf("panic in %s %s: %v", r.Method, r.URL, rec)
        }
    }()

    // request handling
}
```

Do not place recover in the middle of a call chain. It does not turn a bug into a handled error — it just hides where the bug is.

## Runtime Panics

Panics from the runtime itself — nil pointer dereference, out-of-bounds slice access, map write on nil map — cannot be caught by `recover` in all Go versions. This is a factual limitation. Application-level panics (explicit `panic()` calls) are reliably recoverable.

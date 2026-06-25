# 23 — Context

When a function calls other functions that perform I/O or block, the caller needs a way to cancel the entire operation. `context.Context` is that mechanism — it carries cancellation intent and deadlines down through the call stack.

## How It Works

A context is a **shared state object**, not an enforcement mechanism. When a timeout fires or a cancel function is called, the context marks itself as cancelled. It does not stop any running goroutine or abort any operation. Each function in the call chain must actively check the context and choose to stop.

The two methods you'll use are **`ctx.Done()`** (detects that cancellation happened) and **`ctx.Err()`** (returns why — `context.Canceled` or `context.DeadlineExceeded`). See the interface definition below for the full picture.

If a function in the chain ignores the context, cancellation has no effect at that layer. The mechanism only works because every layer checks and propagates the cancellation.

## The Context Interface

By convention, `context.Context` is passed as the first argument to any function that may block or do I/O, and is named `ctx`:

```go
func fetch(ctx context.Context, url string) (string, error) {
    // implementation
}
```

The actual interface has four methods:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done()     chan struct{}
    Err()      error
    Value(key any) any
}
```

- **`Deadline()`** returns the time at which the context will be automatically cancelled, and a boolean indicating whether a deadline is set. Libraries use this to compute how long they have before the context expires (e.g. setting a socket timeout).
- **`Done()`** returns `chan struct{}` — a channel that closes when the context is cancelled. You listen on it with `select` to detect **that** cancellation happened. A channel is used instead of a boolean so cancellation can be multiplexed with other async operations in a single `select` — waiting on I/O, a timer, and cancellation all at once, without busy-polling. A closed channel is always ready to receive, so `case <-ctx.Done()` becomes eligible the moment the context is cancelled.
- **`Err()`** returns `error` — `nil` while active, `context.Canceled` if manually cancelled, or `context.DeadlineExceeded` if a timeout or deadline fired. These are sentinel errors compared with `errors.Is()`. Call this **after** `ctx.Done()` fires to find out **why** the context was cancelled.
- **`Value()`** retrieves a value stored in the context by key. Covered in the Context Value section below.

## Creating Contexts

Contexts form a tree: each context has a parent, and cancellation propagates downward. When a function receives a context and needs to add a deadline or timeout, it derives a new context from the one it received — so it never knows (or needs to know) whether an earlier layer already set a deadline. The child is cancelled by whichever happens first: its own trigger or its parent's cancellation.

`context.Background()` is the **root** of this tree — an empty context that never cancels on its own, has no deadline, and carries no values. It is the base case when no context exists yet (typically at the entry point of a request or program).

Several builder functions create derived contexts. All of them take an existing context as their first argument and return a new context plus a cancel function:

- `WithCancel(parent)` — manual cancellation via the returned `cancel()` function
- `WithTimeout(parent, duration)` — auto-cancels after a duration
- `WithDeadline(parent, time)` — auto-cancels at a specific time
- `WithValue(parent, key, value)` — attaches a key-value pair (discouraged)

```go
func handleRequest() {
    // Entry point: derive from Background() — the root.
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    doWork(ctx)
}

func doWork(parentCtx context.Context) {
    // Inner layer: derive from the received context.
    // This child is cancelled if parentCtx's 5s timeout fires first,
    // or after 2s — whichever comes first.
    ctx, cancel := context.WithTimeout(parentCtx, 2*time.Second)
    defer cancel()
    // ... do work with ctx ...
}
```

Always call `defer cancel()` immediately after creating a derived context. `cancel()` is a cleanup operation: it releases the context's internal resources (timers, tree nodes) so they can be garbage collected. For `WithTimeout` and `WithDeadline`, this matters when the operation finishes before the deadline — `cancel()` stops the timer early. It is safe to call on an already-cancelled context. Forgetting to call it leaks resources.

Calling `cancel()` on **any** derived context — including `WithTimeout` and `WithDeadline` — triggers immediate manual cancellation, regardless of whether the timer has fired. It closes `ctx.Done()`, waking up all children listening on it. `ctx.Err()` returns `context.Canceled` (not `DeadlineExceeded`), because the cancellation came from `cancel()`, not the timer.

### WithCancel

Returns a context that can be cancelled manually by calling the returned `cancel()` function:

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel()

go func() {
    result, err := fetch(ctx, url)
    // fetch checks ctx.Done() and stops if cancelled
}()

// later, when the result is no longer needed:
cancel()
```

### WithTimeout

Returns a context that auto-cancels after a duration elapses:

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

result, err := fetch(ctx, url)
if err != nil {
    if errors.Is(err, context.DeadlineExceeded) {
        fmt.Println("request timed out")
    }
}
```

### WithDeadline

Returns a context that auto-cancels at a specific absolute time:

```go
deadline := time.Now().Add(10 * time.Second)
ctx, cancel := context.WithDeadline(context.Background(), deadline)
defer cancel()
```

## Respecting Context

**1. Pass the context to a function that already checks it.** Many standard library functions watch the context internally — for example, `http.Client.Do()` aborts the request if the context is cancelled. You just pass the context and the library handles the rest.

**2. Check `ctx.Err()` before doing work.** The simplest, most deterministic check — no channels involved:

```go
func process(ctx context.Context) error {
    if ctx.Err() != nil {
        return ctx.Err()
    }
    // do work
    return nil
}
```

**3. Multiplex cancellation with other channels using `select`.** This is the main reason `ctx.Done()` returns a channel — it lets you wait on cancellation alongside other async operations in a single `select`:

```go
func worker(ctx context.Context, jobs <-chan Job) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case job, ok := <-jobs:
            if !ok {
                return nil // channel closed, no more work
            }
            // process job
        }
    }
}
```

`select` evaluates all cases and picks one that is ready. `<-ctx.Done()` becomes ready the moment the context is cancelled, whether by timeout, deadline, or an explicit `cancel()` call. Without the channel, this kind of multiplexing would require polling `ctx.Err()` in a loop.

## Complete Example

A master-worker pattern: the master creates a context with a timeout, a dispatch function derives a tighter deadline from it, and a worker checks the context before processing each job.

```go
package main

import (
    "context"
    "fmt"
    "time"
)

// worker processes jobs from a channel, stopping if the context is cancelled.
func worker(ctx context.Context, jobs <-chan int) (int, error) {
    count := 0
    for {
        select {
        case <-ctx.Done():
            return count, ctx.Err()
        case <-jobs:
            count++
        }
    }
}

// dispatch sends jobs to the worker indefinitely, until the context fires.
func dispatch(ctx context.Context, jobs chan<- int) (int, error) {
    // Derive a context with a shorter timeout from the received one.
    // This child is cancelled if the parent expires first, or after 250ms.
    ctx, cancel := context.WithTimeout(ctx, 250*time.Millisecond)
    defer cancel()

    count := 0
    for {
        select {
        case <-ctx.Done():
            return count, ctx.Err()
        case jobs <- count:
            count++
        }
    }
}

func main() {
    // Entry point: create context from Background().
    ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
    defer cancel()

    jobs := make(chan int)
    go worker(ctx, jobs)

    sent, sendErr := dispatch(ctx, jobs)
    fmt.Printf("dispatch: sent %d jobs — %v\n", sent, sendErr)
}
```

**Output** (exact job count varies by machine):

```
dispatch: sent 2847563 jobs — context deadline exceeded
```

**What happened:**

1. `main` creates a context with a 500ms timeout from `Background()`.
2. `dispatch` derives a tighter 250ms deadline from the received context, and runs an infinite loop sending jobs.
3. After 250ms, the tighter context's deadline fires — `cancel()` is triggered internally, closing `ctx.Done()`, which `dispatch` catches in its `select` and returns.
4. `main` prints the result and exits, taking the worker goroutine with it.
5. The infinite loop in `dispatch` was stopped solely by the context — no counters, limits, or flags needed.

## Context Value

`context.WithValue` exists for passing request-scoped data. It is not covered here by design — it is rarely appropriate and encourages misuse. Prefer explicit parameters.

# 21 — Goroutines

A goroutine is Go's lightweight concurrency primitive. The `go` keyword launches a function to run concurrently with the caller.

## Launching a Goroutine

```go
func greet(name string) {
    fmt.Printf("Hello, %s\n", name)
}

go greet("Alice")
greet("Bob")
```

The `go` statement returns immediately. The function runs concurrently in the background.

## Main Goroutine Exit

The main goroutine exiting terminates the program immediately, regardless of running goroutines:

```go
func main() {
    go func() {
        fmt.Println("this may not print")
    }()
    // program may exit before the goroutine runs
}
```

Synchronize with channels ([document 22](22-channels.md)) or `sync.WaitGroup` ([document 25](25-sync-package.md)) to wait for goroutines to complete.

## Goroutines Are Cheap

Creating thousands of goroutines is normal. They are multiplexed onto OS threads by the Go runtime — not one-to-one with threads. A single OS thread can run many goroutines, and the runtime schedules them based on blocking and readiness.

## Data Races

A data race occurs when multiple goroutines access the same memory without coordination, and at least one access is a write:

```go
var count int

go func() {
    count++  // race: concurrent write
}()

go func() {
    count++  // race: concurrent write
}()

fmt.Println(count)  // race: concurrent read
```

Detect data races at runtime with the race detector:

```bash
go test -race
go run -race main.go
```

The race detector instruments memory accesses and reports conflicts with stack traces. Use it during development — it has a performance cost but catches real bugs.

## Goroutine Leaks

A goroutine that blocks forever accumulates silently and consumes memory. This happens when a goroutine waits on a channel that is never closed or sent to:

```go
func worker(done chan struct{}) {
    <-done  // blocks forever if done is never closed
}

go worker(nil)  // leaked — nil channel blocks forever
```

The fix is to let the goroutine listen for cancellation alongside its blocking operation using `select` and `ctx.Done()`. See [document 23](23-context.md) for the pattern.

## Waiting for Goroutines

The `go` statement returns immediately. To wait for goroutines to finish, use one of these patterns:

**`sync.WaitGroup`** — wait for a known number of goroutines ([document 25](25-sync-package.md)):

```go
var wg sync.WaitGroup

for _, url := range urls {
    wg.Add(1)
    go func(u string) {
        defer wg.Done()
        fetch(u)
    }(url)
}

wg.Wait()  // blocks until all goroutines call Done()
```

**Channel signaling** — wait for a single result ([document 22](22-channels.md)):

```go
ch := make(chan string)
go func() {
    ch <- fetch("https://example.com")
}()

result := <-ch  // blocks until the goroutine sends
```

**Context cancellation** — wait with a timeout ([document 23](23-context.md)):

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

go worker(ctx)
// worker exits when it finishes or the context times out
```

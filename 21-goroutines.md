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

Synchronize with channels (document 22) or `sync.WaitGroup` (document 25) to wait for goroutines to complete.

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

A goroutine that blocks forever accumulates silently and consumes memory. Context cancellation (document 23) addresses this by providing a mechanism to signal goroutines to stop.

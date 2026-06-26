# 25 — Sync Package

The `sync` package provides non-channel concurrency primitives for mutual exclusion and coordination. Channels communicate between goroutines; `sync` coordinates shared-memory access.

## Mutex

`sync.Mutex` provides mutual exclusion — only one goroutine holds the lock at a time:

```go
var (
    mu    sync.Mutex
    count int
)

func increment() {
    mu.Lock()
    defer mu.Unlock()
    count++
}

func getCount() int {
    mu.Lock()
    defer mu.Unlock()
    return count
}
```

`defer mu.Unlock()` ensures the lock is released even if the function panics. A Mutex is not reentrant — calling `Lock()` twice from the same goroutine deadlocks.

## RWMutex

`sync.RWMutex` allows concurrent readers or an exclusive writer:

```go
var mu sync.RWMutex
var config map[string]string

func getConfig(key string) string {
    mu.RLock()
    defer mu.RUnlock()
    return config[key]
}

func setConfig(key, value string) {
    mu.Lock()
    defer mu.Unlock()
    config[key] = value
}
```

Multiple readers can hold `RLock` simultaneously. A writer's `Lock` excludes all readers and other writers. Use `RWMutex` when reads significantly outnumber writes.

## WaitGroup

`sync.WaitGroup` waits for a collection of goroutines to finish:

```go
var wg sync.WaitGroup

urls := []string{"https://a.com", "https://b.com", "https://c.com"}

for _, url := range urls {
    wg.Add(1)
    go func(u string) {
        defer wg.Done()
        fetch(u)
    }(url)
}

wg.Wait()  // blocks until all goroutines call Done()
fmt.Println("all done")
```

`Add(n)` sets the counter. `Done()` decrements by 1. `Wait()` blocks until the counter reaches zero. Pass `WaitGroup` by pointer — copying it resets the counter.

## Once

`sync.Once` executes a function exactly once across goroutines:

```go
var (
    once     sync.Once
    instance *Database
    initErr  error
)

func getDB() (*Database, error) {
    once.Do(func() {
        instance, initErr = connectDB()
    })
    return instance, initErr
}
```

The first call to `Do` runs the function. Subsequent calls return immediately without running it again. `Do` is safe to call from multiple goroutines simultaneously — if a second goroutine calls `Do` while the first is still executing the function, it blocks until the function completes. This guarantees that `instance` and `initErr` are assigned before any caller reaches the `return` statement.

## Sync.Map

`sync.Map` is a specialized concurrent map optimized for two scenarios:

1. **Keys are written once, then read many times** — the map "promotes" frequently-read entries to a lock-free read path.
2. **Different goroutines access disjoint key sets** — writes to different keys don't block each other.

```go
var cache sync.Map

cache.Store("key", "value")
value, ok := cache.Load("key")
cache.Delete("key")

cache.Range(func(key, value any) bool {
    fmt.Printf("%v: %v\n", key, value)
    return true  // continue iteration; return false to stop
})
```

**Trade-off vs. map + `sync.Mutex`:** A regular map with a mutex uses a single global lock — all reads and writes contend on it. `sync.Map` uses internal per-entry locking, so reads of "hot" entries are lock-free and writes to different keys don't block each other. The cost is higher memory overhead, slower writes under heavy contention, and a more verbose API (no `m[key]` syntax). For most use cases, a map with a `sync.Mutex` or `sync.RWMutex` is simpler and faster.

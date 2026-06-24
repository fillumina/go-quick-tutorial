# 22 — Context

When a chain of functions performs I/O or blocks, the caller needs a way to cancel the entire chain. `context.Context` is that mechanism — it propagates cancellation signals and deadlines across function call chains.

## The Context Interface

`context.Context` is passed as the first argument to any function that may block or do I/O. It is always named `ctx`:

```go
func fetch(ctx context.Context, url string) (string, error) {
    // implementation
}
```

## Background Context

`context.Background()` is the root context — used at the entry point of a request or program:

```go
ctx := context.Background()
result, err := fetch(ctx, "https://example.com")
```

## WithCancel

`context.WithCancel` returns a derived context and a cancel function. Calling cancel signals all functions holding that context:

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel()

go func() {
    // do work that can be cancelled
    result, err := fetch(ctx, url)
    // check ctx.Done() or ctx.Err() to respond to cancellation
}()

// later, when the result is no longer needed:
cancel()
```

`defer cancel()` placed immediately after `context.WithCancel` ensures the cancel function runs. Forgetting to call `cancel()` leaks resources.

## WithTimeout

`context.WithTimeout` cancels automatically after the duration elapses:

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

## WithDeadline

`context.WithDeadline` cancels at a specific absolute time:

```go
deadline := time.Now().Add(10 * time.Second)
ctx, cancel := context.WithDeadline(context.Background(), deadline)
defer cancel()
```

## Checking Cancellation

Inside a function, check `ctx.Done()` (a channel that closes on cancellation) or `ctx.Err()` to respond to cancellation:

```go
func fetch(ctx context.Context, url string) (string, error) {
    req, _ := http.NewRequest("GET", url, nil)
    req = req.WithContext(ctx)

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    data, err := io.ReadAll(resp.Body)
    if err != nil {
        return "", err
    }

    return string(data), nil
}
```

The `http` package's `Do` method respects context cancellation. When the context is cancelled, the request is aborted.

For long-running operations, poll `ctx.Done()`:

```go
func process(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            // do work
        }
    }
}
```

`ctx.Err()` returns `nil` if the context is active, `context.Canceled` if cancelled, or `context.DeadlineExceeded` if the deadline passed.

## Context Value

`context.WithValue` exists for passing request-scoped data. It is not covered here by design — it is rarely appropriate and encourages misuse. Prefer explicit parameters.

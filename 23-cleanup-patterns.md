# 23 — Cleanup Patterns

Go's `defer` combines with error handling and context for resource cleanup. The patterns are consistent and appear throughout real code.

## Open, Check, Defer Close

The canonical resource pattern — open, check error, defer close, in that exact order:

```go
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()

    data, err := io.ReadAll(f)
    if err != nil {
        return err
    }

    // use data
    return nil
}
```

The `defer f.Close()` runs when the function returns, regardless of which return statement is taken. The error check before the defer ensures the resource was opened successfully before scheduling cleanup.

## Context Cancellation

`defer cancel()` placed immediately after `context.WithCancel` or `context.WithTimeout`:

```go
func handleRequest(w http.ResponseWriter, r *http.Request) {
    ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
    defer cancel()

    result, err := doWork(ctx)
    if err != nil {
        http.Error(w, err.Error(), 500)
        return
    }

    fmt.Fprintf(w, "%s", result)
}
```

## Multiple Resources

When opening multiple resources, defer each one after its error check:

```go
func copyFiles(src, dst string) error {
    in, err := os.Open(src)
    if err != nil {
        return err
    }
    defer in.Close()

    out, err := os.Create(dst)
    if err != nil {
        return err
    }
    defer out.Close()

    _, err = io.Copy(out, in)
    return err
}
```

If `os.Create` fails, `in.Close()` runs via defer before the function returns. If both succeed, both close functions run in LIFO order when the function returns.

## Early Return

Early return on error is idiomatic — flat code without nesting is preferred:

```go
func handle(r *http.Request) error {
    ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
    defer cancel()

    data, err := fetch(ctx, r.URL.String())
    if err != nil {
        return err
    }

    parsed, err := parse(data)
    if err != nil {
        return err
    }

    result, err := compute(parsed)
    if err != nil {
        return err
    }

    return store(result)
}
```

This pattern avoids deeply nested error checks and keeps the happy path linear. Each error check returns immediately, and defer handles all cleanup.

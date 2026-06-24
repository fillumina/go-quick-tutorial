# 17 — Error Handling

Go signals errors through return values, not exceptions. The `error` type is a built-in interface, and the convention is to return errors as the last value from functions that may fail.

## The Error Interface

```go
type error interface {
    Error() string
}
```

Any type with an `Error() string` method satisfies the `error` interface.

## Creating Errors

`errors.New` creates a simple error from a message:

```go
import "errors"

func validateAge(age int) error {
    if age < 0 {
        return errors.New("age cannot be negative")
    }
    if age > 150 {
        return errors.New("age is unrealistic")
    }
    return nil
}
```

## Checking Errors

The standard pattern checks the error immediately after the call:

```go
err := validateAge(-5)
if err != nil {
    fmt.Println(err)  // prints: age cannot be negative
}
```

With a result value:

```go
result, err := parseInput(data)
if err != nil {
    return err
}
// use result
```

## Wrapping Errors

`fmt.Errorf` with `%w` wraps an error with additional context:

```go
func loadConfig(path string) error {
    data, err := os.ReadFile(path)
    if err != nil {
        return fmt.Errorf("load config: %w", err)
    }
    // parse data...
    return nil
}
```

Wrapping adds context for humans while preserving the original error for programmatic checks. The call chain builds a readable message: `load config: open config.yaml: no such file or directory`.

## Unwrapping Errors

`errors.Is` checks if an error anywhere in the chain matches a target value:

```go
data, err := os.ReadFile("missing.txt")
if errors.Is(err, os.ErrNotExist) {
    fmt.Println("file does not exist")
}
```

`errors.As` extracts a specific error type from the chain:

```go
type PathError struct {
    Op   string
    Path string
}

func (e *PathError) Error() string {
    return fmt.Sprintf("%s: %s", e.Op, e.Path)
}

err := someFunction()
var pathErr *PathError
if errors.As(err, &pathErr) {
    fmt.Printf("operation %s failed on path %s\n", pathErr.Op, pathErr.Path)
}
```

`errors.As` is used when you need to access fields on a custom error type buried in a wrap chain.

## Sentinel Errors

Package-level error values that functions return and callers check with `errors.Is`:

```go
var ErrNotFound = errors.New("not found")

func lookup(key string) (string, error) {
    value, ok := database[key]
    if !ok {
        return "", ErrNotFound
    }
    return value, nil
}

_, err := lookup("missing")
if errors.Is(err, ErrNotFound) {
    fmt.Println("key not in database")
}
```

Sentinel errors are exported so callers can check for them. They are compared by identity, not by message text.

## Errors Are Values

Errors are ordinary values passed through the return mechanism. There is no exception handling, no stack unwinding, and no try-catch. Control flow remains explicit and linear.

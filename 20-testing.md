# 20 — Testing

Go's built-in testing framework requires no external dependencies. Test files end in `_test.go` and are excluded from normal builds.

## Test Files and Functions

```go
// calculator_test.go
package calculator

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Add(2, 3) = %d; want 5", result)
    }
}
```

Test functions must start with `Test` and accept `*testing.T`. `t.Errorf` marks the test as failed and continues execution. `t.Fatalf` marks it as failed and stops immediately.

## Running Tests

```bash
go test ./...           # all tests in the module
go test ./pkg/          # tests in a specific package
go test -run TestAdd    # specific test (supports regex)
go test -cover          # with coverage report
```

## Table-Driven Tests

The dominant Go testing pattern — a slice of structs defines input and expected output, iterated with range:

```go
func TestMultiply(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 3, 4, 12},
        {"zero", 0, 5, 0},
        {"negative", -2, 3, -6},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Multiply(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Multiply(%d, %d) = %d; want %d", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

`t.Run` creates a named sub-test for each table row. Run a specific sub-test with `go test -run TestMultiply/positive`.

## Benchmarks

```go
func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}
```

`b.N` is set by the testing framework to produce a reliable timing. Run with `go test -bench=BenchmarkAdd`. The framework adjusts `b.N` across iterations until the measurement stabilizes.

## Fuzz Testing

Built-in since Go 1.18:

```go
func FuzzReverse(f *testing.F) {
    f.Fuzz(func(t *testing.T, input string) {
        reversed := Reverse(input)
        reversedAgain := Reverse(reversed)
        if reversedAgain != input {
            t.Fatalf("Reverse(Reverse(%q)) = %q", input, reversedAgain)
        }
    })
}
```

Run with `go test -fuzz=FuzzReverse`. The framework generates random inputs and mutates them to find failures. Seed the fuzzer with known inputs using `f.Add("example")`.

The fuzz function parameters can be any of these types: `bool`, `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `uintptr`, `float32`, `float64`, `string`, `[]byte`. You can use multiple parameters in a single fuzz function:

```go
func FuzzParse(f *testing.F) {
    f.Fuzz(func(t *testing.T, s string, n int, flag bool) {
        // fuzzer generates random values for all three parameters
    })
}
```

## t.Helper

Mark a helper function with `t.Helper()` so that failure messages report the caller's location, not the helper's:

```go
func assertEqual(t *testing.T, got, want int) {
    t.Helper()
    if got != want {
        t.Errorf("got %d, want %d", got, want)
    }
}

func TestAdd(t *testing.T) {
    assertEqual(t, Add(2, 3), 5)  // failure points here, not into assertEqual
}
```

Without `t.Helper()`, a failing assertion reports the line inside the helper function, making it harder to trace which test case triggered the failure.

## Mocking

Go's interface-based design makes mocking straightforward — define an interface, implement a mock that satisfies it, and pass the mock to the code under test:

```go
// Interface
type Store interface {
    Get(key string) (string, error)
}

// Mock implementation
type mockStore struct {
    data map[string]string
}

func (m mockStore) Get(key string) (string, error) {
    val, ok := m.data[key]
    if !ok {
        return nil, errors.New("not found")
    }
    return val, nil
}

// Usage in test
func TestHandler(t *testing.T) {
    store := mockStore{data: map[string]string{"key": "value"}}
    handler := NewHandler(store)
    // test with controlled data
}
```

No external mocking framework is needed. The interface acts as a contract between production code and test doubles. For larger projects, code generation tools like `mockgen` (from `go.uber.org/mock`) generate mock implementations from interface definitions automatically.

## Integration Tests

Separate integration tests from unit tests using build tags. Add `//go:build integration` at the top of a test file to exclude it from `go test` by default:

```go
//go:build integration

package db_test

import "testing"

func TestConnectToDatabase(t *testing.T) {
    // runs against real database
}
```

Run with `go test -tags=integration ./...`. This keeps slow or environment-dependent tests out of the normal test cycle while keeping them in the same repository.

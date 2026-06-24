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

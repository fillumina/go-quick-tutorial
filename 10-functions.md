# 10 — Functions

Functions are the primary unit of code organization in Go. They support multiple return values, closures, variadic arguments, and deferred execution.

## Declaration

```go
func length(s string) int {
    return len(s)
}

result := length("Alice")  // 5
```

Multiple parameters of the same type share the type annotation:

```go
func lessThan(a, b int) bool {
    return a < b
}
```

### No Overloading

Go does not support function or method overloading. Two functions cannot share the same name within the same package, even if their parameter lists differ. The same rule applies to methods on a struct — a method name is unique to its receiver type:

```go
func add(a, b int) int { return a + b }

// Compile error: add redeclared in this block
func add(a, b float64) float64 { return a + b }
```

Use distinct names instead, such as `AddInt` and `AddFloat`, or a single function that accepts a more general type.

## Multiple Return Values

Functions can return multiple values. The idiomatic pattern returns a result and an error:

```go
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}

result, err := divide(10, 2)
if err != nil {
    log.Fatal(err)
}
fmt.Println(result)
```

Named return values are declared in the signature and returned by a bare `return`:

```go
func divide(a, b float64) (quotient float64, err error) {
    if b == 0 {
        err = fmt.Errorf("division by zero")
        return
    }
    quotient = a / b
    return
}
```

Named returns reduce repetition but reduce clarity. Use them sparingly.

## Functions as Values

Functions are first-class values — assignable to variables and passable as arguments:

```go
type Selector func(int) bool

func isEven(n int) bool {
    return n%2 == 0
}

func selectAll(numbers []int, s Selector) []int {
    var result []int
    for _, n := range numbers {
        if s(n) {
            result = append(result, n)
        }
    }
    return result
}

evens := selectAll([]int{1, 2, 3, 4, 5, 6}, isEven)
```

## Closures

A closure is a function literal that captures variables from its surrounding scope:

```go
func makeCounter(start int) func() int {
    seed := 1000
    return func() int {
        start++
        return seed + start
    }
}

counter := makeCounter(0)
fmt.Println(counter())  // 1001
fmt.Println(counter())  // 1002
```

The closure captures both `start` (a parameter) and `seed` (a local variable). Both persist across calls.

## Variadic Functions

A variadic function accepts a variable number of arguments of the same type. The variadic parameter must be the last parameter:

```go
func sum(scale float64, values ...int) float64 {
    total := 0
    for _, v := range values {
        total += v
    }
    return float64(total) * scale
}

sum(1, 1, 2, 3)       // 6
sum(0.1, 1, 2, 3)     // 0.6
sum(10, 1, 2, 3, 4, 5) // 150
```

`values` is a slice inside the function. To pass a slice or array as variadic arguments, use the spread notation `...`:

```go
slice := []int{1, 2, 3, 4, 5}
total := sum(1, slice...)  // 15

array := [3]int{1, 2, 3}
total := sum(1, array...)  // 6
```

## Defer

`defer` schedules a function call to run when the surrounding function returns, regardless of how it returns. The defer statement can appear anywhere in the function, as long as it is reached before the return:

```go
func process() {
    file, err := os.Open("data.txt")
    if err != nil {
        return
    }
    defer file.Close()

    // work with file
    // file.Close() runs when process() returns, even if there's an early return
}
```

Deferred calls execute in LIFO order — the last deferred call runs first:

```go
for i := 0; i < 3; i++ {
    defer fmt.Print(i)
}
// prints: 2 1 0
```

Arguments to a deferred function are evaluated immediately at the `defer` statement, not when the deferred call runs:

```go
count := 0
defer fmt.Println(count)  // will print 0, not the final value
count = 5
```

To capture the final value, defer a function literal:

```go
count := 0
defer func() {
    fmt.Println(count)  // prints 5
}()
count = 5
```

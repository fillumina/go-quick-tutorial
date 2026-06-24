# 11 — Functions

Functions are the primary unit of code organization in Go. They support multiple return values, closures, variadic arguments, and deferred execution.

## Declaration

```go
func greet(name string) string {
    return "Hello, " + name
}

result := greet("Alice")
```

Multiple parameters of the same type share the type annotation:

```go
func add(x, y int) int {
    return x + y
}
```

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
type Filter func(int) bool

func isEven(n int) bool {
    return n%2 == 0
}

func filter(numbers []int, f Filter) []int {
    var result []int
    for _, n := range numbers {
        if f(n) {
            result = append(result, n)
        }
    }
    return result
}

evens := filter([]int{1, 2, 3, 4, 5, 6}, isEven)
```

## Closures

A closure is a function literal that captures variables from its surrounding scope:

```go
func makeCounter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

counter := makeCounter()
fmt.Println(counter())  // 1
fmt.Println(counter())  // 2
```

The captured variable is shared, not copied. Each call to the closure sees the updated value.

## Variadic Functions

A variadic function accepts a variable number of arguments of the same type:

```go
func sum(values ...int) int {
    total := 0
    for _, v := range values {
        total += v
    }
    return total
}

sum(1, 2, 3)       // 6
sum(1, 2, 3, 4, 5) // 15
sum()              // 0
```

Inside the function, `values` is a slice. Call with a slice using `...` to spread its elements:

```go
numbers := []int{1, 2, 3, 4, 5}
total := sum(numbers...)  // 15
```

## Defer

`defer` schedules a function call to run when the surrounding function returns, regardless of how it returns:

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

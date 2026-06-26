# 09 — Control Flow

Go provides conditionals, loops, and switches with minimal syntax. There are no parentheses around conditions, and braces are mandatory.

## If

```go
if count > 0 {
    fmt.Println("positive")
}

if count > 0 {
    fmt.Println("positive")
} else {
    fmt.Println("zero or negative")
}
```

No parentheses around the condition. Braces are required — single-line if without braces is a compile error.

### Init Statement in If

An init statement runs before the condition. The variables it declares are scoped to the if block:

```go
if count, err := getCount(); err == nil {
    fmt.Println(count)
}
// count and err are not accessible here
```

This pattern appears constantly in real Go code for error checks:

```go
if result, err := doSomething(); err != nil {
    log.Fatal(err)
}
// use result
```

## For

`for` is the only loop construct in Go. There is no `while` or `do-while`.

### C-Style For Loop

```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}
```

### While Equivalent

Omit the init and post statements for a while loop:

```go
i := 0
for i < 10 {
    fmt.Println(i)
    i++
}
```

### Infinite Loop

Omit all clauses:

```go
for {
    // runs forever until break
}
```

### Range Loop

`for..range` iterates over arrays, slices, maps, strings, and channels. Covered in document 14.

## Switch

```go
switch day {
case "Monday":
    fmt.Println("start of week")
case "Friday":
    fmt.Println("end of week")
default:
    fmt.Println("midweek")
}
```

Cases do not fall through automatically. Each case terminates after its statements. Multiple values in one case use a comma:

```go
switch grade {
case "A", "B":
    fmt.Println("pass")
case "C", "D":
    fmt.Println("marginal")
case "F":
    fmt.Println("fail")
}
```

### Switch Without Value

A switch without a value works as an if-else chain:

```go
switch {
case count > 10:
    fmt.Println("large")
case count > 0:
    fmt.Println("small")
default:
    fmt.Println("zero or negative")
}
```

### Fallthrough

By default, each case terminates after its statements. `fallthrough` forces execution to continue into the next case:

```go
switch grade {
case "B":
    fmt.Println("satisfactory")
    fallthrough
case "C":
    fmt.Println("needs improvement")
}
```

This prints both "satisfactory" and "needs improvement". The `fallthrough` keyword appears in real code (e.g., encoding packages) where multiple cases share cleanup logic. It transfers control to the next case's statements — the next case's condition is not evaluated.

## Break and Continue

`break` exits the innermost loop or switch. `continue` skips to the next iteration:

```go
for i := 0; i < 10; i++ {
    if i == 5 {
        break   // exits loop at i == 5
    }
    if i%2 == 0 {
        continue  // skips even numbers
    }
    fmt.Println(i)
}
```

### Labeled Break

A labeled break exits a named outer loop:

```go
outer:
for i := 0; i < 5; i++ {
    for j := 0; j < 5; j++ {
        if i+j == 4 {
            break outer
        }
    }
}
```

## Goto

`goto` jumps to a labeled statement within the same function:

```go
for i := 0; i < 100; i++ {
    if shouldExit(i) {
        goto cleanup
    }
}
cleanup:
fmt.Println("done")
```

`goto` cannot jump past variable declarations. It exists for deep nesting escape and is rarely used.

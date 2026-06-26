# 01 — Program Structure

Go organizes code into packages, where every source file declares its membership and the compiler enforces strict boundaries between them.

Every `.go` file begins with a package declaration:

```go
package main
```

Files in the same directory must share the same package name and are compiled together as a single unit. A name defined in one file is visible to all other files in the same package without any import.

By convention, the package name matches the directory name. Files in a `geometry` directory declare `package geometry`. `go vet` warns when they differ.

The entry point of an executable program is the function `main` in `package main`:

```go
package main

func main() {
}
```

Visibility across package boundaries is controlled entirely by capitalization. An identifier starting with an uppercase letter is exported — accessible from other packages. One starting with a lowercase letter is unexported — accessible within the package across all its files, but invisible outside.

```go
package geometry

var Pi = 3.14159      // exported
var precision = 10    // unexported

func Area(r float64) float64 { ... }   // exported
func validate(r float64) bool { ... }  // unexported
```

There are no `public`, `private`, or `protected` keywords. Capitalization is the complete visibility system. Unexported does not mean private to a single file — every file in the package can use it.

## Semicolons

Go does not require a semicolon at the end of each statement. The lexer automatically inserts semicolons at newlines in specific situations — primarily after a statement when the line ends with an expression, an identifier, or certain keywords (`break`, `continue`, `fallthrough`, `return`) or tokens (`++`, `--`, `)`, `]`, `}`).

In practice, this means you write code without semicolons and it works. The rules matter when you need to break a statement across lines or put two statements on one line:

```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}  // semicolons required inside for

x := 1; y := 2  // two statements on one line need a semicolon
```

The automatic insertion means an opening `{` must be on the same line as the preceding keyword (`if`, `for`, `func`, `switch`, etc.), otherwise the lexer inserts a semicolon before it, creating an empty statement.

```go
if x > 0 {  // correct
    fmt.Println("positive")
}

if x > 0
{  // compile error: { treated as start of a new statement
    fmt.Println("positive")
}
```

A newline does NOT trigger semicolon insertion when the line ends with an operator, an opening token (`(`, `{`, `[`), a comma, or the keywords `case` or `default`. This is what allows breaking long expressions across lines:

```go
result = a +
    b +
    c

if (x > 0 &&
    y < 10) {
    fmt.Println("range")
}

config := Config{
    Host: "localhost",
    Port: 8080,
}
```

For method chains, the dot must be at the end of the line, not the beginning of the next:

```go
person.address("main").  // OK — line ends with .
    number

person.address("main")   // ERROR — line ends with ), semicolon inserted
    .number
```

## Command-Line Arguments

Command-line arguments are available through `os.Args`, which returns an array of strings:

- `os.Args[0]` — the program name
- `os.Args[1]`, `os.Args[2]`, etc. — the user-supplied arguments

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    fmt.Println(os.Args[0])  // program name, e.g. "./myapp"
    fmt.Println(os.Args[1])  // first argument, e.g. "hello"
    fmt.Println(os.Args[2])  // second argument, e.g. "world"
}
```

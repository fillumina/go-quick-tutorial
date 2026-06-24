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

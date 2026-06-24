# 04 — Standard Library and Help System

Go ships with a large standard library and built-in tooling for navigating documentation — both online and offline.

---

## Standard Library Overview

The standard library is extensive. It covers the areas below without requiring any external dependencies:

| Area | Packages |
| --- | --- |
| Formatting and I/O | `fmt`, `io`, `os`, `bufio` |
| Networking | `net`, `net/http` |
| Encoding | `encoding/json`, `encoding/xml`, `encoding/csv` |
| String manipulation | `strings`, `strconv`, `unicode`, `regexp` |
| Concurrency | `sync`, `sync/atomic` |
| Time and dates | `time` |
| File paths | `path`, `path/filepath` |
| Testing | `testing` |
| Cryptography | `crypto/*` |
| Compression | `compress/*`, `archive/*` |

The standard library source code is installed locally with Go and is readable — it is written in idiomatic Go and serves as a practical reference for patterns and conventions.

---

## `go doc` — Offline Documentation

`go doc` prints package documentation in the terminal. It works offline and is fast — it is the first tool to reach for when looking up an API.

### Package documentation

```bash
go doc net/http
```

Prints the package comment, exported types, and functions for `net/http`.

### Specific symbol

```bash
go doc net/http.ListenAndServe
```

Prints the signature and documentation for a specific function, type, or constant.

### Method on a type

```bash
go doc net/http.ResponseWriter.Write
```

Prints documentation for a method on a specific type.

---

## `pkg.go.dev` — Web Documentation

`pkg.go.dev` is the web interface for all Go documentation. It covers:

- Every standard library package
- Every published third-party module

The URL pattern is predictable: `pkg.go.dev/std` for the standard library index, `pkg.go.dev/net/http` for a specific package, `pkg.go.dev/github.com/gin-gonic/gin` for a third-party module.

---

## Doc-Aware Comments

Go's documentation tooling reads specially formatted comments. The first sentence of a comment is treated as a summary. Comments must start with the identifier name.

```go
// ListenAndServe starts an HTTP server with a given address and handler.
// It returns an error if the address is invalid.
func ListenAndServe(addr string, handler Handler) error {
    // ...
}
```

The `go doc` output shows "ListenAndServe starts an HTTP server with a given address and handler." as the summary line. Blank lines in the comment separate paragraphs in the rendered output.

This convention applies to packages (via `doc.go` files), types, functions, methods, and variables.

---

## Navigation Strategy

When you need to find something in the standard library:

1. **Know the package name** — use `go doc packagename`
2. **Know the function name** — use `go doc packagename.FunctionName`
3. **Exploring** — browse `pkg.go.dev/std` or read the source locally

The standard library is organized by domain, not by abstraction level. Related functionality lives in the same package: `strings` contains all string operations, `os` contains all operating-system-level I/O, `net/http` contains the complete HTTP client and server implementation.

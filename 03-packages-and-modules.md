# 03 — Packages and Modules

Go's module system defines the unit of versioning and distribution, layered above individual packages.

---

## Packages

A **package** is a directory of `.go` files sharing the same `package` declaration.

**Naming conventions:**

- Short, lowercase, no underscores
- Conventionally matches the directory name
- `go vet` warns when package name and directory name differ

**Key rules:**

- Two packages cannot import each other — *circular imports are a compile error*
- Any package with exported names is importable by its path — there is no separate "export" concept

### Internal Packages

A directory named `internal` restricts which other packages can import its contents. Conventionally, `internal` contains subdirectories, each a separate package — `internal/auth/` is imported as `"example/myapp/internal/auth"`. It is also possible to place `.go` files directly in `internal/` (making it a package itself, importable as `"example/myapp/internal"`), but this is uncommon. Only code within the same module can import these packages. A different module trying to import `"example/myapp/internal/auth"` is rejected by the compiler.

A nested `internal` directory applies the same rule at a smaller scope. `storage/internal/cache` is importable only by packages inside `storage/` and its subdirectories — not even by other packages in the same module.

---

## Modules

A **module** is a tree of packages rooted at a directory containing a `go.mod` file. The module path declared in `go.mod` becomes the import prefix for every package in the module:

```
module github.com/example/myapp

go 1.22

require (
    github.com/some/library v1.4.2
)
```

A package at `myapp/storage/postgres` is imported as `"github.com/example/myapp/storage/postgres"`.

### Program vs Library

There is **no formal distinction** between a program module and a library module:

- If any package declares `package main` with a `main()` function, `go build` produces an *executable*
- Packages that are not `package main` are *library packages* — importable by other modules
- A single module can be **both**: contain importable library packages and a `main` package that builds an executable

---

## Dependencies

### Automatic Dependency Download (Preferred)

The typical workflow is: **add the import to your code**, then run `go mod tidy`. Go automatically:

1. Resolves the module path from the import statement
2. Downloads the module if it is not cached locally
3. Adds the dependency to `go.mod` with the minimum required version
4. Updates `go.sum` with the cryptographic hash

**Example — adding a GitHub dependency:**

Add an import to your code:

```go
import "github.com/gorilla/mux"
```

Run `go mod tidy`. Go resolves the module path, downloads the latest compatible version, and updates `go.mod`:

```
require github.com/gorilla/mux v1.8.1
```

The module is now cached locally and available for building. The same automatic resolution happens when you run `go build` or `go run` — they will download missing dependencies before compiling.

**You cannot specify a version with automatic download.** `go mod tidy` always picks the minimum version required by your code. If you need a specific version, use `go get` instead.

### Other Dependency Methods

**`go get` — explicit version control:**

```
go get github.com/gorilla/mux@v1.8.1
```

Use `go get` when you need to pin a specific version, upgrade beyond the current minimum, or add a dependency before writing the import.

**`go mod download` — download without modifying `go.mod`:**

```
go mod download
```

Downloads all dependencies listed in `go.mod` to the local cache without adding or removing entries. Useful for pre-populating the cache in CI pipelines or verifying that all dependencies are reachable.

**`go mod vendor` — local vendor directory:**

```
go mod vendor
```

Copies all dependencies into a `vendor/` directory within your project. Subsequent builds use the vendored copies instead of downloading. Useful for air-gapped environments or when you want to lock the exact source code your project builds against.

**`go mod why` — understand why a dependency is needed:**

```
go mod why github.com/uber/atomic
```

Prints the shortest import chain from your main module to the specified dependency, showing which of your packages transitively requires it.

### Removing Dependencies

`go mod tidy` removes unused dependencies automatically. To remove a specific one:

```
go get github.com/some/library@none
```

This removes the entry from `go.mod` entirely.

### Semver Versioning

Versions map to git tags in semver format: `v<major>.<minor>.<patch>`. In `v1.4.2`:

- **Major** (`1`) — breaking changes. Incrementing to `v2.0.0` signals incompatibility with `v1.x.x`
- **Minor** (`4`) — backward-compatible additions. `v1.5.0` adds features without breaking `v1.4.x` code
- **Patch** (`2`) — bug fixes. `v1.4.3` fixes bugs without changing behavior

**How Go resolves versions:**

- `go.mod` records a *minimum* version, not a pinned version. If `go.mod` says `v1.4.2`, and another dependency requires `v1.4.5`, Go uses `v1.4.5`
- You cannot request "latest patch within a minor version" directly. Go's minimum version selection handles this automatically — the highest required version within the same major is always used
- To get the latest version of a dependency regardless of current requirements: `go get github.com/some/library@latest`

### Direct vs Indirect Dependencies

| Type         | Description                            | Example                                     |
| ------------ | -------------------------------------- | ------------------------------------------- |
| **Direct**   | A package your code imports explicitly | `github.com/some/library v1.4.2`            |
| **Indirect** | A dependency of a dependency           | `github.com/other/utils v0.3.1 // indirect` |

Both appear in `go.mod`, with indirect ones marked `// indirect`.

### Version Conflict Resolution

When two dependencies require different versions of the same transitive package, Go uses **minimum version selection** — it picks the *highest version required by any dependency*. This ensures a single version of each module is used throughout the build.

### Dependency Files

- **`go.mod`** — declares the module path, minimum Go version, and dependencies
- **`go.sum`** — records cryptographic hashes of every downloaded module
- *Commit both files* to version control

### Standard Library

Standard library packages are part of the Go installation:

- Require no `go get`
- Appear in no `go.mod`

---

## Major Version Suffixes

When a module releases a breaking v2 version, the module path gains a **version suffix**: `github.com/example/lib/v2`.

**Rules:**

- Applies to all versions **>= v2**: `/v3`, `/v4`, etc.
- The suffix appears in the *module path* and in *all import paths*
- v1 modules have no suffix
- Allows multiple major versions of the same module to coexist as distinct imports

---

## Build Tags

Build tags control which `.go` files are included in a package compilation. A tag directive at the top of a file tells the compiler to include or exclude the file based on conditions like OS, architecture, or custom labels.

```go
//go:build linux

package main
```

This file is compiled only on Linux. The blank line after the directive is required.

**Common tag conditions:**

| Tag | Meaning |
|-----|---------|
| `linux`, `darwin`, `windows` | Operating system |
| `amd64`, `arm64` | CPU architecture |
| `go1.21` | Minimum Go version |
| Custom labels | Set with `go build -tags labelname` |

**Combining conditions:**

```go
//go:build linux && amd64
//go:build linux || darwin
//go:build !windows
```

Use `&&` (AND), `||` (OR), and `!` (NOT) to compose conditions.

**File naming convention:** Files can also be filtered by suffix — `file_linux.go` is only compiled on Linux, `file_test.go` is only included during `go test`. Build tags offer more flexibility than naming conventions alone.

---

## Build Commands

| Command      | What it does                                                                                                                                                |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `go run .`   | Compiles and executes a `main` package in one step — writes the binary to a *temporary location* and runs it directly, producing **no persistent artifact** |
| `go build`   | Compiles the current package and its dependencies into a binary (for `main`) or validates (for libraries)                                                   |
| `go install` | Builds and installs the resulting binary to `GOBIN` (default `~/go/bin`)                                                                                    |
| `go vet`     | Runs static analysis to detect likely bugs and suspicious constructs                                                                                        |

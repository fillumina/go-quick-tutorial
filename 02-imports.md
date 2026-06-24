# 02 — Imports

Go's import system brings external packages into scope, with strict rules the compiler enforces.

---

## Import Syntax

### Single Import

```go
import "fmt"
```

Used in a complete program:

```go
package main

import "fmt"

func main() {
    fmt.Println("hello")
}
```

### Grouped Imports

Multiple imports use a grouped block — the **preferred form** in all real code:

```go
import (
    "fmt"
    "os"
    "net/http"
)
```

---

## Import Path Categories

| Category | Example | Description |
| --- | --- | --- |
| **Standard library** | `"fmt"`, `"os"`, `"net/http"` | Ships with Go, requires no setup |
| **External packages** | `"github.com/example/json"` | Fetched with `go get` — mechanics covered in the next chapter |

---

## Package Naming

The local name of an imported package is its **last path element** by default:

- `"net/http"` → used as `http`
- `"encoding/json"` → used as `json`
- `"path/filepath"` → used as `filepath`

When two imports share a last element, or when a shorter alias is clearer, declare one explicitly:

```go
import (
    "fmt"
    myjson "github.com/example/json"  // referenced as myjson in this file
)
```

---

## Special Import Forms

### Blank Import

Runs a package's initialization code without making any of its names available. Standard for database drivers and image format decoders, which register themselves as a side effect:

```go
import _ "github.com/lib/pq"  // registers PostgreSQL driver, nothing else used
```

### Dot Import

Pulls all exported names directly into the current file's namespace, removing the need for a qualifier. With `import . "fmt"`, calls like `fmt.Println("hello")` become `Println("hello")`. It exists in the language but *obscures where names originate* and is rarely appropriate:

```go
import . "fmt"  // Println is now available without the fmt. prefix
```

---

## Unused Imports

The compiler treats an unused import as an **error, unconditionally**. If a package is imported and nothing from it is referenced, the program does not compile. There is no flag to suppress this.

---

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

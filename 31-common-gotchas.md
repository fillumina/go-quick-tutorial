# 31 — Common Gotchas

Corner cases and subtle behaviors that trip up experienced developers. Each entry describes the behavior, why it happens, and a minimal example.

## Time.Duration Is Just Int64

`time.Duration` is `int64` nanoseconds. Arithmetic works, but the type prevents mixing with plain integers:

```go
d := 5 * time.Second
n := int64(d)  // 5000000000, explicit conversion needed
```

## Strings.Builder and Bytes.Buffer Are Not Concurrency-Safe

Do not share `strings.Builder` or `bytes.Buffer` across goroutines:

```go
var buf strings.Builder
go func() { buf.WriteString("a") }()  // data race
go func() { buf.WriteString("b") }()  // data race
```

## JSON Unmarshaling Numbers as Float64

When unmarshaling JSON into an `any` (or `map[string]any`), the `encoding/json` package has no type information to guide it. It decodes **all** JSON numbers as `float64`, regardless of whether they look like integers:

```go
var data any
json.Unmarshal([]byte(`{"count": 10000000000}`), &data)
m := data.(map[string]any)
fmt.Printf("%T\n", m["count"])  // float64, not int
```

`float64` cannot precisely represent integers larger than 2⁵³. Values like IDs, timestamps, or large counters silently lose precision:

```go
m["count"].(float64)  // 10000000000 may not equal the original
```

**Two fixes:**

Use a typed struct so the decoder knows the target type:

```go
type Payload struct {
    Count int64 `json:"count"`
}
var p Payload
json.Unmarshal([]byte(`{"count": 10000000000}`), &p)
// p.Count is int64, exact value preserved
```

Or use `json.Decoder.UseNumber()` to decode numbers as `json.Number` (a string-backed type) instead of `float64`:

```go
dec := json.NewDecoder(bytes.NewReader(jsonBytes))
dec.UseNumber()
var data any
dec.Decode(&data)
m := data.(map[string]any)
count, _ := m["count"].(json.Number).Int64()
```

## Predeclared Identifiers Can Be Shadowed

All predeclared identifiers can be shadowed by local declarations. Go does not treat them as reserved keywords — they are ordinary identifiers that happen to be in scope by default.

**Predeclared types (20):**

`string`, `bool`, `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `uintptr`, `byte`, `rune`, `float32`, `float64`, `complex64`, `complex128`, `error`, `any`

**Predeclared constants (3):**

`true`, `false`, `nil`

**Predeclared functions (16):**

`append`, `cap`, `close`, `complex`, `copy`, `delete`, `imag`, `len`, `make`, `new`, `panic`, `print`, `println`, `real`, `recover`

Any of these can be shadowed:

```go
func check() bool {
    true := false  // legal but flagged by go vet
    return true    // returns false
}

func check() bool {
    int := 5       // legal, not flagged by go vet
    return true
}
```

`go vet` flags shadowing of `true`, `false`, and `nil`. Shadowing the rest is not flagged.

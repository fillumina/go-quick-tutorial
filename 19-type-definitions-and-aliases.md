# 19 — Type Definitions and Aliases

Go creates named types from existing types with `type Name BaseType`. A type alias creates a synonym with `type Alias = BaseType`. The distinction is fundamental: a type definition creates a new type; an alias does not.

## Type Definition

`type Name BaseType` creates a new distinct type based on an existing type:

```go
type Celsius float64
type Fahrenheit float64
```

`Celsius` and `Fahrenheit` are distinct types. They cannot be assigned to each other without explicit conversion:

```go
var c Celsius = 20
var f Fahrenheit = c    // compile error: cannot use Celsius as Fahrenheit
f = Fahrenheit(c)       // OK, explicit conversion
```

Two type definitions based on the same underlying type are still distinct:

```go
type Seconds int
type Minutes int

var s Seconds = 5
var m Minutes = s    // compile error
m = Minutes(s)       // OK
```

### Methods on Named Types

A type definition enables adding methods to a primitive type:

```go
type Duration int64

func (d Duration) String() string {
    return fmt.Sprintf("%dms", d)
}

func (d Duration) Seconds() float64 {
    return float64(d) / 1000
}

d := Duration(500)
fmt.Println(d.String())    // 500ms
fmt.Println(d.Seconds())   // 0.5
```

A new type has no methods inherited from the base type. Methods must be defined on the new type explicitly.

## Type Alias

`type Alias = BaseType` creates a synonym — completely interchangeable with the base type in all contexts:

```go
type StringList = []string

func printList(list StringList) {
    for _, s := range list {
        fmt.Println(s)
    }
}

printList([]string{"a", "b"})  // OK, StringList is []string
```

Type aliases are used for renaming without creating a new type — useful for migration and clarity.

## Comparison

|                          | Type Definition              | Type Alias                    |
|--------------------------|------------------------------|-------------------------------|
| Creates new type         | Yes                          | No                            |
| Assignable to base type  | No (requires conversion)     | Yes                           |
| Can define methods       | Yes                          | No (methods go on base type)  |
| Satisfies interfaces     | Only if methods defined      | Same as base type             |

## Known Aliases

`byte` and `rune` (introduced in document 05) are aliases, not type definitions:

```go
byte  // alias for uint8
rune  // alias for int32
```

They are interchangeable with their base types. `var b byte` and `var b uint8` declare the same type.

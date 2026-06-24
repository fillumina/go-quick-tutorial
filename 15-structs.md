# 15 — Structs

A struct groups named fields into a composite type. Structs are Go's primary mechanism for organizing data, and they serve as the foundation for methods and embedding.

## Definition

```go
type Person struct {
    Name string
    Age  int
}
```

Field names that start with an uppercase letter are exported. Lowercase field names are unexported and accessible only within the same package.

## Initialization

Named fields are the preferred form — they are order-independent and self-documenting:

```go
p := Person{
    Name: "Alice",
    Age:  30,
}
```

Positional initialization also works but is fragile to field reordering:

```go
p := Person{"Alice", 30}
```

## Field Access

```go
p := Person{Name: "Alice", Age: 30}
fmt.Println(p.Name)  // Alice
p.Age = 31
```

## Anonymous Structs

Structs can be defined inline without a named type:

```go
config := struct {
    Host string
    Port int
}{
    Host: "localhost",
    Port: 8080,
}
```

Anonymous structs are used for ad-hoc data, JSON payloads, and test fixtures. Two anonymous struct types are identical only if they have exactly the same fields in the same order.

## Methods

A method is a function bound to a type:

```go
func (p Person) Greet() string {
    return fmt.Sprintf("Hi, I'm %s", p.Name)
}

p := Person{Name: "Alice", Age: 30}
fmt.Println(p.Greet())  // Hi, I'm Alice
```

### Receivers

A method uses a type as its receiver. A value receiver (`func (p Person)`) gets a copy; a pointer receiver (`func (p *Person)`) gets the address and can modify the original. The full explanation of value vs pointer receivers, including when to use each, is covered in document 16.

## Struct Embedding

A type included without a field name is embedded — its fields and methods are promoted to the outer struct:

```go
type Address struct {
    City    string
    Country string
}

func (a Address) Location() string {
    return fmt.Sprintf("%s, %s", a.City, a.Country)
}

type Person struct {
    Name    string
    Age     int
    Address // embedded
}

p := Person{
    Name: "Alice",
    Age:  30,
    Address: Address{
        City:    "London",
        Country: "UK",
    },
}

fmt.Println(p.City)        // London — promoted field
fmt.Println(p.Location())  // London, UK — promoted method
```

Embedding is Go's primary composition mechanism. It is not inheritance — the embedded type is not a subtype of the outer struct.

## Struct Tags

Tags are metadata attached to fields as backtick-delimited strings, read via reflection:

```go
type User struct {
    Name    string `json:"name"`
    Age     int    `json:"age,omitempty"`
    Email   string `json:"email" db:"user_email"`
    Password string `json:"-"`
}
```

Common tag keys include `json`, `xml`, `yaml`, and `db`. Multiple key-value pairs are space-separated within a tag. The `omitempty` option omits the field during serialization if it has the zero value. The `-` value skips the field entirely.

Tags are conventions, not enforced by the compiler. A package that reads tags defines its own format.

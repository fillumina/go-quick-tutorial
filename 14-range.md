# 14 — Range

`for..range` iterates over collections, yielding both an index and a value on each iteration. It is the primary way to traverse arrays, slices, maps, and strings.

## Arrays and Slices

Range over an array or slice yields the index and a copy of each element:

```go
names := []string{"Alice", "Bob", "Carol"}
for i, name := range names {
    fmt.Println(i, name)  // 0 Alice, 1 Bob, 2 Carol
}
```

Use the blank identifier to discard the index or value:

```go
for _, name := range names {
    fmt.Println(name)  // value only
}

for i := range names {
    fmt.Println(i)  // index only
}
```

## Range Creates Copies

The value returned by range is a copy of the element, not a reference. Mutating it does not mutate the underlying collection:

```go
scores := []int{1, 2, 3}
for i, score := range scores {
    score = score * 10  // modifies the copy, not the slice
}
fmt.Println(scores)  // [1 2 3], unchanged
```

To mutate elements, use the index. Omit the value variable to get only the index:

```go
for i := range scores {
    scores[i] = scores[i] * 10
}
fmt.Println(scores)  // [10 20 30]
```

## Maps

Range over a map yields key-value pairs. Iteration order is intentionally random on every run — do not write code that depends on a specific order:

```go
ages := map[string]int{"Alice": 30, "Bob": 25}
for name, age := range ages {
    fmt.Printf("%s is %d\n", name, age)  // order is random
}
```

## Strings

Range over a string yields runes (Unicode code points), not bytes. The index is the byte offset, not the rune position:

```go
for i, r := range "caf\u00e9 del mar" {
    fmt.Printf("%d %q\n", i, r)
    // 0 'c'
    // 1 'a'
    // 2 'f'
    // 3 'é'    (2 bytes in UTF-8)
    // 5 ' '    — byte offset jumped from 3 to 5
    // 6 'd'
    // 7 'e'
    // 8 'l'
    // ...
}
```

The precomposed é (U+00E9) occupies 2 bytes. After it, every subsequent byte offset is shifted by 1 compared to the rune position.

If the string contains invalid UTF-8, range substitutes the bad byte with the Unicode replacement character `U+FFFD` and continues — it does not panic:

```go
s := "hello\x80world"  // \x80 is invalid UTF-8
for _, r := range s {
    fmt.Printf("%c ", r)
}
// Output: h e l l o � w o r l d
```

To detect invalid UTF-8 rather than silently replacing it, use the `unicode/utf8` package.

Range over a channel receives values until the channel is closed. Covered in [document 22](22-channels.md).

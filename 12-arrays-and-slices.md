# 12 — Arrays and Slices

Go provides arrays for fixed-size sequences and slices for variable-length views over underlying arrays. Slices are the everyday sequence type.

## Arrays

An array has a fixed size that is part of its type. `[3]int` and `[4]int` are different types:

```go
var arr [3]int           // [0 0 0]
arr = [3]int{1, 2, 3}    // [1 2 3]
arr[0] = 10              // [10 2 3]
```

You can also use index-keyed (sparse) literals to set specific positions, leaving the rest as zero values:

```go
arr := [5]int{2: 10, 4: 20}  // [0 0 10 0 20]
```

Arrays are value types. Assigning or passing an array copies all elements:

```go
a := [3]int{1, 2, 3}
b := a       // full copy
b[0] = 99
fmt.Println(a)  // [1 2 3], unchanged
```

Arrays are rarely used directly. Their fixed size and copy semantics make them impractical for most use cases. They appear as the underlying storage for slices and in fixed-size data structures.

## Slices Are Views Over Arrays

A slice is a view over an underlying array. It does not own the data — it references a portion of an array with a starting index, a length, and a capacity. The slicing operator `arr[low:high]` creates a slice from an array:

```go
arr := [5]int{0, 1, 2, 3, 4}
s := arr[1:4]    // view over arr[1], arr[2], arr[3]
fmt.Println(s)   // [1 2 3]
```

Slice type syntax omits the size: `[]int` rather than `[5]int` which defines an array.

Omit `low` to start from 0, omit `high` to go to the end:

```go
arr[:3]   // [0 1 2]
arr[2:]   // [2 3 4]
arr[:]    // [0 1 2 3 4]
```

### Shared Underlying Array

A slice shares the underlying array. Mutations go both ways — changing the slice affects the array, and changing the array affects the slice:

```go
arr := [5]int{0, 1, 2, 3, 4}
s := arr[1:3]    // [1 2]

s[0] = 99
fmt.Println(arr)  // [0 99 2 3 4], slice modified the array

arr[2] = 77
fmt.Println(s)    // [99 77], array modified the slice
```

### Slicing a Slice

The same slicing syntax works on slices, producing another view over the same backing array:

```go
s := []int{0, 1, 2, 3, 4}
sub := s[1:4]    // [1 2 3]
sub2 := sub[1:3] // [2 3] — still views the same backing array
```

The shared-array behavior compounds: all three slices reference the same underlying data. A mutation through any of them is visible to the others.

### Slice Literals

A slice literal `[]int{1, 2, 3, 4, 5}` is shorthand that creates a backing array behind the scenes and returns a slice view over it. The array is not accessible — only the slice is:

```go
s := []int{1, 2, 3, 4, 5}
```

This is the most common way to create a slice. The view semantics are the same as slicing an array — the literal just hides the intermediate step.

### Make

`make` creates a slice with an explicit backing array of a given length and capacity. All elements are initialized to their zero value (0 for numbers, false for bools, "" for strings, nil for pointers and interfaces):

```go
s := make([]int, 5)          // [0 0 0 0 0], length 5, capacity 5
s := make([]int, 3, 10)      // [0 0 0], length 3, capacity 10
```

- **Length** is the number of elements accessible through the slice.

- **Capacity** is the total number of elements in the backing array from the slice's start — the available space for growth.

### Len and Cap

`len` and `cap` are language built-ins. With an array, both return the array's size:

```go
arr := [5]int{0, 1, 2, 3, 4}
len(arr)  // 5
cap(arr)  // 5
```

With a slice, they return the length and capacity:

```go
s := make([]int, 3, 10)
len(s)  // 3 — number of accessible elements
cap(s)  // 10 — total space in the backing array from the slice's start
```

For a sub-slice, capacity reflects the remaining room in the backing array:

```go
arr := [5]int{0, 1, 2, 3, 4}
s := arr[1:3]
len(s)  // 2 — elements 1 and 2
cap(s)  // 4 — elements 1 through 4 are reachable from the backing array
```

### Append

`append` adds elements to a slice and returns the updated slice:

```go
s := []int{1, 2}
s = append(s, 3)       // [1 2 3]
s = append(s, 4, 5)    // [1 2 3 4 5]
s = append(s, []int{6, 7}...)  // [1 2 3 4 5 6 7]
```

The original variable must be reassigned — `append` may allocate a new backing array when the slice has no remaining capacity (length equals capacity):

```go
s := []int{1, 2}
append(s, 3)    // s is still [1 2], the result was discarded
s = append(s, 3)  // s is now [1 2 3]
```

#### Appending to a Sub-Slice

When a sub-slice shares a backing array with the original and has spare capacity, `append` writes into that shared space — silently overwriting elements the original slice can see:

```go
s := []int{0, 1, 2, 3, 4}
sub := s[1:3]       // [1 2], capacity 4 (elements 1–4 of backing array)
sub = append(sub, 9)  // writes 9 into backing array at index 3
fmt.Println(s)       // [0 1 2 9 4], original silently modified
```

The append did not allocate a new array because the backing array had room. It wrote into the shared space, overwriting `s[3]`.

To prevent this, use the full slice expression `s[low:high:max]` to limit the sub-slice's capacity. Setting `max` equal to `high` leaves no room for growth, forcing `append` to allocate a new backing array:

```go
s := []int{0, 1, 2, 3, 4}
sub := s[1:3:3]      // [1 2], length 2, capacity 2 — no spare room
sub = append(sub, 9)  // must allocate new backing array
fmt.Println(s)        // [0 1 2 3 4], original unchanged
```

The third index (`max`) sets the capacity of the new slice to `max - low`. When capacity equals length, `append` has no choice but to grow into a new array.

### Copy

`copy` copies elements from a source slice to a destination slice:

```go
dst := make([]int, 3)
src := []int{1, 2, 3, 4, 5}
n := copy(dst, src)   // copies 3 elements, n == 3
fmt.Println(dst)      // [1 2 3]
```

`copy` handles overlapping slices correctly. It is also the standard way to detach a sub-slice from its backing array by creating a new slice and copying into it:

```go
s := []int{0, 1, 2, 3, 4}
attached := s[1:3]              // [1 2], shares backing array with s
detached := make([]int, len(attached))  // same length, all elements zero-valued
copy(detached, attached)                // fills detached with the values
detached[0] = 99
fmt.Println(s)                  // [0 1 2 3 4], original unchanged
```

### Nil Slice vs Empty Slice

```go
var s []int          // nil slice
s == nil             // true
len(s)               // 0

e := []int{}         // empty slice
e == nil             // false
len(e)               // 0
```

- `var s []int` declares a slice without a literal value, so it takes the zero value of its type — which for slices is `nil`. 

- `[]int{}` explicitly creates an empty slice with its own empty backing array.

Both have length 0 and behave identically in most operations. The difference matters when serializing to JSON: `json.Marshal` produces `null` for a nil slice and `[]` for an empty slice.

### String to Byte or Rune Slice

A string can be converted directly to `[]byte` (bytes) or `[]rune` (Unicode code points). Both conversions always allocate a copy — there is no zero-copy path. Modifying the slice does not affect the original string.

`[]byte(s)` iterates the string byte by byte:

```go
s := "hello"
b := []byte(s)    // [104 101 108 108 111]
```

`[]rune(s)` decodes the string as UTF-8 and produces one element per Unicode code point:

```go
s := "cafe\u0301"       // e with combining accent, 5 bytes
r := []rune(s)          // [99 97 102 101 769], 5 runes
```

These are the only two direct conversions from string to slice. Converting to other types (e.g., integers) requires the `strconv` package.

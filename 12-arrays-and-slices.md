# 12 — Arrays and Slices

Go provides arrays for fixed-size sequences and slices for variable-length views over underlying arrays. Slices are the everyday sequence type.

## Arrays

An array has a fixed size that is part of its type. `[3]int` and `[4]int` are different types:

```go
var arr [3]int           // [0 0 0]
arr = [3]int{1, 2, 3}    // [1 2 3]
arr[0] = 10              // [10 2 3]
```

Arrays are value types. Assigning or passing an array copies all elements:

```go
a := [3]int{1, 2, 3}
b := a       // full copy
b[0] = 99
fmt.Println(a)  // [1 2 3], unchanged
```

Arrays are rarely used directly. Their fixed size and copy semantics make them impractical for most use cases. They appear as the underlying storage for slices and in fixed-size data structures.

## Slices

A slice is a variable-length view over an underlying array:

```go
s := []int{1, 2, 3, 4, 5}
```

Slice type syntax omits the size: `[]int` rather than `[5]int`.

### Make

`make` creates a slice with explicit length and capacity:

```go
s := make([]int, 5)          // [0 0 0 0 0], length 5, capacity 5
s := make([]int, 3, 10)      // [0 0 0], length 3, capacity 10
```

Length is the number of elements accessible through the slice. Capacity is the number of elements in the underlying array from the slice's start index.

### Len and Cap

```go
s := make([]int, 3, 5)
len(s)   // 3
cap(s)   // 5
```

### Append

`append` adds elements to a slice and returns a new slice header:

```go
s := []int{1, 2}
s = append(s, 3)       // [1 2 3]
s = append(s, 4, 5)    // [1 2 3 4 5]
s = append(s, []int{6, 7}...)  // [1 2 3 4 5 6 7]
```

The original variable must be reassigned — `append` may allocate a new underlying array when the current one is full:

```go
s := []int{1, 2}
append(s, 3)    // s is still [1 2], the result was discarded
s = append(s, 3)  // s is now [1 2 3]
```

### Slicing

`s[low:high]` returns a slice from index `low` to `high-1`:

```go
s := []int{0, 1, 2, 3, 4}
sub := s[1:4]    // [1 2 3]
```

Omit `low` to start from 0, omit `high` to go to the end:

```go
s[:3]   // [0 1 2]
s[2:]   // [2 3 4]
s[:]    // [0 1 2 3 4]
```

### Shared Underlying Array

A sub-slice shares the underlying array with the original. Mutations through one slice affect the other:

```go
s := []int{0, 1, 2, 3, 4}
sub := s[1:3]    // [1 2]
sub[0] = 99
fmt.Println(s)   // [0 99 2 3 4], original is modified
```

To avoid shared mutations, copy the slice:

```go
s := []int{0, 1, 2, 3, 4}
sub := make([]int, len(s[1:3]))
copy(sub, s[1:3])
sub[0] = 99
fmt.Println(s)   // [0 1 2 3 4], original unchanged
```

### Copy

`copy` copies elements from a source slice to a destination slice:

```go
dst := make([]int, 3)
src := []int{1, 2, 3, 4, 5}
n := copy(dst, src)   // copies 3 elements, n == 3
fmt.Println(dst)      // [1 2 3]
```

`copy` handles overlapping slices correctly.

### Nil Slice vs Empty Slice

```go
var s []int          // nil slice, length 0
s := []int{}         // empty slice, not nil, length 0
```

Both have length 0 and behave identically in most operations. The difference matters when serializing to JSON: `json.Marshal` produces `null` for a nil slice and `[]` for an empty slice.

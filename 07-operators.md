# 08 — Operators

Go provides arithmetic, comparison, logical, bitwise, and assignment operators. Operator precedence follows standard C-like rules.

## Arithmetic

```go
sum := 10 + 3       // 13
diff := 10 - 3      // 7
product := 10 * 3   // 30
quotient := 10 / 3  // 3 (integer division truncates toward zero)
remainder := 10 % 3 // 1
```

Integer division truncates toward zero: `7 / 2` is `3`, `-7 / 2` is `-3`.

The `%` operator returns the remainder. The sign of the result matches the dividend, not the divisor:

```go
10 % 3    // 1
-10 % 3   // -1
10 % -3   // 1
-10 % -3  // -1
```

## Increment and Decrement

`++` and `--` are statements, not expressions. They cannot be used as a value:

```go
i := 5
i++       // OK, statement
fmt.Println(i)  // 6

j := i++  // compile error: i++ is a statement, not an expression
```

This differs from C, Java, and C++, where `i++` returns the pre-increment value.

## Comparison

```go
5 == 5    // true
5 != 3    // true
5 < 10    // true
5 <= 5    // true
5 > 2     // true
5 >= 5    // true
```

Structs and arrays are comparable field-by-field:

```go
type Point struct {
    X, Y int
}

a := Point{1, 2}
b := Point{1, 2}
fmt.Println(a == b)  // true
```

Slices, maps, and functions are not comparable with `==` — it is a compile error. Use `reflect.DeepEqual` or `slices.Equal` instead.

## Logical

```go
true && false   // false
true || false   // true
!true           // false
```

Logical operators use short-circuit evaluation: `false && expr` does not evaluate `expr`, and `true || expr` does not evaluate `expr`.

## Bitwise

```go
a := 12  // 1100 in binary
b := 10  // 1010 in binary

a & b    // 8   (1000) — bitwise AND
a | b    // 14  (1110) — bitwise OR
a ^ b    // 6   (0110) — bitwise XOR
a &^ b   // 2   (0010) — bit clear (a AND NOT b)
a << 2   // 48  (110000) — left shift
a >> 1   // 6   (0110) — right shift
```

The `&^` (bit clear) operator is unique to Go. It clears the bits set in the right operand from the left operand:

```go
flags := Read | Write | Execute   // 7 (111)
flags = flags &^ Execute          // 3 (011) — Execute cleared
```

## Assignment

```go
x = 5
x += 3    // x = x + 3
x -= 2    // x = x - 2
x *= 4    // x = x * 4
x /= 2    // x = x / 2
x %= 3    // x = x % 3
x &= 0xF  // x = x & 0xF
x |= 0x1  // x = x | 0x1
x ^= 0x5  // x = x ^ 0x5
x &^= 0x2 // x = x &^ 0x2
x <<= 1   // x = x << 1
x >>= 1   // x = x >> 1
```

## Precedence

Operator precedence from highest to lowest:

```
x *     x /     x %     x <<    x >>    x &     x &^
x +     x -     x |     x ^
x ==    x !=    x <     x <=    x >     x >=
x &&
x ||
```

Within each level, operators are left-to-right. Parentheses override precedence.

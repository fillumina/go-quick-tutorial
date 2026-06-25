# 22 — Channels

Accessing shared variables from multiple goroutines causes race conditions. Channels solve this by passing values between goroutines instead of sharing memory. They are the synchronization mechanism in Go's concurrency model.

## Declaration and Creation

`chan T` is a channel that carries values of type `T`. The zero value of a channel is `nil`:

```go
var ch chan int  // nil channel
```

A nil channel blocks on all operations — sends and receives hang forever. It is effectively a channel that can never complete an operation:

```go
var ch chan int  // nil

go func() {
    ch <- 42  // blocks forever
}()

<-ch  // blocks forever
```

`make()` creates a usable channel. It takes a type and an optional capacity:

```go
ch := make(chan int)       // unbuffered channel
ch := make(chan int, 10)   // buffered channel, capacity 10
```

## Send and Receive

Both send and receive use the `<-` operator. The difference is the position of the channel name: on the left for send, on the right for receive.

Send puts a value into a channel. The value can be a variable, literal, or expression:

```go
ch <- 42         // channel on the left — send
ch <- x + y
ch <- compute()
```

Receive reads a value from a channel and assigns it to a variable:

```go
value := <-ch    // channel on the right — receive
```

Both operations block until the other side is ready. A send waits until a receiver is available to consume the value. A receive waits until a value is available to read.

## Directional Channels

`chan<- T` (send-only) and `<-chan T` (receive-only) are proper channel types that restrict a channel to either sending or receiving. They are compatible with the bidirectional type `chan T`, so a normal channel can be assigned to a send-only or receive-only variable. They can be used as variable types, struct fields, and anywhere a type is expected:

```go
var sendCh chan<- int   // send-only variable
var recvCh <-chan int   // receive-only variable

sendCh <- 42            // OK
<-sendCh                // compile error

<-recvCh                // OK
recvCh <- 42            // compile error
```

A bidirectional channel (`chan T`) converts to either directional type. A directional channel cannot convert back:

```go
ch := make(chan int)
var sendCh chan<- int = ch   // OK
var recvCh <-chan int = ch   // OK
```

They are most commonly used in function signatures to restrict what a caller can do with a channel:

```go
func producer(sendCh chan<- int) {  // send-only
    sendCh <- 42
}

func producer() <-chan int {        // returns receive-only
    ch := make(chan int)
    go func() { ch <- 42 }()
    return ch
}
```

## Unbuffered Channels

An unbuffered channel blocks both send and receive until the other side is ready — this is the synchronization mechanism:

```go
ch := make(chan int)

go func() {
    fmt.Println("sending")
    ch <- 42
    fmt.Println("sent")
}()

fmt.Println("waiting")
value := <-ch
fmt.Println("received", value)
```

The send blocks until the receive is ready. The receive blocks until the send is ready. They synchronize at the channel operation.

## Buffered Channels

A buffered channel sends block only when the buffer is full and receives block only when empty:

```go
ch := make(chan int, 2)

ch <- 1   // OK, buffer has space
ch <- 2   // OK, buffer full
ch <- 3   // blocks, buffer is full

<-ch      // unblocks the send
```

## Close

`close(ch)` signals that no more values will be sent. A receive from a channel returns two values: the received value and a boolean `ok` that is `true` if the channel is open and `false` after the last buffered item has been consumed from a closed channel. This lets the receiver detect when the sender is done:

```go
ch := make(chan int)

go func() {
    ch <- 1
    ch <- 2
    ch <- 3
    close(ch)
}()

for {
    value, ok := <-ch
    if !ok {
        break  // channel closed, no more values
    }
    fmt.Println(value)  // 1, 2, 3
}
```

Sending on a closed channel panics. Receiving from a closed channel does not — it returns immediately, either with a buffered value or with the zero value and `ok = false`.

## Range over Channels

`for..range` on a channel receives values until the channel is closed. It is the idiomatic shorthand for the close-and-drain pattern shown above:

```go
for value := range ch {
    fmt.Println(value)
}
// loop exits when the channel is closed and drained
```

The loop blocks on each iteration waiting for the next value. It only terminates when the sender calls `close(ch)` and all remaining values have been received. A channel that is never closed will cause the loop to block forever.

You can discard the value with the blank identifier if you only need to wait for the channel to close:

```go
for range doneCh {
    // process signals
}
// exits when doneCh is closed
```

## Select

`select` waits on multiple channel send and receive operations simultaneously:

```go
select {
case msg := <-ch1:  // receive
    fmt.Println("from ch1:", msg)
case msg := <-ch2:  // receive
    fmt.Println("from ch2:", msg)
case ch3 <- 42:     // send
    fmt.Println("sent to ch3")
}
```

If multiple cases are ready, `select` chooses one at random. If none are ready, it blocks.

### Select with Default

A `default` case makes `select` non-blocking:

```go
select {
case msg := <-ch:
    fmt.Println("received:", msg)
default:
    fmt.Println("no message available")
}
```

### Select with Timeout

```go
select {
case msg := <-ch:
    fmt.Println("received:", msg)
case <-time.After(5 * time.Second):
    fmt.Println("timed out")
}
```

`time.After` returns a channel that receives the current time after the duration elapses.

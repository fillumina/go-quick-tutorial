# 22 — Channels

Channels pass values between goroutines. They are the synchronization mechanism in Go's concurrency model.

## Declaration and Creation

`chan T` is a channel that carries values of type `T`:

```go
ch := make(chan int)       // unbuffered channel
ch := make(chan int, 10)   // buffered channel, capacity 10
```

Directional channels enforce send-only or receive-only in function signatures:

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

## Send and Receive

```go
ch <- value    // send
value := <-ch  // receive
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

`close(ch)` signals that no more values will be sent:

```go
ch := make(chan int)

go func() {
    for i := 1; i <= 3; i++ {
        ch <- i
    }
    close(ch)
}()

for value := range ch {
    fmt.Println(value)  // 1, 2, 3
    // loop ends when channel is closed
}
```

Receiving from a closed channel returns the zero value with `ok = false`:

```go
value, ok := <-ch
if !ok {
    // channel is closed and drained
}
```

Sending on a closed channel panics. Receiving from a closed channel does not.

## Range over Channels

`for..range` on a channel receives values until the channel is closed. It is the idiomatic way to consume all values from a channel:

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

`select` waits on multiple channel operations simultaneously:

```go
select {
case msg := <-ch1:
    fmt.Println("from ch1:", msg)
case msg := <-ch2:
    fmt.Println("from ch2:", msg)
case ch3 <- 42:
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

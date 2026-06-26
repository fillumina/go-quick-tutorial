# 30 — Logging

Go provides two logging packages: `log` (simple, text-based) and `log/slog` (structured, Go 1.21+). Use `log` for scripts, CLI tools, and simple programs. Use `slog` for services, libraries, and any code where logs are parsed by tools. Both write to `os.Stderr` by default.

## Log

The `log` package writes timestamped text lines to `os.Stderr`. It has no concept of log levels — just formatting variants and a fatal variant that exits:

```go
log.Print("message")         // fmt.Sprint-style (no spaces between args)
log.Println("message")       // fmt.Sprintln-style (spaces between args)
log.Printf("count: %d", 42)   // fmt.Sprintf-style (format string)
```

All three add a trailing newline to the output line. The difference is how arguments are formatted, following the same pattern as `fmt.Print`/`Println`/`Printf`.

`log.Fatal` (and `Fatalf`, `Fatalln`) prints and calls `os.Exit(1)`. It runs deferred functions before exiting, so deferred cleanup still executes:

```go
log.Fatal("cannot start server")      // prints and exits
log.Fatalln("cannot start server")    // prints with newline and exits
log.Fatalf("failed to open %s: %v", path, err)  // formatted, exits
```

The default logger writes to `os.Stderr` with a timestamp and newline. You can customize output with `log.SetPrefix`, `log.SetFlags`, or create a custom logger with `log.New`:

```go
logger := log.New(os.Stdout, "DEBUG: ", log.Ldate|log.Ltime)
logger.Println("custom output")
```

`SetPrefix` and `SetFlags` modify the default logger globally:

```go
log.SetPrefix("myapp: ")
log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
log.Println("error occurred")
// Output: myapp: 2024-01-15 10:30:00 main.go:42: error occurred
```

The `Ldate`, `Ltime`, `Lmicroseconds`, `Llongfile`, and `Lshortfile` flags control what appears before the message. Combine with `|`. The default is `Ldate | Ltime | Lmicroseconds`.

## Slog

`log/slog` (Go 1.21+) produces structured logs — each record carries a level, message, and key-value attributes. It is the idiomatic logging approach for new code:

```go
slog.Info("server started", "addr", ":8080", "version", "1.2.3")
slog.Warn("slow query", "duration", 1200*time.Millisecond)
slog.Error("connection failed", "err", err)
```

Output is structured text by default (parseable by tools):

```
time=2024-01-15T10:30:00Z level=INFO msg="server started" addr=":8080" version="1.2.3"
```

### Handler

The handler controls output format. There are 2 handlers in the standard libriary:

- `slog.NewTextHandler` writes structured text;

- `slog.NewJSONHandler` writes JSON.

Both take an `io.Writer` and optional `*slog.HandlerOptions` (pass `nil` for defaults):

```go
textHandler := slog.NewTextHandler(os.Stdout, nil)
textLogger := slog.New(textHandler)
textLogger.Info("text handler output")
// time=2024-01-15T10:30:00Z level=INFO msg="text handler output"

jsonHandler := slog.NewJSONHandler(os.Stdout, nil)
jsonLogger := slog.New(jsonHandler)
jsonLogger.Info("structured JSON output")
// {"time":"2024-01-15T10:30:00Z","level":"INFO","msg":"structured JSON output"}
```

Make a logger the process-wide default with `slog.SetDefault(logger)`. After calling it, the package-level functions `slog.Info()`, `slog.Warn()`, `slog.Error()` use your configured logger instead of the built-in default.

### HandlerOptions

`HandlerOptions` configures a handler. It has three fields:

- **`Level`** — minimum log level. Four levels exist, from lowest to highest severity: `DEBUG` (-4), `INFO` (0), `WARN` (4), `ERROR` (8). The default minimum is `INFO` — `DEBUG` messages are discarded.
- **`AddSource`** — when `true`, adds file and line number to each log entry.
- **`ReplaceAttr`** — function to transform attributes before output (advanced, rarely used).

```go
opts := &slog.HandlerOptions{
    Level:     slog.LevelDebug,
    AddSource: true,
}
debugHandler := slog.NewTextHandler(os.Stdout, opts)
debugLogger := slog.New(debugHandler)
debugLogger.Debug("only visible with LevelDebug")
debugLogger.Info("always visible")
```

The idiomatic form passes the options inline: `slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug})`.

### With

`With` attaches attributes to every subsequent log from a logger, avoiding repetition:

```go
logger := slog.With("requestID", req.ID)
logger.Info("received request")
logger.Info("processing")
logger.Info("response sent")
```

Each call inherits the `requestID` attribute. `With` returns a new logger — it does not modify the original.

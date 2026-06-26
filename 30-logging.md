# 30 — Logging

Go provides two logging packages: `log` (simple, text-based) and `log/slog` (structured, Go 1.21+). Real code uses both — `log` for scripts and small programs, `slog` for services and libraries.

## Log

The `log` package writes timestamped text lines. Three levels of severity:

```go
log.Println("info message")           // prints with timestamp
log.Printf("count: %d", 42)           // formatted, with timestamp
log.Fatal("cannot start server")      // prints and calls os.Exit(1)
```

`log.Fatal` (and `log.Fatalf`, `log.Fatalln`) always exits. It runs any deferred functions before exiting, so deferred cleanup still executes.

The default logger writes to `os.Stderr` with a timestamp and newline. You can customize output with `log.SetPrefix`, `log.SetFlags`, or create a custom logger with `log.New`:

```go
logger := log.New(os.Stdout, "DEBUG: ", log.Ldate|log.Ltime)
logger.Println("custom output")
```

The `Ldate`, `Ltime`, `Lmicroseconds`, `Llongfile`, and `Lshortfile` flags control what appears in the timestamp. Combine with `|`.

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

### Log Levels

Six levels, from lowest to highest severity: `DEBUG`, `INFO`, `WARN`, `ERROR`, and the less-used `TRACE` and `FATAL`. The default minimum level is `INFO` — `DEBUG` messages are discarded. Set a lower threshold to see them:

```go
slog.SetLogLoggerLevel(slog.LevelDebug)
```

### Context With

`With` attaches attributes to every subsequent log from a logger, avoiding repetition:

```go
logger := slog.With("requestID", req.ID)
logger.Info("received request")
logger.Info("processing")
logger.Info("response sent")
```

Each call inherits the `requestID` attribute. `With` returns a new logger — it does not modify the original.

### Handler

The handler controls output format. The default writes structured text. `slog.NewJSONHandler` writes JSON:

```go
import "io"

jsonHandler := slog.NewJSONHandler(os.Stdout, nil)
jsonLogger := slog.New(jsonHandler)
jsonLogger.Info("structured JSON output")
```

Output:

```
{"time":"2024-01-15T10:30:00Z","level":"INFO","msg":"structured JSON output"}
```

### Slog vs Log

Use `log` for scripts, CLI tools, and simple programs. Use `slog` for services, libraries, and any code where logs are parsed by tools. `slog` is backward compatible — it writes to `os.Stderr` by default, just like `log`.

# Layer 4 · Topic 13 — Async Programming

> How each language enables high-concurrency I/O without one OS thread per task — Rust's zero-cost stackless coroutines compiled to state machines, Java's virtual threads (Project Loom) that make blocking code scalable, and Python's `asyncio` coroutines evolved from generators. Builds directly on concurrency and parallelism — same problems, different execution model.

---

## 1. Async Model Fundamentals

The core problem async programming solves: handling thousands of concurrent I/O operations (network requests, database queries, file reads) without dedicating one OS thread per operation. OS threads are expensive — each consumes 2–8 MB of stack memory and incurs context-switch overhead. With 10,000 concurrent connections, that's 20–80 GB of stack memory alone. Async programming provides lightweight alternatives that achieve the same concurrency with orders-of-magnitude less resource consumption.

### Rust: Stackless Coroutines and Lazy Futures

Rust's async model is based on **stackless coroutines** — `async fn` is compiled into a state machine that implements the `Future` trait. Unlike OS threads, futures do not own a stack; they store only the local variables needed across `await` points. This means thousands of concurrent tasks can exist with minimal memory overhead (each future is typically a few hundred bytes).

```rust
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

// async fn is compiled into a state machine implementing Future
async fn handle_client(mut socket: tokio::net::TcpStream) {
    let mut buf = [0u8; 1024];
    loop {
        let n = match socket.read(&mut buf).await {
            Ok(0) => return,  // connection closed
            Ok(n) => n,
            Err(_) => return,
        };
        // Echo back
        if socket.write_all(&buf[..n]).await.is_err() {
            return;
        }
    }
}

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:8080").await.unwrap();
    loop {
        let (socket, _) = listener.accept().await.unwrap();
        // spawn a lightweight task — not an OS thread
        tokio::spawn(handle_client(socket));
    }
}
```

Key concepts:

- **Lazy futures** — Rust futures do nothing until polled. Creating a future does not start executing it. This contrasts with most other languages where creating a task immediately starts executing it.
- **No built-in runtime** — the executor (Tokio, async-std, smol) is not part of the standard library. The `Future` trait is in stdlib; the runtime is in the ecosystem. This separation is unique to Rust.
- **Zero-cost abstraction** — the generated state machine is at least as efficient as a hand-written one. No heap allocation required for the future itself unless explicitly boxed.
- **Compile-time safety** — `Send` and `Sync` bounds on tasks ensure thread safety at compile time. If a future captures a non-`Send` type, it cannot be spawned on a multi-threaded runtime.

> **Sources:** Gjengset (2022) Ch.8 pp. 117–121 · Matthews (2024) Ch.8 pp. 157–161 · [The Rust Async Book — "Why Async?"](https://rust-lang.github.io/async-book/01_getting_started/01_chapter.html) · [Rust RFC 2394 — `async`/`await` notation](https://rust-lang.github.io/rfcs/2394-async_await.html)

### Java: Virtual Threads (Project Loom)

Java's async story spans three eras. Era 1 (Java 1.0–4): one OS thread per task, limited scalability. Era 2 (Java 5–20): `ExecutorService` + `Future` + `CompletableFuture` — thread pools manage concurrency but callbacks create complexity; reactive frameworks (RxJava, Reactor) provide async I/O with steep learning curves. Era 3 (Java 21+): **virtual threads** (JEP 444) — lightweight threads scheduled by the JVM on carrier threads, making blocking code scalable without callbacks.

```java
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.net.ServerSocket;
import java.net.Socket;

public class AsyncServer {
    public static void main(String[] args) throws Exception {
        // Virtual thread executor — each task gets its own virtual thread
        try (var executor = Executors.newVirtualThreadPerTaskExecutor();
             var server = new ServerSocket(8080)) {
            while (true) {
                Socket socket = server.accept();
                // submit spawns a virtual thread — not an OS thread
                executor.submit(() -> handleClient(socket));
            }
        }
    }

    static void handleClient(Socket socket) {
        // Plain blocking code — but runs on a virtual thread,
        // so blocking calls (read/write) yield the carrier thread
        try (socket;
             var in = socket.getInputStream();
             var out = socket.getOutputStream()) {
            byte[] buf = new byte[1024];
            int n;
            while ((n = in.read(buf)) != -1) {
                out.write(buf, 0, n);
            }
        } catch (Exception e) {
            // handle error
        }
    }
}
```

Key concepts:

- **Virtual threads are stackful** — each virtual thread has its own stack, managed by the JVM rather than the OS. When a virtual thread blocks, the JVM unmounts its stack from the carrier (platform) thread and mounts another virtual thread.
- **Transparent blocking** — `Thread.sleep()`, `socket.read()`, `lock.lock()` all suspend the virtual thread without blocking the carrier thread. Existing code and libraries benefit automatically.
- **No new syntax** — Java deliberately chose NOT to add `async`/`await`. Virtual threads make blocking code effectively async. This is a philosophical choice: make existing code scalable rather than requiring new programming patterns.
- **Hidden costs of platform threads** — each platform thread consumes ~1 MB stack by default, requires OS scheduling, and has context-switch overhead of ~1–10 μs. Virtual threads reduce this to ~hundreds of bytes of heap memory per suspended thread.

> **Sources:** Rahman (2025) Ch.1 pp. 1–30 · Rahman (2025) Ch.2 pp. 31–51 · Lea (1999) Ch.4 pp. 291–310 · [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444) · [Project Loom wiki](https://wiki.openjdk.org/display/loom/Main)

### Python: `asyncio` Coroutines

Python's async model evolved from generators. PEP 255 (Python 2.2) introduced `yield`, PEP 342 (Python 2.5) added `send()` to generators (creating "classic coroutines"), PEP 380 (Python 3.3) added `yield from` for coroutine delegation, and PEP 492 (Python 3.5) introduced `async`/`await` as first-class syntax. Native coroutines are stackless — execution state is saved in the coroutine frame when suspended.

```python
import asyncio

async def handle_client(reader: asyncio.StreamReader,
                        writer: asyncio.StreamWriter):
    """Each connection is a coroutine — not an OS thread."""
    while True:
        data = await reader.read(1024)
        if not data:
            break
        writer.write(data)
        await writer.drain()
    writer.close()
    await writer.wait_closed()

async def main():
    server = await asyncio.start_server(handle_client, '127.0.0.1', 8080)
    async with server:
        await server.serve_forever()

asyncio.run(main())
```

Key concepts:

- **Single-threaded event loop** — all coroutines share one OS thread by default. This is both a simplification (no data races between coroutines) and a limitation (CPU-bound work blocks the event loop).
- **Guido's trick** — to understand async code, mentally remove `async` and `await` keywords and read it as synchronous code. The control flow is the same.
- **GIL interaction** — the GIL prevents true parallel execution of Python bytecode. Coroutines cooperatively yield at `await` points, and since only one coroutine runs at a time, shared state between coroutines is safe without locks.
- **Restaurant analogy** — a single waiter (event loop) serves many tables (connections) by taking orders, delivering food, and clearing plates in interleaved fashion. One waiter can handle many tables efficiently if no single task takes too long.

> **Sources:** Ramalho (2022) Ch.19 pp. 695–711 · Ramalho (2022) Ch.21 pp. 775–781 · Hattingh (2020) Ch.1 pp. 1–8 · Hattingh (2020) Ch.2 pp. 9–20 · [PEP 492 — Coroutines with async and await syntax](https://peps.python.org/pep-0492/) · [PEP 3156 — Asynchronous I/O Support Rebooted: the "asyncio" Module](https://peps.python.org/pep-3156/) · [Python docs — asyncio](https://docs.python.org/3/library/asyncio.html)

### Cross-Language Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Coroutine type** | Stackless | Stackful (virtual threads) | Stackless |
| **Eagerness** | Lazy (does nothing until polled) | Eager (starts on spawn) | Eager when wrapped in `Task` |
| **Runtime** | External (Tokio, async-std) | Built into JVM | stdlib `asyncio` |
| **Special syntax** | `async`/`.await` | None (blocking code just works) | `async`/`await` |
| **Thread safety** | Compile-time (`Send`/`Sync`) | Runtime (JVM manages) | N/A (single-threaded) |
| **Memory per 10K tasks** | ~MB total | ~tens of MB | ~MB total |
| **Memory per 10K OS threads** | 20–80 GB | 20–80 GB | 20–80 GB |

The fundamental design tradeoff: Rust optimizes for zero overhead (no runtime, no allocations for futures), Java optimizes for developer ergonomics (write blocking code, get async behavior), Python optimizes for simplicity (single-threaded, no data races).

---

## 2. Future Trait and Future Types

The `Future` abstraction encodes a value that is not yet available. Each language takes a different approach: Rust uses a poll-based trait (the executor drives the future), Java uses callback-based `CompletableFuture` (completion triggers downstream actions), and Python uses the awaitable protocol (the event loop drives coroutines via `__await__`).

### Rust: The `Future` Trait and Poll-Based Execution

Rust's `Future` trait has a single method: `poll()`. This is a **pull-based** model — the executor calls `poll()` on the future, and the future reports whether it is ready or still pending.

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};

// A simple future that completes after a delay
struct Delay {
    when: Instant,
}

impl Future for Delay {
    type Output = ();

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        if Instant::now() >= self.when {
            Poll::Ready(())
        } else {
            // Register the waker so we get polled again
            let waker = cx.waker().clone();
            let when = self.when;
            std::thread::spawn(move || {
                std::thread::sleep(when - Instant::now());
                waker.wake();  // signal the executor to poll again
            });
            Poll::Pending
        }
    }
}

// Using the future with async/await
async fn example() {
    let delay = Delay {
        when: Instant::now() + Duration::from_secs(1),
    };
    delay.await;  // the executor polls Delay until it returns Ready
    println!("One second has passed");
}
```

Key concepts:

- **`Poll::Ready(value)`** — the future has completed with this value.
- **`Poll::Pending`** — the future is not ready; it has registered a `Waker` to be notified when it should be polled again.
- **`Waker` mechanism** — the future stores the waker from `Context` and calls `waker.wake()` when progress can be made. This avoids busy-polling — the executor only polls when something has changed.
- **Zero-cost** — no heap allocation required for the future itself. The state machine is stored inline. No reference counting, no garbage collection.
- **Inversion of control** — the executor drives the future (pull-based), rather than the future scheduling callbacks (push-based). This is the opposite of Java's `CompletableFuture`.

> **Sources:** Gjengset (2022) Ch.8 pp. 121–126 · [Rust docs — `std::future::Future`](https://doc.rust-lang.org/std/future/trait.Future.html) · [Rust docs — `std::task::Poll`](https://doc.rust-lang.org/std/task/enum.Poll.html) · [Rust docs — `std::task::Context` and `Waker`](https://doc.rust-lang.org/std/task/struct.Context.html) · [The Rust Async Book — "The Future Trait"](https://rust-lang.github.io/async-book/02_execution/02_future.html)

### Java: `Future`, `CompletableFuture`, and Composability

Java has two `Future` types reflecting its evolution from blocking to callback-based to virtual-thread-based concurrency.

```java
import java.util.concurrent.*;

public class FutureExamples {

    // Era 1: java.util.concurrent.Future — blocking handle
    static void classicFuture() throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(4);
        Future<String> future = pool.submit(() -> {
            Thread.sleep(1000);
            return "result";
        });
        // get() blocks the calling thread until result is available
        String result = future.get();  // blocks here
        System.out.println(result);
        pool.shutdown();
    }

    // Era 2: CompletableFuture — callback composition
    static void completableFuture() {
        CompletableFuture.supplyAsync(() -> fetchUser(42))
            .thenApply(user -> user.getName())        // map
            .thenCompose(name -> fetchOrders(name))    // flatMap
            .thenCombine(
                CompletableFuture.supplyAsync(() -> fetchDiscount()),
                (orders, discount) -> applyDiscount(orders, discount)
            )
            .exceptionally(ex -> fallbackOrders())     // error recovery
            .thenAccept(orders -> System.out.println(orders));
    }

    // Era 3: Virtual threads — blocking is cheap again
    static void virtualThreadFuture() throws Exception {
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            Future<String> future = executor.submit(() -> {
                Thread.sleep(1000);  // yields carrier thread, not OS thread
                return "result";
            });
            String result = future.get();  // blocking is fine on virtual thread
            System.out.println(result);
        }
    }
}
```

Key concepts:

- **`Future` (Java 5)** — a blocking handle: `get()` blocks until the result is available, `cancel()` requests cancellation, `isDone()` checks completion. Simple but limited — no composition.
- **`CompletableFuture` (Java 8)** — push-based callback composition: `thenApply()` (map), `thenCompose()` (flatMap), `thenCombine()` (zip), `allOf()` (join all), `exceptionally()` (recover). Over 50 methods for combining asynchronous operations.
- **Philosophical reversal** — Java spent years building `CompletableFuture` to avoid blocking, then virtual threads made blocking cheap again. With virtual threads, `Future.get()` is now acceptable for most use cases, reducing the need for callback chains.

> **Sources:** Goetz (2006) Ch.6 pp. 113–123 · Evans et al (2022) Ch.6 pp. 197–205 · Rahman (2025) Ch.3 pp. 101–103 · [Java docs — `Future`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Future.html) · [Java docs — `CompletableFuture`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CompletableFuture.html) · [Baeldung — Guide to CompletableFuture](https://www.baeldung.com/java-completablefuture)

### Python: Awaitables and the Coroutine Protocol

In Python, an "awaitable" is any object with an `__await__` method returning an iterator. Three things are awaitable: coroutine objects (from `async def`), `asyncio.Task` objects, and `asyncio.Future` objects.

```python
import asyncio

# Coroutine — the most common awaitable
async def fetch_data(url: str) -> str:
    await asyncio.sleep(1)  # simulate I/O
    return f"data from {url}"

# Task — wraps a coroutine and schedules it on the event loop
async def concurrent_fetch():
    # create_task schedules the coroutine for concurrent execution
    task1 = asyncio.create_task(fetch_data("url1"))
    task2 = asyncio.create_task(fetch_data("url2"))

    # Both tasks run concurrently while we await
    result1 = await task1
    result2 = await task2
    return result1, result2

# asyncio.Future — low-level callback primitive (rarely used directly)
async def low_level_example():
    loop = asyncio.get_event_loop()
    future = loop.create_future()

    # Simulate something setting the result later
    loop.call_later(1.0, future.set_result, "done")

    result = await future  # suspends until set_result is called
    return result

# gather — run multiple awaitables concurrently
async def gather_example():
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        fetch_data("url3"),
    )
    return results  # list of results in order
```

Key concepts:

- **Three kinds of awaitables** — coroutines (`async def`), tasks (`asyncio.create_task`), and futures (`asyncio.Future`). User code primarily uses coroutines and tasks.
- **`asyncio.Future`** is a low-level callback-based primitive similar to `CompletableFuture`. User code rarely creates these directly.
- **`asyncio.Task`** wraps a coroutine and schedules it on the event loop. Unlike a bare coroutine, a task starts executing immediately when created.
- **The "all-or-nothing" problem** — you cannot `await` in a regular function. If any function in a call chain needs to `await`, every caller up to the event loop must be `async def`. This is the colored function problem in action.

> **Sources:** Ramalho (2022) Ch.21 pp. 781–785 · Slatkin (2025) Item 75 pp. 364–368 · Hattingh (2020) Ch.3 pp. 33–42 · [Python docs — `asyncio.Future`](https://docs.python.org/3/library/asyncio-future.html) · [Python docs — Awaitables](https://docs.python.org/3/library/asyncio-task.html#awaitables) · [Python docs — `concurrent.futures`](https://docs.python.org/3/library/concurrent.futures.html)

### Cross-Language Comparison

| Aspect | Rust `Future` | Java `CompletableFuture` | Python `asyncio.Future`/`Task` |
|--------|---------------|--------------------------|-------------------------------|
| **Model** | Pull-based (executor polls) | Push-based (callbacks on completion) | Pull-based at protocol level |
| **Eagerness** | Lazy (nothing until polled) | Eager (starts immediately) | Eager when wrapped in `Task` |
| **Allocation** | Stack-allocated (zero-cost) | Heap-allocated | Heap-allocated |
| **Cancellation** | Drop the future | `cancel()` method | `cancel()` raises `CancelledError` |
| **Composition** | Combinators via `FutureExt` | 50+ built-in methods | `gather`, `wait`, `as_completed` |
| **Error handling** | `Result<T, E>` in `Output` | `exceptionally`, `handle` | Exception propagation |

Rust's design is unique in making the future itself a value type that can be composed without allocation. Java's `Future.get()` is synchronous blocking while Python `await future` is asynchronous suspension — the syntax looks different but the semantic intent (wait for a result) is the same.

---

## 3. Runtime Architecture

Between the `Future`/coroutine and the operating system sits the runtime — the scheduler, I/O driver, and timer that coordinate async task execution. Each language takes a fundamentally different approach to this layer.

### Rust: Tokio Runtime Internals

Tokio is a multi-threaded runtime with three core components: the task scheduler, the I/O driver, and the timer.

```rust
use tokio::sync::mpsc;
use tokio::time::{sleep, Duration};

// #[tokio::main] creates a multi-threaded runtime
// Equivalent to:
//   let rt = tokio::runtime::Runtime::new().unwrap();
//   rt.block_on(async { ... })
#[tokio::main]
async fn main() {
    // Spawn tasks — they run concurrently on the thread pool
    let (tx, mut rx) = mpsc::channel(32);

    // Producer task
    let producer = tokio::spawn(async move {
        for i in 0..10 {
            tx.send(i).await.unwrap();
            sleep(Duration::from_millis(100)).await;
        }
    });

    // Consumer task
    let consumer = tokio::spawn(async move {
        while let Some(value) = rx.recv().await {
            println!("received: {value}");
        }
    });

    // Wait for both tasks
    let _ = tokio::join!(producer, consumer);
}

// Single-threaded runtime for tasks that are not Send
#[tokio::main(flavor = "current_thread")]
async fn single_threaded_main() {
    // Tasks here do not need to be Send
    let local_data = std::rc::Rc::new(42);  // Rc is !Send
    println!("value: {}", local_data);
}
```

Key concepts:

- **Work-stealing scheduler** — each worker thread has a local task queue plus a shared injection queue. Idle workers steal tasks from busy workers, balancing load automatically.
- **I/O driver** — integrates with OS async I/O (`epoll` on Linux, `kqueue` on macOS). Registers interest in I/O events and wakes the corresponding tasks via their `Waker`.
- **Timer** — hierarchical timer wheel for `tokio::time::sleep` and timeouts. Timers are cheap to create (no OS thread per timer).
- **`tokio::spawn()`** — creates a new task (lightweight thread) that runs concurrently. The spawned future must be `Send` (can move between threads) unless using `LocalSet`.
- **`#[tokio::main]`** — a macro that creates a `Runtime` and blocks on the provided `async fn main()`. `flavor = "current_thread"` creates a single-threaded runtime.

> **Sources:** Matthews (2024) Ch.8 pp. 159–164 · Gjengset (2022) Ch.10 pp. 175–176 · [Tokio tutorial](https://tokio.rs/tokio/tutorial) · [Tokio blog — "Making the Tokio Scheduler 10x faster"](https://tokio.rs/blog/2019-10-scheduler) · [Alice Ryhl — "Async: What is blocking?"](https://ryhl.io/blog/async-what-is-blocking/)

### Java: Virtual Thread Scheduler and Netty's Event Loop

Java's virtual thread scheduler uses `ForkJoinPool` as the carrier thread pool. Virtual threads are mounted on carrier threads for execution and unmounted when they block.

```java
import java.util.concurrent.*;
import jdk.incubator.concurrent.StructuredTaskScope;

public class RuntimeExamples {

    // Virtual threads — JVM-managed scheduling
    static void virtualThreadDemo() throws Exception {
        // The JVM schedules virtual threads on a ForkJoinPool of carrier threads
        // Blocking operations (sleep, I/O, locks) yield the carrier thread
        Thread vt = Thread.ofVirtual().start(() -> {
            try {
                Thread.sleep(1000);  // unmounts from carrier, not blocking OS
                System.out.println("Virtual thread done");
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        vt.join();
    }

    // Structured concurrency — parent scope manages child tasks
    static String structuredConcurrency() throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            Subtask<String> user = scope.fork(() -> fetchUser());
            Subtask<String> order = scope.fork(() -> fetchOrder());

            scope.join();            // wait for both
            scope.throwIfFailed();   // propagate exceptions

            return user.get() + " " + order.get();
        }
    }
}
```

Key concepts:

- **Carrier threads** — virtual threads are mounted on carrier (platform) threads for execution. When a virtual thread blocks (I/O, sleep, lock), the JVM unmounts its stack and mounts another virtual thread on the same carrier.
- **Transparent interception** — the JVM rewrites blocking operations (`socket.read()`, `Thread.sleep()`, lock acquisition) to yield the carrier thread instead of blocking it. This is invisible to user code.
- **Pinning** — `synchronized` blocks and native methods **pin** the virtual thread to its carrier, preventing unmounting. This is a limitation: long-running `synchronized` sections can block the carrier. Use `ReentrantLock` instead.
- **`StructuredTaskScope`** (Java 21+) — parent scope manages child tasks with automatic cancellation and exception propagation. `ShutdownOnFailure` cancels remaining tasks when one fails.
- **Netty alternative** — Netty uses a small number of event loop threads, each running an I/O multiplexer (`epoll`), processing events via `ChannelHandler` pipelines. This is explicit async I/O requiring callback-based programming. Virtual threads make Netty-style NIO unnecessary for most use cases.

> **Sources:** Rahman (2025) Ch.2 pp. 46–51 · Rahman (2025) Ch.3 pp. 113–123 · Rahman (2025) Ch.6 pp. 249–276 · Lea (1999) Ch.3.4 pp. 199–240 · [JEP 444 — Virtual Threads (scheduling detail)](https://openjdk.org/jeps/444) · [Netty user guide](https://netty.io/wiki/user-guide-for-4.x.html) · [Project Reactor reference](https://projectreactor.io/docs/core/release/reference/)

### Python: The `asyncio` Event Loop

Python's asyncio event loop is single-threaded: it runs coroutines, handles I/O events, manages timers, and schedules callbacks — all on one OS thread.

```python
import asyncio
from concurrent.futures import ProcessPoolExecutor

async def io_bound_work():
    """Coroutine — runs on the event loop thread."""
    reader, writer = await asyncio.open_connection('example.com', 80)
    writer.write(b'GET / HTTP/1.0\r\nHost: example.com\r\n\r\n')
    await writer.drain()
    data = await reader.read(4096)
    writer.close()
    await writer.wait_closed()
    return data

def cpu_bound_work(n: int) -> int:
    """Regular function — blocks the calling thread."""
    return sum(i * i for i in range(n))

async def main():
    # I/O-bound: runs as a coroutine on the event loop
    data = await io_bound_work()

    # CPU-bound: offload to a thread pool to avoid blocking the event loop
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(None, cpu_bound_work, 10_000_000)

    # CPU-bound with true parallelism: use ProcessPoolExecutor
    with ProcessPoolExecutor() as pool:
        result = await loop.run_in_executor(pool, cpu_bound_work, 10_000_000)

asyncio.run(main())
```

Key concepts:

- **Event loop cycle** — the loop repeatedly: (1) checks the ready queue for runnable callbacks/coroutines, (2) polls the OS for I/O events via `selectors` module (wraps `epoll`/`kqueue`/`select`), (3) runs expired timers.
- **CPU-bound starvation** — CPU-bound work blocks the entire event loop (all other coroutines are starved). Mitigation: `loop.run_in_executor()` offloads blocking/CPU work to a `ThreadPoolExecutor` or `ProcessPoolExecutor`.
- **`uvloop`** — a drop-in replacement for the default event loop, built on `libuv` (the same library Node.js uses). Provides 2–4x throughput improvement.
- **Single-threaded safety** — no locks needed between coroutines. Shared state is safe because only one coroutine runs at a time. Context switches happen only at `await` points.
- **Graceful shutdown** — signal handling (`SIGTERM`, `SIGINT`) must cancel running tasks and close executors. Hattingh covers patterns for clean startup and shutdown including `return_exceptions=True` in `gather()`.

> **Sources:** Ramalho (2022) Ch.21 pp. 797–810 · Slatkin (2025) Item 78 pp. 389–393 · Hattingh (2020) Ch.3 pp. 27–33, 55–73 · Beazley (2021) Ch.9.14 pp. 247–296 · [Python docs — Event Loop](https://docs.python.org/3/library/asyncio-eventloop.html) · [uvloop — Ultra fast asyncio event loop](https://github.com/MagicStack/uvloop) · [Python docs — Developing with asyncio](https://docs.python.org/3/library/asyncio-dev.html)

### Cross-Language Comparison

| Aspect | Rust / Tokio | Java / Loom | Python / asyncio |
|--------|-------------|-------------|-----------------|
| **Threading** | Multi-threaded work-stealing | `ForkJoinPool` carrier threads | Single-threaded |
| **I/O integration** | `epoll`/`kqueue` via I/O driver | JVM intercepts blocking calls | `selectors` module |
| **Task requirements** | Must be `Send` (multi-thread) | No special requirements | No special requirements |
| **CPU-bound handling** | `spawn_blocking()` | Just run it (virtual thread) | `run_in_executor()` |
| **Configurability** | Choose runtime, configure pool | JVM-managed | Replace loop (`uvloop`) |
| **Philosophy** | Maximum control | Maximum compatibility | Maximum simplicity |

---

## 4. `async`/`await` Syntax and Desugaring

How `async`/`await` syntax is compiled or interpreted in each language. Rust compiles it to state machines, Java deliberately has no async syntax (virtual threads replace it), and Python evolved it from generators.

### Rust: Desugaring `async` into State Machines

The compiler transforms each `async fn` into an anonymous `enum` (state machine) where each variant holds the local variables live at that `.await` point.

```rust
// What you write:
async fn fetch_two(url1: String, url2: String) -> (String, String) {
    let resp1 = reqwest::get(&url1).await.unwrap().text().await.unwrap();
    // ↑ state boundary: AfterFirstAwait stores url2, and resp1 partial state
    let resp2 = reqwest::get(&url2).await.unwrap().text().await.unwrap();
    // ↑ state boundary: AfterSecondAwait stores resp1, resp2 partial state
    (resp1, resp2)
}

// What the compiler generates (conceptual):
// fn fetch_two(url1: String, url2: String) -> impl Future<Output = (String, String)>
//
// The returned future is an enum:
//   enum FetchTwo {
//       Start { url1: String, url2: String },
//       AfterGet1 { url2: String, get_future: GetFuture },
//       AfterText1 { url2: String, text_future: TextFuture },
//       AfterGet2 { resp1: String, get_future: GetFuture },
//       AfterText2 { resp1: String, text_future: TextFuture },
//   }
//
// Each poll() call resumes from the current variant,
// executes until the next .await, saves state, returns Pending.
```

Key concepts:

- **State machine enum** — each `.await` point creates a new variant. Local variables that survive across an `.await` are stored as fields in the variant. Variables that don't survive are dropped.
- **Size of the future** — equals the maximum size of any state variant (plus discriminant). The compiler optimizes by sharing space between non-overlapping variants.
- **Stackless** — no heap allocation for the coroutine frame unless the future is boxed. `tokio::spawn()` requires boxing because task ownership transfers to the runtime.
- **Zero-cost claim** — the generated state machine is at least as efficient as a hand-written one. The compiler can optimize across `await` points.
- **`async fn` signature** — `async fn foo(x: i32) -> String` desugars to `fn foo(x: i32) -> impl Future<Output = String>`.

> **Sources:** Gjengset (2022) Ch.8 pp. 124–126 · [The Rust Async Book — "async/.await"](https://rust-lang.github.io/async-book/03_async_await/01_chapter.html) · [Tyler Mandry — "How Rust optimizes async/await"](https://tmandry.gitlab.io/blog/posts/optimizing-await-1/) · [Rust Reference — `await` expression](https://doc.rust-lang.org/reference/expressions/await-expr.html)

### Java: No `async`/`await` — Virtual Threads Instead

Java deliberately chose NOT to add `async`/`await` syntax. Virtual threads make every blocking call an implicit suspension point.

```java
public class NoAsyncNeeded {

    // This is "async" code in Java — it looks exactly like sync code.
    // When run on a virtual thread, blocking calls yield the carrier.
    static String fetchUser(int id) throws Exception {
        // Thread.sleep yields the carrier — not blocking the OS thread
        Thread.sleep(100);
        return "User-" + id;
    }

    static String fetchOrder(int userId) throws Exception {
        Thread.sleep(100);
        return "Order-for-" + userId;
    }

    // Sequential — blocking calls are cheap on virtual threads
    static void sequential() throws Exception {
        Thread.ofVirtual().start(() -> {
            try {
                String user = fetchUser(42);       // suspends, not blocks
                String order = fetchOrder(42);     // suspends, not blocks
                System.out.println(user + ": " + order);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }).join();
    }

    // Pinning: synchronized blocks pin the virtual thread to its carrier
    static final Object lock = new Object();

    static void pinningExample() {
        // BAD: synchronized pins the virtual thread
        synchronized (lock) {
            try { Thread.sleep(1000); } catch (InterruptedException e) {}
            // carrier thread is blocked for the entire sleep!
        }

        // GOOD: ReentrantLock does not pin
        var reentrantLock = new java.util.concurrent.locks.ReentrantLock();
        reentrantLock.lock();
        try {
            try { Thread.sleep(1000); } catch (InterruptedException e) {}
            // carrier thread is yielded during sleep
        } finally {
            reentrantLock.unlock();
        }
    }
}
```

Key concepts:

- **No colored functions** — any function can call any other function. `fetchUser()` is a regular method that blocks — on a virtual thread, the blocking is transparent.
- **Existing code benefits automatically** — libraries, frameworks, JDBC drivers all work with virtual threads without modification (as long as they avoid `synchronized` for long-running sections).
- **Pinning limitation** — `synchronized` blocks and native methods pin the virtual thread to its carrier, preventing unmounting. Mitigation: use `java.util.concurrent.locks.ReentrantLock` instead.
- **Stack traces** — virtual thread stack traces look like normal thread stack traces. No async transformation means debugging is straightforward.

> **Sources:** Rahman (2025) Ch.2 pp. 37–49 · Evans et al (2022) Ch.18 pp. 618–625 · [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444) · [Cay Horstmann — "Java's Virtual Threads"](https://horstmann.com/unblog/2024-01-03/index.html)

### Python: From Generators to `async`/`await`

Python's `async`/`await` evolved through four stages: generators (`yield`), enhanced generators (`send()`), `yield from` delegation, and native coroutines (`async def` + `await`).

```python
import asyncio

# Stage 1: Generator (Python 2.2) — yield suspends, caller calls next()
def countdown(n):
    while n > 0:
        yield n
        n -= 1

# Stage 2: Enhanced generator (Python 2.5) — two-way communication
def accumulator():
    total = 0
    while True:
        value = yield total  # receives values via send()
        total += value

# Stage 3: yield from (Python 3.3) — delegation
def delegator():
    result = yield from sub_generator()  # delegates to another generator
    return result

# Stage 4: Native coroutines (Python 3.5) — async/await
async def fetch_data(url: str) -> str:
    # await suspends the coroutine — conceptually similar to yield from
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

# Under the hood: async def creates a coroutine object
# whose __await__ method returns a generator-like iterator.
# await expr ≈ yield from expr.__await__()
# The event loop catches StopIteration with the return value.

# CPython bytecodes: GET_AWAITABLE, YIELD_FROM, SEND
```

Key concepts:

- **Historical evolution** — understanding generators → enhanced generators → `yield from` → `async`/`await` reveals that native coroutines share the same underlying machinery as generators.
- **`__await__` protocol** — an awaitable is any object with `__await__` returning an iterator. `await expr` is conceptually `yield from expr.__await__()`.
- **Native coroutines vs generators** — you cannot use `yield` in an `async def` (unless creating an async generator). This syntactic separation was added by PEP 492 to prevent confusion.
- **CPython bytecodes** — `GET_AWAITABLE`, `YIELD_FROM`, `SEND` opcodes implement the coroutine protocol at the interpreter level.

> **Sources:** Ramalho (2022) Ch.17 pp. 641–652 · Ramalho (2022) Ch.21 pp. 782–785 · Shaw (2021) pp. 265–278 · Beazley (2021) Ch.6 pp. 139–152 · Beazley (2021) Ch.5.23 pp. 101–137 · [PEP 492 — Coroutines with async and await syntax](https://peps.python.org/pep-0492/) · [Python docs — Await expression](https://docs.python.org/3/reference/expressions.html#await) · [Brett Cannon — "How the heck does async/await work in Python 3.5?"](https://snarky.ca/how-the-heck-does-async-await-work-in-python-3-5/)

### Cross-Language Comparison

The spectrum of desugaring strategies:

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Transformation** | Compile-time state machine `enum` | None (JVM intercepts blocking) | Interpreter-level coroutine frames |
| **Suspension points** | Explicit (`.await`) | Implicit (any blocking call) | Explicit (`await`) |
| **Overhead** | Zero runtime cost | JVM stack management | Interpreter frame overhead |
| **Backward compat** | New syntax required | Existing code works | New syntax required |
| **Debugging** | State machine obscures traces | Normal stack traces | Event loop obscures traces |
| **Precedent** | C#, JavaScript | Go goroutines | JavaScript, C# |

Rust and Python took the "explicit async" path (you see `.await`/`await` at every suspension point), while Java took the "transparent async" path (blocking calls suspend transparently). Explicit async gives visibility into context switches; transparent async gives backward compatibility.

---

## 5. Pinning (`Pin<T>`) and Self-Referential Futures

When the Rust compiler desugars `async fn`, the generated state machine may contain **self-references** — a variable in one state may borrow another variable in the same state. Moving the state machine in memory would invalidate these internal pointers. `Pin` prevents this. Java and Python do not face this problem because of garbage collection and reference-based semantics.

### Rust: Why `Pin` Exists and How It Works

```rust
use std::pin::Pin;
use std::future::Future;
use std::task::{Context, Poll};

// This async fn creates a self-referential future:
async fn self_referential() {
    let data = vec![1, 2, 3];
    let reference = &data;  // borrows data
    // After this .await, both `data` and `reference` must be in the future's state.
    // `reference` is a pointer into `data` — if the future is moved,
    // `reference` would point to invalid memory.
    tokio::time::sleep(std::time::Duration::from_secs(1)).await;
    println!("{:?}", reference);
}

// Pin prevents the pointee from being moved after pinning
fn using_pin() {
    // Box::pin — heap pinning (most common)
    let future: Pin<Box<dyn Future<Output = ()>>> = Box::pin(self_referential());

    // tokio::pin! — stack pinning
    // let future = self_referential();
    // tokio::pin!(future);  // future is now Pin<&mut impl Future>
}

// Manual Future implementation with pin-project
use pin_project::pin_project;

#[pin_project]
struct TwoFutures<F1, F2> {
    #[pin]
    first: F1,   // pinned — this is a future that may be self-referential
    #[pin]
    second: F2,
    done_first: bool,
}

impl<F1: Future, F2: Future> Future for TwoFutures<F1, F2> {
    type Output = (F1::Output, F2::Output);

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let this = self.project();  // safe pin projection via pin-project
        // now this.first: Pin<&mut F1>, this.second: Pin<&mut F2>
        // can call poll() on them safely
        todo!()
    }
}
```

Key concepts:

- **Self-references in futures** — when the compiler desugars an `async fn`, a variable may borrow another variable that lives in the same state machine. Moving the future would invalidate these internal pointers.
- **`Pin<P>`** — a wrapper that prevents the pointee from being moved after it has been pinned. `Pin<&mut T>` guarantees that `T` will not move.
- **`Unpin`** — an auto-trait. Types that implement `Unpin` can be freely moved even when pinned (because they contain no self-references). Most types are `Unpin` — only compiler-generated futures and manually self-referential types are `!Unpin`.
- **`Future::poll()` takes `Pin<&mut Self>`** — this prevents the caller from moving the future between polls.
- **`pin-project` crate** — provides `#[pin_project]` derive macro that generates safe pin projections, eliminating most `unsafe` code when implementing `Future` manually.
- **Three contexts for `Pin`** — (1) `async fn`: compiler handles pinning automatically; (2) manual `Future` implementations: use `pin-project`; (3) storing futures in collections: `Vec<Pin<Box<dyn Future>>>`.

> **Sources:** Gjengset (2022) Ch.8 pp. 126–132 · [Rust docs — `std::pin::Pin`](https://doc.rust-lang.org/std/pin/struct.Pin.html) · [Rust docs — `std::marker::Unpin`](https://doc.rust-lang.org/std/marker/trait.Unpin.html) · [The Rust Async Book — "Pinning"](https://rust-lang.github.io/async-book/04_pinning/01_chapter.html) · [`pin-project` crate documentation](https://docs.rs/pin-project/latest/pin_project/) · [Rust RFC 2349 — Pin](https://rust-lang.github.io/rfcs/2349-pin.html) · [fasterthanlime — "Pin and suffering"](https://fasterthanli.me/articles/pin-and-suffering)

### Why Java and Python Don't Need `Pin`

**Java:** objects live on the GC heap. The GC may move objects (for compaction), but it transparently updates all references — user code never sees raw memory addresses, so self-references are not a problem. Virtual thread stacks are managed by the JVM and can be moved (stack frames are stored on the heap), but the JVM handles all pointer updates.

**Python:** objects use reference counting and are never moved in memory. CPython allocates objects with `PyObject_Malloc` and their address is stable for their lifetime. Coroutine frames can safely contain self-references because internal pointers remain valid.

`Pin` is a consequence of Rust's ownership model — the language gives programmers raw pointers and move semantics, so it must also give them tools to prevent moves when they would be unsafe. Languages with managed memory handle this transparently at the cost of GC overhead.

### Decision Flowchart

| Situation | What to do |
|-----------|-----------|
| Writing `async fn` and using `.await` | `Pin` is handled automatically by the compiler and runtime |
| Implementing `Future` manually | Use `pin-project` crate for safe pin projection |
| Storing futures in collections or trait objects | Use `Box::pin()` or `Pin<Box<dyn Future>>` |
| Coming from Java/Python | `Pin` is the price Rust pays for zero-cost async without GC |

---

## 6. Cancellation Semantics

How each language handles cancellation of in-progress async operations. Rust drops futures (deterministic RAII cleanup), Java uses interruption and structured concurrency, Python injects `CancelledError`.

### Rust: Cancellation by Dropping

In Rust, cancelling a future is simply dropping it. When a `Future` is dropped, its destructor runs, cleaning up any resources via RAII.

```rust
use tokio::time::{sleep, Duration};

async fn cancellation_examples() {
    // select! races multiple futures — losers are dropped (cancelled)
    tokio::select! {
        _ = sleep(Duration::from_secs(5)) => {
            println!("sleep completed");
        }
        result = fetch_data() => {
            // If fetch_data finishes first, the sleep future is dropped
            println!("data: {result}");
        }
    }

    // JoinHandle::abort() cancels a spawned task
    let handle = tokio::spawn(async {
        sleep(Duration::from_secs(60)).await;
        println!("this may never print");
    });
    sleep(Duration::from_secs(1)).await;
    handle.abort();  // cancels at the next .await point

    // Cancellation safety: code after .await may never run
    // BAD:
    // let guard = mutex.lock().await;
    // do_something().await;  // if cancelled here, guard is dropped — OK (RAII)
    // manual_cleanup();      // this may never execute!

    // GOOD: use RAII guards rather than manual cleanup-after-await
}

async fn fetch_data() -> String {
    sleep(Duration::from_millis(100)).await;
    "data".to_string()
}
```

Key concepts:

- **Drop = cancel** — when a future is dropped, its destructor runs, cleaning up resources recursively. Sub-futures that were being awaited are also dropped.
- **`tokio::select!`** — races multiple futures. The first to complete wins; all other branches are dropped (cancelled).
- **`JoinHandle::abort()`** — cancels a spawned task by marking it for cancellation at the next `.await` point.
- **Cancellation safety** — any code after an `.await` in a dropped future will never execute. Use RAII guards (like `MutexGuard`) rather than manual cleanup-after-await patterns.
- **Deterministic** — drop runs immediately and synchronously. Compare with Java/Python where cancellation is cooperative and asynchronous.

> **Sources:** Gjengset (2022) Ch.8 pp. 136–140 · [Tokio docs — `select!` macro](https://tokio.rs/tokio/tutorial/select) · [Tokio docs — Graceful Shutdown](https://tokio.rs/tokio/topics/shutdown)

### Java: Interruption, `Future.cancel()`, and Structured Concurrency

Java has multiple cancellation mechanisms, from legacy `Thread.interrupt()` to modern structured concurrency.

```java
import java.util.concurrent.*;
import jdk.incubator.concurrent.StructuredTaskScope;

public class CancellationExamples {

    // 1. Thread.interrupt() — cooperative cancellation
    static void interruptExample() throws InterruptedException {
        Thread worker = Thread.ofVirtual().start(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    Thread.sleep(100);  // throws InterruptedException if interrupted
                    doWork();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();  // restore flag
                    break;  // clean up and exit
                }
            }
        });
        Thread.sleep(1000);
        worker.interrupt();  // request cancellation
        worker.join();
    }

    // 2. Future.cancel() — cancel a submitted task
    static void futureCancelExample() throws Exception {
        var executor = Executors.newVirtualThreadPerTaskExecutor();
        Future<String> future = executor.submit(() -> {
            Thread.sleep(10_000);
            return "result";
        });
        future.cancel(true);  // mayInterruptIfRunning = true

        // future.get() now throws CancellationException
        executor.shutdown();
    }

    // 3. StructuredTaskScope — hierarchical cancellation
    static String structuredCancellation() throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            var user = scope.fork(() -> fetchUser());
            var order = scope.fork(() -> fetchOrder());  // if this throws...

            scope.join();
            scope.throwIfFailed();  // ...ShutdownOnFailure cancels user task

            return user.get() + " " + order.get();
        }
        // Scope exit cancels any remaining subtasks
    }
}
```

Key concepts:

- **`Thread.interrupt()`** — sets the interrupt flag. Blocking methods (`sleep`, `wait`, `read`) throw `InterruptedException`. The task must check `Thread.interrupted()` or handle `InterruptedException`. Cooperative: the task decides how to respond.
- **`Future.cancel(boolean mayInterruptIfRunning)`** — if `mayInterruptIfRunning` is true, interrupts the thread running the task.
- **Structured concurrency (`StructuredTaskScope`)** — cancellation flows from parent to children. When `shutdown()` is called (e.g., by `ShutdownOnFailure` when one subtask fails), all other subtasks are cancelled (interrupted). Scope exit cancels remaining tasks.
- **Cooperative** — the task must respond to interruption. Compare with Rust where drop is unconditional.

> **Sources:** Goetz (2006) Ch.7 pp. 135–161 · Lea (1999) Ch.3.1 pp. 149–170 · Rahman (2025) Ch.4 pp. 125–140 · [JEP 453 — Structured Concurrency](https://openjdk.org/jeps/453) · [Java docs — `Thread.interrupt()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html#interrupt()) · [Java docs — `Future.cancel()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Future.html#cancel(boolean))

### Python: `CancelledError` and `TaskGroup`

Python's cancellation is cooperative — `task.cancel()` schedules a `CancelledError` to be thrown into the coroutine at the next `await` point.

```python
import asyncio

async def cancellable_work():
    try:
        while True:
            await asyncio.sleep(1)
            print("working...")
    except asyncio.CancelledError:
        print("cleaning up...")
        # Perform cleanup, then re-raise
        raise  # ALWAYS re-raise CancelledError

async def cancel_example():
    task = asyncio.create_task(cancellable_work())
    await asyncio.sleep(3)
    task.cancel()  # schedules CancelledError at next await
    try:
        await task
    except asyncio.CancelledError:
        print("task was cancelled")

# Timeout-based cancellation
async def timeout_example():
    async with asyncio.timeout(5.0):
        # If this takes more than 5 seconds, the task is cancelled
        await long_running_operation()

# TaskGroup — structured concurrency (Python 3.11+)
async def taskgroup_example():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(fetch("url1"))
        task2 = tg.create_task(fetch("url2"))
        # If task1 raises, task2 is cancelled automatically
        # All exceptions are collected into an ExceptionGroup

# gather with return_exceptions for graceful error handling
async def gather_example():
    results = await asyncio.gather(
        fetch("url1"),
        fetch("url2"),
        fetch("url3"),
        return_exceptions=True,  # exceptions returned as results, not raised
    )
    for r in results:
        if isinstance(r, Exception):
            print(f"failed: {r}")
        else:
            print(f"success: {r}")
```

Key concepts:

- **`task.cancel()`** — schedules a `CancelledError` to be thrown at the next `await` point. The coroutine can catch it for cleanup but should re-raise it.
- **`CancelledError` is a `BaseException`** (since Python 3.9) — `except Exception:` no longer catches it. This prevents accidentally swallowing cancellations.
- **`asyncio.TaskGroup`** (Python 3.11+) — structured concurrency. If any task in the group raises, all other tasks are cancelled and exceptions are collected into an `ExceptionGroup`.
- **`asyncio.timeout()`** and **`asyncio.wait_for()`** — use cancellation internally. When a timeout expires, the wrapped task is cancelled.
- **Cooperative** — the task must reach an `await` point for cancellation to take effect. A CPU-bound coroutine that never awaits cannot be cancelled.

> **Sources:** Hattingh (2020) Ch.3 pp. 55–73 · [Python docs — `Task.cancel()`](https://docs.python.org/3/library/asyncio-task.html#asyncio.Task.cancel) · [Python docs — `TaskGroup`](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup) · [PEP 654 — Exception Groups and `except*`](https://peps.python.org/pep-0654/)

### Cross-Language Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Mechanism** | Drop the future | `interrupt()` / `cancel()` / scope | `CancelledError` injection |
| **Cooperative?** | No (drop is unconditional) | Yes (task must respond) | Yes (next `await` point) |
| **Cleanup** | RAII (destructors run) | `finally` blocks | `try`/`finally`, `async with` |
| **Structured** | `select!` drops losers | `StructuredTaskScope` | `TaskGroup` |
| **Deterministic** | Yes (drop runs immediately) | No (depends on task) | No (next `await` point) |
| **Risk** | Code after `.await` never runs | Forgotten interrupt handling | Swallowed `CancelledError` |

Rust's drop-based cancellation is the safest (no forgotten cleanup) but can be surprising (code after `.await` may never run). Java's and Python's cooperative cancellation gives the task a chance to clean up gracefully but requires discipline.

---

## 7. Backpressure and Flow Control

The producer-consumer problem in async streams: how does a fast producer avoid overwhelming a slow consumer? Rust uses pull-based `Stream`, Java uses `Flow` API with explicit `request(n)`, Python uses async generators with implicit single-consumer backpressure.

### Rust: `Stream` and Async Iterators

`Stream` is the async equivalent of `Iterator`: the consumer controls the rate by choosing when to call `poll_next()`. Backpressure is automatic.

```rust
use tokio_stream::{self as stream, StreamExt};
use tokio::sync::mpsc;

async fn stream_examples() {
    // Creating a stream from an iterator
    let mut stream = stream::iter(vec![1, 2, 3, 4, 5]);
    while let Some(value) = stream.next().await {
        println!("got: {value}");
    }

    // Bounded channel — natural backpressure
    let (tx, mut rx) = mpsc::channel::<i32>(10);  // buffer of 10

    tokio::spawn(async move {
        for i in 0..100 {
            // send() returns Pending when buffer is full — backpressure!
            tx.send(i).await.unwrap();
        }
    });

    while let Some(value) = rx.recv().await {
        // Consumer processes at its own pace
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
        println!("processed: {value}");
    }
}

// StreamExt combinators
async fn stream_combinators() {
    let stream = stream::iter(1..=100);

    let results: Vec<_> = stream
        .filter(|x| *x % 2 == 0)        // keep even numbers
        .map(|x| x * x)                  // square them
        .take(10)                         // first 10 results
        .collect()
        .await;

    println!("{results:?}");
}

// async-stream crate: create streams with async/yield syntax
use async_stream::stream;

fn countdown(n: u32) -> impl tokio_stream::Stream<Item = u32> {
    stream! {
        for i in (1..=n).rev() {
            tokio::time::sleep(std::time::Duration::from_secs(1)).await;
            yield i;
        }
    }
}
```

Key concepts:

- **`Stream` trait** — `fn poll_next(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Option<Self::Item>>`. Returns `Poll::Ready(Some(item))`, `Poll::Ready(None)` (end), or `Poll::Pending`.
- **Pull-based** — the consumer drives the stream. Backpressure is automatic: the producer is not called until the consumer is ready.
- **Bounded channels** — `tokio::sync::mpsc::channel(n)` provides natural backpressure. `send()` returns `Poll::Pending` when the buffer is full.
- **`StreamExt`** — combinators: `map`, `filter`, `buffered`, `throttle`, `chunks`, `take`.
- **Not yet in stdlib** — `Stream` lives in the `futures` crate. Stabilization as `AsyncIterator` is in progress.
- **`async-stream` crate** — `stream!` macro for creating streams with `async` blocks and `yield`.

> **Sources:** [`futures` crate — `Stream` trait](https://docs.rs/futures/latest/futures/stream/trait.Stream.html) · [`tokio-stream` crate](https://docs.rs/tokio-stream/latest/tokio_stream/) · [`async-stream` crate](https://docs.rs/async-stream/latest/async_stream/)

### Java: Reactive Streams and `Flow` API

Java's `Flow` API (JDK 9+) implements the Reactive Streams specification with four interfaces and explicit backpressure via `request(n)`.

```java
import java.util.concurrent.Flow;
import java.util.concurrent.SubmissionPublisher;

public class FlowExample {

    // Simple subscriber with explicit demand control
    static class PrintSubscriber implements Flow.Subscriber<String> {
        private Flow.Subscription subscription;

        @Override
        public void onSubscribe(Flow.Subscription subscription) {
            this.subscription = subscription;
            subscription.request(1);  // request first item
        }

        @Override
        public void onNext(String item) {
            System.out.println("Received: " + item);
            // Process the item, then request the next one
            subscription.request(1);  // explicit backpressure
        }

        @Override
        public void onError(Throwable throwable) {
            System.err.println("Error: " + throwable.getMessage());
        }

        @Override
        public void onComplete() {
            System.out.println("Done");
        }
    }

    public static void main(String[] args) throws Exception {
        // SubmissionPublisher is the JDK's built-in Publisher
        try (var publisher = new SubmissionPublisher<String>()) {
            publisher.subscribe(new PrintSubscriber());

            for (int i = 0; i < 10; i++) {
                publisher.submit("item-" + i);
            }
        }
        Thread.sleep(1000);  // wait for async processing
    }

    // With virtual threads, blocking queues provide simpler backpressure
    static void virtualThreadAlternative() throws Exception {
        var queue = new java.util.concurrent.LinkedBlockingQueue<String>(10);

        Thread.ofVirtual().start(() -> {
            // Producer — blocks when queue is full (backpressure)
            for (int i = 0; i < 100; i++) {
                try { queue.put("item-" + i); } catch (InterruptedException e) { break; }
            }
        });

        Thread.ofVirtual().start(() -> {
            // Consumer — blocks when queue is empty
            while (true) {
                try {
                    String item = queue.take();
                    System.out.println("Processed: " + item);
                } catch (InterruptedException e) { break; }
            }
        });
    }
}
```

Key concepts:

- **Four interfaces** — `Publisher<T>`, `Subscriber<T>`, `Subscription`, `Processor<T,R>`.
- **`request(n)` backpressure** — the subscriber signals how many items it can handle. The publisher must respect this demand.
- **Implemented by** Project Reactor (`Flux`/`Mono`), RxJava (`Observable`/`Flowable`), and Netty.
- **Virtual thread alternative** — blocking queues on virtual threads provide natural backpressure without reactive complexity. `LinkedBlockingQueue` with a capacity limit blocks the producer when full.
- **When reactive still matters** — extremely high-throughput event processing where operator fusion and scheduler control provide benefits beyond what blocking queues offer.

> **Sources:** Rahman (2025) Ch.6 pp. 279–292 · [Java docs — `java.util.concurrent.Flow`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Flow.html) · [Reactive Streams specification](https://www.reactive-streams.org/) · [Project Reactor reference — Backpressure](https://projectreactor.io/docs/core/release/reference/#reactive.backpressure)

### Python: Async Generators and Async Iteration

Python's async generators provide natural pull-based backpressure: `async for` drives the generator one item at a time.

```python
import asyncio

# Async generator — the async equivalent of a generator
async def ticker(interval: float, count: int):
    for i in range(count):
        await asyncio.sleep(interval)
        yield i  # produces one item at a time

# async for — pull-based iteration
async def consumer():
    async for value in ticker(0.5, 10):
        # Next item is not produced until this iteration completes
        print(f"got: {value}")
        await asyncio.sleep(1)  # slow consumer — backpressure is automatic

# Async comprehensions
async def comprehension_example():
    results = [x async for x in ticker(0.1, 10)]
    squared = [x * x async for x in ticker(0.1, 10)]
    even = {x async for x in ticker(0.1, 10) if x % 2 == 0}

# asyncio.Queue — bounded queue for decoupled producer-consumer
async def queue_backpressure():
    queue: asyncio.Queue[int] = asyncio.Queue(maxsize=10)

    async def producer():
        for i in range(100):
            await queue.put(i)  # blocks when queue is full
            print(f"produced: {i}")

    async def consumer():
        while True:
            item = await queue.get()  # blocks when queue is empty
            await asyncio.sleep(0.1)  # simulate processing
            print(f"consumed: {item}")
            queue.task_done()

    prod = asyncio.create_task(producer())
    cons = asyncio.create_task(consumer())
    await prod
    cons.cancel()

# __aiter__ / __anext__ protocol — manual async iterable
class AsyncRange:
    def __init__(self, start, stop):
        self.current = start
        self.stop = stop

    def __aiter__(self):
        return self

    async def __anext__(self):
        if self.current >= self.stop:
            raise StopAsyncIteration
        await asyncio.sleep(0.1)
        value = self.current
        self.current += 1
        return value
```

Key concepts:

- **Async generators** — `async def` with `yield`. `async for item in gen():` iterates asynchronously, suspending at each step.
- **`__aiter__`/`__anext__` protocol** — mirrors `__iter__`/`__next__`. `StopAsyncIteration` signals end of iteration.
- **Implicit backpressure** — `async for` drives the generator one item at a time. The producer is not called until the consumer is ready. Naturally pull-based, like Rust's `Stream`.
- **`asyncio.Queue`** — bounded queue for decoupled producers/consumers. `put()` blocks when full, `get()` blocks when empty.
- **Async comprehensions** — `[x async for x in aiter]`, `{x async for x in aiter}` — compact syntax for collecting async iterator results.

> **Sources:** Ramalho (2022) Ch.21 pp. 811–820 · Hattingh (2020) Ch.3 pp. 43–55 · Hattingh (2020) Ch.4 pp. 75–90 · Slatkin (2025) Item 75 pp. 364–368 · [PEP 525 — Asynchronous Generators](https://peps.python.org/pep-0525/) · [Python docs — `async for` statement](https://docs.python.org/3/reference/compound_stmts.html#the-async-for-statement)

### Cross-Language Comparison

| Aspect | Rust `Stream` | Java `Flow` / Reactive Streams | Python async generators |
|--------|--------------|-------------------------------|------------------------|
| **Model** | Pull-based (consumer polls) | Push with demand signaling (`request(n)`) | Pull-based (`async for` drives) |
| **Backpressure** | Automatic (consumer controls rate) | Explicit (`request(n)`) | Implicit (one item at a time) |
| **Multi-subscriber** | Via broadcast channels | Built-in (`Publisher` → N subscribers) | No (single consumer) |
| **Operator fusion** | No | Yes (Reactor, RxJava) | No |
| **Bounded channel** | `mpsc::channel(n)` | `LinkedBlockingQueue(n)` | `asyncio.Queue(maxsize=n)` |
| **In stdlib** | No (stabilization in progress) | Yes (`j.u.c.Flow`, JDK 9+) | Yes (PEP 525, Python 3.6+) |
| **Complexity** | Low | High | Lowest |

Python is simplest (implicit pull), Rust is zero-cost (pull-based, no allocation), Java is most flexible (explicit demand signaling) but also most complex.

---

## 8. Colored Function Problem and Synthesis

The "colored function" problem (Bob Nystrom, 2015): in languages with `async`/`await`, functions come in two "colors" — sync and async — that cannot freely interoperate. This creates an ecosystem split that affects library design, debugging, and testing.

### The Problem Defined

In languages with `async`/`await`, three rules apply:

1. **Async functions can call sync functions** — no restriction.
2. **Sync functions cannot call async functions** — cannot `await` in a non-`async` context.
3. **Async is contagious** — if any function in a call chain needs to `await`, every caller up to the event loop must be `async`.

This creates a split: libraries must provide both sync and async APIs (doubling API surface), or choose one "color" and exclude the other.

### Rust: Fully Colored

```rust
// The ecosystem is split:
//   Async: reqwest, sqlx, tokio-postgres, hyper
//   Sync:  ureq, diesel, postgres, actix-web (uses async internally)

// Calling async from sync — requires a runtime handle
fn sync_function() {
    let rt = tokio::runtime::Runtime::new().unwrap();
    let result = rt.block_on(async {
        reqwest::get("https://example.com").await.unwrap().text().await.unwrap()
    });
    println!("{result}");
}

// Calling sync from async — risks blocking the executor
async fn async_function() {
    // BAD: blocks the executor thread
    // let data = std::fs::read_to_string("file.txt").unwrap();

    // GOOD: offload to a blocking thread pool
    let data = tokio::task::spawn_blocking(|| {
        std::fs::read_to_string("file.txt").unwrap()
    }).await.unwrap();
    println!("{data}");
}
```

Key concepts:

- **`runtime.block_on()`** — bridges sync-to-async. Blocks the current thread until the future completes.
- **`spawn_blocking()`** — bridges async-to-sync. Offloads blocking work to a dedicated thread pool so it doesn't block executor threads.
- **Library duplication** — `reqwest` (async) vs `ureq` (sync), `sqlx` (async) vs `diesel` (sync). Some libraries provide both via feature flags.
- **When to avoid async** — for CPU-bound or simple programs, sync is simpler. Use async only when you have many concurrent I/O operations.

> **Sources:** Matthews (2024) Ch.8 pp. 174–180 · [Without Boats — "Why async Rust?"](https://without.boats/blog/why-async-rust/)

### Java: Not Colored (Since Virtual Threads)

```java
// No coloring — the same function works everywhere
static String fetchUser(int id) throws Exception {
    Thread.sleep(100);  // on a virtual thread: yields. On a platform thread: blocks.
    return "User-" + id;
}

// Can be called from any context:
// - From a virtual thread: blocking is cheap
// - From a platform thread: blocking is expensive (but still works)
// - From a reactive pipeline: would need wrapping (legacy coloring)

// The pre-Loom reactive ecosystem DID create its own coloring:
// Mono<String> fetchUserReactive(int id) { ... }
// Migrating from reactive back to imperative is a current challenge.
```

Key concepts:

- **No function coloring** — `Thread.sleep()` works in both platform and virtual threads. Libraries don't need async variants.
- **The only mainstream language (besides Go) to avoid coloring entirely** — virtual threads make blocking cheap, eliminating the need for `async`/`await` syntax.
- **Legacy reactive coloring** — the pre-Loom reactive ecosystem (Reactor `Mono`/`Flux`, RxJava `Observable`) created its own "color". Migrating back to imperative is an ongoing effort.

> **Sources:** Rahman (2025) Ch.2 pp. 47–49 · [Ron Pressler — "Why Continuations are Coming to Java"](https://inside.java/2020/08/07/loom-performance/)

### Python: Fully Colored

```python
import asyncio

# sync-to-async bridge
def sync_caller():
    # asyncio.run() is the top-level bridge
    result = asyncio.run(async_function())
    print(result)

# async-to-sync bridge
async def async_caller():
    loop = asyncio.get_event_loop()
    # Offload sync/blocking work to a thread pool
    result = await loop.run_in_executor(None, sync_blocking_function)
    print(result)

def sync_blocking_function() -> str:
    import time
    time.sleep(1)
    return "done"

async def async_function() -> str:
    await asyncio.sleep(1)
    return "async done"

# Gradual migration pattern (Slatkin Item 77):
# 1. Wrap sync code in threads called from async
# 2. Wrap async code in asyncio.run() called from sync
# 3. Gradually convert inner functions to async

# Janus queue: bridging sync and async worlds
# (from Hattingh Ch.4 — a queue with both sync and async interfaces)
```

Key concepts:

- **`asyncio.run()`** — bridges sync-to-async at the top level.
- **`loop.run_in_executor()`** — bridges async-to-sync by offloading to a thread pool.
- **Contagious async** — converting one function to async often cascades through the call stack. The "all-or-nothing" problem.
- **Gradual migration** — Slatkin Item 77 shows the pattern: wrap sync code in threads, wrap async code in `asyncio.run()`, gradually convert inner functions.
- **Janus queue** — a queue with both sync and async interfaces, enabling communication between sync and async worlds.

> **Sources:** Slatkin (2025) Item 77 pp. 381–389 · Ramalho (2022) Ch.21 pp. 825–827 · Hattingh (2020) Ch.4 pp. 90–100

### Practical Implications

| Dimension | Rust | Java | Python |
|-----------|------|------|--------|
| **Debugging** | State machine obscures traces; use `tracing` + `tokio-console` | Normal stack traces — major advantage | Event loop obscures traces; use `set_debug(True)` |
| **Testing** | `#[tokio::test]` required | No special infrastructure | `pytest-asyncio` or `IsolatedAsyncioTestCase` |
| **Library ecosystem** | Parallel sync/async ecosystems | Converging to single sync ecosystem | Parallel sync/async ecosystems |
| **Performance** | Zero-cost but compile-time complexity | Scales to millions with simple code | Single-threaded limitation |
| **Learning curve** | `Pin`, `Send`/`Sync`, executor choice | Minimal (just use virtual threads) | Moderate (event loop, coloring) |

### Grand Synthesis

| Dimension | Rust | Java | Python |
|-----------|------|------|--------|
| **Coroutine type** | Stackless (state machine) | Stackful (virtual threads) | Stackless (coroutine frames) |
| **Future** | `Future` trait (poll-based) | `CompletableFuture` / `Future.get()` | `asyncio.Future` / `Task` |
| **Runtime** | External (Tokio) | Built into JVM | stdlib `asyncio` |
| **Syntax** | `async`/`.await` | None (blocking = async) | `async`/`await` |
| **Pin / memory safety** | `Pin<T>` required | N/A (GC handles) | N/A (no object moves) |
| **Cancellation** | Drop (non-cooperative) | Interruption (cooperative) | `CancelledError` (cooperative) |
| **Backpressure** | `Stream` (pull-based) | `Flow` / `request(n)` | Async generators (pull-based) |
| **Colored functions** | Yes | No (since Loom) | Yes |
| **Core philosophy** | Maximum performance and safety | Backward compatibility and ergonomics | Simplicity and readability |

Each language's async model reflects its core values: Rust chose zero-cost abstractions with explicit control; Java chose to extend its existing thread model rather than add new syntax; Python chose explicit coroutines with clear suspension points. There is no objectively "best" approach — each makes tradeoffs appropriate to its ecosystem, performance requirements, and target audience.

> **Sources:** [Bob Nystrom — "What Color is Your Function?"](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/) · [Yoshua Wuyts — "Async cancellation"](https://blog.yoshuawuyts.com/async-cancellation-1/) · [Without Boats — "Why async Rust?"](https://without.boats/blog/why-async-rust/) · Matthews (2024) Ch.8 pp. 174–180 · Ramalho (2022) Ch.21 pp. 825–827 · Slatkin (2025) Item 77 pp. 381–389

---

## Sources

### Books

**Rust**
- Gjengset (2022) — *Rust for Rustaceans*: Ch.8 pp. 117–140 (async fundamentals, `Future`, `Pin`, waking, tasks), Ch.10 pp. 175–176 (asynchrony and parallelism)
- Matthews (2024) — *Code Like a Pro in Rust*: Ch.8 pp. 157–180 (practical async, Tokio, mixing sync/async, tracing, testing)
- Blandy & Orendorff (2017) — *Programming Rust*: Ch.19 pp. 457–497 (threads, channels, `Send`/`Sync` — background for async)

**Java**
- Rahman (2025) — *Modern Concurrency in Java*: Ch.1 pp. 1–30 (history, `CompletableFuture`, virtual threads promise), Ch.2 pp. 31–89 (virtual threads deep dive), Ch.3 pp. 91–123 (executor framework, continuation, I/O polling), Ch.4 pp. 125–214 (structured concurrency), Ch.6 pp. 247–294 (reactive vs virtual threads)
- Goetz (2006) — *Java Concurrency in Practice*: Ch.5 pp. 79–110 (blocking queues, `FutureTask`), Ch.6 pp. 113–134 (task execution, Executor framework), Ch.7 pp. 135–166 (cancellation and shutdown)
- Lea (1999) — *Concurrent Programming in Java*: Ch.3 pp. 149–290 (state dependence, concurrency control), Ch.4 pp. 291–382 (creating threads, parallel decomposition)
- Evans et al (2022) — *The Well-Grounded Java Developer*: Ch.6 pp. 169–205 (concurrent collections, `Future`, `CompletableFuture`), Ch.16 pp. 537–570 (Fork/Join, `CompletableFuture`, coroutines), Ch.18 pp. 609–635 (Project Loom, virtual threads)

**Python**
- Ramalho (2022) — *Fluent Python*: Ch.17 pp. 593–652 (generators, classic coroutines, `yield from`), Ch.19 pp. 695–738 (concurrency models, GIL), Ch.20 pp. 743–772 (concurrent executors), Ch.21 pp. 775–828 (asyncio, async generators, comprehensions)
- Slatkin (2025) — *Effective Python*: Item 75 pp. 364–368 (coroutines for concurrent I/O), Item 76 pp. 368–381 (porting threaded I/O to asyncio), Item 77 pp. 381–389 (mixing threads and coroutines), Item 78 pp. 389–393 (async-friendly worker threads), Item 79 pp. 393–398 (`concurrent.futures` for parallelism)
- Shaw (2021) — *CPython Internals*: pp. 221–283 (GIL, generators, coroutines, async generators, subinterpreters)
- Hattingh (2020) — *Using Asyncio in Python*: Ch.1–2 pp. 1–20 (introducing asyncio), Ch.3 pp. 21–73 (coroutines, event loop, tasks, graceful shutdown), Ch.4 pp. 75–127 (asyncio libraries in practice)
- Beazley (2021) — *Python Distilled*: Ch.5.23 pp. 101–137 (async functions and `await`), Ch.6 pp. 139–152 (generators and the bridge to `async`/`await`), Ch.9.14 pp. 247–296 (blocking operations, asyncio)

### External Resources

**Rust**
- [The Rust Async Book — "Why Async?"](https://rust-lang.github.io/async-book/01_getting_started/01_chapter.html)
- [The Rust Async Book — "Under the Hood: Executing Futures and Tasks"](https://rust-lang.github.io/async-book/02_execution/01_chapter.html)
- [The Rust Async Book — "The Future Trait"](https://rust-lang.github.io/async-book/02_execution/02_future.html)
- [The Rust Async Book — "async/.await"](https://rust-lang.github.io/async-book/03_async_await/01_chapter.html)
- [The Rust Async Book — "Pinning"](https://rust-lang.github.io/async-book/04_pinning/01_chapter.html)
- [Rust RFC 2394 — `async`/`await` notation](https://rust-lang.github.io/rfcs/2394-async_await.html)
- [Rust RFC 2349 — Pin](https://rust-lang.github.io/rfcs/2349-pin.html)
- [Rust docs — `std::future::Future`](https://doc.rust-lang.org/std/future/trait.Future.html)
- [Rust docs — `std::task::Poll`](https://doc.rust-lang.org/std/task/enum.Poll.html)
- [Rust docs — `std::task::Context` and `Waker`](https://doc.rust-lang.org/std/task/struct.Context.html)
- [Rust docs — `std::pin::Pin`](https://doc.rust-lang.org/std/pin/struct.Pin.html)
- [Rust docs — `std::marker::Unpin`](https://doc.rust-lang.org/std/marker/trait.Unpin.html)
- [Rust Reference — `await` expression](https://doc.rust-lang.org/reference/expressions/await-expr.html)
- [Tokio tutorial](https://tokio.rs/tokio/tutorial)
- [Tokio blog — "Making the Tokio Scheduler 10x faster"](https://tokio.rs/blog/2019-10-scheduler)
- [Tokio docs — `select!` macro](https://tokio.rs/tokio/tutorial/select)
- [Tokio docs — Graceful Shutdown](https://tokio.rs/tokio/topics/shutdown)
- [Alice Ryhl — "Async: What is blocking?"](https://ryhl.io/blog/async-what-is-blocking/)
- [Tyler Mandry — "How Rust optimizes async/await"](https://tmandry.gitlab.io/blog/posts/optimizing-await-1/)
- [fasterthanlime — "Pin and suffering"](https://fasterthanli.me/articles/pin-and-suffering)
- [Without Boats — "Why async Rust?"](https://without.boats/blog/why-async-rust/)
- [`futures` crate — `Stream` trait](https://docs.rs/futures/latest/futures/stream/trait.Stream.html)
- [`tokio-stream` crate](https://docs.rs/tokio-stream/latest/tokio_stream/)
- [`async-stream` crate](https://docs.rs/async-stream/latest/async_stream/)
- [`pin-project` crate documentation](https://docs.rs/pin-project/latest/pin_project/)
- [async-std documentation](https://docs.rs/async-std/latest/async_std/)

**Java**
- [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444)
- [JEP 453 — Structured Concurrency (Preview)](https://openjdk.org/jeps/453)
- [Project Loom wiki](https://wiki.openjdk.org/display/loom/Main)
- [Inside.java — Virtual Threads tag](https://inside.java/tag/loom)
- [Java docs — `java.util.concurrent.Future`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Future.html)
- [Java docs — `java.util.concurrent.CompletableFuture`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CompletableFuture.html)
- [Java docs — `java.util.concurrent.Flow`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Flow.html)
- [Java docs — `Thread.interrupt()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html#interrupt())
- [Java docs — `Future.cancel()`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Future.html#cancel(boolean))
- [Baeldung — Guide to CompletableFuture](https://www.baeldung.com/java-completablefuture)
- [Cay Horstmann — "Java's Virtual Threads"](https://horstmann.com/unblog/2024-01-03/index.html)
- [Ron Pressler — "Why Continuations are Coming to Java"](https://inside.java/2020/08/07/loom-performance/)
- [Netty user guide](https://netty.io/wiki/user-guide-for-4.x.html)
- [Project Reactor reference](https://projectreactor.io/docs/core/release/reference/)
- [Project Reactor reference — Backpressure](https://projectreactor.io/docs/core/release/reference/#reactive.backpressure)
- [Reactive Streams specification](https://www.reactive-streams.org/)

**Python**
- [PEP 492 — Coroutines with async and await syntax](https://peps.python.org/pep-0492/)
- [PEP 3156 — Asynchronous I/O Support Rebooted: the "asyncio" Module](https://peps.python.org/pep-3156/)
- [PEP 525 — Asynchronous Generators](https://peps.python.org/pep-0525/)
- [PEP 654 — Exception Groups and `except*`](https://peps.python.org/pep-0654/)
- [Python docs — asyncio — Asynchronous I/O](https://docs.python.org/3/library/asyncio.html)
- [Python docs — Coroutines and Tasks](https://docs.python.org/3/library/asyncio-task.html)
- [Python docs — `asyncio.Future`](https://docs.python.org/3/library/asyncio-future.html)
- [Python docs — Awaitables](https://docs.python.org/3/library/asyncio-task.html#awaitables)
- [Python docs — `Task.cancel()`](https://docs.python.org/3/library/asyncio-task.html#asyncio.Task.cancel)
- [Python docs — `TaskGroup`](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup)
- [Python docs — Event Loop](https://docs.python.org/3/library/asyncio-eventloop.html)
- [Python docs — `concurrent.futures`](https://docs.python.org/3/library/concurrent.futures.html)
- [Python docs — Await expression](https://docs.python.org/3/reference/expressions.html#await)
- [Python docs — `async for` statement](https://docs.python.org/3/reference/compound_stmts.html#the-async-for-statement)
- [Python docs — Asynchronous Generators](https://docs.python.org/3/reference/expressions.html#asynchronous-generator-functions)
- [Python docs — Developing with asyncio](https://docs.python.org/3/library/asyncio-dev.html)
- [Brett Cannon — "How the heck does async/await work in Python 3.5?"](https://snarky.ca/how-the-heck-does-async-await-work-in-python-3-5/)
- [uvloop — Ultra fast asyncio event loop](https://github.com/MagicStack/uvloop)

**Cross-Language**
- [Bob Nystrom — "What Color is Your Function?"](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/)
- [Yoshua Wuyts — "Async cancellation"](https://blog.yoshuawuyts.com/async-cancellation-1/)

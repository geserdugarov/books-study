# Layer 4 · Topic 12 — Concurrency & Parallelism

> How each language approaches concurrent and parallel execution — from Rust's compile-time "fearless concurrency" enforced by Send/Sync marker traits, through Java's rich shared-memory threading model with virtual threads and structured concurrency, to Python's GIL-constrained threading with multiprocessing as the escape hatch and free-threaded Python on the horizon.

---

## 1. Concurrency Model Philosophy and Thread Basics

Each language embodies a distinct philosophy toward concurrent execution. Rust enforces safety at compile time through its ownership system — if a concurrent program compiles, it is free of data races. Java provides a shared-memory model with true OS-level parallelism and rich runtime synchronization primitives, relying on programmer discipline (and libraries) for correctness. Python, constrained by the Global Interpreter Lock (GIL), provides concurrent interleaving for I/O-bound work but requires multiprocessing or C extensions for CPU-bound parallelism.

### Rust: Fearless Concurrency

Rust's concurrency model is called "fearless" because the ownership system and type system prevent data races at compile time. `std::thread::spawn` takes a closure and returns a `JoinHandle`. The closure must be `'static` (own all its data) unless scoped threads are used. The compiler rejects code that would share mutable references across threads without synchronization.

```rust
use std::thread;

// Basic thread spawning — the closure must own its data (move)
fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    let handle = thread::spawn(move || {
        // `numbers` is moved into the thread's closure
        let sum: i32 = numbers.iter().sum();
        println!("Sum: {sum}");
        sum
    });

    // join() returns Result<T, Box<dyn Any>> — panics are propagated
    let result = handle.join().unwrap();
    println!("Thread returned: {result}");
}

// Scoped threads (Rust 1.63+) — threads can borrow from the parent stack
fn scoped_example() {
    let mut data = vec![1, 2, 3];

    thread::scope(|s| {
        s.spawn(|| {
            // Can borrow `data` immutably — scope guarantees join before return
            println!("Thread sees: {data:?}");
        });
    });
    // All scoped threads have joined here — safe to use `data` again
    data.push(4);
}
```

Key concepts:

- **Ownership prevents data races.** The compiler enforces that mutable data is either owned by one thread or shared through synchronization primitives. If it compiles, it is free of data races.
- **`move` closures** transfer ownership of captured variables into the spawned thread, satisfying the `'static` lifetime requirement.
- **Scoped threads** (`std::thread::scope`, stabilized in Rust 1.63) relax the `'static` requirement: threads in a scope can borrow from the parent's stack because the scope guarantees all threads join before returning.
- **Error propagation** via `JoinHandle::join()` returns `Result<T, Box<dyn Any>>` — thread panics are caught and can be inspected by the parent.

> **Sources:** Bos (2023) Ch.1 pp. 1–6 · Klabnik & Nichols (2023) Ch.16 pp. 353–360 · Blandy & Orendorff (2017) Ch.19 pp. 457–459 · [The Rust Book — Fearless Concurrency](https://doc.rust-lang.org/book/ch16-00-concurrency.html) · [Rust By Example — Threads](https://doc.rust-lang.org/rust-by-example/std_misc/threads.html)

### Java: Shared-Memory Threading from 1.0 to Virtual Threads

Java has had threads since version 1.0 (1996) — every Java program is multithreaded (GC threads, finalizer thread, JIT compiler thread). Traditional Java threads are 1:1 mapped to OS threads (platform threads), making them expensive to create (~1MB stack each). Java's concurrency philosophy is shared-memory with cooperative synchronization: any thread can access any heap object, and programmers use `synchronized`, `volatile`, and `java.util.concurrent` to manage access. Project Loom (Java 21) introduced virtual threads — lightweight threads (M:N scheduled onto platform threads) that make thread-per-request practical at massive scale.

```java
// Platform thread — 1:1 with OS thread, ~1MB stack
Thread platformThread = new Thread(() -> {
    System.out.println("Running on: " + Thread.currentThread());
});
platformThread.start();
platformThread.join();

// Virtual thread (Java 21) — lightweight, M:N scheduled
Thread virtualThread = Thread.startVirtualThread(() -> {
    System.out.println("Virtual: " + Thread.currentThread());
});
virtualThread.join();

// Using Thread.Builder for named threads
Thread named = Thread.ofVirtual()
    .name("worker-", 0)
    .start(() -> {
        System.out.println("Named virtual thread");
    });

// Creating many virtual threads is cheap (millions are feasible)
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (int i = 0; i < 100_000; i++) {
        executor.submit(() -> {
            Thread.sleep(Duration.ofSeconds(1));
            return "done";
        });
    }
}
```

Key concepts:

- **Platform threads** are 1:1 OS threads. Expensive to create (~1MB stack), limited to thousands. Java's traditional concurrency model.
- **Virtual threads** (Java 21, JEP 444) are M:N scheduled onto a pool of carrier (platform) threads using `ForkJoinPool`. Initial stack ~1KB, grows as needed. When a virtual thread blocks on I/O, it is "unmounted" from its carrier thread, freeing it for other virtual threads.
- **Every Java program is multithreaded** — GC, finalizer, JIT compiler threads run alongside application threads.
- **No compile-time safety** — Java has no mechanism like Rust's `Send`/`Sync` to prevent data races at compile time. Correctness depends on programmer discipline and proper use of synchronization.
- **Lea's design forces** shape concurrent Java programs: safety (no corrupted state), liveness (threads make progress), and performance (minimal synchronization overhead).

> **Sources:** Goetz (2006) Ch.1 pp. 1–12 · Lea (1999) Ch.1 pp. 1–20 · Rahman (2025) Ch.1 pp. 1–30 · [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444) · [Oracle Tutorial — Concurrency](https://docs.oracle.com/javase/tutorial/essential/concurrency/) · [Baeldung — Introduction to Thread Safety in Java](https://www.baeldung.com/java-thread-safety)

### Python: GIL-Constrained Threading

Python (CPython) has the Global Interpreter Lock (GIL), a mutex that allows only one thread to execute Python bytecode at a time. This means Python threads provide concurrency (interleaving) but not parallelism for CPU-bound work. Threads are useful for I/O-bound work because the GIL is released during I/O operations, C extension calls, and `time.sleep`.

```python
import threading
import time

# Basic thread creation
def worker(name, delay):
    print(f"{name} starting")
    time.sleep(delay)  # GIL is released during sleep
    print(f"{name} done")

# Threads are real OS threads, but the GIL limits CPU parallelism
t1 = threading.Thread(target=worker, args=("Thread-1", 1))
t2 = threading.Thread(target=worker, args=("Thread-2", 1))
t1.start()
t2.start()
t1.join()  # Wait for completion
t2.join()

# Daemon threads are killed when the main thread exits
daemon = threading.Thread(target=worker, args=("Daemon", 5), daemon=True)
daemon.start()
# daemon is killed when main thread exits — no need to join

# CPU-bound work gets NO speedup from threads (GIL contention)
def cpu_bound():
    total = 0
    for i in range(10_000_000):
        total += i
    return total

# For CPU-bound parallelism, use multiprocessing instead
from multiprocessing import Process

def cpu_worker(n):
    return sum(range(n))

p = Process(target=cpu_worker, args=(10_000_000,))
p.start()
p.join()
```

Key concepts:

- **The GIL** allows only one thread to execute Python bytecode at a time. Threads provide concurrency (interleaving) but not CPU parallelism.
- **I/O-bound work benefits from threads** — the GIL is released during I/O syscalls, allowing other threads to run.
- **CPU-bound work gets zero speedup from threads** — threads actually slow down due to GIL contention. Use `multiprocessing` for CPU parallelism.
- **Thread exceptions do not propagate** to the parent — they kill the thread silently unless caught, unlike Rust's `join()`, which returns `Result`.
- **Daemon threads** (`daemon=True`) are killed when the main thread exits, useful for background tasks.

> **Sources:** Ramalho (2022) Ch.19 pp. 695–714 · Hattingh (2020) Ch.2 pp. 9–20 · Beazley (2021) Ch.9.14 pp. 247–260 · [Python docs — `threading` module](https://docs.python.org/3/library/threading.html) · [Python docs — Concurrency](https://docs.python.org/3/library/concurrency.html) · [Real Python — An Intro to Threading in Python](https://realpython.com/intro-to-python-threading/)

### Cross-Language Comparison

The three languages represent a trade-off triangle. Rust maximizes safety (compile-time data race prevention, zero runtime overhead). Java maximizes flexibility and performance (true OS threads, now virtual threads, rich synchronization library). Python maximizes simplicity (GIL makes many operations implicitly thread-safe at the cost of parallelism).

Thread creation syntax reflects these philosophies:
- **Rust:** `thread::spawn(move || { ... })` — closure-based, compiler checks data ownership
- **Java:** `Thread.startVirtualThread(() -> { ... })` — any Runnable, no compile-time safety
- **Python:** `threading.Thread(target=fn, args=(...)).start()` — any callable, GIL provides implicit atomicity for single bytecode ops

---

## 2. The GIL: What It Is, Free-Threaded Python (PEP 703)

The Global Interpreter Lock is CPython's most controversial design choice. It simplifies the interpreter implementation and protects reference counting, but it prevents true parallelism in pure Python code. PEP 703 (accepted 2023) introduces free-threaded CPython builds where the GIL is optional, representing the biggest change to CPython since Python 3.0.

### The GIL in Depth

The GIL exists because CPython's memory management uses reference counting. Every `Py_INCREF`/`Py_DECREF` would need to be atomic without the GIL, which would slow down single-threaded code (the common case) by 30–40%. The GIL is acquired/released every 5ms (configurable via `sys.setswitchinterval`), not per bytecode instruction.

```python
import sys
import threading
import time

# The GIL switch interval (default 5ms)
print(sys.getswitchinterval())  # 0.005

# Demonstrating GIL impact on CPU-bound work
def count(n):
    while n > 0:
        n -= 1

# Sequential: two tasks run one after another
start = time.perf_counter()
count(100_000_000)
count(100_000_000)
sequential = time.perf_counter() - start

# Threaded: two threads, but GIL serializes execution
start = time.perf_counter()
t1 = threading.Thread(target=count, args=(100_000_000,))
t2 = threading.Thread(target=count, args=(100_000_000,))
t1.start(); t2.start()
t1.join(); t2.join()
threaded = time.perf_counter() - start

# threaded >= sequential (threads add overhead with no parallelism)
print(f"Sequential: {sequential:.2f}s, Threaded: {threaded:.2f}s")

# Process-based parallelism bypasses the GIL
from multiprocessing import Process

start = time.perf_counter()
p1 = Process(target=count, args=(100_000_000,))
p2 = Process(target=count, args=(100_000_000,))
p1.start(); p2.start()
p1.join(); p2.join()
parallel = time.perf_counter() - start
# parallel ≈ sequential / 2 (true parallelism)
print(f"Parallel (processes): {parallel:.2f}s")
```

Key concepts:

- **Reference counting drives the GIL.** Every Python object has a reference count. Without the GIL, every `Py_INCREF`/`Py_DECREF` would need atomic operations, slowing single-threaded code by 30–40%.
- **The GIL is released during I/O** — `read()`, `write()`, `socket` operations, `time.sleep()`, and C extension calls that explicitly release it (e.g., NumPy, Polars).
- **GIL contention degrades performance** — CPU-bound threaded code is slower than sequential due to context switching and lock acquisition overhead.
- **Many high-performance libraries already bypass the GIL** — NumPy, pandas, scikit-learn release the GIL in their C/Fortran/Rust backends. The GIL primarily constrains pure Python CPU-bound code.

> **Sources:** Ramalho (2022) Ch.19 pp. 713–724 · Shaw (2021) pp. 221–260 · [Python Wiki — Global Interpreter Lock](https://wiki.python.org/moin/GlobalInterpreterLock) · [Real Python — Python's GIL: A Guide to the Global Interpreter Lock](https://realpython.com/python-gil/)

### PEP 703: Free-Threaded Python

PEP 703 (Sam Gross, accepted 2023) makes the GIL optional. The `--disable-gil` build flag produces a CPython binary where threads achieve true parallelism. This is a phased rollout: Python 3.13 includes experimental free-threaded builds; Python 3.14+ refines the approach.

Key changes in free-threaded CPython:

- **Biased reference counting** replaces traditional reference counting — fast for the owning thread (no atomic operations), atomic for cross-thread references.
- **`mimalloc` allocator** replaces `pymalloc` — designed for concurrent allocation.
- **Per-object locks** replace the GIL for container operations — `dict` and `list` use fine-grained locking.
- **Lock-free reads** for `dict` and `list` — reads do not acquire locks.
- **C extensions must be updated** — extensions that assume single-threaded execution (the biggest migration challenge) need modifications to work without the GIL.

The `PYTHON_GIL=0` environment variable or `python -X gil=0` disables the GIL at runtime on free-threaded builds.

> **Sources:** [PEP 703 — Making the Global Interpreter Lock Optional in CPython](https://peps.python.org/pep-0703/) · [Python 3.13 What's New — Free-threaded CPython](https://docs.python.org/3.13/whatsnew/3.13.html#free-threaded-cpython) · [Python docs — Free-threaded CPython](https://docs.python.org/3.13/howto/free-threading-python.html) · [Sam Gross — nogil project](https://github.com/colesbury/nogil)

### How Rust and Java Avoid the GIL Problem

Rust avoids the need for a GIL through the ownership system. `Send` and `Sync` marker traits tell the compiler which types can cross thread boundaries. Reference counting (`Arc<T>`) uses atomic operations, but the compiler enforces this — you cannot accidentally use `Rc<T>` (non-atomic reference counting) across threads because `Rc<T>` does not implement `Send`.

Java avoids the need for a GIL because the JVM uses a tracing garbage collector (no reference counting), and the Java Memory Model (JMM) defines precisely when changes by one thread become visible to another. Java's `volatile` keyword and `synchronized` blocks provide the visibility guarantees that the GIL implicitly provides in Python.

Both Rust and Java demonstrate that a GIL is not inherent to programming languages — it is a CPython implementation choice driven by the simplicity of reference counting.

**Ecosystem implications:** Rust has no issue — all threads run in parallel, the compiler ensures safety. Java has no issue — all threads run in parallel, programmer ensures safety via synchronization. Python forces a choice: (a) threads for I/O concurrency, (b) multiprocessing for CPU parallelism, (c) C extensions that release the GIL, or (d) free-threaded Python 3.13+ (experimental).

> **Sources:** Bos (2023) Ch.1 pp. 16–17 · Goetz (2006) Ch.16 pp. 337–352 · Ramalho (2022) Ch.19 pp. 724–738

---

## 3. Thread Primitives and Lifecycle

Each language provides distinct thread creation, lifecycle, and joining APIs. The key differences lie in thread cost, error propagation, and whether scoped/structured lifetimes are supported.

### Rust: `std::thread` API

`std::thread::spawn` takes a `FnOnce() -> T + Send + 'static` closure and returns `JoinHandle<T>`. The `'static` bound means the closure must own all its data. Scoped threads relax this requirement.

```rust
use std::thread;
use std::time::Duration;

fn main() {
    // Named thread with builder
    let builder = thread::Builder::new()
        .name("worker".into())
        .stack_size(4 * 1024 * 1024); // 4MB stack

    let handle = builder.spawn(|| {
        println!("Thread name: {:?}", thread::current().name());
        thread::sleep(Duration::from_millis(100));
        42 // return value
    }).unwrap();

    // join() propagates panics as Err
    match handle.join() {
        Ok(value) => println!("Got: {value}"),
        Err(panic_payload) => println!("Thread panicked: {panic_payload:?}"),
    }

    // Scoped threads — can borrow from parent stack
    let shared_data = vec![1, 2, 3];
    let mut results = Vec::new();

    thread::scope(|s| {
        for chunk in shared_data.chunks(2) {
            let handle = s.spawn(move || -> i32 {
                chunk.iter().sum()
            });
            results.push(handle);
        }
    });
    // All threads guaranteed to have joined here
}
```

Key concepts:

- **`JoinHandle<T>`** carries the thread's return value. `join()` returns `Result<T, Box<dyn Any>>` — panics are caught and propagated.
- **Thread builder** allows setting name and stack size. Names appear in debugger and panic messages.
- **`'static` requirement** for `spawn` means the closure must own all captured data. Scoped threads (`thread::scope`) relax this.
- **Rayon's `join(a, b)`** is a higher-level fork-join API using a work-stealing thread pool, avoiding the overhead of OS thread creation.

> **Sources:** Bos (2023) Ch.1 pp. 2–6 · Klabnik & Nichols (2023) Ch.16 pp. 353–360 · Blandy & Orendorff (2017) Ch.19 pp. 459–468 · [Rust docs — `std::thread` module](https://doc.rust-lang.org/std/thread/) · [Rust docs — `thread::spawn`](https://doc.rust-lang.org/std/thread/fn.spawn.html) · [Rust docs — `thread::scope`](https://doc.rust-lang.org/std/thread/fn.scope.html)

### Java: Platform Threads vs Virtual Threads

Java 21 has two kinds of threads: platform threads (1:1 with OS threads, ~1MB stack, expensive) and virtual threads (M:N scheduled, ~1KB initial stack, cheap). Virtual threads are scheduled by the JVM onto a pool of carrier (platform) threads using `ForkJoinPool`. When a virtual thread blocks on I/O, it is "unmounted" from its carrier thread.

```java
// Platform thread — traditional, expensive
Thread platform = Thread.ofPlatform()
    .name("platform-worker")
    .start(() -> {
        System.out.println("Platform thread: " + Thread.currentThread());
    });
platform.join();

// Virtual thread — lightweight, cheap to create
Thread virtual = Thread.ofVirtual()
    .name("virtual-worker")
    .start(() -> {
        System.out.println("Virtual thread: " + Thread.currentThread());
        try {
            Thread.sleep(Duration.ofMillis(100)); // unmounts from carrier
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    });
virtual.join();

// Virtual threads should NOT be pooled — create one per task
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = new ArrayList<>();
    for (int i = 0; i < 1_000_000; i++) {
        futures.add(executor.submit(() -> {
            Thread.sleep(Duration.ofSeconds(1));
            return Thread.currentThread().toString();
        }));
    }
    // One million concurrent virtual threads is practical
}
```

Key concepts:

- **Virtual threads are M:N scheduled** — many virtual threads run on few carrier (platform) threads. The JVM scheduler manages mounting/unmounting.
- **Blocking unmounts the virtual thread** — when a virtual thread blocks on I/O or `Thread.sleep()`, its stack is saved and the carrier thread is freed for other virtual threads.
- **Do not pool virtual threads** — they are cheap to create. Use `Executors.newVirtualThreadPerTaskExecutor()` which creates a new virtual thread per task.
- **Same `Thread` API** — virtual threads share the same API as platform threads. Existing code works with minimal changes.
- **Pinning** occurs when a virtual thread holds a monitor lock (`synchronized`) or calls native code — it cannot unmount from the carrier. Use `ReentrantLock` instead of `synchronized` to avoid pinning.

> **Sources:** Rahman (2025) Ch.2 pp. 31–50 · Goetz (2006) Ch.6 pp. 113–117 · [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444) · [JEP 425 — Virtual Threads (Preview)](https://openjdk.org/jeps/425) · [Java docs — `java.lang.Thread`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html) · [Baeldung — Virtual Threads in Java 21](https://www.baeldung.com/java-virtual-thread-vs-thread) · [Inside Java — Loom](https://inside.java/tag/loom)

### Python: `threading.Thread`

Python threads are real OS threads (via `pthreads` on Unix, Windows threads on Windows), but the GIL limits CPU parallelism.

```python
import threading

# Basic thread with target function
def worker(name, result_list):
    """Thread target function."""
    value = sum(range(1000))
    result_list.append((name, value))  # list.append is GIL-atomic

results = []
threads = []
for i in range(4):
    t = threading.Thread(
        target=worker,
        args=(f"worker-{i}", results),
        name=f"Worker-{i}",  # name for debugging
    )
    threads.append(t)
    t.start()

for t in threads:
    t.join()

# Subclassing Thread (less common, target= is preferred)
class CounterThread(threading.Thread):
    def __init__(self, limit):
        super().__init__()
        self.limit = limit
        self.result = None

    def run(self):
        self.result = sum(range(self.limit))

ct = CounterThread(1_000_000)
ct.start()
ct.join()
print(ct.result)

# Thread identity and current thread
print(threading.current_thread().name)    # "MainThread"
print(threading.active_count())           # number of active threads
print(threading.enumerate())              # list of all active threads
```

Key concepts:

- **`target=` parameter** specifies the callable to run in the thread. Preferred over subclassing `Thread`.
- **`.start()` begins execution, `.join()` waits for completion.** `.join(timeout=n)` allows timed waiting.
- **Exceptions do not propagate** — an exception in a thread kills that thread silently unless caught. This differs from Rust where `join()` returns `Result`.
- **`threading.current_thread()`** returns the current thread object. Useful for debugging.
- **No scoped threads** — Python has no equivalent of Rust's `thread::scope`. Must manually join threads.

> **Sources:** Slatkin (2025) Item 68 pp. 324–330 · Slatkin (2025) Item 69 pp. 330–333 · [Python docs — `threading` module](https://docs.python.org/3/library/threading.html) · [Python docs — `threading.Thread`](https://docs.python.org/3/library/threading.html#thread-objects) · [Python docs — `_thread`](https://docs.python.org/3/library/_thread.html)

### Cross-Language Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| Thread creation cost | OS thread (minimal stack) | Platform: ~1MB OS thread; Virtual: ~1KB, no OS thread | OS thread + GIL coordination |
| Joining semantics | `join()` returns `Result` (panics propagated) | Exceptions propagated only via `Future.get()` | Exceptions lost silently |
| Scoped lifetimes | `thread::scope` (std, 1.63+) | `StructuredTaskScope` (preview) | None (manual join) |
| Named threads | `Builder::new().name(...)` | `Thread.ofVirtual().name(...)` | `Thread(name=...)` |

---

## 4. Shared State and Mutual Exclusion

All three languages provide primitives for protecting shared mutable state, but with fundamentally different enforcement models. Rust's `Mutex<T>` is data-oriented (the mutex owns the data). Java's `synchronized` and `ReentrantLock` are code-oriented (the lock protects a critical section). Python's `Lock` is convention-oriented (nothing enforces that you hold it before accessing shared data).

### Rust: `Mutex<T>`, `RwLock<T>`, `Arc<T>`

Rust's `Mutex<T>` wraps its data — you cannot access the protected data without locking the mutex. `mutex.lock()` returns a `MutexGuard<T>` that automatically unlocks when dropped (RAII).

```rust
use std::sync::{Arc, Mutex, RwLock, Condvar};
use std::thread;

// Arc<Mutex<T>> — the standard pattern for shared mutable state
fn shared_counter() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        handles.push(thread::spawn(move || {
            let mut num = counter.lock().unwrap(); // returns MutexGuard
            *num += 1;
            // MutexGuard dropped here — automatically unlocks
        }));
    }

    for h in handles { h.join().unwrap(); }
    println!("Counter: {}", *counter.lock().unwrap()); // 10
}

// RwLock — multiple readers OR one writer
fn reader_writer() {
    let data = Arc::new(RwLock::new(vec![1, 2, 3]));

    let data_read = Arc::clone(&data);
    let reader = thread::spawn(move || {
        let read_guard = data_read.read().unwrap(); // shared access
        println!("Read: {:?}", *read_guard);
    });

    let data_write = Arc::clone(&data);
    let writer = thread::spawn(move || {
        let mut write_guard = data_write.write().unwrap(); // exclusive access
        write_guard.push(4);
    });

    reader.join().unwrap();
    writer.join().unwrap();
}

// Condition variable — waiting for a condition
fn condvar_example() {
    let pair = Arc::new((Mutex::new(false), Condvar::new()));
    let pair_clone = Arc::clone(&pair);

    thread::spawn(move || {
        let (lock, cvar) = &*pair_clone;
        let mut ready = lock.lock().unwrap();
        *ready = true;
        cvar.notify_one(); // wake up the waiting thread
    });

    let (lock, cvar) = &*pair;
    let mut ready = lock.lock().unwrap();
    while !*ready {
        ready = cvar.wait(ready).unwrap(); // releases lock, waits, re-acquires
    }
    println!("Condition met!");
}
```

Key concepts:

- **`Mutex<T>` owns the data** — you get access only through the lock guard (`MutexGuard<T>`). This makes it impossible to forget to lock or to access data without locking.
- **`Arc<T>`** (atomic reference counting) enables shared ownership across threads. `Arc<Mutex<T>>` is the standard pattern.
- **Lock poisoning** — if a thread panics while holding a lock, the mutex is "poisoned." Subsequent `lock()` calls return `Err(PoisonError)`, signaling the protected data may be inconsistent.
- **`RwLock<T>`** allows multiple concurrent readers or one exclusive writer. Useful when reads vastly outnumber writes.
- **RAII unlocking** — `MutexGuard` implements `Drop`, so the lock is released when the guard goes out of scope. No risk of forgetting to unlock.

> **Sources:** Bos (2023) Ch.1 pp. 7–29 · Klabnik & Nichols (2023) Ch.16 pp. 365–374 · Blandy & Orendorff (2017) Ch.19 pp. 482–497 · [Rust docs — `std::sync::Mutex`](https://doc.rust-lang.org/std/sync/struct.Mutex.html) · [Rust docs — `std::sync::RwLock`](https://doc.rust-lang.org/std/sync/struct.RwLock.html) · [Rust docs — `std::sync::Arc`](https://doc.rust-lang.org/std/sync/struct.Arc.html) · [Rust docs — `std::sync::Condvar`](https://doc.rust-lang.org/std/sync/struct.Condvar.html)

### Java: `synchronized`, `ReentrantLock`, `volatile`

Java has two locking mechanisms: intrinsic locks (`synchronized`) and explicit locks (`ReentrantLock`). `synchronized` is built into the language — every object has an implicit monitor lock.

```java
// Intrinsic locks — synchronized blocks and methods
public class Counter {
    private int count = 0;

    // synchronized method — acquires `this` monitor
    public synchronized void increment() {
        count++;
    }

    // synchronized block — more fine-grained control
    public void incrementBlock() {
        synchronized (this) {
            count++;
        }
    }

    public synchronized int getCount() {
        return count;
    }
}

// ReentrantLock — more flexible than synchronized
import java.util.concurrent.locks.*;

public class FlexibleCounter {
    private final ReentrantLock lock = new ReentrantLock();
    private int count = 0;

    public void increment() {
        lock.lock();
        try {
            count++;
        } finally {
            lock.unlock(); // must manually unlock in finally
        }
    }

    // Timed lock attempt — not possible with synchronized
    public boolean tryIncrement(long timeout, TimeUnit unit)
            throws InterruptedException {
        if (lock.tryLock(timeout, unit)) {
            try {
                count++;
                return true;
            } finally {
                lock.unlock();
            }
        }
        return false;
    }
}

// volatile — visibility without atomicity
public class StopFlag {
    private volatile boolean stopped = false; // visible to all threads

    public void stop() { stopped = true; }

    public void run() {
        while (!stopped) {
            // do work
        }
    }
}

// ReadWriteLock — multiple readers or one writer
ReadWriteLock rwLock = new ReentrantReadWriteLock();
rwLock.readLock().lock();    // shared access
rwLock.readLock().unlock();
rwLock.writeLock().lock();   // exclusive access
rwLock.writeLock().unlock();
```

Key concepts:

- **Intrinsic locks (`synchronized`)** — every Java object has a monitor lock. `synchronized(obj) { ... }` acquires the monitor. Method-level `synchronized` acquires `this`. Intrinsic locks are reentrant (a thread can acquire the same lock multiple times).
- **`ReentrantLock`** (Java 5+) adds timed lock attempts (`tryLock(timeout)`), interruptible locking, fairness policies, and multiple condition queues. Requires manual `unlock()` in `finally`.
- **`volatile`** ensures visibility (changes immediately visible to all threads) but does not provide atomicity for compound operations (check-then-act, read-modify-write).
- **`ReadWriteLock`** (`ReentrantReadWriteLock`) allows multiple concurrent readers or one exclusive writer, like Rust's `RwLock`.
- **No lock poisoning** — Java and Python do not have Rust's panic-aware lock poisoning mechanism.

> **Sources:** Goetz (2006) Ch.2 pp. 15–31 · Goetz (2006) Ch.3 pp. 33–42 · Goetz (2006) Ch.13 pp. 277–289 · Lea (1999) Ch.2 pp. 57–100 · [Java docs — `java.util.concurrent.locks` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/package-summary.html) · [Baeldung — Guide to the Synchronized Keyword in Java](https://www.baeldung.com/java-synchronized) · [Baeldung — Guide to java.util.concurrent.Locks](https://www.baeldung.com/java-concurrent-locks)

### Java: State Dependence and Concurrency Utilities

Lea's treatment of state dependence establishes the design patterns behind Java's concurrency utilities: how to structure state-dependent actions, the semantics of guarded waits using `wait`/`notify`/`notifyAll`, and the principles that led to `java.util.concurrent.Semaphore`, `CountDownLatch`, and `CyclicBarrier`.

```java
// Synchronizers from java.util.concurrent

// CountDownLatch — wait for N events
CountDownLatch latch = new CountDownLatch(3);
for (int i = 0; i < 3; i++) {
    new Thread(() -> {
        // do work...
        latch.countDown(); // decrement count
    }).start();
}
latch.await(); // blocks until count reaches zero

// Semaphore — limit concurrent access to a resource
Semaphore semaphore = new Semaphore(3); // max 3 concurrent permits
semaphore.acquire(); // blocks if no permits available
try {
    // access limited resource
} finally {
    semaphore.release();
}

// CyclicBarrier — N threads wait for each other
CyclicBarrier barrier = new CyclicBarrier(3, () -> {
    System.out.println("All threads reached barrier");
});
for (int i = 0; i < 3; i++) {
    new Thread(() -> {
        // phase 1 work...
        barrier.await(); // blocks until all 3 threads arrive
        // phase 2 work...
    }).start();
}
```

> **Sources:** Lea (1999) Ch.3 pp. 149–220 · Goetz (2006) Ch.5 pp. 79–109 · [Java docs — `ReentrantLock`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantLock.html) · [Java docs — `ReentrantReadWriteLock`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantReadWriteLock.html)

### Python: `threading.Lock` and Friends

Python's `threading.Lock` is a simple mutex. Because of the GIL, Python locks primarily protect against data races in compound operations (check-then-act patterns), not against memory visibility issues.

```python
import threading

# Lock — simple mutex (not reentrant)
lock = threading.Lock()
counter = 0

def increment(n):
    global counter
    for _ in range(n):
        with lock:  # context manager acquires/releases automatically
            counter += 1  # not atomic: LOAD, ADD, STORE bytecodes

threads = [threading.Thread(target=increment, args=(100_000,))
           for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(counter)  # always 1_000_000 (protected by lock)

# RLock — reentrant lock (same thread can acquire multiple times)
rlock = threading.RLock()
def recursive_work(depth):
    with rlock:
        if depth > 0:
            recursive_work(depth - 1)

# Condition — wait/notify pattern
condition = threading.Condition()
queue = []

def producer():
    with condition:
        queue.append("item")
        condition.notify()  # wake up one waiting consumer

def consumer():
    with condition:
        while not queue:
            condition.wait()  # releases lock, waits, re-acquires
        item = queue.pop(0)

# Semaphore — limit concurrent access
semaphore = threading.Semaphore(3)  # max 3 concurrent threads

def limited_worker():
    with semaphore:
        # only 3 threads can be here simultaneously
        pass

# Event — one-bit flag for signaling
event = threading.Event()
# event.set()    — set the flag
# event.clear()  — clear the flag
# event.wait()   — block until the flag is set
# event.is_set() — check without blocking
```

Key concepts:

- **`Lock`** is a simple mutex (not reentrant). Use `with lock:` context manager for automatic acquire/release.
- **`RLock`** (reentrant lock) allows the same thread to acquire the lock multiple times. Use for recursive functions.
- **`Condition`** wraps a lock with `wait()`/`notify()`/`notify_all()` semantics. Same pattern as Java's `Object.wait()`/`notify()`.
- **`Semaphore`** limits access to a finite number of permits.
- **`counter += 1` is not atomic** — it compiles to multiple bytecodes (`LOAD_FAST`, `LOAD_CONST`, `BINARY_ADD`, `STORE_FAST`), so the GIL can switch threads between them. Locks are still necessary.

> **Sources:** Slatkin (2025) Item 69 pp. 330–333 · Ramalho (2022) Ch.19 pp. 699–701 · [Python docs — `threading.Lock`](https://docs.python.org/3/library/threading.html#lock-objects) · [Python docs — `threading.RLock`](https://docs.python.org/3/library/threading.html#rlock-objects) · [Python docs — `threading.Condition`](https://docs.python.org/3/library/threading.html#condition-objects) · [Python docs — `threading.Semaphore`](https://docs.python.org/3/library/threading.html#semaphore-objects)

### Comparison: Lock Semantics

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| Lock model | Data-oriented (`Mutex<T>` owns data) | Code-oriented (lock protects critical section) | Convention-oriented (nothing enforces lock usage) |
| Lock poisoning | Yes (panic-aware) | No | No |
| Reentrant locks | Not reentrant by default | `synchronized` and `ReentrantLock` are reentrant | `RLock` is reentrant; `Lock` is not |
| Timed lock | No (but `try_lock()` exists) | `tryLock(timeout)` | `Lock.acquire(timeout=)` |
| Deadlock detection | None built-in (ownership prevents many cases) | `ThreadMXBean.findDeadlockedThreads()` | None built-in |
| Unlocking | Automatic (RAII via `MutexGuard` drop) | Manual (`finally`) or automatic (`synchronized`) | Automatic (`with` statement) or manual |

---

## 5. Send/Sync Traits and Compile-Time Safety

Rust's approach to thread safety is unique among mainstream languages: the `Send` and `Sync` marker traits encode thread-safety properties into the type system, allowing the compiler to prevent data races statically. Java and Python take runtime approaches — the Java Memory Model (JMM) defines visibility rules, while Python's GIL provides implicit sequential consistency.

### Rust: `Send` and `Sync` in Depth

`Send` means a type can be transferred to another thread (ownership can move). `Sync` means a type can be referenced from multiple threads simultaneously (i.e., `&T` is `Send` if `T` is `Sync`). These are auto-traits: the compiler derives them automatically from the fields of a struct.

```rust
use std::sync::{Arc, Mutex};
use std::cell::RefCell;
use std::rc::Rc;

// Rc<T> is NOT Send — non-atomic reference counting is unsafe across threads
// This fails to compile:
// let rc = Rc::new(42);
// std::thread::spawn(move || println!("{}", rc)); // error: Rc<i32> is not Send

// Arc<T> IS Send and Sync — atomic reference counting
let arc = Arc::new(42);
std::thread::spawn(move || println!("{}", arc)); // OK

// RefCell<T> is Send but NOT Sync — non-atomic interior mutability
// Can move it to a thread, but cannot share references across threads
let cell = RefCell::new(42);
std::thread::spawn(move || {
    *cell.borrow_mut() = 43; // OK — we own the RefCell
});

// Mutex<T> makes any Send type Sync
// If T: Send, then Mutex<T>: Send + Sync
let mutex = Arc::new(Mutex::new(vec![1, 2, 3]));
let m2 = Arc::clone(&mutex);
std::thread::spawn(move || {
    mutex.lock().unwrap().push(4); // OK — Mutex provides synchronized access
});

// Composability: a struct is Send if all its fields are Send
struct MyData {
    value: i32,        // i32: Send + Sync
    name: String,      // String: Send + Sync
}
// MyData is automatically Send + Sync

struct NotSendData {
    rc: Rc<i32>,       // Rc: !Send
}
// NotSendData is automatically !Send — compiler prevents sharing

// Escape hatch: unsafe impl Send
struct RawPointerWrapper(*mut i32);
unsafe impl Send for RawPointerWrapper {}
// "I guarantee this is safe to send across threads"
```

Key concepts:

- **Auto-traits** — `Send` and `Sync` are derived automatically. A struct is `Send` if all fields are `Send`. No annotation needed.
- **`Rc<T>` is `!Send`** — non-atomic reference counting is unsafe across threads. The compiler prevents sharing.
- **`Arc<T>` is `Send + Sync`** — atomic reference counting is safe across threads.
- **`Cell<T>` and `RefCell<T>` are `Send` but `!Sync`** — non-atomic interior mutability can be moved to a thread but not shared.
- **`Mutex<T>` makes `T: Send` into `Sync`** — by wrapping data in a mutex, it becomes safely shareable.
- **`unsafe impl Send`** is the escape hatch for types wrapping raw pointers. The programmer manually guarantees thread safety.
- **Rust's safety is opt-out** (everything is checked unless `unsafe` is used), while Java/Python safety is opt-in (nothing is checked unless synchronization is added).

> **Sources:** Bos (2023) Ch.1 pp. 16–17 · Klabnik & Nichols (2023) Ch.16 pp. 372–374 · Gjengset (2022) Ch.10 pp. 167–175 · Blandy & Orendorff (2017) Ch.19 pp. 479–482 · [The Rustonomicon — Send and Sync](https://doc.rust-lang.org/nomicon/send-and-sync.html) · [The Rust Reference — Send and Sync](https://doc.rust-lang.org/reference/special-types-and-traits.html) · [Rust docs — `std::marker::Send`](https://doc.rust-lang.org/std/marker/trait.Send.html) · [Rust docs — `std::marker::Sync`](https://doc.rust-lang.org/std/marker/trait.Sync.html) · [Niko Matsakis — "Fearless Concurrency with Rust"](https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html)

### Java: The Java Memory Model (JMM)

Java's thread safety relies on the Java Memory Model (JMM, JLS Chapter 17), which defines happens-before relationships. Without synchronization, changes by one thread may never become visible to another thread due to compiler/CPU reordering and CPU caching.

```java
// Without synchronization — visibility is NOT guaranteed
public class BrokenVisibility {
    private boolean ready = false;  // NOT volatile
    private int number = 0;

    // Writer thread
    void writer() {
        number = 42;
        ready = true;
    }

    // Reader thread — may see ready=true but number=0
    // due to reordering or caching
    void reader() {
        if (ready) {
            System.out.println(number); // might print 0!
        }
    }
}

// With volatile — establishes happens-before
public class FixedVisibility {
    private volatile boolean ready = false;
    private int number = 0;

    void writer() {
        number = 42;      // happens-before the volatile write
        ready = true;      // volatile write
    }

    void reader() {
        if (ready) {       // volatile read
            // guaranteed to see number = 42
            System.out.println(number); // always prints 42
        }
    }
}
```

Key happens-before rules:

- **Monitor lock:** unlock on a monitor happens-before every subsequent lock on that same monitor.
- **`volatile`:** a write to a volatile field happens-before every subsequent read of that field.
- **`Thread.start()`** happens-before any action in the started thread.
- **`Thread.join()`** — all actions in a thread happen-before `join()` returns.
- **Transitivity:** if A happens-before B and B happens-before C, then A happens-before C.

Unlike Rust, Java has no compile-time enforcement of these rules. Incorrect programs compile and run but produce subtle, non-deterministic bugs.

> **Sources:** Goetz (2006) Ch.16 pp. 337–352 · [Java Language Specification — Threads and Locks (JLS Ch.17)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html) · [Baeldung — The volatile Keyword in Java](https://www.baeldung.com/java-volatile)

### Python: Implicit Safety Through the GIL

Python's GIL provides a form of implicit sequential consistency — all bytecode operations appear to execute in a total order. Python has no equivalent of Java's visibility problem where unsynchronized reads see stale values. However, the GIL does not make compound operations atomic.

```python
# These are effectively atomic under the GIL (single bytecode ops):
my_list.append(x)        # single CALL_METHOD bytecode
my_dict[key] = value     # single STORE_SUBSCR bytecode
x = shared_var           # single LOAD_FAST / STORE_FAST

# These are NOT atomic (multiple bytecodes):
counter += 1             # LOAD, LOAD_CONST, BINARY_ADD, STORE
my_list[0] = my_list[0] + 1  # LOAD, LOAD, ADD, STORE

# IMPORTANT: GIL atomicity guarantees are CPython implementation details,
# not language guarantees. Free-threaded Python (PEP 703), PyPy, and
# GraalPy may not preserve them.
```

Key concepts:

- **No visibility problem** — the GIL ensures that all threads see a consistent view of memory (no stale caches).
- **Compound operations still need locks** — `counter += 1` is read-modify-write across multiple bytecodes.
- **Implementation detail, not guarantee** — GIL atomicity is specific to CPython. Other implementations and free-threaded Python may behave differently.
- **No thread-safety annotations** — Python has no equivalent of Java's `@ThreadSafe`/`@GuardedBy` or Rust's `Send`/`Sync`.

> **Sources:** Ramalho (2022) Ch.19 pp. 699–701 · Shaw (2021) pp. 221–260

### Who Catches the Bugs?

| Language | Data race prevention | Mechanism | Developer burden |
|----------|---------------------|-----------|-----------------|
| Rust | Compile time | `Send`/`Sync` type system | Low — compiler catches errors |
| Java | Runtime + tooling | JMM + `synchronized`/`volatile` + static analyzers (FindBugs, ErrorProne) | High — programmer must understand happens-before |
| Python | Runtime (GIL) | GIL for simple ops + manual locks for compound ops | Medium — GIL hides many issues |

Rust prevents data races but not all race conditions — logical races like TOCTOU (time-of-check-to-time-of-use) are still possible. Java's `@ThreadSafe` and `@NotThreadSafe` annotations are documentation, not enforcement. Python has no thread safety annotations.

---

## 6. Lock-Free Programming and Atomics

Atomic operations provide lock-free synchronization — they complete in a single indivisible step at the hardware level, without requiring a mutex. Each language offers a different level of control over atomics.

### Rust: `std::sync::atomic` with Memory Orderings

Rust's atomics require specifying a memory ordering for every operation, providing fine-grained control over what other memory accesses become visible.

```rust
use std::sync::atomic::{AtomicBool, AtomicUsize, AtomicI64, Ordering};
use std::sync::Arc;
use std::thread;

// Stop flag — Relaxed is sufficient (only atomicity needed)
fn stop_flag_example() {
    let stop = Arc::new(AtomicBool::new(false));
    let stop_clone = Arc::clone(&stop);

    let worker = thread::spawn(move || {
        while !stop_clone.load(Ordering::Relaxed) {
            // do work
        }
        println!("Worker stopped");
    });

    thread::sleep(std::time::Duration::from_millis(100));
    stop.store(true, Ordering::Relaxed);
    worker.join().unwrap();
}

// Progress reporting with fetch_add
fn progress_example() {
    let counter = Arc::new(AtomicUsize::new(0));
    let mut handles = vec![];

    for _ in 0..4 {
        let counter = Arc::clone(&counter);
        handles.push(thread::spawn(move || {
            for _ in 0..1000 {
                counter.fetch_add(1, Ordering::Relaxed);
            }
        }));
    }

    for h in handles { h.join().unwrap(); }
    println!("Total: {}", counter.load(Ordering::Relaxed)); // 4000
}

// Lazy initialization with Acquire/Release
use std::sync::atomic::AtomicPtr;
use std::ptr;

fn lazy_init() {
    static VALUE: AtomicPtr<String> = AtomicPtr::new(ptr::null_mut());

    fn get_value() -> &'static String {
        let mut ptr = VALUE.load(Ordering::Acquire);
        if ptr.is_null() {
            let new = Box::into_raw(Box::new("initialized".to_string()));
            match VALUE.compare_exchange(
                ptr::null_mut(), new,
                Ordering::Release, Ordering::Acquire,
            ) {
                Ok(_) => ptr = new,
                Err(existing) => {
                    // Another thread beat us — drop our allocation
                    unsafe { drop(Box::from_raw(new)); }
                    ptr = existing;
                }
            }
        }
        unsafe { &*ptr }
    }
}

// Compare-and-exchange for lock-free ID allocation
fn id_allocation() {
    let next_id = Arc::new(AtomicUsize::new(0));

    let id = next_id.fetch_add(1, Ordering::Relaxed);
    println!("Allocated ID: {id}");

    // With overflow check using compare_exchange
    loop {
        let current = next_id.load(Ordering::Relaxed);
        if current == usize::MAX {
            panic!("ID overflow");
        }
        match next_id.compare_exchange(
            current, current + 1,
            Ordering::Relaxed, Ordering::Relaxed,
        ) {
            Ok(_) => break,
            Err(_) => continue, // another thread modified — retry
        }
    }
}
```

The five memory orderings:

- **`Relaxed`** — only guarantees atomicity. No ordering of surrounding operations. Sufficient for counters and flags.
- **`Acquire`** — subsequent reads/writes cannot be reordered before this load. Pairs with `Release`.
- **`Release`** — preceding reads/writes cannot be reordered after this store. Pairs with `Acquire`.
- **`AcqRel`** — both `Acquire` and `Release`. Used for read-modify-write operations.
- **`SeqCst`** — total global order across all threads. Most expensive, easiest to reason about.

The critical insight: memory ordering affects surrounding non-atomic operations, not the atomic operation itself. `Relaxed` atomics are always atomic; the ordering controls what other memory accesses become visible.

> **Sources:** Bos (2023) Ch.2 pp. 31–47 · Bos (2023) Ch.3 pp. 49–73 · Gjengset (2022) Ch.10 pp. 179–188 · [Rust docs — `std::sync::atomic` module](https://doc.rust-lang.org/std/sync/atomic/) · [Rust docs — `Ordering` enum](https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html) · [`crossbeam` crate documentation](https://docs.rs/crossbeam/latest/crossbeam/)

### Java: `java.util.concurrent.atomic` and CAS

Java's atomic classes provide compare-and-set (CAS) operations. They use a single memory ordering model (roughly equivalent to Rust's `SeqCst`) unless `VarHandle` is used for explicit ordering modes.

```java
import java.util.concurrent.atomic.*;

// AtomicInteger — lock-free counter
AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();      // atomic increment, returns new value
counter.getAndAdd(5);           // atomic add, returns old value
int current = counter.get();    // atomic read

// Compare-and-set — foundational CAS operation
AtomicInteger value = new AtomicInteger(0);
boolean success = value.compareAndSet(0, 42); // if value==0, set to 42
// success == true, value is now 42

// CAS retry loop — common pattern for lock-free updates
AtomicInteger max = new AtomicInteger(Integer.MIN_VALUE);
void updateMax(int candidate) {
    int current;
    do {
        current = max.get();
        if (candidate <= current) return;
    } while (!max.compareAndSet(current, candidate));
}

// AtomicReference — CAS on object references
AtomicReference<String> ref = new AtomicReference<>("initial");
ref.compareAndSet("initial", "updated");

// Lock-free stack using AtomicReference (Treiber stack)
class ConcurrentStack<E> {
    private final AtomicReference<Node<E>> top = new AtomicReference<>();

    void push(E item) {
        Node<E> newHead = new Node<>(item);
        Node<E> oldHead;
        do {
            oldHead = top.get();
            newHead.next = oldHead;
        } while (!top.compareAndSet(oldHead, newHead));
    }

    E pop() {
        Node<E> oldHead;
        Node<E> newHead;
        do {
            oldHead = top.get();
            if (oldHead == null) return null;
            newHead = oldHead.next;
        } while (!top.compareAndSet(oldHead, newHead));
        return oldHead.item;
    }

    private static class Node<E> {
        final E item;
        Node<E> next;
        Node(E item) { this.item = item; }
    }
}

// VarHandle (Java 9+) — explicit memory ordering modes
import java.lang.invoke.MethodHandles;
import java.lang.invoke.VarHandle;

class VarHandleExample {
    private int value;
    private static final VarHandle VALUE;
    static {
        try {
            VALUE = MethodHandles.lookup()
                .findVarHandle(VarHandleExample.class, "value", int.class);
        } catch (Exception e) { throw new Error(e); }
    }

    void setRelease(int v) { VALUE.setRelease(this, v); }
    int getAcquire()       { return (int) VALUE.getAcquire(this); }
    int getOpaque()        { return (int) VALUE.getOpaque(this); }  // like Relaxed
}
```

Key concepts:

- **`AtomicInteger`, `AtomicLong`, `AtomicReference`** — provide CAS-based atomic operations.
- **`compareAndSet(expected, newValue)`** — atomically updates only if the current value matches `expected`. Foundation for lock-free algorithms.
- **CAS retry loop** — the standard pattern: read current, compute new, CAS, retry on failure.
- **`VarHandle`** (Java 9+) — more flexible alternative to atomic classes, supporting different access modes (plain, opaque, acquire/release, volatile). Like Rust, allows choosing memory ordering.
- **Default strong ordering** — standard atomic classes use roughly `SeqCst` ordering. `VarHandle` is needed for weaker orderings.

> **Sources:** Goetz (2006) Ch.15 pp. 319–335 · [Java docs — `java.util.concurrent.atomic` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/package-summary.html) · [Java docs — `VarHandle`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/invoke/VarHandle.html) · [Baeldung — Introduction to Lock-Free Data Structures](https://www.baeldung.com/lock-free-programming) · [Doug Lea — "The java.util.concurrent Synchronizer Framework"](https://gee.cs.oswego.edu/dl/papers/aqs.pdf)

### Python: Limited Atomics Under the GIL

CPython does not have a standard atomic types library. The GIL makes certain operations implicitly atomic — single bytecode operations like `list.append(x)` and `dict[key] = value` — but this is an implementation detail, not a language guarantee.

```python
import queue
import threading

# queue.Queue — the primary thread-safe data structure in Python
q = queue.Queue(maxsize=100)  # bounded queue

# Producer
def producer():
    for i in range(10):
        q.put(i)  # blocks if full
    q.put(None)   # sentinel to signal completion

# Consumer
def consumer():
    while True:
        item = q.get()  # blocks if empty
        if item is None:
            break
        print(f"Got: {item}")
        q.task_done()  # signal that processing is complete

# threading.Event — a simple one-bit flag
event = threading.Event()

def waiter():
    event.wait()  # blocks until set
    print("Event fired!")

def setter():
    event.set()  # unblocks all waiters

# With free-threaded Python (PEP 703), true atomic primitives become
# necessary — this is an active area of development.
```

Key concepts:

- **No standard atomic types** — Python has no `AtomicInteger` equivalent. The GIL provides implicit atomicity for single bytecode operations.
- **`queue.Queue`** is the primary thread-safe data structure — uses internal locks for put/get operations. Available in `queue.LifoQueue` (stack) and `queue.PriorityQueue`.
- **`threading.Event`** is a simple one-bit flag for signaling between threads.
- **Implementation detail** — GIL atomicity guarantees are specific to CPython. PyPy, GraalPy, and free-threaded CPython may not preserve them.

> **Sources:** [Python docs — `queue.Queue`](https://docs.python.org/3/library/queue.html) · [Python Wiki — Atomic operations under the GIL](https://wiki.python.org/moin/GlobalInterpreterLock)

### Comparison: Atomics Spectrum

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| Control level | 5 memory orderings per operation | Strong ordering by default; `VarHandle` for fine-grained | Implicit via GIL (no explicit atomics) |
| CAS primitive | `compare_exchange` / `compare_exchange_weak` | `compareAndSet` / `compareAndExchange` | None |
| Lock-free data structures | `crossbeam` crate (queues, deques, epoch GC) | `ConcurrentHashMap`, `ConcurrentLinkedQueue`, Treiber stack | `queue.Queue` (uses internal locks, not lock-free) |
| Learning curve | Hard (must understand memory orderings) | Medium (simple API, `VarHandle` is advanced) | Easy (GIL handles it, but least powerful) |

---

## 7. Thread Pools and Executors

Thread pools decouple task submission from execution, reuse threads to amortize creation cost, and provide lifecycle management. Each language takes a different approach: Rust's Rayon provides zero-config work-stealing parallel iterators, Java offers a rich executor hierarchy with virtual thread executors, and Python's `concurrent.futures` provides a simple two-class API.

### Rust: Rayon and Work-Stealing Parallelism

Rayon provides data parallelism through parallel iterators. `par_iter()` distributes work across a global thread pool using work-stealing. Converting sequential code to parallel often requires changing `.iter()` to `.par_iter()`.

```rust
use rayon::prelude::*;

// Parallel iterator — drop-in replacement for sequential iteration
fn parallel_map() {
    let numbers: Vec<i32> = (0..1_000_000).collect();

    // Sequential
    let sum_seq: i32 = numbers.iter().map(|x| x * x).sum();

    // Parallel — just change .iter() to .par_iter()
    let sum_par: i32 = numbers.par_iter().map(|x| x * x).sum();

    assert_eq!(sum_seq, sum_par);
}

// Parallel sort
fn parallel_sort() {
    let mut data: Vec<i32> = (0..1_000_000).rev().collect();
    data.par_sort(); // parallel merge sort
}

// rayon::join — fork two tasks
fn parallel_join() {
    let (a, b) = rayon::join(
        || expensive_computation_a(),
        || expensive_computation_b(),
    );
    // Both run in parallel on the work-stealing pool
}

// Custom thread pool configuration
fn custom_pool() {
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(4)
        .build()
        .unwrap();

    pool.install(|| {
        // All par_iter() calls inside here use this pool
        let result: Vec<_> = (0..100)
            .into_par_iter()
            .map(|x| x * 2)
            .collect();
    });
}

// rayon::scope — structured fork-join parallelism
fn scoped_parallelism() {
    let mut results = vec![0; 4];
    rayon::scope(|s| {
        for (i, slot) in results.iter_mut().enumerate() {
            s.spawn(move |_| {
                *slot = expensive_compute(i);
            });
        }
    });
    // All tasks complete before scope exits
}
```

Key concepts:

- **Parallel iterators** have the same API as regular iterators — `.par_iter()` instead of `.iter()`.
- **Work-stealing** — idle threads steal tasks from busy threads' queues, achieving automatic load balancing.
- **Zero-config** — the global thread pool sizes itself to the number of CPU cores.
- **`rayon::join(a, b)`** forks two closures and joins them. Structured parallelism — both complete before `join` returns.
- **`rayon::scope`** allows spawning tasks that can borrow from the parent stack, similar to `std::thread::scope`.

> **Sources:** Blandy & Orendorff (2017) Ch.19 pp. 466–470 · Gjengset (2022) Ch.10 pp. 175–179 · [Rayon crate documentation](https://docs.rs/rayon/latest/rayon/) · [Rayon — `par_iter` and parallel iterators](https://docs.rs/rayon/latest/rayon/iter/index.html) · [`threadpool` crate documentation](https://docs.rs/threadpool/latest/threadpool/)

### Java: `ExecutorService`, `ForkJoinPool`, and Virtual Thread Executors

Java's executor hierarchy is rich. `ExecutorService` decouples task submission from execution. `ForkJoinPool` uses work-stealing for divide-and-conquer parallelism. With virtual threads, the guidance has shifted: do not pool virtual threads — create one per task.

```java
import java.util.concurrent.*;

// Fixed thread pool — n platform threads
ExecutorService fixed = Executors.newFixedThreadPool(4);
Future<Integer> future = fixed.submit(() -> {
    return expensiveComputation();
});
int result = future.get(); // blocks until complete
fixed.shutdown();

// Virtual thread per-task executor (Java 21) — no pooling needed
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = new ArrayList<>();
    for (String url : urls) {
        futures.add(executor.submit(() -> fetchUrl(url)));
    }
    for (var f : futures) {
        System.out.println(f.get());
    }
} // auto-shutdown when try-with-resources exits

// ForkJoinPool — work-stealing for recursive tasks
class SumTask extends RecursiveTask<Long> {
    private final int[] array;
    private final int lo, hi;
    static final int THRESHOLD = 1000;

    SumTask(int[] array, int lo, int hi) {
        this.array = array; this.lo = lo; this.hi = hi;
    }

    @Override
    protected Long compute() {
        if (hi - lo <= THRESHOLD) {
            long sum = 0;
            for (int i = lo; i < hi; i++) sum += array[i];
            return sum;
        }
        int mid = (lo + hi) / 2;
        SumTask left = new SumTask(array, lo, mid);
        SumTask right = new SumTask(array, mid, hi);
        left.fork();          // submit left to pool
        long rightResult = right.compute(); // compute right in this thread
        long leftResult = left.join();      // wait for left
        return leftResult + rightResult;
    }
}

// Using ForkJoinPool
ForkJoinPool pool = ForkJoinPool.commonPool();
long sum = pool.invoke(new SumTask(bigArray, 0, bigArray.length));

// CompletableFuture — composable async tasks
CompletableFuture<String> cf = CompletableFuture
    .supplyAsync(() -> fetchData())
    .thenApply(data -> process(data))
    .thenApply(result -> format(result));
String finalResult = cf.get();

// Configuring ThreadPoolExecutor directly
ThreadPoolExecutor custom = new ThreadPoolExecutor(
    4,                          // core pool size
    8,                          // max pool size
    60, TimeUnit.SECONDS,       // idle thread keepalive
    new LinkedBlockingQueue<>(100), // work queue
    new ThreadPoolExecutor.CallerRunsPolicy() // rejection policy
);
```

Key concepts:

- **`ExecutorService`** is the primary abstraction — submit tasks, get `Future` results.
- **`Executors.newVirtualThreadPerTaskExecutor()`** (Java 21) creates a new virtual thread per task. Replaces pooling for I/O-bound work.
- **`ForkJoinPool`** uses work-stealing for divide-and-conquer parallelism. `ForkJoinPool.commonPool()` is the default pool used by parallel streams and `CompletableFuture`.
- **Lea's foundational patterns** — oneway messages, thread-based services, parallel decomposition, and the active object pattern — directly informed the design of `ExecutorService`.
- **Virtual threads should not be pooled** — they are cheap to create. Use per-task executors instead.
- **`CompletableFuture`** enables composable async pipelines with `thenApply`, `thenCompose`, `thenCombine`.

> **Sources:** Goetz (2006) Ch.6 pp. 117–133 · Goetz (2006) Ch.8 pp. 167–181 · Lea (1999) Ch.4 pp. 291–382 · Rahman (2025) Ch.3 pp. 91–112 · Bloch (2018) Item 80 pp. 323–325 · [Java docs — `ExecutorService`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ExecutorService.html) · [Java docs — `Executors`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Executors.html) · [Java docs — `ForkJoinPool`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ForkJoinPool.html) · [Baeldung — Guide to the Java ExecutorService](https://www.baeldung.com/java-executor-service-tutorial) · [Baeldung — Guide to the Fork/Join Framework](https://www.baeldung.com/java-fork-join)

### Python: `concurrent.futures`

Python's `concurrent.futures` provides a unified API for thread-based and process-based parallelism. Switching from `ThreadPoolExecutor` to `ProcessPoolExecutor` requires changing one line of code.

```python
from concurrent.futures import (
    ThreadPoolExecutor, ProcessPoolExecutor, as_completed
)
import urllib.request

# ThreadPoolExecutor — good for I/O-bound work
def fetch_url(url):
    with urllib.request.urlopen(url) as response:
        return response.read()

urls = ["https://example.com"] * 10

with ThreadPoolExecutor(max_workers=5) as executor:
    # submit() returns a Future
    futures = {executor.submit(fetch_url, url): url for url in urls}

    # as_completed() yields futures as they finish
    for future in as_completed(futures):
        url = futures[future]
        try:
            data = future.result()
            print(f"{url}: {len(data)} bytes")
        except Exception as e:
            print(f"{url} failed: {e}")

# map() — simpler interface, preserves order
with ThreadPoolExecutor(max_workers=5) as executor:
    results = executor.map(fetch_url, urls)
    for result in results:  # results come in input order
        print(len(result))

# ProcessPoolExecutor — good for CPU-bound work (bypasses the GIL)
def cpu_intensive(n):
    return sum(i * i for i in range(n))

with ProcessPoolExecutor(max_workers=4) as executor:
    # Same API as ThreadPoolExecutor!
    futures = [executor.submit(cpu_intensive, 1_000_000)
               for _ in range(8)]
    results = [f.result() for f in as_completed(futures)]

# Switching from thread to process executor: change one line
# ThreadPoolExecutor(max_workers=4) -> ProcessPoolExecutor(max_workers=4)
```

Key concepts:

- **Unified API** — `ThreadPoolExecutor` and `ProcessPoolExecutor` implement the same `Executor` interface.
- **`submit(fn, *args)`** returns a `Future`. `future.result()` blocks until the result is ready.
- **`as_completed(futures)`** yields futures as they complete — good for handling results as they arrive.
- **`map(fn, iterable)`** applies `fn` in parallel, returns results in input order.
- **Thread vs process** — `ThreadPoolExecutor` for I/O-bound (GIL allows I/O concurrency); `ProcessPoolExecutor` for CPU-bound (bypasses GIL via separate processes). Process pool has higher per-task overhead due to serialization (pickling).

> **Sources:** Ramalho (2022) Ch.20 pp. 743–772 · Slatkin (2025) Item 74 pp. 361–363 · Slatkin (2025) Item 79 pp. 393–397 · [Python docs — `concurrent.futures` module](https://docs.python.org/3/library/concurrent.futures.html) · [Real Python — concurrent.futures in Python](https://realpython.com/python-concurrency/)

### Comparison: Executor Models

| Aspect | Rust (Rayon) | Java | Python |
|--------|-------------|------|--------|
| Primary API | `par_iter()` parallel iterators | `ExecutorService` hierarchy | `concurrent.futures` |
| Work-stealing | Built-in (global pool) | `ForkJoinPool` | None |
| Configuration | Zero-config (auto-sizes to cores) | Rich (pool sizes, policies, queues) | Simple (`max_workers`) |
| Task granularity | Fine-grained (work-stealing handles imbalance) | Fine-grained (`ForkJoinPool`) | Coarse-grained for `ProcessPoolExecutor` (serialization overhead) |
| Virtual/lightweight threads | N/A (use `tokio::spawn` for async) | `newVirtualThreadPerTaskExecutor()` | N/A |

---

## 8. Multiprocessing and IPC

Python uses multiprocessing as its primary mechanism for CPU-bound parallelism — a workaround for the GIL. Rust and Java rarely use multi-process architectures within a single application because they have true thread-level parallelism; they use processes for isolation (sandboxing, fault tolerance) rather than for performance.

### Python: The `multiprocessing` Module

The `multiprocessing` module spawns separate OS processes, each with its own Python interpreter and GIL. Data must be serialized (pickled) to cross process boundaries.

```python
from multiprocessing import Process, Pool, Queue, Value, Array
import multiprocessing as mp

# Basic process creation
def worker(name):
    print(f"Process {name}, PID: {mp.current_process().pid}")

p = Process(target=worker, args=("worker-1",))
p.start()
p.join()

# Process pool with map
def square(x):
    return x * x

with Pool(processes=4) as pool:
    results = pool.map(square, range(100))  # distributes work
    print(sum(results))

    # imap_unordered — results as they complete
    for result in pool.imap_unordered(square, range(100)):
        pass  # process each result

# Start methods: 'fork', 'spawn', 'forkserver'
mp.set_start_method('spawn')  # safest, re-imports modules
# 'fork'  — fast but unsafe with threads (copies GIL state)
# 'spawn' — safe, creates fresh interpreter (default on Windows/macOS)
# 'forkserver' — compromise: forks from a clean server process
```

Key concepts:

- **Separate GILs** — each process has its own Python interpreter and GIL, enabling true CPU parallelism.
- **Pickling overhead** — data must be serialized to cross process boundaries. This is the main cost of multiprocessing.
- **`Pool.map(fn, iterable)`** distributes work across worker processes. Similar to `concurrent.futures.ProcessPoolExecutor`.
- **Start methods** affect child process creation: `fork` (fast, copies parent), `spawn` (safe, fresh interpreter), `forkserver` (compromise).

> **Sources:** Gorelick & Ozsvald (2020) Ch.9 pp. 245–285 · [Python docs — `multiprocessing` module](https://docs.python.org/3/library/multiprocessing.html) · [Real Python — multiprocessing in Python](https://realpython.com/python-multiprocessing/) · [PEP 371 — Addition of the multiprocessing package](https://peps.python.org/pep-0371/)

### Python: IPC Mechanisms and Shared Memory

Python offers multiple inter-process communication mechanisms, each with different performance and safety trade-offs.

```python
from multiprocessing import Queue, Pipe, Value, Array, Manager
from multiprocessing.shared_memory import SharedMemory
import numpy as np

# Queue — message passing via serialization
q = Queue()
q.put("hello")       # serializes and sends
item = q.get()        # receives and deserializes

# Pipe — two-way connection between two processes
parent_conn, child_conn = Pipe()
parent_conn.send({"key": "value"})
data = child_conn.recv()

# Value and Array — shared memory with synchronization (ctypes)
counter = Value('i', 0)       # shared int, locked by default
with counter.get_lock():
    counter.value += 1

shared_array = Array('d', [1.0, 2.0, 3.0])  # shared doubles

# RawValue / RawArray — shared memory WITHOUT locking (faster, unsafe)
from multiprocessing import RawValue
raw_counter = RawValue('i', 0)  # no lock — user must synchronize

# SharedMemory (Python 3.8+) — named shared memory blocks
shm = SharedMemory(create=True, size=1024, name="my_buffer")
buffer = shm.buf
buffer[:5] = b"hello"
# Other processes can attach: SharedMemory(name="my_buffer")
shm.close()
shm.unlink()  # remove the shared memory block

# Manager — proxy objects via a server process (safest, slowest)
with Manager() as manager:
    shared_list = manager.list([1, 2, 3])
    shared_dict = manager.dict({"key": "value"})
    # Access is proxied through the manager process
    shared_list.append(4)
```

Key IPC trade-offs:

| Mechanism | Safety | Performance | Use case |
|-----------|--------|-------------|----------|
| `Queue` / `Pipe` | High (message passing) | Moderate (serialization) | General inter-process communication |
| `Value` / `Array` | Medium (locked by default) | Good (shared memory) | Simple shared counters/arrays |
| `RawValue` / `RawArray` | Low (no locking) | Best (shared memory, no overhead) | Performance-critical with manual sync |
| `SharedMemory` | Low (user manages) | Best (named, zero-copy) | Large data blocks (e.g., NumPy arrays) |
| `Manager` | High (proxy objects) | Slowest (network roundtrips) | Complex shared data structures |

> **Sources:** Gorelick & Ozsvald (2020) Ch.9 pp. 278–308 · [Python docs — `multiprocessing.shared_memory`](https://docs.python.org/3/library/multiprocessing.shared_memory.html) · [Python docs — `multiprocessing.Manager`](https://docs.python.org/3/library/multiprocessing.html#managers)

### Rust and Java: Multi-Process Perspectives

Rust and Java rarely use multi-process architectures for parallelism. They use processes for isolation and fault tolerance.

```rust
// Rust: std::process::Command — spawning external processes
use std::process::Command;

let output = Command::new("ls")
    .arg("-la")
    .output()
    .expect("failed to execute");

println!("stdout: {}", String::from_utf8_lossy(&output.stdout));

// For IPC: ipc-channel crate (Servo project), shared_memory crate,
// Unix domain sockets, or plain pipes
```

```java
// Java: ProcessBuilder — spawning and managing processes
ProcessBuilder pb = new ProcessBuilder("ls", "-la");
pb.redirectErrorStream(true);
Process process = pb.start();

try (var reader = process.inputReader()) {
    reader.lines().forEach(System.out::println);
}
int exitCode = process.waitFor();

// For IPC: java.nio.channels (memory-mapped files),
// sockets, pipes, or message queues
```

The key contrast: Python uses multiprocessing as a workaround for the GIL — it is the standard way to achieve CPU parallelism. Rust and Java use multiprocessing for process isolation (sandboxing, fault isolation) rather than for parallelism, since they already have true thread-level parallelism.

> **Sources:** Ramalho (2022) Ch.19 pp. 716–724 · [Rust docs — `std::process`](https://doc.rust-lang.org/std/process/) · [`shared_memory` crate](https://docs.rs/shared_memory/latest/shared_memory/) · [`ipc-channel` crate](https://docs.rs/ipc-channel/latest/ipc_channel/) · [Java docs — `ProcessBuilder`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ProcessBuilder.html) · [Java docs — `java.nio.channels`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/channels/package-summary.html)

### When to Use Processes vs Threads

| Criterion | Threads | Processes |
|-----------|---------|-----------|
| Data sharing | Shared memory (fast, needs synchronization) | Serialization or shared memory (overhead) |
| Fault isolation | Crash kills the process | Crash is isolated to one process |
| CPU parallelism | Rust/Java: yes; Python: no (GIL) | All languages: yes |
| Memory overhead | Low (shared address space) | High (separate address space per process) |
| Best for | Fine-grained shared data, I/O concurrency | CPU isolation, GIL bypass (Python), sandboxing |

---

## 9. Structured Concurrency

Structured concurrency ensures that concurrent task lifetimes match lexical scopes — when a scope exits, all tasks spawned within it are guaranteed to have completed (or been cancelled). This prevents leaked threads, lost exceptions, and difficult cancellation. All three languages are converging on this insight, with Java providing the most comprehensive implementation.

### Java: `StructuredTaskScope` and Scoped Values

Java 21's `StructuredTaskScope` (preview) enforces that subtasks complete before the scope closes. Joining policies control behavior on success or failure.

```java
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.*;

// Basic structured concurrency — all tasks complete before scope exits
try (var scope = StructuredTaskScope.open()) {
    Subtask<String> user = scope.fork(() -> fetchUser(userId));
    Subtask<String> order = scope.fork(() -> fetchOrder(orderId));

    scope.join(); // waits for all subtasks to complete

    // Access results after join
    String userData = user.get();
    String orderData = order.get();
    return new Response(userData, orderData);
}
// Scope is closed — all tasks guaranteed complete

// ShutdownOnFailure — cancel all if any task fails
try (var scope = StructuredTaskScope.open(
        Joiner.allSuccessfulOrThrow())) {
    Subtask<String> a = scope.fork(() -> fetchA());
    Subtask<String> b = scope.fork(() -> fetchB());

    scope.join(); // if A fails, B is cancelled (and vice versa)
    // All succeeded if we reach here
    return combine(a.get(), b.get());
}

// ShutdownOnSuccess — return first successful result
try (var scope = StructuredTaskScope.open(
        Joiner.anySuccessfulResultOrThrow())) {
    scope.fork(() -> fetchFromPrimary());
    scope.fork(() -> fetchFromMirror());

    // Returns as soon as one succeeds, cancels the other
    String result = scope.join();
    return result;
}

// Nested scopes
try (var outer = StructuredTaskScope.open()) {
    outer.fork(() -> {
        try (var inner = StructuredTaskScope.open()) {
            inner.fork(() -> subtask1());
            inner.fork(() -> subtask2());
            inner.join(); // inner tasks complete before outer continues
        }
        return "done";
    });
    outer.join();
}
```

```java
// ScopedValue — structured context propagation (replaces ThreadLocal)
import java.lang.ScopedValue;

// Declare a scoped value
private static final ScopedValue<String> USER = ScopedValue.newInstance();

// Bind a value for the duration of a scope
ScopedValue.where(USER, "alice").run(() -> {
    System.out.println(USER.get()); // "alice"
    // All subtasks in StructuredTaskScope inherit this binding
    try (var scope = StructuredTaskScope.open()) {
        scope.fork(() -> {
            System.out.println(USER.get()); // "alice" — inherited
            return null;
        });
        scope.join();
    }
});
// USER is no longer bound here
```

Key concepts:

- **`StructuredTaskScope`** guarantees all forked subtasks complete (or are cancelled) before the scope closes. Uses try-with-resources for automatic cleanup.
- **Joining policies** control behavior: `allSuccessfulOrThrow()` cancels remaining tasks on first failure; `anySuccessfulResultOrThrow()` returns the first success and cancels others.
- **`ScopedValue`** replaces `ThreadLocal` for structured concurrency. It is immutable within a scope, automatically inherited by child tasks, and cleaned up when the scope exits. More efficient than `ThreadLocal` (no per-thread HashMap lookup).
- **Exception handling** is policy-driven — exceptions are collected and can be rethrown or inspected.

> **Sources:** Rahman (2025) Ch.4 pp. 125–214 · Rahman (2025) Ch.5 pp. 217–245 · [JEP 462 — Structured Concurrency (Second Preview)](https://openjdk.org/jeps/462) · [JEP 453 — Structured Concurrency (Preview)](https://openjdk.org/jeps/453) · [JEP 464 — Scoped Values (Second Preview)](https://openjdk.org/jeps/464) · [Java docs — `StructuredTaskScope`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html) · [Inside Java — Structured Concurrency](https://inside.java/tag/structured-concurrency)

### Rust: Scoped Threads and Structured Concurrency

Rust's `std::thread::scope` provides structured concurrency for synchronous code. All spawned threads within the scope are guaranteed to join before the closure returns.

```rust
use std::thread;

// std::thread::scope — threads can borrow from the parent stack
fn structured_computation() {
    let data = vec![1, 2, 3, 4, 5, 6, 7, 8];
    let mut results = vec![0; 4];

    thread::scope(|s| {
        for (i, chunk) in data.chunks(2).enumerate() {
            let result_slot = &mut results[i];
            s.spawn(move || {
                *result_slot = chunk.iter().sum();
            });
        }
    });
    // All threads have joined — results is fully populated
    println!("Results: {results:?}"); // [3, 7, 11, 15]
}

// crossbeam::scope — predated std::thread::scope, same concept
// crossbeam also provides scoped thread pools and concurrent data structures
```

Key concepts:

- **`thread::scope`** (std, Rust 1.63+) relaxes the `'static` bound on thread closures. Threads can borrow from the parent stack.
- **Guaranteed join** — all threads spawned in the scope are joined before the scope closure returns. Cannot leak threads.
- **`crossbeam::scope`** — community solution that inspired the standard library addition. Also provides concurrent data structures (queues, deques, epoch-based garbage collection).
- **Async structured concurrency** is less mature in Rust — `tokio::task::spawn` is unstructured. Experimental crates like `async-scoped` and `moro` provide scoped task spawning.

> **Sources:** Bos (2023) Ch.1 pp. 5–7 · Blandy & Orendorff (2017) Ch.19 pp. 461–463 · [Rust docs — `std::thread::scope`](https://doc.rust-lang.org/std/thread/fn.scope.html) · [`crossbeam::scope` documentation](https://docs.rs/crossbeam/latest/crossbeam/fn.scope.html) · [RFC discussion — Scoped tasks in async Rust](https://github.com/rust-lang/rfcs)

### Python: `asyncio.TaskGroup` and Trio

Python 3.11 introduced `asyncio.TaskGroup` for structured concurrency in async code. The Trio library pioneered this approach in Python with its "nursery" concept.

```python
import asyncio

# asyncio.TaskGroup (Python 3.11+) — structured async concurrency
async def fetch_all():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(fetch_user("alice"))
        task2 = tg.create_task(fetch_order(123))
        task3 = tg.create_task(fetch_inventory())
    # All tasks complete before exiting the async with block
    # If any task raises, all others are cancelled
    # Exceptions are collected into an ExceptionGroup (PEP 654)
    return task1.result(), task2.result(), task3.result()

# Exception handling with ExceptionGroup
async def robust_fetch():
    try:
        async with asyncio.TaskGroup() as tg:
            tg.create_task(might_fail_1())
            tg.create_task(might_fail_2())
    except* ValueError as eg:
        # except* handles individual exceptions from the group
        for exc in eg.exceptions:
            print(f"ValueError: {exc}")
    except* ConnectionError as eg:
        for exc in eg.exceptions:
            print(f"Connection failed: {exc}")

# Trio — pioneered structured concurrency in Python
# import trio
#
# async def main():
#     async with trio.open_nursery() as nursery:
#         nursery.start_soon(task1)
#         nursery.start_soon(task2)
#     # All tasks complete before exiting
```

Key concepts:

- **`asyncio.TaskGroup`** ensures all tasks complete (or are cancelled) before exiting the `async with` block. Async-only.
- **`ExceptionGroup`** (PEP 654) collects exceptions from all failed tasks. `except*` syntax handles individual exceptions from the group.
- **Trio's nurseries** pioneered structured concurrency in Python. Nathaniel J. Smith's blog post argues that fire-and-forget concurrency (`go`-statement style) is as harmful as `goto`.
- **No structured concurrency for threads** — Python has no equivalent of Rust's `thread::scope` or Java's `StructuredTaskScope` for `threading.Thread`.

> **Sources:** [Python docs — `asyncio.TaskGroup`](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup) · [PEP 654 — Exception Groups and `except*`](https://peps.python.org/pep-0654/) · [Trio — Structured concurrency for Python](https://trio.readthedocs.io/en/stable/) · ["Notes on structured concurrency" by Nathaniel J. Smith](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/)

### Cross-Language Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| Sync structured concurrency | `std::thread::scope` | `StructuredTaskScope` (preview) | None |
| Async structured concurrency | Experimental (`async-scoped`, `moro`) | `StructuredTaskScope` works with virtual threads | `asyncio.TaskGroup` (3.11+) |
| Cancellation policy | Manual (no built-in policy) | Joining policies (`ShutdownOnSuccess`, `ShutdownOnFailure`) | Automatic on exception |
| Context propagation | Ownership system (no need) | `ScopedValue` (replaces `ThreadLocal`) | No equivalent |
| Exception handling | Panics propagated via `join()` | Policy-driven (`throwIfFailed()`) | `ExceptionGroup` + `except*` |

Each language's concurrency model reflects its core philosophy:
- **Rust** enforces safety at compile time — ownership prevents data races, scoped threads enforce structured lifetimes.
- **Java** provides rich runtime abstractions — virtual threads for scale, `StructuredTaskScope` for structure, JMM for memory safety.
- **Python** prioritizes simplicity — GIL for implicit safety, multiprocessing for parallelism, `TaskGroup` for async structure.

---

## Sources

### Books

**Rust**
- Bos (2023) — *Rust Atomics and Locks*: Ch.1 pp. 1–29 (basics of Rust concurrency), Ch.2 pp. 31–47 (atomics), Ch.3 pp. 49–73 (memory ordering), Ch.4 pp. 75–83 (building a spin lock), Ch.5 pp. 85–104 (building channels), Ch.6 pp. 105–125 (building `Arc`), Ch.7 pp. 127–159 (processor internals), Ch.8 pp. 161–179 (OS primitives), Ch.9 pp. 181–211 (building locks), Ch.10 pp. 213–219 (ideas and inspiration)
- Gjengset (2022) — *Rust for Rustaceans*: Ch.10 pp. 167–192 (concurrency and parallelism)
- Klabnik & Nichols (2023) — *The Rust Programming Language*: Ch.16 pp. 353–374 (fearless concurrency)
- Blandy & Orendorff (2017) — *Programming Rust*: Ch.19 pp. 457–497 (concurrency)

**Java**
- Goetz (2006) — *Java Concurrency in Practice*: Ch.1 pp. 1–12 (introduction), Ch.2 pp. 15–31 (thread safety), Ch.3 pp. 33–53 (sharing objects), Ch.4 pp. 55–76 (composing objects), Ch.5 pp. 79–109 (building blocks), Ch.6 pp. 113–133 (task execution), Ch.7 pp. 135–166 (cancellation and shutdown), Ch.8 pp. 167–187 (thread pools), Ch.10 pp. 205–219 (liveness hazards), Ch.11 pp. 221–243 (performance and scalability), Ch.13 pp. 277–289 (explicit locks), Ch.14 pp. 291–317 (custom synchronizers), Ch.15 pp. 319–335 (atomic variables), Ch.16 pp. 337–352 (Java Memory Model)
- Rahman (2025) — *Modern Concurrency in Java*: Ch.1 pp. 1–30 (introduction), Ch.2 pp. 31–89 (virtual threads), Ch.3 pp. 91–123 (mechanics of modern concurrency), Ch.4 pp. 125–214 (structured concurrency), Ch.5 pp. 217–245 (scoped values)
- Lea (1999) — *Concurrent Programming in Java*: Ch.1 pp. 1–56 (concurrent OO programming), Ch.2 pp. 57–148 (exclusion), Ch.3 pp. 149–290 (state dependence), Ch.4 pp. 291–382 (creating threads)
- Bloch (2018) — *Effective Java*: Ch.11 pp. 311–337 (concurrency items 78–84)
- Horstmann (2024) — *Core Java, Vol. II*: Concurrency chapters
- Evans et al (2022) — *The Well-Grounded Java Developer*: Ch.6 (Java concurrency fundamentals)
- Beckwith (2024) — *JVM Performance Engineering*: Threading chapters
- Oaks (2020) — *Java Performance*: Threading chapters

**Python**
- Ramalho (2022) — *Fluent Python*: Ch.19 pp. 695–738 (concurrency models), Ch.20 pp. 743–772 (concurrent executors)
- Gorelick & Ozsvald (2020) — *High Performance Python*: Ch.8 pp. 213–243 (asynchronous I/O), Ch.9 pp. 245–308 (multiprocessing)
- Slatkin (2025) — *Effective Python*: Ch.9 pp. 319–397 (concurrency and parallelism items 67–79)
- Martelli et al (2023) — *Python in a Nutshell*: Concurrency chapters
- Shaw (2021) — *CPython Internals*: pp. 221–283 (parallelism and concurrency)
- Beazley (2021) — *Python Distilled*: Ch.9.14 pp. 247–296 (blocking operations and concurrency)
- Hattingh (2020) — *Using Asyncio in Python*: Ch.2 pp. 9–20 (the truth about threads)

### External Resources

**Rust**
- [The Rust Book — Fearless Concurrency](https://doc.rust-lang.org/book/ch16-00-concurrency.html)
- [The Rust Reference — Send and Sync](https://doc.rust-lang.org/reference/special-types-and-traits.html#send-and-sync)
- [The Rustonomicon — Send and Sync](https://doc.rust-lang.org/nomicon/send-and-sync.html)
- [Rust By Example — Threads](https://doc.rust-lang.org/rust-by-example/std_misc/threads.html)
- [Rust docs — `std::thread` module](https://doc.rust-lang.org/std/thread/)
- [Rust docs — `thread::spawn`](https://doc.rust-lang.org/std/thread/fn.spawn.html)
- [Rust docs — `thread::scope`](https://doc.rust-lang.org/std/thread/fn.scope.html)
- [Rust docs — `std::sync::Mutex`](https://doc.rust-lang.org/std/sync/struct.Mutex.html)
- [Rust docs — `std::sync::RwLock`](https://doc.rust-lang.org/std/sync/struct.RwLock.html)
- [Rust docs — `std::sync::Arc`](https://doc.rust-lang.org/std/sync/struct.Arc.html)
- [Rust docs — `std::sync::Condvar`](https://doc.rust-lang.org/std/sync/struct.Condvar.html)
- [Rust docs — `std::marker::Send`](https://doc.rust-lang.org/std/marker/trait.Send.html)
- [Rust docs — `std::marker::Sync`](https://doc.rust-lang.org/std/marker/trait.Sync.html)
- [Rust docs — `std::sync::atomic` module](https://doc.rust-lang.org/std/sync/atomic/)
- [Rust docs — `AtomicUsize`](https://doc.rust-lang.org/std/sync/atomic/struct.AtomicUsize.html)
- [Rust docs — `Ordering` enum](https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html)
- [Rust docs — `std::process` module](https://doc.rust-lang.org/std/process/)
- [Niko Matsakis — "Fearless Concurrency with Rust"](https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html)
- [Rayon crate documentation](https://docs.rs/rayon/latest/rayon/)
- [Rayon — parallel iterators](https://docs.rs/rayon/latest/rayon/iter/index.html)
- [`threadpool` crate documentation](https://docs.rs/threadpool/latest/threadpool/)
- [`crossbeam` crate documentation](https://docs.rs/crossbeam/latest/crossbeam/)
- [`crossbeam::scope` documentation](https://docs.rs/crossbeam/latest/crossbeam/fn.scope.html)
- [`shared_memory` crate](https://docs.rs/shared_memory/latest/shared_memory/)
- [`ipc-channel` crate](https://docs.rs/ipc-channel/latest/ipc_channel/)

**Java**
- [Java Language Specification — Threads and Locks (JLS Ch.17)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html)
- [Oracle Tutorial — Concurrency](https://docs.oracle.com/javase/tutorial/essential/concurrency/)
- [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444)
- [JEP 425 — Virtual Threads (Preview)](https://openjdk.org/jeps/425)
- [JEP 462 — Structured Concurrency (Second Preview)](https://openjdk.org/jeps/462)
- [JEP 453 — Structured Concurrency (Preview)](https://openjdk.org/jeps/453)
- [JEP 464 — Scoped Values (Second Preview)](https://openjdk.org/jeps/464)
- [Java docs — `java.lang.Thread`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html)
- [Java docs — `java.util.concurrent.locks` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/package-summary.html)
- [Java docs — `ReentrantLock`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantLock.html)
- [Java docs — `ReentrantReadWriteLock`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantReadWriteLock.html)
- [Java docs — `java.util.concurrent.atomic` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/package-summary.html)
- [Java docs — `AtomicInteger`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/AtomicInteger.html)
- [Java docs — `VarHandle`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/invoke/VarHandle.html)
- [Java docs — `ExecutorService`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ExecutorService.html)
- [Java docs — `Executors`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Executors.html)
- [Java docs — `ForkJoinPool`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ForkJoinPool.html)
- [Java docs — `StructuredTaskScope`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html)
- [Java docs — `ProcessBuilder`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ProcessBuilder.html)
- [Java docs — `java.nio.channels`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/channels/package-summary.html)
- [Inside Java — Loom](https://inside.java/tag/loom)
- [Inside Java — Structured Concurrency](https://inside.java/tag/structured-concurrency)
- [Baeldung — Introduction to Thread Safety in Java](https://www.baeldung.com/java-thread-safety)
- [Baeldung — Virtual Threads in Java 21](https://www.baeldung.com/java-virtual-thread-vs-thread)
- [Baeldung — Guide to the Synchronized Keyword in Java](https://www.baeldung.com/java-synchronized)
- [Baeldung — Guide to java.util.concurrent.Locks](https://www.baeldung.com/java-concurrent-locks)
- [Baeldung — The volatile Keyword in Java](https://www.baeldung.com/java-volatile)
- [Baeldung — Introduction to Lock-Free Data Structures](https://www.baeldung.com/lock-free-programming)
- [Baeldung — Guide to the Java ExecutorService](https://www.baeldung.com/java-executor-service-tutorial)
- [Baeldung — Guide to the Fork/Join Framework](https://www.baeldung.com/java-fork-join)
- [Doug Lea — "The java.util.concurrent Synchronizer Framework"](https://gee.cs.oswego.edu/dl/papers/aqs.pdf)

**Python**
- [Python docs — `threading` module](https://docs.python.org/3/library/threading.html)
- [Python docs — `threading.Thread`](https://docs.python.org/3/library/threading.html#thread-objects)
- [Python docs — `threading.Lock`](https://docs.python.org/3/library/threading.html#lock-objects)
- [Python docs — `threading.RLock`](https://docs.python.org/3/library/threading.html#rlock-objects)
- [Python docs — `threading.Condition`](https://docs.python.org/3/library/threading.html#condition-objects)
- [Python docs — `threading.Semaphore`](https://docs.python.org/3/library/threading.html#semaphore-objects)
- [Python docs — `_thread`](https://docs.python.org/3/library/_thread.html)
- [Python docs — Concurrency](https://docs.python.org/3/library/concurrency.html)
- [Python docs — `concurrent.futures` module](https://docs.python.org/3/library/concurrent.futures.html)
- [Python docs — `ThreadPoolExecutor`](https://docs.python.org/3/library/concurrent.futures.html#threadpoolexecutor)
- [Python docs — `ProcessPoolExecutor`](https://docs.python.org/3/library/concurrent.futures.html#processpoolexecutor)
- [Python docs — `multiprocessing` module](https://docs.python.org/3/library/multiprocessing.html)
- [Python docs — `multiprocessing.shared_memory`](https://docs.python.org/3/library/multiprocessing.shared_memory.html)
- [Python docs — `multiprocessing.Manager`](https://docs.python.org/3/library/multiprocessing.html#managers)
- [Python docs — `queue.Queue`](https://docs.python.org/3/library/queue.html)
- [Python docs — `asyncio.TaskGroup`](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup)
- [Python docs — Free-threaded CPython](https://docs.python.org/3.13/howto/free-threading-python.html)
- [Python Wiki — Global Interpreter Lock](https://wiki.python.org/moin/GlobalInterpreterLock)
- [PEP 703 — Making the Global Interpreter Lock Optional in CPython](https://peps.python.org/pep-0703/)
- [PEP 654 — Exception Groups and `except*`](https://peps.python.org/pep-0654/)
- [PEP 371 — Addition of the multiprocessing package](https://peps.python.org/pep-0371/)
- [Python 3.13 What's New — Free-threaded CPython](https://docs.python.org/3.13/whatsnew/3.13.html#free-threaded-cpython)
- [Sam Gross — nogil project](https://github.com/colesbury/nogil)
- [Real Python — An Intro to Threading in Python](https://realpython.com/intro-to-python-threading/)
- [Real Python — Python's GIL: A Guide](https://realpython.com/python-gil/)
- [Real Python — concurrent.futures in Python](https://realpython.com/python-concurrency/)
- [Real Python — multiprocessing in Python](https://realpython.com/python-multiprocessing/)
- [Trio — Structured concurrency for Python](https://trio.readthedocs.io/en/stable/)
- ["Notes on structured concurrency" by Nathaniel J. Smith](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/)
- [Larry Hastings — "Removing Python's GIL: The Gilectomy" (PyCon talk)](https://www.youtube.com/watch?v=P3AyI_u66Bw)

# Layer 4 · Topic 12 — Concurrency & Parallelism

> Comparative study of Rust, Java, and Python: how each language approaches concurrent and parallel execution — from Rust's compile-time "fearless concurrency" enforced by Send/Sync marker traits, through Java's rich shared-memory threading model with virtual threads (Project Loom) and structured concurrency, to Python's GIL-constrained threading with multiprocessing as the escape hatch and free-threaded Python on the horizon.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.1 pp. 1–29 | Basics of Rust concurrency: threads, scoped threads, shared ownership and reference counting (`Arc<T>`), borrowing and data races, interior mutability (`Cell`, `RefCell`, `Mutex`, `RwLock`, atomics, `UnsafeCell`), `Send` and `Sync` traits, locking (`Mutex`, `RwLock`, lock poisoning), waiting and parking, condition variables |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.2 pp. 31–47 | Atomics: atomic load/store operations (stop flag, progress reporting, lazy initialization), fetch-and-modify operations (statistics, ID allocation), compare-and-exchange operations (ID allocation without overflow, lazy one-time initialization) |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.3 pp. 49–73 | Memory ordering: reordering and optimizations, the memory model, happens-before relationship, spawning and joining, Relaxed ordering, Release and Acquire ordering (locking example, lazy initialization with indirection), Consume ordering, Sequentially Consistent ordering, fences, common misconceptions |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.4 pp. 75–83 | Building a spin lock from scratch: minimal implementation, unsafe spin lock, safe interface using a lock guard |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.5 pp. 85–104 | Building channels: mutex-based channel, unsafe one-shot channel, safety through runtime checks, safety through types, borrowing to avoid allocation, blocking |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.6 pp. 105–125 | Building `Arc` from scratch: basic reference counting, testing, mutation, weak pointers, optimizing |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.7 pp. 127–159 | Understanding the processor: processor instructions (load/store, read-modify-write, load-linked/store-conditional), caching, cache coherence, impact on performance, reordering, memory ordering on x86-64 and ARM64, memory fences |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.8 pp. 161–179 | Operating system primitives: interfacing with the kernel, POSIX (wrapping in Rust), Linux (futex, futex operations, priority inheritance), macOS (`os_unfair_lock`), Windows (heavyweight and lighter-weight kernel objects, address-based waiting) |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.9 pp. 181–211 | Building locks from OS primitives: mutex (avoiding syscalls, optimizing, benchmarking), condition variable (avoiding syscalls, avoiding spurious wake-ups), reader-writer lock (avoiding busy-looping writers, avoiding writer starvation) |
| Rust | Bos (2023) — *Rust Atomics and Locks* | Ch.10 pp. 213–219 | Ideas and inspiration: semaphore, RCU, lock-free linked list, queue-based locks, parking lot-based locks, sequence lock |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.10 pp. 167–192 | Concurrency and parallelism: shared memory models (Mutex, RwLock, condition variables), worker pools and actor models, message passing vs shared state, atomic types and memory ordering (Relaxed, Acquire/Release, SeqCst), compare-and-swap patterns, concurrency testing with `loom` |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.16 pp. 353–374 | Fearless concurrency: using threads with `thread::spawn` and `join`, using `move` closures, message passing with channels (`mpsc`), shared-state concurrency with `Mutex<T>` and `Arc<T>`, `Send` and `Sync` traits |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.19 pp. 457–497 | Concurrency: fork-join parallelism (`spawn`, `join`, error handling, sharing immutable data, Rayon, Mandelbrot example), channels (sending/receiving values, pipeline, features and performance, `Send` and `Sync`, piping iterators), shared mutable state (`Mutex<T>`, `mut` and `Mutex`, deadlock, poisoned mutexes, multi-producer channels using mutexes, `RwLock<T>`, condition variables, atomics, global variables) |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.1 pp. 1–12 | Introduction: brief history of concurrency, benefits of threads, risks of threads, threads are everywhere |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.2 pp. 15–31 | Thread safety: what is thread safety, atomicity, locking (intrinsic locks, reentrancy), guarding state with locks, liveness and performance |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.3 pp. 33–53 | Sharing objects: visibility, publication and escape, thread confinement, immutability, safe publication |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.4 pp. 55–76 | Composing objects: designing thread-safe classes, instance confinement, delegating thread safety, adding functionality to thread-safe classes, documenting synchronization policies |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.5 pp. 79–109 | Building blocks: synchronized collections, concurrent collections (`ConcurrentHashMap`), blocking queues and producer-consumer pattern, blocking and interruptible methods, synchronizers (`CountDownLatch`, `FutureTask`, `Semaphore`, `CyclicBarrier`), building an efficient scalable result cache |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.6 pp. 113–133 | Task execution: executing tasks in threads, the Executor framework, finding exploitable parallelism |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.7 pp. 135–166 | Cancellation and shutdown: task cancellation, stopping a thread-based service, handling abnormal thread termination, JVM shutdown |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.8 pp. 167–187 | Applying thread pools: implicit couplings between tasks and execution policies, sizing thread pools, configuring `ThreadPoolExecutor`, extending `ThreadPoolExecutor`, parallelizing recursive algorithms |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.10 pp. 205–219 | Avoiding liveness hazards: deadlock (lock-ordering, dynamic lock order, between cooperating objects, open calls), avoiding and diagnosing deadlocks, other liveness hazards (starvation, livelock) |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.11 pp. 221–243 | Performance and scalability: thinking about performance, Amdahl's law, costs introduced by threads, reducing lock contention, comparing Map performance, reducing context switch overhead |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.13 pp. 277–289 | Explicit locks: `Lock` and `ReentrantLock`, performance considerations, fairness, choosing between `synchronized` and `ReentrantLock`, read-write locks |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.14 pp. 291–317 | Building custom synchronizers: managing state dependence, using condition queues, explicit condition objects, anatomy of a synchronizer, `AbstractQueuedSynchronizer` (AQS), AQS in `java.util.concurrent` |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.15 pp. 319–335 | Atomic variables and nonblocking synchronization: disadvantages of locking, hardware support for concurrency (CAS), atomic variable classes, nonblocking algorithms (stack, linked list) |
| Java | Goetz (2006) — *Java Concurrency in Practice* | Ch.16 pp. 337–352 | The Java Memory Model: what is a memory model and why, publication, initialization safety |
| Java | Rahman (2025) — *Modern Concurrency in Java* | Ch.1 pp. 1–30 | Introduction: brief history of threads in Java, genesis of Java 1.0 threads, starting threads, hidden costs, resource efficiency in high-scale applications, parallel execution strategy, Executor framework, `ForkJoinPool`, `CompletableFuture`, asynchronous programming, reactive frameworks, revolutionizing concurrency (virtual threads promise, seamless integration, handling blocking operations) |
| Java | Rahman (2025) — *Modern Concurrency in Java* | Ch.2 pp. 31–89 | Understanding virtual threads: what is a virtual thread, two kinds of threads, key differences from platform threads, creating virtual threads, adapting to virtual threads, throughput and scalability, how virtual threads work under the hood (stack frames, memory management, carrier threads, OS involvement, handling blocking, transparency), structured concurrency promise, managing resource constraints with rate limiting (semaphores), limitations (pinning, `ReentrantLock` and pinning, native method invocation), `ThreadLocal` conundrum, monitoring, practical tips for migrating |
| Java | Rahman (2025) — *Modern Concurrency in Java* | Ch.3 pp. 91–123 | Mechanics of modern concurrency: thread pool, Executor framework, `Callable` and `Future`, `ForkJoinPool` (why for virtual threads?), continuation, building virtual threads from scratch, virtual threads and I/O polling |
| Java | Rahman (2025) — *Modern Concurrency in Java* | Ch.4 pp. 125–214 | Structured concurrency: challenge of unstructured concurrency, promise of structured concurrency, `StructuredTaskScope` API, scopes and subtasks (relationship and lifecycle), joining policies with `Joiner`, common joining policies, exception handling, configuration, custom joiners, memory consistency effects, nested scopes, observability |
| Java | Rahman (2025) — *Modern Concurrency in Java* | Ch.5 pp. 217–245 | Scoped values: burden of passing context, parameter pollution, `ThreadLocal` (limitations), toward lightweight sharing, core components of `ScopedValue`, `ScopedValue` and structured concurrency, performance considerations, migrating to scoped values |
| Java | Bloch (2018) — *Effective Java* | Ch.11 pp. 311–337 | Concurrency: Item 78 (synchronize access to shared mutable data), Item 79 (avoid excessive synchronization), Item 80 (prefer executors, tasks, and streams to threads), Item 81 (prefer concurrency utilities to `wait`/`notify`), Item 82 (document thread safety), Item 83 (use lazy initialization judiciously), Item 84 (don't depend on the thread scheduler) |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Concurrency chapters | Threads, synchronization, concurrent collections, executors, processes |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.6 | Java concurrency fundamentals: threads, locks, concurrent data structures |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Threading chapters | Thread performance, monitoring, JVM threading internals |
| Java | Oaks (2020) — *Java Performance* | Threading chapters | Thread and synchronization performance, thread pool sizing |
| Python | Ramalho (2022) — *Fluent Python* | Ch.19 pp. 695–738 | Concurrency models in Python: the big picture, jargon, processes/threads/GIL, concurrent hello world (spinner with threads, processes, coroutines, supervisors side-by-side), the real impact of the GIL (quick quiz), a homegrown process pool (process-based solution, multicore prime checker, experimenting with more or fewer processes, thread-based nonsolution), Python in the multicore world (system administration, data science, server-side, WSGI, distributed task queues) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.20 pp. 743–772 | Concurrent executors: concurrent web downloads, `concurrent.futures` (`ThreadPoolExecutor`, `ProcessPoolExecutor`), `Executor.map`, downloads with progress display and error handling, `futures.as_completed` |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.9 pp. 245–308 | The `multiprocessing` module: overview, estimating Pi with Monte Carlo (processes vs threads), using Python objects, replacing multiprocessing with Joblib, random numbers in parallel systems, using numpy, finding prime numbers, queues of work, verifying primes using IPC (serial solution, naive pool, `Manager.Value` as flag, Redis as flag, `RawValue` as flag, mmap as flag), sharing numpy data with multiprocessing, synchronizing file and variable access (file locking, locking a value) |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.8 pp. 213–243 | Asynchronous I/O: introduction to asynchronous programming, `async`/`await`, serial crawler, gevent, tornado, aiohttp, shared CPU-I/O workload (serial, batched, full async) |
| Python | Slatkin (2025) — *Effective Python* | Ch.9 pp. 319–397 | Concurrency and parallelism: Item 67 (use `subprocess` to manage child processes), Item 68 (use threads for blocking I/O, avoid for parallelism), Item 69 (use `Lock` to prevent data races in threads), Item 70 (use `Queue` to coordinate work between threads), Item 71 (know how to recognize when concurrency is necessary), Item 72 (avoid creating new thread instances for on-demand fan-out), Item 73 (understand how using `Queue` for concurrency requires refactoring), Item 74 (consider `ThreadPoolExecutor` when threads are necessary for concurrency), Item 75 (achieve highly concurrent I/O with coroutines), Item 76 (know how to port threaded I/O to `asyncio`), Item 77 (mix threads and coroutines to ease the transition to `asyncio`), Item 78 (maximize responsiveness of `asyncio` event loops with async-friendly worker threads), Item 79 (consider `concurrent.futures` for true parallelism) |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Concurrency chapters | Threading module, multiprocessing module, `concurrent.futures`, synchronization primitives |
| Python | Shaw (2021) — *CPython Internals* | Parallelism and Concurrency pp. 221–283 | Models of parallelism and concurrency, structure of a process, multiprocess parallelism, multithreading, asynchronous programming, generators, coroutines, asynchronous generators, subinterpreters |
| Java | Lea (1999) — *Concurrent Programming in Java* | Ch.1 pp. 1–56 | Concurrent OO programming: concurrency constructs by example, objects and concurrency, design forces, before/after patterns |
| Java | Lea (1999) — *Concurrent Programming in Java* | Ch.2 pp. 57–148 | Exclusion: immutability as safety strategy, synchronization (`synchronized` keyword, intrinsic locks), thread confinement, structuring and refactoring classes for concurrency, lock utilities for flexible locking |
| Java | Lea (1999) — *Concurrent Programming in Java* | Ch.3 pp. 149–290 | State dependence: guarded methods (wait/notify/notifyAll), monitor-based coordination, concurrency control utilities (semaphores, latches, barriers), joint actions across multiple participants, transactional patterns, implementing custom utility classes |
| Java | Lea (1999) — *Concurrent Programming in Java* | Ch.4 pp. 291–382 | Creating threads: oneway (fire-and-forget) message patterns, composing oneway messages into workflows, thread-based services, parallel decomposition of computational tasks, active objects pattern |
| Python | Beazley (2021) — *Python Distilled* | Ch.9.14 pp. 247–296 | Blocking operations and concurrency: nonblocking I/O, I/O polling, threads, concurrent execution with asyncio; standard library modules reference (asyncio, threading, subprocess, socket, select) |
| Python | Hattingh (2020) — *Using Asyncio in Python* | Ch.2 pp. 9–20 | The truth about threads: benefits of threading (ease of use, OS API compatibility, CPU parallelism), drawbacks (race conditions, resource overhead for thousands of connections, hard-to-debug failures), case study demonstrating race conditions with robots-and-cutlery simulation |

### Coverage Gaps

The owned books **do not** cover:

- **PEP 703 (free-threaded Python) and `nogil` builds in depth** — Ramalho Ch.19 discusses the GIL's impact and mentions ongoing debates, but PEP 703 (making the GIL optional), the `--disable-gil` build flag in CPython 3.13+, the `PYTHON_GIL=0` environment variable, the implications for C extension compatibility, and the phased rollout plan are not covered in any owned book; Shaw's *CPython Internals* predates this development; the PEP itself, Python 3.13/3.14 release notes, and Sam Gross's `nogil` project documentation are needed
- **Rayon crate for Rust data parallelism in depth** — Blandy Ch.19 pp. 466–468 introduces Rayon briefly (parallel iterators, `par_iter()`), but the full Rayon API (`join`, `scope`, `ThreadPoolBuilder`, custom thread pools, parallel sorting, `ParallelIterator` combinators, work-stealing internals) is not covered; the Rayon crate documentation and blog posts by Niko Matsakis are needed
- **Java virtual thread internals and implementation details beyond Rahman** — Rahman Ch.2–3 covers virtual threads comprehensively, but the JEP specifications (JEP 444, JEP 425), the `Continuation` class internals, the mount/unmount lifecycle, the carrier thread pool implementation, and how the JVM scheduler differs from OS schedulers require the OpenJDK source code, JEP documents, and Ron Pressler's talks and blog posts
- **Python `asyncio.TaskGroup` as structured concurrency** — no owned book covers the `TaskGroup` API (Python 3.11+) for structured concurrency; Ramalho Ch.21 covers `asyncio` but predates `TaskGroup`; the Python 3.11+ documentation and PEP 654 (exception groups) are needed for this comparison with Java's `StructuredTaskScope`
- **Cross-language comparison of memory models** — Bos Ch.3 covers the Rust/C++ memory model, Goetz Ch.16 covers the Java Memory Model (JMM, happens-before), but no owned book systematically compares the three languages' memory models side-by-side; Python's memory model is largely undefined beyond the GIL's implicit sequential consistency guarantee; Hans Boehm's papers on memory models and the JLS Chapter 17 are needed
- **Structured concurrency in the Rust ecosystem** — neither Bos, Gjengset, Klabnik, nor Blandy covers Rust structured concurrency crates (`async-scoped`, `moro`, or the proposed `scope` API); this is an evolving area requiring crate documentation and Rust RFC discussions
- **Lock-free data structures beyond basic CAS patterns** — Bos Ch.10 mentions lock-free linked lists and RCU but does not implement them; Goetz Ch.15 covers a nonblocking stack and linked list; neither covers hazard pointers, epoch-based reclamation, or the `crossbeam` crate's lock-free data structures; the `crossbeam` documentation and academic papers on epoch-based memory reclamation are needed
- **Python's limited atomics and thread-safe operations** — no owned book covers which Python operations are atomic under the GIL (`list.append`, `dict[key] = value`, reference count operations), the `queue.Queue` implementation, or the `atomics` PyPI package; the CPython source code and Python Wiki's "Global Interpreter Lock" page are needed

---

## External Resources

### Sub-topic 1 — Concurrency Model Philosophy and Thread Basics

**Rust**
- The Rust Book — Fearless Concurrency: `https://doc.rust-lang.org/book/ch16-00-concurrency.html`
- The Rust Reference — Send and Sync: `https://doc.rust-lang.org/reference/special-types-and-traits.html#send-and-sync`
- Rust By Example — Threads: `https://doc.rust-lang.org/rust-by-example/std_misc/threads.html`
- The Rustonomicon — Send and Sync: `https://doc.rust-lang.org/nomicon/send-and-sync.html`

**Java**
- Java Language Specification — Threads and Locks (JLS Ch.17): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html`
- Oracle Tutorial — Concurrency: `https://docs.oracle.com/javase/tutorial/essential/concurrency/`
- Baeldung — Introduction to Thread Safety in Java: `https://www.baeldung.com/java-thread-safety`
- JEP 444 — Virtual Threads: `https://openjdk.org/jeps/444`

**Python**
- Python docs — `threading` module: `https://docs.python.org/3/library/threading.html`
- Python docs — Concurrency: `https://docs.python.org/3/library/concurrency.html`
- Real Python — An Intro to Threading in Python: `https://realpython.com/intro-to-python-threading/`
- Python Wiki — Global Interpreter Lock: `https://wiki.python.org/moin/GlobalInterpreterLock`

### Sub-topic 2 — The GIL: What It Is, Free-Threaded Python (PEP 703)

**Python**
- PEP 703 — Making the Global Interpreter Lock Optional in CPython: `https://peps.python.org/pep-0703/`
- Python 3.13 What's New — Free-threaded CPython: `https://docs.python.org/3.13/whatsnew/3.13.html#free-threaded-cpython`
- Python docs — Free-threaded CPython: `https://docs.python.org/3.13/howto/free-threading-python.html`
- Sam Gross — nogil project: `https://github.com/colesbury/nogil`
- Real Python — Python's GIL: A Guide to the Global Interpreter Lock: `https://realpython.com/python-gil/`
- Larry Hastings — "Removing Python's GIL: The Gilectomy" (PyCon talk): `https://www.youtube.com/watch?v=P3AyI_u66Bw`

**Rust**
- (Rust has no GIL — all thread safety is enforced at compile time via `Send`/`Sync`; see sub-topic 5)

**Java**
- (Java has no GIL — JVM threads are true OS threads with full parallelism; see sub-topic 3)

### Sub-topic 3 — Thread Primitives and Lifecycle

**Rust**
- Rust docs — `std::thread` module: `https://doc.rust-lang.org/std/thread/`
- Rust docs — `thread::spawn`: `https://doc.rust-lang.org/std/thread/fn.spawn.html`
- Rust docs — `thread::scope` (scoped threads): `https://doc.rust-lang.org/std/thread/fn.scope.html`
- Rust By Example — Threads: `https://doc.rust-lang.org/rust-by-example/std_misc/threads.html`

**Java**
- Java docs — `java.lang.Thread`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html`
- JEP 444 — Virtual Threads: `https://openjdk.org/jeps/444`
- JEP 425 — Virtual Threads (Preview): `https://openjdk.org/jeps/425`
- Baeldung — Virtual Threads in Java 21: `https://www.baeldung.com/java-virtual-thread-vs-thread`
- Ron Pressler — "Loom: Bringing Lightweight Threads to Java" (Inside Java): `https://inside.java/tag/loom`

**Python**
- Python docs — `threading` module: `https://docs.python.org/3/library/threading.html`
- Python docs — `threading.Thread`: `https://docs.python.org/3/library/threading.html#thread-objects`
- Python docs — `_thread` (low-level threading API): `https://docs.python.org/3/library/_thread.html`

### Sub-topic 4 — Shared State and Mutual Exclusion

**Rust**
- Rust docs — `std::sync::Mutex`: `https://doc.rust-lang.org/std/sync/struct.Mutex.html`
- Rust docs — `std::sync::RwLock`: `https://doc.rust-lang.org/std/sync/struct.RwLock.html`
- Rust docs — `std::sync::Arc`: `https://doc.rust-lang.org/std/sync/struct.Arc.html`
- Rust docs — `std::sync::Condvar`: `https://doc.rust-lang.org/std/sync/struct.Condvar.html`

**Java**
- Java docs — `java.util.concurrent.locks` package: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/package-summary.html`
- Java docs — `ReentrantLock`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantLock.html`
- Java docs — `ReentrantReadWriteLock`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantReadWriteLock.html`
- Baeldung — Guide to the Synchronized Keyword in Java: `https://www.baeldung.com/java-synchronized`
- Baeldung — Guide to java.util.concurrent.Locks: `https://www.baeldung.com/java-concurrent-locks`

**Python**
- Python docs — `threading.Lock`: `https://docs.python.org/3/library/threading.html#lock-objects`
- Python docs — `threading.RLock`: `https://docs.python.org/3/library/threading.html#rlock-objects`
- Python docs — `threading.Condition`: `https://docs.python.org/3/library/threading.html#condition-objects`
- Python docs — `threading.Semaphore`: `https://docs.python.org/3/library/threading.html#semaphore-objects`

### Sub-topic 5 — Send/Sync Traits and Compile-Time Safety

**Rust**
- The Rustonomicon — Send and Sync: `https://doc.rust-lang.org/nomicon/send-and-sync.html`
- The Rust Reference — Special types and traits (Send, Sync): `https://doc.rust-lang.org/reference/special-types-and-traits.html`
- Rust docs — `std::marker::Send`: `https://doc.rust-lang.org/std/marker/trait.Send.html`
- Rust docs — `std::marker::Sync`: `https://doc.rust-lang.org/std/marker/trait.Sync.html`
- Niko Matsakis — "Fearless Concurrency with Rust" (blog post): `https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html`

**Java**
- JLS Ch.17 — Threads and Locks (happens-before, visibility): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html`
- Baeldung — The volatile Keyword in Java: `https://www.baeldung.com/java-volatile`

**Python**
- (Python has no compile-time thread safety mechanism; the GIL provides implicit safety for single bytecode operations; see sub-topic 2)

### Sub-topic 6 — Lock-Free Programming and Atomics

**Rust**
- Rust docs — `std::sync::atomic` module: `https://doc.rust-lang.org/std/sync/atomic/`
- Rust docs — `AtomicBool`, `AtomicUsize`, `AtomicPtr`: `https://doc.rust-lang.org/std/sync/atomic/struct.AtomicUsize.html`
- Rust docs — `Ordering` enum: `https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html`
- `crossbeam` crate documentation: `https://docs.rs/crossbeam/latest/crossbeam/`

**Java**
- Java docs — `java.util.concurrent.atomic` package: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/package-summary.html`
- Java docs — `AtomicInteger`, `AtomicLong`, `AtomicReference`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/AtomicInteger.html`
- Java docs — `VarHandle` (Java 9+): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/invoke/VarHandle.html`
- Baeldung — Introduction to Lock-Free Data Structures: `https://www.baeldung.com/lock-free-programming`
- Doug Lea — "The java.util.concurrent Synchronizer Framework" (paper): `https://gee.cs.oswego.edu/dl/papers/aqs.pdf`

**Python**
- Python docs — `queue.Queue` (thread-safe queue): `https://docs.python.org/3/library/queue.html`
- Python Wiki — Atomic operations under the GIL: `https://wiki.python.org/moin/GlobalInterpreterLock`

### Sub-topic 7 — Thread Pools and Executors

**Rust**
- Rayon crate documentation: `https://docs.rs/rayon/latest/rayon/`
- Rayon — `par_iter` and parallel iterators: `https://docs.rs/rayon/latest/rayon/iter/index.html`
- `threadpool` crate documentation: `https://docs.rs/threadpool/latest/threadpool/`

**Java**
- Java docs — `ExecutorService`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ExecutorService.html`
- Java docs — `Executors` factory class: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Executors.html`
- Java docs — `ForkJoinPool`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ForkJoinPool.html`
- Baeldung — Guide to the Java ExecutorService: `https://www.baeldung.com/java-executor-service-tutorial`
- Baeldung — Guide to the Fork/Join Framework: `https://www.baeldung.com/java-fork-join`

**Python**
- Python docs — `concurrent.futures` module: `https://docs.python.org/3/library/concurrent.futures.html`
- Python docs — `ThreadPoolExecutor`: `https://docs.python.org/3/library/concurrent.futures.html#threadpoolexecutor`
- Python docs — `ProcessPoolExecutor`: `https://docs.python.org/3/library/concurrent.futures.html#processpoolexecutor`
- Real Python — concurrent.futures in Python: `https://realpython.com/python-concurrency/`

### Sub-topic 8 — Multiprocessing and IPC

**Python**
- Python docs — `multiprocessing` module: `https://docs.python.org/3/library/multiprocessing.html`
- Python docs — `multiprocessing.shared_memory`: `https://docs.python.org/3/library/multiprocessing.shared_memory.html`
- Python docs — `multiprocessing.Manager`: `https://docs.python.org/3/library/multiprocessing.html#managers`
- Real Python — multiprocessing in Python: `https://realpython.com/python-multiprocessing/`
- PEP 371 — Addition of the multiprocessing package: `https://peps.python.org/pep-0371/`

**Rust**
- Rust docs — `std::process` module: `https://doc.rust-lang.org/std/process/`
- `shared_memory` crate: `https://docs.rs/shared_memory/latest/shared_memory/`
- `ipc-channel` crate (Servo project): `https://docs.rs/ipc-channel/latest/ipc_channel/`

**Java**
- Java docs — `ProcessBuilder`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ProcessBuilder.html`
- Java docs — `java.nio.channels` (memory-mapped files, file locks): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/channels/package-summary.html`

### Sub-topic 9 — Structured Concurrency

**Java**
- JEP 462 — Structured Concurrency (Second Preview): `https://openjdk.org/jeps/462`
- JEP 453 — Structured Concurrency (Preview): `https://openjdk.org/jeps/453`
- JEP 464 — Scoped Values (Second Preview): `https://openjdk.org/jeps/464`
- Java docs — `StructuredTaskScope`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html`
- Inside Java — Structured Concurrency articles: `https://inside.java/tag/structured-concurrency`

**Rust**
- `crossbeam::scope` documentation: `https://docs.rs/crossbeam/latest/crossbeam/fn.scope.html`
- Rust docs — `std::thread::scope`: `https://doc.rust-lang.org/std/thread/fn.scope.html`
- RFC discussion — Scoped tasks and structured concurrency in async Rust: `https://github.com/rust-lang/rfcs`

**Python**
- Python docs — `asyncio.TaskGroup` (Python 3.11+): `https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup`
- PEP 654 — Exception Groups and `except*`: `https://peps.python.org/pep-0654/`
- Trio library — Structured concurrency for Python: `https://trio.readthedocs.io/en/stable/`
- "Notes on structured concurrency" by Nathaniel J. Smith: `https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| General | Paul Butcher — *Seven Concurrency Models in Seven Weeks* (Pragmatic Bookshelf, 2014) | Covers threads-and-locks, functional programming, actors, communicating sequential processes (CSP), data parallelism, GPU computing, and the Lambda Architecture — provides the conceptual framework for comparing the three languages' concurrency philosophies; language-agnostic concepts map directly to the Rust/Java/Python comparison |
| Rust | Alice Ryhl — Tokio documentation and blog posts | While Tokio is an async runtime (Topic 13), understanding how its `spawn_blocking` bridges sync and async code is relevant for Thread Pool discussion; the Tokio tutorial covers `task::spawn_blocking`, `JoinHandle`, and multi-threaded vs current-thread runtimes |

---

## Study Plan — 9 Sessions

Estimated total: **20–27 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from concurrency philosophy and thread basics through shared state, compile-time safety, lock-free programming, thread pools, multiprocessing, to structured concurrency.

---

### Session 1 — Concurrency Model Philosophy and Thread Basics

**Goal:** understand the fundamental concurrency philosophy of each language — Rust's "fearless concurrency" enforced by the type system, Java's shared-memory threading with monitor-based synchronization, Python's GIL-constrained threading — and spawn basic threads in each.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: fearless concurrency and thread spawning.** Read Bos Ch.1 pp. 1–6 (threads in Rust, scoped threads). Read Klabnik Ch.16 pp. 353–360 (using threads with `spawn`, `move` closures). Key insight: Rust's concurrency model is called "fearless" because the ownership system and type system prevent data races at compile time. `std::thread::spawn` takes a closure and returns a `JoinHandle`. The closure must be `'static` (own all its data) or use scoped threads (`std::thread::scope`, stabilized in Rust 1.63). The compiler rejects code that would share mutable references across threads without synchronization — if it compiles, it is free of data races. This is fundamentally different from Java and Python, where data races are possible at runtime and must be prevented through programmer discipline. |
| 1.2 | 30 min | **Java: threads from Java 1.0 to virtual threads.** Read Goetz Ch.1 pp. 1–12 (introduction: history, benefits, risks). Read Lea Ch.1 pp. 1–20 (concurrent OO programming: using concurrency constructs, objects and concurrency). Read Rahman Ch.1 pp. 1–30 (history of threads in Java, genesis of Java 1.0 threads, starting threads, hidden costs, executor framework evolution, the promise of virtual threads). Key insight: Java has had threads since 1.0 (1996) — every Java program is multithreaded (GC threads, finalizer thread, JIT compiler thread). Traditional Java threads are 1:1 mapped to OS threads (platform threads), making them expensive to create (~1MB stack each). Java's concurrency philosophy is shared-memory with cooperative synchronization: any thread can access any heap object, and programmers use `synchronized`, `volatile`, and `java.util.concurrent` to manage access. Lea's *Concurrent Programming in Java* establishes the design-pattern foundations: the three concurrency constructs (exclusion, state dependence, thread creation) and the design forces (safety, liveness, performance) that shape every concurrent Java program. Project Loom (Java 21) introduced virtual threads — lightweight threads (M:N scheduled onto platform threads) that make thread-per-request practical at massive scale without changing the programming model. |
| 1.3 | 25 min | **Python: GIL-constrained threading.** Read Ramalho Ch.19 pp. 695–714 (the big picture, jargon, processes/threads/GIL, concurrent hello world with threads/processes/coroutines, supervisors side-by-side). Read Hattingh Ch.2 pp. 9–20 (the truth about threads: benefits, drawbacks, race conditions case study). Read Beazley Ch.9.14 pp. 247–260 (blocking operations and concurrency: nonblocking I/O, threads). Key insight: Python (CPython) has the Global Interpreter Lock (GIL), a mutex that allows only one thread to execute Python bytecode at a time. This means Python threads provide concurrency (interleaving) but not parallelism for CPU-bound work. Threads are useful for I/O-bound work (the GIL is released during I/O operations, C extension calls, and `time.sleep`). Hattingh's robots-and-cutlery case study vividly demonstrates race conditions even under the GIL. For CPU-bound parallelism, Python programmers must use the `multiprocessing` module (separate processes with separate GILs) or C extensions that release the GIL. Ramalho demonstrates this with the spinner example: the thread-based spinner works for I/O but fails for CPU-bound computation; the process-based spinner achieves true parallelism. |
| 1.4 | 20 min | **Cross-language comparison.** Read Blandy Ch.19 pp. 457–459 (fork-join parallelism introduction, safety is invisible in Rust). Map the concurrency spectrum: Rust prevents data races at compile time (zero runtime overhead for safety); Java prevents nothing at compile time but provides rich runtime synchronization primitives; Python prevents most issues via the GIL (which also prevents true parallelism). Compare thread creation: Rust `thread::spawn(move || { ... })` (closure-based, compiler checks data ownership); Java `Thread.startVirtualThread(() -> { ... })` (any closure or Runnable, no compile-time safety); Python `threading.Thread(target=fn, args=(...)).start()` (any callable, GIL provides implicit atomicity for single bytecode ops). Note the trade-off triangle: Rust maximizes safety (compile-time), Java maximizes flexibility and performance (true OS threads, now virtual threads), Python maximizes simplicity (GIL makes many operations implicitly thread-safe at the cost of parallelism). |

---

### Session 2 — The GIL: What It Is, Free-Threaded Python (PEP 703)

**Goal:** deep-dive into CPython's Global Interpreter Lock — what it protects, why it exists, how it constrains parallelism, and how PEP 703 (free-threaded Python) aims to make it optional — with comparison to how Rust and Java solve the same problems without a GIL.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **The GIL in depth.** Read Ramalho Ch.19 pp. 713–724 (the real impact of the GIL: quick quiz, homegrown process pool, process-based solution, multicore prime checker, experimenting with more/fewer processes, thread-based nonsolution). Read Shaw pp. 221–260 (models of parallelism and concurrency, structure of a process, multithreading sections). Key insight: the GIL exists because CPython's memory management (reference counting) is not thread-safe. Every `Py_INCREF`/`Py_DECREF` would need to be atomic without the GIL, which would slow down single-threaded code (the common case) by 30–40%. The GIL is released during I/O syscalls, allowing I/O-bound concurrency. For CPU-bound work, Ramalho's prime checker demonstrates that threads provide zero speedup (they actually slow down due to GIL contention), while processes achieve near-linear speedup. The GIL is acquired/released every 5ms (configurable via `sys.setswitchinterval`), not per bytecode instruction. |
| 2.2 | 25 min | **PEP 703 and free-threaded Python.** Read PEP 703 online. Read the Python 3.13 "Free-threaded CPython" documentation online. Key insight: PEP 703 (Sam Gross, accepted 2023) makes the GIL optional. The `--disable-gil` build flag produces a CPython binary where threads achieve true parallelism. Key changes: (1) reference counting is replaced with biased reference counting (fast for the owning thread, atomic for other threads); (2) a new memory allocator (`mimalloc`) replaces `pymalloc`; (3) container operations use per-object locks instead of the GIL; (4) the `dict` and `list` implementations use lock-free reads. The rollout is phased: Python 3.13 includes experimental free-threaded builds; Python 3.14+ refines the approach. The main challenge: C extensions must be updated to work without the GIL (many assume single-threaded execution). This is the biggest change to CPython since Python 3.0. |
| 2.3 | 20 min | **How Rust and Java avoid the GIL problem.** Key insight: Rust avoids the need for a GIL through the ownership system. `Send` and `Sync` marker traits tell the compiler which types can cross thread boundaries. Reference counting (`Arc<T>`) uses atomic operations, but the compiler enforces this — you cannot accidentally use `Rc<T>` (non-atomic reference counting) across threads because `Rc<T>` does not implement `Send`. Java avoids the need for a GIL because the JVM uses a tracing garbage collector (no reference counting), and the Java Memory Model (JMM) defines precisely when changes by one thread become visible to another. Java's `volatile` keyword and `synchronized` blocks provide the visibility guarantees that the GIL implicitly provides in Python. Both Rust and Java demonstrate that a GIL is not inherent to programming languages — it is a CPython implementation choice driven by the simplicity of reference counting. |
| 2.4 | 15 min | **Comparison: implications for ecosystem.** Compare how each ecosystem handles the parallelism question. Rust: no issue, all threads run in parallel, the compiler ensures safety. Java: no issue, all threads run in parallel, programmer ensures safety via synchronization. Python: GIL forces a choice between (a) threads for I/O concurrency, (b) multiprocessing for CPU parallelism, (c) C extensions that release the GIL (NumPy, Polars), (d) free-threaded Python 3.13+ (experimental). Note that many high-performance Python libraries (NumPy, pandas, scikit-learn) already release the GIL in their C/Fortran/Rust backends — the GIL primarily constrains pure Python CPU-bound code. |

---

### Session 3 — Thread Primitives and Lifecycle

**Goal:** master the thread creation, lifecycle, and joining APIs in each language — Rust's `std::thread` (spawn, scope, join), Java's `Thread` class and virtual threads (Project Loom), Python's `threading.Thread` — understanding the differences in thread identity, naming, stack management, and error propagation.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 30 min | **Rust: `std::thread` API.** Read Bos Ch.1 pp. 2–6 (threads in Rust, scoped threads). Read Klabnik Ch.16 pp. 353–360 (using threads with `spawn`). Read Blandy Ch.19 pp. 459–468 (fork-join parallelism: `spawn`, `join`, error handling, sharing immutable data across threads). Key insight: `std::thread::spawn` takes a `FnOnce() -> T + Send + 'static` closure and returns `JoinHandle<T>`. The `'static` bound means the closure must own all its data (no borrowed references). `JoinHandle::join()` returns `Result<T, Box<dyn Any>>` — thread panics are caught and propagated via `join()`. Scoped threads (`std::thread::scope`) relax the `'static` requirement: threads in a scope can borrow from the parent's stack because the scope guarantees all threads join before returning. Rayon's `join(a, b)` function is a higher-level fork-join API that uses a work-stealing thread pool. |
| 3.2 | 35 min | **Java: platform threads vs virtual threads.** Read Rahman Ch.2 pp. 31–50 (what is a virtual thread, two kinds of threads, key differences, creating virtual threads, adapting to virtual threads, demonstrating creation, throughput and scalability, fundamental principle behind scalability). Read Goetz Ch.6 pp. 113–117 (executing tasks in threads). Key insight: Java 21 has two kinds of threads: platform threads (1:1 with OS threads, ~1MB stack, expensive) and virtual threads (M:N scheduled, ~1KB initial stack that grows, cheap). `Thread.ofVirtual().start(runnable)` or `Thread.startVirtualThread(runnable)` creates a virtual thread. Virtual threads are scheduled by the JVM onto a pool of carrier (platform) threads using `ForkJoinPool`. When a virtual thread blocks on I/O, it is "unmounted" from its carrier thread (the carrier is freed for other virtual threads) — this is why virtual threads scale to millions of concurrent tasks. Virtual threads should not be pooled (they are cheap to create). They share the same `Thread` API as platform threads — existing code works with minimal changes. |
| 3.3 | 20 min | **Python: `threading.Thread`.** Read Slatkin Item 68 pp. 324–330 (use threads for blocking I/O, avoid for parallelism). Read Slatkin Item 69 pp. 330–333 (use `Lock` to prevent data races in threads). Key insight: `threading.Thread(target=fn, args=(...))` creates a thread. `.start()` begins execution, `.join()` waits for completion. Python threads are real OS threads (via `pthreads` on Unix, Windows threads on Windows), but the GIL limits CPU parallelism. `threading.current_thread()` returns the current thread object. Daemon threads (`daemon=True`) are killed when the main thread exits. Slatkin's key advice: use threads for I/O-bound work only; use `multiprocessing` or `concurrent.futures.ProcessPoolExecutor` for CPU-bound work. Thread exceptions do not propagate to the parent — they kill the thread silently unless caught. |
| 3.4 | 15 min | **Cross-language comparison.** Compare thread lifecycle: creation cost (Rust: minimal stack + OS thread; Java platform: ~1MB stack + OS thread; Java virtual: ~1KB stack, no OS thread; Python: OS thread + GIL coordination). Compare joining semantics: Rust propagates panics via `Result` from `join()`; Java propagates exceptions only if checked via `Future.get()`; Python silently loses exceptions. Compare scoped/structured thread lifetimes: Rust's `thread::scope` guarantees all threads join; Java 21's `StructuredTaskScope` (preview) provides the same; Python has no equivalent (must manually join). Compare naming: all three support named threads for debugging. |

---

### Session 4 — Shared State and Mutual Exclusion

**Goal:** master the shared-state synchronization primitives in each language — Rust's `Mutex<T>`, `RwLock<T>`, `Arc<T>` (where the type system enforces correct usage), Java's `synchronized`, `ReentrantLock`, `volatile`, `ReadWriteLock`, and Python's `threading.Lock`, `RLock`, `Condition` — understanding how each language handles deadlock, lock poisoning, and contention.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: `Mutex<T>`, `RwLock<T>`, `Arc<T>`.** Read Bos Ch.1 pp. 7–29 (shared ownership and reference counting with `Arc<T>`, borrowing and data races, interior mutability, `Mutex` and `RwLock`, lock poisoning, reader-writer lock, condition variables). Read Klabnik Ch.16 pp. 365–374 (shared-state concurrency with `Mutex<T>` and `Arc<T>`, `Send`/`Sync`). Key insight: Rust's `Mutex<T>` wraps its data — you cannot access the protected data without locking the mutex. `mutex.lock()` returns a `MutexGuard<T>` that implements `Deref`/`DerefMut` for the inner data and automatically unlocks when dropped (RAII). This makes it impossible to forget to unlock or to access the data without locking. `Arc<T>` (atomic reference counting) enables shared ownership across threads. `Arc<Mutex<T>>` is the standard pattern for shared mutable state. Lock poisoning: if a thread panics while holding a lock, the mutex is "poisoned" — subsequent `lock()` calls return `Err(PoisonError)`, signaling that the protected data may be in an inconsistent state. `RwLock<T>` allows multiple readers or one writer. |
| 4.2 | 30 min | **Java: `synchronized`, `ReentrantLock`, `volatile`.** Read Goetz Ch.2 pp. 15–31 (thread safety, atomicity, locking, intrinsic locks, reentrancy, guarding state with locks). Read Goetz Ch.3 pp. 33–42 (visibility, `volatile`). Read Lea Ch.2 pp. 57–100 (exclusion: immutability, synchronization, confinement, structuring classes for concurrency). Read Goetz Ch.13 pp. 277–289 (explicit locks: `ReentrantLock`, performance, fairness, choosing between `synchronized` and `ReentrantLock`, read-write locks). Key insight: Java has two locking mechanisms: intrinsic locks (`synchronized` blocks/methods) and explicit locks (`ReentrantLock`). `synchronized` is built into the language — every object has an implicit monitor lock. `synchronized(obj) { ... }` acquires `obj`'s monitor; method-level `synchronized` acquires `this`'s monitor. Lea's treatment of exclusion provides the theoretical foundation: immutability as the simplest safety strategy, confinement as an alternative to synchronization, and design patterns for structuring classes that minimize lock contention. `ReentrantLock` (Java 5+) adds timed lock attempts (`tryLock(timeout)`), interruptible locking, fairness policies, and multiple condition queues. `volatile` ensures visibility (changes are immediately visible to all threads) but does not provide atomicity for compound operations (check-then-act, read-modify-write). Java locks are reentrant (a thread can acquire the same lock multiple times); Rust's `Mutex` is not reentrant. |
| 4.3 | 20 min | **Python: `threading.Lock` and friends.** Read Slatkin Item 69 pp. 330–333 (use `Lock` to prevent data races). Read Ramalho Ch.19 pp. 699–701 (processes, threads, and Python's infamous GIL). Key insight: Python's `threading.Lock` is a simple mutex (no reentrancy). `threading.RLock` is reentrant. `threading.Condition` wraps a lock with wait/notify semantics. `threading.Semaphore` limits access to a finite number of threads. Because of the GIL, Python's locks primarily protect against data races in compound operations (check-then-act patterns), not against memory visibility issues (the GIL provides sequential consistency). However, operations like `balance += amount` are not atomic in Python (it is a read-modify-write sequence of multiple bytecodes), so locks are still necessary for correctness. Compare with Rust: Python locks protect code regions; Rust's `Mutex<T>` protects data. Compare with Java: Python locks are simpler (no fairness, no timed acquire in the basic `Lock`); Java's locks are more feature-rich. |
| 4.4 | 20 min | **Java: state dependence and guarded methods.** Read Lea Ch.3 pp. 149–220 (state dependence: guarded methods using wait/notify/notifyAll, concurrency control utilities — semaphores, latches, barriers, joint actions). Key insight: Lea's treatment of state dependence complements Goetz's coverage of the same primitives. While Goetz focuses on practical usage of `java.util.concurrent` building blocks, Lea establishes the theoretical design patterns behind them: how to structure state-dependent actions, the semantics of guarded waits, and the principles used to build the utility classes (semaphores, latches, barriers) that later became `java.util.concurrent.Semaphore`, `CountDownLatch`, and `CyclicBarrier`. Understanding these patterns is essential for knowing when to use which synchronizer. |
| 4.5 | 15 min | **Comparison: lock semantics.** Compare the lock designs: Rust's `Mutex<T>` is data-oriented (the mutex owns the data, you get access only through the lock guard); Java's `synchronized` and `ReentrantLock` are code-oriented (the lock protects a critical section, any thread could access unprotected data); Python's `Lock` is convention-oriented (the lock exists, but nothing enforces that you hold it before accessing shared data). Compare deadlock: Rust's ownership prevents many deadlocks (you cannot hold two `MutexGuard`s in the wrong order if you structure the code correctly, but the compiler does not prevent all deadlocks); Java provides deadlock detection via `ThreadMXBean.findDeadlockedThreads()`; Python has no built-in deadlock detection. Compare lock poisoning: Rust has it (panic-aware); Java and Python do not. |

---

### Session 5 — Send/Sync Traits and Compile-Time Safety

**Goal:** deep-dive into Rust's `Send` and `Sync` marker traits as the foundation of its compile-time data race prevention — understanding what they guarantee, which types implement them, and how this mechanism compares to Java's memory model and Python's GIL-based safety.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 35 min | **Rust: `Send` and `Sync` in depth.** Read Bos Ch.1 pp. 16–17 (thread safety: `Send` and `Sync`). Read Klabnik Ch.16 pp. 372–374 (`Send` and `Sync` traits). Read Gjengset Ch.10 pp. 167–175 (shared memory, `Mutex`, `RwLock`, when to use which). Read Blandy Ch.19 pp. 479–482 (thread safety: `Send` and `Sync`). Key insight: `Send` means a type can be transferred to another thread (its ownership can be moved). `Sync` means a type can be referenced from multiple threads simultaneously (i.e., `&T` is `Send` if `T` is `Sync`). These are auto-traits: the compiler derives them automatically from the fields of a struct. `Rc<T>` is not `Send` (non-atomic reference counting is unsafe across threads). `Arc<T>` is both `Send` and `Sync`. `Cell<T>` and `RefCell<T>` are `Send` but not `Sync` (they use non-atomic interior mutability). Raw pointers (`*const T`, `*mut T`) are neither `Send` nor `Sync`. `Mutex<T>` makes any `Send` type `Sync`. The critical insight: Rust's type system statically prevents data races. If you try to share a `RefCell` across threads, the compiler rejects your code with a clear error message about `Sync` not being implemented. |
| 5.2 | 25 min | **How `Send`/`Sync` compose.** Read the Rustonomicon "Send and Sync" section online. Key insight: `Send` and `Sync` compose automatically: a struct is `Send` if all its fields are `Send`. This means user-defined types get the correct thread-safety behavior without any annotation. `unsafe impl Send for MyType {}` is the escape hatch — it tells the compiler "I am manually guaranteeing thread safety." This is required for types wrapping raw pointers (e.g., a custom smart pointer) and is the only case where the programmer must reason about thread safety manually. The key difference from Java/Python: Rust's thread safety is opt-out (everything is checked unless you use `unsafe`), while Java/Python thread safety is opt-in (nothing is checked unless you add synchronization). |
| 5.3 | 20 min | **Java: the Java Memory Model (JMM).** Read Goetz Ch.16 pp. 337–352 (the Java Memory Model: what is a memory model, happens-before, publication, initialization safety). Key insight: Java's thread safety relies on the Java Memory Model (JMM, JLS Chapter 17), which defines happens-before relationships. Without synchronization, changes by one thread may never become visible to another thread (compiler/CPU reordering, CPU caching). `synchronized` blocks establish happens-before edges (unlock happens-before subsequent lock). `volatile` reads/writes establish happens-before edges. `Thread.start()` happens-before any action in the started thread. `Thread.join()` completion happens-before the joining thread's return. Unlike Rust, Java has no compile-time enforcement — the programmer must correctly use `synchronized`/`volatile`/`concurrent` utilities. Incorrect programs compile and run but produce subtle, non-deterministic bugs. |
| 5.4 | 15 min | **Python: implicit safety through the GIL.** Key insight: Python's GIL provides a form of implicit sequential consistency — all bytecode operations appear to execute in a total order. This means Python has no equivalent of Java's visibility problem (where unsynchronized reads see stale values). However, the GIL does not make compound operations atomic. `counter += 1` compiles to `LOAD_FAST`, `LOAD_CONST`, `BINARY_ADD`, `STORE_FAST` — the GIL can be released between any of these instructions. So locks are still needed for correctness in multi-step operations. Compare the three approaches: Rust's `Send`/`Sync` is a compile-time type system solution (zero runtime cost, cannot be wrong); Java's JMM is a specification-based solution (programmer must understand happens-before, violations are silent bugs); Python's GIL is a runtime lock solution (simplest to reason about, but prevents parallelism). |
| 5.5 | 15 min | **Comparison: who catches the bugs?** Build a mental model: Rust catches data races at compile time (the code does not compile). Java relies on programmer discipline + static analysis tools (FindBugs, ErrorProne, `@GuardedBy` annotations) + runtime testing. Python relies on the GIL for simple operations and programmer discipline for compound operations. Note that Rust prevents data races but not all race conditions (logical races like TOCTOU are still possible). Java's `@ThreadSafe` and `@NotThreadSafe` annotations (Goetz Appendix A) are documentation, not enforcement. Python has no thread safety annotations. |

---

### Session 6 — Lock-Free Programming and Atomics

**Goal:** understand atomic operations and lock-free programming across all three languages — Rust's `std::sync::atomic` with explicit memory orderings, Java's `java.util.concurrent.atomic` with `VarHandle`, and Python's limited atomic guarantees under the GIL.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 40 min | **Rust: atomics and memory ordering.** Read Bos Ch.2 pp. 31–47 (atomics: load/store, fetch-and-modify, compare-and-exchange, practical examples). Read Bos Ch.3 pp. 49–73 (memory ordering: Relaxed, Release/Acquire, SeqCst, happens-before, fences, common misconceptions). Key insight: Rust's atomics (`AtomicBool`, `AtomicI32`, `AtomicUsize`, `AtomicPtr`) provide lock-free operations with explicit memory ordering. Every atomic operation requires specifying an `Ordering`: `Relaxed` (no ordering guarantees, only atomicity), `Acquire` (subsequent reads see all writes before the paired `Release`), `Release` (all prior writes become visible to a paired `Acquire`), `AcqRel` (both `Acquire` and `Release`), `SeqCst` (total global order, most expensive). Bos's examples are excellent: stop flag (`Relaxed` is sufficient), progress reporting (multiple threads, `Relaxed`), lazy initialization (`Acquire`/`Release`), compare-and-exchange for ID allocation. The critical insight: memory ordering is about what other memory accesses become visible, not about the atomic operation itself. `Relaxed` atomics are always atomic; the ordering affects surrounding non-atomic operations. |
| 6.2 | 25 min | **Java: `java.util.concurrent.atomic` and CAS.** Read Goetz Ch.15 pp. 319–335 (atomic variables and nonblocking synchronization: disadvantages of locking, hardware support for concurrency, atomic variable classes, nonblocking algorithms). Key insight: Java's `AtomicInteger`, `AtomicLong`, `AtomicReference` provide CAS (compare-and-set) operations: `compareAndSet(expected, newValue)` atomically updates the value only if it matches `expected`. `AtomicInteger.incrementAndGet()` uses CAS in a retry loop. Java 9 introduced `VarHandle` as a more flexible alternative to atomic classes, supporting different access modes (plain, opaque, acquire/release, volatile). Goetz shows nonblocking algorithms: a CAS-based stack and a linked list using `AtomicReference`. Java's atomics always use a single memory ordering model (roughly equivalent to Rust's `SeqCst`) unless `VarHandle` is used with explicit ordering modes. Compared to Rust: Java atomics are simpler (no ordering parameter) but less flexible (no `Relaxed` equivalent without `VarHandle`). |
| 6.3 | 15 min | **Python: limited atomics under the GIL.** Key insight: CPython does not have a standard atomic types library comparable to Rust or Java. The GIL makes certain operations implicitly atomic: bytecode operations like `list.append(x)`, `dict[key] = value`, and `x = shared_var` (single `STORE_FAST`/`LOAD_FAST`) are effectively atomic because the GIL is not released mid-bytecode-operation. However, this is an implementation detail of CPython, not a language guarantee — PyPy, GraalPy, and free-threaded CPython may not preserve these guarantees. For explicit thread-safe data exchange, Python provides `queue.Queue` (thread-safe FIFO queue using internal locks) and `threading.Event` (a simple one-bit flag). With free-threaded Python (PEP 703), true atomic primitives become necessary — this is an active area of development. |
| 6.4 | 15 min | **Comparison: atomics spectrum.** Map the atomics spectrum: Rust provides fine-grained control (five memory orderings, user chooses per operation), enabling maximum performance for lock-free algorithms. Java provides high-level atomic classes with implicit strong ordering, plus `VarHandle` for expert-level control (Java 9+). Python relies on the GIL for implicit atomicity (no explicit atomic types in the standard library). Note the trade-off: Rust's approach requires understanding memory ordering (hard to learn, easy to audit); Java's approach hides ordering behind a simple API (easy to learn, hard to optimize); Python's approach avoids the problem entirely (easiest to use, least powerful). |

---

### Session 7 — Thread Pools and Executors

**Goal:** master the executor and thread pool patterns across all three languages — Rust's Rayon (work-stealing parallel iterators), Java's `ExecutorService`, `ForkJoinPool`, and virtual thread executors, Python's `concurrent.futures` (`ThreadPoolExecutor`, `ProcessPoolExecutor`) — understanding how each abstracts thread management.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 30 min | **Rust: Rayon and work-stealing parallelism.** Read Blandy Ch.19 pp. 466–470 (Rayon, revisiting the Mandelbrot set with Rayon). Read Gjengset Ch.10 pp. 175–179 (worker pools, actor models). Key insight: Rayon provides data parallelism through parallel iterators. `vec.par_iter().map(|x| f(x)).collect()` distributes work across a global thread pool using work-stealing (idle threads steal tasks from busy threads' queues). `rayon::join(a, b)` forks two tasks and joins them. Rayon is zero-config: the global thread pool automatically sizes itself to the number of CPU cores. The key design insight: Rayon's parallel iterators have the same API as regular iterators — converting sequential code to parallel code often requires changing `.iter()` to `.par_iter()`. Unlike Java's `ExecutorService`, Rayon does not require explicit task submission or future management. Rayon guarantees that all spawned tasks complete before `join` returns (structured parallelism). For custom thread pool configuration, `ThreadPoolBuilder::new().num_threads(n).build_global()` sets the global pool size. |
| 7.2 | 30 min | **Java: `ExecutorService`, `ForkJoinPool`, and virtual thread executors.** Read Goetz Ch.6 pp. 117–133 (the Executor framework, finding exploitable parallelism). Read Goetz Ch.8 pp. 167–181 (applying thread pools: implicit couplings, sizing, configuring `ThreadPoolExecutor`). Read Lea Ch.4 pp. 291–382 (creating threads: oneway messages, thread-based services, parallel decomposition, active objects). Read Rahman Ch.3 pp. 91–112 (thread pool, Executor framework, `Callable` and `Future`, `ForkJoinPool`, why `ForkJoinPool` for virtual threads). Read Bloch Item 80 pp. 323–325 (prefer executors, tasks, and streams to threads). Key insight: Java's executor hierarchy is rich. Lea's earlier work establishes the foundational patterns — oneway messages, thread-based services, parallel decomposition, and the active object pattern — that directly informed the design of `java.util.concurrent.ExecutorService`. `ExecutorService` decouples task submission from execution. `Executors.newFixedThreadPool(n)` creates a pool of `n` platform threads. `Executors.newVirtualThreadPerTaskExecutor()` (Java 21) creates a new virtual thread per task (replacing pooling with per-task threads since virtual threads are cheap). `ForkJoinPool` uses work-stealing for divide-and-conquer parallelism. `ForkJoinPool.commonPool()` is the default pool used by parallel streams and `CompletableFuture`. With virtual threads, the guidance has shifted: do not pool virtual threads; instead, create one per task. `ThreadPoolExecutor` is still appropriate for CPU-bound work where you want to limit parallelism. |
| 7.3 | 25 min | **Python: `concurrent.futures`.** Read Ramalho Ch.20 pp. 743–772 (concurrent executors: `concurrent.futures`, `ThreadPoolExecutor`, `ProcessPoolExecutor`, `Executor.map`, downloads with progress display). Read Slatkin Item 74 pp. 361–363 (consider `ThreadPoolExecutor`). Read Slatkin Item 79 pp. 393–397 (consider `concurrent.futures` for true parallelism). Key insight: Python's `concurrent.futures` provides a unified API for thread-based and process-based parallelism. `ThreadPoolExecutor(max_workers=n)` manages a pool of threads (good for I/O-bound work under the GIL). `ProcessPoolExecutor(max_workers=n)` manages a pool of processes (good for CPU-bound work, bypasses the GIL). Both implement the same `Executor` API: `submit(fn, *args)` returns a `Future`, `map(fn, iterable)` applies `fn` in parallel. `as_completed(futures)` yields futures as they finish. Slatkin's Item 79 demonstrates the key insight: switching from `ThreadPoolExecutor` to `ProcessPoolExecutor` requires changing one line of code, but delivers true parallelism for CPU-bound work at the cost of inter-process serialization overhead. |
| 7.4 | 15 min | **Comparison: executor models.** Compare the three executor models: Rust's Rayon (work-stealing, parallel iterators, zero-config, compile-time safety) vs Java's `ExecutorService` hierarchy (rich API, virtual thread executors, `ForkJoinPool` for divide-and-conquer) vs Python's `concurrent.futures` (simple two-class API, thread vs process executors). Note the key design differences: Rayon is opinionated (one global work-stealing pool, structured parallelism); Java is flexible (multiple executor types, configurable policies, lifecycle management); Python is pragmatic (simple API, process pool as GIL workaround). Compare task sizing: Rayon handles fine-grained parallelism well (work-stealing avoids load imbalance); Java's `ForkJoinPool` similarly handles recursive decomposition; Python's `ProcessPoolExecutor` has high per-task overhead (serialization), so tasks must be coarse-grained. |

---

### Session 8 — Multiprocessing and IPC

**Goal:** understand multiprocessing as Python's primary mechanism for CPU-bound parallelism — the `multiprocessing` module, inter-process communication (IPC) mechanisms, shared memory, and process pools — and compare with Rust and Java's approaches to multi-process architectures.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 35 min | **Python: the `multiprocessing` module.** Read Gorelick & Ozsvald Ch.9 pp. 245–285 (overview of multiprocessing, estimating Pi using Monte Carlo, processes vs threads, using Python objects, replacing multiprocessing with Joblib, random numbers in parallel systems, finding prime numbers, queues of work). Key insight: the `multiprocessing` module spawns separate OS processes, each with its own Python interpreter and GIL. This is Python's primary mechanism for CPU-bound parallelism. `multiprocessing.Process(target=fn, args=(...))` creates a new process. `multiprocessing.Pool(n)` creates a pool of `n` worker processes with `pool.map(fn, iterable)` for parallel map operations. Data must be serialized (pickled) to cross process boundaries — this is the main overhead. `multiprocessing.Queue` provides inter-process communication. The start method (`fork`, `spawn`, `forkserver`) affects how child processes inherit parent state: `fork` is fast but unsafe with threads; `spawn` is safe but slower (re-imports modules); `forkserver` is a compromise. |
| 8.2 | 25 min | **Python: IPC mechanisms and shared memory.** Read Gorelick & Ozsvald Ch.9 pp. 278–308 (verifying primes using IPC: serial solution, naive pool, `Manager.Value` as flag, Redis as flag, `RawValue` as flag, mmap as flag, sharing numpy data, synchronizing file and variable access, file locking, locking a value). Key insight: Python offers multiple IPC mechanisms: (1) `multiprocessing.Queue` / `multiprocessing.Pipe` — message passing via serialization; (2) `multiprocessing.Value` / `multiprocessing.Array` — shared memory with synchronization (uses `ctypes` types, locked by default); (3) `multiprocessing.RawValue` / `multiprocessing.RawArray` — shared memory without locking (faster but unsafe); (4) `multiprocessing.shared_memory.SharedMemory` (Python 3.8+) — named shared memory blocks accessible across processes; (5) `multiprocessing.Manager` — proxy objects that synchronize access via a server process; (6) `mmap` — memory-mapped files for zero-copy shared data. The choice depends on the trade-off between performance and safety: `Manager` is safest but slowest; `RawValue` + explicit locks is fastest but requires manual synchronization. |
| 8.3 | 20 min | **Rust and Java: multi-process perspectives.** Key insight: Rust and Java rarely use multi-process architectures for parallelism within a single application because they have true thread-level parallelism. However, both support process creation: Rust's `std::process::Command` spawns external processes (similar to Python's `subprocess`). Java's `ProcessBuilder` provides the same. For IPC, Rust has `ipc-channel` (Servo's cross-process channels), `shared_memory` crate (shared memory segments), and Unix domain sockets. Java has `java.nio.channels` for memory-mapped files, `ProcessBuilder` for process management, and typically uses sockets, pipes, or message queues for IPC. The key contrast: Python uses multiprocessing as a workaround for the GIL; Rust and Java use multiprocessing for process isolation (sandboxing, fault isolation) rather than for parallelism. |
| 8.4 | 15 min | **Comparison: when to use processes vs threads.** Map the decision matrix across languages. Use threads when: sharing data is frequent and fine-grained (Rust, Java), or when doing I/O-bound work (all three). Use processes when: CPU isolation is needed (all three), fault isolation is needed (a crash in one task should not kill others), or the GIL prevents thread-level parallelism (Python). Note that containerization (Docker) and microservices have shifted the process-level parallelism question from within-application to between-applications. Python's `multiprocessing` is often a stepping stone to distributed systems (`celery`, `dask`, `ray`). |

---

### Session 9 — Structured Concurrency

**Goal:** understand structured concurrency as a paradigm for managing concurrent task lifetimes — Java 21's `StructuredTaskScope` (the most mature implementation among the three), Rust's scoped threads and ecosystem crates, Python's `asyncio.TaskGroup` (Python 3.11+) — and why unstructured concurrency is error-prone.

| Step | Time | Activity |
|------|------|----------|
| 9.1 | 35 min | **Java: structured concurrency with `StructuredTaskScope`.** Read Rahman Ch.4 pp. 125–180 (the challenge of unstructured concurrency, promise of structured concurrency, understanding the API, `StructuredTaskScope`, scopes and subtasks relationship and lifecycle, joining policies with `Joiner`, common joining policies, exception handling, configuration). Key insight: unstructured concurrency (fire-and-forget thread creation) leads to leaked threads, lost exceptions, and difficult cancellation. Java 21's `StructuredTaskScope` (preview) enforces that subtasks complete before the scope closes. `try (var scope = StructuredTaskScope.open()) { scope.fork(task1); scope.fork(task2); scope.join(); }` guarantees both tasks complete (or are cancelled) before the try-with-resources block exits. Joining policies control behavior: `ShutdownOnSuccess` cancels remaining tasks when one succeeds (useful for racing parallel requests); `ShutdownOnFailure` cancels remaining tasks when one fails (useful for all-or-nothing operations). Subtask results are available via `Subtask.get()` after `join()`. Exception handling is policy-driven: `ShutdownOnFailure.throwIfFailed()` rethrows the first exception. |
| 9.2 | 20 min | **Java: scoped values and nested scopes.** Read Rahman Ch.4 pp. 202–214 (memory consistency effects, nested scopes, observability). Read Rahman Ch.5 pp. 217–245 (scoped values: burden of passing context, `ThreadLocal` limitations, `ScopedValue` components, `ScopedValue` and structured concurrency, performance, migration). Key insight: `ScopedValue` (preview in Java 21) replaces `ThreadLocal` for structured concurrency. `ThreadLocal` is problematic with virtual threads: it allows mutable shared state, has unbounded lifetime, and is inherited by child threads (expensive copying). `ScopedValue` is immutable within a scope, automatically available to child tasks in a `StructuredTaskScope`, and cleaned up when the scope exits. `ScopedValue.where(key, value).run(task)` binds a value for the duration of `task`. This complements structured concurrency by providing structured context propagation. |
| 9.3 | 20 min | **Rust: scoped threads and structured concurrency.** Read Bos Ch.1 pp. 5–7 (scoped threads). Read Blandy Ch.19 pp. 461–463 (error handling across threads, sharing immutable data). Key insight: Rust's `std::thread::scope` (stabilized in Rust 1.63) provides structured concurrency for synchronous code: `thread::scope(|s| { s.spawn(|| task1()); s.spawn(|| task2()); })` guarantees all spawned threads join before the closure returns. This allows threads to borrow from the parent's stack (the `'static` lifetime requirement is relaxed). In async Rust, structured concurrency is more complex: `tokio::task::spawn` is unstructured (fire-and-forget), while crates like `async-scoped` and the `moro` experimental crate provide scoped task spawning. Rust's scoped threads solve the same problem as Java's `StructuredTaskScope` but at the thread level rather than the task level. The `crossbeam::scope` function (predating `std::thread::scope`) was the community solution that inspired the standard library addition. |
| 9.4 | 20 min | **Python: `asyncio.TaskGroup` and Trio.** Read the Python docs for `asyncio.TaskGroup` online. Read the Trio documentation's "Structured Concurrency" section online. Read the Nathaniel J. Smith blog post "Notes on structured concurrency" online. Key insight: Python 3.11 introduced `asyncio.TaskGroup` for structured concurrency in async code: `async with asyncio.TaskGroup() as tg: tg.create_task(coro1()); tg.create_task(coro2())` ensures all tasks complete (or are cancelled) before exiting the `async with` block. If any task raises an exception, all other tasks are cancelled and the exceptions are collected into an `ExceptionGroup` (PEP 654). The Trio library (by Nathaniel J. Smith) pioneered structured concurrency in Python with its "nursery" concept: `async with trio.open_nursery() as nursery: nursery.start_soon(task1)`. Smith's influential blog post argues that `go`-statement-style fire-and-forget concurrency is as harmful as `goto` — structured concurrency ensures that concurrent task lifetimes match lexical scopes. Note: `TaskGroup` is async-only; Python has no structured concurrency for `threading.Thread`. |
| 9.5 | 15 min | **Comparison and synthesis.** Compare structured concurrency across languages. Java has the most comprehensive implementation: `StructuredTaskScope` + `ScopedValue` + `Joiner` policies provide a complete framework for managing task lifetimes, cancellation, exception handling, and context propagation. Rust has native scoped threads (`std::thread::scope`) for synchronous code, but async structured concurrency is still evolving. Python has `asyncio.TaskGroup` for async code but nothing for threaded code. All three are converging on the same insight: concurrent task lifetimes should be lexically scoped, just like variable lifetimes. The key insight for the entire topic: each language's concurrency model reflects its core philosophy — Rust enforces safety at compile time (ownership prevents data races, scoped threads enforce structured lifetimes), Java provides rich runtime abstractions (virtual threads for scale, `StructuredTaskScope` for structure, JMM for memory safety), Python prioritizes simplicity (GIL for implicit safety, multiprocessing for parallelism, `TaskGroup` for async structure). |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Concurrency model philosophy and thread basics | Bos 1–6; Klabnik 353–360; Goetz 1–12; Lea 1–20; Rahman 1–30; Ramalho 695–714; Hattingh 9–20; Beazley 247–260; Blandy 457–459 | Rust Book Ch.16, JEP 444, Python `threading` docs, Python GIL Wiki |
| 2 | The GIL: what it is, free-threaded Python (PEP 703) | Ramalho 713–724; Shaw 221–260 | PEP 703, Python 3.13 free-threaded docs, Sam Gross nogil project |
| 3 | Thread primitives and lifecycle | Bos 2–6; Klabnik 353–360; Blandy 459–468; Rahman 31–50; Goetz 113–117; Slatkin 324–333 | `std::thread` docs, JEP 444, `threading.Thread` docs |
| 4 | Shared state and mutual exclusion | Bos 7–29; Klabnik 365–374; Goetz 15–53, 277–289; Lea 57–220; Slatkin 330–333; Ramalho 699–701 | `Mutex`/`RwLock`/`Arc` docs, `java.util.concurrent.locks` docs, `threading.Lock` docs |
| 5 | Send/Sync traits and compile-time safety | Bos 16–17; Klabnik 372–374; Gjengset 167–175; Blandy 479–482; Goetz 337–352 | Rustonomicon Send/Sync, JLS Ch.17, Rust Blog "Fearless Concurrency" |
| 6 | Lock-free programming and atomics | Bos 31–73; Goetz 319–335; Gjengset 179–188 | `std::sync::atomic` docs, `java.util.concurrent.atomic` docs, crossbeam docs |
| 7 | Thread pools and executors | Blandy 466–470; Gjengset 175–179; Goetz 113–133, 167–181; Lea 291–382; Rahman 91–112; Bloch 323–325; Ramalho 743–772; Slatkin 361–397 | Rayon docs, `ExecutorService` docs, `concurrent.futures` docs |
| 8 | Multiprocessing and IPC | Gorelick & Ozsvald 245–308; Ramalho 716–724 | `multiprocessing` docs, `multiprocessing.shared_memory` docs, PEP 371 |
| 9 | Structured concurrency | Rahman 125–245; Bos 5–7; Blandy 461–463 | JEP 462, `asyncio.TaskGroup` docs, PEP 654, Trio docs, Nathaniel J. Smith blog post |

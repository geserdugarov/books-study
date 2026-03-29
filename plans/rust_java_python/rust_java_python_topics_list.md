# Comparative Study: Rust × Java × Python

> A structured curriculum for gaining deep understanding of three fundamentally different programming languages by studying them in parallel, topic by topic.
>
> Sections are ordered for progressive learning — each layer builds on concepts from the previous one.

---

## Layer 1: Context & Setup

> Before writing a single line of code — understand *why* and *how* these languages exist and run.

### 1. Philosophy & Design Goals

- Historical context and creation motivation (why the language exists, what problem it solves)
- Core design tradeoffs: safety vs performance vs expressiveness
- Target domains and "sweet spots"
- Language specification governance (JCP/JSR, PEP, RFC process)
- Backwards compatibility philosophy and edition/versioning model

### 2. Build Systems & Toolchains

> You need this immediately to run code and follow along with every subsequent topic.

- Cargo (Rust) vs Maven/Gradle (Java) vs pip/uv/poetry/hatch (Python)
- Project scaffolding: `cargo new` vs `mvn archetype` vs `uv init`
- Dependency resolution algorithms
- Reproducible builds, lockfiles, dependency vendoring
- Mono-repo tooling and workspace support
- Cross-compilation and target platforms
- CI/CD integration patterns

### 3. Compilation & Execution

> How source code becomes something that runs — fundamentally different in all three.

- AOT compilation (Rust/LLVM) vs JIT compilation (JVM HotSpot C1/C2, GraalVM) vs interpreted bytecode (CPython)
- MIR/HIR/LLVM IR (Rust) vs Java bytecode vs Python bytecode (`dis` module)
- Link-time optimization, PGO, cross-compilation
- GraalVM Native Image vs standard JVM startup
- Alternative runtimes: PyPy (tracing JIT), GraalPy, Cython, mypyc
- Compile-time computation: const generics, `const fn` (Rust), annotation processing (Java), metaclasses (Python)
- Build profiles, optimization levels, debug info

---

## Layer 2: Core Language Mechanics

> The foundational building blocks — types, memory, errors, objects. Everything else rests on these.

### 4. Type System

- Static vs dynamic vs gradual typing
- Type inference mechanisms (Hindley-Milner influence in Rust, `var` in Java, mypy/pyright in Python)
- Primitive types vs reference types vs everything-is-an-object
- Generics: monomorphization (Rust) vs type erasure (Java) vs duck typing (Python)
- Algebraic data types, enums, sealed classes, union types
- Nullability: `Option<T>` vs `Optional<T>` vs `None`
- Variance: covariance/contravariance in generics and lifetimes
- Type bounds, trait bounds, upper/lower bounded wildcards
- Phantom types and zero-sized types (Rust-specific, but worth contrasting with Java's type-level tricks)

### 5. Memory Model & Management

> Requires understanding of types (§4) — how values of those types are stored, moved, and freed.

- Stack vs heap allocation strategies and when each language uses which
- Ownership, borrowing, and lifetimes (Rust) vs GC roots and reachability (Java) vs reference counting + cycle collector (CPython)
- Move semantics vs copy semantics vs reference semantics
- Interior mutability (`Cell`, `RefCell`, `UnsafeCell` in Rust)
- Java GC algorithms deep dive: G1, ZGC, Shenandoah — generational hypothesis, safepoints, card tables
- Python's `gc` module, `__del__`, weak references, `sys.getrefcount`
- RAII / deterministic destruction vs finalizers vs context managers
- Memory layout: struct padding, alignment, `repr` in Rust, JVM object headers, Python object internals (`PyObject` struct)
- Escape analysis (JVM) and its effect on allocation
- Arena allocation patterns across all three

### 6. Ownership & Mutability

> Tightly coupled with §5 — how each language controls who can read/write what, and when.

- Immutable by default (Rust) vs mutable by default (Java, Python)
- Shared XOR mutable (`&T` vs `&mut T`)
- `final` (Java), `frozenset`/`tuple` (Python) — shallow vs deep immutability
- Interior mutability patterns revisited at the API design level
- Copy-on-write (`Cow<T>` in Rust, implications elsewhere)

### 7. Error Handling

> Uses types (§4) and ownership/RAII (§5–6) — `Result<T,E>`, exception unwinding, resource cleanup.

- `Result<T, E>` and the `?` operator (Rust) vs checked/unchecked exceptions (Java) vs exception hierarchy (Python)
- `panic!` vs `unwrap` vs recoverable errors (Rust)
- Error propagation patterns and error type composition
- `try-with-resources` (Java) vs context managers (Python) vs RAII (Rust)
- Custom error types: `thiserror`/`anyhow` (Rust), chained exceptions (Java), exception groups (Python 3.11+)

### 8. Object Model & Polymorphism

> Builds on types (§4), memory (§5), and mutability (§6) — how you compose behavior.

- Structs + traits (Rust) vs class hierarchy (Java) vs dynamic duck-typed objects (Python)
- Inheritance vs composition: why Rust has no inheritance
- Trait objects and dynamic dispatch (`dyn Trait`, vtable layout) vs Java interfaces/abstract classes vs Python protocols/ABCs
- Static dispatch vs dynamic dispatch tradeoffs
- Method resolution order: Rust's coherence rules, Java's single inheritance + interfaces, Python's C3 linearization (MRO)
- Companion objects (Rust `impl` blocks) vs static methods vs classmethods/staticmethods
- Operator overloading: `std::ops` traits vs limited Java support vs `__dunder__` methods
- Data classes: Rust `#[derive]` vs Java records vs Python `@dataclass`
- Pattern matching across all three

---

## Layer 3: Practical Patterns

> Daily-use tools — how you structure data, organize code, and extend the language itself.

### 9. Collections & Iterators

> Uses types (§4), ownership (§5–6), and polymorphism (§8) — the data structures you'll touch every day.

- Standard collection types and their internal data structures
- Iterator protocol: `Iterator`/`IntoIterator` traits (Rust) vs `Iterable`/`Iterator` (Java) vs `__iter__`/`__next__` (Python)
- Lazy evaluation: Rust iterators, Java streams, Python generators
- Functional combinators: `map`/`filter`/`fold` vs Stream API vs comprehensions/generator expressions
- Ownership in collections: what happens when you iterate, borrow, or consume
- Specialized collections: `BTreeMap`, `VecDeque` (Rust), `ConcurrentHashMap` (Java), `collections`/`defaultdict` (Python)

### 10. Module System & Code Organization

> How real projects are structured — visibility, encapsulation, dependency boundaries.

- Crates/modules/`mod.rs` (Rust) vs packages/classes/JARs (Java) vs modules/packages/`__init__.py` (Python)
- Visibility: `pub`/`pub(crate)`/private (Rust) vs `public`/`protected`/package-private/`private` (Java) vs name-mangling conventions (Python)
- Dependency management: Cargo vs Maven/Gradle vs pip/uv/poetry
- Semantic versioning enforcement and API compatibility
- Conditional compilation and feature flags (`#[cfg]`, Cargo features)

### 11. Metaprogramming

> Extending or generating code — requires solid understanding of the object model (§8) and module system (§10).

- Macros: declarative (`macro_rules!`) and procedural macros, derive macros (Rust)
- Reflection and annotation processing (Java)
- Metaclasses, decorators, descriptors, `__init_subclass__` (Python)
- Code generation at compile time vs runtime
- Annotation/attribute systems: `#[derive]`, `#[serde]` (Rust) vs `@Override`, Lombok (Java) vs `@dataclass`, `@property` (Python)
- AST manipulation capabilities

---

## Layer 4: Concurrency & Async

> Requires deep understanding of memory (§5), ownership (§6), and types (§4) — especially `Send`/`Sync` in Rust.

### 12. Concurrency & Parallelism

- Concurrency model philosophy: fearless concurrency (Rust) vs shared-memory threads (Java) vs GIL-constrained threading (Python)
- The GIL: what it is, PEP 703 (free-threaded Python), `nogil` builds
- Thread primitives: `std::thread` (Rust) vs `java.lang.Thread`/virtual threads (Project Loom) vs `threading` module
- Shared state: `Mutex<T>`, `RwLock<T>`, `Arc<T>` (Rust) vs `synchronized`/`ReentrantLock`/`volatile` (Java) vs `threading.Lock` (Python)
- `Send` and `Sync` marker traits (Rust) — compile-time data race prevention
- Lock-free programming: atomics (`std::sync::atomic`, `java.util.concurrent.atomic`, Python's limited atomics)
- Thread pools and executors: Rayon (Rust) vs `ForkJoinPool`/`ExecutorService` (Java) vs `concurrent.futures` (Python)
- Multiprocessing as a workaround for GIL: `multiprocessing` module, IPC mechanisms
- Structured concurrency (Java 21+, Rust crate ecosystem, Python `asyncio.TaskGroup`)

### 13. Async Programming

> Builds directly on §12 — same problems, different execution model.

- Async model fundamentals: stackless coroutines (Rust) vs virtual threads + reactive (Java) vs coroutines (Python `asyncio`)
- `Future` trait and zero-cost async (Rust) vs `CompletableFuture` (Java) vs `asyncio.Future`/awaitables (Python)
- Runtime architecture: Tokio/async-std (Rust) vs Netty/Project Loom (Java) vs event loop (Python)
- `async`/`await` syntax and desugaring in each language
- Pinning (`Pin<T>`) and self-referential futures (Rust)
- Cancellation semantics across all three
- Backpressure and flow control: `Stream` (Rust) vs `Flow`/reactive streams (Java) vs async generators (Python)
- Colored function problem and how each language deals with (or doesn't deal with) it

---

## Layer 5: Advanced — Breaking the Rules

> The escape hatches — when safety guarantees are intentionally bypassed. Unsafe first, because FFI depends on it.

### 14. Unsafe Code & Low-Level Access

- `unsafe` blocks and what they unlock (Rust) — raw pointers, FFI, union access
- `sun.misc.Unsafe` / `VarHandle` / Panama (Java) — off-heap memory, CAS operations
- CPython C API, buffer protocol, `memoryview` (Python)
- Inline assembly, SIMD intrinsics
- When and why to reach for unsafe in each ecosystem

### 15. FFI & Interoperability

> Requires §14 — crossing language boundaries always involves unsafe territory.

- C FFI: `extern "C"`, `#[no_mangle]`, `unsafe` (Rust) vs JNI/JNA/Panama (Java) vs ctypes/cffi/PyO3 (Python)
- ABI stability considerations
- Cross-language calling: PyO3, jni crate, GraalVM polyglot
- Embedding one runtime inside another
- Serialization formats for cross-language communication: protobuf, flatbuffers, Arrow IPC
- WASM as a universal interop target

---

## Layer 6: Engineering Practice

> Cross-cutting concerns that tie everything together — quality, performance, ecosystem.

### 16. Testing & Quality

- Built-in test frameworks: `#[test]`, `cargo test` (Rust) vs JUnit/TestNG (Java) vs `pytest`/`unittest` (Python)
- Property-based testing: `proptest` (Rust) vs `jqwik` (Java) vs `hypothesis` (Python)
- Benchmarking: `criterion` (Rust) vs JMH (Java) vs `timeit`/`pytest-benchmark` (Python)
- Mocking strategies and how the type system affects them
- Fuzzing: `cargo-fuzz`/`libFuzzer` (Rust) vs Jazzer (Java) vs Atheris (Python)
- Static analysis: Clippy (Rust) vs SpotBugs/ErrorProne (Java) vs Ruff/pylint (Python)
- Code coverage tools and integration

### 17. Performance Characteristics

> Requires understanding of compilation (§3), memory (§5), and concurrency (§12) to reason about properly.

- Zero-cost abstractions (Rust) vs JIT-optimized hotpaths (Java) vs interpreter overhead (Python)
- Benchmarking methodology: microbenchmarks vs real-world
- Memory footprint comparison for equivalent programs
- Startup time: native binary vs JVM warmup vs interpreter startup
- Profiling tools: `perf`/`flamegraph` (Rust), async-profiler/JFR (Java), `cProfile`/`py-spy` (Python)
- Common optimization patterns in each language

### 18. Ecosystem & Package Management

- crates.io vs Maven Central vs PyPI — governance, trust models, security
- Standard library philosophy: batteries-included (Python) vs minimal core (Rust) vs middle ground (Java)
- Key ecosystem crates/libraries for common tasks (HTTP, serialization, CLI, DB)
- Supply chain security: `cargo-audit`, Dependabot, `safety`/`pip-audit`

### 19. Ecosystem for Specific Domains

- Web: Actix/Axum (Rust) vs Spring/Quarkus (Java) vs Django/FastAPI (Python)
- Data: Polars/DataFusion (Rust) vs Spark (Java/Scala) vs pandas/NumPy (Python)
- CLI tools, systems programming, embedded
- ML/AI: `tch-rs`/`candle` (Rust) vs DJL (Java) vs PyTorch/TensorFlow (Python)
- How Rust increasingly serves as the backend for Python libraries (Polars, Pydantic v2, Ruff, cryptography)

---

## Layer 7: Capstone

### 20. Language Evolution & Future

> With full context from all previous layers, you can now evaluate where each language is heading.

- Rust editions (2015, 2018, 2021, 2024) and the edition system
- Java's six-month release cadence, preview features, incubator modules
- Python's annual release cycle, PEPs, typing evolution
- Major upcoming features: Rust (async traits stabilization, polonius), Java (Valhalla value types, patterns), Python (free-threaded, JIT compiler in 3.13+)
- Deprecation and migration strategies

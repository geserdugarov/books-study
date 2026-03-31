# Layer 2 · Topic 5 — Memory Model & Management

> Comparative study of Rust, Java, and Python: how each language stores, moves, and frees data — from stack/heap allocation through ownership and garbage collection to memory layout internals and advanced allocation strategies.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.4 pp. 59–83 | Ownership rules, variable scope, String type, memory and allocation, references and borrowing, mutable references, dangling references, slices |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.10 pp. 181–213 | Lifetimes — preventing dangling references, borrow checker, generic lifetime annotations, lifetime elision rules, the `'static` lifetime |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.15 pp. 315–351 | Smart Pointers — `Box<T>`, Deref, Drop, `Rc<T>`, `RefCell<T>`, interior mutability, `Weak<T>`, reference cycles |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.3 pp. 43–69 | Pointer types — references, boxes, raw pointers |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.4 pp. 71–90 | Ownership — moves, Copy types, Rc, Arc |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.5 pp. 93–121 | References — borrowing, lifetime parameters, reference safety, sharing versus mutation |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.9 pp. 193–209 | Struct Layout, Interior Mutability — Cell, RefCell |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.13 pp. 281–301 | Utility Traits — Drop, Sized, Clone, Copy, Deref/DerefMut, Cow |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.21 pp. 525–583 | Unsafe Code — raw pointers, dereferencing, FFI |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.1 pp. 1–17 | Foundations — memory terminology, memory regions (stack/heap/static), ownership, borrowing, interior mutability, lifetimes, variance |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.2 pp. 19–35 | Types in Memory — alignment, layout, complex types, dynamically sized types, wide pointers |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.10 pp. 167–192 | Lower-Level Concurrency — memory operations, atomic types, memory ordering |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.12 pp. 211–222 | Rust Without the Standard Library — dynamic memory allocation, OOM handler, low-level memory accesses |
| Rust | McNamara (2021) — *Rust in Action* | Ch.4 pp. 107–133 | Lifetimes, Ownership, and Borrowing — owner responsibilities, how ownership moves, resolving ownership issues |
| Rust | McNamara (2021) — *Rust in Action* | Ch.6 pp. 175–211 | Memory — pointers, smart pointer building blocks, stack/heap, dynamic memory allocation, virtual memory |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.5 pp. 93–118 | Working with Memory — heap/stack, ownership, copies, borrowing, smart pointers (Box, Rc, Arc), Cow, custom allocators |
| Java | Oaks (2020) — *Java Performance* | Ch.4 pp. 89–120 | JIT Compiler — escape analysis, inlining, advanced compiler flags |
| Java | Oaks (2020) — *Java Performance* | Ch.5 pp. 121–152 | Introduction to Garbage Collection — GC overview, generational garbage collectors, GC algorithms, basic GC tuning (sizing heap, generations, metaspace) |
| Java | Oaks (2020) — *Java Performance* | Ch.6 pp. 153–201 | Garbage Collection Algorithms — Throughput Collector, G1 Garbage Collector, CMS Collector, ZGC, Shenandoah, Epsilon GC, advanced tunings |
| Java | Oaks (2020) — *Java Performance* | Ch.7 pp. 203–248 | Heap Memory Best Practices — heap analysis, reducing object size, lazy initialization, object reuse, soft/weak/other references, compressed oops |
| Java | Oaks (2020) — *Java Performance* | Ch.8 pp. 249–265 | Native Memory Best Practices — native memory tracking, large pages |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.1 pp. 1–42 | HotSpot GC — generational GC, stop-the-world, concurrent algorithms, weak generational hypothesis |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.6 pp. 177–217 | Advanced Memory Management — TLABs/PLABs, NUMA-aware GC, G1 deep dive, regionalized heap, ZGC, GC performance evaluation |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.7 pp. 219–270 | String Optimizations — literal and interned string optimization, string deduplication with G1, reducing string footprint |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.8 pp. 273–306 | Accelerating Time to Steady State — Class Data Sharing, AOT compilation, GraalVM |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.5 pp. 119–166 | Java Memory Model — JMM, happens-before, concurrency through bytecode |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.7 pp. 207–246 | Understanding Java Performance — GC (mark-sweep, generations, G1, parallel GC), JIT compilation |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.17 pp. 571–607 | Modern Internals — Unsafe API |
| Java | Bloch (2018) — *Effective Java* | Ch.2 pp. 5–35 | Creating and Destroying Objects — Item 6: avoid creating unnecessary objects, Item 7: eliminate obsolete object references, Item 8: avoid finalizers and cleaners |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.2 pp. 42–52 | Memory-Mapped Files, File Locking |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.13 pp. 160–174 | Native Methods — JNI, Foreign Function & Memory API |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.5 pp. 124–154 | Common Exceptions — NullPointerException, OutOfMemoryError |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.9 pp. 249–272 | Library Methods — accidental invalidation of weak/soft references, non-atomic access to concurrent data structures |
| Python | Shaw (2020) — *CPython Internals* | Ch.7 pp. 177–219 | Memory Management — C memory allocation, CPython memory allocator design, object/PyMem/raw domains, custom allocators, PyArena, reference counting, garbage collection (cycle collector) |
| Python | Shaw (2020) — *CPython Internals* | Ch.8 pp. 221–283 | Parallelism and Concurrency — the Global Interpreter Lock, multiprocessing, multithreading, async/await |
| Python | Shaw (2020) — *CPython Internals* | Ch.9 pp. 285–315 | Objects and Types — PyObject struct, variable-size objects (PyVarObject), the type type, built-in type internals (bool, long, str, dict) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.6 pp. 201–228 | Object References, Mutability, and Recycling — variables as labels, identity vs equality, aliasing, shallow/deep copies, del and garbage collection |
| Python | Ramalho (2022) — *Fluent Python* | Ch.11 pp. 363–396 | A Pythonic Object — `__slots__` for memory optimization |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.1 pp. 1–20 | Understanding Performant Python — CPU/RAM/cache hierarchies, how Python abstracts over hardware |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.3 pp. 65–77 | Lists and Tuples — lists as dynamic arrays (over-allocation, resizing), tuples as static arrays (exact memory, immutable) |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.4 pp. 79–95 | Dictionaries and Sets — hash table implementation, hash functions, collisions, resizing |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.6 pp. 109–160 | Matrix and Vector Computation — memory fragmentation, NumPy vectorization, in-place operations |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.11 pp. 341–390 | Using Less RAM — Python object memory overhead, array module, NumPy memory, bytes vs Unicode, probabilistic data structures |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.14 pp. 429–441 | Customizing Execution — garbage collection (reference counting, cycle detector, gc module), internal types |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.15 pp. 443–483 | Concurrency — the Global Interpreter Lock, the mmap module (memory-mapped files) |

### Coverage Gaps

The owned books **do not** cover:

- **JVM object header layout at byte level** — Oaks covers compressed oops at the tuning level but none of the books provide a byte-by-byte breakdown of the mark word, klass pointer, and array length fields in HotSpot object headers; this requires Aleksey Shipilev's "Java Objects Inside Out" blog post or the OpenJDK JOL (Java Object Layout) tool documentation
- **Rust `repr` attributes in full depth** — Blandy covers struct layout and Gjengset covers alignment, but the complete semantics of `repr(C)`, `repr(transparent)`, `repr(packed)`, `repr(align(N))` and their interaction with FFI are only fully documented in the Rust Reference and the Rustonomicon
- **Arena allocation in Rust** — Matthews mentions custom allocators briefly, and Gjengset covers the allocator API in no_std contexts, but none of the owned Rust books dedicate material to arena allocation patterns (`bumpalo`, `typed-arena` crate); this is primarily documented in crate-level documentation and blog posts
- **Java safepoints and card tables in depth** — the GC books cover safepoints conceptually but do not explain the implementation details (polling mechanism, safepoint bias, card table dirty-bit marking) at the level needed for JVM internals understanding; this requires HotSpot source code and Aleksey Shipilev's JVM Anatomy Quarks blog series
- **Python's `tracemalloc` module and memory debugging** — Shaw covers the allocator layers and the gc module, but none of the owned Python books cover `tracemalloc` (PEP 454) for tracking memory allocations, which is essential for debugging memory issues in production
- **Cross-language arena/region allocation comparison** — no owned book provides a systematic comparison of arena patterns across Rust (`bumpalo`), Java (off-heap via `ByteBuffer`/`MemorySegment`), and Python (`PyArena` internals); this requires synthesizing across separate sources

---

## External Resources

### Sub-topic 1 — Stack vs Heap Allocation

**Rust**
- The Rust Reference — Memory Allocation: `https://doc.rust-lang.org/reference/memory-allocation.html`
- The Rustonomicon — Lifetimes and the Stack: `https://doc.rust-lang.org/nomicon/lifetimes.html`
- Rust By Example — Box, stack and heap: `https://doc.rust-lang.org/rust-by-example/std/box.html`

**Java**
- JVM Specification — Run-Time Data Areas: `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html#jvms-2.5`
- Baeldung — Stack Memory and Heap Space in Java: `https://www.baeldung.com/java-stack-heap`

**Python**
- Python docs — Memory Management: `https://docs.python.org/3/c-api/memory.html`
- RealPython — Memory Management in Python: `https://realpython.com/python-memory-management/`

### Sub-topic 2 — Ownership, Borrowing & Lifetimes

**Rust**
- The Rust Reference — Ownership: `https://doc.rust-lang.org/reference/ownership.html`
- The Rustonomicon — Ownership: `https://doc.rust-lang.org/nomicon/ownership.html`
- The Rustonomicon — Lifetimes: `https://doc.rust-lang.org/nomicon/lifetimes.html`
- The Rustonomicon — Borrow Splitting: `https://doc.rust-lang.org/nomicon/borrow-splitting.html`
- RFC 2094 — Non-lexical lifetimes: `https://rust-lang.github.io/rfcs/2094-nll.html`

### Sub-topic 3 — Garbage Collection (Java & Python)

**Java**
- Oracle GC Tuning Guide: `https://docs.oracle.com/en/java/javase/21/gctuning/`
- JEP 248 — Make G1 the Default Garbage Collector: `https://openjdk.org/jeps/248`
- JEP 333 — ZGC: A Scalable Low-Latency Garbage Collector: `https://openjdk.org/jeps/333`
- JEP 189 — Shenandoah: A Low-Pause-Time Garbage Collector: `https://openjdk.org/jeps/189`
- Aleksey Shipilev — JVM Anatomy Quarks series: `https://shipilev.net/jvm/anatomy-quarks/`

**Python**
- Python docs — gc module: `https://docs.python.org/3/library/gc.html`
- Python docs — sys.getrefcount: `https://docs.python.org/3/library/sys.html#sys.getrefcount`
- PEP 442 — Safe object finalization: `https://peps.python.org/pep-0442/`
- CPython Developer Guide — Garbage collector design: `https://devguide.python.org/internals/garbage-collector/`

### Sub-topic 4 — Move, Copy & Reference Semantics

**Rust**
- The Rust Reference — Copy and Clone: `https://doc.rust-lang.org/reference/special-types-and-traits.html#copy`
- The Rustonomicon — Drop Check: `https://doc.rust-lang.org/nomicon/dropck.html`
- Rust By Example — Ownership/Moves: `https://doc.rust-lang.org/rust-by-example/scope/move.html`

**Java**
- JLS — Assignment Expressions: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.26`

**Python**
- Python docs — Data model (objects, values, types): `https://docs.python.org/3/reference/datamodel.html`
- Python docs — copy module: `https://docs.python.org/3/library/copy.html`

### Sub-topic 5 — Interior Mutability

**Rust**
- The Rust Reference — Interior Mutability: `https://doc.rust-lang.org/reference/interior-mutability.html`
- The Rustonomicon — Concurrency: `https://doc.rust-lang.org/nomicon/concurrency.html`
- std docs — Cell module: `https://doc.rust-lang.org/std/cell/index.html`
- std docs — UnsafeCell: `https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html`

### Sub-topic 6 — RAII, Drop, Finalizers & Context Managers

**Rust**
- The Rust Reference — Destructors: `https://doc.rust-lang.org/reference/destructors.html`
- std docs — Drop trait: `https://doc.rust-lang.org/std/ops/trait.Drop.html`

**Java**
- JLS — Finalization: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-12.html#jls-12.6`
- JEP 421 — Deprecate Finalization for Removal: `https://openjdk.org/jeps/421`
- Java docs — Cleaner: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/Cleaner.html`
- Java docs — AutoCloseable: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html`

**Python**
- Python docs — `__del__` method: `https://docs.python.org/3/reference/datamodel.html#object.__del__`
- Python docs — Context Manager Types: `https://docs.python.org/3/reference/datamodel.html#context-managers`
- PEP 343 — The "with" Statement: `https://peps.python.org/pep-0343/`
- Python docs — contextlib: `https://docs.python.org/3/library/contextlib.html`

### Sub-topic 7 — Memory Layout & Object Headers

**Rust**
- The Rust Reference — Type Layout: `https://doc.rust-lang.org/reference/type-layout.html`
- The Rustonomicon — Data Representation: `https://doc.rust-lang.org/nomicon/data.html`
- The Rustonomicon — repr(Rust), repr(C), repr(transparent), repr(packed): `https://doc.rust-lang.org/nomicon/other-reprs.html`

**Java**
- Aleksey Shipilev — Java Objects Inside Out: `https://shipilev.net/jvm/objects-inside-out/`
- OpenJDK JOL (Java Object Layout) tool: `https://openjdk.org/projects/code-tools/jol/`
- JVM Specification — The class File Format: `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html`

**Python**
- CPython source — Include/object.h (PyObject struct): `https://github.com/python/cpython/blob/main/Include/object.h`
- Python docs — sys.getsizeof: `https://docs.python.org/3/library/sys.html#sys.getsizeof`

### Sub-topic 8 — Escape Analysis

**Java**
- Oracle — Escape Analysis in HotSpot: `https://docs.oracle.com/javase/8/docs/technotes/guides/vm/performance-enhancements-7.html#escapeAnalysis`
- Aleksey Shipilev — JVM Anatomy Quark #18: Scalar Replacement: `https://shipilev.net/jvm/anatomy-quarks/18-scalar-replacement/`
- GraalVM docs — Partial Escape Analysis: `https://www.graalvm.org/latest/reference-manual/java/compiler/#partial-escape-analysis`

### Sub-topic 9 — Arena Allocation

**Rust**
- bumpalo crate documentation: `https://docs.rs/bumpalo/latest/bumpalo/`
- typed-arena crate documentation: `https://docs.rs/typed-arena/latest/typed_arena/`
- Rust Allocator API (nightly): `https://doc.rust-lang.org/std/alloc/trait.Allocator.html`

**Java**
- JEP 454 — Foreign Function & Memory API: `https://openjdk.org/jeps/454`
- Java docs — MemorySegment and Arena: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/foreign/Arena.html`

**Python**
- CPython Developer Guide — Memory management: `https://devguide.python.org/internals/memory/`

### Sub-topic 10 — Weak References

**Rust**
- std docs — Weak (Rc): `https://doc.rust-lang.org/std/rc/struct.Weak.html`
- std docs — Weak (Arc): `https://doc.rust-lang.org/std/sync/struct.Weak.html`

**Java**
- Java docs — java.lang.ref package: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/package-summary.html`
- Java docs — WeakReference: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/WeakReference.html`
- Java docs — SoftReference: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/SoftReference.html`
- Java docs — PhantomReference: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/PhantomReference.html`

**Python**
- Python docs — weakref module: `https://docs.python.org/3/library/weakref.html`
- PEP 205 — Weak References: `https://peps.python.org/pep-0205/`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Rust | *The Rustonomicon* (online, continuously updated) | The authoritative guide to unsafe Rust, raw pointers, and memory layout details (`repr` attributes, drop check, variance) that the owned books only touch on; essential for understanding how Rust's safety guarantees are built and where they end |
| Java | Aleksey Shipilev — *JVM Anatomy Quarks* (blog series, 2017–present) | 40+ short deep-dive articles on specific JVM internals (object headers, TLAB allocation, compressed oops, safepoints, card tables, false sharing) that go far deeper than any book; the definitive micro-reference for HotSpot internals |
| Java | Charlie Hunt & Binu John — *Java Performance Companion* (Addison-Wesley, 2016) | Focused specifically on G1 GC internals, JIT compilation details, and HotSpot memory management at a level below what Oaks or Beckwith cover; includes JMC/JFR usage for memory analysis |
| Python | Jake Edge & Neil Schemenauer — *CPython Developer Guide: Garbage Collector Design* (online) | Official documentation of CPython's generational garbage collector internals, the tri-color marking algorithm for cycle detection, and how the collector interacts with reference counting |
| General | Research papers on memory allocators — *Hoard* (Berger et al), *jemalloc* (Evans), *mimalloc* (Leijen et al) | Understanding the allocator landscape that underlies all three runtimes: CPython uses pymalloc on top of the system allocator, the JVM has TLAB/PLAB strategies, and Rust defaults to the system allocator but can switch to jemalloc or mimalloc |

---

## Study Plan — 10 Sessions

Estimated total: **20–25 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from foundational memory concepts through language-specific memory models to advanced optimization patterns.

---

### Session 1 — Stack vs Heap Allocation & Memory Regions

**Goal:** understand the fundamental distinction between stack and heap memory, how each language decides where to allocate data, and the performance implications of each choice.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: stack, heap, and static memory.** Read Klabnik Ch.4 pp. 59–68 (ownership rules, variable scope, the String type, memory and allocation — stack vs heap distinction, how String differs from string literals). Read McNamara Ch.6 pp. 175–195 (pointers, stack and heap, dynamic memory allocation, virtual memory). Read Gjengset Ch.1 pp. 1–5 (memory terminology, memory regions — stack, heap, static). Key insight: Rust makes the stack/heap distinction explicit through types. Stack-allocated data has a known, fixed size at compile time (integers, fixed arrays, structs of known-size fields). Heap allocation happens through types like `String`, `Vec<T>`, and `Box<T>` — you see the allocation in the type. There is no hidden heap allocation by the compiler. Static memory (`'static` lifetime) holds string literals and constants. The programmer always knows where data lives by reading the types. |
| 1.2 | 30 min | **Java: JVM runtime data areas.** Read Evans Ch.7 pp. 207–215 (mark-sweep basics, how the JVM heap is organized). Read Oaks Ch.5 pp. 121–135 (GC overview, generational garbage collectors, heap generations — young/old/metaspace). Read the JVM Specification section 2.5 (Run-Time Data Areas) online. Key insight: the JVM manages memory in regions invisible to the programmer. The heap is divided into young generation (Eden + survivor spaces) and old generation. The stack holds primitive local variables and object references (not the objects themselves). Almost all objects go to the heap — the programmer has no direct control over stack vs heap placement. Metaspace (replacing PermGen since Java 8) holds class metadata. Native memory sits outside the managed heap. The key design tradeoff: the programmer writes simple code, and the JVM + GC handle placement and reclamation. |
| 1.3 | 25 min | **Python: everything on the heap.** Read Shaw Ch.7 pp. 177–190 (C memory allocation, design of CPython's memory management system, the layered allocator). Read Gorelick Ch.1 pp. 1–15 (fundamental computer system — CPU, RAM, cache hierarchy, how Python abstracts over hardware). Key insight: in CPython, virtually everything is a heap-allocated object. Even integers, booleans, and None are objects on the heap with reference counts and type pointers. The C call stack holds frame metadata and local variable pointers (`PyObject*`), but the values themselves are heap objects. CPython's memory allocator is layered: OS malloc at the bottom, then pymalloc (an arena-based allocator optimized for small objects up to 512 bytes), then domain-specific allocators (raw, PyMem, object). This uniformity simplifies the language but means Python has the highest per-value memory overhead of the three languages. |
| 1.4 | 15 min | **Cross-language comparison.** Create a comparison table: rows = {where primitives/scalars live, where composite objects live, where string data lives, programmer control over placement, who decides allocation site, memory overhead per integer, explicit heap types}, columns = {Rust, Java, Python}. Note the spectrum: Rust gives full explicit control (types encode allocation); Java provides limited implicit control (JVM decides, escape analysis may optimize); Python provides no control (everything is a heap object). Read the Rust By Example "Box" page online for a concise summary of explicit heap allocation. |

---

### Session 2 — Ownership, Borrowing & Lifetimes (Rust)

**Goal:** master Rust's unique compile-time memory management system — ownership rules, borrowing, and lifetimes — which replaces both manual memory management and garbage collection.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 35 min | **Ownership fundamentals.** Read Klabnik Ch.4 pp. 59–83 (full chapter: ownership rules, scope, String type, memory and allocation, ownership and functions, return values and scope, references and borrowing, mutable references, dangling references, slices). Read Blandy Ch.4 pp. 71–85 (ownership model, moves, value transfer). Key insight: Rust's ownership system has three rules: (1) each value has exactly one owner, (2) when the owner goes out of scope, the value is dropped, (3) ownership can be transferred (moved). This eliminates the need for GC — the compiler inserts deallocation calls at deterministic points (scope exits). There is no runtime cost for this memory management; it is all resolved at compile time. The `String` type illustrates this perfectly: it owns heap-allocated data, and when it goes out of scope, it frees that data via `drop`. |
| 2.2 | 30 min | **Borrowing and the borrow checker.** Read Blandy Ch.5 pp. 93–121 (references as values, reference safety, borrowing locals, receiving/passing/returning references, structs containing references, sharing versus mutation). Read McNamara Ch.4 pp. 107–125 (lifetimes, ownership, borrowing in practice). Key insight: borrowing lets you use data without taking ownership. Two rules enforce safety: (1) you can have either one mutable reference OR any number of shared references to data, but not both simultaneously; (2) references must not outlive the data they point to. The borrow checker enforces these rules at compile time. This eliminates data races at compile time (shared XOR mutable) and use-after-free (lifetime checking). NLL (non-lexical lifetimes, RFC 2094) made the borrow checker smarter — borrows now end at their last use, not at scope exit. |
| 2.3 | 25 min | **Lifetimes in depth.** Read Klabnik Ch.10 pp. 181–213 (preventing dangling references, the borrow checker, generic lifetime annotations, lifetime elision rules, the `'static` lifetime). Read Gjengset Ch.1 pp. 8–17 (lifetimes, variance, lifetime relationships). Key insight: lifetime annotations (`'a`) do not change how long data lives — they describe relationships between references that the compiler cannot infer. The three elision rules handle most cases automatically. Variance determines how lifetime relationships compose: `&'a T` is covariant in `'a` (a longer lifetime can substitute for a shorter one) and covariant in `T`. Understanding variance is essential for advanced Rust — it explains why `&'a mut T` is invariant in `T` and why `fn(&'a T)` is contravariant in `'a`. |
| 2.4 | 15 min | **Compare with Java and Python.** Neither Java nor Python has ownership or lifetimes. Java's GC roots + reachability analysis serves the same purpose (determining when to free memory) but at runtime with GC pauses. Python's reference counting serves the same purpose but with per-object overhead and a cycle collector for circular references. Write a function that creates, borrows, and returns data in all three languages. Note how Rust's version makes the memory flow explicit in the type signatures, while Java and Python hide it entirely. |

---

### Session 3 — GC Roots & Reachability (Java) vs Reference Counting (Python)

**Goal:** understand the two dominant automatic memory management paradigms — tracing GC (Java) and reference counting (Python) — their core algorithms, trade-offs, and failure modes.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Java: generational hypothesis and GC foundations.** Read Oaks Ch.5 pp. 121–152 (full chapter: GC overview, generational garbage collectors, GC algorithms, choosing a GC algorithm, basic GC tuning — sizing the heap and generations). Read Beckwith Ch.1 pp. 20–42 (generational GC, stop-the-world, concurrent algorithms, young collections, weak generational hypothesis, old-generation collection triggers). Key insight: Java's GC is based on the generational hypothesis — most objects die young. The heap is divided into young generation (frequent, fast collections) and old generation (infrequent, slower collections). GC starts from "roots" (stack variables, static fields, JNI references) and traces all reachable objects; unreachable objects are reclaimed. Young generation collection (minor GC) uses copying collectors and is fast because most objects are already dead. Objects that survive multiple minor GCs are promoted ("tenured") to the old generation. This design means the common case (short-lived objects) is very efficient. |
| 3.2 | 30 min | **Python: reference counting + cycle collector.** Read Shaw Ch.7 pp. 200–219 (reference counting internals, garbage collection cycle collector). Read Martelli Ch.14 pp. 429–441 (reference counting, cycle detector, gc module). Read Ramalho Ch.6 pp. 220–228 (del and garbage collection, weak references). Key insight: CPython uses reference counting as its primary memory management strategy. Every object has an `ob_refcnt` field; when it reaches zero, the object is immediately freed — no GC pause required. This gives deterministic destruction for non-cyclic data, which is why `file.close()` often "works" even without `with` statements. However, reference counting alone cannot handle cycles (A references B, B references A, both have refcount > 0 but are unreachable). CPython's cycle collector (a generational mark-and-sweep running on generations 0, 1, 2) detects and breaks these cycles. The cycle collector only examines container objects (lists, dicts, classes) — immutable non-containers (int, str) cannot form cycles. |
| 3.3 | 20 min | **Evans on Java Memory Model foundations.** Read Evans Ch.5 pp. 119–140 (Java Memory Model, happens-before, concurrency through bytecode). Key insight: the Java Memory Model (JMM) defines visibility rules for shared memory across threads — when one thread's write to a field becomes visible to another thread. This is not directly about GC but is fundamental to understanding how GC interacts with concurrent programs: the JMM's happens-before edges determine when GC can safely reclaim objects that other threads might be using. Safepoints — special points where all application threads are stopped — are how the JVM ensures a consistent heap snapshot for GC. |
| 3.4 | 15 min | **Comparative analysis: tracing vs reference counting.** Compare: (1) latency profile (Rust — zero GC latency; Java — periodic GC pauses measured in microseconds to milliseconds; Python — no tracing GC pauses for non-cyclic data, occasional cycle collection pauses). (2) Throughput overhead (Rust — zero; Java — ~5–10% for modern collectors; Python — refcount increment/decrement on every assignment). (3) Determinism (Rust — fully deterministic via Drop; Python — mostly deterministic via refcounting, non-deterministic for cycles; Java — non-deterministic, GC timing is not guaranteed). (4) Cycle handling (Rust — prevented by the borrow checker, `Weak<T>` for intentional back-references; Java — handled by tracing GC; Python — requires cycle collector). |

---

### Session 4 — Move Semantics vs Copy Semantics vs Reference Semantics

**Goal:** understand the fundamentally different ways data is transferred between variables in Rust (move/copy), Java (reference copy for objects, value copy for primitives), and Python (reference copy for everything).

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 30 min | **Rust: moves and Copy types.** Read Blandy Ch.4 pp. 71–90 (full chapter: ownership model, moves, Copy types, Rc and Arc for shared ownership). Read Matthews Ch.5 pp. 93–105 (heap and stack, ownership, copies, borrowing, references, moves). Key insight: in Rust, assignment is a move by default — `let b = a;` transfers ownership of a's value to b, and a becomes invalid. This is not a deep copy; it is a bitwise copy of the stack representation followed by invalidating the source. Types that implement the `Copy` trait (integers, floats, bools, tuples of Copy types) are an exception — they are bitwise-copied and the source remains valid. The distinction is semantic: `Copy` types have no owned resources (no heap data to manage), so a bitwise copy is always safe. Move semantics eliminate double-free bugs and enable Rust's single-owner model. |
| 4.2 | 25 min | **Java: reference semantics with value-copy primitives.** Read Bloch Ch.2 pp. 22–28 (Item 6: avoid creating unnecessary objects, Item 7: eliminate obsolete references). Read Valeev Ch.5 pp. 124–140 (NullPointerException patterns, when references go stale). Key insight: Java has two categories of types with different assignment semantics. Primitives (int, double, boolean, etc.) are copied by value — `int b = a;` creates an independent copy. Reference types (all objects) are copied by reference — `String b = a;` copies the reference (pointer), not the object; both a and b point to the same heap object. There are no moves. Copying a reference is always cheap (one pointer copy), but it means multiple variables can alias the same object. This is the root cause of many Java bugs: holding a reference to an object prevents it from being GC'd (memory leak via obsolete references, Item 7), and mutating shared mutable objects causes unintended side effects. Java has no equivalent of Rust's move semantics — the GC handles cleanup. |
| 4.3 | 25 min | **Python: everything is reference semantics.** Read Ramalho Ch.6 pp. 201–220 (variables as labels, identity vs equality, aliasing, copies of objects, shallow and deep copies). Key insight: Python has only reference semantics — every assignment copies a reference, never a value. `b = a` makes b an alias for the same object; `b is a` returns True. There is no distinction like Java's primitive/reference duality — even `int` and `float` are heap-allocated objects, and assignment copies the reference. Immutability provides a practical substitute for copy semantics: since `int`, `str`, `tuple`, and `frozenset` are immutable, aliasing them is safe because no one can mutate through the alias. For mutable objects (lists, dicts), aliasing creates a shared-mutable-state problem. `copy.copy()` creates a shallow copy (new container, same elements); `copy.deepcopy()` creates a full recursive copy. Python's model is simpler than Java's (no primitive/reference split) but requires understanding aliasing to avoid bugs. |
| 4.4 | 20 min | **Three-way comparison.** Write the same scenario in all three languages: create a list/vector, assign it to another variable, modify the original, and observe the effect on the copy. In Rust, the assignment moves, so the original is invalid. In Java, both variables alias the same ArrayList, so mutations are visible through both. In Python, both variables alias the same list, same as Java. Then show how to achieve a true independent copy in each language: Rust `.clone()`, Java `new ArrayList<>(original)` or `.clone()`, Python `copy.deepcopy()`. Note the performance spectrum: Rust's move is O(1) and statically safe; Java's reference copy is O(1) but requires GC; Python's reference copy is O(1) but requires reference counting. Deep copies are O(n) in all three. |

---

### Session 5 — Interior Mutability & Smart Pointers (Rust)

**Goal:** understand Rust's interior mutability pattern — how `Cell`, `RefCell`, and `UnsafeCell` allow mutation through shared references, why this is necessary, and how Java and Python handle the same problem differently.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 35 min | **Cell and RefCell.** Read Blandy Ch.9 pp. 200–209 (interior mutability: Cell\<T\> for Copy types, RefCell\<T\> for runtime borrow checking). Read Klabnik Ch.15 pp. 335–345 (RefCell\<T\> and the interior mutability pattern, enforcing borrowing rules at runtime, combining Rc\<T\> and RefCell\<T\>). Read Gjengset Ch.1 pp. 6–8 (interior mutability overview). Key insight: Rust's default rule — shared references (`&T`) cannot mutate — is sometimes too restrictive. Interior mutability types relax this rule in controlled ways. `Cell<T>` allows get/set on Copy types through `&Cell<T>`, with zero runtime overhead (no dynamic borrow checking). `RefCell<T>` allows borrow/borrow\_mut through `&RefCell<T>`, with runtime borrow checking that panics on violations. The critical distinction: both maintain Rust's safety guarantees (no data races, no UB), but shift the borrow checking from compile time to runtime. `UnsafeCell<T>` is the primitive that underlies both — it is the only type in Rust that allows mutation through a shared reference, and it is always unsafe. All safe interior mutability is built on top of `UnsafeCell`. |
| 5.2 | 25 min | **Smart pointers and combined patterns.** Read Klabnik Ch.15 pp. 315–335 (Box\<T\> for heap allocation, Deref trait, Drop trait, Rc\<T\> for shared ownership). Read Klabnik Ch.15 pp. 345–351 (reference cycles, Weak\<T\> for breaking cycles). Read Matthews Ch.5 pp. 105–118 (smart pointers Box/Rc/Arc, Cow, custom allocators). Key insight: Rust's smart pointer ecosystem builds on ownership and interior mutability. `Box<T>` provides heap allocation with single ownership. `Rc<T>` provides shared ownership via reference counting (single-threaded). `Arc<T>` provides shared ownership via atomic reference counting (thread-safe). The common pattern `Rc<RefCell<T>>` gives shared ownership with interior mutability — multiple owners can each mutate the inner value through runtime borrow checking. `Weak<T>` breaks reference cycles by not contributing to the strong reference count, preventing memory leaks in tree/graph structures. |
| 5.3 | 20 min | **Java and Python: no interior mutability concept needed.** In Java, all non-final fields are mutable through any reference — there is no compile-time aliasing restriction to relax. Java's `volatile` and `synchronized` serve a different purpose (visibility and atomicity across threads, not single-threaded mutation control). In Python, everything is mutable by default (except tuples, frozensets, and strings). Python has no concept analogous to interior mutability because it has no concept of shared-vs-exclusive references. Create a comparison: the same tree-with-parent-pointers problem in all three languages. Rust needs `Rc<RefCell<Node>>` + `Weak<RefCell<Node>>` for parent back-references. Java uses plain object references (GC handles cycles). Python uses plain object references (cycle collector handles cycles). |
| 5.4 | 15 min | **Synthesis: the trade-off spectrum.** Rust's interior mutability exists because its compile-time borrow checker is intentionally conservative — it rejects some safe programs. Cell/RefCell are the controlled escape hatch. Java and Python do not need this concept because they never restrict aliased mutation at compile time — they pay the cost at runtime (GC, race conditions) instead. Note that `UnsafeCell` is also the building block for `Mutex<T>` and `RwLock<T>` in concurrent Rust — the same interior mutability principle extends to multi-threaded contexts with appropriate synchronization. Read the Rust Reference "Interior Mutability" section and std docs for `std::cell` online. |

---

### Session 6 — RAII, Deterministic Destruction, Finalizers & Context Managers

**Goal:** compare how each language manages resource lifetimes (files, locks, network connections) — Rust's RAII/Drop, Java's try-with-resources/finalizers/Cleaner, and Python's context managers/`__del__`.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **Rust: RAII and the Drop trait.** Read Blandy Ch.13 pp. 281–289 (Drop trait, when drop runs, drop order). Read Klabnik Ch.15 pp. 325–330 (running code on cleanup with the Drop trait). Read Gjengset Ch.1 pp. 3–5 (ownership and drop semantics). Key insight: RAII (Resource Acquisition Is Initialization) means that owning a value means owning its resources. When a value goes out of scope, its `Drop::drop` method is called automatically — this is deterministic (happens at a predictable, known point) and guaranteed (no GC timing uncertainty). Files are closed, locks are released, memory is freed, all at scope exit. Drop order is defined: struct fields are dropped in declaration order, local variables in reverse declaration order. You can call `std::mem::drop(value)` to drop early. RAII is Rust's answer to try-with-resources and context managers — but it requires no special syntax and works for every value, not just resources. |
| 6.2 | 30 min | **Java: finalizers, Cleaner, and try-with-resources.** Read Bloch Ch.2 pp. 29–35 (Item 8: avoid finalizers and cleaners — they are unpredictable, slow, and dangerous; Item 9: prefer try-with-resources to try-finally). Read Valeev Ch.5 pp. 140–154 (OOM, resource management pitfalls). Read JEP 421 (Deprecate Finalization for Removal) online. Key insight: Java has three resource-management mechanisms, two of which are deeply flawed. (1) `finalize()` (deprecated for removal via JEP 421) — called by the GC at an unpredictable time (or never), runs on a special thread, can resurrect objects, causes severe performance problems. Never use it. (2) `Cleaner` (Java 9+) — a safer replacement that registers cleanup actions on phantom references, but still non-deterministic. (3) `try-with-resources` (Java 7+) — the correct approach for deterministic resource cleanup: `try (var f = new FileReader("x")) { ... }` guarantees `f.close()` is called at block exit. The resource must implement `AutoCloseable`. This is Java's closest equivalent to RAII, but it requires explicit syntax at every use site. |
| 6.3 | 25 min | **Python: context managers, `__del__`, and weakref finalizers.** Read Ramalho Ch.6 pp. 220–228 (del statement, `__del__` finalizer, garbage collection interaction). Read Martelli Ch.14 pp. 429–441 (garbage collection, reference counting, `__del__`). Read PEP 343 (The "with" Statement) and PEP 442 (Safe object finalization) online. Key insight: Python's `__del__` method is called when an object's reference count drops to zero — this is usually deterministic in CPython (immediate cleanup for non-cyclic data) but not guaranteed (cycles delay it, other Python implementations like PyPy do not use refcounting). The `with` statement and context managers (`__enter__`/`__exit__`) are the recommended pattern for resource cleanup, analogous to Java's try-with-resources: `with open('file') as f: ...`. PEP 442 (Python 3.4) improved `__del__` reliability for objects in reference cycles. `weakref.finalize()` (Python 3.4+) provides a more reliable cleanup mechanism than `__del__`. The practical advice is the same across Java and Python: use structured cleanup (try-with-resources / with statement), not finalizers. |
| 6.4 | 15 min | **Three-way comparison.** Compare the three approaches by implementing a database connection wrapper that must release the connection on cleanup. Rust: struct with `Drop` — always works, always deterministic, no special call-site syntax. Java: class implementing `AutoCloseable` — works deterministically only if caller uses try-with-resources; finalizer/Cleaner as a safety net. Python: class implementing `__enter__`/`__exit__` — works deterministically only if caller uses `with`; `__del__` as unreliable safety net. Key takeaway: Rust's RAII is the only approach that is both deterministic and automatic (no caller cooperation needed). Java and Python require the caller to opt in to deterministic cleanup. |

---

### Session 7 — Memory Layout: Struct Padding, Object Headers & PyObject Internals

**Goal:** understand the physical layout of data in memory — how structs are padded and aligned in Rust, what overhead JVM object headers add in Java, and how CPython's PyObject struct is organized.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 35 min | **Rust: struct layout, padding, alignment, repr.** Read Gjengset Ch.2 pp. 19–30 (alignment, layout, complex types, dynamically sized types, wide pointers). Read Blandy Ch.9 pp. 193–200 (struct layout). Read the Rustonomicon "Data Representation" and "Alternative Representations" sections online. Key insight: Rust's default layout (`repr(Rust)`) allows the compiler to reorder fields to minimize padding — there is no guaranteed field order. `repr(C)` matches C struct layout (fields in declaration order, C padding rules) and is required for FFI. `repr(transparent)` guarantees a single-field struct has the same layout as its field. `repr(packed)` removes all padding (may cause unaligned access). `repr(align(N))` sets minimum alignment. Alignment rules: a type with alignment N must be placed at an address divisible by N; the compiler inserts padding bytes to satisfy this. Understanding layout is essential for FFI, cache performance, and minimizing memory usage. Use `std::mem::size_of::<T>()` and `std::mem::align_of::<T>()` to inspect layout. |
| 7.2 | 30 min | **Java: JVM object headers and compressed oops.** Read Oaks Ch.7 pp. 203–225 (heap analysis, reducing object size, object headers). Read Beckwith Ch.6 pp. 177–185 (TLABs/PLABs overview). Read Aleksey Shipilev's "Java Objects Inside Out" blog post online. Key insight: every Java object on the heap has a header of 12–16 bytes (64-bit JVM with compressed oops). The header contains: (1) mark word (8 bytes) — hash code, GC age, lock state, GC forwarding pointer; (2) klass pointer (4 bytes compressed, 8 uncompressed) — pointer to the class metadata. Arrays add an additional 4-byte length field. Compressed oops (`-XX:+UseCompressedOops`, default for heaps < 32 GB) reduce object pointers from 8 to 4 bytes by using base + offset × 8 encoding. This means the minimum Java object size is 16 bytes (header + padding to 8-byte alignment). Boolean fields take 1 byte in a field but the object may need 15 bytes of padding. Use JOL (Java Object Layout) tool to inspect actual object sizes and layouts. |
| 7.3 | 25 min | **Python: PyObject struct and object internals.** Read Shaw Ch.9 pp. 285–315 (PyObject, variable-size objects, the type type, built-in type internals). Read Gorelick Ch.11 pp. 341–360 (Python object memory overhead, array module for compact storage). Read Ramalho Ch.11 pp. 363–380 (`__slots__` for memory optimization). Key insight: every CPython object starts with a `PyObject` header: `ob_refcnt` (Py\_ssize\_t, 8 bytes on 64-bit) for reference counting and `ob_type` (PyObject\*, 8 bytes) pointing to the type object. Variable-size objects (PyVarObject) add `ob_size` (Py\_ssize\_t, 8 bytes). So the minimum overhead per object is 16 bytes, before any actual data. A Python `int` with value 42 takes 28 bytes. A Python `float` takes 24 bytes. A Python `list` with no elements takes 56 bytes. `__slots__` eliminates the per-instance `__dict__` (which adds another 48–112 bytes), reducing memory by 40–60% for data-heavy objects with many instances. `sys.getsizeof()` reports the direct size; `tracemalloc` tracks allocations. |
| 7.4 | 15 min | **Layout comparison.** Compare the memory cost of storing 1 million points (x, y as 64-bit floats) in each language. Rust `struct Point { x: f64, y: f64 }`: 16 bytes each, 16 MB total in a Vec (contiguous, cache-friendly). Java `class Point { double x; double y; }`: 32 bytes each (16 header + 16 data), 32 MB total, non-contiguous (pointers from array to objects). Python `class Point: def __init__(self, x, y): self.x = x; self.y = y`: ~170 bytes each (Point object + dict + two float objects), ~170 MB total. With `__slots__`: ~64 bytes each (Point object + two float objects). With NumPy `np.array(shape=(1_000_000, 2), dtype=np.float64)`: 16 MB total (C-contiguous). This 10× memory difference between Python objects and Rust structs is fundamental to understanding why Rust and Java are preferred for memory-intensive workloads. |

---

### Session 8 — Java GC Deep Dive: G1, ZGC, Shenandoah

**Goal:** understand the three modern Java GC algorithms in detail — how they work, their latency/throughput trade-offs, and the internal mechanisms (safepoints, card tables, remembered sets) that make them possible.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 35 min | **G1 Garbage Collector.** Read Oaks Ch.6 pp. 160–180 (understanding the G1 GC, tuning G1 GC). Read Beckwith Ch.6 pp. 185–205 (G1 deep dive, regionalized heap, optimizing G1 parameters). Read Evans Ch.7 pp. 225–240 (G1 overview in context). Key insight: G1 (Garbage First) is the default collector since Java 9. It divides the heap into equal-sized regions (~2000 regions) instead of contiguous generations. Each region can be Eden, Survivor, Old, or Humongous (for objects spanning multiple regions). G1 uses concurrent marking to identify garbage, then selects regions with the most garbage first (hence the name) for collection, copying live objects to new regions. This allows G1 to meet pause-time targets (`-XX:MaxGCPauseMillis=200` default). Key mechanisms: remembered sets track cross-region references (which regions point to which), card tables mark dirty cards when references are updated, and write barriers maintain these data structures. Mixed collections reclaim both young and old regions together. |
| 8.2 | 30 min | **ZGC and Shenandoah.** Read Oaks Ch.6 pp. 191–201 (ZGC, Shenandoah, Epsilon GC). Read Beckwith Ch.6 pp. 205–217 (ZGC deep dive, future trends). Read JEP 333 (ZGC) and JEP 189 (Shenandoah) online. Key insight: both ZGC and Shenandoah aim for sub-millisecond GC pauses regardless of heap size. ZGC uses colored pointers (metadata stored in unused bits of 64-bit pointers) and load barriers — every time a reference is loaded, the barrier checks the pointer color and potentially remaps it. This allows ZGC to compact the heap concurrently with application threads. Shenandoah uses Brooks forwarding pointers (an extra word per object) and similar concurrent compaction. Both collectors trade throughput (~5–15% overhead from barriers) for latency (pauses typically under 1ms). ZGC became production-ready in Java 15 and generational in Java 21. Shenandoah is available in OpenJDK but not Oracle JDK. The choice between G1/ZGC/Shenandoah depends on the application's latency requirements. |
| 8.3 | 25 min | **Safepoints and internal mechanisms.** Read Beckwith Ch.1 pp. 30–42 (stop-the-world, concurrent algorithms, parallel and concurrent GC threads). Read Aleksey Shipilev's JVM Anatomy Quarks online (entries on safepoints and card tables). Key insight: safepoints are positions in the code where a thread can be safely paused for GC. HotSpot injects safepoint polls at method returns and loop back-edges (but not in counted loops, which can cause long time-to-safepoint). When GC needs to run, it sets a flag; each thread checks this flag at its next safepoint and suspends. Card tables (one byte per 512-byte heap region) track which old-generation regions contain pointers to young-generation objects, avoiding scanning the entire old generation during minor GC. Write barriers (software, not hardware) update the card table on every reference store. These mechanisms are invisible to the programmer but have significant performance implications — understanding them is key to interpreting GC logs and tuning GC behavior. |
| 8.4 | 15 min | **Comparison with Rust and Python.** Rust has no GC and no safepoints. The "cost" of Rust's memory management is paid at compile time (borrow checker complexity) and in design constraints (ownership model). Python's cycle collector is much simpler than Java's GC — it only handles cycles, runs infrequently, and does not compact the heap. Python has no card tables, no remembered sets, no concurrent collection. The trade-off: Java's GC algorithms are sophisticated because Java creates far more short-lived heap objects than Rust (which uses the stack extensively) and requires higher throughput than Python's cycle collector (which handles fewer objects due to refcounting). |

---

### Session 9 — Python Memory Internals: gc Module, `__del__`, Weak References

**Goal:** understand CPython's complete memory management picture — the gc module API, interaction between reference counting and the cycle collector, `__del__` finalizer semantics, weak references, and `sys.getrefcount`.

| Step | Time | Activity |
|------|------|----------|
| 9.1 | 30 min | **The gc module and cycle collector internals.** Read Shaw Ch.7 pp. 200–219 (reference counting mechanics, garbage collection — the cycle collector algorithm, generations, thresholds). Read Martelli Ch.14 pp. 429–441 (gc module in detail). Read the CPython Developer Guide "Garbage collector design" document online. Key insight: CPython's cycle collector uses a generational tri-color marking algorithm. Generation 0 collects most frequently (threshold ~700 allocations minus deallocations). Objects surviving a gen-0 collection move to gen-1, then to gen-2. The collector only examines container objects (those that can hold references: list, dict, set, class instances with `__dict__`, tuples). For each generation: (1) merge with younger generations, (2) track gc\_refs (a copy of refcount), (3) for each container, decrement gc\_refs of objects it references, (4) objects with gc\_refs > 0 are reachable from outside the collector's set — these are "roots," (5) trace from roots and mark all reachable objects, (6) unreachable objects are finalized and freed. `gc.get_threshold()` returns the three generation thresholds. `gc.collect()` forces a full collection. `gc.disable()` disables the cycle collector (reference counting still works). |
| 9.2 | 25 min | **`__del__`, weak references, `sys.getrefcount`.** Read Ramalho Ch.6 pp. 220–228 (del statement vs `__del__`, garbage collection, weak references). Read Valeev Ch.9 pp. 267–272 (weak/soft references invalidation — for Java context comparison). Read PEP 205 (Weak References) and PEP 442 (Safe object finalization) online. Key insight: `__del__` is called when an object is being destroyed, but there are many caveats: (1) it is not called if the object is part of a reference cycle (before PEP 442/Python 3.4), (2) exceptions in `__del__` are ignored (printed to stderr), (3) the order of `__del__` calls is not guaranteed for objects in cycles, (4) `__del__` can resurrect the object by creating new references to it. `sys.getrefcount(obj)` returns the reference count (always at least 2 because the function argument itself is a reference). `weakref.ref(obj)` creates a weak reference that does not prevent garbage collection — essential for caches, observer patterns, and parent back-references. `weakref.finalize()` (Python 3.4+) is the recommended alternative to `__del__` for cleanup actions. |
| 9.3 | 25 min | **CPython allocator layers and performance implications.** Read Shaw Ch.7 pp. 177–200 (C memory allocation, CPython allocator design, object/PyMem domains, raw domain, custom allocators, PyArena). Read Gorelick Ch.6 pp. 109–140 (memory fragmentation, NumPy contiguous memory). Read Gorelick Ch.11 pp. 360–390 (NumPy memory, probabilistic data structures for RAM savings). Key insight: CPython has three allocation domains: (1) raw domain — wraps OS malloc/free for non-Python buffers, (2) PyMem domain — for generic Python memory (uses pymalloc for ≤ 512 bytes, falls through to raw for larger), (3) object domain — for Python objects (also uses pymalloc). pymalloc is an arena-based allocator: it allocates 256 KB arenas from the OS, divides them into 4 KB pools, and pools into fixed-size blocks (8 to 512 bytes in 8-byte increments). This avoids the overhead of calling OS malloc for every small object. For numeric-heavy workloads, NumPy provides C-contiguous arrays with minimal per-element overhead, bypassing Python's object overhead entirely. |
| 9.4 | 15 min | **Comparison with Rust and Java.** CPython's layered allocator (pymalloc) is conceptually similar to the JVM's TLAB (Thread-Local Allocation Buffer) — both provide fast, bump-pointer allocation for common cases. But CPython's allocator is single-threaded (protected by the GIL), while JVM's TLABs are per-thread. Rust uses the system allocator by default (malloc/free) but can be switched to jemalloc or mimalloc via the `#[global_allocator]` attribute. Rust's allocator choice is simpler because the allocator does not need to support GC (no object headers, no forwarding pointers, no color bits). Write a summary comparing: allocator strategies, per-object overhead, allocation speed, and fragmentation handling across all three runtimes. |

---

### Session 10 — Escape Analysis (JVM) & Arena Allocation Patterns

**Goal:** understand the JVM's escape analysis optimization (which can eliminate heap allocations entirely) and arena allocation patterns used across all three languages for performance-critical scenarios.

| Step | Time | Activity |
|------|------|----------|
| 10.1 | 35 min | **JVM Escape Analysis.** Read Oaks Ch.4 pp. 100–120 (escape analysis, inlining, advanced compiler flags). Read Beckwith Ch.1 pp. 25–30 (HotSpot compilation strategies). Read Aleksey Shipilev's "JVM Anatomy Quark #18: Scalar Replacement" online. Read the GraalVM documentation on Partial Escape Analysis online. Key insight: escape analysis determines whether a newly created object "escapes" the method that created it. Three states: (1) NoEscape — the object is only used within the method and can be scalar-replaced (its fields become local variables on the stack, eliminating the heap allocation entirely); (2) ArgEscape — the object is passed to a called method but does not escape the thread; (3) GlobalEscape — the object escapes to the heap (stored in a field, returned, etc.). C2 (HotSpot's optimizing compiler) performs escape analysis and can eliminate allocations, eliminate synchronization on non-escaping objects, and replace heap allocation with stack allocation. GraalVM's Partial Escape Analysis is even more powerful — it only materializes an object on code paths where it actually escapes, keeping it virtualized elsewhere. This is why micro-benchmarks must use JMH's Blackhole to prevent escape analysis from eliminating the measured work. |
| 10.2 | 25 min | **Rust: no escape analysis needed, plus arena allocation.** Read Matthews Ch.5 pp. 110–118 (custom allocators, protected memory). Read Gjengset Ch.12 pp. 211–222 (dynamic memory allocation, OOM handler, low-level memory accesses). Read the bumpalo and typed-arena crate documentation online. Key insight: Rust does not need escape analysis because the programmer explicitly chooses stack vs heap allocation through types — values are on the stack by default, and only `Box::new()`, `Vec::new()`, etc. move data to the heap. Arena allocation in Rust is a pattern where a bulk allocator (arena) allocates from a contiguous memory region and frees everything at once when the arena is dropped. The `bumpalo` crate provides a bump allocator: extremely fast allocation (just increment a pointer), no individual deallocation, all memory freed when the arena is dropped. `typed-arena` provides type-safe arena allocation. Arenas are ideal for parser ASTs, graph structures, and request-scoped allocations where all data has the same lifetime. The nightly Allocator API (`std::alloc::Allocator`) allows collections like `Vec` and `Box` to use custom allocators. |
| 10.3 | 25 min | **Java and Python arena patterns.** Read Horstmann Vol. II Ch.13 pp. 160–174 (Foreign Function & Memory API — MemorySegment, Arena). Read Horstmann Vol. II Ch.2 pp. 42–52 (memory-mapped files). Read Shaw Ch.7 pp. 195–200 (PyArena memory arena in CPython). Read JEP 454 (Foreign Function & Memory API) online. Key insight: Java 21's Foreign Memory API (`java.lang.foreign`) provides explicit arena-like allocation via `Arena.ofConfined()` and `Arena.ofShared()`. Memory segments allocated from an Arena are freed when the Arena is closed — deterministic, scope-based deallocation, similar to Rust's arena crates. This is primarily used for off-heap memory (FFI, memory-mapped I/O, large buffers), not for general object allocation. For general Java objects, arena-like patterns are approximated by object pooling (reusing objects to reduce GC pressure). In CPython, `PyArena` is used internally by the compiler for AST nodes — all nodes are allocated from the arena and freed together after compilation. Python application code does not have direct access to arena allocation; the closest approximation is `numpy` arrays (single allocation for contiguous data) or `mmap` for memory-mapped regions. |
| 10.4 | 15 min | **Synthesis: when to use arena allocation.** Arena allocation makes sense when: (1) many objects share a common lifetime (e.g., all AST nodes from parsing one file), (2) individual deallocation is not needed, (3) allocation speed is critical (bump allocation is faster than malloc), (4) memory fragmentation must be minimized. In Rust, arenas are a library pattern (bumpalo, typed-arena). In Java, arenas exist for off-heap memory (Foreign Memory API) and general heap objects benefit from TLAB allocation (which is arena-like within the young generation). In Python, arenas are an internal implementation detail of pymalloc and the compiler. The converging trend: all three languages are moving toward explicit, scoped memory management for performance-critical scenarios — even Java, which traditionally hid memory management entirely. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Stack vs heap allocation | Klabnik 59–68, McNamara 175–195, Gjengset 1–5, Oaks 121–135, Evans 207–215, Shaw 177–190, Gorelick 1–15 | JVM Spec 2.5, Python C-API memory docs, Rust By Example Box |
| 2 | Ownership, borrowing & lifetimes | Klabnik 59–83 + 181–213, Blandy 71–85 + 93–121, McNamara 107–125, Gjengset 8–17 | Rustonomicon ownership/lifetimes, RFC 2094 (NLL) |
| 3 | GC roots & reference counting | Oaks 121–152, Beckwith 20–42, Evans 119–140 + 207–215, Shaw 200–219, Martelli 429–441, Ramalho 220–228 | Oracle GC Tuning Guide, JEP 248/333/189, CPython GC design docs, PEP 442 |
| 4 | Move vs copy vs reference semantics | Blandy 71–90, Matthews 93–105, Bloch 22–28, Valeev 124–140, Ramalho 201–220 | Rust Reference Copy trait, JLS 15.26, Python copy module docs |
| 5 | Interior mutability & smart pointers | Blandy 200–209, Klabnik 315–351, Gjengset 6–8, Matthews 105–118 | Rust Reference interior mutability, std::cell docs, UnsafeCell docs |
| 6 | RAII, destruction, finalizers, context managers | Blandy 281–289, Klabnik 325–330, Gjengset 3–5, Bloch 29–35, Valeev 140–154, Ramalho 220–228, Martelli 429–441 | JEP 421, PEP 343, PEP 442, Rust Reference destructors, Java Cleaner/AutoCloseable docs |
| 7 | Memory layout & object headers | Gjengset 19–30, Blandy 193–200, Oaks 203–225, Beckwith 177–185, Shaw 285–315, Gorelick 341–360, Ramalho 363–380 | Rustonomicon data repr, Shipilev "Objects Inside Out", JOL tool, Python sys.getsizeof docs |
| 8 | Java GC deep dive: G1, ZGC, Shenandoah | Oaks 153–201, Beckwith 1–42 + 177–217, Evans 207–246 | JEP 248/333/189, Shipilev JVM Anatomy Quarks, Oracle GC Tuning Guide |
| 9 | Python memory internals: gc, `__del__`, weakref | Shaw 177–219, Martelli 429–441, Ramalho 220–228 + 363–396, Gorelick 109–160 + 341–390 | gc module docs, PEP 205/442, CPython Developer Guide GC design, tracemalloc docs |
| 10 | Escape analysis & arena allocation | Oaks 89–120, Beckwith 25–30, Matthews 110–118, Gjengset 211–222, Horstmann II 42–52 + 160–174, Shaw 195–200 | Shipilev Anatomy Quark #18, GraalVM Partial EA docs, JEP 454, bumpalo/typed-arena docs |

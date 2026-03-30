# Layer 1 · Topic 3 — Compilation & Execution

> Comparative study of Rust, Java, and Python: how source code becomes a running program — compilation pipelines, intermediate representations, runtimes, JIT compilation, and linking models.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.1 pp. 1–11 | Getting Started — compilation with `rustc`, Cargo building and running |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.10 (Generics section) | Monomorphization — compile-time generic specialization into concrete types |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.13 pp. 273–294 | Comparing Performance: Loops vs. Iterators — zero-cost abstractions, compiles to identical machine code |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.1 pp. 1–5 | Why Rust? — zero-overhead abstractions, compile-time safety guarantees |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.8 pp. 161–191 | Crates and Modules — build profiles (debug vs release), optimization levels |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.11 pp. 235–263 | Traits and Generics — static dispatch via monomorphization vs dynamic dispatch via vtables |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.21 pp. 525–583 | Unsafe Code — FFI, raw pointers, linking to C libraries |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.2 pp. 11–42 | Cargo project management — cross-compilation, static linking, binary distribution, linking to C libraries |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.3 pp. 43–62 | Rust Tooling — sccache for compilation caching, cargo-expand for macro expansion |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.5 pp. 93–118 | Working with Memory — stack/heap allocation, ownership model, smart pointers |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.11 pp. 219–231 | Optimizations — zero-cost abstractions, SIMD intrinsics, Rayon parallelization |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.1 | Introduction to Java — "interpreted," "architecture-neutral" design, bytecode on JVM |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.2 pp. 33–40 | Java Programming Environment — compiling with javac, bytecode, running on JVM |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.8 pp. 114–118 | Compiling and Scripting — javax.tools.JavaCompiler API, programmatic compilation |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.9 pp. 120–126 | Security — class loaders and their hierarchy |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.11 pp. 140–148 | Annotations — bytecode engineering, source-level annotation processing |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.13 pp. 160–174 | Native Methods — JNI (Java Native Interface) |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.4 pp. 81–117 | Class Files and Bytecode — class loading/linking, examining class files with javap, bytecode opcodes, reflection |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.7 pp. 207–246 | Understanding Java Performance — GC (mark-sweep, generations, G1), JIT compilation with HotSpot (inlining, monomorphic calls, deoptimization), JDK Flight Recorder |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.17 pp. 571–607 | Modern Internals — method invocation (virtual, interface, special, final), reflection internals, MethodHandles, invokedynamic, string optimization, Unsafe API, VarHandles |
| Java | Bloch (2018) — *Effective Java* | Generics chapters | Type erasure — compile-time generic checking, runtime type erasure |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.1 pp. 1–18 | Managing Code Quality — static analysis tools and their role in the compilation pipeline |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.1 pp. 1–19 | Introduction to Python — implementations (CPython, PyPy, Jython, IronPython) |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.2 pp. 21–31 | The Python Interpreter — running Python programs, command-line options |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.14 pp. 429–441 | Customizing Execution — eval, compile, exec, code/frame/traceback objects, GC (reference counting + cycle detector) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.2 (dis examples) | Bytecode analysis with the `dis` module |
| Python | Ramalho (2022) — *Fluent Python* | Ch.19 pp. 695–742 | Concurrency Models — the GIL and its implications for execution |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.1 pp. 1–20 | Understanding Performant Python — idealized computing vs Python virtual machine overhead |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.2 pp. 21–64 | Profiling — bytecode analysis with `dis`, cProfile, understanding the evaluation loop |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.7 pp. 161–211 | Compiling to C — JIT vs AOT, Cython, Numba, PyPy, ctypes, cffi, CPython extension modules |

### Coverage Gaps

The owned books **do not** cover:

- **LLVM architecture and Rust's compilation pipeline** — no book explains how `rustc` compiles through HIR → MIR → LLVM IR → machine code, or the role of LLVM optimization passes
- **CPython internals in depth** — how the CPython interpreter works internally (tokenizer → parser → AST → bytecode compiler → evaluation loop); Martelli covers the user-facing side but not the implementation
- **JVM specification details** — class file format binary layout, JVM instruction set specification, verification algorithm; Evans gives an overview but not the spec-level detail
- **GraalVM and Truffle framework** — polyglot runtime, Graal JIT compiler architecture, AOT compilation via Native Image for Java
- **Compilation pipeline stages** — lexing, parsing, AST construction, IR generation, optimization passes, and code generation as a general framework across all three languages
- **Linking models in depth** — static vs dynamic linking mechanics, symbol resolution, shared libraries (.so/.dll/.dylib), Rust's approach to static linking with musl
- **Ahead-of-time compilation alternatives** — GraalVM native-image for Java, Cython/mypyc/Nuitka for Python, cranelift as an alternative Rust backend
- **WebAssembly as a compilation target** — Rust → WASM (wasm-pack, wasm-bindgen), JVM → WASM, Pyodide (Python in WASM)
- **Startup time and cold-start optimization** — JVM warmup characteristics, CDS/AppCDS archives, Python import overhead, Rust instant-start behavior
- **Debug vs release compilation** — what each optimization level does (`-O0` through `-O3`), debug symbols, the performance gap between debug and release builds
- **Profile-guided optimization (PGO)** — how PGO works in rustc and the JVM (C2 compiler uses profiling data from C1)

---

## External Resources

### Sub-topic 1 — Compilation Models Overview

**Rust**
- The Rustc Dev Guide — Overview of the compiler: `https://rustc-dev-guide.rust-lang.org/overview.html`
- The Rust Reference — Crates and source files: `https://doc.rust-lang.org/reference/crates-and-source-files.html`
- The Rustc Dev Guide — How Rustc Uses LLVM: `https://rustc-dev-guide.rust-lang.org/backend/getting-started.html`

**Java**
- JVM Specification — Chapter 1 (Introduction): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-1.html`
- JVM Specification — Chapter 2 (Structure of the JVM): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html`
- Oracle — Understanding HotSpot VM Performance Enhancements: `https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html`

**Python**
- CPython Developer Guide — Compiler Design: `https://devguide.python.org/internals/compiler/`
- Python docs — `dis` module (bytecode disassembler): `https://docs.python.org/3/library/dis.html`
- PEP 3147 — PYC Repository Directories (.pyc file layout): `https://peps.python.org/pep-3147/`

**General**
- LLVM Language Reference Manual: `https://llvm.org/docs/LangRef.html`
- Compiler Explorer (Godbolt) — interactive multi-language compilation: `https://godbolt.org/`

### Sub-topic 2 — Rust Compilation Pipeline

- The Rustc Dev Guide — HIR (High-Level IR): `https://rustc-dev-guide.rust-lang.org/hir.html`
- The Rustc Dev Guide — MIR (Mid-Level IR): `https://rustc-dev-guide.rust-lang.org/mir/index.html`
- The Rustc Dev Guide — Monomorphization: `https://rustc-dev-guide.rust-lang.org/backend/monomorph.html`
- The Rustc Dev Guide — The Borrow Checker: `https://rustc-dev-guide.rust-lang.org/borrow_check.html`
- The Rust Reference — Linkage: `https://doc.rust-lang.org/reference/linkage.html`
- Rust Blog — "Introducing MIR" (2016): `https://blog.rust-lang.org/2016/04/19/MIR.html`
- The Cargo Book — Build profiles: `https://doc.rust-lang.org/cargo/reference/profiles.html`

### Sub-topic 3 — JVM Compilation & Execution

- JVM Specification — Chapter 4 (The class File Format): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html`
- JVM Specification — Chapter 5 (Loading, Linking, and Initializing): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html`
- JVM Specification — Chapter 6 (Instruction Set): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html`
- Oracle — HotSpot JIT Compiler: `https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html`
- GraalVM Documentation — Compiler: `https://www.graalvm.org/latest/reference-manual/java/compiler/`
- GraalVM Documentation — Native Image: `https://www.graalvm.org/latest/reference-manual/native-image/`
- JEP 295 — Ahead-of-Time Compilation (jaotc): `https://openjdk.org/jeps/295`
- Oracle — Class Data Sharing (CDS): `https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html`

### Sub-topic 4 — Python Execution Model

- CPython Developer Guide — Compiler Design: `https://devguide.python.org/internals/compiler/`
- Python docs — `dis` module (bytecode instruction reference): `https://docs.python.org/3/library/dis.html`
- Python docs — `compile()` built-in: `https://docs.python.org/3/library/functions.html#compile`
- Python docs — `py_compile` module: `https://docs.python.org/3/library/py_compile.html`
- PEP 3147 — PYC Repository Directories: `https://peps.python.org/pep-3147/`
- PEP 659 — Specializing Adaptive Interpreter (Python 3.11+): `https://peps.python.org/pep-0659/`
- PEP 744 — JIT Compilation (Python 3.13+): `https://peps.python.org/pep-0744/`
- PyPy documentation — JIT overview: `https://doc.pypy.org/en/latest/jit/index.html`
- Cython documentation: `https://cython.readthedocs.io/`
- Numba documentation: `https://numba.readthedocs.io/`

### Sub-topic 5 — Runtime Systems & Memory Management

**Rust**
- The Rust Reference — Memory model: `https://doc.rust-lang.org/reference/memory-model.html`
- The Rustonomicon — The Dark Arts of Unsafe Rust: `https://doc.rust-lang.org/nomicon/`

**Java**
- Oracle — Garbage Collection Tuning Guide: `https://docs.oracle.com/en/java/javase/21/gctuning/`
- Oracle — G1 Garbage Collector: `https://docs.oracle.com/en/java/javase/21/gctuning/garbage-first-g1-garbage-collector1.html`
- Oracle — ZGC: `https://docs.oracle.com/en/java/javase/21/gctuning/z-garbage-collector.html`

**Python**
- Python docs — `gc` module (garbage collector interface): `https://docs.python.org/3/library/gc.html`
- Python docs — `sys.getrefcount()`: `https://docs.python.org/3/library/sys.html#sys.getrefcount`
- PEP 703 — Making the GIL Optional: `https://peps.python.org/pep-0703/`

### Sub-topic 6 — Intermediate Representations & Optimization

**Rust**
- The Rustc Dev Guide — Optimization passes: `https://rustc-dev-guide.rust-lang.org/backend/optimization.html`
- LLVM — Passes: `https://llvm.org/docs/Passes.html`
- Rust Playground (view LLVM IR, ASM, MIR): `https://play.rust-lang.org/`

**Java**
- OpenJDK — C2 Compiler wiki: `https://wiki.openjdk.org/display/HotSpot/C2`

**Python**
- Python docs — `dis` module (bytecode instructions): `https://docs.python.org/3/library/dis.html#python-bytecode-instructions`
- Python docs — `ast` module: `https://docs.python.org/3/library/ast.html`

**General**
- Compiler Explorer (Godbolt): `https://godbolt.org/`
- LLVM documentation hub: `https://llvm.org/docs/`

### Sub-topic 7 — WebAssembly, GraalVM & Linking Models

**Rust**
- Rust and WebAssembly book: `https://rustwasm.github.io/docs/book/`
- wasm-bindgen documentation: `https://rustwasm.github.io/wasm-bindgen/`
- wasm-pack documentation: `https://rustwasm.github.io/wasm-pack/`
- The Rust Reference — Linkage: `https://doc.rust-lang.org/reference/linkage.html`

**Java**
- GraalVM — Native Image reference: `https://www.graalvm.org/latest/reference-manual/native-image/`
- GraalVM — Truffle language implementation framework: `https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/`
- JEP 295 — Ahead-of-Time Compilation: `https://openjdk.org/jeps/295`
- JEP 454 — Foreign Function & Memory API: `https://openjdk.org/jeps/454`

**Python**
- Pyodide — Python in the browser via WebAssembly: `https://pyodide.org/`
- Emscripten (compiling C/Python to WASM): `https://emscripten.org/`

**General**
- WebAssembly specification: `https://webassembly.github.io/spec/`
- WebAssembly MDN guide: `https://developer.mozilla.org/en-US/docs/WebAssembly`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Rust | Tim McNamara — *Rust in Action* (Manning, 2021) | Covers systems-level details including how Rust compiles to machine code, CPU architecture interaction, memory layout, and LLVM |
| Java | Scott Oaks — *Java Performance* (O'Reilly, 2nd ed., 2020) | Deep coverage of JVM internals: JIT compilation (C1/C2), garbage collectors (G1, ZGC, Shenandoah), JVM tuning flags, JMH benchmarking |
| Java | Monica Beckwith — *JVM Performance Engineering* (Addison-Wesley, 2024) | Modern JVM performance: GC algorithms, JIT compilation pipeline, runtime optimizations, monitoring and diagnostics |
| Python | Anthony Shaw — *CPython Internals* (Real Python, 2021) | The definitive guide to how CPython works: parser, AST, compiler, bytecode, evaluation loop, memory allocator, GC implementation |
| General | Keith Cooper & Linda Torczon — *Engineering a Compiler* (Morgan Kaufmann, 3rd ed., 2022) | Compiler theory fundamentals: lexing, parsing, IRs, optimization passes, register allocation, code generation — the shared foundation underlying all three languages |

---

## Study Plan — 7 Sessions

Estimated total: **13–16 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from a high-level comparison of compilation models through language-specific deep dives to advanced topics like WebAssembly and GraalVM.

---

### Session 1 — Compilation Models Overview

**Goal:** understand the fundamental distinction between AOT compilation (Rust), JIT compilation (Java/JVM), and interpreted bytecode (Python/CPython); build a mental model of each language's source-to-execution pipeline.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: AOT compilation.** Read Klabnik Ch.1 pp. 1–11 (compiling with `rustc`, Cargo build). Read Blandy Ch.1 pp. 1–5 (zero-overhead abstractions, compile-time safety). Then read The Rustc Dev Guide "Overview of the Compiler" online. Key insight: Rust is fully ahead-of-time compiled — `rustc` produces native machine code via LLVM. No runtime, no GC, no interpreter. The binary runs directly on the OS. The compilation pipeline is: source → HIR → MIR (borrow checking here) → LLVM IR → machine code. |
| 1.2 | 30 min | **Java: JIT compilation on the JVM.** Read Horstmann Vol. I Ch.1 ("interpreted," "architecture-neutral" buzzwords). Read Horstmann Vol. I Ch.2 pp. 33–40 (compiling and running — `javac` to bytecode, `java` to run on JVM). Read JVM Specification Chapter 1 online. Key insight: Java uses a two-stage model — `javac` compiles source to platform-independent bytecode (.class files), then the JVM interprets that bytecode and selectively JIT-compiles hot methods to native code at runtime via HotSpot. This gives "write once, run anywhere" portability with near-native performance for long-running applications. |
| 1.3 | 30 min | **Python: interpreted bytecode.** Read Martelli Ch.1 pp. 1–19 (Python implementations: CPython, PyPy, Jython, IronPython). Read Martelli Ch.2 pp. 21–31 (the Python interpreter, running programs). Read Gorelick Ch.1 pp. 1–20 (idealized computing vs Python VM overhead). Key insight: CPython compiles source to bytecode (.pyc files) at import time, then interprets that bytecode in a C-based evaluation loop. There is no JIT in standard CPython (though Python 3.13+ experiments with one per PEP 744). The GIL serializes bytecode execution across threads. PyPy adds a tracing JIT on top of the same bytecode model. |
| 1.4 | 20 min | **Three-way comparison.** Read the Wikipedia article on AOT vs JIT compilation. Visit Compiler Explorer (godbolt.org) and compile a simple function in Rust, Java, and Python (via `dis`) to see the output side by side. Create a comparison table: rows = {compilation timing, output format, runtime required, garbage collection, startup speed, peak throughput, portability}, columns = {Rust, Java/JVM, Python/CPython}. |

---

### Session 2 — Rust Compilation Pipeline

**Goal:** trace Rust source code through every stage of the `rustc` compiler — from parsing through LLVM to the final binary; understand monomorphization, the borrow checker's place in the pipeline, and linking.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 35 min | **The rustc pipeline: HIR → MIR → LLVM IR → machine code.** Read The Rustc Dev Guide sections on HIR and MIR online. Read the "Introducing MIR" Rust Blog post (2016) online. Key insight: rustc first lowers source to HIR (desugared AST), then to MIR (control-flow graph used for borrow checking, optimization, and monomorphization), then to LLVM IR (where LLVM's optimization passes run), and finally to native machine code. The borrow checker operates on MIR — this is where ownership and lifetime rules are enforced. Use `cargo rustc -- --emit=mir` and `--emit=llvm-ir` on a small program to see the intermediate representations. |
| 2.2 | 30 min | **Monomorphization and dispatch.** Read Klabnik Ch.10 (generics and monomorphization). Read Blandy Ch.11 pp. 235–263 (traits and generics — static dispatch via monomorphization, dynamic dispatch via `dyn Trait` and vtables). Read Klabnik Ch.13 pp. 273–294 (zero-cost abstractions, iterators compile to same code as loops). Key insight: when you write `fn foo<T: Display>(x: T)`, the compiler generates a separate copy of `foo` for each concrete type `T` used — this is monomorphization. It enables static dispatch (direct function calls, inlinable) at the cost of larger binary size. `dyn Trait` opts out of monomorphization in favor of dynamic dispatch via vtable pointers, similar to Java interfaces. |
| 2.3 | 25 min | **Linking and build profiles.** Read Matthews Ch.2 pp. 33–42 (cross-compilation, static linking, binary distribution, linking to C libraries). Read Blandy Ch.8 pp. 161–175 (crate structure, build profiles). Read The Cargo Book "Build Profiles" and The Rust Reference "Linkage" online. Key insight: Rust defaults to static linking (the binary includes all Rust dependencies). Dynamic linking is used for system libraries (libc). The `musl` target enables fully static binaries with no system library dependencies. Debug builds (`dev` profile) include debug symbols and disable optimizations; release builds enable `-O3` and LTO (link-time optimization). The difference between debug and release performance can be 10–40x. |
| 2.4 | 15 min | **Hands-on exploration.** Build a small Rust program in both debug and release mode. Compare binary sizes (`ls -la target/debug/ target/release/`). Use `cargo rustc -- --emit=llvm-ir` to inspect LLVM IR. Use `cargo expand` (requires `cargo-expand` tool) to see macro expansion. Use Compiler Explorer (godbolt.org) to view the generated assembly for a generic function and observe monomorphization. |

---

### Session 3 — JVM Compilation & Execution

**Goal:** understand the full Java execution lifecycle — from `javac` bytecode generation through class loading to JIT compilation by HotSpot; explore GraalVM as an alternative.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Bytecode and class files.** Read Evans Ch.4 pp. 81–117 (class files and bytecode — class loading/linking, examining with `javap`, bytecode opcodes, reflection). Read JVM Specification Chapter 4 (class file format) online — skim the structure (magic number, constant pool, fields, methods, attributes). Key insight: `javac` compiles `.java` to `.class` files containing JVM bytecode — a stack-based instruction set. Each method becomes a sequence of bytecode instructions (e.g., `aload_0`, `invokevirtual`, `ireturn`). Use `javap -c -v MyClass.class` to disassemble a compiled class and examine the constant pool, method bytecodes, and metadata. |
| 3.2 | 35 min | **Class loading and JIT compilation.** Read Horstmann Vol. II Ch.9 pp. 120–126 (class loaders and their hierarchy). Read Evans Ch.7 pp. 207–246 (JIT compilation with HotSpot — C1/C2 compilers, inlining, monomorphic calls, deoptimization, JDK Flight Recorder). Read Oracle's HotSpot JIT overview online. Key insight: The JVM uses tiered compilation — methods start interpreted, then are compiled by C1 (fast compilation, basic optimizations) when warm, and finally by C2 (aggressive optimization — inlining, escape analysis, loop unrolling, devirtualization) when hot. The JVM can deoptimize back to interpreted code if assumptions are violated (e.g., a monomorphic call site becomes polymorphic). This adaptive optimization is why Java performance improves over time ("warmup"). |
| 3.3 | 25 min | **Type erasure, invokedynamic, and modern internals.** Read Bloch's Effective Java generics discussion on type erasure. Read Evans Ch.17 pp. 571–607 (method invocation — virtual/interface/special/final, MethodHandles, invokedynamic, string optimization). Read Horstmann Vol. II Ch.11 pp. 140–148 (annotation processing and bytecode engineering). Key insight: Java generics are erased at compile time — `List<String>` becomes `List<Object>` in bytecode, with cast instructions inserted by the compiler. `invokedynamic` (added in Java 7) allows the JVM to defer method resolution to runtime, enabling lambda expressions, string concatenation optimization, and dynamic language support. |
| 3.4 | 20 min | **GraalVM and ahead-of-time compilation.** Read GraalVM compiler documentation and Native Image documentation online. Read JEP 295 (AOT compilation) and Oracle's CDS documentation online. Key insight: GraalVM provides an alternative JIT compiler (written in Java itself) that can also compile Java applications ahead-of-time to native binaries via `native-image`. This eliminates JVM warmup and reduces startup time from seconds to milliseconds — critical for serverless/CLI use cases. The tradeoff: native-image has restrictions (limited reflection, no dynamic class loading) and peak throughput may be lower than HotSpot C2 for long-running applications. CDS (Class Data Sharing) is a less radical approach that pre-loads class metadata to reduce startup time. |

---

### Session 4 — Python Execution Model

**Goal:** understand CPython internals from source to running code — parsing, AST, bytecode compilation, and the evaluation loop; explore alternative implementations that change the execution model.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 30 min | **CPython's compilation pipeline.** Read Martelli Ch.14 pp. 429–441 (eval, compile, exec, code objects, frame objects, traceback objects). Read CPython Developer Guide "Compiler Design" online. Key insight: CPython is not purely interpreted — it has a compiler that transforms source code into bytecode. The pipeline is: source text → tokenizer → parser → AST → bytecode compiler → code objects. The `compile()` built-in exposes this: `compile("x + 1", "<string>", "eval")` returns a code object. Code objects contain bytecode, constants, variable names, and metadata. The `.pyc` files (cached in `__pycache__/`) store marshalled code objects to skip recompilation on subsequent imports. |
| 4.2 | 30 min | **Bytecode and the evaluation loop.** Read Ramalho Ch.2 (bytecode analysis with `dis`). Read Gorelick Ch.2 pp. 21–45 (profiling, bytecode analysis with `dis`). Read the Python docs for the `dis` module online (bytecode instruction reference). Key insight: Python bytecode is a stack-based instruction set executed by `ceval.c` — the core evaluation loop in CPython. Use `dis.dis(function)` to see bytecodes like `LOAD_FAST`, `BINARY_ADD`, `RETURN_VALUE`. Each bytecode dispatches through a giant switch statement (or computed goto). Python 3.11+ introduced the specializing adaptive interpreter (PEP 659) that replaces generic bytecodes with type-specialized versions at runtime — a form of inline caching. Python 3.13+ experiments with a copy-and-patch JIT compiler (PEP 744). |
| 4.3 | 30 min | **The GIL and alternative implementations.** Read Ramalho Ch.19 pp. 695–720 (GIL and its implications). Read Gorelick Ch.7 pp. 161–211 (compiling to C — Cython, Numba, PyPy, ctypes, cffi, CPython extensions). Read PEP 703 (making the GIL optional) online. Key insight: the GIL (Global Interpreter Lock) ensures only one thread executes Python bytecode at a time — this simplifies CPython's memory management (reference counting is not thread-safe) but limits CPU parallelism. PyPy uses a tracing JIT compiler that can achieve 4–10x speedup over CPython for long-running numeric code. Cython compiles Python-like code to C for AOT compilation. Numba JIT-compiles numeric Python functions via LLVM. Python 3.13+ offers an experimental free-threaded build without the GIL. |
| 4.4 | 15 min | **Hands-on exploration.** Use `python -m dis script.py` or `dis.dis(fn)` interactively to disassemble functions. Inspect `.pyc` files in `__pycache__/` — note the naming convention per PEP 3147 (e.g., `module.cpython-312.pyc`). Use `compile()` and `exec()` to compile and run code objects manually. Compare `sys.implementation` across CPython and PyPy (if installed). |

---

### Session 5 — Runtime Systems Compared

**Goal:** compare the runtime environments of all three languages — memory management strategies, startup behavior, warm-up characteristics, and runtime introspection capabilities.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Memory management: no GC vs generational GC vs reference counting.** Read Matthews Ch.5 pp. 93–118 (Rust stack/heap, ownership, smart pointers). Read Evans Ch.7 pp. 207–230 (Java GC — mark-sweep, generations, G1). Read Martelli Ch.14 pp. 436–441 (Python GC — reference counting + cycle detector). Key insight: Rust has no garbage collector — memory is freed deterministically when ownership is transferred or scope ends (RAII). Java uses tracing GC with generational hypothesis (most objects die young) — G1 is the default, ZGC and Shenandoah offer sub-millisecond pause times. CPython uses reference counting (immediate free when refcount hits zero) plus a cycle-detecting collector for circular references. Each approach has different latency, throughput, and memory overhead characteristics. |
| 5.2 | 25 min | **Startup time and warm-up behavior.** Read Oracle CDS/AppCDS documentation and GraalVM native-image startup characteristics online. Key insight: Rust binaries start in microseconds — there is no runtime to initialize. Java has significant startup overhead (JVM initialization, class loading, bytecode verification, JIT warmup) — typically 100ms–2s for simple programs, with peak performance reached after seconds to minutes of warmup. Python startup is moderate (30–100ms for the interpreter, but `import` chains can add significant overhead). Solutions: Java uses CDS/AppCDS, GraalVM native-image, and Project Leyden (future); Python uses lazy imports and `__pycache__`. |
| 5.3 | 25 min | **Runtime reflection and introspection.** Read Evans Ch.17 pp. 571–590 (Java reflection internals, MethodHandles). Read Martelli Ch.14 pp. 429–435 (Python code/frame/traceback objects). Key insight: Python has the richest runtime introspection — `type()`, `dir()`, `getattr()`, `inspect` module, modifiable classes at runtime. Java has extensive reflection (`java.lang.reflect`) but it is slower than direct access and constrained by the module system since Java 9. Rust has essentially no runtime reflection — all type information is erased at compile time (except for `Any` trait with `TypeId`). This is a direct consequence of Rust's AOT compilation model: the compiler has all the information, so the runtime does not need it. |
| 5.4 | 15 min | **Comparative synthesis.** Create a comparison table: rows = {GC model, GC pause time, startup time, warmup needed, peak throughput, runtime reflection, binary/deployment size, deterministic destruction}, columns = {Rust, Java/JVM, Python/CPython}. Note the fundamental tradeoff: Rust trades runtime flexibility for predictable performance; Java trades startup time for adaptive optimization; Python trades performance for maximum dynamism. |

---

### Session 6 — Intermediate Representations & Optimization

**Goal:** compare intermediate representations (LLVM IR, JVM bytecode, Python bytecode) and the optimization techniques applied at each level — zero-cost abstractions, devirtualization, inlining, and more.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **LLVM IR and Rust optimizations.** Read The Rustc Dev Guide "Optimization Passes" and "How Rustc Uses LLVM" online. Read LLVM Passes documentation online. Read Klabnik Ch.13 pp. 273–294 (iterators compile to identical code as hand-written loops — zero-cost abstractions). Read Matthews Ch.11 pp. 219–231 (SIMD, zero-cost abstractions). Key insight: after `rustc` generates LLVM IR, LLVM applies dozens of optimization passes: dead code elimination, constant folding, loop unrolling, function inlining, auto-vectorization. Rust's zero-cost abstractions are enabled by monomorphization + LLVM inlining — a `map().filter().collect()` chain compiles to the same tight loop as a manual `for` loop. LTO (link-time optimization) enables cross-crate inlining. PGO (profile-guided optimization) can further improve hot paths. |
| 6.2 | 30 min | **JVM bytecode and HotSpot optimizations.** Read Evans Ch.7 pp. 230–246 (JIT details — inlining, monomorphic/bimorphic/megamorphic call sites, deoptimization). Read Evans Ch.17 pp. 590–607 (invokedynamic, string optimization). Read OpenJDK C2 wiki page online. Key insight: The HotSpot C2 compiler performs aggressive speculative optimizations based on runtime profiling data collected by C1: devirtualization (if a virtual call site always sees one type, inline that implementation), escape analysis (if an object doesn't escape a method, allocate it on the stack), loop unrolling, null-check elimination, and range-check elimination. If speculation is wrong, the JVM deoptimizes (backs out to interpreted code). This is fundamentally different from Rust's static optimization — Java optimizes based on actual runtime behavior. |
| 6.3 | 25 min | **Python bytecode and limited optimization.** Read Gorelick Ch.2 pp. 45–64 (profiling, understanding where time goes). Read PEP 659 (specializing adaptive interpreter) online. Read Python `dis` module bytecode instruction reference online. Key insight: CPython performs almost no bytecode optimization — there is a peephole optimizer that does constant folding and dead code removal, but no inlining, no loop unrolling, no devirtualization. Python 3.11+ added the specializing adaptive interpreter that replaces generic bytecodes with type-specialized ones (e.g., `BINARY_ADD` becomes `BINARY_ADD_INT` when operands are always integers) — a limited form of runtime optimization. PyPy's tracing JIT goes much further, recording and optimizing entire execution traces. |
| 6.4 | 15 min | **Side-by-side comparison on Compiler Explorer.** Visit godbolt.org. Write the same function in Rust and C (e.g., sum of an array) and compare the generated assembly. Then write the equivalent in Java and use `javap -c` to see bytecode. Finally, use Python `dis.dis()` for the same function. Compare: how many instructions? How close to optimal machine code? Document the IR "depth" hierarchy: Rust (source → HIR → MIR → LLVM IR → assembly → machine code) vs Java (source → bytecode → interpreted / C1 assembly / C2 assembly) vs Python (source → AST → bytecode → interpreted). |

---

### Session 7 — Advanced: WebAssembly, GraalVM & Linking Models

**Goal:** explore advanced compilation targets (WebAssembly), alternative runtimes (GraalVM polyglot), and linking models (static vs dynamic) across all three languages.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 30 min | **Rust and WebAssembly.** Read the "Rust and WebAssembly" book online (Introduction + "Hello World" chapters). Read wasm-bindgen and wasm-pack documentation online. Read WebAssembly MDN guide online. Key insight: Rust has first-class WebAssembly support — `rustup target add wasm32-unknown-unknown` enables compilation to WASM. `wasm-pack` integrates with npm for web deployment. `wasm-bindgen` provides JavaScript interop. Rust → WASM produces small, fast binaries because Rust has no runtime/GC overhead. WASM is also used outside browsers: Wasmtime, Wasmer for server-side sandboxed execution. This is a growing target for Rust CLI tools and libraries. |
| 7.2 | 30 min | **GraalVM: polyglot runtime and native-image.** Re-read GraalVM documentation online (compiler, native-image, Truffle framework). Read Blandy Ch.21 pp. 525–540 (FFI context). Key insight: GraalVM is an alternative JVM that includes: (1) the Graal JIT compiler (written in Java, replaces C2), (2) Native Image (AOT compilation to standalone binaries), (3) the Truffle framework for implementing languages (GraalPy for Python, TruffleRuby, GraalJS). Native Image performs "closed-world analysis" at build time — all reachable code must be known ahead of time, which restricts dynamic features (reflection needs configuration, no dynamic class loading). The tradeoff: instant startup + lower memory vs restricted dynamism + potentially lower peak throughput. |
| 7.3 | 25 min | **Linking models: static vs dynamic.** Read Matthews Ch.2 pp. 33–37 (static linking, linking to C libraries). Read The Rust Reference "Linkage" online. Read Blandy Ch.21 pp. 540–583 (FFI, unsafe code, linking). Read Horstmann Vol. II Ch.13 pp. 160–174 (JNI). Read JEP 454 (Foreign Function & Memory API) online. Key insight: Rust defaults to static linking for Rust dependencies and dynamic linking for system libraries; with `musl`, full static linking is possible. Java uses JNI (complex, unsafe) or the newer Foreign Function & Memory API (JEP 454 / "Panama") for native interop. Python uses ctypes/cffi for dynamic linking to shared libraries and CPython extension modules (.so/.pyd) for compiled C code. The linking model fundamentally affects deployment: Rust ships a single binary, Java ships JARs (requiring a JVM), Python ships source or wheels (requiring an interpreter). |
| 7.4 | 20 min | **Cross-language interop and future directions.** Read about PyO3 (Rust-Python bridge) online at `https://pyo3.rs/`. Read about Pyodide online at `https://pyodide.org/`. Read JEP 454 online. Key insight: the boundaries between languages are increasingly blurred. PyO3 lets Rust code expose Python modules (Pydantic v2, Polars, Ruff all use this). GraalVM's polyglot engine allows Java, Python, JavaScript, and Ruby to share objects in the same process. WebAssembly serves as a universal compilation target — WASM Interface Types aim to enable cross-language component composition. The trend is toward compilation-time interop (Rust→Python via PyO3, Rust→WASM→JS) rather than runtime interop (JNI, ctypes). |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Compilation models overview | Klabnik 1–11, Blandy 1–5, Horstmann Vol.I Ch.1 + 33–40, Martelli 1–19 + 21–31, Gorelick 1–20 | Rustc Dev Guide overview, JVM Spec Ch.1–2, CPython compiler design, LLVM docs, Compiler Explorer |
| 2 | Rust compilation pipeline | Klabnik Ch.10 + 273–294, Blandy 235–263, Matthews 33–42 + 161–175 | Rustc Dev Guide (HIR, MIR, LLVM backend), Rust Reference linkage, Cargo build profiles, MIR blog post |
| 3 | JVM compilation & execution | Evans 81–117 + 207–246 + 571–607, Horstmann Vol.II 114–126 + 140–148, Bloch generics | JVM Spec Ch.4–6, HotSpot JIT docs, GraalVM compiler + native-image, JEP 295, CDS docs |
| 4 | Python execution model | Martelli 429–441, Ramalho Ch.2 + 695–720, Gorelick 21–64 + 161–211 | CPython compiler design, `dis` module docs, PEP 3147, PEP 659, PEP 744, PEP 703, PyPy JIT docs |
| 5 | Runtime systems compared | Matthews 93–118, Evans 207–230 + 571–590, Martelli 429–441 | Oracle GC tuning guide, G1/ZGC docs, Python `gc` module, CDS/AppCDS docs, PEP 703 |
| 6 | IRs & optimization | Klabnik 273–294, Matthews 219–231, Evans 230–246 + 590–607, Gorelick 45–64 | Rustc Dev Guide optimization, LLVM passes, OpenJDK C2 wiki, PEP 659, Compiler Explorer |
| 7 | WASM, GraalVM & linking | Matthews 33–37, Blandy 525–583, Horstmann Vol.II 160–174 | Rust+WASM book, wasm-bindgen, GraalVM native-image + Truffle, JEP 454, WebAssembly spec, Pyodide, PyO3 |

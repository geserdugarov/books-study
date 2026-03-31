# Layer 1 · Topic 3 — Compilation & Execution

> Comparative study of Rust, Java, and Python: how source code becomes a running program — compilation pipelines, intermediate representations, runtimes, JIT compilation, and linking models.

---

## 1. Compilation Models Overview

Three fundamentally different approaches to turning source code into running programs: **ahead-of-time compilation** (Rust), **JIT compilation on a virtual machine** (Java/JVM), and **interpreted bytecode** (Python/CPython). Each model makes a different tradeoff between compilation time, startup speed, peak throughput, and runtime flexibility.

### Rust: Ahead-of-Time (AOT) Compilation

Rust is fully ahead-of-time compiled — `rustc` produces native machine code before the program ever runs. There is no runtime, no garbage collector, no interpreter. The resulting binary runs directly on the operating system, communicating through system calls.

The compilation pipeline passes through multiple intermediate representations:

```
Source → Tokens → AST → HIR → THIR → MIR → LLVM IR → Machine Code
```

Each stage progressively simplifies the program. The **borrow checker** operates on MIR (Mid-Level IR), enforcing ownership and lifetime rules. **LLVM** handles the final optimization passes and machine code generation. Because all analysis and optimization happens before execution, the binary starts instantly and runs at peak performance from the first instruction.

The Rustc Dev Guide describes the compiler as a query-based system rather than a sequential pipeline: "major steps are organized as queries that call each other." Query results are cached on disk for incremental compilation — only queries whose inputs changed need to be recomputed. This architectural choice means recompilation after small changes can be substantially faster than a full rebuild.

Rust's compilation model is similar to C and C++ — the compiler sees the whole program (or crate) and produces optimized native code. The key difference is that Rust's compiler enforces memory safety and thread safety at compile time, eliminating entire classes of bugs that plague C/C++ programs without adding any runtime overhead.

> **Sources:** Klabnik & Nichols (2023) Ch.1 pp. 1–11 · Blandy & Orendorff (2017) Ch.1 pp. 1–5 · McNamara (2021) Ch.5 pp. 137–173 · [Rustc Dev Guide — Overview](https://rustc-dev-guide.rust-lang.org/overview.html)

### Java: Two-Stage Compilation with JIT

Java uses a two-stage compilation model. First, `javac` compiles source code to platform-independent **bytecode** stored in `.class` files. Then, the **Java Virtual Machine (JVM)** loads and executes that bytecode at runtime, selectively compiling hot methods to native machine code via **Just-In-Time (JIT) compilation**.

```
Source → javac → Bytecode (.class) → JVM (Interpreter → C1 JIT → C2 JIT) → Machine Code
```

The JVM Specification defines the JVM as "an abstract computing machine" with an instruction set and run-time memory areas. Critically, "the JVM knows nothing of the Java programming language. It only understands the class file format" — a binary format containing bytecodes, a symbol table, and ancillary information. This means any language that can produce valid class files can run on the JVM (Kotlin, Scala, Clojure, Groovy all exploit this).

The JIT compilation process is adaptive. HotSpot (the standard JVM implementation) uses **tiered compilation**:
- **Tier 0 — Interpreter**: Executes bytecode directly. Collects basic profiling data.
- **Tiers 1–3 — C1 compiler**: Compiles warm methods quickly with basic optimizations and profiling instrumentation.
- **Tier 4 — C2 compiler**: Compiles hot methods aggressively using profiling data from C1 — inlining, escape analysis, loop unrolling, devirtualization.

This adaptive approach means Java programs get faster over time as the JIT learns which code paths are hot and what types flow through them. The tradeoff is startup overhead: the JVM must initialize, load classes, verify bytecode, and warm up the JIT before reaching peak performance.

> **Sources:** Horstmann (2024) Vol. I Ch.1, Ch.2 pp. 33–40 · Evans et al (2022) Ch.7 pp. 207–246 · Oaks (2020) Ch.4 pp. 89–120 · Beckwith (2024) Ch.1 pp. 1–42 · [JVM Spec Ch.1](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-1.html) · [Oracle — HotSpot VM Performance](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)

### Python: Compiled Bytecode, Interpreted Execution

CPython (the reference Python implementation) compiles source code to **bytecode** at import time, then interprets that bytecode in a C-based evaluation loop. Despite common perception, Python is not purely interpreted — it does have a compilation step.

```
Source → Tokenizer → Parser → AST → CFG → Bytecode → Interpreter (ceval.c)
```

The compilation happens transparently: when you `import` a module, CPython compiles it to bytecode and caches the result in `.pyc` files inside `__pycache__/`. On subsequent imports, the cached bytecode is loaded directly if the source hasn't changed.

Unlike Java's JVM, the CPython bytecode interpreter does not JIT-compile hot code to native machine code (in standard CPython). Each bytecode instruction is dispatched through a C switch statement (or computed goto) in the evaluation loop (`ceval.c`). The **GIL (Global Interpreter Lock)** ensures only one thread executes Python bytecode at a time, simplifying the interpreter but preventing true CPU parallelism from threads.

Python 3.11+ introduced a **specializing adaptive interpreter** (PEP 659) that replaces generic bytecodes with type-specialized versions at runtime — a limited form of runtime optimization. Python 3.13+ adds an experimental **copy-and-patch JIT compiler** (PEP 744), and a **free-threaded build** without the GIL (PEP 703). Alternative implementations like **PyPy** provide a full tracing JIT compiler, achieving 4–10x speedup over CPython for long-running programs.

> **Sources:** Martelli et al (2023) Ch.1 pp. 1–19, Ch.2 pp. 21–31 · Gorelick & Ozsvald (2020) Ch.1 pp. 1–20 · Shaw (2021) pp. 61–74, 118–150 · [CPython Developer Guide — Compiler Design](https://devguide.python.org/internals/compiler/) · [PEP 659](https://peps.python.org/pep-0659/)

### Comparison Matrix

| Aspect | Rust | Java/JVM | Python/CPython |
|--------|------|----------|----------------|
| **Compilation model** | AOT (source → native binary) | Two-stage: AOT to bytecode, then JIT to native | AOT to bytecode, then interpreted |
| **Output format** | Native executable (ELF/Mach-O/PE) | Bytecode in `.class` files (JAR archives) | Bytecode in `.pyc` files |
| **Runtime required** | None (OS only) | JVM (50–200 MB) | CPython interpreter (~15 MB) |
| **Garbage collection** | None (ownership/RAII) | Tracing GC (G1, ZGC, etc.) | Reference counting + cycle collector |
| **Startup time** | Microseconds | 100ms–2s (class loading, JIT warmup) | 30–100ms (interpreter + imports) |
| **Peak throughput** | Native speed from start | Near-native after warmup (C2 JIT) | 10–100x slower than C |
| **Warmup needed** | No | Yes (seconds to minutes) | No (but no JIT speedup either) |
| **Portability** | Per-target binary | Bytecode runs on any JVM | Source runs on any CPython |
| **Key IR** | LLVM IR | JVM bytecode | Python bytecode |

---

## 2. Rust Compilation Pipeline

### Pipeline Stages: Source to Binary

The `rustc` compiler transforms Rust source through six intermediate representations before producing a final binary. Each IR is progressively simpler, with specific compiler passes operating at each level.

**1. Lexing and Parsing → AST**

The low-level lexer (`rustc_lexer`) converts raw UTF-8 source into a token stream. A higher-level lexer performs **string interning** — storing one immutable copy of each distinct string. The recursive descent parser then builds an Abstract Syntax Tree (AST). Macro expansion, AST validation, name resolution, and early linting all happen at this stage. The parser recovers from errors by parsing a superset of Rust's grammar while emitting diagnostics.

**2. AST → HIR (High-Level IR)**

The AST is lowered to HIR, a more compiler-friendly form. This involves extensive desugaring — for example, `for` loops are converted to `loop` + `match` constructs, and `async fn` is desugared into state machines. HIR uses **out-of-band storage**: items are stored in maps indexed by ID rather than nested directly, enabling fine-grained incremental compilation tracking. Type inference, trait solving, and type checking are performed on HIR.

Three identifier types track entities at different granularities:

| ID Type | Scope | Purpose |
|---------|-------|---------|
| `DefId` | Cross-crate | Top-level items (functions, structs, traits) |
| `LocalDefId` | Current crate | Like DefId but guaranteed local |
| `HirId` | Current crate | Fine-grained: expressions, patterns, statements |

**3. HIR → THIR → MIR (Mid-Level IR)**

HIR is first lowered to THIR (Typed High-level IR, used for pattern/exhaustiveness checking), then to MIR. MIR is the most important IR for Rust-specific analysis — it is a **control-flow graph (CFG)** of basic blocks containing simple typed statements. As the 2016 blog post "Introducing MIR" explained, MIR "is a vastly simplified version of Rust" that reduces the language to primitive operations:

- All loop forms (`for`, `while`, `while let`) become `loop` + `match` or goto-like constructs
- Method calls are desugared to explicit function calls
- Match expressions decompose into variant checking (switches) and data extraction (downcasts)
- Drop instructions mark exactly where destructors execute
- Panic edges in the CFG show potential panic points and cleanup paths

MIR's core vocabulary:

| Concept | Description |
|---------|-------------|
| **Basic block** | Sequence of statements + one terminator (with potentially multiple successors) |
| **Local** | Stack-allocated memory slot (`_0` = return value, `_1`, `_2`, ...) |
| **Place** | Memory location expression (e.g., `_1` or `_1.f`) |
| **Rvalue** | Expression producing a value (right-hand side of assignment) |
| **Operand** | Constant, `copy Place`, or `move Place` |

Complex expressions are broken into primitive operations with temporaries:
```
// Source: x = a + b + c
TMP1 = a + b
x = TMP1 + c
```

MIR enables three key benefits: faster compilation (serializable for incremental compilation), faster execution (Rust-specific optimizations before LLVM), and more precise type checking (non-lexical lifetimes derived from the control-flow graph).

**4. Borrow Checking (on MIR)**

The borrow checker operates on MIR, enforcing five rules:
1. All variables are initialized before use
2. Cannot move the same value twice
3. Cannot move a value while it is borrowed
4. Cannot access a place while it is mutably borrowed (except through the reference)
5. Cannot mutate a place while it is immutably borrowed

The major phases: replace all regions with fresh inference variables, run dataflow analyses to compute what data is moved when, perform a type check across MIR to determine constraints between regions, run region inference to compute lifetime values (points in the CFG where each lifetime must be valid), compute borrows in scope at each program point, then walk the MIR reporting errors.

Non-lexical lifetimes (NLL) are possible because MIR is a CFG — regions are derived from control-flow structure rather than lexical scope, eliminating many artificial restrictions from the older borrow checker that operated on HIR.

**5. MIR → LLVM IR**

Monomorphization happens at this stage: generic code is stamped out for each concrete type used. The monomorphized MIR is then translated to LLVM IR — a typed assembly language with annotations that serves as input to the LLVM optimization and code generation framework.

LLVM IR is organized into **codegen units (CGUs)**. Multiple CGUs can be compiled in parallel for multi-core utilization. For incremental builds, the partitioner creates two CGUs per source-level module: one for "stable" (non-generic) code and one for "volatile" (monomorphized/specialized) code.

**6. LLVM → Machine Code**

LLVM runs optimization passes on the IR (dead code elimination, constant folding, loop unrolling, inlining, auto-vectorization), then emits machine code as object files. The linker combines objects into the final executable.

You can inspect each stage:
```bash
cargo rustc -- -Z unpretty=hir       # View HIR
cargo rustc -- -Z unpretty=hir-tree  # View HIR (structured)
cargo rustc -- --emit=mir            # View MIR
cargo rustc -- --emit=llvm-ir        # View LLVM IR
```

> **Sources:** [Rustc Dev Guide — Overview](https://rustc-dev-guide.rust-lang.org/overview.html) · [Rustc Dev Guide — HIR](https://rustc-dev-guide.rust-lang.org/hir.html) · [Rustc Dev Guide — MIR](https://rustc-dev-guide.rust-lang.org/mir/index.html) · [Rustc Dev Guide — Borrow Checker](https://rustc-dev-guide.rust-lang.org/borrow_check.html) · [Rust Blog — Introducing MIR (2016)](https://blog.rust-lang.org/2016/04/19/MIR.html)

### Monomorphization and Dispatch

When you write a generic function like `fn foo<T: Display>(x: T)`, the compiler generates a **separate copy** of `foo` for each concrete type `T` actually used in the program. This is monomorphization — the process of stamping out specialized code.

```rust
// Source code
fn print_it<T: Display>(x: T) { println!("{}", x); }

print_it(42_u32);       // Generates print_it::<u32>
print_it("hello");      // Generates print_it::<&str>
print_it(3.14_f64);     // Generates print_it::<f64>
```

The monomorphization collector determines what concrete types need code generated by walking the call graph. For example, if `main()` calls `banana()` which calls `peach::<u64>()`, the collector produces `[main, banana, peach::<u64>]`.

**Monomorphization vs. type erasure (Java's approach)**:

| Aspect | Rust (monomorphization) | Java (type erasure) |
|--------|------------------------|---------------------|
| **Mechanism** | Separate compiled copy per concrete type | Single compiled copy, types erased to Object |
| **Dispatch** | Static (direct function call, inlinable) | Virtual (through vtable/itable) |
| **Runtime cost** | Zero — same as hand-written specialized code | Pointer indirection on every access |
| **Binary size** | Larger (N copies for N types) | Smaller (one copy) |
| **Compile time** | Longer (compiling N copies) | Shorter |

Rust also supports **dynamic dispatch** via `dyn Trait`:

```rust
fn print_dyn(x: &dyn Display) { println!("{}", x); }
```

With `dyn Trait`, the compiler generates a **vtable** (virtual method table) containing function pointers. Each call goes through an indirection, similar to Java interface dispatch. The tradeoff: dynamic dispatch avoids code bloat but prevents inlining and adds pointer indirection overhead.

Klabnik demonstrates that Rust's zero-cost abstractions are enabled by monomorphization + LLVM inlining: a `map().filter().collect()` iterator chain compiles to the same tight loop as a hand-written `for` loop. "The iterators, although a high-level abstraction, get compiled down to roughly the same code as if you'd written the lower-level code yourself."

> **Sources:** Klabnik & Nichols (2023) Ch.10, Ch.13 pp. 273–294 · Blandy & Orendorff (2017) Ch.11 pp. 235–263 · [Rustc Dev Guide — Monomorphization](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html)

### Linking and Build Profiles

**Crate types and linking**:

Rust supports seven crate types, each producing a different output artifact:

| Crate Type | Output | Description |
|------------|--------|-------------|
| `bin` | Executable | Runnable binary; links all Rust and native deps |
| `lib` | Compiler-chosen | Alias for the recommended library type |
| `rlib` | `.rlib` | Rust library — intermediate artifact with metadata |
| `dylib` | `.so`/`.dylib`/`.dll` | Dynamic Rust library |
| `staticlib` | `.a`/`.lib` | Static library for embedding in non-Rust code |
| `cdylib` | `.so`/`.dylib`/`.dll` | Dynamic library for loading from other languages |
| `proc-macro` | Host-arch dynamic lib | Procedural macro crate (compiled for the host) |

By default, Rust **statically links** all Rust dependencies into the final binary — the executable contains all the code it needs. Dynamic linking is used only for system libraries (libc). For fully self-contained binaries on Linux, you can link against musl:

```bash
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl
```

The C runtime linking mode is controlled via `target-feature=+crt-static` / `-crt-static`. Most targets default to dynamic C runtime; musl-based targets default to static.

**Build profiles** control optimization levels and debug information:

| Setting | `dev` (debug) | `release` |
|---------|--------------|-----------|
| `opt-level` | 0 (none) | 3 (aggressive) |
| `debug` | true (full symbols) | false |
| `debug-assertions` | true | false |
| `overflow-checks` | true | false |
| `lto` | false | false |
| `incremental` | true | false |
| `codegen-units` | 256 | 16 |

The `opt-level` settings: 0 (none), 1 (basic), 2 (standard), 3 (aggressive — can sometimes be slower than 2), `"s"` (optimize for size), `"z"` (size + no loop vectorization).

**LTO (Link-Time Optimization)**: `true`/"fat" enables whole-program LTO across all crates — the LLVM optimizer can inline across crate boundaries. "thin" provides similar benefits with less compilation time. The performance difference between `dev` and `release` builds is typically **10–40x**.

**Codegen units**: How many units a crate is split into for parallel compilation. More units = faster compilation but potentially slower code (LLVM can't optimize across units). Custom profiles can override these settings:

```toml
[profile.release-lto]
inherits = "release"
lto = true
codegen-units = 1   # Maximum optimization, slowest compilation
```

An important subtlety: raising the optimization level of a dependency that defines generic functions may not speed up your code, because generic code is monomorphized in the **calling** crate and uses the calling crate's optimization settings.

> **Sources:** Matthews (2024) Ch.2 pp. 33–42 · Blandy & Orendorff (2017) Ch.8 pp. 161–175 · [Rust Reference — Linkage](https://doc.rust-lang.org/reference/linkage.html) · [Cargo Book — Build Profiles](https://doc.rust-lang.org/cargo/reference/profiles.html)

---

## 3. JVM Compilation & Execution

### Bytecode and the Class File Format

The `javac` compiler transforms Java source into `.class` files containing **JVM bytecode** — a stack-based instruction set designed for platform independence. The JVM Specification defines the class file format precisely: a magic number (`0xCAFEBABE`), version information, a constant pool (symbolic references and literals), field and method descriptors, and the bytecode itself.

**JVM data types**: Primitive types (`byte`, `short`, `int`, `long`, `char`, `float`, `double`, `boolean`) and reference types (class types, array types, interface types). Notably, `boolean`, `byte`, `char`, and `short` lack direct instruction support for most operations — the compiler uses `int` operations with narrowing conversions.

**Run-time data areas**:

| Area | Scope | Purpose |
|------|-------|---------|
| **PC Register** | Per-thread | Address of currently executing instruction |
| **JVM Stacks** | Per-thread | Frames for method invocations (local variables + operand stack) |
| **Heap** | Shared | All object instances and arrays; garbage collected |
| **Method Area** | Shared | Per-class structures, constant pool, method code |
| **Native Method Stacks** | Per-thread | Support for native (C) methods |

Each **frame** (method invocation) contains:
- **Local variables array**: indexed from 0; instance methods have `this` at index 0; `long`/`double` occupy two slots
- **Operand stack**: LIFO stack with compile-time-determined max depth
- **Dynamic linking**: translates symbolic references to concrete runtime references

The **instruction set** uses single-byte opcodes (max 256 instructions) with type-encoded mnemonics: `i`=int, `l`=long, `f`=float, `d`=double, `a`=reference. Categories include load/store, arithmetic, type conversion, object creation, stack management, control transfer, and five method invocation opcodes:

| Opcode | Purpose |
|--------|---------|
| `invokevirtual` | Instance method dispatch (virtual, uses vtable) |
| `invokeinterface` | Interface method dispatch |
| `invokespecial` | Constructors, `super` calls, private methods |
| `invokestatic` | Static methods |
| `invokedynamic` | Bootstrap-method-based dispatch (lambdas, string concat) |

You can inspect bytecode with `javap`:
```bash
javap -c -v MyClass.class   # Disassemble with verbose output
```

This shows the constant pool, method bytecodes, line number tables, and stack map frames.

> **Sources:** Evans et al (2022) Ch.4 pp. 81–117 · [JVM Spec Ch.2](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html) · [JVM Spec Ch.4](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html) · [JVM Spec Ch.6](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html)

### Class Loading, Linking, and Initialization

The JVM loads classes lazily — a class is loaded only when it is first referenced. The process has three phases:

**1. Loading**: Finding and creating a binary representation of a class.

Two kinds of class loaders exist:
- **Bootstrap class loader**: Built into the JVM; loads core platform classes (`java.base`)
- **User-defined class loaders**: Subclasses of `ClassLoader`; delegate to parent loaders or define classes directly via `defineClass()`

The distinction between **defining loader** (actually creates the class) and **initiating loader** (any loader in the delegation chain) is important — loading constraints ensure that two different loaders initiating loading of the same class name get the same class, preventing type confusion attacks.

**2. Linking**: Three sub-phases:
- **Verification**: Ensures binary representation is structurally correct; type-checks bytecode. This is the JVM's safety net — it guarantees that class files haven't been tampered with.
- **Preparation**: Creates static fields, initializes to default values (zero/null/false). Does NOT execute user-written initializers yet.
- **Resolution**: Dynamically determines concrete values from symbolic references. Triggered by instructions like `new`, `getstatic`, `invokevirtual`. Successful resolution is cached; failed resolution throws the same error on subsequent attempts. `invokedynamic` is special: each call site maintains separate resolution state.

**3. Initialization**: Executes the class initialization method `<clinit>` (static blocks and static field initializers). This is thread-safe: the JVM acquires a lock on the class, checks state, marks it as "initializing", initializes the superclass first, executes `<clinit>`, then marks it as "initialized." Only one thread executes `<clinit>`; others wait.

The JVM startup sequence itself: load initial class via bootstrap loader → link it → initialize it → invoke `public static void main(String[])`.

> **Sources:** Horstmann (2024) Vol. II Ch.9 pp. 120–126 · Evans et al (2022) Ch.4 pp. 81–100 · [JVM Spec Ch.5](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html)

### HotSpot JIT Compilation

The HotSpot JVM uses **tiered compilation** (enabled by default since Java SE 7) that combines two JIT compilers:

**C1 (Client compiler)**: Fast compilation, basic optimizations. Produces compiled code with profiling instrumentation. Methods progress through tiers:
- Tier 0: Interpreter — collects basic profiling
- Tier 1: C1 without profiling (simple methods)
- Tier 2: C1 with basic profiling (invocation counts)
- Tier 3: C1 with full profiling (type information, branch counts)

**C2 (Server compiler)**: Slow compilation, aggressive optimizations. Uses profiling data accumulated by C1:
- Tier 4: C2 fully optimized code — inlining, escape analysis, loop unrolling, devirtualization

The code cache is **segmented** into three regions:
- **Non-method**: Compiler buffers, interpreter code (fixed 3 MB)
- **Profiled**: Lightly optimized code with short lifetime (C1 Tier 2–3)
- **Non-profiled**: Fully optimized code with long lifetime (C2 Tier 4)

**Key HotSpot optimizations**:

**Escape Analysis**: Analyzes whether a new object "escapes" its creating method. Three escape states: GlobalEscape (escapes method/thread), ArgEscape (passed as argument), NoEscape (scalar replaceable). NoEscape objects can have their allocations eliminated entirely — fields are replaced with local variables. Associated locks on non-escaping objects are also removed.

**Compressed Ordinary Object Pointers (CompressedOops)**: On 64-bit systems, managed pointers are represented as 32-bit object offsets scaled by 8 (objects aligned on 8-byte boundaries). This addresses up to ~32 GB of heap with 32-bit references. **Zero-based CompressedOops** requests the OS to start the heap at virtual address zero, eliminating base address addition. Enabled by default when `-Xmx` < 32 GB.

**Compact Strings (Java SE 9+)**: Changed `String` internal representation from UTF-16 `char[]` to `byte[]` + encoding flag. Latin-1 characters stored as 1 byte instead of 2, saving ~50% memory for most strings.

> **Sources:** Evans et al (2022) Ch.7 pp. 207–246 · Oaks (2020) Ch.4 pp. 89–120 · Beckwith (2024) Ch.5 pp. 115–175 · [Oracle — HotSpot VM Performance](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)

### Type Erasure, invokedynamic, and Modern Internals

**Type erasure**: Java generics are erased at compile time. `List<String>` becomes `List<Object>` in bytecode, with cast instructions inserted by `javac`. The JVM never sees generic type parameters at runtime. This differs fundamentally from Rust's monomorphization (which generates specialized code per type) and means Java generics carry a runtime cost (casts, boxing for primitives).

**invokedynamic** (added in Java 7, JEP 292) is the most important bytecode innovation since Java's creation. Unlike other invoke instructions where the target method is fixed in the constant pool, `invokedynamic` defers method resolution to a **bootstrap method** that runs the first time the call site is reached. The bootstrap method returns a `CallSite` object containing a `MethodHandle` — a direct, JIT-optimizable pointer to the target method. Subsequent calls go through the cached `CallSite` with no further bootstrap overhead.

Uses of `invokedynamic`:
- **Lambda expressions**: Each lambda is compiled to an `invokedynamic` that bootstraps a lightweight anonymous class at first invocation
- **String concatenation** (Java 9+): `"Hello " + name` compiles to an `invokedynamic` call rather than `StringBuilder` chains, allowing the JVM to choose the optimal concatenation strategy at runtime
- **Dynamic language support**: JRuby, Jython, Nashorn JavaScript engine all use `invokedynamic` for method dispatch

**Method invocation internals**: Evans describes five dispatch mechanisms:

| Mechanism | Bytecode | Use Case |
|-----------|----------|----------|
| Virtual dispatch | `invokevirtual` | Standard instance methods (vtable lookup) |
| Interface dispatch | `invokeinterface` | Methods called through interface type (itable search) |
| Special dispatch | `invokespecial` | Constructors, `super` calls, private methods (no lookup) |
| Static dispatch | `invokestatic` | Static methods (no receiver object) |
| Dynamic dispatch | `invokedynamic` | Lambdas, string concat, dynamic languages |

**MethodHandles** (Java 7+) provide a more flexible and performant alternative to reflection. A `MethodHandle` is a typed, directly executable reference to a method, constructor, or field accessor. Unlike reflection, MethodHandles can be inlined by the JIT compiler.

> **Sources:** Bloch (2018) Generics chapters · Evans et al (2022) Ch.17 pp. 571–607 · Horstmann (2024) Vol. II Ch.11 pp. 140–148

### GraalVM and Ahead-of-Time Compilation

**The Graal compiler** is a dynamic JIT compiler **written in Java** that transforms bytecode into machine code. It integrates with the HotSpot VM as a replacement for the C2 compiler, using a language-independent intermediate graph representation.

Graal's key advantage is **Partial Escape Analysis** — more powerful than HotSpot's escape analysis. It determines object accessibility boundaries within compilation units, only materializing allocations on paths where objects actually "escape." This provides the greatest benefit for code using modern Java features (Streams, Lambdas) with many non-escaping objects.

**GraalVM Native Image** takes a different approach entirely — **ahead-of-time compilation** that converts Java bytecode into standalone native executables:

Build process:
1. **Static analysis phase**: Reachability analysis determines which classes, methods, and resources are needed at runtime
2. **Compilation phase**: Converts identified bytecode + standard libraries + JDK native code into a platform-specific binary

```bash
native-image -jar myapp.jar myapp     # Produces native executable
```

Native Image operates under the **closed-world assumption**: all bytecode callable at runtime must be known and analyzed at build time. Dynamic features require pre-declaration:
- Reflection → `reflect-config.json`
- JNI calls → `jni-config.json`
- Dynamic proxies → `proxy-config.json`
- Resource loading → `resource-config.json`

| Aspect | HotSpot JIT | GraalVM Native Image |
|--------|------------|---------------------|
| Compilation time | At runtime | At build time |
| Startup | 100ms–2s | Milliseconds |
| Peak throughput | Higher (adaptive optimization) | Lower (no runtime profiling) |
| Memory footprint | Larger (JVM overhead) | Smaller (only needed code) |
| Dynamic features | Full support | Restricted (closed-world) |
| Warmup | Required | None |
| Use case | Long-running servers | CLI tools, serverless, microservices |

**Class Data Sharing (CDS)** is a less radical approach to startup optimization. CDS memory-maps pre-processed class metadata from a shared archive at startup:
- Pre-packaged default archive since JDK 12 (at `lib/[arch]/server/classes.jsa`)
- Multiple JVM processes share the same archive (read-only memory mapping)
- **Application CDS (AppCDS)** extends this to application classes
- **Dynamic CDS** automatically archives loaded classes at application exit
- Controlled via `-XX:+AutoCreateSharedArchive -XX:SharedArchiveFile=app.jsa`

**JEP 295 (jaotc)** was an earlier experimental AOT approach in JDK 9: the `jaotc` tool produced shared libraries (`.so`) using Graal as the code-generating backend. These AOT libraries were treated as an extension of the CodeCache at runtime. A class fingerprinting mechanism validated that bytecode hadn't changed since AOT compilation. Two modes were supported: non-tiered (behaves like statically compiled C++ code) and tiered (collects profiling for later C2 recompilation). This experiment was later superseded by GraalVM Native Image.

> **Sources:** Evans et al (2022) Ch.7 pp. 230–246 · Oaks (2020) Ch.4 pp. 115–120 · Beckwith (2024) Ch.8 pp. 273–306 · [GraalVM — Compiler](https://www.graalvm.org/latest/reference-manual/java/compiler/) · [GraalVM — Native Image](https://www.graalvm.org/latest/reference-manual/native-image/) · [Oracle — CDS](https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html) · [JEP 295](https://openjdk.org/jeps/295)

### Performance Testing and Monitoring

Effective Java performance work requires rigorous measurement methodology. The **Java Microbenchmark Harness (JMH)** is the standard tool for writing correct microbenchmarks. JMH is critical because naive benchmarks in Java produce misleading results — dead-code elimination, constant folding, and JIT warmup make hand-rolled timing loops unreliable.

JMH provides annotations to control benchmark execution:
- `@Benchmark` marks benchmark methods
- `@Fork` controls JVM process isolation (each fork is a fresh JVM — eliminates profile pollution)
- `@Warmup` and `@Measurement` specify iteration counts and duration
- `@BenchmarkMode` selects throughput, average time, sample time, or single-shot measurement
- `@OperationsPerInvocation` corrects for loop-based benchmarks

Performance testing exists at three scales: **microbenchmarks** (isolated operations, JMH), **mesobenchmarks** (multi-threaded subsystem tests), and **macrobenchmarks** (full application under realistic load). Oaks argues that mesobenchmarks often provide the best signal for real-world performance decisions, as microbenchmarks can be dominated by JIT artifacts and macrobenchmarks are difficult to isolate.

Beckwith identifies four key **performance metrics**: **footprint** (memory consumption including heap, native, and off-heap), **responsiveness** (latency at various percentiles — p50, p99, p99.9), **throughput** (operations per unit time), and **availability** (uptime under load). A systematic performance engineering methodology combines top-down analysis (start from user-visible symptoms, trace to root cause) with bottom-up analysis (start from hardware counters, identify resource bottlenecks).

**Java Flight Recorder (JFR)** enables production-safe profiling with minimal overhead (typically < 2%). JFR collects events — method profiling, GC activity, thread states, I/O operations, class loading — into a ring buffer that can be dumped on demand or streamed. **Java Mission Control (JMC)** provides a GUI for analyzing JFR recordings. Key JFR capabilities:
- Continuous recording with configurable event thresholds
- Selectable event categories (GC, compiler, threads, I/O, etc.)
- Post-hoc analysis without needing to reproduce the issue

> **Sources:** Oaks (2020) Ch.2 pp. 15–48, Ch.3 pp. 49–88 · Beckwith (2024) Ch.5 pp. 115–175

---

## 4. Python Execution Model

### CPython's Compilation Pipeline

CPython's compilation pipeline transforms source code into bytecode through several stages:

**1. Tokenizer/Lexer** (`Parser/tokenizer.c`): Converts source text into a stream of tokens.

**2. Parser**: Since Python 3.9, CPython uses a **PEG parser** (replacing the older LL(1) parser). It produces a Concrete Syntax Tree, then an Abstract Syntax Tree (AST). The AST is defined in `Parser/Python.asdl`.

**3. AST Optimization**: A constant folding pass runs over the AST (e.g., folding `1 + 2` into `3`).

**4. Symbol Table** (`Python/symtable.c`): Analyzes scoping — identifies local, global, free, and cell variables for each scope. Determines which variables need closures.

**5. CFG Construction** (`Python/compile.c`): The compiler converts the AST into a Control Flow Graph of basic blocks. Each basic block is a sequence of instructions with a single entry point.

**6. Bytecode Emission**: The CFG is assembled into a linear sequence of bytecode instructions. Jump targets are resolved.

**7. Peephole Optimizer**: A pass that performs local optimizations — dead code elimination, jump optimization, constant folding at the bytecode level.

**8. Code Object Creation**: The final bytecode, constants, names, and metadata are packaged into an immutable `PyCodeObject`.

```
Source Text → Tokenizer → Parser (PEG) → AST → Optimizer → Symbol Table
         → CFG → Bytecode Emission → Peephole Optimizer → Code Object
```

Each function, class body, module, and comprehension gets its own code object. Code objects contain: bytecode (`co_code`), constants (`co_consts`), variable names (`co_varnames`, `co_freevars`, `co_cellvars`), a line number table, exception handling table, and other metadata.

The `compile()` built-in exposes this pipeline:
```python
code = compile("x + 1", "<string>", "eval")  # Returns a code object
exec(code)                                      # Executes the code object
```

> **Sources:** Martelli et al (2023) Ch.14 pp. 429–441 · Shaw (2021) pp. 61–150 · [CPython Developer Guide — Compiler Design](https://devguide.python.org/internals/compiler/)

### Bytecode and the Evaluation Loop

Python bytecode is a **stack-based instruction set** executed by `ceval.c` — the core evaluation loop in CPython.

**Instruction format**: Since Python 3.6, each instruction uses exactly **2 bytes** (1 byte opcode + 1 byte argument). Extended arguments use `EXTENDED_ARG` prefix instructions. Since Python 3.11, instructions are accompanied by inline `CACHE` entries used by the specializing adaptive interpreter.

Key instruction categories:

| Category | Examples | Purpose |
|----------|----------|---------|
| Load/Store | `LOAD_FAST`, `STORE_FAST`, `LOAD_GLOBAL` | Move values between stack and variables |
| Arithmetic | `BINARY_ADD`, `BINARY_MULTIPLY` | Arithmetic operations |
| Control flow | `JUMP_FORWARD`, `POP_JUMP_IF_TRUE` | Branches and jumps |
| Function calls | `CALL_FUNCTION`, `RETURN_VALUE` | Method/function invocation |
| Object access | `LOAD_ATTR`, `STORE_ATTR` | Attribute access |
| Stack manipulation | `POP_TOP`, `DUP_TOP`, `ROT_TWO` | Stack operations |

The `dis` module disassembles bytecode:

```python
import dis

def add(a, b):
    return a + b

dis.dis(add)
# Output:
#   2           0 LOAD_FAST                0 (a)
#               2 LOAD_FAST                1 (b)
#               4 BINARY_ADD
#               6 RETURN_VALUE
```

The `Instruction` named tuple provides detailed information: `opcode`, `opname`, `arg`, `argval`, `offset`, `line_number`, `is_jump_target`, and `positions` (source line/column mapping).

The `dis` module provides: `dis.dis()` (disassemble functions/classes/modules), `dis.get_instructions()` (iterator of `Instruction` tuples), `dis.code_info()` (code object metadata), `dis.stack_effect()` (compute stack effect of an opcode), and the `dis.Bytecode` class for programmatic analysis.

**The evaluation loop internals** (`Python/ceval.c`) are the heart of CPython. Shaw describes the execution machinery in detail:

- **Thread state** (`PyThreadState`): Each OS thread running Python has a thread state object containing the current frame, exception state, and a pointer to the interpreter state. Thread states are linked in a per-interpreter list.
- **Frame objects** (`PyFrameObject`): Each function call creates a frame. A frame contains: a pointer to its code object, local variables array, the value stack, a pointer to the enclosing frame (forming a call chain), and the current bytecode instruction pointer. Closure variables use `co_freevars` (referencing enclosing scope) and `co_cellvars` (referenced by inner scope).
- **The value stack**: Bytecode instructions operate on a per-frame LIFO stack. `LOAD_FAST` pushes a local variable onto the stack; `BINARY_ADD` pops two values, adds them, and pushes the result. The maximum stack depth is computed at compile time (`co_stacksize`).
- **Frame execution cycle**: The main loop in `_PyEval_EvalFrameDefault()` fetches the next opcode, dispatches through a giant switch statement (or computed goto on supported platforms), executes the operation, and advances the instruction pointer. On every iteration, the loop checks for pending signals, thread switches (every 5ms by default), and async exceptions.

> **Sources:** Ramalho (2022) Ch.2 · Gorelick & Ozsvald (2020) Ch.2 pp. 21–45 · Shaw (2021) pp. 151–175 · [Python docs — `dis` module](https://docs.python.org/3/library/dis.html)

### .pyc Files and Caching

PEP 3147 (implemented in Python 3.2) introduced the `__pycache__/` directory and magic-tagged `.pyc` filenames.

**Problem**: Multiple Python versions sharing the same source files would fight over a single `.pyc` file, rewriting it each time because the magic number differs between versions.

**Solution**: `.pyc` files are stored in `__pycache__/` subdirectories with implementation-specific names:
```
mypackage/
├── __init__.py
├── module.py
└── __pycache__/
    ├── __init__.cpython-312.pyc
    ├── __init__.cpython-313.pyc
    ├── module.cpython-312.pyc
    └── module.pypy39.pyc          # PyPy can coexist
```

The `.pyc` file format: magic number (changes when bytecode format changes) + timestamp + source file size + marshalled code object.

Key rules:
- If the `.py` source is missing, `.pyc` files inside `__pycache__/` are **ignored** (prevents stale cache imports)
- Import still succeeds if `.pyc` cannot be written (read-only filesystems)
- Source-less distribution is supported when `.pyc` is placed where the `.py` would have been (outside `__pycache__/`)
- The magic tag is accessible via `sys.implementation.cache_tag`

> **Sources:** [PEP 3147](https://peps.python.org/pep-3147/) · [Python docs — `py_compile`](https://docs.python.org/3/library/py_compile.html)

### The Specializing Adaptive Interpreter (Python 3.11+)

PEP 659 introduced a **specializing, adaptive interpreter** that speculatively specializes bytecode instructions based on observed types, then de-specializes if assumptions are violated.

**How it works**:
1. Each specializable instruction (e.g., `LOAD_ATTR`) is first replaced by an **adaptive form** (`LOAD_ATTR_ADAPTIVE`)
2. After enough executions, the adaptive instruction attempts **specialization** based on observed types
3. Specialized instructions maintain a **saturating counter** — incremented on success, decremented on failure
4. If the counter reaches minimum, the instruction is **de-specialized** back to the adaptive form

**Specialization families — examples**:

| Generic Instruction | Specialized Forms | Condition |
|--------------------|-------------------|-----------|
| `LOAD_ATTR` | `LOAD_ATTR_INSTANCE_VALUE` | Attribute in object's value array, not shadowed |
| `LOAD_ATTR` | `LOAD_ATTR_MODULE` | Attribute from module dict |
| `LOAD_ATTR` | `LOAD_ATTR_SLOT` | Class with `__slots__` |
| `LOAD_GLOBAL` | `LOAD_GLOBAL_MODULE` | Value in globals dict |
| `LOAD_GLOBAL` | `LOAD_GLOBAL_BUILTIN` | Value in builtins, globals keys unchanged |
| `BINARY_ADD` | `BINARY_ADD_INT` | Both operands are integers |

Specialized instructions store extra data in **inline cache entries** (16-bit values immediately following the instruction in the bytecode stream). Unspecialized instructions skip over these caches.

**Performance impact**: Speedups of 10–60%, with the largest gains from attribute lookup, global variable access, and call specialization. Memory cost: about 6 bytes per instruction on 64-bit (vs. 2 bytes cold / 7.8 bytes hot in Python 3.10). This is the foundation for the PEP 744 JIT — it generates the profiling information that feeds more sophisticated optimizations.

> **Sources:** Gorelick & Ozsvald (2020) Ch.2 pp. 45–64 · [PEP 659](https://peps.python.org/pep-0659/)

### The GIL and Alternative Implementations

**The GIL (Global Interpreter Lock)** ensures only one thread executes Python bytecode at a time. It exists because CPython's memory management — **reference counting** — is not thread-safe. Every object has a reference count that is incremented/decremented on every assignment, function call, and scope exit. Without the GIL, concurrent threads would corrupt these counts.

**PEP 703 — Making the GIL Optional** (accepted, implementation in Python 3.13+):

The `--disable-gil` build flag produces a **free-threaded** CPython build (ABI tag includes "t"). Key changes required:

1. **Biased Reference Counting**: Most objects are accessed by a single thread (their "owner"). The owner uses non-atomic operations on a "local" reference count. Other threads use atomic operations on a "shared" reference count. Three fields per object: local refcount, shared refcount, owning thread ID. This avoids expensive atomic operations in the common single-threaded pattern.

2. **Immortalization**: Long-lived objects (`None`, `True`, `False`, small integers) are made immortal — their refcount is never modified, eliminating contention.

3. **Deferred Reference Counting**: Some objects (top-level module variables) defer refcount operations; the garbage collector periodically reconciles.

4. **Container Thread-Safety**: Dict and list operations use optimistic locking (try lock-free first, fall back to locks).

5. **`Py_mod_gil` Slot**: C extension modules declare GIL requirements. Non-thread-safe extensions can request the GIL be held.

**Subinterpreters** (PEP 554, experimental): CPython supports running multiple independent Python interpreters within a single OS process. Each subinterpreter has its own module namespace, import state, and — crucially — its own GIL. This enables true parallelism for Python code without the complexity of multiprocessing (no serialization overhead for communication). Shaw describes subinterpreters as a middle ground between threads (shared GIL) and processes (separate memory spaces). The `interpreters` module (Python 3.12+) exposes this capability, though it remains experimental with restrictions on sharing objects between interpreters.

**Alternative Python implementations**:

**PyPy** uses a **meta-tracing JIT** — it traces the RPython interpreter itself, not the user's Python program directly. The RPython toolchain translates RPython source into C code (via flow graphs and annotation), which is compiled to a native binary. The tracer records execution traces, the optimizer optimizes residual operations, and the backend generates native machine code. PyPy generally achieves 4–10x speedup over CPython for long-running programs. PyPy uses real GC (not reference counting) — the `incminimark` (incremental minimark) collector.

**Cython** compiles Python-like code to C for AOT compilation. You add type annotations to Python code, and Cython generates C extension modules that run at C speed:
```python
# Cython (.pyx file)
def f(double x):
    return x ** 2 - x
```

**Numba** JIT-compiles numeric Python functions via LLVM. Decorate functions with `@numba.jit` and Numba compiles them to optimized machine code at runtime, particularly effective for NumPy-heavy code.

**PEP 744 — JIT Compilation** (experimental, Python 3.13+):

A **copy-and-patch JIT** that uses pre-compiled code "stencils" (templates) generated at build time by Clang/LLVM. At runtime, templates are copied and patched with actual values to produce machine code.

Architecture:
1. Bytecode is specialized by the adaptive interpreter (PEP 659)
2. Hot bytecode traces are translated into sequences of **micro-ops**
3. Micro-ops are optimized (dead code elimination, constant propagation)
4. Optimized micro-ops are compiled to native code via copy-and-patch

Why copy-and-patch over LLVM: LLVM would add heavy runtime dependencies and high compilation overhead. Copy-and-patch requires ~900 lines of build-time Python + ~500 lines of runtime C. It eliminates dispatch overhead between micro-ops, instruction decoding overhead, and memory traffic. Must be enabled with `--enable-experimental-jit` at build time; not yet default.

> **Sources:** Ramalho (2022) Ch.19 pp. 695–742 · Gorelick & Ozsvald (2020) Ch.7 pp. 161–211 · Shaw (2021) pp. 221–283 · [PEP 703](https://peps.python.org/pep-0703/) · [PEP 744](https://peps.python.org/pep-0744/) · [PyPy documentation](https://doc.pypy.org/)

---

## 5. Runtime Systems Compared

### Memory Management

Three fundamentally different approaches to memory management, each with different tradeoffs for latency, throughput, and developer effort.

**Rust: Ownership and RAII (No GC)**

Rust has no garbage collector. Memory is freed **deterministically** when ownership is transferred or scope ends — this is RAII (Resource Acquisition Is Initialization). The compiler inserts drop calls (destructors) at precise points in the code, visible in MIR as explicit drop instructions.

Key mechanisms:
- **Stack allocation** is the default for local variables — fast allocation, automatic cleanup
- **Heap allocation** via `Box<T>`, `Vec<T>`, `String`, etc. — freed when the owning variable goes out of scope
- **Smart pointers**: `Rc<T>` (reference counting, single-threaded), `Arc<T>` (atomic reference counting, multi-threaded) for shared ownership
- **Custom allocators** can be specified for performance-critical code

The advantage: no GC pauses, predictable latency, minimal memory overhead (no GC metadata per object). The cost: the programmer must satisfy the borrow checker, which can be challenging for complex data structures.

**Java: Tracing Garbage Collection**

The JVM uses tracing garbage collection based on the **generational hypothesis**: most objects die young. Objects are allocated in a "young generation" area; survivors are promoted to an "old generation."

Available collectors (Java 21):

| Collector | Pause Model | Best For | Flag |
|-----------|------------|----------|------|
| **Serial** | Stop-the-world, single-threaded | Small heaps (< 100 MB) | `-XX:+UseSerialGC` |
| **Parallel** | Stop-the-world, multi-threaded | Throughput priority | `-XX:+UseParallelGC` |
| **G1** (default) | Mostly concurrent, regionalized | Balance of throughput and latency | `-XX:+UseG1GC` |
| **ZGC** | Fully concurrent | Ultra-low latency (< 1ms pauses) | `-XX:+UseZGC -XX:+ZGenerational` |

G1 divides the heap into ~2048 equal-sized regions. It collects regions with the most garbage first ("Garbage-First"). Young generation collection is always stop-the-world; mixed collections include some old-generation regions selected by priority.

ZGC provides sub-millisecond pause times regardless of heap size (tested up to 16 TB). Pauses are independent of heap size, live set size, and root set size. The tradeoff: slightly lower throughput than G1.

**Behavior-based tuning** (three goals):
1. **Maximum pause-time goal** (`-XX:MaxGCPauseMillis=200`): Limit longest GC pause
2. **Throughput goal** (`-XX:GCTimeRatio=19`): Target 5% total time in GC
3. **Footprint**: If both goals met, reduce heap until one fails

Amdahl's Law impact: 1% GC time on a single processor translates to >20% throughput loss at 32 processors.

**Thread-Local Allocation Buffers (TLABs)**: To avoid lock contention on Eden space, each thread gets its own **TLAB** — a private allocation region within the young generation. Object allocation within a TLAB is a simple pointer bump (no synchronization). When a TLAB is exhausted, the thread requests a new one. **Promotion-Local Allocation Buffers (PLABs)** serve the same purpose during GC — each GC thread gets a private buffer in the old generation to avoid contention when promoting surviving objects. TLABs are sized dynamically based on allocation rate and thread count.

**G1 internals**: G1 divides the heap into equally-sized **regions** (1–32 MB each, configurable with `-XX:G1HeapRegionSize`). Each region can be Eden, Survivor, Old, or Humongous (objects > 50% of region size). G1 tracks **remembered sets** per region to avoid scanning the entire heap during young collection. Mixed collections select old-generation regions based on a **garbage-first priority** — regions with the most reclaimable space are collected first. Key tuning parameters include `-XX:MaxGCPauseMillis` (target pause, default 200ms), `-XX:G1MixedGCCountTarget` (target number of mixed GCs), and `-XX:G1HeapWastePercent` (stop mixed GC when waste drops below threshold).

**ZGC architecture**: ZGC uses **colored pointers** — metadata is stored in unused bits of 64-bit object references (using multi-mapping of virtual memory). A **load barrier** intercepts every object reference load to check pointer color and perform any necessary remapping or marking. This design enables fully concurrent marking, relocation, and reference processing without stop-the-world pauses beyond a brief (< 1ms) root scanning phase. ZGC supports heap sizes from 8 MB to 16 TB. Since Java 21, ZGC is **generational** (`-XX:+ZGenerational`), applying the generational hypothesis for improved throughput.

**Shenandoah** is Red Hat's concurrent GC with a similar goal to ZGC — sub-millisecond pauses — but uses a **Brooks forwarding pointer** (an extra word per object) rather than colored pointers. **Epsilon** (`-XX:+UseEpsilonGC`) is a no-op collector that never reclaims memory — useful for ultra-short-lived processes, benchmarking GC overhead, and memory pressure testing.

**GC workload evaluation**: The optimal GC choice depends on the workload type. Beckwith categorizes: **OLTP** (many short transactions — latency-sensitive, G1 or ZGC), **OLAP** (batch analytical queries — throughput-sensitive, Parallel collector), and **HTAP** (mixed transactional + analytical — balanced, G1). Data lifespan patterns also matter — long-lived caches stress old-generation collection; request-scoped allocations die in young generation.

**Python: Reference Counting + Cycle Collector**

CPython uses **reference counting** as its primary memory management mechanism. Every object has a reference count (`ob_refcnt`). When the count drops to zero, the object is immediately deallocated. This provides deterministic destruction — objects are freed as soon as they become unreachable (similar to Rust's RAII for simple cases).

The weakness of reference counting: **circular references** (A references B, B references A) never reach zero. CPython supplements reference counting with a **cycle-detecting garbage collector** (`gc` module) that periodically searches for and collects reference cycles.

```python
import gc
gc.get_count()      # Objects in each generation
gc.collect()         # Force cycle collection
gc.get_threshold()   # Collection thresholds (700, 10, 10) by default
```

The cycle collector uses generational collection with three generations. New objects start in generation 0; surviving objects are promoted.

**CPython's memory allocator architecture** (Shaw) has three layered domains:

| Domain | Scope | Mechanism |
|--------|-------|-----------|
| **Raw** | General-purpose | Thin wrapper around `malloc`/`free` |
| **PyMem** | Python runtime | Used for non-object memory (buffers, internal arrays) |
| **Object** | Python objects | Specialized allocator for small objects (< 512 bytes) |

The **object domain allocator** organizes memory into **arenas** (256 KB chunks obtained from the OS), which contain **pools** (4 KB, matching the OS page size), which contain fixed-size **blocks** for objects of a specific size class. Size classes are 8-byte aligned from 8 to 512 bytes. This three-tier hierarchy minimizes `malloc` overhead for the millions of small objects a typical Python program creates. The **PyArena** allocator is a separate arena used specifically for compilation artifacts (AST nodes, symbol tables) — it allows bulk deallocation when compilation completes.

Reference counting uses `Py_INCREF(op)` and `Py_DECREF(op)` macros that directly manipulate the `ob_refcnt` field on every `PyObject`. When `ob_refcnt` reaches zero, the object's type-specific deallocator is called immediately. The cycle collector's generational algorithm uses three generations with configurable thresholds (default: 700, 10, 10) — generation 0 is collected when 700 more allocations than deallocations have occurred; generations 1 and 2 are collected after 10 collections of the previous generation.

> **Sources:** Matthews (2024) Ch.5 pp. 93–118 · McNamara (2021) Ch.6 pp. 175–211 · Evans et al (2022) Ch.7 pp. 207–230 · Oaks (2020) Ch.5–6 pp. 121–201 · Beckwith (2024) Ch.6 pp. 177–217 · Martelli et al (2023) Ch.14 pp. 436–441 · Shaw (2021) pp. 177–219 · [Oracle — GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/) · [Python docs — `gc` module](https://docs.python.org/3/library/gc.html)

### Startup Time and Warmup Behavior

| Metric | Rust | Java/JVM | Python/CPython |
|--------|------|----------|----------------|
| **Startup time** | Microseconds | 100ms–2s | 30–100ms |
| **Warmup needed** | None | Yes (seconds to minutes) | None |
| **Peak performance** | From first instruction | After JIT warmup | Immediate (but slow) |
| **What causes overhead** | N/A | JVM init, class loading, bytecode verification, JIT | Interpreter init, module imports |

**Rust**: Binaries start in microseconds — there is no runtime to initialize. The program begins executing `main()` immediately. This makes Rust ideal for CLI tools and serverless functions where cold-start latency matters.

**Java**: Beckwith describes the JVM lifecycle as four phases: **boot** (JVM process starts, loads core classes), **initialization** (application classes loaded, static initializers run), **ramp-up** (JIT compiling hot methods, profiling stabilizing), and **steady state** (peak performance reached, code caches warm). The time to steady state can be seconds for simple applications or minutes for complex frameworks — this is the "warmup" problem.

Mitigations for startup and warmup:
- **CDS/AppCDS**: Memory-maps pre-processed class metadata from shared archives. Multiple JVM processes share the same archive. Dynamic CDS automatically archives loaded classes at exit.
- **GraalVM Native Image**: Eliminates JVM startup entirely — the result is a native binary like Rust
- **CRIU and Project CRaC**: Checkpoint/Restore In Userspace (CRIU) snapshots a running JVM process to disk; restoring from checkpoint provides near-instant startup. **Project CRaC** (Coordinated Restore at Checkpoint) provides a Java API for applications to prepare for checkpoint (e.g., close network connections, flush buffers) and reinitialize on restore. This is particularly valuable for serverless platforms where cold-start latency directly impacts user experience.
- **Project Leyden** (future): Aims to progressively "condense" Java programs by shifting work from run time to earlier phases

**Python**: Moderate startup from interpreter initialization and `import` chains. Heavy frameworks (Django, NumPy) can add seconds of import time. Mitigations: `__pycache__/` avoids recompilation; lazy imports (`from __future__ import annotations`); `importlib.resources` for efficient resource loading.

> **Sources:** Beckwith (2024) Ch.8 pp. 273–306 · [Oracle — CDS](https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html) · [GraalVM — Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)

### Runtime Reflection and Introspection

**Python** has the richest runtime introspection. Everything is an object with a `__dict__`, and classes can be modified at runtime:
```python
type(obj)            # Runtime type
dir(obj)             # List attributes
getattr(obj, 'x')   # Dynamic attribute access
inspect.getsource(fn) # Source code of a function
```

You can add/remove methods from classes, modify inheritance hierarchies, and intercept attribute access — all at runtime. Code objects, frame objects, and traceback objects are all inspectable.

**Java** has extensive reflection (`java.lang.reflect`) but it is slower than direct access and constrained by the module system since Java 9:
```java
Class<?> cls = obj.getClass();
Method m = cls.getMethod("foo", String.class);
m.invoke(obj, "arg");
```

`MethodHandles` (Java 7+) provide a faster alternative — `MethodHandle` is a typed, directly executable reference that can be inlined by the JIT. The module system (`java.lang.Module`) restricts reflective access to non-exported packages by default.

**Rust** has essentially **no runtime reflection**. All type information is erased at compile time (except for the `Any` trait with `TypeId`, which provides basic type identification). This is a direct consequence of the AOT compilation model — the compiler has all the information, so the runtime does not need it. Procedural macros provide compile-time metaprogramming instead.

### Comparative Synthesis

| Aspect | Rust | Java/JVM | Python/CPython |
|--------|------|----------|----------------|
| **GC model** | None (ownership/RAII) | Tracing (generational) | Refcounting + cycle collector |
| **GC pause time** | Zero (no GC) | < 1ms (ZGC) to 100ms+ (Serial) | Negligible (small cycle collections) |
| **Startup time** | Microseconds | 100ms–2s | 30–100ms |
| **Warmup needed** | No | Yes (JIT) | No |
| **Peak throughput** | Native speed | Near-native (after warmup) | 10–100x slower |
| **Runtime reflection** | None (except `Any`) | Extensive (`java.lang.reflect`) | Full (everything is inspectable) |
| **Binary/deployment size** | 1–10 MB static binary | JRE: 50–200 MB; JAR: variable | Interpreter: ~15 MB + packages |
| **Deterministic destruction** | Yes (drop at scope end) | No (GC decides when) | Mostly (refcount = 0 → immediate free) |

The fundamental tradeoff: **Rust trades runtime flexibility for predictable performance**; **Java trades startup time for adaptive optimization**; **Python trades performance for maximum dynamism**.

> **Sources:** Evans et al (2022) Ch.17 pp. 571–590 · Martelli et al (2023) Ch.14 pp. 429–435 · Matthews (2024) Ch.5 pp. 93–118 · McNamara (2021) Ch.10 pp. 328–363 · Shaw (2021) pp. 221–283

### JVM Runtime Optimizations: Strings, Locks, and Virtual Threads

Beyond GC and JIT compilation, the HotSpot JVM applies several important runtime optimizations.

**String optimization** has evolved across Java versions. **Compact Strings** (Java 9+) changed `String` internals from `char[]` (UTF-16, 2 bytes per character) to `byte[]` with an encoding flag — Latin-1 strings use 1 byte per character, roughly halving memory for most strings. **String interning** (`String.intern()`) and the JVM's string constant pool deduplicate identical string literals. G1 GC offers **automatic string deduplication** (`-XX:+UseStringDeduplication`) that identifies duplicate `char[]`/`byte[]` arrays across the heap and shares them — Beckwith reports this can reduce heap usage by 10–25% in string-heavy applications.

**Lock evolution in HotSpot** uses an adaptive escalation strategy. When a `synchronized` block is entered, the JVM first attempts **biased locking** — if only one thread ever acquires the lock, it simply stores the thread ID with near-zero overhead. If a second thread contends, the lock **revokes bias** and escalates to a **thin lock** (CAS-based spinlock using the object header's mark word). If spin attempts fail (high contention), the lock escalates to a **fat lock** (OS mutex with thread parking). Java 15 deprecated biased locking by default, as modern concurrent code rarely benefits from it and the revocation cost is high. Post-Java 9, contention optimization improvements include adaptive spin-wait hints and refined lock escalation thresholds.

**Virtual threads** (Project Loom, Java 21+) are lightweight, JVM-managed threads that decouple the Java thread abstraction from OS threads. A virtual thread is mounted on a **carrier thread** (from a ForkJoinPool) only while it is executing CPU work. When a virtual thread blocks on I/O, the JVM unmounts it from the carrier — freeing the carrier to run another virtual thread. This enables millions of concurrent virtual threads on a handful of OS threads.

The transition from the traditional **thread-per-request** model (one OS thread per incoming request, limited to ~10K concurrent connections) to virtual threads eliminates the need for reactive/async programming patterns in many cases. Virtual threads make `Thread.sleep()`, `Socket.read()`, and `Lock.lock()` cheap — they block the virtual thread but not the carrier, maintaining the familiar synchronous programming model while achieving the scalability of async I/O.

> **Sources:** Beckwith (2024) Ch.7 pp. 219–270

---

## 6. Intermediate Representations & Optimization

### LLVM IR and Rust Optimizations

After `rustc` generates LLVM IR, LLVM applies dozens of **optimization passes**: dead code elimination, constant folding and propagation, loop unrolling, function inlining, auto-vectorization (SIMD), global value numbering, tail call elimination, and more.

Rust's **zero-cost abstractions** are enabled by the combination of monomorphization + LLVM inlining. Klabnik demonstrates that a `map().filter().collect()` iterator chain compiles to the same tight loop as a hand-written `for` loop:

```rust
// These two produce identical machine code:
let sum: u32 = (0..1000).filter(|n| n % 2 == 0).sum();

let mut sum = 0u32;
for n in 0..1000 {
    if n % 2 == 0 { sum += n; }
}
```

Because generics are monomorphized (each concrete type gets its own code copy), LLVM sees fully specialized code with no type abstraction overhead. It can then inline aggressively, turning chains of function calls into tight loops.

**Link-Time Optimization (LTO)** extends optimization across crate boundaries:
- **Fat LTO** (`lto = true`): Whole-program optimization; LLVM merges all code into one module before optimizing. Produces the fastest code at the cost of very slow compilation.
- **Thin LTO** (`lto = "thin"`): Similar benefit with parallel compilation; modules are analyzed together for cross-module inlining but compiled separately.

**Profile-Guided Optimization (PGO)**: Compile with instrumentation (`-Cprofile-generate`), run representative workloads to collect profiles, then recompile with profile data (`-Cprofile-use`). LLVM uses the profile to prioritize hot paths, improve branch prediction, and make better inlining decisions.

The Rust Playground (play.rust-lang.org) can show LLVM IR, MIR, and assembly output. Compiler Explorer (godbolt.org) provides interactive side-by-side comparison of source and generated assembly.

> **Sources:** Klabnik & Nichols (2023) Ch.13 pp. 273–294 · Matthews (2024) Ch.11 pp. 219–231 · [Rustc Dev Guide — Optimization](https://rustc-dev-guide.rust-lang.org/backend/optimization.html) · [LLVM — Passes](https://llvm.org/docs/Passes.html) · [Rust Playground](https://play.rust-lang.org/)

### JVM Bytecode and HotSpot Optimizations

The HotSpot C2 compiler performs **speculative optimizations** based on runtime profiling data. This is fundamentally different from Rust's static optimization — Java optimizes based on **actual runtime behavior**.

**Key C2 optimizations**:

**Devirtualization**: If a virtual call site (`invokevirtual`) always sees one type at runtime (monomorphic), C2 inlines that implementation directly. If it sees two types (bimorphic), C2 generates a type check with inlined fast paths. If it sees many types (megamorphic), C2 falls back to virtual dispatch. Profiling data from C1 identifies which case applies.

**Escape Analysis**: If an object doesn't escape a method (NoEscape), C2 can:
- **Scalar replace** the object — replace fields with local variables, eliminating the allocation entirely
- **Eliminate locks** on the object (if synchronized)
- **Remove redundant null checks**

Note: HotSpot does NOT do true stack allocation for non-escaping objects — it uses scalar replacement instead.

**Inlining**: C2 aggressively inlines small methods, guided by call frequency profiling. Method handles and lambdas (via `invokedynamic`) are inlined through their `CallSite` binding.

**Loop optimizations**: Unrolling, peeling, vectorization (auto-SIMD), range-check elimination within loop bounds.

**Deoptimization**: If a speculation is wrong (e.g., a monomorphic call site becomes polymorphic because a new class is loaded), the JVM can **deoptimize** — discard the compiled code and fall back to interpreted mode, then recompile with updated profiling. This is why Java can handle dynamic class loading without sacrificing performance in the common case.

**invokedynamic optimization**: Evans describes how string concatenation was migrated from `StringBuilder` chains to `invokedynamic` (Java 9+). The bootstrap method chooses the optimal concatenation strategy at runtime — potentially using `byte[]` instead of `char[]`, pre-sizing buffers, or using specialized fast paths for common patterns. The JIT then inlines the result.

> **Sources:** Evans et al (2022) Ch.7 pp. 230–246, Ch.17 pp. 590–607 · Oaks (2020) Ch.4 pp. 89–120 · Beckwith (2024) Ch.7 pp. 219–270 · [OpenJDK — C2 Compiler](https://wiki.openjdk.org/display/HotSpot/C2)

### Python Bytecode and Limited Optimization

CPython performs **almost no bytecode optimization**. There is a peephole optimizer that does constant folding and dead code removal, but no inlining, no loop unrolling, no devirtualization. The dynamic nature of Python makes most traditional optimizations unsound — any attribute could be overridden, any name could be rebound, and even built-in operations could be replaced.

**The specializing adaptive interpreter** (PEP 659, Python 3.11+) is CPython's first step toward runtime optimization:

```
Generic instruction → Adaptive form → Specialized form (if types stable)
                                    → De-specialized (if types change)
```

Speedups of 10–60%, with largest gains from:
- Attribute lookup: `LOAD_ATTR_INSTANCE_VALUE` skips dict lookup for objects with consistent layout
- Global access: `LOAD_GLOBAL_BUILTIN` only checks that global keys haven't changed
- Binary operations: `BINARY_ADD_INT` avoids type dispatch for integer addition

**PyPy's tracing JIT** goes much further. It records and optimizes entire execution traces — sequences of operations that span multiple bytecode instructions and function calls. When a trace is "hot" (executed many times), PyPy compiles it to native code. Because it traces the interpreter itself (meta-tracing), it can eliminate interpreter overhead entirely for hot paths. PyPy achieves 4–10x speedup over CPython for computation-heavy code.

**The copy-and-patch JIT** (PEP 744, Python 3.13+) bridges the gap: it compiles optimized micro-op traces into native code using pre-compiled templates. It eliminates dispatch overhead between micro-ops, instruction decoding, and moves data from heap-allocated frames into hardware registers. It's less powerful than a full JIT (like PyPy's) but much simpler to implement and maintain.

### Side-by-Side IR Comparison

Using [Compiler Explorer (godbolt.org)](https://godbolt.org/), you can compare the output for a simple "sum of array" function:

**Rust** (with `-O`): Produces tight vectorized assembly — the loop is auto-vectorized with SIMD instructions, processing 4–8 elements per iteration. The `Iterator::sum()` call compiles away completely.

**Java bytecode** (via `javap -c`): Shows stack-based bytecodes (`iload`, `iadd`, `iinc`, `goto`). At runtime, HotSpot C2 would produce similar vectorized assembly after warmup.

**Python bytecodes** (via `dis.dis`): Shows interpreter instructions (`LOAD_FAST`, `BINARY_ADD`, `STORE_FAST`). Each instruction dispatches through the C evaluation loop — no native code generation in standard CPython.

**IR depth hierarchy**:

| Language | Compilation Stages |
|----------|-------------------|
| **Rust** | Source → AST → HIR → THIR → MIR → LLVM IR → Assembly → Machine Code |
| **Java** | Source → AST → Bytecode → Interpreted / C1 Assembly / C2 Assembly |
| **Python** | Source → AST → CFG → Bytecode → Interpreted (adaptive/specialized) |

> **Sources:** Gorelick & Ozsvald (2020) Ch.2 pp. 45–64 · Shaw (2021) pp. 118–150 · [PEP 659](https://peps.python.org/pep-0659/) · [Compiler Explorer](https://godbolt.org/)

---

## 7. WebAssembly, GraalVM & Linking Models

### Rust and WebAssembly

Rust has first-class WebAssembly support. WASM is a portable, compact binary format designed to execute at near-native speeds in a sandboxed environment.

```bash
rustup target add wasm32-unknown-unknown
cargo build --target wasm32-unknown-unknown --release
```

**WebAssembly fundamentals**: WASM defines a simple machine model with a stack-based instruction set, linear memory (a flat byte array grown in 64K page increments), and strong sandboxing (no direct access to the host system). Two representations: `.wat` (text, S-expression based) and `.wasm` (binary). WASM is formally specified with validation rules that ensure type safety and memory safety. The spec is layered: Core Specification (host-independent), JavaScript Embedding, Web Embedding, and Code Metadata.

**Why Rust for WASM**: Rust compiles to small `.wasm` binaries because it has no runtime or garbage collector — you only pay for functions you actually use. Rust provides low-level control over memory layout, indirection, and monomorphization. The toolchain:

- **wasm-pack**: Builds Rust code as WASM packages for npm
- **wasm-bindgen**: Generates JavaScript ↔ Rust FFI bindings
- **web-sys/js-sys**: Rust bindings to Web APIs and JavaScript built-ins

```rust
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```

WASM is not just for browsers. Runtimes like **Wasmtime** and **Wasmer** execute WASM outside the browser for server-side sandboxed execution. **WASI (WebAssembly System Interface)** provides standardized system call access.

> **Sources:** [Rust and WebAssembly book](https://rustwasm.github.io/docs/book/) · [wasm-bindgen](https://rustwasm.github.io/wasm-bindgen/) · [WebAssembly Specification](https://webassembly.github.io/spec/) · [WebAssembly MDN Guide](https://developer.mozilla.org/en-US/docs/WebAssembly)

### GraalVM: Polyglot Runtime

GraalVM extends the compilation story beyond single-language optimization through the **Truffle framework** — an open-source framework for building language implementations as interpreters on **self-modifying Abstract Syntax Trees**.

Combined with the Graal compiler, Truffle automatically derives high-performance native code from AST interpreters via **partial evaluation**: the Graal compiler partially evaluates the interpreter with respect to the program being run, effectively producing a compiled version of that specific program.

Key optimization techniques:
- **Specialization**: DSL-based, automatically generates specialized node implementations for observed types
- **Monomorphization (Splitting)**: Splits polymorphic call sites into monomorphic specialized versions
- **On-Stack Replacement (OSR)**: Transitions from interpreted to compiled code mid-execution (e.g., inside a hot loop)
- **Cross-language inlining**: Function calls across language boundaries can be inlined by the JIT

**Polyglot interoperability**: Languages built on Truffle can interoperate seamlessly. A JavaScript program can call a Python function which calls a Ruby function, all within the same VM, sharing objects directly (no serialization, no IPC).

Truffle languages in production: GraalJS (JavaScript), GraalPython (Python), TruffleRuby (Ruby), FastR (R), Sulong (LLVM bitcode — enabling C/C++/Rust), GraalWasm (WebAssembly).

**Pyodide** takes a different approach to running Python in WASM: it compiles the entire CPython interpreter to WebAssembly using the Emscripten toolchain. Python code executes in the browser with no server-side component. It supports many packages with C/C++/Rust extensions (NumPy, pandas, SciPy, scikit-learn). It provides robust bidirectional JavaScript-Python FFI with async/await interop. Limitations include no native threading, virtualized filesystem, and ~10+ MB WASM binary for the CPython runtime.

> **Sources:** [GraalVM — Truffle](https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/) · [GraalVM — Native Image](https://www.graalvm.org/latest/reference-manual/native-image/) · [Pyodide](https://pyodide.org/)

### Linking Models: Static vs. Dynamic

How each language connects compiled code together and interfaces with native libraries.

**Rust: Static by default**

Rust defaults to **static linking** for Rust dependencies — the final binary contains all Rust code. System libraries (libc) are dynamically linked by default. With musl, full static linking produces completely self-contained binaries:

```bash
# Fully static binary — no dynamic library dependencies
cargo build --release --target x86_64-unknown-linux-musl
```

For interfacing with C libraries, Rust provides **FFI** (Foreign Function Interface) through `extern` blocks. The `unsafe` keyword is required because the compiler cannot verify safety of foreign code:

```rust
extern "C" {
    fn strlen(s: *const c_char) -> usize;
}
```

The `cdylib` crate type produces shared libraries loadable from C, Python, or any language supporting C ABIs.

**Java: JNI → Foreign Function & Memory API**

Java historically used **JNI (Java Native Interface)** for native interop — a complex, error-prone API requiring native "glue code" in C:

```java
// Java side
public class MyLib {
    static { System.loadLibrary("mylib"); }
    public native int add(int a, int b);
}
```
```c
// C side (must match exact JNI naming convention)
JNIEXPORT jint JNICALL Java_MyLib_add(JNIEnv *env, jobject obj, jint a, jint b) {
    return a + b;
}
```

**JEP 454 — Foreign Function & Memory API** (final in JDK 22) replaces JNI with a pure-Java API:

```java
// Pure Java — no native glue code
Linker linker = Linker.nativeLinker();
SymbolLookup stdlib = linker.defaultLookup();
MethodHandle strlen = linker.downcallHandle(
    stdlib.find("strlen").orElseThrow(),
    FunctionDescriptor.of(JAVA_LONG, ADDRESS)
);
```

Key FFM API abstractions:

| Component | Purpose |
|-----------|---------|
| `MemorySegment` | Contiguous memory region (native, mapped, array-backed) |
| `Arena` | Controls allocation, deallocation, and lifetime of segments |
| `MemoryLayout` | Declarative description of memory structure |
| `Linker` | Creates downcall handles (Java→native) and upcall stubs (native→Java) |
| `SymbolLookup` | Finds symbol addresses in native libraries |

Safety model: spatial bounds (valid address range) and temporal bounds (lifetime tied to Arena). Access after deallocation throws an exception. Unsafe operations (downcall handles, `reinterpret`) are restricted — `--enable-native-access=<module>` is required.

The FFM API is JIT-optimized end-to-end and supports passing/returning C structs by value (JNI cannot).

**Python: ctypes/cffi and Extension Modules**

Python provides multiple mechanisms for native interop:

```python
# ctypes — dynamic binding to shared libraries
from ctypes import cdll, c_char_p, c_size_t
libc = cdll.LoadLibrary("libc.so.6")
libc.strlen.restype = c_size_t
libc.strlen.argtypes = [c_char_p]
libc.strlen(b"hello")  # Returns 5
```

**cffi** provides a more Pythonic API with inline C declarations. **CPython extension modules** (`.so`/`.pyd` files) are compiled C code that links against the CPython API — this is what NumPy, pandas, and cryptography use internally.

**PyO3** bridges Rust and Python directly:
```rust
use pyo3::prelude::*;

#[pyfunction]
fn sum_as_string(a: usize, b: usize) -> String {
    (a + b).to_string()
}

#[pymodule]
fn my_module(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(sum_as_string, m)?)?;
    Ok(())
}
```

PyO3 is used by Pydantic v2, Polars, Ruff, and cryptography to expose Rust code as Python modules. The `maturin` tool builds and publishes PyO3 packages.

### Linking Model Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Default model** | Static (Rust deps) + dynamic (system libs) | Dynamic (class loading at runtime) | Dynamic (import at runtime) |
| **Fully static option** | Yes (musl target) | Yes (GraalVM native-image) | No (needs interpreter) |
| **Native interop** | `extern "C"` + FFI | JNI (legacy) / FFM API (modern) | ctypes / cffi / C extensions |
| **Deployment unit** | Single binary (1–10 MB) | JAR + JVM (50–200 MB) | Source/wheel + interpreter (~15 MB) |
| **Cross-language bridge** | PyO3 (Python), wasm-bindgen (JS) | FFM API, GraalVM polyglot | PyO3 (Rust), ctypes (C) |

### Exotic Hardware and Accelerators

Beckwith explores the emerging frontier of JVM integration with specialized hardware — GPUs, FPGAs, and vector processors.

**TornadoVM** is a specialized JVM that automatically offloads annotated Java code to GPUs and FPGAs via OpenCL or PTX backends. It intercepts bytecode at runtime, builds a parallel task graph, and generates hardware-specific kernels — enabling GPU acceleration without leaving Java.

**Project Panama's Vector API** (incubating) provides portable SIMD (Single Instruction, Multiple Data) operations in Java. The Vector API maps to hardware vector registers (AVX-512, ARM NEON) and allows explicit data-parallel programming:
```java
var a = FloatVector.fromArray(SPECIES_256, arrayA, i);
var b = FloatVector.fromArray(SPECIES_256, arrayB, i);
var c = a.mul(b).add(a);  // Fused multiply-add, 8 floats at once
c.intoArray(result, i);
```

Earlier efforts include **Aparapi** (translating Java bytecode to OpenCL at runtime) and **Project Sumatra** (transparently offloading Stream operations to GPUs). These demonstrated the potential but were limited by the impedance mismatch between Java's object model and GPU programming. **Project Panama** represents the current approach — providing low-level memory access and foreign function calls that enable idiomatic Java wrappers around native GPU libraries (CUDA, OpenCL) without JNI overhead.

> **Sources:** Beckwith (2024) Ch.9 pp. 307–336

### Cross-Language Interop and Future Directions

The boundaries between languages are increasingly blurred:

- **PyO3** lets Rust code expose Python modules — Pydantic v2, Polars, Ruff all use this pattern
- **GraalVM's polyglot engine** allows Java, Python, JavaScript, and Ruby to share objects in the same process, with cross-language inlining
- **WebAssembly** serves as a universal compilation target — WASM Interface Types aim to enable cross-language component composition without serialization
- **Java's FFM API** (JEP 454) replaces JNI with a safe, JIT-optimized, pure-Java foreign function interface

The trend is toward **compilation-time interop** (Rust→Python via PyO3, Rust→WASM→JS) rather than runtime interop (JNI, ctypes). Compilation-time binding eliminates IPC overhead and enables the optimizer to inline across language boundaries.

> **Sources:** Matthews (2024) Ch.2 pp. 33–37 · McNamara (2021) Ch.12 pp. 390–417 · Blandy & Orendorff (2017) Ch.21 pp. 525–583 · Horstmann (2024) Vol. II Ch.13 pp. 160–174 · [Rust Reference — Linkage](https://doc.rust-lang.org/reference/linkage.html) · [JEP 454](https://openjdk.org/jeps/454) · [PyO3](https://pyo3.rs/) · [Pyodide](https://pyodide.org/)

---

## Sources

### Books (local)

| Book | Relevant Sections | Path |
|------|-------------------|------|
| Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.1 pp. 1–11, Ch.10 (Generics/Monomorphization), Ch.13 pp. 273–294 | `books/Rust/Klabnik Nichols 2023 The Rust programming language.pdf` |
| Blandy & Orendorff (2017) — *Programming Rust* | Ch.1 pp. 1–5, Ch.8 pp. 161–191, Ch.11 pp. 235–263, Ch.21 pp. 525–583 | `books/Rust/Blandy Orendorff 2017 Programming Rust.pdf` |
| Matthews (2024) — *Code Like a Pro in Rust* | Ch.2 pp. 11–42, Ch.3 pp. 43–62, Ch.5 pp. 93–118, Ch.11 pp. 219–231 | `books/Rust/Matthews 2024 Code like a pro in Rust.pdf` |
| Horstmann (2024) — *Core Java, Vol. I* | Ch.1, Ch.2 pp. 33–40 | `books/Java/Horstmann 2024 Core Java. I Fundamentals.pdf` |
| Horstmann (2024) — *Core Java, Vol. II* | Ch.8 pp. 114–118, Ch.9 pp. 120–126, Ch.11 pp. 140–148, Ch.13 pp. 160–174 | `books/Java/Horstmann 2024 Core Java. II Advanced features.pdf` |
| Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.4 pp. 81–117, Ch.7 pp. 207–246, Ch.17 pp. 571–607 | `books/Java/Evans et al 2022 The well-grounded Java developer.pdf` |
| Bloch (2018) — *Effective Java* | Generics chapters (type erasure) | `books/Java/Bloch 2018 Effective Java.pdf` |
| Valeev (2024) — *100 Java Mistakes* | Ch.1 pp. 1–18 | `books/Java/Valeev 2024 100 Java mistakes.pdf` |
| Martelli et al (2023) — *Python in a Nutshell* | Ch.1 pp. 1–19, Ch.2 pp. 21–31, Ch.14 pp. 429–441 | `books/Python/Martelli et al 2023 Python in a nutshell.pdf` |
| Ramalho (2022) — *Fluent Python* | Ch.2, Ch.19 pp. 695–742 | `books/Python/Ramalho 2022 Fluent Python.pdf` |
| Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.1 pp. 1–20, Ch.2 pp. 21–64, Ch.7 pp. 161–211 | `books/Python/Gorelick, Ozsvald 2020 High performance Python.pdf` |
| McNamara (2021) — *Rust in Action* | Ch.5 pp. 137–173, Ch.6 pp. 175–211, Ch.10 pp. 328–363, Ch.11 pp. 365–387, Ch.12 pp. 390–417 | `books/Rust/McNamara 2021 Rust in Action.pdf` |
| Oaks (2020) — *Java Performance* | Ch.2 pp. 15–48, Ch.3 pp. 49–88, Ch.4 pp. 89–120, Ch.5 pp. 121–152, Ch.6 pp. 153–201 | `books/Java/Oaks 2020 Java performance.pdf` |
| Beckwith (2024) — *JVM Performance Engineering* | Ch.1 pp. 1–42, Ch.5 pp. 115–175, Ch.6 pp. 177–217, Ch.7 pp. 219–270, Ch.8 pp. 273–306, Ch.9 pp. 307–336 | `books/Java/Beckwith 2024 JVM performance engineering.pdf` |
| Shaw (2021) — *CPython Internals* | pp. 42–60, 61–74, 91–150, 151–175, 177–219, 221–283 | `books/Python/Shaw 2020 CPython internals.pdf` |

### External Resources

**Rust**
- [Rustc Dev Guide — Overview of the Compiler](https://rustc-dev-guide.rust-lang.org/overview.html)
- [Rustc Dev Guide — HIR](https://rustc-dev-guide.rust-lang.org/hir.html)
- [Rustc Dev Guide — MIR](https://rustc-dev-guide.rust-lang.org/mir/index.html)
- [Rustc Dev Guide — Monomorphization](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html)
- [Rustc Dev Guide — Borrow Checker](https://rustc-dev-guide.rust-lang.org/borrow_check.html)
- [Rustc Dev Guide — Code Generation (LLVM Backend)](https://rustc-dev-guide.rust-lang.org/backend/codegen.html)
- [Rustc Dev Guide — Optimization Passes](https://rustc-dev-guide.rust-lang.org/backend/optimization.html)
- [Rust Blog — Introducing MIR (2016)](https://blog.rust-lang.org/2016/04/19/MIR.html)
- [Rust Reference — Linkage](https://doc.rust-lang.org/reference/linkage.html)
- [Cargo Book — Build Profiles](https://doc.rust-lang.org/cargo/reference/profiles.html)
- [Rust and WebAssembly book](https://rustwasm.github.io/docs/book/)
- [wasm-bindgen](https://rustwasm.github.io/wasm-bindgen/)
- [wasm-pack](https://rustwasm.github.io/wasm-pack/)
- [LLVM Language Reference](https://llvm.org/docs/LangRef.html)
- [LLVM Passes](https://llvm.org/docs/Passes.html)
- [Rust Playground](https://play.rust-lang.org/)

**Java**
- [JVM Specification Ch.1 — Introduction](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-1.html)
- [JVM Specification Ch.2 — Structure of the JVM](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html)
- [JVM Specification Ch.4 — The class File Format](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html)
- [JVM Specification Ch.5 — Loading, Linking, Initializing](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html)
- [JVM Specification Ch.6 — Instruction Set](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html)
- [Oracle — HotSpot VM Performance Enhancements](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)
- [Oracle — GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/)
- [Oracle — Class Data Sharing](https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html)
- [GraalVM — Compiler](https://www.graalvm.org/latest/reference-manual/java/compiler/)
- [GraalVM — Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)
- [GraalVM — Truffle Framework](https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/)
- [JEP 295 — Ahead-of-Time Compilation](https://openjdk.org/jeps/295)
- [JEP 454 — Foreign Function & Memory API](https://openjdk.org/jeps/454)
- [OpenJDK — C2 Compiler](https://wiki.openjdk.org/display/HotSpot/C2)

**Python**
- [CPython Developer Guide — Compiler Design](https://devguide.python.org/internals/compiler/)
- [Python docs — `dis` module](https://docs.python.org/3/library/dis.html)
- [Python docs — `gc` module](https://docs.python.org/3/library/gc.html)
- [Python docs — `compile()` built-in](https://docs.python.org/3/library/functions.html#compile)
- [Python docs — `ast` module](https://docs.python.org/3/library/ast.html)
- [PEP 3147 — PYC Repository Directories](https://peps.python.org/pep-3147/)
- [PEP 659 — Specializing Adaptive Interpreter](https://peps.python.org/pep-0659/)
- [PEP 703 — Making the GIL Optional](https://peps.python.org/pep-0703/)
- [PEP 744 — JIT Compilation](https://peps.python.org/pep-0744/)
- [PyPy documentation](https://doc.pypy.org/)
- [Cython documentation](https://cython.readthedocs.io/)
- [Numba documentation](https://numba.readthedocs.io/)
- [PyO3](https://pyo3.rs/)
- [Pyodide](https://pyodide.org/)

**General**
- [Compiler Explorer (Godbolt)](https://godbolt.org/)
- [WebAssembly Specification](https://webassembly.github.io/spec/)
- [WebAssembly MDN Guide](https://developer.mozilla.org/en-US/docs/WebAssembly)
- [LLVM Documentation Hub](https://llvm.org/docs/)

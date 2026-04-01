# Layer 6 · Topic 17 — Performance Characteristics

> How each language's execution model — Rust's AOT compilation via LLVM with zero-cost abstractions, Java's tiered JIT compilation with profile-guided optimization, and Python's CPython interpreter with bytecode dispatch — produces fundamentally different performance profiles across startup time, steady-state throughput, memory footprint, and parallel scalability. Builds on compilation (Topic 3), memory (Topic 5), and concurrency (Topic 12) to reason about performance holistically.

---

## 1. Execution Model Fundamentals

The three languages occupy fundamentally different positions on the performance spectrum. Rust compiles ahead-of-time (AOT) to native machine code via LLVM, achieving peak performance from the first instruction. Java starts by interpreting bytecode and progressively JIT-compiles hot methods through tiered compilation. CPython interprets bytecode through an evaluation loop, paying per-instruction dispatch overhead for every operation.

### Rust: AOT Compilation and Zero-Cost Abstractions

Rust compiles to native machine code via LLVM ahead of time. The "zero-cost abstraction" principle means that high-level constructs — iterators, closures, trait dispatch, generics — compile down to code that is as efficient as hand-written low-level equivalents. The cost is paid at compile time (longer builds, larger binaries from monomorphization) rather than at runtime.

Monomorphization eliminates generic overhead at compile time by generating specialized code for each concrete type. `Vec<i32>` and `Vec<String>` become distinct types with distinct optimized code. The LLVM backend applies aggressive optimizations: inlining, loop unrolling, autovectorization, dead code elimination, constant propagation.

```rust
// These two produce identical machine code — zero-cost abstraction proof
// Iterator chain version
fn sum_doubled_positives_iter(v: &[i32]) -> i32 {
    v.iter()
        .filter(|&&x| x > 0)
        .map(|&x| x * 2)
        .sum()
}

// Hand-written loop version
fn sum_doubled_positives_loop(v: &[i32]) -> i32 {
    let mut total = 0;
    for &x in v {
        if x > 0 {
            total += x * 2;
        }
    }
    total
}
```

The LLVM backend compiles the iterator chain into a single loop with no function call overhead, no allocation, and no dynamic dispatch — identical to the hand-written version.

For example, calling `largest` with `i32` and `f64` slices produces two fully specialized functions:

```rust
// This generic function...
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    for item in &list[1..] {
        if item > largest {
            largest = item;
        }
    }
    largest
}

// ...becomes two separate, fully specialized functions at compile time:
// largest::<i32>  — specialized comparison for i32
// largest::<f64>  — specialized comparison for f64
```

> **Sources:** Klabnik & Nichols (2023) Ch.13 pp. 273–294 · Blandy & Orendorff (2017) Ch.11 pp. 235–263 · Gjengset (2022) Ch.11 pp. 193–209 · Matthews (2024) Ch.11 pp. 219–222 · [Rust Reference — Codegen attributes](https://doc.rust-lang.org/reference/attributes/codegen.html) · [LLVM — Optimization Passes](https://llvm.org/docs/Passes.html)

### Java: Tiered JIT Compilation and Profile-Guided Optimization

Java uses a fundamentally different performance strategy. The JVM starts by interpreting bytecode, then progressively compiles hot methods through tiered compilation:

- **Tier 0** — Interpreter. All code starts here. 5–10x slower than compiled code.
- **Tiers 1–3** — C1 (client) compiler with increasing levels of profiling instrumentation. Generates moderately optimized code quickly while collecting runtime profiles.
- **Tier 4** — C2 (server) compiler. Maximum optimization guided by profiling data from earlier tiers. Produces code competitive with AOT compilers.

```java
// The JIT compiler optimizes this based on runtime behavior
public class JitDemo {
    interface Shape { double area(); }

    static class Circle implements Shape {
        final double radius;
        Circle(double r) { this.radius = r; }
        public double area() { return Math.PI * radius * radius; }
    }

    // If the JIT observes that 'shape' is always a Circle (monomorphic call site),
    // it inlines Circle.area() directly — eliminating virtual dispatch entirely.
    // If a new Shape subtype appears later, the JIT deoptimizes and recompiles.
    static double computeArea(Shape shape) {
        return shape.area();
    }
}
```

Profile-guided optimization (PGO) enables optimizations that AOT compilers cannot easily perform:

- **Speculative inlining** — if a virtual call always dispatches to one implementation, inline it directly
- **Escape analysis** — if an object never escapes the method, allocate it on the stack or eliminate it entirely
- **Uncommon trap deoptimization** — optimize for the common case, bail out if assumptions are violated
- **On-stack replacement (OSR)** — replace a running interpreted method with its compiled version mid-execution

The trade-off: Java pays a warmup cost (thousands of invocations before a method reaches peak performance) but can potentially match or exceed AOT performance for long-running applications because it optimizes based on actual runtime behavior.

> **Sources:** Beckwith (2024) Ch.1 pp. 1–42 · Oaks (2020) Ch.4 pp. 89–120 · Evans et al (2022) Ch.7 pp. 207–230 · [Oracle — JVM Performance Enhancements](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html) · [Aleksey Shipilev — JVM Anatomy Quarks](https://shipilev.net/jvm/anatomy-quarks/)

### Python: Interpreter Overhead and the Evaluation Loop

CPython is the slowest execution model of the three by a significant margin. Source code is compiled to bytecode (`.pyc` files), which is then interpreted by the evaluation loop (`ceval.c`). Each bytecode instruction requires: fetching the opcode, dispatching through a switch statement (or computed goto), manipulating the value stack, and updating the instruction pointer.

```python
import dis

def add_numbers(a, b):
    return a + b

dis.dis(add_numbers)
# Output:
#   0 RESUME                   0
#   2 LOAD_FAST                0 (a)
#   4 LOAD_FAST                1 (b)
#   6 BINARY_OP                0 (+)
#  10 RETURN_VALUE
#
# Even a simple addition requires 4 bytecode dispatches.
# Each dispatch involves type checking (is 'a' an int? a float? a string?),
# method lookup (__add__), and object allocation for the result.
```

The dynamic typing tax is severe: the interpreter cannot know at compile time that `a + b` means integer addition, so it must check types at runtime for every operation. Every integer is a heap-allocated `PyObject` with a 28-byte minimum size.

CPython 3.11 introduced the **specializing adaptive interpreter**: hot bytecodes are specialized based on observed types (e.g., `BINARY_OP` becomes `BINARY_OP_ADD_INT` after seeing integer operands), reducing dispatch overhead by 10–25%. CPython 3.13 introduced an experimental **copy-and-patch JIT compiler** (PEP 744) that compiles specialized bytecodes to machine code, though gains are still modest compared to Java's JIT.

Even specialized CPython is typically **10–100x slower** than equivalent Rust or Java for CPU-bound computation.

> **Sources:** Shaw (2021) Ch.5 pp. 151–175 · Gorelick & Ozsvald (2020) Ch.1 pp. 1–20 · [PEP 744 — JIT Compilation](https://peps.python.org/pep-0744/) · [Faster CPython project](https://github.com/faster-cpython/ideas) · [Python docs — `dis` module](https://docs.python.org/3/library/dis.html) · [PyPy — Architecture](https://doc.pypy.org/en/latest/architecture.html)

### Cross-Language Comparison: The Performance Spectrum

| Aspect | Rust | Java | Python (CPython) |
|--------|------|------|------------------|
| **Compilation** | AOT via LLVM | Tiered JIT (C1/C2) | Bytecode interpretation |
| **Peak performance** | From first instruction | After warmup (seconds–minutes) | Never reaches native speed |
| **Optimization basis** | Static analysis | Runtime profiling (PGO) | Minimal (specializing interpreter) |
| **Abstraction cost** | Zero (monomorphization) | Near-zero after JIT | Per-instruction dispatch overhead |
| **Typical CPU-bound speed** | 1x (baseline) | 1–3x slower | 10–100x slower |
| **Adaptive optimization** | No (fixed at compile time) | Yes (deoptimize + reoptimize) | Limited (CPython 3.11+ specialization) |

Rust achieves peak performance from the first instruction but cannot adapt to runtime behavior. Java starts slow but reaches competitive peak performance after warmup, with the unique advantage of runtime profile-guided optimization. Python has the slowest baseline but compensates through C extensions (NumPy, Polars), alternative runtimes (PyPy achieves 5–10x speedup), and compilation tools (Cython, Numba). The choice of language rarely determines application performance for most real-world systems — algorithm selection, I/O patterns, and architecture matter more than the execution model.

> **Sources:** Oaks (2020) Ch.1 pp. 1–13 · Matthews (2024) Ch.11 pp. 219–222

---

## 2. Benchmarking Methodology

Rigorous benchmarking requires understanding each language's pitfalls: dead code elimination and constant folding in Rust, JIT warmup artifacts and GC pauses in Java, and import/GC overhead in Python.

### Rust: Criterion and `cargo bench`

Rust benchmarking faces the challenge that LLVM is extremely aggressive at eliminating "useless" computation. `std::hint::black_box()` prevents the compiler from optimizing away benchmark computations.

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        n => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| {
        b.iter(|| fibonacci(black_box(20)))
        //                   ^^^^^^^^^
        // Without black_box, LLVM might compute fibonacci(20)
        // at compile time and eliminate the entire function call
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

Criterion.rs handles warmup, outlier detection, and significance testing automatically. It runs benchmarks multiple times, performs statistical analysis (confidence intervals, regression detection), and produces HTML reports with comparison against previous runs.

Main measurement pitfalls in Rust:
1. **Dead code elimination** without `black_box` — LLVM removes unused computation
2. **Constant folding** if inputs are compile-time constants
3. **CPU frequency scaling** (turbo boost) affecting reproducibility
4. **Memory allocator variability** between runs

Unlike Java, Rust has no JIT warmup concern — the first run is representative of steady-state performance.

> **Sources:** Bos (2023) Ch.9 pp. 181–211 · Matthews (2024) Ch.11 pp. 219–231 · [Criterion.rs documentation](https://bheisler.github.io/criterion.rs/book/) · [`cargo bench` documentation](https://doc.rust-lang.org/cargo/commands/cargo-bench.html) · [`std::hint::black_box`](https://doc.rust-lang.org/std/hint/fn.black_box.html)

### Java: JMH and the Science of JVM Benchmarking

JVM benchmarking is notoriously difficult because the JIT compiler actively undermines naive benchmarks. JMH (Java Microbenchmark Harness), developed by the OpenJDK team, is the only reliable way to benchmark JVM code.

```java
import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;

@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Warmup(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 10, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(3) // Fork 3 separate JVMs to prevent profile pollution
@State(Scope.Thread)
public class SortBenchmark {

    @Param({"100", "1000", "10000"})
    private int size;

    private int[] data;

    @Setup(Level.Invocation)
    public void setup() {
        data = new java.util.Random(42).ints(size).toArray();
    }

    @Benchmark
    public int[] benchmarkSort() {
        java.util.Arrays.sort(data);
        return data; // Return value prevents dead code elimination
    }
}
```

JMH addresses multiple hazards:

| Hazard | How JMH prevents it |
|--------|---------------------|
| **JIT warmup** | Configurable warmup iterations before measurement |
| **Dead code elimination** | `Blackhole.consume()` or returning the value |
| **Constant folding** | `@State` ensures inputs are loaded from non-constant fields |
| **Loop optimization** | Prevents JIT from hoisting invariant computation |
| **Profile pollution** | `@Fork` spawns a new JVM per benchmark |

Microbenchmarks should be interpreted with caution — application-level benchmarks with realistic workloads are far more informative. JIT optimizations in isolation (escape analysis eliminating allocations) may not occur in the full application where objects escape to callers.

> **Sources:** Beckwith (2024) Ch.5 pp. 115–175 · Oaks (2020) Ch.2 pp. 15–48 · Goetz (2006) Ch.12 pp. 245–276 · Evans et al (2022) Ch.7 pp. 207–246 · Bloch (2018) Item 48 · [OpenJDK JMH](https://github.com/openjdk/jmh) · [Baeldung — Microbenchmarking with JMH](https://www.baeldung.com/java-microbenchmark-harness)

### Python: timeit, pytest-benchmark, and pyperf

Python benchmarking is comparatively straightforward because CPython's interpreter has no JIT warmup in standard builds and does not aggressively optimize away dead code.

```python
import timeit

# timeit runs a statement many times and reports the best time
# It automatically disables the garbage collector during measurement
result = timeit.timeit(
    stmt='sum(range(1000))',
    number=100_000
)
print(f"Average: {result / 100_000 * 1e6:.2f} microseconds")

# For more rigorous benchmarks, pyperf spawns separate processes,
# tunes the system for reproducibility, and performs significance testing:
# $ python -m pyperf timeit "sum(range(1000))"
```

```python
# pytest-benchmark integrates benchmarking into the pytest workflow
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

def test_fibonacci_benchmark(benchmark):
    result = benchmark(fibonacci, 20)
    assert result == 6765
```

Main Python benchmarking pitfalls:
1. **GC pauses** — `timeit` disables the cycle collector by default, which may not represent real workload performance
2. **Import overhead** — module imports can dominate benchmark time for small benchmarks
3. **Warm cache vs cold cache** — CPython caches compiled bytecode (`.pyc`), but first-import overhead is real
4. **I/O-bound vs CPU-bound** — Python's performance characteristics differ dramatically between these modes

> **Sources:** Shaw (2021) Ch.11 · Slatkin (2025) Items 92–93 pp. 448–457 · Martelli et al (2023) Ch.17 · [Python docs — `timeit`](https://docs.python.org/3/library/timeit.html) · [`pyperf`](https://github.com/psf/pyperf) · [pytest-benchmark](https://pytest-benchmark.readthedocs.io/)

### Cross-Language Comparison: Micro vs Macro Benchmarks

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Standard tool** | Criterion.rs | JMH | timeit / pyperf |
| **Dead code prevention** | `black_box()` | `Blackhole.consume()` | Not needed (interpreter) |
| **Warmup needed** | No | Yes (critical) | No |
| **Process isolation** | Not required | `@Fork` (essential) | `pyperf` (recommended) |
| **GC interference** | No GC | GC pauses distort results | GC disabled by `timeit` |
| **Micro→macro fidelity** | High (no runtime variance) | Low (JIT/GC differ at scale) | Low (interpreter overhead compounds) |

The Computer Language Benchmarks Game provides a useful cross-language comparison framework: each program is algorithmically equivalent, implementations are community-optimized, and measurements include both CPU time and memory consumption.

> **Sources:** Oaks (2020) Ch.2 pp. 15–48 · [Computer Language Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/)

---

## 3. Profiling Tools and Techniques

Each language's profiling ecosystem reflects its performance model: Rust uses OS-level tools (native code, no runtime to introspect), Java uses JVM-provided infrastructure (deep runtime visibility), Python uses interpreter-level tools (the interpreter is the bottleneck).

### Rust: perf, Flamegraphs, and DHAT

Rust profiling leverages Linux system tools directly because Rust compiles to native code with standard DWARF debug information.

```toml
# Cargo.toml — enable debug symbols in release builds
# This does NOT impact runtime performance
[profile.release]
debug = true
```

```bash
# Record CPU samples with perf (99Hz to avoid aliasing with timer interrupts)
perf record -g --call-graph dwarf ./target/release/myapp

# Generate a flamegraph from perf data
cargo install flamegraph
cargo flamegraph --bin myapp

# Hardware performance counters — cache misses, branch mispredictions, IPC
perf stat -e cache-misses,cache-references,branch-misses,instructions,cycles \
    ./target/release/myapp
```

Reading a flamegraph: the x-axis represents the percentage of samples, the y-axis represents call stack depth. Wide boxes at the top indicate functions consuming the most CPU time. Narrow boxes at the bottom indicate deep call stacks.

For heap profiling, DHAT tracks every allocation and its lifetime:

```rust
// Add to Cargo.toml: dhat = "0.3"
#[cfg(feature = "dhat-heap")]
#[global_allocator]
static ALLOC: dhat::Alloc = dhat::Alloc;

fn main() {
    #[cfg(feature = "dhat-heap")]
    let _profiler = dhat::Profiler::new_heap();

    // ... application code ...
    // DHAT report shows which allocations are short-lived
    // (candidates for stack allocation) and which are the largest
    // consumers of heap memory
}
```

> **Sources:** Bos (2023) Ch.9 pp. 181–211 · [The Rust Performance Book](https://nnethercote.github.io/perf-book/) · [`cargo-flamegraph`](https://github.com/flamegraph-rs/flamegraph) · [`inferno`](https://github.com/jonhoo/inferno) · [Brendan Gregg — Flame Graphs](https://www.brendangregg.com/flamegraphs.html) · [`perf` wiki](https://perf.wiki.kernel.org/index.php/Main_Page) · [`dhat` crate](https://docs.rs/dhat/latest/dhat/)

### Java: async-profiler, JFR, and Java Mission Control

Java profiling is uniquely rich because the JVM provides built-in profiling infrastructure.

**JDK Flight Recorder (JFR)** is a low-overhead (~2% CPU) always-on profiling framework. It records events: method profiling samples, GC pauses, thread states, lock contention, I/O operations, class loading, JIT compilation activity.

```bash
# Start a JFR recording on a running JVM
jcmd <pid> JFR.start duration=60s filename=recording.jfr

# Or enable at startup
java -XX:StartFlightRecording=duration=60s,filename=recording.jfr MyApp

# Analyze with Java Mission Control (JMC) — GUI tool with automated
# analysis rules that flag performance problems (excessive GC,
# lock contention, large allocations)
```

**async-profiler** is the premier sampling profiler for the JVM. It uses `perf_event_open` on Linux to capture both Java and native frames in the same flamegraph, avoiding safepoint bias.

```bash
# Generate a CPU flamegraph with async-profiler
./asprof -d 30 -f flamegraph.html <pid>

# Profile allocations — shows where objects are created
./asprof -d 30 -e alloc -f alloc-flamegraph.html <pid>

# Profile lock contention
./asprof -d 30 -e lock -f lock-flamegraph.html <pid>
```

The **safepoint bias problem**: the JVM can only walk thread stacks at "safepoints" (GC-safe points in generated code). Naive profilers that sample at safepoints miss CPU time spent between safepoints, producing biased results. async-profiler avoids this by using OS-level signals via `AsyncGetCallTrace`.

JFR can profile allocations (`jdk.ObjectAllocationInNewTLAB`, `jdk.ObjectAllocationOutsideTLAB` events) to find allocation-heavy code paths without instrumenting every allocation.

> **Sources:** Oaks (2020) Ch.3 pp. 49–88 · Evans et al (2022) Ch.7 pp. 230–246 · Beckwith (2024) Ch.5 pp. 115–175 · [async-profiler](https://github.com/async-profiler/async-profiler) · [JDK Mission Control](https://www.oracle.com/java/technologies/jdk-mission-control.html) · [Oracle — JDK Flight Recorder](https://docs.oracle.com/en/java/javase/21/jfapi/) · [Baeldung — Java Flight Recorder](https://www.baeldung.com/java-flight-recorder-monitoring)

### Python: cProfile, py-spy, line_profiler, memory_profiler, and Scalene

Python has a rich profiling ecosystem because performance optimization is frequently needed.

```python
# cProfile — built-in deterministic profiler (instruments every function call)
# Adds 30-50% overhead but provides exact call counts
import cProfile

cProfile.run('main()', sort='cumulative')

# Or from command line:
# python -m cProfile -s cumulative script.py
```

```bash
# py-spy — sampling profiler that attaches to a RUNNING process
# No code modification needed, ~5% overhead, produces flamegraphs
py-spy record -o flamegraph.svg --pid <pid>
py-spy top --pid <pid>  # Live top-like view
```

```python
# line_profiler — line-by-line timing within a function
# Decorate with @profile, run with: kernprof -l -v script.py
@profile
def slow_function():
    total = 0                   # Time:   0.1%
    for i in range(1000000):    # Time:   5.2%
        total += i * i          # Time:  94.7%  <-- bottleneck identified
    return total
```

```python
# memory_profiler — line-by-line memory consumption
# Decorate with @profile, run with: python -m memory_profiler script.py
@profile
def build_large_list():
    data = []                          # Mem: +0.0 MiB
    for i in range(1_000_000):
        data.append(i)                 # Mem: +35.1 MiB
    filtered = [x for x in data if x % 2 == 0]  # Mem: +17.6 MiB
    return filtered
```

**Scalene** simultaneously profiles CPU time (distinguishing Python vs C code), GPU utilization, and memory without requiring code modification. It separates "Python time" from "C extension time," which is critical for understanding whether optimization should target Python code or the C library interface.

```bash
# Scalene — CPU + GPU + memory profiler
scalene script.py
# Output shows per-line: Python time | C time | Memory allocation
```

> **Sources:** Gorelick & Ozsvald (2020) Ch.2 pp. 21–64 · Slatkin (2025) Item 92 pp. 448–452 · [Python docs — `cProfile`](https://docs.python.org/3/library/profile.html) · [`py-spy`](https://github.com/benfred/py-spy) · [`line_profiler`](https://github.com/pyutils/line_profiler) · [`memory_profiler`](https://github.com/pythonprofilers/memory_profiler) · [`Scalene`](https://github.com/plasma-umass/scalene)

### Cross-Language Comparison: Profiling Philosophy

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Infrastructure** | OS-level (`perf`, DWARF) | JVM-provided (JFR, JMX) | Interpreter hooks (`sys.settrace`) |
| **CPU profiler** | `perf record` + flamegraph | async-profiler / JFR | py-spy / Scalene |
| **Allocation profiler** | DHAT | JFR alloc events | memory_profiler / Scalene |
| **Line-level profiler** | N/A (use `perf annotate`) | JFR + JMC | line_profiler |
| **Production-safe** | `perf` (~2% overhead) | JFR (~2% overhead) | py-spy (~5% overhead) |
| **Flamegraphs show** | Your actual code | Your code + JVM internals | Interpreter loop + your code |

Rust flamegraphs show your actual code (hot loops, algorithm choices). Java flamegraphs show a mix of your code and JVM internals (GC, JIT compilation, class loading). Python flamegraphs show the interpreter overhead alongside your code. This is why Python profilers like Scalene distinguish "Python time" from "C time" — in data science workloads, most CPU time is in C extensions, and the Python interpreter overhead is negligible.

> **Sources:** Oaks (2020) Ch.3 pp. 49–88 · Gorelick & Ozsvald (2020) Ch.2 pp. 21–64

---

## 4. Memory Footprint and Layout

Memory layout determines cache efficiency, which directly impacts performance. Compact, contiguous data fits in CPU caches (L1 hit: ~1ns, L2: ~5ns, L3: ~10ns); scattered, pointer-heavy data causes cache misses (main memory: ~100ns per miss).

### Rust: Struct Layout, Alignment, and Cache Efficiency

Rust gives programmers explicit control over memory layout. By default, the Rust compiler is free to reorder struct fields to minimize padding (unlike C, which must preserve field order).

```rust
use std::mem;

// Rust compiler may reorder fields to minimize padding
struct Optimized {
    a: u8,   // 1 byte
    b: u64,  // 8 bytes
    c: u8,   // 1 byte
}
// Compiler reorders to: b (u64), a (u8), c (u8) → 16 bytes total

// C-compatible layout preserves field order
#[repr(C)]
struct CLayout {
    a: u8,   // 1 byte + 7 padding
    b: u64,  // 8 bytes
    c: u8,   // 1 byte + 7 padding
}
// Size: 24 bytes (padding to align u64)

fn main() {
    println!("Optimized: {} bytes", mem::size_of::<Optimized>()); // 16
    println!("CLayout:   {} bytes", mem::size_of::<CLayout>());   // 24
}
```

Layout control attributes:
- `#[repr(C)]` — C-compatible layout for FFI
- `#[repr(packed)]` — eliminates padding (cost: unaligned access)
- `#[repr(align(64))]` — pads to cache line boundaries (prevents false sharing)

Enum niche optimization: `Option<&T>` is the same size as `&T` because the null pointer value serves as the `None` discriminant.

```rust
use std::mem;

fn main() {
    // Niche optimization — Option<&T> == size of &T
    assert_eq!(mem::size_of::<&u64>(), mem::size_of::<Option<&u64>>());
    // Both are 8 bytes — the null pointer represents None

    // Without niche optimization, Option<u64> needs a tag
    assert_eq!(mem::size_of::<Option<u64>>(), 16);
    // 8 bytes for u64 + 8 bytes for discriminant (padded)
}
```

Cache coherence and false sharing: CPU caches operate on cache lines (typically 64 bytes). Two threads modifying data on the same cache line cause cache line invalidation storms via the MESI protocol.

> **Sources:** Gjengset (2022) Ch.2 pp. 19–35 · McNamara (2021) Ch.5 pp. 137–173 · Bos (2023) Ch.7 pp. 127–159 · [Rust Reference — Type Layout](https://doc.rust-lang.org/reference/type-layout.html) · [`std::mem::size_of`](https://doc.rust-lang.org/std/mem/fn.size_of.html) · [`std::alloc` module](https://doc.rust-lang.org/std/alloc/index.html)

### Java: Object Headers, Compressed Oops, and Valhalla

Every Java object on the heap carries a 12-byte header (with compressed oops enabled, default for heaps under 32 GB):

| Component | Size | Purpose |
|-----------|------|---------|
| Mark word | 8 bytes | Hash code, lock state, GC age |
| Class pointer | 4 bytes | Compressed from 8 bytes |
| **Total** | **12 bytes** | Padded to 16 bytes (8-byte alignment) |
| Array length (arrays only) | 4 bytes | Total header: 16 bytes |

This means an `Integer` object (wrapping a 4-byte `int`) occupies **16 bytes** — 4x the raw data size.

```java
// JOL (Java Object Layout) reveals exact memory layout
// org.openjdk.jol:jol-core dependency
import org.openjdk.jol.info.ClassLayout;

public class LayoutDemo {
    public static void main(String[] args) {
        // Integer: 16 bytes (12 header + 4 int value)
        System.out.println(ClassLayout.parseInstance(42).toPrintable());

        // int[1000]: 4016 bytes (16 header + 4000 data)
        System.out.println(ClassLayout.parseInstance(new int[1000]).toPrintable());

        // ArrayList<Integer> of 1000: ~20,000 bytes
        // 16 (ArrayList header) + 4016 (Object[] backing) + 1000 × 16 (boxed Integers)
    }
}
```

This boxing overhead is why Java performance guides emphasize primitive arrays and `IntStream` over `Stream<Integer>`:

```java
// BAD: boxing overhead — each int autoboxed to Integer (16 bytes each)
long sum = list.stream()
    .map(x -> x * 2)       // Stream<Integer> — boxed
    .reduce(0, Integer::sum);

// GOOD: primitive stream — no boxing
long sum = list.stream()
    .mapToInt(Integer::intValue)  // IntStream — unboxed
    .map(x -> x * 2)
    .sum();
```

**Project Valhalla** (JEP 401, in progress) aims to introduce value types that eliminate object headers for small, identity-free types. `Complex(double re, double im)` would be 16 bytes instead of 32 bytes, and arrays of value types would be flattened (contiguous memory, no pointers).

> **Sources:** Oaks (2020) Ch.7 pp. 203–248 · Beckwith (2024) Ch.6 pp. 177–217 · Bloch (2018) Item 6 · [OpenJDK — JOL](https://github.com/openjdk/jol) · [Aleksey Shipilev — Java Objects Inside Out](https://shipilev.net/jvm/objects-inside-out/) · [JEP 401 — Value Classes and Objects](https://openjdk.org/jeps/401)

### Python: PyObject Overhead and Reference Counting Cost

CPython has the highest per-object memory overhead. Every Python object starts with a `PyObject` header:

| Field | Size | Purpose |
|-------|------|---------|
| `ob_refcnt` | 8 bytes | Reference count (`Py_ssize_t`) |
| `ob_type` | 8 bytes | Pointer to type object (`PyTypeObject*`) |
| **Minimum** | **16 bytes** | Plus type-specific data |

Variable-size objects (`PyVarObject`) add 8 bytes for the size field.

```python
import sys

# Every Python object has significant overhead
print(sys.getsizeof(0))          # 28 bytes — a single integer!
print(sys.getsizeof(1))          # 28 bytes
print(sys.getsizeof(3.14))       # 24 bytes — a float
print(sys.getsizeof(""))         # 49 bytes — empty string
print(sys.getsizeof([]))         # 56 bytes — empty list
print(sys.getsizeof({}))         # 64 bytes — empty dict

# A list of 1000 integers: ~36,000 bytes
# (list header + pointer array + 1000 boxed int objects)
data = list(range(1000))
# sys.getsizeof(data) returns only the shallow size (pointer array)
# The deep size including all int objects is much larger
```

`__slots__` eliminates the per-instance `__dict__`, reducing object size significantly:

```python
import sys

class WithDict:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class WithSlots:
    __slots__ = ('x', 'y')
    def __init__(self, x, y):
        self.x = x
        self.y = y

print(sys.getsizeof(WithDict(1, 2)))   # 48 bytes (+ dict overhead)
print(sys.getsizeof(WithSlots(1, 2)))   # 48 bytes (no dict)
# The real savings: WithDict also creates a __dict__ (~64 bytes per instance)
```

For large datasets, `array.array` and NumPy bypass per-element overhead entirely:

```python
import array
import numpy as np
import sys

# Python list of 1M ints: ~36 MB (boxed objects + pointers)
py_list = list(range(1_000_000))

# array.array: ~8 MB (C-level typed array, no boxing)
arr = array.array('q', range(1_000_000))  # 'q' = signed long long

# NumPy: ~8 MB (contiguous typed memory)
np_arr = np.arange(1_000_000, dtype=np.int64)
```

> **Sources:** Shaw (2021) Ch.7 pp. 177–219 · Gorelick & Ozsvald (2020) Ch.11 pp. 341–390 · Slatkin (2025) Item 99 pp. 485–492 · [Python docs — `sys.getsizeof`](https://docs.python.org/3/library/sys.html#sys.getsizeof) · [`pympler`](https://pympler.readthedocs.io/) · [Python docs — `__slots__`](https://docs.python.org/3/reference/datamodel.html#slots)

### Cross-Language Comparison: Memory Footprint of 1 Million 64-bit Integers

| Storage | Approximate Size | Overhead |
|---------|-----------------|----------|
| Rust `Vec<i64>` | ~8 MB | ~0% (contiguous, zero overhead) |
| Java `long[]` | ~8 MB | ~0% (contiguous, 16-byte header negligible) |
| Java `ArrayList<Long>` | ~24 MB | 3x (boxed Long objects + pointer array) |
| Python `list` of `int` | ~36 MB | 4.5x (boxed int objects + pointer array) |
| NumPy `np.array(int64)` | ~8 MB | ~0% (contiguous C-level storage) |

The memory tax compounds for hash maps: each entry requires boxed key, boxed value, hash, and pointer overhead. Memory footprint directly affects performance through cache utilization: 8 MB of contiguous data fits in L3 cache on modern CPUs; 36 MB does not, causing frequent cache misses (~100ns per miss vs ~1ns for L1 hit).

> **Sources:** Gorelick & Ozsvald (2020) Ch.3–4 pp. 65–95 · McNamara (2021) Ch.6 pp. 175–211 · Klabnik & Nichols (2023) Ch.4 pp. 59–83

---

## 5. Startup Time and Warmup

The three languages have dramatically different startup characteristics: Rust starts in microseconds, Python in tens of milliseconds, and Java in hundreds of milliseconds to seconds.

### Rust: Instant Startup

Rust native binaries start in low single-digit milliseconds. The OS loads the binary into memory, the dynamic linker resolves shared library symbols (if any — Rust defaults to static linking), and `main()` executes. There is no runtime initialization, no interpreter startup, no JIT warmup.

```bash
# A "hello world" Rust binary starts in ~1-3 milliseconds
$ time ./target/release/hello
Hello, world!
real    0m0.001s

# Static linking eliminates even dynamic linker overhead
$ RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target x86_64-unknown-linux-musl

# Binary size optimization (faster page loading)
# Cargo.toml:
# [profile.release]
# lto = true           # Link-Time Optimization
# strip = true         # Remove debug symbols
# codegen-units = 1    # Maximize optimization
# opt-level = "z"      # Optimize for size
```

This makes Rust ideal for CLI tools (ripgrep starts instantly), serverless functions (AWS Lambda cold starts), and short-lived processes. A trivially simple Rust program is ready to do useful work before the JVM has even finished loading the class file containing `main`.

> **Sources:** Matthews (2024) Ch.11 pp. 219–231 · [The Rust Performance Book — Build Configuration](https://nnethercote.github.io/perf-book/build-configuration.html)

### Java: JVM Warmup and Mitigation Strategies

JVM startup is a multi-phase process:

1. **JVM initialization** (~50–100ms) — loading core classes, initializing GC, JIT compiler threads
2. **Class loading** — loading, verifying, and linking application classes
3. **Interpreter execution** (Tier 0) — 5–10x slower than compiled code
4. **JIT compilation** — methods compiled after ~10,000 invocations (default C2 threshold)
5. **Full warmup** — all critical paths C2-compiled, caches populated (seconds to minutes)

For a typical Spring Boot web application, full warmup takes 30–60 seconds.

Mitigation strategies:

```bash
# 1. Class Data Sharing (CDS/AppCDS) — serialize loaded classes to shared archive
#    Reduces class loading time by 10-30%
java -Xshare:dump                                     # Create default archive
java -XX:ArchiveClassesAtExit=app.jsa -jar myapp.jar  # Create app-specific archive
java -XX:SharedArchiveFile=app.jsa -jar myapp.jar     # Use the archive

# 2. GraalVM Native Image — AOT compile to native binary (10-50ms startup)
#    Restrictions: closed-world assumption, limited reflection, no dynamic class loading
native-image -jar myapp.jar
./myapp  # Starts in ~10-50ms, like Rust

# 3. CRaC (Coordinated Restore at Checkpoint)
#    Snapshot a fully warmed-up JVM, restore it later for instant startup
java -XX:CRaCCheckpointTo=checkpoint_dir -jar myapp.jar
# ... wait for warmup, then trigger checkpoint ...
java -XX:CRaCRestoreFrom=checkpoint_dir  # Instant restart with full JIT
```

| Strategy | Startup time | Trade-offs |
|----------|-------------|------------|
| Standard JVM | 100–500ms (bare), 2–10s (frameworks) | Full JIT optimization after warmup |
| CDS/AppCDS | 70–350ms | ~10–30% improvement, no restrictions |
| GraalVM Native Image | 10–50ms | Closed-world, limited reflection, no dynamic loading |
| CRaC | Near-instant | Requires checkpoint infrastructure, state management |

> **Sources:** Beckwith (2024) Ch.8 pp. 273–306 · Oaks (2020) Ch.4 pp. 89–95 · Evans et al (2022) Ch.7 pp. 215–225 · [JEP 310 — Application CDS](https://openjdk.org/jeps/310) · [JEP 350 — Dynamic CDS Archives](https://openjdk.org/jeps/350) · [CRaC](https://wiki.openjdk.org/display/crac) · [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/) · [Oracle — Class Data Sharing](https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html)

### Python: Interpreter Startup and Import Overhead

CPython startup is faster than JVM startup but slower than native binaries. `python -c "pass"` takes approximately 30–50ms. The dominant cost is importing modules.

```bash
# Measure import time for every module
$ python -X importtime -c "import pandas"
# Shows the import tree and time for each module
# Django imports hundreds of modules, taking 500ms-2s

# Skip site module import for faster startup
$ python -S -c "pass"  # ~15ms vs ~30ms

# Precompile bytecode to avoid recompilation
$ python -m compileall /path/to/package

# Measure exact startup overhead
$ python -X importtime -c "pass" 2>&1 | head -5
```

```python
# Lazy imports — import only when first accessed (not at import time)
# PEP 690 proposes this as a language feature

# Manual lazy import pattern:
def process_data(data):
    import pandas as pd  # Only imported when this function is first called
    return pd.DataFrame(data).describe()
```

Unlike Java, Python has no JIT warmup — performance is the same from the first bytecode instruction to the last in standard CPython.

The startup spectrum:

| Runtime | Startup time | Dominant cost |
|---------|-------------|---------------|
| Rust native binary | 1–5ms | Binary loading |
| Python (bare) | 30–50ms | Interpreter init + site module |
| Python + Django | 500ms–2s | Module imports |
| Java (bare) | 100–500ms | JVM init + class loading |
| Java + Spring Boot | 2–10s | Framework initialization |
| GraalVM Native Image | 10–50ms | Binary loading (like Rust) |

> **Sources:** Slatkin (2025) Items 97–98 pp. 475–484 · Gorelick & Ozsvald (2020) Ch.1 pp. 1–10 · [PEP 690 — Lazy Imports](https://peps.python.org/pep-0690/) · [Python docs — `py_compile`](https://docs.python.org/3/library/py_compile.html) · [Python docs — `-X importtime`](https://docs.python.org/3/using/cmdline.html#cmdoption-X)

---

## 6. Data Structure and Algorithm Performance

Data layout (contiguous arrays vs pointer-heavy structures), iterator optimization (zero-cost vs stream fusion vs generator overhead), and SIMD vectorization create orders-of-magnitude performance differences for the same algorithmic work.

### Rust: Collection Performance and Iterator Optimization

Rust collections achieve near-optimal performance because data is stored contiguously in memory with no boxing or indirection for primitive types.

```rust
use std::collections::HashMap;

fn main() {
    // Vec<i32> — contiguous block of 4-byte integers
    // CPU prefetchers predict sequential access and load cache lines ahead
    let numbers: Vec<i32> = (0..1_000_000).collect();

    // Iterator chains compile to a single loop — zero overhead
    let sum: i32 = numbers.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * 3)
        .sum();
    // LLVM compiles this to the same assembly as a hand-written for loop
    // with SIMD autovectorization processing 4-8 integers per instruction

    // HashMap uses SwissTable (hashbrown) — designed for cache efficiency
    // Metadata bytes for each slot fit in a single SIMD register,
    // enabling 16-way parallel probing
    let mut map = HashMap::new();
    map.insert("key", 42);
}
```

`HashMap` in Rust's standard library uses the **SwissTable algorithm** (via the `hashbrown` crate): metadata bytes for each slot fit in a single SIMD register, enabling 16-way parallel probing. Compare with Java's `HashMap` (linked-list chaining with pointer traversal) and Python's `dict` (boxed `PyObject` keys/values with pointer indirection).

> **Sources:** Matthews (2024) Ch.11 pp. 222–231 · Klabnik & Nichols (2023) Ch.13 pp. 273–294 · Blandy & Orendorff (2017) Ch.11 pp. 235–263 · [Rust docs — `std::collections`](https://doc.rust-lang.org/std/collections/index.html) · [`hashbrown` crate](https://docs.rs/hashbrown/latest/hashbrown/)

### Java: Stream API Optimization and Escape Analysis

Java's Stream API introduces an abstraction layer that the C2 JIT compiler optimizes through inlining, escape analysis, and loop fusion.

```java
import java.util.List;
import java.util.stream.IntStream;

public class StreamPerformance {
    // BAD: Stream<Integer> — boxing/unboxing at each step
    static int sumBoxed(List<Integer> list) {
        return list.stream()
            .filter(x -> x > 0)
            .map(x -> x * 2)
            .reduce(0, Integer::sum);
    }

    // GOOD: IntStream — no boxing, primitive operations
    static int sumPrimitive(List<Integer> list) {
        return list.stream()
            .mapToInt(Integer::intValue)  // Convert to IntStream once
            .filter(x -> x > 0)
            .map(x -> x * 2)
            .sum();
    }

    // GOOD: primitive array — best performance
    static int sumArray(int[] array) {
        return IntStream.of(array)
            .filter(x -> x > 0)
            .map(x -> x * 2)
            .sum();
    }
}
```

String performance is a Java-specific concern:

```java
// BAD: O(n²) — string concatenation in loop creates n intermediate objects
String result = "";
for (String s : items) {
    result += s;  // Each += allocates a new String
}

// GOOD: O(n) — StringBuilder amortizes allocation
StringBuilder sb = new StringBuilder();
for (String s : items) {
    sb.append(s);
}
String result = sb.toString();

// Compact strings (Java 9+): Latin-1 strings stored as byte arrays
// instead of char arrays, halving memory usage for ASCII content
```

> **Sources:** Oaks (2020) Ch.4 pp. 95–120 · Bloch (2018) Items 48, 61, 63 · Beckwith (2024) Ch.7 pp. 219–270 · [Java Collections Framework](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/doc-files/coll-overview.html) · [Baeldung — Java Collections Performance](https://www.baeldung.com/java-collections-complexity)

### Python: Data Structure Performance and NumPy Vectorization

Python's built-in data structures are implemented in C and optimized within the object model constraints. For numerical work, NumPy eliminates the per-element boxing overhead entirely.

```python
import numpy as np
import timeit

# Python list — each element is a boxed PyObject with pointer indirection
py_list = list(range(1_000_000))

# NumPy array — contiguous typed memory, C-level operations
np_arr = np.arange(1_000_000, dtype=np.int64)

# Performance comparison: sum of 1 million integers
t_python = timeit.timeit(lambda: sum(py_list), number=100)
t_numpy  = timeit.timeit(lambda: np.sum(np_arr), number=100)
# NumPy is ~100x faster because it avoids:
# - Interpreter dispatch per element
# - Type checking per element
# - Boxing/unboxing per element
# - Pointer chasing (cache misses)
```

```python
# Generators provide memory efficiency via lazy evaluation
# range(1_000_000) uses O(1) memory instead of O(n)
total = sum(x * x for x in range(1_000_000))

# List comprehensions are faster than explicit loops
# (internal C optimization in CPython)
squares = [x * x for x in range(1000)]    # ~30% faster than:
squares = []
for x in range(1000):
    squares.append(x * x)

# dict — highly optimized with compact layout (since Python 3.6)
# Maintains insertion order, open addressing
d = {str(i): i for i in range(10000)}
# O(1) average lookup, but each key/value is a boxed PyObject
```

> **Sources:** Gorelick & Ozsvald (2020) Ch.3–4 pp. 65–95 · Gorelick & Ozsvald (2020) Ch.5 pp. 97–107 · Gorelick & Ozsvald (2020) Ch.6 pp. 109–160 · Ramalho (2022) Ch.2 pp. 21–76 · [Python Wiki — Time Complexity](https://wiki.python.org/moin/TimeComplexity) · [Python docs — `array` module](https://docs.python.org/3/library/array.html) · [Python docs — `collections`](https://docs.python.org/3/library/collections.html)

### SIMD and Vectorization Comparison

SIMD (Single Instruction, Multiple Data) processes multiple data elements with a single instruction — 4 floats with SSE, 8 with AVX2, 16 with AVX-512.

```rust
// Rust: explicit SIMD via std::arch
#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;

// LLVM autovectorization works on tight loops over contiguous data
fn sum_array(data: &[f32]) -> f32 {
    data.iter().sum()
    // LLVM autovectorizes this into SIMD instructions
    // processing 4-8 floats per instruction
}

// Explicit SIMD for maximum control (unsafe)
#[cfg(target_arch = "x86_64")]
unsafe fn simd_add(a: &[f32; 8], b: &[f32; 8]) -> [f32; 8] {
    let va = _mm256_loadu_ps(a.as_ptr());
    let vb = _mm256_loadu_ps(b.as_ptr());
    let vc = _mm256_add_ps(va, vb);
    let mut result = [0.0f32; 8];
    _mm256_storeu_ps(result.as_mut_ptr(), vc);
    result
}
```

```java
// Java: Vector API (incubating since Java 16, JEP 448)
import jdk.incubator.vector.*;

static final VectorSpecies<Integer> SPECIES = IntVector.SPECIES_256;

static int[] vectorAdd(int[] a, int[] b) {
    int[] result = new int[a.length];
    int i = 0;
    for (; i < SPECIES.loopBound(a.length); i += SPECIES.length()) {
        IntVector va = IntVector.fromArray(SPECIES, a, i);
        IntVector vb = IntVector.fromArray(SPECIES, b, i);
        va.add(vb).intoArray(result, i);
    }
    // Handle tail elements
    for (; i < a.length; i++) {
        result[i] = a[i] + b[i];
    }
    return result;
}
```

```python
# Python: SIMD via NumPy/Numba (not accessible from pure Python)
import numpy as np

a = np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
b = np.array([8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0])
c = a + b  # NumPy ufuncs use SIMD internally

# Numba JIT compiles to LLVM IR with autovectorization
import numba

@numba.njit
def add_arrays(a, b):
    return a + b  # Compiled to SIMD instructions via LLVM
```

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Auto-vectorization** | LLVM (reliable) | C2 JIT (limited) | N/A |
| **Explicit SIMD** | `std::arch` intrinsics | Vector API (incubating) | N/A |
| **Portable SIMD** | `std::simd` (nightly) | Vector API | NumPy ufuncs / Numba |
| **Where SIMD code lives** | Your code | JIT-compiled code | C extensions |

> **Sources:** Matthews (2024) Ch.11 pp. 227–231 · Beckwith (2024) Ch.9 pp. 307–336 · Gorelick & Ozsvald (2020) Ch.6 pp. 109–160 · [Rust docs — `std::arch`](https://doc.rust-lang.org/std/arch/index.html) · [JEP 448 — Vector API](https://openjdk.org/jeps/448)

---

## 7. Common Optimization Patterns

Each language has a fundamentally different optimization philosophy. Rust: remove abstractions the compiler cannot see through. Java: work with the JIT compiler, not against it. Python: escape the interpreter for hot code.

### Rust: Inlining, Monomorphization, and Allocation Reduction

Rust optimization follows a predictable pattern:

```rust
// 1. Ensure zero-cost abstractions are working:
//    Use iterators, generics, and borrowing instead of allocation

// AVOID: allocates a new String
fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}

// PREFER: borrows, avoids allocation when possible
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

// Use Cow for "clone on write" — avoids cloning in the common case
use std::borrow::Cow;

fn maybe_transform(input: &str) -> Cow<'_, str> {
    if input.contains("bad") {
        Cow::Owned(input.replace("bad", "good"))  // Allocates only when needed
    } else {
        Cow::Borrowed(input)  // Zero-cost: just a reference
    }
}
```

```rust
// 2. Control inlining
#[inline]          // Hint: inline across crate boundaries
fn hot_function() { /* ... */ }

#[inline(always)]  // Force inlining (use sparingly)
fn tiny_critical() { /* ... */ }

#[inline(never)]   // Prevent inlining (cold error paths)
fn handle_error() { /* ... */ }

// 3. Monomorphization trade-off: static vs dynamic dispatch
// Static dispatch (monomorphized) — zero overhead, but code bloat
fn process<T: Display>(items: &[T]) { /* specialized per type */ }

// Dynamic dispatch (trait objects) — ~2ns per call, but compact code
fn process(items: &[&dyn Display]) { /* one copy, vtable indirection */ }
```

```toml
# 4. Release build optimization in Cargo.toml
[profile.release]
lto = true           # Link-Time Optimization for cross-crate inlining
codegen-units = 1    # Maximize optimization (slower compile)
opt-level = 3        # Maximum optimization level

# 5. Target the specific CPU
# RUSTFLAGS="-C target-cpu=native" cargo build --release
# Enables CPU-specific instructions (AVX2, etc.)
```

> **Sources:** Gjengset (2022) Ch.11 pp. 193–209 · Blandy & Orendorff (2017) Ch.11 pp. 235–263 · Klabnik & Nichols (2023) Ch.4 pp. 59–83 · [Rust Performance Book — Inlining](https://nnethercote.github.io/perf-book/inlining.html)

### Java: Escape Analysis, String Optimization, and Lock Elision

Java's C2 JIT compiler performs aggressive optimizations not possible at compile time.

**Escape analysis** determines whether an object escapes its creating method:

```java
public class EscapeAnalysisDemo {
    // The Point object never escapes this method
    static double distance(double x1, double y1, double x2, double y2) {
        // JIT detects that 'p' does not escape — three possible optimizations:
        // 1. Stack allocation (avoid GC entirely)
        // 2. Scalar replacement (break into dx, dy fields in registers)
        // 3. Elimination (compute result directly)
        record Point(double x, double y) {}
        Point p = new Point(x2 - x1, y2 - y1);
        return Math.sqrt(p.x() * p.x() + p.y() * p.y());
    }

    // Lock elision: lock is eliminated because the object is thread-local
    static int compute(int x) {
        Object lock = new Object();
        synchronized (lock) {  // JIT removes this — lock never escapes
            return x * x;
        }
    }
}
```

**Lock optimization** in HotSpot:

| Lock type | Description | When used |
|-----------|-------------|-----------|
| Biased locking | Lock is biased to first thread; no CAS needed for relock | Uncontended, single thread (deprecated in recent JDKs) |
| Thin lock | Single CAS operation | Uncontended, multiple threads |
| Fat lock | OS mutex (syscall) | Contended |
| Lock coarsening | Merge adjacent synchronized blocks | Multiple locks on same monitor |
| Lock elision | Remove lock entirely | Object doesn't escape |

**Avoiding unnecessary object creation** (Bloch Item 6):

```java
// BAD: creates ~2 billion unnecessary Long objects
Long sum = 0L;
for (long i = 0; i <= Integer.MAX_VALUE; i++) {
    sum += i;  // Autoboxing: long → Long for every addition
}

// GOOD: uses primitive long — no boxing, no GC pressure
long sum = 0L;
for (long i = 0; i <= Integer.MAX_VALUE; i++) {
    sum += i;
}
```

> **Sources:** Oaks (2020) Ch.4 pp. 100–120 · Beckwith (2024) Ch.7 pp. 219–270 · Bloch (2018) Items 6, 61, 63 · [Baeldung — Escape Analysis](https://www.baeldung.com/java-escape-analysis)

### Python: Cython, Numba, and C Extension Optimization

Python's primary optimization strategy is to move hot code out of the interpreter entirely.

```python
# Decision tree for Python optimization:
# 1. Profile to find the bottleneck (cProfile, py-spy)
# 2. Try NumPy vectorization (easiest)
# 3. Try Numba @njit (moderate effort, great for numerical loops)
# 4. Try Cython (moderate effort, works for general Python code)
# 5. Write a C/Rust extension (most effort, maximum performance)
```

**NumPy vectorization** — the easiest optimization:

```python
import numpy as np

# SLOW: Python loop — interpreter dispatch per element
def slow_distance(x1, y1, x2, y2):
    result = []
    for i in range(len(x1)):
        dx = x2[i] - x1[i]
        dy = y2[i] - y1[i]
        result.append((dx*dx + dy*dy) ** 0.5)
    return result

# FAST: NumPy vectorization — C-level SIMD operations
def fast_distance(x1, y1, x2, y2):
    return np.sqrt((x2 - x1)**2 + (y2 - y1)**2)
# ~100x faster for large arrays
```

**Numba JIT** — for numerical loops that can't be easily vectorized:

```python
import numba

@numba.njit  # Compiles to machine code via LLVM on first call
def mandelbrot(c, max_iter):
    z = 0
    for n in range(max_iter):
        if abs(z) > 2:
            return n
        z = z*z + c
    return max_iter
# First call: ~200ms (compilation). Subsequent calls: C-like performance.
```

**Cython** — Python superset that compiles to C:

```cython
# cython: language_level=3
# Typed Cython: 100-1000x faster than pure Python for loops

def primes_cython(int nb_primes):
    cdef int n, i, len_p
    cdef int[10000] p  # C array on the stack, not a Python list
    len_p = 0
    n = 2
    while len_p < nb_primes:
        for i in range(len_p):
            if n % p[i] == 0:
                break
        else:
            p[len_p] = n
            len_p += 1
        n += 1
    return [p[i] for i in range(len_p)]
```

**`memoryview`** — zero-copy buffer access:

```python
# memoryview avoids copying data between Python and C extensions
data = bytearray(1_000_000)
view = memoryview(data)
chunk = view[1000:2000]  # No copy — just a pointer + offset
```

> **Sources:** Gorelick & Ozsvald (2020) Ch.7 pp. 161–211 · Slatkin (2025) Items 94–96 pp. 458–474 · [Cython documentation](https://cython.readthedocs.io/) · [Numba documentation](https://numba.readthedocs.io/) · [Python docs — `memoryview`](https://docs.python.org/3/library/stdtypes.html#memoryview)

### Cross-Language Optimization Philosophy

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Who optimizes** | LLVM compiler | C2 JIT at runtime | The programmer (via C extensions) |
| **Primary strategy** | Remove abstractions compiler can't see through | Work with the JIT, reduce GC pressure | Escape the interpreter for hot code |
| **System-level** | Cache efficiency, memory layout, SIMD | JIT-friendliness, GC tuning | Choose the right library |
| **When defaults fail** | Explicit SIMD, allocator tuning, `unsafe` | Primitive types, off-heap, lock-free | Numba, Cython, C/Rust extension |
| **Typical speedup** | 2–5x from optimization | 2–10x from avoiding boxing/GC | 10–1000x from escaping interpreter |

> **Sources:** Oaks (2020) Ch.1 pp. 1–13 · Gorelick & Ozsvald (2020) Ch.7 pp. 161–211

---

## 8. Concurrency Performance

Parallel execution creates different challenges in each language: Rust's Rayon achieves near-linear speedup with compile-time safety, Java's ForkJoinPool provides mature thread pooling with GC-aware scheduling, and Python's GIL forces multiprocessing for CPU-bound parallelism.

### Rust: Rayon Parallelism and Cache-Aware Concurrency

Rayon achieves near-linear parallel speedup for data-parallel workloads by addressing three main barriers.

```rust
use rayon::prelude::*;

fn main() {
    let data: Vec<i64> = (0..10_000_000).collect();

    // Sequential: single-threaded iterator
    let sum_seq: i64 = data.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .sum();

    // Parallel: just change .iter() to .par_iter()
    // Rayon's work-stealing scheduler distributes across all cores
    let sum_par: i64 = data.par_iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .sum();

    assert_eq!(sum_seq, sum_par);
}
```

Rayon's work-stealing scheduler dynamically balances work: if one thread finishes early, it steals tasks from other threads' queues, avoiding idle cores.

Atomic operations are the cheapest synchronization primitive:

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

static COUNTER: AtomicUsize = AtomicUsize::new(0);

fn main() {
    // Relaxed: ~10-20ns on contended data
    COUNTER.fetch_add(1, Ordering::Relaxed);

    // vs Mutex: ~200-500ns on contended locks
    // Use atomics for simple counters and flags;
    // use Mutex only when protecting complex state
}
```

Preventing false sharing with alignment:

```rust
// Two threads modifying adjacent data on the same cache line
// causes cache line invalidation storms (MESI protocol)

// BAD: counter1 and counter2 likely share a cache line
struct Counters {
    counter1: u64,  // Thread 1 writes
    counter2: u64,  // Thread 2 writes — same cache line!
}

// GOOD: pad to separate cache lines
#[repr(align(64))]
struct PaddedCounter {
    value: u64,
}
struct Counters {
    counter1: PaddedCounter,  // Own cache line
    counter2: PaddedCounter,  // Own cache line
}
```

> **Sources:** Matthews (2024) Ch.11 pp. 227–231 · Bos (2023) Ch.7 pp. 127–159 · Gjengset (2022) Ch.10 pp. 167–192 · Bos (2023) Ch.9 pp. 181–211 · [Rayon crate](https://docs.rs/rayon/latest/rayon/) · [`std::sync::atomic::Ordering`](https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html)

### Java: Threading Performance, False Sharing, and Amdahl's Law

**Amdahl's law**: the maximum speedup from N processors is `1 / (S + (1-S)/N)` where S is the serial fraction. If 10% of work is serial, maximum speedup is 10x regardless of processor count.

Lock contention is the primary serial bottleneck:

```java
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicLong;

public class ConcurrencyPerformance {
    // BAD: synchronized HashMap — all threads contend on one lock
    // private final Map<String, Long> counts =
    //     Collections.synchronizedMap(new HashMap<>());

    // GOOD: ConcurrentHashMap — lock striping, multiple threads proceed
    private final ConcurrentHashMap<String, Long> counts = new ConcurrentHashMap<>();

    // GOOD: AtomicLong — lock-free CAS instead of synchronized
    private final AtomicLong counter = new AtomicLong();

    void increment() {
        counter.incrementAndGet();  // CAS loop, no lock
    }
}
```

Strategies to reduce lock contention:
1. **Reduce lock scope** — hold locks for less time
2. **Reduce lock frequency** — use `ConcurrentHashMap` instead of `synchronized HashMap`
3. **Lock striping** — partition data so threads lock different stripes
4. **Lock-free algorithms** — `AtomicInteger.compareAndSet()`

```java
// False sharing prevention with @Contended
// (requires -XX:-RestrictContended)
import jdk.internal.vm.annotation.Contended;

public class PaddedCounters {
    @Contended  // Pads field to its own cache line
    volatile long counter1;

    @Contended
    volatile long counter2;
}
```

**Virtual threads** (Java 21) change the equation for I/O-bound workloads:

```java
// Spawn millions of virtual threads — no thread pool sizing needed
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (int i = 0; i < 100_000; i++) {
        executor.submit(() -> {
            // Each virtual thread can block on I/O without wasting an OS thread
            var response = httpClient.send(request, BodyHandlers.ofString());
            process(response);
        });
    }
}
// Virtual threads eliminate the cost of blocking I/O
// but do NOT improve CPU-bound parallelism
```

> **Sources:** Oaks (2020) Ch.9 pp. 267–306 · Goetz (2006) Ch.11 pp. 221–243 · Goetz (2006) Ch.12 pp. 245–276 · [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444) · [Baeldung — False Sharing](https://www.baeldung.com/java-false-sharing-contended)

### Python: GIL, Multiprocessing, and Parallel Performance

Python's GIL means that threads cannot execute Python bytecode in parallel on multiple cores. For CPU-bound work, `threading` provides zero speedup.

```python
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import numpy as np

# CPU-bound work: multiprocessing (separate processes, each with own GIL)
def cpu_bound(n):
    return sum(i * i for i in range(n))

# ProcessPoolExecutor: true parallelism via separate OS processes
with ProcessPoolExecutor(max_workers=8) as executor:
    results = list(executor.map(cpu_bound, [1_000_000] * 8))
# Break-even: tasks must be >~1ms to overcome IPC serialization overhead

# I/O-bound work: threading is fine (GIL released during I/O waits)
import urllib.request

def io_bound(url):
    return urllib.request.urlopen(url).read()

with ThreadPoolExecutor(max_workers=32) as executor:
    results = list(executor.map(io_bound, urls))
```

NumPy operations automatically release the GIL during C-level computation:

```python
import numpy as np
from threading import Thread

# These run in TRUE parallel — GIL released during C-level BLAS operations
def matrix_multiply(a, b, result, idx):
    result[idx] = np.dot(a, b)

a = np.random.rand(1000, 1000)
b = np.random.rand(1000, 1000)
results = [None, None]

t1 = Thread(target=matrix_multiply, args=(a, b, results, 0))
t2 = Thread(target=matrix_multiply, args=(a, b, results, 1))
t1.start(); t2.start()
t1.join(); t2.join()
# Both np.dot calls execute simultaneously in C/Fortran BLAS threads
```

**Free-threaded Python** (PEP 703, Python 3.13+) aims to remove the GIL entirely, enabling true thread-level parallelism for Python bytecode. The trade-off: 5–10% single-threaded performance overhead (biased reference counting, per-object locks).

> **Sources:** Gorelick & Ozsvald (2020) Ch.9 pp. 245–308 · Ramalho (2022) Ch.19–20 pp. 695–772 · [PEP 703 — Making the GIL Optional](https://peps.python.org/pep-0703/) · [Python docs — `multiprocessing`](https://docs.python.org/3/library/multiprocessing.html)

### Cross-Language Comparison: Parallel Performance

For a CPU-bound embarrassingly parallel workload (1 million independent items, 8 cores):

| Runtime | Speedup | Limiting factor |
|---------|---------|-----------------|
| Rust + Rayon | ~7.5–7.8x | Amdahl's law for reduce phase, cache coherence |
| Java + ForkJoinPool | ~6–7x | GC pauses, JIT compilation of parallel paths |
| Java + parallel streams | ~6–7x | Same, plus stream overhead |
| Python + multiprocessing | ~4–6x | Serialization overhead (pickle) for IPC |
| Python + NumPy (GIL-releasing) | ~6–7x | BLAS thread pool, no serialization |

For I/O-bound workloads (10,000 HTTP requests):

| Runtime | Mechanism | OS Threads |
|---------|-----------|------------|
| Rust + tokio | async/await, epoll | ~4 |
| Java + virtual threads | Millions of virtual threads | ~N cores carrier threads |
| Python + asyncio | async/await, single thread | 1 |

The final insight: Rust gives you tools for maximum performance and trusts you to use them correctly (the compiler prevents safety errors, not performance errors). Java gives you reasonable performance by default with JVM tuning knobs. Python gives you the fastest development time and delegates performance-critical work to compiled extensions.

> **Sources:** Oaks (2020) Ch.9 pp. 267–306 · Goetz (2006) Ch.11 pp. 221–243 · Gorelick & Ozsvald (2020) Ch.9 pp. 245–308

---

## Sources

### Books

**Rust**
- Gjengset (2022) — *Rust for Rustaceans* · Ch.2 pp. 19–35 (types in memory), Ch.10 pp. 167–192 (concurrency performance), Ch.11 pp. 193–209 (FFI zero-cost)
- Matthews (2024) — *Code Like a Pro in Rust* · Ch.11 pp. 219–231 (optimizations, SIMD, Rayon)
- Blandy & Orendorff (2017) — *Programming Rust* · Ch.11 pp. 235–263 (traits, generics, monomorphization)
- McNamara (2021) — *Rust in Action* · Ch.5 pp. 137–173 (data in depth), Ch.6 pp. 175–211 (memory)
- Klabnik & Nichols (2023) — *The Rust Programming Language* · Ch.4 pp. 59–83 (ownership), Ch.13 pp. 273–294 (iterators, zero-cost abstractions)
- Bos (2023) — *Rust Atomics and Locks* · Ch.7 pp. 127–159 (processor, caching, MESI), Ch.9 pp. 181–211 (building locks, benchmarking)

**Java**
- Beckwith (2024) — *JVM Performance Engineering* · Ch.1 pp. 1–42 (HotSpot, tiered compilation), Ch.2 pp. 43–68 (type system performance), Ch.5 pp. 115–175 (JMH, methodology), Ch.6 pp. 177–217 (GC deep dive), Ch.7 pp. 219–270 (strings, locks), Ch.8 pp. 273–306 (startup, CDS, GraalVM, CRaC), Ch.9 pp. 307–336 (SIMD, Vector API)
- Oaks (2020) — *Java Performance* · Ch.1 pp. 1–13 (philosophy), Ch.2 pp. 15–48 (benchmarking), Ch.3 pp. 49–88 (toolbox), Ch.4 pp. 89–120 (JIT), Ch.5–6 pp. 121–201 (GC), Ch.7 pp. 203–248 (heap memory), Ch.8 pp. 249–265 (native memory), Ch.9 pp. 267–306 (threading)
- Evans et al (2022) — *The Well-Grounded Java Developer* · Ch.7 pp. 207–246 (performance, JIT, JFR)
- Bloch (2018) — *Effective Java* · Items 6, 48, 61, 63
- Goetz (2006) — *Java Concurrency in Practice* · Ch.11 pp. 221–243 (performance, Amdahl's law), Ch.12 pp. 245–276 (testing concurrent programs)

**Python**
- Gorelick & Ozsvald (2020) — *High Performance Python* · Ch.1 pp. 1–20 (performant Python), Ch.2 pp. 21–64 (profiling), Ch.3–4 pp. 65–95 (data structures), Ch.5 pp. 97–107 (iterators/generators), Ch.6 pp. 109–160 (NumPy), Ch.7 pp. 161–211 (compiling to C), Ch.9 pp. 245–308 (multiprocessing), Ch.11 pp. 341–390 (less RAM)
- Shaw (2021) — *CPython Internals* · Ch.5 pp. 151–175 (evaluation loop), Ch.7 pp. 177–219 (memory management), Ch.11 (benchmarking)
- Slatkin (2025) — *Effective Python* · Items 92–99 pp. 448–492
- Ramalho (2022) — *Fluent Python* · Ch.2 pp. 21–76 (sequences), Ch.19–20 pp. 695–772 (concurrency)
- Martelli et al (2023) — *Python in a Nutshell* · Ch.17 (testing, optimization)

### External Resources

**Execution Models**
- [The Rust Performance Book](https://nnethercote.github.io/perf-book/)
- [Rust Reference — Codegen attributes](https://doc.rust-lang.org/reference/attributes/codegen.html)
- [LLVM — Optimization Passes](https://llvm.org/docs/Passes.html)
- [Oracle — JVM Performance Enhancements](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)
- [JEP 295 — Ahead-of-Time Compilation](https://openjdk.org/jeps/295)
- [Aleksey Shipilev — JVM Anatomy Quarks](https://shipilev.net/jvm/anatomy-quarks/)
- [PEP 744 — JIT Compilation (CPython 3.13)](https://peps.python.org/pep-0744/)
- [Faster CPython project](https://github.com/faster-cpython/ideas)
- [Python docs — `dis` module](https://docs.python.org/3/library/dis.html)
- [PyPy — Architecture](https://doc.pypy.org/en/latest/architecture.html)

**Benchmarking**
- [Criterion.rs documentation](https://bheisler.github.io/criterion.rs/book/)
- [`cargo bench` documentation](https://doc.rust-lang.org/cargo/commands/cargo-bench.html)
- [`std::hint::black_box`](https://doc.rust-lang.org/std/hint/fn.black_box.html)
- [OpenJDK JMH](https://github.com/openjdk/jmh)
- [Aleksey Shipilev — JMH Samples](https://hg.openjdk.org/code-tools/jmh/file/tip/jmh-samples/)
- [Baeldung — Microbenchmarking with JMH](https://www.baeldung.com/java-microbenchmark-harness)
- [Python docs — `timeit`](https://docs.python.org/3/library/timeit.html)
- [pytest-benchmark](https://pytest-benchmark.readthedocs.io/)
- [`pyperf`](https://github.com/psf/pyperf)
- [Computer Language Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/)

**Profiling**
- [`cargo-flamegraph`](https://github.com/flamegraph-rs/flamegraph)
- [`inferno` crate](https://github.com/jonhoo/inferno)
- [`perf` wiki](https://perf.wiki.kernel.org/index.php/Main_Page)
- [Brendan Gregg — Flame Graphs](https://www.brendangregg.com/flamegraphs.html)
- [`dhat` crate](https://docs.rs/dhat/latest/dhat/)
- [async-profiler](https://github.com/async-profiler/async-profiler)
- [JDK Mission Control](https://www.oracle.com/java/technologies/jdk-mission-control.html)
- [Oracle — JDK Flight Recorder](https://docs.oracle.com/en/java/javase/21/jfapi/)
- [Baeldung — Java Flight Recorder](https://www.baeldung.com/java-flight-recorder-monitoring)
- [Python docs — `cProfile`](https://docs.python.org/3/library/profile.html)
- [`py-spy`](https://github.com/benfred/py-spy)
- [`line_profiler`](https://github.com/pyutils/line_profiler)
- [`memory_profiler`](https://github.com/pythonprofilers/memory_profiler)
- [`Scalene`](https://github.com/plasma-umass/scalene)

**Memory Layout**
- [Rust Reference — Type Layout](https://doc.rust-lang.org/reference/type-layout.html)
- [`std::mem::size_of`](https://doc.rust-lang.org/std/mem/fn.size_of.html)
- [`std::alloc` module](https://doc.rust-lang.org/std/alloc/index.html)
- [OpenJDK — JOL](https://github.com/openjdk/jol)
- [Aleksey Shipilev — Java Objects Inside Out](https://shipilev.net/jvm/objects-inside-out/)
- [JEP 401 — Value Classes (Project Valhalla)](https://openjdk.org/jeps/401)
- [Python docs — `sys.getsizeof`](https://docs.python.org/3/library/sys.html#sys.getsizeof)
- [`pympler`](https://pympler.readthedocs.io/)
- [Python docs — `__slots__`](https://docs.python.org/3/reference/datamodel.html#slots)

**Startup and Warmup**
- [The Rust Performance Book — Build Configuration](https://nnethercote.github.io/perf-book/build-configuration.html)
- [JEP 310 — Application Class-Data Sharing](https://openjdk.org/jeps/310)
- [JEP 350 — Dynamic CDS Archives](https://openjdk.org/jeps/350)
- [CRaC (Coordinated Restore at Checkpoint)](https://wiki.openjdk.org/display/crac)
- [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)
- [Oracle — Class Data Sharing](https://docs.oracle.com/en/java/javase/21/vm/class-data-sharing.html)
- [PEP 690 — Lazy Imports](https://peps.python.org/pep-0690/)
- [Python docs — `py_compile`](https://docs.python.org/3/library/py_compile.html)
- [Python docs — `-X importtime`](https://docs.python.org/3/using/cmdline.html#cmdoption-X)

**Data Structures and SIMD**
- [Rust docs — `std::collections`](https://doc.rust-lang.org/std/collections/index.html)
- [`hashbrown` crate](https://docs.rs/hashbrown/latest/hashbrown/)
- [Java Collections Framework](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/doc-files/coll-overview.html)
- [Baeldung — Java Collections Performance](https://www.baeldung.com/java-collections-complexity)
- [Python Wiki — Time Complexity](https://wiki.python.org/moin/TimeComplexity)
- [Python docs — `array` module](https://docs.python.org/3/library/array.html)
- [Python docs — `collections`](https://docs.python.org/3/library/collections.html)
- [Rust docs — `std::arch` (SIMD)](https://doc.rust-lang.org/std/arch/index.html)
- [JEP 448 — Vector API](https://openjdk.org/jeps/448)

**Optimization Patterns**
- [Rust Performance Book — Inlining](https://nnethercote.github.io/perf-book/inlining.html)
- [Baeldung — Escape Analysis](https://www.baeldung.com/java-escape-analysis)
- [Cython documentation](https://cython.readthedocs.io/)
- [Numba documentation](https://numba.readthedocs.io/)
- [Python docs — `memoryview`](https://docs.python.org/3/library/stdtypes.html#memoryview)

**Concurrency Performance**
- [Rayon crate](https://docs.rs/rayon/latest/rayon/)
- [`std::sync::atomic::Ordering`](https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html)
- [JEP 444 — Virtual Threads](https://openjdk.org/jeps/444)
- [Baeldung — False Sharing](https://www.baeldung.com/java-false-sharing-contended)
- [PEP 703 — Making the GIL Optional](https://peps.python.org/pep-0703/)
- [Python docs — `multiprocessing`](https://docs.python.org/3/library/multiprocessing.html)

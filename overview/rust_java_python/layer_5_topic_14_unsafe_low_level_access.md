# Layer 5 · Topic 14 — Unsafe Code & Low-Level Access

> The escape hatches each language provides when safety guarantees must be intentionally bypassed — Rust's `unsafe` blocks that unlock raw pointers and direct memory manipulation, Java's evolution from `sun.misc.Unsafe` through `VarHandle` to the Foreign Function & Memory API (Project Panama), and Python's CPython C API with the buffer protocol and ctypes/cffi for native code integration. Understanding when and why to reach for these mechanisms is as important as knowing how they work.

---

## 1. Philosophy of "Unsafe" Across Languages

Each language defines a different boundary between "safe" and "unsafe" code. The shape of that boundary reveals deep philosophical differences about control, trust, and abstraction.

### Rust: The Formal Safety Contract

Rust has two languages inside one: **Safe Rust** (guaranteed memory/type safety, no undefined behavior possible) and **Unsafe Rust** (same rules, but five additional operations unlocked). The `unsafe` keyword does not turn off the borrow checker or type system — it unlocks exactly five additional capabilities (the "superpowers"):

1. **Dereference raw pointers** (`*const T`, `*mut T`)
2. **Call unsafe functions or methods**
3. **Access or modify mutable static variables**
4. **Implement unsafe traits** (like `Send` and `Sync`)
5. **Access union fields**

The fundamental contract: `unsafe` code promises the compiler "I have manually verified the invariants you cannot check." The compiler still enforces all other rules inside `unsafe` blocks. A correct `unsafe` block can be wrapped in a safe API — this encapsulation (unsafe implementation detail, safe public interface) is the core pattern for unsafe Rust.

The **soundness property**: Safe Rust can never cause undefined behavior, regardless of what it does. If safe code can trigger UB, the bug is in the unsafe code that failed to properly encapsulate its invariants. Trust is asymmetric: safe code trusts that unsafe code is correct, but unsafe code cannot blindly trust generic safe code passed in as parameters (a safe `Ord` implementation might violate ordering invariants that unsafe code relies on).

**Safety is non-local** — changing `<` to `<=` in a bounds check can make a distant `get_unchecked` unsound. Privacy at module boundaries is the primary tool for maintaining soundness, because it prevents external safe code from violating internal invariants.

```rust
// Creating a raw pointer is safe
let x = 42;
let ptr = &x as *const i32;    // safe — no dereference yet

// Dereferencing requires unsafe
let val = unsafe { *ptr };      // unsafe — programmer asserts ptr is valid

// Wrapping unsafe in a safe API — the core pattern
pub fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    let ptr = values.as_mut_ptr();
    assert!(mid <= len);  // safety check at the boundary
    unsafe {
        (
            std::slice::from_raw_parts_mut(ptr, mid),
            std::slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}
```

Contrast with C/C++ where everything is "unsafe" — there is no compiler-enforced boundary between safe and unsafe operations.

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 419–437 · Gjengset (2022) Ch.9 pp. 141–148 · [Rustonomicon — "Meet Safe and Unsafe"](https://doc.rust-lang.org/nomicon/meet-safe-and-unsafe.html) · [Rustonomicon — "How Safe and Unsafe Interact"](https://doc.rust-lang.org/nomicon/safe-unsafe-meaning.html) · [Rustonomicon — "What Unsafe Can Do"](https://doc.rust-lang.org/nomicon/what-unsafe-does.html) · [Rust Reference — "Unsafety"](https://doc.rust-lang.org/reference/unsafety.html)

### Java: The Evolution of Low-Level Access

Java's "unsafe" story has three eras:

**Era 1 (Java 1.1–8): `sun.misc.Unsafe`** — an internal, undocumented class providing raw memory access (`allocateMemory`, `getInt`/`putInt`), CAS operations (`compareAndSwapInt` — the foundation of `java.util.concurrent.atomic`), object instantiation without constructors (`allocateInstance`), and thread parking (`park`/`unpark` — the foundation of `LockSupport`). Never part of the public API, yet became a de facto standard used by Netty, Kafka, Cassandra, Spark, and most high-performance Java libraries. To obtain an instance, you must bypass access checks via reflection:

```java
Field f = Unsafe.class.getDeclaredField("theUnsafe");
f.setAccessible(true);
Unsafe unsafe = (Unsafe) f.get(null);

// Off-heap memory allocation (bypasses GC)
long address = unsafe.allocateMemory(1024);
unsafe.putInt(address, 42);
int val = unsafe.getInt(address);    // 42
unsafe.freeMemory(address);

// CAS operation on a field
long offset = unsafe.objectFieldOffset(MyClass.class.getDeclaredField("value"));
unsafe.compareAndSwapInt(myObj, offset, expectedVal, newVal);

// Create instance without calling constructor
MyClass obj = (MyClass) unsafe.allocateInstance(MyClass.class);
```

**Era 2 (Java 9+): `VarHandle` and `MethodHandle`** — sanctioned replacements for `Unsafe`'s CAS and memory access operations, with proper safety checks and API guarantees.

**Era 3 (Java 22+): Foreign Function & Memory API (JEP 454)** — a complete, safe API for off-heap memory management and native function calls, replacing both `sun.misc.Unsafe` memory operations and JNI. JEP 471 (Java 23) formally deprecated `Unsafe`'s memory-access methods for removal.

The philosophical difference from Rust: Java's "unsafe" was never a language feature — it was an implementation leak that the platform is now systematically replacing with sanctioned alternatives.

> **Sources:** Evans & Gough (2024) Ch.13 pp. 348–355 · Evans & Gough (2024) Ch.7 pp. 177–179 · [JEP 471 — Deprecate sun.misc.Unsafe Memory-Access Methods](https://openjdk.org/jeps/471) · [Baeldung — Guide to sun.misc.Unsafe](https://www.baeldung.com/java-unsafe)

### Python: Crossing the C Boundary

Python has no `unsafe` keyword because CPython itself is written in C — the entire interpreter is "unsafe" from a memory safety perspective. The concept of "unsafe" in Python means crossing the boundary from Python code into C code, where you lose Python's automatic memory management (reference counting) and must manually manage `Py_INCREF`/`Py_DECREF`, handle NULL returns, and avoid dereferencing freed memory.

Every Python object is a `PyObject` struct in C, containing a reference count (`ob_refcnt`) and a pointer to its type object (`ob_type`). Variable-size objects (lists, strings, tuples) use `PyVarObject` which adds `ob_size`. The CPython C API provides functions to create, manipulate, and destroy Python objects from C code.

```c
// Every Python object in C
typedef struct {
    Py_ssize_t ob_refcnt;   // reference count
    PyTypeObject *ob_type;  // pointer to type
} PyObject;

// Variable-size objects (list, tuple, str...)
typedef struct {
    PyObject ob_base;
    Py_ssize_t ob_size;     // number of items
} PyVarObject;
```

The critical discipline: every C function that receives a Python object must manage reference counts correctly. A mismatched INCREF/DECREF leads to either memory leaks (forgotten DECREF) or use-after-free (extra DECREF). There are two kinds of references: "borrowed" (you don't own it, don't DECREF) and "new" (you own it, must DECREF when done).

The practical consequence: bugs in C extensions cause segfaults, memory leaks, and corruption rather than Python exceptions.

> **Sources:** Shaw (2020) pp. 285–315 · Gorelick & Ozsvald (2020) Ch.7 pp. 161–168 · [Python docs — Extending Python with C or C++](https://docs.python.org/3/extending/extending.html) · [Python docs — Python/C API Reference Manual](https://docs.python.org/3/c-api/index.html)

### Cross-Language Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **"Unsafe" is** | A formal language keyword | An evolving platform concept | A runtime boundary (Python ↔ C) |
| **Compiler involvement** | Compiler tracks unsafe operations | None — JVM handles safety | None — CPython is C code |
| **Safety boundary** | `unsafe` block/function | API version (Unsafe → VarHandle → Panama) | Language boundary (Python → C) |
| **Failure mode** | Undefined behavior | JVM crash or exception | Segfault, memory leak |
| **Tooling for verification** | Miri, sanitizers, cargo-careful | None specific | Valgrind, AddressSanitizer |
| **Philosophy** | Minimize unsafe surface, maximize safe abstractions | Replace unofficial backdoors with sanctioned APIs | Delegate unsafe work to C/Rust, expose safe Python APIs |

---

## 2. Rust Unsafe: Raw Pointers and Unsafe Blocks

### Raw Pointer Types and Operations

Raw pointers (`*const T`, `*mut T`) differ from references in four critical ways: (1) they can be null, (2) they can dangle (point to freed memory), (3) they can alias (`*mut T` and `*const T` to the same location), (4) they are not bound by the borrow checker. Creating a raw pointer is safe; **dereferencing** is the unsafe operation.

```rust
let mut x = 10;

// Creating raw pointers — safe code
let r1 = &x as *const i32;
let r2 = &mut x as *mut i32;

// Can even create a pointer to an arbitrary address — still safe
let address = 0x012345usize;
let r3 = address as *const i32;

// Dereferencing — must be inside unsafe
unsafe {
    println!("r1 = {}", *r1);
    *r2 = 20;
    // *r3 would be UB — dangling/invalid pointer
}
```

Key raw pointer operations:

```rust
// Pointer arithmetic (unsafe — must stay within allocation)
let arr = [1, 2, 3, 4, 5];
let ptr = arr.as_ptr();
unsafe {
    let third = *ptr.add(2);       // pointer arithmetic: ptr + 2*sizeof(i32)
    assert_eq!(third, 3);
}

// Read/write without moving the value
unsafe {
    let val = ptr.read();           // copies the value, doesn't move
    ptr_mut.write(42);              // writes without dropping old value
}

// Copy memory (like C memcpy/memmove)
unsafe {
    std::ptr::copy_nonoverlapping(src, dst, count);  // like memcpy
    std::ptr::copy(src, dst, count);                  // like memmove (handles overlap)
}

// Null pointers
let null_ptr: *const i32 = std::ptr::null();
let null_mut: *mut i32 = std::ptr::null_mut();

// NonNull — guaranteed non-null pointer wrapper
let nn = unsafe { std::ptr::NonNull::new_unchecked(ptr) };

// Convert raw pointer to reference (unsafe — must be valid, aligned, not aliased)
let reference: &i32 = unsafe { &*ptr };
let opt_ref: Option<&i32> = unsafe { ptr.as_ref() };  // returns None for null
```

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 425–437 · Blandy & Orendorff (2017) Ch.21 pp. 525–555 · McNamara (2021) Ch.6 pp. 175–196 · [Rust docs — `std::ptr`](https://doc.rust-lang.org/std/ptr/index.html) · [Rust docs — `NonNull`](https://doc.rust-lang.org/std/ptr/struct.NonNull.html)

### Calling Unsafe Functions and Implementing Unsafe Traits

Unsafe functions signal that the caller must uphold certain invariants — the function's documentation should specify exactly what those invariants are (the "safety contract").

```rust
// Unsafe function — caller must ensure valid pointer and count
unsafe fn dangerous(ptr: *const i32, count: usize) -> i32 {
    // SAFETY: caller guarantees ptr is valid for `count` reads
    let slice = std::slice::from_raw_parts(ptr, count);
    slice.iter().sum()
}

// Calling unsafe functions
let data = [1, 2, 3];
let sum = unsafe { dangerous(data.as_ptr(), data.len()) };

// Unsafe trait — implementor must uphold invariants
unsafe trait MySync {
    // Implementor guarantees thread-safe sharing
}

unsafe impl MySync for MyType {
    // We assert: MyType can be safely shared between threads
}
```

Mutable statics are unsafe to access because the compiler cannot verify absence of data races — this is the only place in Rust where global mutable state exists:

```rust
static mut COUNTER: u32 = 0;

fn increment() {
    unsafe {
        COUNTER += 1;  // unsafe — potential data race
    }
}
```

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 425–437 · Gjengset (2022) Ch.9 pp. 141–148

### Undefined Behavior

Rust defines specific categories of undefined behavior. UB is not "just a crash" — the compiler assumes UB never happens and optimizes accordingly, which can cause the compiler to delete code, reorder operations, or merge branches in ways that produce correct-seeming output in tests but fail in production.

The comprehensive (but non-exhaustive) list of UB:

1. **Data races** — two threads accessing the same memory, at least one writing, without synchronization
2. **Dangling/null/misaligned pointer dereference** — (misalignment is UB on load/store; `&raw` on misaligned places is allowed)
3. **Aliasing violations** — creating two `&mut T` to the same location, or `&mut T` and `&T` to the same location (Stacked Borrows model)
4. **Invalid values** — a `bool` not 0/1, a `char` outside Unicode range, a `&T` or `&mut T` that is null, a `str` that is not valid UTF-8, a `fn` pointer that is null, an invalid enum discriminant
5. **Unwinding across `extern "C"` boundaries** — may corrupt the stack
6. **Reading uninitialized memory** — using `std::mem::uninitialized()` or `MaybeUninit` incorrectly
7. **Mutating immutable data** — modifying bytes that are behind a `&` (without `UnsafeCell`)
8. **Wrong ABI calls** — calling a function with the wrong calling convention

Note: deadlocks, memory leaks, and integer overflow are explicitly **not** UB — they are "safe" behaviors (impractical to prevent statically).

> **Sources:** Gjengset (2022) Ch.9 pp. 148–159 · [Rust Reference — "Behavior considered undefined"](https://doc.rust-lang.org/reference/behavior-considered-undefined.html) · [Rustonomicon — "Working with Unsafe"](https://doc.rust-lang.org/nomicon/working-with-unsafe.html)

### Aliasing Rules

Aliasing (overlapping memory regions) is the key challenge for compiler optimizations. Rust's `&mut` guarantee (exclusive access) allows the compiler to:
- Cache values in registers (no other pointer can change them)
- Eliminate redundant reads/writes
- Merge branches
- Vectorize loops

`UnsafeCell<T>` is the escape hatch — the only legal way to mutate data behind a shared reference. Without `UnsafeCell`, mutating `&T`'s contents is UB because the compiler assumes `&T` data is immutable.

```rust
use std::cell::UnsafeCell;

// UnsafeCell opts out of the "shared refs are immutable" optimization
struct MyCell<T> {
    value: UnsafeCell<T>,
}

impl<T> MyCell<T> {
    fn set(&self, val: T) {
        // SAFETY: single-threaded access guaranteed by not implementing Sync
        unsafe { *self.value.get() = val; }
    }
    fn get(&self) -> T where T: Copy {
        unsafe { *self.value.get() }
    }
}
```

> **Sources:** Bos (2023) Ch.1 pp. 32–33 · Gjengset (2022) Ch.9 pp. 155–158 · [Rustonomicon — "Aliasing"](https://doc.rust-lang.org/nomicon/aliasing.html) · [Rust docs — `UnsafeCell`](https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html)

---

## 3. Rust Unsafe: Practical Patterns and Auditing

### Pattern: Safe Abstractions Over Unsafe Primitives

The core pattern in the Rust ecosystem: unsafe implementation details wrapped in a safe public API with documented safety invariants.

**RefWithFlag** — packing a bool flag into a reference's alignment bits. Since references are aligned, the lowest bit is always 0 and can store a boolean:

```rust
use std::marker::PhantomData;
use std::mem::align_of;

pub struct RefWithFlag<'a, T> {
    ptr_and_bit: usize,
    _phantom: PhantomData<&'a T>,
}

impl<'a, T> RefWithFlag<'a, T> {
    pub fn new(reference: &'a T, flag: bool) -> Self {
        assert!(align_of::<T>() >= 2);  // need at least 1 bit of alignment
        RefWithFlag {
            ptr_and_bit: (reference as *const T as usize) | (flag as usize),
            _phantom: PhantomData,
        }
    }
    pub fn as_ref(&self) -> &'a T {
        unsafe { &*((self.ptr_and_bit & !1) as *const T) }
    }
    pub fn flag(&self) -> bool {
        self.ptr_and_bit & 1 != 0
    }
}
```

**GapBuffer** — a text editor data structure using raw pointer manipulation for O(1) insertion at the cursor, managing a dynamically allocated buffer with an uninitialized gap region that moves to the cursor position.

Both examples follow the core pattern: unsafe implementation, safe public API, documented safety invariants.

> **Sources:** Blandy & Orendorff (2017) Ch.21 pp. 555–575

### PhantomData, Drop Check, Send and Sync

**`PhantomData<T>`** — a zero-size type that tells the compiler a type logically owns or references a `T`, even though it doesn't physically contain one. Controls variance (covariant/contravariant/invariant), Send/Sync auto-derivation, and drop-checking behavior. Common patterns:

| Phantom type | Effect |
|---|---|
| `PhantomData<T>` | Owns `T` (drop check, covariant) |
| `PhantomData<fn() -> T>` | Covariant in `T`, no drop check |
| `PhantomData<fn(T)>` | Contravariant in `T` |
| `PhantomData<fn(T) -> T>` | Invariant in `T` |
| `PhantomData<*mut T>` | Invariant, not Send/Sync |

**Drop check** — generic arguments must strictly outlive the type for a sound `Drop` impl (the compiler doesn't analyze destructor internals). The `#[may_dangle]` attribute (unstable, unsafe) asserts that the destructor does not access data behind the marked parameter:

```rust
// Standard library Vec uses this
unsafe impl<#[may_dangle] T, A: Allocator> Drop for Vec<T, A> {
    fn drop(&mut self) {
        // drops elements, then deallocates — never accesses T after dropping it
    }
}
```

**`Send` and `Sync`** — auto-derived marker traits. `Send` means safe to move to another thread. `Sync` means safe to share references (`T: Sync` iff `&T: Send`). Raw pointers implement neither (conservative default). `Rc` is neither (non-atomic reference count). `MutexGuard` is `Sync` but not `Send` (must unlock on the acquiring thread). Manual implementation requires `unsafe impl`:

```rust
struct MyBox(*mut u8);

// We assert: MyBox can safely be sent to another thread
unsafe impl Send for MyBox {}
// We assert: &MyBox can safely be shared between threads
unsafe impl Sync for MyBox {}
```

> **Sources:** Gjengset (2022) Ch.9 pp. 155–159 · [Rustonomicon — "PhantomData"](https://doc.rust-lang.org/nomicon/phantom-data.html) · [Rustonomicon — "Dropck"](https://doc.rust-lang.org/nomicon/dropck.html) · [Rustonomicon — "Send and Sync"](https://doc.rust-lang.org/nomicon/send-and-sync.html)

### no_std and Bare-Metal Unsafe

`#![no_std]` removes the standard library, leaving only `core` (and optionally `alloc`). Necessary for bare-metal, embedded, and kernel programming where no OS provides heap allocation or I/O.

In no_std contexts, unsafe code is more prevalent: direct hardware register interaction via volatile reads/writes, manual memory management, and interrupt handler implementation. Volatile operations prevent the compiler from optimizing away reads/writes to memory-mapped I/O registers:

```rust
#![no_std]
#![no_main]

// Volatile read/write — prevents compiler from optimizing away hardware I/O
use core::ptr;

const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;

unsafe fn write_vga(offset: usize, byte: u8) {
    ptr::write_volatile(VGA_BUFFER.add(offset), byte);
}

// Custom panic handler required in no_std
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
```

The pattern for hardware abstraction: define typed wrappers around memory-mapped registers, use volatile operations internally, expose a safe API that prevents misuse (e.g., writing to read-only registers).

> **Sources:** Gjengset (2022) Ch.12 pp. 211–222 · McNamara (2021) Ch.11 pp. 365–387

### Tools for Verifying Unsafe Code

**Miri** — an interpreter for Rust's MIR (Mid-level Intermediate Representation) that detects UB at runtime: use-after-free, out-of-bounds access, invalid pointer alignment, aliasing violations (Stacked Borrows), data races, invalid enum discriminants. Run with `cargo +nightly miri test`. Limitations: 10–100x slower than native, no raw syscalls, limited FFI, only detects UB that is actually executed.

**`cargo-careful`** — lighter-weight tool that enables extra runtime checks in the standard library.

**Sanitizers** — LLVM-based, detecting memory errors and data races in compiled code:
```bash
RUSTFLAGS="-Z sanitizer=address" cargo test   # AddressSanitizer
RUSTFLAGS="-Z sanitizer=thread" cargo test    # ThreadSanitizer
```

Best practice: combine Miri (for unsafe-specific UB), sanitizers (for memory/thread bugs), and property-based testing (proptest/quickcheck) to maximize coverage of unsafe code.

> **Sources:** Gjengset (2022) Ch.9 pp. 141–166 · [Miri — GitHub repository](https://github.com/rust-lang/miri) · [cargo-careful](https://github.com/RalfJung/cargo-careful) · [Unsafe Code Guidelines Reference](https://rust-lang.github.io/unsafe-code-guidelines/)

---

## 4. Java: Unsafe → VarHandle → Foreign Function & Memory API

### sun.misc.Unsafe — The Historical Backdoor

`sun.misc.Unsafe` was an internal JDK class providing capabilities that no public Java API offered. It was used by almost every high-performance Java library because there was no alternative.

Key capabilities:
- **Off-heap allocation**: `allocateMemory(size)` / `freeMemory(address)` — bypasses GC entirely
- **Direct memory access**: `getInt(address)` / `putInt(address, val)` — read/write at arbitrary offsets, including volatile and ordered variants
- **CAS operations**: `compareAndSwapInt(obj, offset, expected, update)` — the foundation of `java.util.concurrent.atomic`
- **Object instantiation**: `allocateInstance(Class)` — creates objects without calling constructors
- **Thread control**: `park()` / `unpark(thread)` — the foundation of `LockSupport`
- **Memory fences**: `loadFence()` / `storeFence()` / `fullFence()`

The dangers: no type checking, no bounds checking, no access control on field access. Wrong offset = heap corruption = JVM crash. JEP 471 (JDK 23) deprecated the memory-access methods for removal. Non-memory methods (`allocateInstance`, `throwException`) are not affected by this JEP.

> **Sources:** Evans & Gough (2024) Ch.13 pp. 348–355 · Beckwith (2024) Ch.7 pp. 219–270 · [JEP 471](https://openjdk.org/jeps/471) · [Baeldung — Guide to sun.misc.Unsafe](https://www.baeldung.com/java-unsafe)

### VarHandle — The Sanctioned Replacement (Java 9+)

`VarHandle` (JEP 193) provides type-safe access to variables with explicit memory ordering semantics, replacing `Unsafe` for field access and CAS operations.

Five access modes:
1. **Plain** — no ordering guarantees (like Rust's `Relaxed`)
2. **Opaque** — atomic + coherent (no reordering with respect to same-variable accesses)
3. **Acquire** — one-way fence on reads (like Rust's `Acquire`)
4. **Release** — one-way fence on writes (like Rust's `Release`)
5. **Volatile** — full sequential consistency (like Rust's `SeqCst`)

```java
import java.lang.invoke.MethodHandles;
import java.lang.invoke.VarHandle;

public class AtomicCounter {
    private volatile int count = 0;
    private static final VarHandle COUNT;

    static {
        try {
            COUNT = MethodHandles.lookup()
                .findVarHandle(AtomicCounter.class, "count", int.class);
        } catch (ReflectiveOperationException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public int increment() {
        return (int) COUNT.getAndAdd(this, 1);  // atomic increment
    }

    public boolean compareAndSet(int expected, int update) {
        return COUNT.compareAndSet(this, expected, update);
    }

    // Different memory orderings
    public int getPlain() { return (int) COUNT.get(this); }            // plain
    public int getOpaque() { return (int) COUNT.getOpaque(this); }     // opaque
    public int getAcquire() { return (int) COUNT.getAcquire(this); }   // acquire
    public int getVolatile() { return (int) COUNT.getVolatile(this); } // volatile
}
```

Unlike `Unsafe`, VarHandle performs type checking and access control at lookup time, and memory ordering semantics are explicit in the API. Static fence methods: `VarHandle.fullFence()`, `acquireFence()`, `releaseFence()`, `loadLoadFence()`, `storeStoreFence()`.

> **Sources:** Evans & Gough (2024) Ch.13 pp. 348–355 · Beckwith (2024) Ch.2 pp. 43–50 · [JEP 193 — Variable Handles](https://openjdk.org/jeps/193) · [Java docs — VarHandle](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/invoke/VarHandle.html)

### Foreign Function & Memory API — Project Panama (Java 22+)

The Foreign Function & Memory API (JEP 454, finalized in Java 22) provides two capabilities that replace both `sun.misc.Unsafe` memory operations and JNI.

**Foreign Memory API** — safe off-heap memory management:

```java
import java.lang.foreign.*;
import java.lang.invoke.MethodHandle;

// Arena manages memory lifecycle — deterministic deallocation (like Rust's RAII)
try (Arena arena = Arena.ofConfined()) {
    // Allocate off-heap memory
    MemorySegment segment = arena.allocateFrom(ValueLayout.JAVA_INT, 42);
    int val = segment.get(ValueLayout.JAVA_INT, 0);   // bounds-checked read

    // Struct layout — describes C struct in memory
    StructLayout pointLayout = MemoryLayout.structLayout(
        ValueLayout.JAVA_INT.withName("x"),
        ValueLayout.JAVA_INT.withName("y")
    );

    MemorySegment point = arena.allocate(pointLayout);
    VarHandle xHandle = pointLayout.varHandle(
        MemoryLayout.PathElement.groupElement("x"));
    xHandle.set(point, 0L, 10);  // set point.x = 10
}
// All segments freed when arena closes — no memory leaks
```

**Foreign Function API** — calling native C functions from pure Java:

```java
// Calling C's strlen — ~5 lines with Panama vs 50+ with JNI
try (Arena arena = Arena.ofConfined()) {
    // Look up the native function
    Linker linker = Linker.nativeLinker();
    SymbolLookup stdlib = linker.defaultLookup();
    MethodHandle strlen = linker.downcallHandle(
        stdlib.find("strlen").orElseThrow(),
        FunctionDescriptor.of(ValueLayout.JAVA_LONG, ValueLayout.ADDRESS)
    );

    // Call it
    MemorySegment str = arena.allocateFrom("Hello");
    long len = (long) strlen.invoke(str);  // returns 5
}
```

Key safety guarantees:
- **Spatial safety** — bounds checking on every access
- **Temporal safety** — `IllegalStateException` if accessing a closed arena (vs Rust's UB for use-after-free)
- **Thread confinement** — confined arenas can only be accessed from the owning thread

The **jextract** tool automatically generates Java binding classes from C header files, eliminating manual FunctionDescriptor/MethodHandle boilerplate.

> **Sources:** Horstmann (2024) Ch.13 · Evans & Gough (2024) Ch.15 pp. 412–414 · [JEP 454 — Foreign Function & Memory API](https://openjdk.org/jeps/454) · [Baeldung — Guide to Java Project Panama](https://www.baeldung.com/java-project-panama) · [Java docs — `java.lang.foreign`](https://docs.oracle.com/en/java/javase/22/docs/api/java.base/java/lang/foreign/package-summary.html)

### Comparison: Rust unsafe vs Java Low-Level APIs

| Aspect | Rust `unsafe` / raw pointers | Java VarHandle + Panama |
|--------|------------------------------|------------------------|
| **Memory allocation** | `alloc::alloc(layout)` — manual | `Arena.allocate()` — lifetime-managed |
| **Deallocation** | Manual or RAII via `Drop` | Automatic when Arena closes |
| **Bounds checking** | None (UB on out-of-bounds) | Always checked (throws exception) |
| **CAS operations** | `AtomicU64` (zero-cost, compile-time) | `VarHandle.compareAndSet` (JIT-optimized) |
| **Memory ordering** | `Ordering::Acquire/Release/SeqCst` | `getAcquire()`/`setRelease()`/`getVolatile()` |
| **FFI** | `extern "C"` + `unsafe` | `Linker` + `FunctionDescriptor` |
| **Failure on misuse** | Undefined behavior | Exception (safe failure) |
| **Overhead** | Zero | Bounds/lifetime checks (JIT-optimizable) |

---

## 5. Python: CPython C API, Buffer Protocol, ctypes/cffi

### CPython Memory Management

CPython uses a layered memory allocator with three domains:

1. **Raw domain** — wraps the system allocator (`malloc`/`free`)
2. **PyMem domain** — general-purpose allocator for Python internals
3. **Object domain** — specialized allocator for Python objects, including an arena-based allocator for small objects (≤512 bytes) that reduces fragmentation

Memory management relies on **reference counting** with a cyclic garbage collector as a backup:

```c
// Core reference counting API
Py_INCREF(obj);     // increment — you are keeping a reference (must not be NULL)
Py_DECREF(obj);     // decrement — releasing a reference (must not be NULL)
Py_XINCREF(obj);    // NULL-safe increment
Py_XDECREF(obj);    // NULL-safe decrement

// Modern additions (Python 3.10+)
PyObject *ref = Py_NewRef(obj);    // INCREF + return (combined pattern)

// Safe patterns for avoiding dangling pointers
Py_CLEAR(obj);       // DECREF + set to NULL (GC-safe, avoids double-free)
Py_SETREF(dst, src); // safe replacement: DECREF old, assign new (Python 3.6+)

// Since Python 3.12, immortal objects (None, True, small ints) are
// unaffected by INCREF/DECREF — they are never freed
```

Warning: `Py_DECREF` can invoke arbitrary Python code via `__del__`, which may modify data structures the caller is iterating over.

> **Sources:** Shaw (2020) pp. 177–219 · [Python docs — Reference Counting](https://docs.python.org/3/c-api/refcounting.html)

### Writing C Extension Modules

A C extension module follows a standard pattern:

```c
#include <Python.h>

// 1. Implement the function
static PyObject* mymod_add(PyObject *self, PyObject *args) {
    int a, b;
    // Parse arguments: "ii" = two ints
    if (!PyArg_ParseTuple(args, "ii", &a, &b))
        return NULL;  // error already set
    return Py_BuildValue("i", a + b);  // build return value
}

// Working with arrays — operating on buffer data
static PyObject* mymod_sum_array(PyObject *self, PyObject *args) {
    Py_buffer view;
    if (!PyArg_ParseTuple(args, "y*", &view))
        return NULL;
    double *data = (double *)view.buf;
    double sum = 0.0;
    for (Py_ssize_t i = 0; i < view.len / sizeof(double); i++)
        sum += data[i];
    PyBuffer_Release(&view);  // always release!
    return Py_BuildValue("d", sum);
}

// 2. Define module methods
static PyMethodDef MyModMethods[] = {
    {"add", mymod_add, METH_VARARGS, "Add two integers."},
    {"sum_array", mymod_sum_array, METH_VARARGS, "Sum a double array."},
    {NULL, NULL, 0, NULL}  // sentinel
};

// 3. Define the module
static struct PyModuleDef mymodmodule = {
    PyModuleDef_HEAD_INIT,
    "mymod",       // module name
    NULL,          // docstring
    -1,            // per-interpreter state size (-1 = global)
    MyModMethods
};

// 4. Init function — called on import
PyMODINIT_FUNC PyInit_mymod(void) {
    return PyModule_Create(&mymodmodule);
}
```

GIL management in C extensions — release for long-running C operations:

```c
static PyObject* mymod_heavy_computation(PyObject *self, PyObject *args) {
    // ... parse args ...
    Py_BEGIN_ALLOW_THREADS    // release GIL
    // ... long-running C computation (no Python API calls!) ...
    Py_END_ALLOW_THREADS      // re-acquire GIL
    return result;
}
```

Opaque pointers — wrapping C structs that Python cannot access directly:

```c
// Wrap a C pointer in a PyCapsule
PyObject *capsule = PyCapsule_New(my_c_struct, "mymod.MyStruct", destructor_fn);
// Retrieve the pointer
MyStruct *ptr = PyCapsule_GetPointer(capsule, "mymod.MyStruct");
```

> **Sources:** Beazley & Jones (2013) Ch.15 pp. 597–663 · Shaw (2020) pp. 364–369 · [Python docs — Extending Python with C or C++](https://docs.python.org/3/extending/extending.html)

### Buffer Protocol and memoryview

The buffer protocol (PEP 3118) allows Python objects to expose their internal memory as a contiguous buffer for zero-copy data sharing. The `Py_buffer` struct describes the buffer:

| Field | Type | Meaning |
|-------|------|---------|
| `buf` | `void *` | Pointer to memory |
| `len` | `Py_ssize_t` | Total size in bytes |
| `itemsize` | `Py_ssize_t` | Size per element |
| `format` | `const char *` | struct-style format (`"d"` = double, `"i"` = int) |
| `ndim` | `int` | Number of dimensions |
| `shape` | `Py_ssize_t *` | Size of each dimension |
| `strides` | `Py_ssize_t *` | Bytes to skip per dimension |
| `suboffsets` | `Py_ssize_t *` | For PIL-style indirect arrays |

Two memory models: **NumPy-style** (constant strides — `ptr = buf + sum(indices[i] * strides[i])`) and **PIL-style** (pointer indirection via suboffsets for discontiguous data).

Request flags let consumers declare what they can handle: `PyBUF_SIMPLE` (contiguous, no format), `PyBUF_ND` (adds shape), `PyBUF_STRIDES` (adds strides), `PyBUF_INDIRECT` (adds suboffsets).

```python
# memoryview — Python-level access to the buffer protocol
import array

a = array.array('d', [1.0, 2.0, 3.0, 4.0, 5.0])
mv = memoryview(a)

# Slicing creates a VIEW, not a copy
mv_slice = mv[1:4]         # view of elements 1,2,3 — zero copy
print(mv_slice.tolist())   # [2.0, 3.0, 4.0]

# Cast to a different format
mv_bytes = mv.cast('B')    # view as raw bytes
print(len(mv_bytes))       # 40 (5 doubles × 8 bytes)

# Direct modification through the view
mv[0] = 99.0
print(a[0])                # 99.0 — original array modified

# Properties
print(mv.format)           # 'd' (double)
print(mv.itemsize)         # 8
print(mv.ndim)             # 1
print(mv.shape)            # (5,)
print(mv.strides)          # (8,)

# NumPy, array.array, bytes, bytearray, mmap all support the buffer protocol
import numpy as np
arr = np.array([[1, 2], [3, 4]], dtype=np.int32)
mv = memoryview(arr)
print(mv.shape)            # (2, 2)
print(mv.strides)          # (8, 4) — row-major
```

This is Python's closest analogue to Rust's slice (`&[T]`) — a non-owning view into contiguous memory.

> **Sources:** Ramalho (2022) Ch.2 pp. 67–71 · [PEP 3118 — Revising the Buffer Protocol](https://peps.python.org/pep-3118/) · [Python docs — Buffer Protocol](https://docs.python.org/3/c-api/buffer.html) · [Python docs — memoryview](https://docs.python.org/3/library/stdtypes.html#memoryview)

### ctypes and cffi — Calling Native Code Without Writing C

**ctypes** (stdlib) — load and call shared libraries directly from Python:

```python
import ctypes

# Load a shared library
libc = ctypes.CDLL("libc.so.6")        # Linux
# libc = ctypes.CDLL("libc.dylib")     # macOS

# Declare argument and return types (important for correctness!)
libc.strlen.argtypes = [ctypes.c_char_p]
libc.strlen.restype = ctypes.c_size_t

# Call the function
result = libc.strlen(b"Hello")  # 5

# Fundamental ctypes types
# c_int, c_long, c_float, c_double, c_char_p (char*), c_void_p (void*)
# c_bool, c_uint, c_size_t, py_object (PyObject*)

# Defining C structs
class Point(ctypes.Structure):
    _fields_ = [("x", ctypes.c_int),
                ("y", ctypes.c_int)]

p = Point(10, 20)
print(p.x, p.y)  # 10 20

# Pointers
int_ptr = ctypes.POINTER(ctypes.c_int)
val = ctypes.c_int(42)
ptr = ctypes.pointer(val)
print(ptr.contents.value)  # 42

# Callback function pointers
COMPARE_FUNC = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_int, ctypes.c_int)

def py_compare(a, b):
    return a - b

libc.qsort(array, len(array), ctypes.sizeof(ctypes.c_int), COMPARE_FUNC(py_compare))
```

**cffi** (third-party) — two modes:

```python
# ABI mode — like ctypes but with C declarations
from cffi import FFI
ffi = FFI()
ffi.cdef("size_t strlen(const char *s);")      # declare C function
lib = ffi.dlopen("libc.so.6")                  # load library
result = lib.strlen(b"Hello")                   # call

# API mode (recommended) — compiles a real C extension
ffibuilder = FFI()
ffibuilder.cdef("double sqrt(double x);")
ffibuilder.set_source("_math_ext",
    '#include <math.h>',
    libraries=["m"])
ffibuilder.compile()

# Then in Python:
from _math_ext import lib
print(lib.sqrt(2.0))  # 1.4142135623730951
```

cffi's API mode is preferred because it handles function signatures automatically from C header declarations and produces faster calls (compiled at build time, verified by the C compiler).

String passing is a common source of bugs: Python 3 strings are Unicode, but C expects `char*` (bytes) — use `bytes` objects or `.encode('utf-8')` when passing to C.

> **Sources:** Beazley & Jones (2013) Ch.15 pp. 599–604, 644–656 · Gorelick & Ozsvald (2020) Ch.7 pp. 196–203 · [Python docs — ctypes](https://docs.python.org/3/library/ctypes.html) · [cffi documentation](https://cffi.readthedocs.io/en/stable/)

### Cython — Bridging Python and C

Cython is a superset of Python that compiles to C extension modules, handling all the `PyArg_ParseTuple`/`Py_BuildValue`/reference counting boilerplate automatically.

```cython
# mymodule.pyx
cimport cython
from libc.math cimport sqrt

# C type declarations for speed
def euclidean_distance(double x1, double y1, double x2, double y2):
    cdef double dx = x2 - x1
    cdef double dy = y2 - y1
    return sqrt(dx * dx + dy * dy)

# Typed memoryviews — C-speed array access with bounds checking
@cython.boundscheck(False)
@cython.wraparound(False)
def sum_array(double[:] arr):
    cdef double total = 0.0
    cdef Py_ssize_t i
    for i in range(arr.shape[0]):
        total += arr[i]
    return total

# Wrapping external C libraries
cdef extern from "mylib.h":
    double my_function(double x, int n)

def py_my_function(double x, int n):
    return my_function(x, n)

# Releasing the GIL for parallel execution
from cython.parallel import prange

def parallel_sum(double[:] arr):
    cdef double total = 0.0
    cdef Py_ssize_t i
    for i in prange(arr.shape[0], nogil=True):
        total += arr[i]
    return total
```

Comparison: ctypes is simplest (no compilation), cffi is more robust (handles edge cases better), Cython is most powerful (can mix Python and C semantics) but requires a build step.

> **Sources:** Beazley & Jones (2013) Ch.15 pp. 632–642 · Gorelick & Ozsvald (2020) Ch.7 pp. 168–186

---

## 6. Inline Assembly, SIMD, and Hardware Access

### Rust Inline Assembly (`asm!`)

Stabilized in Rust 1.59 (RFC 2873), `asm!` allows embedding assembly instructions directly in Rust code with structured operand binding:

```rust
use std::arch::asm;

// Basic usage — move a constant into a register
let x: u64;
unsafe {
    asm!("mov {}, 42", out(reg) x);
}
assert_eq!(x, 42);

// Input and output operands
let input: u64 = 5;
let output: u64;
unsafe {
    asm!(
        "add {0}, {1}",
        inout(reg) input => output,  // same register for in and out
        in(reg) 3u64,
    );
}
assert_eq!(output, 8);

// Explicit register operands (for instructions requiring specific registers)
let cmd: u32 = 0x8000_0000;
let eax: u32;
let ebx: u32;
unsafe {
    asm!(
        "cpuid",
        inout("eax") cmd => eax,
        out("ebx") ebx,
        out("ecx") _,      // scratch register (clobbered, unused)
        out("edx") _,
    );
}

// Options for compiler optimization hints
unsafe {
    asm!(
        "nop",
        options(pure, nomem, nostack)  // no side effects, no memory access, no stack use
    );
}
```

Operand types: `in(reg)`, `out(reg)`, `inout(reg)`, `lateout(reg)` (allows input/output register reuse), `const`, `sym` (symbol reference), `label` (for branch targets). `clobber_abi("C")` tells the compiler which registers the assembly may modify.

`global_asm!` allows defining entire functions in assembly (for boot code, ISR trampolines). `naked_asm!` is used in `#[naked]` functions (no prologue/epilogue).

> **Sources:** Matthews (2024) Ch.11 pp. 219–231 · [Rust Reference — Inline Assembly](https://doc.rust-lang.org/reference/inline-assembly.html) · [Rust By Example — Inline Assembly](https://doc.rust-lang.org/rust-by-example/unsafe/asm.html) · [Rust RFC 2873](https://rust-lang.github.io/rfcs/2873-inline-asm.html)

### SIMD Across Languages

**Rust** provides SIMD at two levels:

```rust
// Level 1: std::arch (stable) — platform-specific intrinsics
#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;

#[target_feature(enable = "avx2")]
unsafe fn add_arrays_avx2(a: &[f32; 8], b: &[f32; 8]) -> [f32; 8] {
    let va = _mm256_loadu_ps(a.as_ptr());
    let vb = _mm256_loadu_ps(b.as_ptr());
    let result = _mm256_add_ps(va, vb);
    let mut out = [0.0f32; 8];
    _mm256_storeu_ps(out.as_mut_ptr(), result);
    out
}

// Runtime feature detection
if is_x86_feature_detected!("avx2") {
    unsafe { add_arrays_avx2(&a, &b) }
} else {
    // scalar fallback
}

// Level 2: std::simd (nightly) — portable, safe SIMD
#![feature(portable_simd)]
use std::simd::f32x4;

fn add_portable(a: f32x4, b: f32x4) -> f32x4 {
    a + b  // safe — no unsafe needed, compiler picks best instructions
}
```

**Java** — the Vector API (incubating since Java 16, JEP 460):

```java
import jdk.incubator.vector.*;

static final VectorSpecies<Float> SPECIES = FloatVector.SPECIES_PREFERRED;

static float[] vectorAdd(float[] a, float[] b) {
    float[] result = new float[a.length];
    int bound = SPECIES.loopBound(a.length);

    // Vectorized main loop
    for (int i = 0; i < bound; i += SPECIES.length()) {
        FloatVector va = FloatVector.fromArray(SPECIES, a, i);
        FloatVector vb = FloatVector.fromArray(SPECIES, b, i);
        va.add(vb).intoArray(result, i);
    }

    // Scalar tail
    for (int i = bound; i < a.length; i++) {
        result[i] = a[i] + b[i];
    }
    return result;
}
```

The JIT compiler maps Vector API operations to actual SIMD instructions (SSE, AVX2, AVX-512, NEON). Unlike Rust's `std::arch`, Java's Vector API is safe — no `unsafe`, bounds checked, and the JIT chooses the best instruction set for the running CPU. Typical 2x–16x speedups. Still incubating because optimal performance requires Project Valhalla value types.

**Python** has no inline assembly or direct SIMD support. The approach is indirect: NumPy's internal C/Fortran code uses SIMD (via compiler auto-vectorization and hand-tuned kernels), Cython can generate SIMD-friendly C code, and Numba JIT-compiles Python to LLVM IR which auto-vectorizes. For compute-intensive work, Python delegates to C/Rust extensions — the buffer protocol provides the zero-copy interface.

> **Sources:** Matthews (2024) Ch.11 pp. 219–231 · Beckwith (2024) Ch.9 pp. 307–336 · Evans & Gough (2024) Ch.7 pp. 170–179 · [JEP 460 — Vector API](https://openjdk.org/jeps/460) · [Rust docs — `std::arch`](https://doc.rust-lang.org/std/arch/index.html)

### Cross-Language SIMD Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Direct SIMD** | `std::arch` (unsafe, stable) | Vector API (safe, incubating) | None |
| **Portable SIMD** | `std::simd` (safe, nightly) | Vector API (safe) | None |
| **Inline assembly** | `asm!` (unsafe) | Not possible (JVM) | Not possible (interpreter) |
| **Auto-vectorization** | LLVM compiler | JIT compiler | Via NumPy/Cython/Numba |
| **Safety** | Platform intrinsics are unsafe | Always safe (bounds-checked) | N/A |
| **Control level** | Instruction-level | Operation-level | Library-level |

---

## 7. Grand Synthesis: When and Why to Go Unsafe

All three ecosystems converge on the same pattern: **unsafe low-level code wrapped in safe high-level APIs**. They differ in where the boundary lives.

### Rust

`unsafe` is a precisely scoped language feature — five superpowers, formal safety contract, compiler-assisted auditing.

- **Use cases:** implementing data structures (Vec, HashMap), FFI, SIMD, hardware access, performance-critical hot paths, OS kernel development
- **Philosophy:** minimize unsafe surface, maximize safe abstractions, document invariants with `// SAFETY:` comments
- **The boundary:** the `unsafe` keyword itself

### Java

Low-level access evolved from unofficial backdoors to sanctioned APIs.

- **Use cases:** high-performance libraries (off-heap caches, serializers, network frameworks), native interop, hardware acceleration
- **Philosophy:** the platform provides safe alternatives to every low-level operation; prefer sanctioned APIs
- **The boundary:** API version — `sun.misc.Unsafe` → `VarHandle` (CAS, memory ordering) + Foreign Function & Memory API (off-heap, native calls) + Vector API (SIMD)

### Python

"Unsafe" means crossing the C boundary — C extensions, ctypes/cffi, Cython, buffer protocol.

- **Use cases:** wrapping native libraries, performance-critical code, hardware access, scientific computing
- **Philosophy:** Python is the glue — delegate unsafe work to C/Rust and expose safe Python APIs
- **The boundary:** the language boundary (Python → C)

### The Meta-Pattern

| Where the unsafe boundary lives | Rust | Java | Python |
|--------------------------------|------|------|--------|
| **Language keyword** | `unsafe` | — | — |
| **API evolution** | — | Unsafe → VarHandle → Panama | — |
| **Language boundary** | — | — | Python → C |

Rust makes the safe/unsafe boundary a first-class language concept with compiler support. Java makes it a platform evolution story (removing unofficial escape hatches, providing official replacements). Python makes it a runtime boundary (safe Python code vs unsafe C extensions). The convergence: in every ecosystem, the goal is to write as little unsafe code as possible and expose as much safe API as possible.

The increasing use of Rust as a backend for Python libraries (Polars, Pydantic v2, Ruff, cryptography) illustrates the cross-language synthesis: Rust provides unsafe-level SIMD and memory performance with safety guarantees, PyO3 provides ergonomic Python bindings, and the buffer protocol enables zero-copy data sharing. The result: safe Python API → safe Rust API → unsafe Rust implementation → hardware.

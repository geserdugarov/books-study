# Layer 2 · Topic 5 — Memory Model & Management

> Comparative study of Rust, Java, and Python: how each language stores, moves, and frees data — from stack/heap allocation through ownership and garbage collection to memory layout internals and advanced allocation strategies.

---

## 1. Stack vs Heap Allocation & Memory Regions

How each language decides where to allocate data — Rust makes it explicit through types, Java hides it behind the JVM, and Python puts virtually everything on the heap.

### Rust: Explicit Stack, Heap, and Static Memory

Rust makes the stack/heap distinction explicit through types. Stack-allocated data has a known, fixed size at compile time. Heap allocation happens through types like `String`, `Vec<T>`, and `Box<T>` — the programmer always knows where data lives by reading the types.

**Three memory regions:**

| Region | Contents | Lifetime |
|--------|----------|----------|
| **Stack** | Local variables of known size (integers, fixed arrays, structs of known-size fields), function parameters, return addresses | Current function scope |
| **Heap** | Dynamically-sized data owned by `String`, `Vec<T>`, `Box<T>`, `HashMap<K,V>`, etc. | Until the owner is dropped |
| **Static** | String literals (`&'static str`), constants (`const`), statics (`static`) | Entire program duration |

```rust
fn demo() {
    let x: i32 = 42;             // stack — 4 bytes, known size
    let arr = [1, 2, 3];          // stack — 12 bytes, fixed array
    let s = String::from("hello"); // stack: 24 bytes (ptr + len + capacity)
                                   // heap: 5 bytes (actual UTF-8 data)
    let b = Box::new(100);        // stack: 8 bytes (pointer)
                                   // heap: 4 bytes (the i32)
    let literal = "world";        // stack: 16 bytes (ptr + len, a &str)
                                   // static: 5 bytes (read-only data segment)
}
// All stack data freed instantly (stack pointer moves back)
// All heap data freed when owners (s, b) are dropped
```

There is no hidden heap allocation. The compiler does not silently move stack data to the heap (unlike Java's escape analysis, which goes the other direction). If you see `let x: i32 = 5;`, that integer is on the stack — guaranteed.

**Pointer types** differ in width. Thin pointers (e.g., `&i32`, `Box<i32>`) are one `usize` (8 bytes on 64-bit). Fat pointers carry extra metadata — `&[T]` and `&str` are pointer + length (16 bytes); `&dyn Trait` is pointer + vtable pointer (16 bytes).

> **Sources:** Klabnik & Nichols (2023) Ch.4 pp. 59–68 · McNamara (2021) Ch.6 pp. 175–195 · Gjengset (2022) Ch.1 pp. 1–5 · [Rust Reference — Memory Allocation](https://doc.rust-lang.org/reference/memory-allocation.html) · [Rust By Example — Box, stack and heap](https://doc.rust-lang.org/rust-by-example/std/box.html)

### Java: JVM Runtime Data Areas

The JVM manages memory in regions invisible to the programmer. The programmer has no direct control over stack vs heap placement — almost all objects go to the heap, and the JVM + GC handle reclamation.

**JVM memory structure:**

| Area | Contents | Management |
|------|----------|------------|
| **Stack** (per thread) | Primitive local variables, object references, frame metadata | Automatic (LIFO) |
| **Heap** (shared) | All object instances, arrays | Managed by GC |
| **Metaspace** (off-heap) | Class metadata, method bytecode, constant pools | Managed by JVM, replaces PermGen since Java 8 |
| **Native memory** | JNI buffers, thread stacks, direct byte buffers | OS-level, outside GC control |

The heap is further divided by the garbage collector into **generations**:

```
┌──────────────── Heap ────────────────────────────┐
│ ┌──── Young Generation ────┐  ┌─ Old Generation ─┐│
│ │ Eden │ S0 │ S1           │  │                   ││
│ │ (new │(sur│(sur          │  │ (long-lived       ││
│ │  obj)│viv)│viv)          │  │  objects)         ││
│ └──────────────────────────┘  └───────────────────┘│
└────────────────────────────────────────────────────┘
```

- **Eden**: where new objects are allocated (via TLAB — Thread-Local Allocation Buffer — for fast bump-pointer allocation). Each thread gets its own TLAB, so allocation is lock-free — just incrementing a pointer. TLABs are dynamically sized based on thread allocation rate (`-XX:TLABSize`, `-XX:TLABRefillWasteFraction`)
- **Survivor spaces** (S0, S1): objects surviving minor GC are copied here
- **Old generation**: objects that survived multiple minor GCs are promoted here. Promotion uses PLABs (Promotion Local Allocation Buffers) — per-GC-thread buffers with depth-first copying for cache-friendly co-locality

```java
void demo() {
    int x = 42;                    // stack — primitive, 4 bytes
    String s = new String("hello"); // stack: reference (4-8 bytes)
                                    // heap: String object (header + char[]/byte[])
    int[] arr = new int[3];        // stack: reference
                                    // heap: array object (header + 12 bytes data)
}
// Stack vars freed on method return
// Heap objects freed eventually by GC (non-deterministic)
```

> **Sources:** Oaks (2020) Ch.5 pp. 121–135 · Beckwith (2024) Ch.1 pp. 20–42 · Evans et al (2022) Ch.7 pp. 207–215 · [JVM Specification — Run-Time Data Areas](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html#jvms-2.5) · [Baeldung — Stack Memory and Heap Space](https://www.baeldung.com/java-stack-heap)

### Python: Everything on the Heap

In CPython, virtually everything is a heap-allocated object — even integers, booleans, and `None`. The C call stack holds frame metadata and local variable pointers (`PyObject*`), but the values themselves are always heap objects.

**CPython's layered memory allocator:**

```
┌──────────────────────────────────────┐
│         Object-specific layer        │  int, list, dict free-lists
├──────────────────────────────────────┤
│         Object allocator             │  PyObject_Malloc
├──────────────────────────────────────┤
│         PyMem allocator              │  PyMem_Malloc (pymalloc for ≤512 bytes)
├──────────────────────────────────────┤
│         Raw allocator                │  PyMem_RawMalloc (wraps OS malloc)
├──────────────────────────────────────┤
│         OS (malloc/mmap/VirtualAlloc)│
└──────────────────────────────────────┘
```

**pymalloc** is CPython's arena-based small-object allocator:
- Allocates **256 KB arenas** from the OS
- Divides each arena into **4 KB pools**
- Each pool is divided into **fixed-size blocks** (8 to 512 bytes in 8-byte increments)
- Objects larger than 512 bytes fall through to the raw allocator (OS malloc)

```python
import sys

# Everything is a heap object with overhead
sys.getsizeof(42)        # 28 bytes — not 4!
sys.getsizeof(3.14)      # 24 bytes — not 8!
sys.getsizeof(True)      # 28 bytes — bool is an int subclass
sys.getsizeof(None)      # 16 bytes
sys.getsizeof("")        # 49 bytes — empty string
sys.getsizeof([])        # 56 bytes — empty list
sys.getsizeof({})        # 64 bytes — empty dict
```

CPython maintains **free lists** for frequently used types — pre-allocated pools that avoid calling the allocator for common operations:
- **Small integers** (-5 to 256): pre-allocated singletons, never freed
- **Floats**: free list of recently deallocated float objects
- **Tuples** (size 0–20): free lists per size
- **Lists, dicts**: free lists for empty containers

```python
a = 256
b = 256
a is b  # True — same cached singleton object

a = 257
b = 257
a is b  # False — different objects (outside cache range)
```

> **Sources:** Shaw (2020) Ch.7 pp. 177–190 · Gorelick & Ozsvald (2020) Ch.1 pp. 1–15 · [Python docs — Memory Management](https://docs.python.org/3/c-api/memory.html) · [RealPython — Memory Management in Python](https://realpython.com/python-memory-management/)

### Allocation Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Where scalars live** | Stack (always) | Stack (primitives) / Heap (boxed) | Heap (always) |
| **Where objects live** | Stack by default; heap via Box/Vec/String | Heap (always) | Heap (always) |
| **Programmer control** | Full — types encode allocation site | None — JVM decides | None — everything is a heap object |
| **Memory per integer** | 1–16 bytes (no overhead) | 4 bytes (primitive) / ~16 bytes (Integer) | 28+ bytes (PyObject + value) |
| **Allocation speed** | Stack: instant; Heap: malloc | Eden: bump pointer via TLAB (fast) | pymalloc: pool/arena (fast for small objects) |
| **Deallocation** | Deterministic (scope exit / drop) | Non-deterministic (GC) | Reference counting (mostly deterministic) + cycle collector |

---

## 2. Ownership, Borrowing & Lifetimes (Rust)

Rust's unique compile-time memory management system eliminates the need for both garbage collection and manual malloc/free. The ownership system is Rust's most distinctive feature compared to Java and Python.

### The Three Ownership Rules

1. Each value in Rust has exactly **one owner** (the variable that holds it)
2. When the owner goes out of scope, the value is **dropped** (freed)
3. Ownership can be **transferred** (moved) but not duplicated (for non-Copy types)

```rust
fn main() {
    let s1 = String::from("hello"); // s1 owns the String
    let s2 = s1;                     // ownership moves to s2; s1 is now invalid
    // println!("{}", s1);           // ERROR: value used after move
    println!("{}", s2);              // OK — s2 is the owner
}  // s2 goes out of scope → String is dropped → heap memory freed
```

**Ownership forms a tree** (Blandy & Orendorff): at the root is a variable; the tree includes structs, tuples, and collections as interior nodes, with simple types at the leaves. When a variable goes out of scope, the entire tree is dropped recursively.

The String's stack representation (pointer, length, capacity) is bitwise-copied to `s2`, and `s1` is invalidated. The heap data is **not** duplicated. This is a **move** — a zero-cost transfer of responsibility:

```
Stack:                     Heap:
s1: [ptr|5|5] ─────┐     ┌───────────┐
    (invalidated)   ├────→│ h e l l o │
s2: [ptr|5|5] ─────┘     └───────────┘
```

For an explicit deep copy, use `.clone()`:

```rust
let s1 = String::from("hello");
let s2 = s1.clone();  // deep copy — both are valid, independent Strings
println!("{} {}", s1, s2);  // OK
```

### Borrowing: Shared and Mutable References

Borrowing allows using data without taking ownership. Two rules enforce safety:

1. **Shared XOR Mutable**: you can have either one mutable reference (`&mut T`) OR any number of shared references (`&T`), but not both simultaneously
2. **No dangling references**: references must not outlive the data they point to

```rust
fn calculate_length(s: &String) -> usize {  // borrows s (shared reference)
    s.len()
}   // s goes out of scope, but since it's a borrow, nothing is dropped

fn main() {
    let mut s = String::from("hello");

    // Multiple shared references — OK
    let r1 = &s;
    let r2 = &s;
    println!("{} {}", r1, r2);

    // Mutable reference — OK after shared refs are no longer used (NLL)
    let r3 = &mut s;
    r3.push_str(", world");
    println!("{}", r3);

    // ERROR: cannot have &mut while & exists
    // let r4 = &s;       // shared borrow
    // let r5 = &mut s;   // ERROR — mutable borrow while shared borrow alive
}
```

**Moving out of collections**: you cannot move out of a `Vec` element by indexing (would leave it partially initialized). Use `pop()`, `swap_remove(i)`, `std::mem::replace()`, or `std::mem::swap()` instead.

**Non-Lexical Lifetimes (NLL)** — since Rust 2018 (RFC 2094), borrows end at their last use point, not at scope exit. This makes the borrow checker significantly more permissive.

### Lifetimes

Lifetime annotations describe relationships between reference lifetimes that the compiler cannot infer automatically. They do **not** change how long data lives:

```rust
// Without annotation — compiler cannot determine relationship
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
// 'a says: the returned reference lives at least as long as
// the shorter-lived of x and y
```

**Three lifetime elision rules** handle most cases automatically:
1. Each reference parameter gets its own lifetime
2. If there is exactly one input lifetime, it is assigned to all output lifetimes
3. If one of the parameters is `&self` or `&mut self`, its lifetime is assigned to all output lifetimes

**`'static` does NOT always mean "lives forever"** (Gjengset). As a trait bound (`T: 'static`), it means T is self-sufficient and does not borrow any non-static values. An owned `String` satisfies `T: 'static` even though it is heap-allocated and will be freed.

**Variance** determines how lifetime relationships compose:
- `&'a T` is **covariant** in `'a`: a `&'long T` can be used where `&'short T` is expected
- `&'a mut T` is **invariant** in `T`: a `&'a mut Vec<&'long str>` cannot substitute for `&'a mut Vec<&'short str>`
- `fn(&'a T)` is **contravariant** in `'a`: a function accepting short-lived references can substitute for one accepting long-lived references

> **Sources:** Klabnik & Nichols (2023) Ch.4 pp. 59–83, Ch.10 pp. 181–213 · Blandy & Orendorff (2017) Ch.4 pp. 71–85, Ch.5 pp. 93–121 · McNamara (2021) Ch.4 pp. 107–125 · Gjengset (2022) Ch.1 pp. 8–17 · [Rustonomicon — Ownership](https://doc.rust-lang.org/nomicon/ownership.html) · [Rustonomicon — Lifetimes](https://doc.rust-lang.org/nomicon/lifetimes.html) · [RFC 2094 — Non-lexical lifetimes](https://rust-lang.github.io/rfcs/2094-nll.html)

### Java and Python: No Ownership Concept

Neither Java nor Python has ownership or lifetimes. The same data-flow written across all three languages illustrates the fundamental difference:

```java
// Java — GC handles everything, no ownership transfer
String s1 = new String("hello");
String s2 = s1;   // copies the reference — both point to same object
System.out.println(s1);  // still valid
// Object freed when GC determines it's unreachable
```

```python
# Python — reference counting handles everything
s1 = "hello"
s2 = s1    # copies the reference — both point to same object
print(s1)  # still valid
# Object freed when refcount drops to 0
```

In Rust, `let s2 = s1;` **moves** — in Java and Python, it **aliases**. This is the root difference.

---

## 3. Garbage Collection (Java) vs Reference Counting (Python)

The two dominant automatic memory management paradigms — tracing GC (Java) and reference counting with a cycle collector (CPython).

### Java: Generational Tracing GC

Java's GC is based on the **generational hypothesis** — most objects die young. The collector starts from **GC roots** (stack variables, static fields, JNI references) and traces all reachable objects; everything unreachable is reclaimed.

**Generational collection:**

| Generation | Typical size | Collection type | Frequency | Algorithm |
|------------|-------------|-----------------|-----------|-----------|
| **Young** (Eden + Survivors) | 1/3 of heap | Minor GC | Frequent (seconds) | Copying collector |
| **Old** | 2/3 of heap | Major / Mixed GC | Infrequent (minutes) | Mark-compact or mark-sweep |
| **Metaspace** | Grows as needed | Class unloading | Rare | Triggered by class loader GC |

**Minor GC flow:**
1. New objects are allocated in **Eden** (via bump-pointer in TLABs — extremely fast)
2. When Eden fills, a minor GC runs — live objects are copied to a survivor space
3. Dead objects in Eden (typically 90%+) are reclaimed by simply resetting the Eden pointer
4. Objects surviving several minor GCs (configurable via `-XX:MaxTenuringThreshold`, default 15) are **promoted** to the old generation

```java
// This code creates and discards objects rapidly — perfect for generational GC
void processRequests(List<Request> requests) {
    for (Request req : requests) {
        // These temporary objects die in Eden — very cheap to collect
        String formatted = req.format();
        byte[] encoded = formatted.getBytes(UTF_8);
        Response resp = new Response(encoded);
        send(resp);
    }
}
```

> **Sources:** Oaks (2020) Ch.5 pp. 121–152 · Beckwith (2024) Ch.1 pp. 20–42 · Evans et al (2022) Ch.7 pp. 207–215 · [Oracle GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/)

### Python: Reference Counting + Cycle Collector

CPython uses **reference counting** as its primary memory management. Every object has an `ob_refcnt` field; when it reaches zero, the object is freed immediately.

```python
import sys

a = [1, 2, 3]
sys.getrefcount(a)  # 2 (a + the getrefcount argument itself)

b = a               # refcount → 3
c = a               # refcount → 4
del b               # refcount → 3
c = None            # refcount → 2 (just a + getrefcount arg)
del a               # refcount → 0 → list is freed immediately
```

**Reference counting strengths:**
- **Deterministic destruction** for non-cyclic objects — freed at the exact moment the last reference is dropped
- **Incremental** — no stop-the-world pauses for most deallocations
- **Simple** — no graph traversal needed for acyclic structures

**Reference counting weakness — cycles:**

```python
# Creates a reference cycle — refcount never reaches 0
a = []
b = []
a.append(b)  # a → b
b.append(a)  # b → a
del a, b     # Both have refcount 1 (from each other) — LEAKED without cycle collector
```

CPython's **cycle collector** handles this. It uses a generational algorithm across three generations:

| Generation | Trigger threshold | Collected frequency |
|------------|------------------|---------------------|
| Gen 0 | ~700 allocations - deallocations | Most frequent |
| Gen 1 | After 10 gen-0 collections | Medium |
| Gen 2 | After 10 gen-1 collections | Least frequent |

The cycle detection algorithm:
1. For each container object in the generation, copy its refcount to `gc_refs`
2. For each container, decrement `gc_refs` of objects it references
3. Objects with `gc_refs > 0` are reachable from outside — they are **roots**
4. Trace from roots and mark everything reachable
5. Everything unmarked is unreachable (part of a cycle) — finalize and free it

The cycle collector only examines **container objects** (list, dict, set, class instances with `__dict__`, tuples). Non-containers (int, str, float) cannot form cycles and are handled purely by reference counting.

```python
import gc

gc.get_threshold()      # (700, 10, 10) — default thresholds
gc.collect()            # Force a full collection, returns number of unreachable objects
gc.disable()            # Disable cycle collector (refcounting still works)
gc.get_stats()          # Per-generation collection statistics
```

> **Sources:** Shaw (2020) Ch.7 pp. 200–219 · Martelli et al (2023) Ch.14 pp. 429–441 · Ramalho (2022) Ch.6 pp. 220–228 · [Python docs — gc module](https://docs.python.org/3/library/gc.html) · [CPython Developer Guide — Garbage collector design](https://devguide.python.org/internals/garbage-collector/) · [PEP 442 — Safe object finalization](https://peps.python.org/pep-0442/)

### Java Memory Model (JMM)

The Java Memory Model defines visibility rules for shared memory across threads — when one thread's write becomes visible to another. The **happens-before** relationship guarantees that if A happens-before B, then A's effects are visible to B.

**Eight happens-before rules:**

1. **Program order**: each action in a thread happens-before subsequent actions in that thread
2. **Monitor lock**: unlock happens-before subsequent lock on the same monitor
3. **Volatile variable**: write to volatile happens-before subsequent read of same volatile
4. **Thread start**: `thread.start()` happens-before any action in the started thread
5. **Thread termination**: any action in a thread happens-before `thread.join()` returns
6. **Transitivity**: if A happens-before B and B happens-before C, then A happens-before C
7. **Interruption**: `thread.interrupt()` happens-before the interrupted thread detects it
8. **Finalizer**: constructor completion happens-before `finalize()` begins

**Volatile** guarantees visibility and ordering but does **not** provide atomicity for compound operations (`volatile int count; count++;` is not thread-safe — the read-modify-write is not atomic).

**Safepoints** are positions where all application threads can be safely paused for GC (detailed in Section 8).

> **Sources:** Evans et al (2022) Ch.5 pp. 119–140

### Memory Management Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Strategy** | Compile-time ownership | Tracing GC (generational) | Reference counting + cycle collector |
| **GC pauses** | None | Microseconds to milliseconds | None (refcount) / brief (cycle collector) |
| **Throughput overhead** | Zero | ~5–10% for modern collectors | Refcount increment/decrement on every assignment |
| **Deterministic destruction** | Yes (scope exit / Drop) | No (GC timing non-deterministic) | Mostly yes (non-cyclic); no for cycles |
| **Cycle handling** | Prevented by borrow checker; `Weak<T>` for back-refs | Handled automatically by tracing GC | Requires cycle collector; `weakref` for back-refs |
| **Concurrent GC** | N/A | G1, ZGC, Shenandoah | N/A (GIL protects allocator) |

---

## 4. Move Semantics vs Copy Semantics vs Reference Semantics

The fundamentally different ways data is transferred between variables — Rust moves by default, Java copies references for objects and values for primitives, Python copies references for everything.

### Rust: Move by Default, Copy by Opt-In

Assignment in Rust is a **move** by default — ownership transfers, and the source becomes invalid:

```rust
let v1 = vec![1, 2, 3];
let v2 = v1;            // MOVE — v1 is now invalid
// println!("{:?}", v1); // ERROR: value used after move
println!("{:?}", v2);    // OK: [1, 2, 3]
```

Types implementing the **`Copy` trait** are an exception — they are bitwise-copied and the source remains valid. `Copy` types have no owned resources (no heap data):

```rust
let x: i32 = 42;
let y = x;          // COPY — both x and y are valid
println!("{} {}", x, y);  // OK: 42 42

// Copy types: all integer types, float types, bool, char,
// tuples of Copy types, arrays of Copy types, shared references (&T)
```

The `Clone` trait provides explicit deep copying for types that are not `Copy`:

```rust
let s1 = String::from("hello");
let s2 = s1.clone();       // explicit deep copy — heap data duplicated
println!("{} {}", s1, s2);  // OK: both valid and independent
```

| Mechanism | When | Cost | Source validity |
|-----------|------|------|-----------------|
| **Move** | Assignment of non-Copy types | O(1) — bitwise copy of stack repr | Source invalidated |
| **Copy** | Assignment of Copy types | O(1) — bitwise copy | Source still valid |
| **Clone** | Explicit `.clone()` call | O(n) — deep copy of heap data | Source still valid |

> **Sources:** Blandy & Orendorff (2017) Ch.4 pp. 71–90 · Matthews (2024) Ch.5 pp. 93–105 · [Rust Reference — Copy and Clone](https://doc.rust-lang.org/reference/special-types-and-traits.html#copy) · [Rust By Example — Ownership/Moves](https://doc.rust-lang.org/rust-by-example/scope/move.html)

### Java: Reference Copy for Objects, Value Copy for Primitives

Java has a dual system — primitives are copied by value, objects are copied by reference:

```java
// Primitives: value copy
int a = 42;
int b = a;      // independent copy
b = 100;
System.out.println(a);  // 42 — unaffected

// Objects: reference copy (aliasing)
List<Integer> list1 = new ArrayList<>(List.of(1, 2, 3));
List<Integer> list2 = list1;   // copies the reference, NOT the list
list2.add(4);
System.out.println(list1);     // [1, 2, 3, 4] — same object!
```

There are no moves in Java. Multiple references can alias the same object, and the GC cleans up when the last reference disappears. This aliasing is the root cause of **obsolete reference** memory leaks (Bloch Item 7) — holding a reference prevents GC even if the object is logically unused:

```java
// Memory leak via obsolete references
public class Stack {
    private Object[] elements;
    private int size = 0;

    public Object pop() {
        return elements[--size];
        // BUG: elements[size] still holds a reference — prevents GC
        // FIX: elements[size] = null;  // let GC reclaim
    }
}
```

> **Sources:** Bloch (2018) Ch.2 pp. 22–28 (Items 6, 7) · Valeev (2024) Ch.5 pp. 124–140 · [JLS — Assignment Expressions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.26)

### Python: Pure Reference Semantics

Python has only reference semantics — every assignment copies a reference, never a value. Even integers are heap objects:

```python
a = [1, 2, 3]
b = a           # copies the reference — b IS a (same object)
b.append(4)
print(a)        # [1, 2, 3, 4] — same list

a is b          # True — same identity
id(a) == id(b)  # True
```

**Immutability** substitutes for copy semantics in practice — since `int`, `str`, `tuple`, and `frozenset` cannot be mutated, aliasing them is safe:

```python
a = 42
b = a       # aliases the same int object
b = b + 1   # creates a NEW int object (43) — does NOT mutate the old one
print(a)    # 42 — unaffected because ints are immutable
```

For mutable objects, explicit copies are needed:

```python
import copy

original = [[1, 2], [3, 4]]
shallow = copy.copy(original)      # new outer list, same inner lists
deep = copy.deepcopy(original)     # new everything, recursively

shallow[0].append(99)
print(original[0])  # [1, 2, 99] — shallow copy shares inner lists
print(deep[0])      # [1, 2]     — deep copy is fully independent
```

> **Sources:** Ramalho (2022) Ch.6 pp. 201–220 · [Python docs — Data model](https://docs.python.org/3/reference/datamodel.html) · [Python docs — copy module](https://docs.python.org/3/library/copy.html)

### Semantics Comparison

| Operation | Rust | Java | Python |
|-----------|------|------|--------|
| `b = a` (non-primitive) | Move (a invalidated) | Reference copy (alias) | Reference copy (alias) |
| `b = a` (primitive/scalar) | Copy (both valid) | Value copy (both valid) | Reference copy (immutable alias) |
| Independent copy | `.clone()` | `new ArrayList<>(a)` / `.clone()` | `copy.deepcopy(a)` |
| Mutation visible through alias? | N/A (no aliasing for owned data) | Yes (shared mutable state) | Yes (for mutable types) |
| Cost of assignment | O(1) always | O(1) always | O(1) always |
| Who prevents double-free? | Compiler (single owner) | GC (reference tracing) | Reference counting |

---

## 5. Interior Mutability & Smart Pointers (Rust)

Rust's borrow checker rule — shared references (`&T`) cannot mutate — is sometimes too restrictive. Interior mutability types provide controlled escape hatches, and smart pointers enable shared ownership patterns.

### Cell and RefCell

**`Cell<T>`** — for `Copy` types only, allows get/set through a shared reference with **zero runtime overhead**:

```rust
use std::cell::Cell;

struct Counter {
    count: Cell<u32>,
}

impl Counter {
    fn increment(&self) {  // takes &self, not &mut self
        self.count.set(self.count.get() + 1);
    }
}
```

**`RefCell<T>`** — for any type, provides runtime-checked borrowing. Panics if borrow rules are violated at runtime:

```rust
use std::cell::RefCell;

let data = RefCell::new(vec![1, 2, 3]);
{
    let mut borrow = data.borrow_mut();  // runtime mutable borrow
    borrow.push(4);
}
{
    let borrow = data.borrow();          // runtime shared borrow
    println!("{:?}", *borrow);           // [1, 2, 3, 4]
}

// This would PANIC at runtime:
// let b1 = data.borrow();
// let b2 = data.borrow_mut();  // panic! already borrowed as shared
```

**`UnsafeCell<T>`** — the primitive underlying all interior mutability. It is the **only** Rust type that allows mutation through a shared reference, and using it directly is always `unsafe`. Both `Cell` and `RefCell` are safe wrappers around `UnsafeCell`.

### Smart Pointer Ecosystem

| Type | Ownership | Thread-safe | Runtime cost | Use case |
|------|-----------|-------------|-------------|----------|
| `Box<T>` | Single | Yes (if T: Send) | Zero (just a pointer) | Heap allocation with known single owner |
| `Rc<T>` | Shared (refcounted) | **No** | Refcount increment/decrement | Shared ownership in single thread |
| `Arc<T>` | Shared (atomic refcount) | Yes | Atomic refcount operations | Shared ownership across threads |
| `Cell<T>` | N/A (interior mut) | **No** | Zero | Mutating Copy types through &self |
| `RefCell<T>` | N/A (interior mut) | **No** | Borrow flag check | Mutating any type through &self |
| `Mutex<T>` | N/A (interior mut) | Yes | Lock/unlock | Mutating across threads with locking |
| `Weak<T>` | Non-owning | Matches Rc/Arc | Upgrade check | Breaking reference cycles |

**Common combined pattern — `Rc<RefCell<T>>`:**

```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

#[derive(Debug)]
struct Node {
    value: i32,
    children: RefCell<Vec<Rc<Node>>>,
    parent: RefCell<Weak<Node>>,      // Weak prevents cycles
}

let leaf = Rc::new(Node {
    value: 3,
    children: RefCell::new(vec![]),
    parent: RefCell::new(Weak::new()),
});

let branch = Rc::new(Node {
    value: 5,
    children: RefCell::new(vec![Rc::clone(&leaf)]),
    parent: RefCell::new(Weak::new()),
});

*leaf.parent.borrow_mut() = Rc::downgrade(&branch);
```

> **Sources:** Blandy & Orendorff (2017) Ch.9 pp. 200–209 · Klabnik & Nichols (2023) Ch.15 pp. 315–351 · Gjengset (2022) Ch.1 pp. 6–8 · Matthews (2024) Ch.5 pp. 105–118 · [Rust Reference — Interior Mutability](https://doc.rust-lang.org/reference/interior-mutability.html) · [std docs — Cell module](https://doc.rust-lang.org/std/cell/index.html) · [std docs — UnsafeCell](https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html)

### Java and Python: No Interior Mutability Needed

Java and Python do not have a concept of interior mutability because they never restrict aliased mutation at compile time:

- **Java**: all non-`final` fields are mutable through any reference. `volatile` and `synchronized` control thread visibility and atomicity, not single-threaded mutation.
- **Python**: everything is mutable by default (except `tuple`, `frozenset`, `str`). No compile-time aliasing restrictions exist.

The **same tree-with-parent-pointers** problem illustrates the difference:

```java
// Java — GC handles cycles, no special types needed
class Node {
    int value;
    List<Node> children = new ArrayList<>();
    Node parent;  // plain reference — GC traces and handles the cycle
}
```

```python
# Python — cycle collector handles cycles
class Node:
    def __init__(self, value):
        self.value = value
        self.children = []
        self.parent = None  # plain reference — cycle collector handles it
```

The trade-off: Rust requires explicit type gymnastics (`Rc<RefCell<T>>` + `Weak`) to express patterns that are trivial in Java and Python. The payoff is compile-time elimination of data races and dangling references.

---

## 6. RAII, Deterministic Destruction, Finalizers & Context Managers

How each language manages resource lifetimes — files, locks, network connections, database handles.

### Rust: RAII via the Drop Trait

RAII (Resource Acquisition Is Initialization) means owning a value means owning its resources. When a value goes out of scope, its `Drop::drop` method is called automatically — **deterministic** and **guaranteed**:

```rust
struct DatabaseConnection {
    url: String,
}

impl Drop for DatabaseConnection {
    fn drop(&mut self) {
        println!("Closing connection to {}", self.url);
        // Actual cleanup: close socket, release pool slot, etc.
    }
}

fn process() {
    let conn = DatabaseConnection {
        url: String::from("postgres://localhost/mydb"),
    };
    // ... use conn ...
}   // conn.drop() called HERE — deterministic, guaranteed
```

**Drop order** is well-defined:
- **Local variables**: dropped in **reverse** declaration order
- **Struct fields**: dropped in **declaration** order
- **Early drop**: `std::mem::drop(value)` or `drop(value)` drops before scope exit

```rust
fn demo() {
    let a = String::from("first");
    let b = String::from("second");
    drop(a);  // dropped early — before scope exit
    // a is no longer usable
}   // b dropped here (only remaining variable)
```

**`Drop` and `Copy` are mutually exclusive** — a type implementing `Drop` cannot implement `Copy`. If `Drop` runs cleanup logic, a bitwise copy would create two values that both try to clean up the same resource (double-free). This is enforced by the compiler.

RAII requires **no special syntax at the call site** — every value with a `Drop` implementation gets deterministic cleanup automatically. You cannot call `.drop()` directly — use `std::mem::drop(value)` or `drop(value)` for early cleanup.

> **Sources:** Blandy & Orendorff (2017) Ch.13 pp. 281–289 · Klabnik & Nichols (2023) Ch.15 pp. 325–330 · Gjengset (2022) Ch.1 pp. 3–5 · [Rust Reference — Destructors](https://doc.rust-lang.org/reference/destructors.html) · [std docs — Drop trait](https://doc.rust-lang.org/std/ops/trait.Drop.html)

### Java: try-with-resources, Finalizers, Cleaner

Java has three resource-management mechanisms:

**1. `finalize()` — Deprecated for Removal (JEP 421)**

Called by the GC at an unpredictable time (or never). Never use it:
- Non-deterministic timing — resources may remain open for an arbitrary period
- Runs on a special finalizer thread — concurrency issues
- Can resurrect objects — causes GC confusion
- **Severe performance penalty** — objects with finalizers survive at least 2 GC cycles (queued for finalization after first cycle, actually finalized in second), and object creation/destruction is ~50x slower
- Security vulnerability — a subclass can override `finalize()` to hold a reference to a partially constructed (and potentially invalid) object

**2. `Cleaner` (Java 9+) — Safer but Still Non-Deterministic**

Registers cleanup actions on phantom references:

```java
Cleaner cleaner = Cleaner.create();
cleaner.register(resource, () -> {
    // cleanup action — runs when resource becomes phantom-reachable
});
```

**3. try-with-resources (Java 7+) — The Correct Approach**

Deterministic resource cleanup for types implementing `AutoCloseable`:

```java
// Deterministic — close() called at block exit, even if exception thrown
try (var conn = DriverManager.getConnection(url);
     var stmt = conn.prepareStatement(sql);
     var rs = stmt.executeQuery()) {
    while (rs.next()) {
        process(rs);
    }
}
// rs.close(), stmt.close(), conn.close() — called in reverse order
// Suppressed exceptions are properly handled
```

> **Sources:** Bloch (2018) Ch.2 pp. 29–35 (Items 8, 9) · Valeev (2024) Ch.5 pp. 140–154 · [JEP 421 — Deprecate Finalization for Removal](https://openjdk.org/jeps/421) · [Java docs — AutoCloseable](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html) · [Java docs — Cleaner](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/Cleaner.html)

### Python: Context Managers, `__del__`, weakref.finalize

**`__del__` — Unreliable Finalizer**

Called when refcount drops to zero (usually deterministic in CPython for non-cyclic data), but with many caveats:
- Not called for objects in reference cycles (improved by PEP 442 in Python 3.4)
- Exceptions in `__del__` are silently ignored (printed to stderr)
- Order of `__del__` calls not guaranteed for cyclic objects
- Can resurrect objects by creating new references to `self`

```python
class Resource:
    def __del__(self):
        print("Cleaning up")  # unreliable — don't depend on this
```

Important implication: `open('file').write('data')` is safe in CPython (the file object's refcount drops to zero immediately, triggering `__del__` which closes the file), but this is **NOT safe in PyPy or Jython** (which use tracing GC instead of refcounting). Always use `with` statements for portable code.

**Context managers — The Correct Approach:**

```python
class DatabaseConnection:
    def __init__(self, url):
        self.url = url
        self.conn = connect(url)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()  # deterministic cleanup
        return False        # don't suppress exceptions

# Usage — close() guaranteed at block exit
with DatabaseConnection("postgres://localhost/mydb") as db:
    db.execute("SELECT ...")
# db.__exit__() called HERE — deterministic
```

**`weakref.finalize()` (Python 3.4+)** — More reliable than `__del__`:

```python
import weakref

class TempFile:
    def __init__(self, path):
        self.path = path
        self._finalizer = weakref.finalize(self, os.unlink, path)

    def close(self):
        self._finalizer()  # explicit cleanup

# Cleanup happens:
# 1. On explicit close() call, OR
# 2. When the TempFile object is garbage collected, OR
# 3. At interpreter shutdown (weakref.finalize registers an atexit callback)
```

> **Sources:** Ramalho (2022) Ch.6 pp. 220–228 · Martelli et al (2023) Ch.14 pp. 429–441 · [PEP 343 — The "with" Statement](https://peps.python.org/pep-0343/) · [PEP 442 — Safe object finalization](https://peps.python.org/pep-0442/) · [Python docs — `__del__`](https://docs.python.org/3/reference/datamodel.html#object.__del__) · [Python docs — Context Managers](https://docs.python.org/3/reference/datamodel.html#context-managers) · [Python docs — contextlib](https://docs.python.org/3/library/contextlib.html)

### Resource Management Comparison

| Aspect | Rust (RAII / Drop) | Java (try-with-resources) | Python (with / context mgr) |
|--------|-------------------|--------------------------|----------------------------|
| **Deterministic?** | Always | Only if caller uses try-with-resources | Only if caller uses `with` |
| **Automatic?** | Yes (no call-site syntax needed) | No (caller must wrap in try) | No (caller must wrap in `with`) |
| **Safety net** | N/A (compiler guarantees Drop) | Cleaner (non-deterministic) | `__del__` / `weakref.finalize` |
| **Nesting** | Implicit (scope-based) | Explicit (multi-resource try) | Explicit (`contextlib.ExitStack`) |
| **Exception safety** | Guaranteed (Drop runs even on panic) | Guaranteed (close called in finally) | Guaranteed (`__exit__` called) |
| **Caller cooperation** | Not required | Required | Required |

---

## 7. Memory Layout: Struct Padding, Object Headers & PyObject Internals

The physical layout of data in memory — the hidden costs that determine real-world memory consumption and cache behavior.

### Rust: Struct Layout, Padding, Alignment, repr

Rust's default layout (`repr(Rust)`) allows the compiler to **reorder fields** to minimize padding:

```rust
use std::mem;

struct Unoptimized {
    a: u8,    // 1 byte
    b: u64,   // 8 bytes (needs 8-byte alignment → 7 bytes padding after a)
    c: u16,   // 2 bytes
}
// Naive C layout: 1 + 7(pad) + 8 + 2 + 6(pad) = 24 bytes
// Rust may reorder to: b(8) + c(2) + a(1) + 5(pad) = 16 bytes

struct Optimized {
    b: u64,   // 8 bytes
    c: u16,   // 2 bytes
    a: u8,    // 1 byte
              // 5 bytes padding to reach alignment of 8
}

println!("{}", mem::size_of::<Optimized>());  // 16
println!("{}", mem::align_of::<Optimized>()); // 8
```

**repr attributes** control layout explicitly:

| Attribute | Behavior | Use case |
|-----------|----------|----------|
| `repr(Rust)` | Default — compiler may reorder fields, no guaranteed layout | Normal Rust structs |
| `repr(C)` | C-compatible layout — fields in declaration order, C padding rules | FFI, serialization |
| `repr(transparent)` | Single-field struct has same layout as its field | Newtype pattern for FFI |
| `repr(packed)` | No padding — may cause unaligned access (slower on some architectures) | Memory-constrained systems |
| `repr(align(N))` | Minimum alignment of N bytes | Cache-line alignment |

```rust
#[repr(C)]
struct CPoint {
    x: f64,   // 8 bytes at offset 0
    y: f64,   // 8 bytes at offset 8
}             // Total: 16 bytes, alignment: 8

#[repr(transparent)]
struct Meters(f64);  // Same layout as f64 — zero-cost newtype

#[repr(C, align(64))]
struct CacheAligned {
    data: [u8; 32],
}  // Aligned to 64-byte cache line boundary
```

**Niche optimization** — Rust uses "unused" bit patterns to represent enum discriminants without additional space:

```rust
// Option<&T> is the SAME SIZE as &T (8 bytes, not 16)
// because null (0x0) represents None — references can never be null
assert_eq!(mem::size_of::<Option<&i32>>(), mem::size_of::<&i32>());  // 8 == 8

// Option<NonZeroU32> is the same size as u32
// because 0 represents None
use std::num::NonZeroU32;
assert_eq!(mem::size_of::<Option<NonZeroU32>>(), mem::size_of::<u32>());  // 4 == 4
```

> **Sources:** Gjengset (2022) Ch.2 pp. 19–30 · Blandy & Orendorff (2017) Ch.9 pp. 193–200 · [Rust Reference — Type Layout](https://doc.rust-lang.org/reference/type-layout.html) · [Rustonomicon — Data Representation](https://doc.rust-lang.org/nomicon/data.html) · [Rustonomicon — Alternative Representations](https://doc.rust-lang.org/nomicon/other-reprs.html)

### Java: JVM Object Headers and Compressed Oops

Every Java object on the heap has a **header** before its field data:

```
64-bit JVM with compressed oops (heap < 32 GB):
┌───────────────────────────────────────────┐
│ Mark Word (8 bytes)                       │  hash code, GC age (4 bits),
│                                           │  lock state, GC forwarding ptr
├───────────────────────────────────────────┤
│ Klass Pointer (4 bytes, compressed)       │  pointer to class metadata
├───────────────────────────────────────────┤
│ [Array Length (4 bytes) — arrays only]    │
├───────────────────────────────────────────┤
│ Instance fields (+ padding to 8-byte)     │
└───────────────────────────────────────────┘
```

**Mark word** contents vary by state:
- **Unlocked**: identity hash code (31 bits), GC age (4 bits), biased lock flag
- **Biased locked**: thread ID, epoch, GC age
- **Lightweight locked**: pointer to lock record on stack
- **Heavyweight locked**: pointer to monitor object
- **GC marked**: forwarding pointer (during GC relocation)

**Object sizing examples:**

| Java type | Header | Fields | Padding | Total |
|-----------|--------|--------|---------|-------|
| `new Object()` | 12 bytes | 0 | 4 | **16 bytes** |
| `new Integer(42)` | 12 bytes | 4 (int) | 0 | **16 bytes** |
| `new Long(42L)` | 12 bytes | 8 (long) | 4 | **24 bytes** |
| `new boolean[0]` | 16 bytes (incl. length) | 0 | 0 | **16 bytes** |
| `new int[10]` | 16 bytes | 40 | 0 | **56 bytes** |

**Compressed oops** (`-XX:+UseCompressedOops`, default for heaps < 32 GB) reduce object references from 8 to 4 bytes. The trick: since objects are 8-byte aligned, the lowest 3 bits are always zero, so they store `address >> 3` in 4 bytes and reconstruct the full address as `value << 3`. This effectively addresses up to 32 GB of heap with 4-byte references.

Use the **JOL** (Java Object Layout) tool to inspect actual layouts:

```java
// org.openjdk.jol:jol-core
System.out.println(ClassLayout.parseInstance(new Object()).toPrintable());
```

> **Sources:** Oaks (2020) Ch.7 pp. 203–225 · Beckwith (2024) Ch.6 pp. 177–185 · [Aleksey Shipilev — Java Objects Inside Out](https://shipilev.net/jvm/objects-inside-out/) · [OpenJDK JOL tool](https://openjdk.org/projects/code-tools/jol/)

### Python: PyObject Struct and Object Internals

Every CPython object starts with a `PyObject` header (defined in `Include/object.h`):

```c
// PyObject — base for all Python objects
typedef struct _object {
    Py_ssize_t ob_refcnt;    // 8 bytes — reference count
    PyTypeObject *ob_type;   // 8 bytes — pointer to type object
} PyObject;                  // Total header: 16 bytes minimum

// PyVarObject — for variable-size objects (list, tuple, str, etc.)
typedef struct {
    PyObject ob_base;        // 16 bytes
    Py_ssize_t ob_size;      //  8 bytes — number of items
} PyVarObject;               // Total header: 24 bytes
```

**Object size breakdown:**

| Python type | Header | Data | Dict/Slots | Total |
|-------------|--------|------|------------|-------|
| `int(0)` | 16 (PyObject) | 4 (digit count) + 0 | — | **28 bytes** |
| `int(42)` | 16 | 4 + 4 (one digit) | — | **28 bytes** |
| `float(3.14)` | 16 (PyObject) | 8 (C double) | — | **24 bytes** |
| `True` | 16 (PyObject) | 12 (int data) | — | **28 bytes** |
| `None` | 16 (PyObject) | 0 | — | **16 bytes** |
| `""` (empty str) | 24 (PyVarObject) | ~25 (str metadata) | — | **49 bytes** |
| `[]` (empty list) | 24 (PyVarObject) | 32 (ob_item ptr + allocated) | — | **56 bytes** |
| `{}` (empty dict) | 24 | 40 (hash table) | — | **64 bytes** |
| Regular class instance | 16 | 0 | 48–112 (`__dict__`) | **~170 bytes** |
| `__slots__` instance | 16 | N × 8 (slot ptrs) | 0 | **~48 bytes** |

**`__slots__`** eliminates the per-instance `__dict__`, saving 40–65% memory for data-heavy objects. Ramalho measured 10 million `Vector2d` instances: **1.55 GiB without `__slots__`** vs **551 MiB with `__slots__`** (~65% reduction).

```python
class PointWithDict:
    def __init__(self, x, y):
        self.x = x  # stored in __dict__ (hash table)
        self.y = y

class PointWithSlots:
    __slots__ = ('x', 'y')
    def __init__(self, x, y):
        self.x = x  # stored in fixed-offset slots (like C struct fields)
        self.y = y

import sys
sys.getsizeof(PointWithDict(1.0, 2.0))   # ~48 bytes (+ __dict__ ~104 bytes + 2 floats)
sys.getsizeof(PointWithSlots(1.0, 2.0))  # ~48 bytes (+ 2 floats)
```

**`__slots__` caveats**: must redeclare in each subclass; instances can only have declared attributes; cannot use `@cached_property` without `'__dict__'` in slots; must include `'__weakref__'` in slots for weak reference support.

> **Sources:** Shaw (2020) Ch.9 pp. 285–315 · Gorelick & Ozsvald (2020) Ch.11 pp. 341–360 · Ramalho (2022) Ch.11 pp. 363–380 · [CPython source — Include/object.h](https://github.com/python/cpython/blob/main/Include/object.h) · [Python docs — sys.getsizeof](https://docs.python.org/3/library/sys.html#sys.getsizeof)

### Memory Layout Comparison: 1 Million Points

Storing 1,000,000 points (x, y as 64-bit floats):

| Language | Representation | Per-point | Total | Contiguous? |
|----------|---------------|-----------|-------|-------------|
| **Rust** | `Vec<Point>` where `struct Point { x: f64, y: f64 }` | 16 bytes | **16 MB** | Yes — cache-friendly |
| **Java** | `Point[]` where `class Point { double x, y; }` | 32 bytes (16 header + 16 data) + 4-8 bytes ref | **~36 MB** | No — array of pointers to scattered objects |
| **Python** | `list` of `Point(x, y)` instances | ~170 bytes (object + dict + 2 floats) | **~170 MB** | No — scattered heap objects |
| **Python** `__slots__` | `list` of `Point(x, y)` with `__slots__` | ~64 bytes (object + 2 float objects) | **~64 MB** | No — still scattered |
| **Python** NumPy | `np.array(shape=(1_000_000, 2), dtype=np.float64)` | 16 bytes | **16 MB** | Yes — C-contiguous |

---

## 8. Java GC Deep Dive: G1, ZGC, Shenandoah

The three modern Java garbage collector algorithms — their internal mechanisms, trade-offs, and the infrastructure (safepoints, card tables) that enables them.

### G1 Garbage Collector (Default Since Java 9)

G1 (Garbage First) divides the heap into **equal-sized regions** (~1–32 MB each, ~2048 regions total) rather than contiguous generations:

```
┌─────────────────────────────────────────────────┐
│ ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐ │
│ │ E││ E││ S││ O││ O││ H│ H││ O││ E││ S││  │ │
│ │  ││  ││  ││  ││  ││  │  ││  ││  ││  ││  │ │
│ └──┘└──┘└──┘└──┘└──┘└──┘└──┘└──┘└──┘└──┘└──┘ │
│  E=Eden  S=Survivor  O=Old  H=Humongous  =Free │
└─────────────────────────────────────────────────┘
```

Each region can dynamically be Eden, Survivor, Old, or Humongous (for objects ≥ 50% of region size). This flexibility lets G1 target pause times.

**G1 collection phases:**

1. **Young-only phase**: collects Eden + Survivor regions (stop-the-world, parallel, copying collector)
2. **Concurrent marking**: traces the entire heap concurrently with application threads to identify garbage in old regions
3. **Mixed collections**: once marking completes, G1 collects both young regions AND the old regions with the most garbage (hence "Garbage First") — selects regions that maximize reclaimed space within the pause target
4. **Full GC** (fallback): if mixed collections cannot keep up, a full stop-the-world compacting GC runs

**Key mechanisms:**

- **Remembered sets (RSets)**: per-region data structures tracking which other regions contain references into this region — avoids scanning the entire heap during partial collections
- **Card tables**: the heap is divided into 512-byte "cards"; a write barrier marks a card as dirty when a reference is updated, so only dirty cards need scanning to update remembered sets
- **Write barriers**: software barriers injected by the JIT compiler at every reference store — they update the card table and queue dirty cards for refinement

G1 uses **SATB (Snapshot-At-The-Beginning) marking** — a pre-write barrier records the old value of any reference overwritten during concurrent marking, ensuring the collector sees a consistent snapshot. This prevents objects from being incorrectly reclaimed when the application modifies references concurrently with the marker.

Since JDK 11, G1 supports **abortable mixed collections** — if the collector detects it will exceed the pause target, it can abort mid-collection, improving adherence to `-XX:MaxGCPauseMillis`.

**Key tuning flags:**

```bash
-XX:+UseG1GC                       # Enable G1 (default since Java 9)
-XX:MaxGCPauseMillis=200           # Target max pause (default: 200ms)
-XX:G1HeapRegionSize=N             # Region size (1-32 MB, auto-calculated)
-XX:InitiatingHeapOccupancyPercent=45  # Start concurrent marking at 45% heap
-XX:G1MixedGCCountTarget=8        # Number of mixed GCs after marking
-XX:G1HeapWastePercent=5           # Stop mixed GCs when reclaimable < 5%
```

> **Sources:** Oaks (2020) Ch.6 pp. 160–180 · Beckwith (2024) Ch.6 pp. 185–205 · Evans et al (2022) Ch.7 pp. 225–240 · [JEP 248 — Make G1 the Default GC](https://openjdk.org/jeps/248)

### ZGC: Sub-Millisecond Pauses

ZGC aims for **< 1ms pauses** regardless of heap size (tested up to 16 TB heaps). It uses **colored pointers** and **load barriers** for concurrent relocation.

**Colored pointers**: ZGC stores GC metadata in unused bits of 64-bit object pointers:

```
64-bit pointer layout (ZGC):
┌─────────────────────────────────────────────────────────────────────┐
│ [unused] [Finalizable] [Remapped] [Marked1] [Marked0] [44-bit address] │
└─────────────────────────────────────────────────────────────────────┘
```

**Load barrier**: every time a reference is loaded from memory, the barrier checks the pointer's color bits:
- If the pointer is "good" (correct color for the current GC phase), proceed normally
- If "bad" (stale color), remap to the new object location, fix the pointer, and continue

This allows ZGC to relocate objects **concurrently** with application threads — no stop-the-world for compaction. The only pauses are for thread scanning (root marking), which is proportional to the number of threads, not heap size.

**ZGC became generational in Java 21** — separate young and old generations within the ZGC framework, reducing total GC work.

```bash
-XX:+UseZGC                        # Enable ZGC
-XX:+ZGenerational                 # Enable generational ZGC (Java 21+)
```

### Shenandoah: Concurrent Compaction via Brooks Pointers

Shenandoah uses a similar goal (sub-millisecond pauses) but a different mechanism — **Brooks forwarding pointers**:

- Every object has an extra word (8 bytes) before it — a forwarding pointer that normally points to the object itself
- During concurrent relocation, the forwarding pointer is updated to point to the new copy
- Read and write barriers check the forwarding pointer on every object access

Shenandoah is available in **OpenJDK** but not in Oracle JDK.

```bash
-XX:+UseShenandoahGC               # Enable Shenandoah (OpenJDK only)
```

### Safepoints and Card Tables

**Safepoints** are positions in compiled code where a thread can be safely paused for GC operations:

- HotSpot injects **safepoint polls** at method returns and loop back-edges
- **Not** inserted in counted loops (`for (int i = 0; i < n; i++)`) — can cause long "time-to-safepoint" (TTSP) delays
- When GC needs to pause threads, it sets a flag; each thread checks at its next safepoint and suspends
- All threads must reach a safepoint before GC can proceed — one slow thread blocks the entire GC

**Card tables** optimize minor GC by tracking cross-generational references:

```
Heap memory:     |  512 bytes  |  512 bytes  |  512 bytes  | ...
Card table:      |  1 byte     |  1 byte     |  1 byte     | ...
                    (clean)       (dirty)       (clean)

When old-gen object writes a reference to young-gen:
  → write barrier marks the card as dirty
  → minor GC only scans dirty cards for old→young references
  → avoids scanning entire old generation
```

> **Sources:** Oaks (2020) Ch.6 pp. 191–201 · Beckwith (2024) Ch.1 pp. 30–42, Ch.6 pp. 205–217 · [JEP 333 — ZGC](https://openjdk.org/jeps/333) · [JEP 189 — Shenandoah](https://openjdk.org/jeps/189) · [Aleksey Shipilev — JVM Anatomy Quarks](https://shipilev.net/jvm/anatomy-quarks/)

### Java Reference Types (java.lang.ref)

Beyond strong references, Java provides three special reference types that interact with the GC:

| Reference type | Cleared when | `get()` returns | Use case |
|---------------|-------------|-----------------|----------|
| **SoftReference** | Memory pressure (before OOM) | Object or null | Caches — `-XX:SoftRefLRUPolicyMSPerMB` controls retention |
| **WeakReference** | Next GC cycle | Object or null | `WeakHashMap`, canonicalization, observer patterns |
| **PhantomReference** | After finalization | Always null | Post-mortem cleanup via `ReferenceQueue`; basis for `Cleaner` |

```java
// SoftReference for caching — cleared only under memory pressure
SoftReference<byte[]> cache = new SoftReference<>(new byte[10_000_000]);
byte[] data = cache.get();  // may return null if cleared by GC

// WeakReference — cleared at next GC regardless of memory
WeakReference<BigObject> weak = new WeakReference<>(obj);
obj = null;  // now eligible for collection
// weak.get() will return null after next GC

// PhantomReference — always returns null, used with ReferenceQueue for cleanup
ReferenceQueue<Resource> queue = new ReferenceQueue<>();
PhantomReference<Resource> phantom = new PhantomReference<>(resource, queue);
// Poll queue to detect when resource has been finalized
```

> **Sources:** Oaks (2020) Ch.7 pp. 225–248 · Valeev (2024) Ch.9 pp. 249–272 · [Java docs — java.lang.ref](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/package-summary.html)

### GC Collector Comparison

| Feature | G1 | ZGC | Shenandoah |
|---------|-----|------|-----------|
| **Default since** | Java 9 | — | — |
| **Target pause** | ~200ms (configurable) | < 1ms | < 10ms |
| **Heap limit** | Practical: ~64 GB | Tested: 16 TB | Tested: ~100 GB |
| **Concurrent compaction** | No (stop-the-world evacuation) | Yes (colored pointers + load barriers) | Yes (Brooks pointers + read/write barriers) |
| **Barrier type** | Write barrier (card table) | Load barrier | Read + write barriers |
| **Per-object overhead** | None | None (metadata in pointer bits) | 8 bytes (forwarding pointer) |
| **Generational** | Yes | Yes (Java 21+) | No |
| **Throughput overhead** | ~5% | ~5–15% | ~5–15% |
| **Availability** | All JDK distributions | Oracle JDK, OpenJDK | OpenJDK only |

---

## 9. Python Memory Internals: gc Module, `__del__`, Weak References

CPython's complete memory management picture — allocator layers, reference counting internals, the cycle collector API, and practical memory optimization.

### The gc Module and Cycle Collector Internals

CPython's cycle collector uses a **generational tri-color marking algorithm**:

```python
import gc

# Inspect current thresholds: (gen0_threshold, gen1_threshold, gen2_threshold)
gc.get_threshold()   # (700, 10, 10) by default

# gen0 collects when: allocations - deallocations > 700
# gen1 collects when: gen0 has collected 10 times since last gen1 collection
# gen2 collects when: gen1 has collected 10 times since last gen2 collection

# Freeze/unfreeze (useful for fork-based servers to avoid copy-on-write):
gc.freeze()    # move all current objects to a permanent generation (not collected)
gc.unfreeze()  # move them back
```

**Cycle detection algorithm (per generation):**

1. Merge target generation with all younger generations
2. For each container object, create `gc_refs` = copy of `ob_refcnt`
3. For each container, iterate its referents — decrement their `gc_refs`
4. Objects with `gc_refs > 0` are reachable from **outside** the set (external roots)
5. Trace from roots — mark everything reachable as alive
6. Remaining objects (unreachable) are finalized and freed

Only **container objects** participate — objects that can hold references to other objects:
- Participate: `list`, `dict`, `set`, `tuple`, `class instances`, `function`, `generator`
- Do NOT participate: `int`, `float`, `str`, `bytes`, `None`, `bool`

```python
import gc

# Force a full collection
unreachable_count = gc.collect()  # returns count of unreachable objects found

# Inspect garbage that couldn't be freed (has __del__ in cycles, pre-3.4)
gc.garbage  # list of uncollectable objects

# Disable/enable cycle collector
gc.disable()  # refcounting still works; only cycle collection stops
gc.enable()

# Get collection statistics
gc.get_stats()
# [{'collections': 72, 'collected': 412, 'uncollectable': 0},  # gen 0
#  {'collections': 6,  'collected': 68,  'uncollectable': 0},   # gen 1
#  {'collections': 1,  'collected': 0,   'uncollectable': 0}]   # gen 2
```

> **Sources:** Shaw (2020) Ch.7 pp. 200–219 · Martelli et al (2023) Ch.14 pp. 429–441 · [Python docs — gc module](https://docs.python.org/3/library/gc.html) · [CPython Developer Guide — Garbage collector design](https://devguide.python.org/internals/garbage-collector/)

### `__del__`, Weak References, sys.getrefcount

**`sys.getrefcount(obj)`** returns the current reference count. The count is always at least 2 because the function argument itself creates a temporary reference:

```python
import sys

a = "hello"
sys.getrefcount(a)  # 2+ (a + the function argument; possibly more from interning)

b = a
sys.getrefcount(a)  # 3+ (a + b + argument)

del b
sys.getrefcount(a)  # 2+ again
```

**`weakref.ref(obj)`** creates a weak reference that does **not** increment the refcount and does not prevent garbage collection:

```python
import weakref

class Cache:
    pass

obj = Cache()
weak = weakref.ref(obj)
weak()        # <Cache object> — returns the object
del obj
weak()        # None — object was garbage collected

# Weak references are essential for:
# - Caches (don't prevent cached items from being collected)
# - Observer patterns (observers don't keep subjects alive)
# - Parent back-references in tree structures
```

Not all types support weak references — `int`, `str`, `tuple`, `list`, `dict` do not. Custom classes support them by default, but classes using `__slots__` must include `'__weakref__'` in the slot list. Python also provides `WeakValueDictionary`, `WeakKeyDictionary`, and `WeakSet` for common patterns.

**`weakref.finalize()`** (Python 3.4+) — the recommended cleanup mechanism:

```python
import weakref, tempfile, os

class TempDir:
    def __init__(self):
        self.path = tempfile.mkdtemp()
        # Register cleanup — will run when TempDir is collected or at shutdown
        self._finalizer = weakref.finalize(
            self, shutil.rmtree, self.path
        )

    @property
    def alive(self):
        return self._finalizer.alive
```

> **Sources:** Ramalho (2022) Ch.6 pp. 220–228 · [Python docs — weakref module](https://docs.python.org/3/library/weakref.html) · [Python docs — sys.getrefcount](https://docs.python.org/3/library/sys.html#sys.getrefcount) · [PEP 205 — Weak References](https://peps.python.org/pep-0205/) · [PEP 442 — Safe object finalization](https://peps.python.org/pep-0442/)

### CPython Allocator Layers and Performance

**pymalloc** internals — the arena/pool/block hierarchy:

```
Arena (256 KB, allocated from OS via mmap/VirtualAlloc)
├── Pool 0 (4 KB, block size = 8 bytes)
│   ├── Block 0 (8 bytes)
│   ├── Block 1 (8 bytes)
│   └── ... (512 blocks per pool)
├── Pool 1 (4 KB, block size = 16 bytes)
│   ├── Block 0 (16 bytes)
│   └── ... (256 blocks per pool)
├── Pool 2 (4 KB, block size = 24 bytes)
│   └── ...
└── ... (64 pools per arena)

Block size classes: 8, 16, 24, 32, ..., 504, 512 bytes (64 classes)
Objects > 512 bytes → fall through to raw malloc
```

**Memory optimization techniques:**

```python
# 1. Use __slots__ for data-heavy classes
class Point:
    __slots__ = ('x', 'y')  # saves ~100 bytes per instance vs __dict__

# 2. Use array module for homogeneous numeric data
import array
arr = array.array('d', [1.0, 2.0, 3.0])  # 8 bytes per float (C array)
# vs list: ~28 bytes per float object + 8 bytes per list pointer

# 3. Use NumPy for large numeric datasets
import numpy as np
points = np.zeros((1_000_000, 2), dtype=np.float64)  # 16 MB total
# vs list of tuples: ~170 MB

# 4. Use generators instead of lists for one-pass processing
sum(x*x for x in range(1_000_000))  # O(1) memory
# vs sum([x*x for x in range(1_000_000)])  # O(n) memory

# 5. sys.getsizeof for direct size (does NOT include referenced objects)
import sys
d = {'a': [1, 2, 3], 'b': [4, 5, 6]}
sys.getsizeof(d)      # ~232 bytes (just the dict itself)
# Total memory including values is much larger
# For deep measurement, use pympler.asizeof or tracemalloc
```

**GIL and memory management**: the GIL (Global Interpreter Lock) exists primarily to protect reference counting from thread races. Without it, every `ob_refcnt` increment/decrement would need per-object locking. `PyMem_Malloc` and `PyObject_Malloc` require the GIL; only `PyMem_RawMalloc` is safe without it. The cycle collector runs while holding the GIL, pausing all threads. Python 3.13+ offers an experimental free-threaded build (`--disable-gil`).

> **Sources:** Shaw (2020) Ch.7 pp. 177–200 · Gorelick & Ozsvald (2020) Ch.6 pp. 109–140, Ch.11 pp. 341–390 · [Python docs — Memory Management](https://docs.python.org/3/c-api/memory.html)

### Python vs Java vs Rust: Allocator Comparison

| Aspect | Rust (system allocator) | Java (TLAB/GC) | Python (pymalloc) |
|--------|------------------------|-----------------|-------------------|
| **Fast path** | malloc (or jemalloc/mimalloc) | Bump-pointer in TLAB (extremely fast) | Pool allocation for ≤512 bytes |
| **Thread safety** | Allocator is thread-safe | TLABs are per-thread (no contention) | GIL protects allocator (single-threaded) |
| **Fragmentation** | Depends on allocator | Compacting GC eliminates fragmentation | Arenas return to OS but may fragment within |
| **Per-object overhead** | 0 bytes | 12–16 bytes (header) | 16+ bytes (refcount + type pointer) |
| **Custom allocators** | `#[global_allocator]` | Not for objects (Foreign Memory API for off-heap) | `PyMem_SetAllocator` (C extension API) |

---

## 10. Escape Analysis (JVM) & Arena Allocation Patterns

Advanced optimization — the JVM's ability to eliminate heap allocations entirely, and arena-based allocation across all three languages.

### JVM Escape Analysis

Escape analysis determines whether an object "escapes" the method that created it. Three escape states:

| State | Object visible to | Optimization |
|-------|-------------------|--------------|
| **NoEscape** | Only the creating method | **Scalar replacement**: fields become stack variables, object allocation eliminated entirely |
| **ArgEscape** | Called methods (but not other threads) | **Synchronization elimination**: locks on the object can be removed |
| **GlobalEscape** | Arbitrary code (stored in heap field, returned, etc.) | No optimization — normal heap allocation |

```java
// Escape analysis in action — object may be scalar-replaced
public double distance(double x1, double y1, double x2, double y2) {
    Point p = new Point(x2 - x1, y2 - y1);  // NoEscape — only used locally
    return Math.sqrt(p.x * p.x + p.y * p.y);
}
// C2 compiler can replace this with:
//   double px = x2 - x1;
//   double py = y2 - y1;
//   return Math.sqrt(px * px + py * py);
// No heap allocation at all!
```

**Scalar replacement** is only possible after **inlining** — the JIT compiler must first inline the constructor and any methods called on the object to prove the object doesn't escape.

**GraalVM's Partial Escape Analysis** is more powerful — it only materializes an object on code paths where it actually escapes:

```java
Point p = new Point(x, y);  // NOT allocated yet (virtualized)
if (condition) {
    store(p);                // escapes here — NOW allocated (materialized)
} else {
    return p.x + p.y;       // never escapes — scalar-replaced, no allocation
}
```

**Important for benchmarking**: escape analysis can eliminate the allocation you are trying to measure. Use JMH's `Blackhole.consume()` to prevent this:

```java
@Benchmark
public void measure(Blackhole bh) {
    Point p = new Point(1.0, 2.0);
    bh.consume(p);  // prevents escape analysis from eliminating p
}
```

> **Sources:** Oaks (2020) Ch.4 pp. 100–120 · Beckwith (2024) Ch.1 pp. 25–30 · [Aleksey Shipilev — JVM Anatomy Quark #18: Scalar Replacement](https://shipilev.net/jvm/anatomy-quarks/18-scalar-replacement/) · [GraalVM — Partial Escape Analysis](https://www.graalvm.org/latest/reference-manual/java/compiler/#partial-escape-analysis)

### Rust: No Escape Analysis Needed + Arena Allocation

Rust does not need escape analysis because the programmer **explicitly** chooses stack vs heap:

```rust
let p = Point { x: 1.0, y: 2.0 };  // stack — always, guaranteed
let p = Box::new(Point { x: 1.0, y: 2.0 });  // heap — explicit choice
```

**Arena allocation** — allocate many objects from a contiguous region, free everything at once:

```rust
// Using bumpalo crate — bump allocator
use bumpalo::Bump;

let arena = Bump::new();

// Extremely fast allocation — just increments a pointer
let node1 = arena.alloc(AstNode::Number(42));
let node2 = arena.alloc(AstNode::Add(node1, node1));
let node3 = arena.alloc(AstNode::Multiply(node2, node1));

// No individual deallocation — all memory freed when arena drops
drop(arena);  // everything freed at once
```

```rust
// Using typed-arena crate — type-safe arena
use typed_arena::Arena;

let arena: Arena<Node> = Arena::new();
let n1 = arena.alloc(Node { value: 1, next: None });
let n2 = arena.alloc(Node { value: 2, next: Some(n1) });
// All nodes freed when arena drops
```

**Nightly Allocator API** allows collections to use custom allocators:

```rust
#![feature(allocator_api)]
use bumpalo::Bump;

let bump = Bump::new();
let mut vec = Vec::new_in(&bump);  // Vec backed by bump allocator
vec.push(1);
vec.push(2);
// vec and its backing storage freed when bump drops
```

> **Sources:** Matthews (2024) Ch.5 pp. 110–118 · Gjengset (2022) Ch.12 pp. 211–222 · [bumpalo crate](https://docs.rs/bumpalo/latest/bumpalo/) · [typed-arena crate](https://docs.rs/typed-arena/latest/typed_arena/) · [Rust Allocator API](https://doc.rust-lang.org/std/alloc/trait.Allocator.html)

### Java: Foreign Memory API Arenas

Java 21's Foreign Function & Memory API provides explicit arena-like allocation for **off-heap memory**:

```java
// Arena.ofConfined() — single-thread access, deterministic cleanup
try (Arena arena = Arena.ofConfined()) {
    MemorySegment segment = arena.allocate(1024);  // 1 KB off-heap
    segment.set(ValueLayout.JAVA_INT, 0, 42);
    int value = segment.get(ValueLayout.JAVA_INT, 0);  // 42
}
// All memory allocated from this arena is freed here — deterministic!

// Arena.ofShared() — multi-thread access
try (Arena arena = Arena.ofShared()) {
    MemorySegment segment = arena.allocate(ValueLayout.JAVA_LONG, 1_000_000);
    // Can be accessed from multiple threads
}
```

**Arena types:**

| Arena factory | Thread access | Lifecycle |
|---------------|--------------|-----------|
| `Arena.ofConfined()` | Single thread only | Closed explicitly (try-with-resources) |
| `Arena.ofShared()` | Multiple threads | Closed explicitly |
| `Arena.ofAuto()` | Multiple threads | Managed by GC (no explicit close) |
| `Arena.global()` | Multiple threads | JVM lifetime (never closed) |

For regular Java objects, the closest to arena allocation is:
- **TLAB allocation** — already arena-like within the young generation (bump-pointer, per-thread)
- **Object pooling** — reuse objects to reduce GC pressure (e.g., thread pools, connection pools)
- **Off-heap buffers** — `ByteBuffer.allocateDirect()` for native memory

> **Sources:** Horstmann (2024) Vol. II Ch.13 pp. 160–174, Ch.2 pp. 42–52 · [JEP 454 — Foreign Function & Memory API](https://openjdk.org/jeps/454) · [Java docs — Arena](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/foreign/Arena.html)

### Python: Internal Arenas and Practical Alternatives

CPython's **PyArena** is used internally by the compiler for AST nodes — all nodes for a single compilation unit are allocated from the arena and freed together:

```c
// CPython internal — not accessible from Python code
PyArena *arena = _PyArena_New();
// ... allocate AST nodes from arena ...
_PyArena_Free(arena);  // free everything at once
```

Python application code has no direct access to arena allocation. Practical alternatives:

```python
# 1. NumPy arrays — single contiguous allocation
import numpy as np
data = np.zeros((1_000_000, 3), dtype=np.float64)  # 24 MB, C-contiguous

# 2. mmap — memory-mapped files for large datasets
import mmap
with open('data.bin', 'r+b') as f:
    mm = mmap.mmap(f.fileno(), 0)  # maps file into memory
    mm[0:4]  # read bytes directly from mapped memory

# 3. array module — compact C arrays for homogeneous data
import array
a = array.array('d', range(1_000_000))  # 8 bytes per element

# 4. struct module — pack data into bytes (manual "arena")
import struct
buffer = bytearray(16 * 1_000_000)
for i in range(1_000_000):
    struct.pack_into('dd', buffer, i * 16, float(i), float(i))
```

> **Sources:** Shaw (2020) Ch.7 pp. 195–200 · Martelli et al (2023) Ch.15 pp. 443–483 · [CPython Developer Guide — Memory management](https://devguide.python.org/internals/memory/)

### Arena Allocation Comparison

| Aspect | Rust (bumpalo/typed-arena) | Java (Foreign Memory API) | Python (internal PyArena) |
|--------|---------------------------|--------------------------|--------------------------|
| **Available to user code** | Yes (crate ecosystem) | Yes (Java 21+, off-heap) | No (internal only) |
| **Scope** | Any data type | Off-heap `MemorySegment` | AST nodes during compilation |
| **Allocation speed** | Bump pointer (fastest) | Bump pointer | Bump pointer |
| **Deallocation** | Drop the arena | Close the arena (try-with-resources) | Free the arena (C API) |
| **Type safety** | Full (generics + lifetimes) | Limited (raw memory segments) | None (C void pointers) |
| **GC interaction** | None | None (off-heap) | None (separate from pymalloc) |

---

## Consolidated Links

### Rust

- [Rust Reference — Memory Allocation](https://doc.rust-lang.org/reference/memory-allocation.html)
- [Rust Reference — Ownership](https://doc.rust-lang.org/reference/ownership.html)
- [Rust Reference — Type Layout](https://doc.rust-lang.org/reference/type-layout.html)
- [Rust Reference — Interior Mutability](https://doc.rust-lang.org/reference/interior-mutability.html)
- [Rust Reference — Destructors](https://doc.rust-lang.org/reference/destructors.html)
- [Rust Reference — Copy and Clone](https://doc.rust-lang.org/reference/special-types-and-traits.html#copy)
- [Rustonomicon — Ownership](https://doc.rust-lang.org/nomicon/ownership.html)
- [Rustonomicon — Lifetimes](https://doc.rust-lang.org/nomicon/lifetimes.html)
- [Rustonomicon — Borrow Splitting](https://doc.rust-lang.org/nomicon/borrow-splitting.html)
- [Rustonomicon — Data Representation](https://doc.rust-lang.org/nomicon/data.html)
- [Rustonomicon — Alternative Representations](https://doc.rust-lang.org/nomicon/other-reprs.html)
- [Rustonomicon — Drop Check](https://doc.rust-lang.org/nomicon/dropck.html)
- [Rustonomicon — Concurrency](https://doc.rust-lang.org/nomicon/concurrency.html)
- [Rust By Example — Box, stack and heap](https://doc.rust-lang.org/rust-by-example/std/box.html)
- [Rust By Example — Ownership/Moves](https://doc.rust-lang.org/rust-by-example/scope/move.html)
- [std docs — Cell module](https://doc.rust-lang.org/std/cell/index.html)
- [std docs — UnsafeCell](https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html)
- [std docs — Drop trait](https://doc.rust-lang.org/std/ops/trait.Drop.html)
- [std docs — Weak (Rc)](https://doc.rust-lang.org/std/rc/struct.Weak.html)
- [std docs — Weak (Arc)](https://doc.rust-lang.org/std/sync/struct.Weak.html)
- [std docs — Allocator API](https://doc.rust-lang.org/std/alloc/trait.Allocator.html)
- [RFC 2094 — Non-lexical lifetimes](https://rust-lang.github.io/rfcs/2094-nll.html)
- [bumpalo crate](https://docs.rs/bumpalo/latest/bumpalo/)
- [typed-arena crate](https://docs.rs/typed-arena/latest/typed_arena/)

### Java

- [JVM Specification — Run-Time Data Areas](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-2.html#jvms-2.5)
- [JLS — Assignment Expressions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.26)
- [JLS — Finalization](https://docs.oracle.com/javase/specs/jls/se21/html/jls-12.html#jls-12.6)
- [Oracle GC Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/)
- [Oracle — Escape Analysis](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/performance-enhancements-7.html#escapeAnalysis)
- [Java docs — AutoCloseable](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html)
- [Java docs — Cleaner](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/Cleaner.html)
- [Java docs — java.lang.ref package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/package-summary.html)
- [Java docs — WeakReference](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/WeakReference.html)
- [Java docs — SoftReference](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/SoftReference.html)
- [Java docs — PhantomReference](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ref/PhantomReference.html)
- [Java docs — Arena](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/foreign/Arena.html)
- [JEP 189 — Shenandoah](https://openjdk.org/jeps/189)
- [JEP 248 — Make G1 the Default GC](https://openjdk.org/jeps/248)
- [JEP 333 — ZGC](https://openjdk.org/jeps/333)
- [JEP 421 — Deprecate Finalization for Removal](https://openjdk.org/jeps/421)
- [JEP 454 — Foreign Function & Memory API](https://openjdk.org/jeps/454)
- [Aleksey Shipilev — JVM Anatomy Quarks](https://shipilev.net/jvm/anatomy-quarks/)
- [Aleksey Shipilev — Java Objects Inside Out](https://shipilev.net/jvm/objects-inside-out/)
- [Aleksey Shipilev — JVM Anatomy Quark #18: Scalar Replacement](https://shipilev.net/jvm/anatomy-quarks/18-scalar-replacement/)
- [GraalVM — Partial Escape Analysis](https://www.graalvm.org/latest/reference-manual/java/compiler/#partial-escape-analysis)
- [OpenJDK JOL tool](https://openjdk.org/projects/code-tools/jol/)
- [Baeldung — Stack Memory and Heap Space](https://www.baeldung.com/java-stack-heap)

### Python

- [Python docs — Memory Management](https://docs.python.org/3/c-api/memory.html)
- [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)
- [Python docs — `__del__`](https://docs.python.org/3/reference/datamodel.html#object.__del__)
- [Python docs — Context Managers](https://docs.python.org/3/reference/datamodel.html#context-managers)
- [Python docs — gc module](https://docs.python.org/3/library/gc.html)
- [Python docs — weakref module](https://docs.python.org/3/library/weakref.html)
- [Python docs — copy module](https://docs.python.org/3/library/copy.html)
- [Python docs — contextlib](https://docs.python.org/3/library/contextlib.html)
- [Python docs — sys.getrefcount](https://docs.python.org/3/library/sys.html#sys.getrefcount)
- [Python docs — sys.getsizeof](https://docs.python.org/3/library/sys.html#sys.getsizeof)
- [CPython source — Include/object.h](https://github.com/python/cpython/blob/main/Include/object.h)
- [CPython Developer Guide — Garbage collector design](https://devguide.python.org/internals/garbage-collector/)
- [CPython Developer Guide — Memory management](https://devguide.python.org/internals/memory/)
- [PEP 205 — Weak References](https://peps.python.org/pep-0205/)
- [PEP 343 — The "with" Statement](https://peps.python.org/pep-0343/)
- [PEP 442 — Safe object finalization](https://peps.python.org/pep-0442/)
- [RealPython — Memory Management in Python](https://realpython.com/python-memory-management/)

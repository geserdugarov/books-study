# Layer 2 · Topic 6 — Ownership & Mutability

> Comparative study of Rust, Java, and Python: how each language controls who can read and write what, and when — from immutability defaults through aliasing rules and shallow/deep immutability to interior mutability patterns and copy-on-write strategies.

---

## 1. Immutable by Default vs Mutable by Default

How each language treats mutability at the variable, field, and parameter level — the single design choice that shapes everything downstream.

### Rust: Immutable by Default

In Rust, **all bindings are immutable unless explicitly marked `mut`**. This is not a convention — it is enforced by the compiler.

```rust
let x = 5;
// x = 6;          // ERROR: cannot assign twice to immutable variable `x`

let mut y = 5;
y = 6;             // OK — explicitly opted into mutability
```

**Variables:** `let` creates an immutable binding. `let mut` creates a mutable one. The mutability applies to the entire bound value — there is no way to make individual struct fields mutable while the rest are immutable (struct-level mutability granularity is inherited from the binding).

```rust
struct Point { x: i32, y: i32 }

let p = Point { x: 1, y: 2 };
// p.x = 10;       // ERROR: p is not mutable

let mut q = Point { x: 1, y: 2 };
q.x = 10;          // OK — q is mutable, so all fields are
```

**Constants and statics:**

| Keyword | Meaning | When evaluated | Mutability |
|---------|---------|----------------|------------|
| `const` | Compile-time constant, inlined at every use site | Compile time (must be const-evaluable) | Always immutable |
| `static` | Fixed address in memory, one instance for the whole program | Program startup | Immutable by default; `static mut` exists but requires `unsafe` |
| `let` | Runtime binding | Runtime | Immutable by default; `let mut` for mutable |

```rust
const MAX_POINTS: u32 = 100_000;    // inlined everywhere, no memory address
static GREETING: &str = "Hello";     // one address, immutable
static mut COUNTER: u32 = 0;        // mutable static — requires unsafe to access
```

**Shadowing vs mutation:** Shadowing creates a *new* binding with the same name. The old binding is not mutated — it becomes inaccessible. Shadowing can change the type.

```rust
let x = 5;           // x: i32 = 5
let x = x + 1;       // new x: i32 = 6 (old x is shadowed, not mutated)
let x = "hello";     // new x: &str — type changed (impossible with mut)
```

**Function parameters** are immutable by default. To mutate a parameter inside the function, mark it `mut`:

```rust
fn process(mut input: String) -> String {
    input.push_str(" world");   // OK — input is a mutable local copy
    input
}
```

**Closures** capture variables with the minimum capability needed. If the closure only reads, it captures by `&T` (implements `Fn`). If it mutates, it captures by `&mut T` (implements `FnMut`). If it moves out, it takes ownership (implements `FnOnce`). The `move` keyword forces ownership transfer:

```rust
let mut count = 0;
let mut inc = || { count += 1; };  // captures count by &mut — FnMut
inc();
inc();
println!("{}", count);             // 2

let name = String::from("Alice");
let greet = move || println!("Hi, {}", name); // name moved into closure
// println!("{}", name);           // ERROR: name moved
```

**Definite initialization:** Rust variables are not initialized upon allocation — the entire stack frame is allocated in an uninitialized state. A variable may only be used after it has been definitely assigned through *all* reachable control flow paths. This is checked at compile time:

```rust
let x: i32;
if condition {
    x = 1;
} else {
    x = 2;
}
println!("{}", x);   // OK — x is definitely assigned in both branches

let y: i32;
if condition {
    y = 1;
}
// println!("{}", y);  // ERROR: y may be uninitialized (else branch missing)
```

**Design rationale:** immutability is the safer default. It prevents accidental mutation, lets the compiler assume values behind `&T` won't change (enabling optimizations), and makes code easier to reason about. You must *opt in* to the more dangerous capability.

> **Sources:** Klabnik & Nichols (2023) Ch.3 pp. 31–42 · Blandy & Orendorff (2017) Ch.5 pp. 93–100 · Gjengset (2022) Ch.1 pp. 1–5 · Bos (2023) Ch.1 pp. 1–7 · [Rust Reference — Variables](https://doc.rust-lang.org/reference/variables.html) · [Rust By Example — Variable Bindings / Mutability](https://doc.rust-lang.org/rust-by-example/variable_bindings/mut.html)

### Java: Mutable by Default, `final` as Opt-Out

Java variables and fields are **mutable by default**. The `final` keyword prevents reassignment but is opt-in and shallow.

```java
int x = 5;
x = 6;              // OK — mutable by default

final int y = 5;
// y = 6;           // ERROR: cannot assign a value to final variable y
```

**`final` for local variables:** Prevents reassignment. Since Java 10, `var` infers the type but does not imply `final`:

```java
final var name = "Alice";   // type inferred as String, cannot be reassigned
var age = 30;               // mutable — var does not imply final
age = 31;                   // OK
```

**`final` for fields:** Makes the field a "blank final" (must be assigned exactly once in the constructor) or an explicit constant:

```java
class Circle {
    final double radius;           // blank final — set in constructor
    static final double PI = 3.14; // compile-time constant
    
    Circle(double r) {
        this.radius = r;           // assigned once
    }
}
```

**Constant variables** — a `final` variable of primitive type or `String` initialized with a constant expression is a *constant variable* (JLS 15.29). The compiler inlines its value at every use site. Consequence: changing the value in a library requires recompiling all dependent code (the old value is baked into their bytecodes).

**`final` is shallow for reference types** — it prevents reassigning the reference but does not prevent mutating the referent:

```java
final List<String> list = new ArrayList<>();
list.add("hello");          // OK — mutating the list object
// list = new ArrayList<>(); // ERROR — cannot reassign the reference
```

**Bloch's five rules for immutable classes** (Effective Java, Item 17):

1. Don't provide mutators (no setters)
2. Ensure the class can't be extended (make it `final` or use static factories)
3. Make all fields `final`
4. Make all fields `private`
5. Ensure exclusive access to any mutable components (defensive copies)

```java
// Immutable class following all five rules
public final class Complex {
    private final double re;
    private final double im;
    
    public Complex(double re, double im) {
        this.re = re;
        this.im = im;
    }
    
    public Complex plus(Complex c) {
        return new Complex(re + c.re, im + c.im); // returns new instance
    }
    
    public double realPart()      { return re; }
    public double imaginaryPart() { return im; }
}
```

**Records** (Java 16+) are immutable data carriers with all fields implicitly `final`:

```java
record Point(int x, int y) {}

var p = new Point(1, 2);
// p.x = 10;      // ERROR — no setter, field is final
```

Records generate `equals()`, `hashCode()`, `toString()`, and accessor methods automatically. The class itself is implicitly `final`. However, records only provide **shallow immutability** — a record with a mutable field is not truly immutable:

```java
record Group(String name, List<String> members) {}

var g = new Group("Team", new ArrayList<>(List.of("Alice")));
g.members().add("Bob");   // Legal — the List inside is mutable!
```

**JMM `final` field semantics** (JLS 17.5): The Java Memory Model provides a critical guarantee — if an object is properly constructed (no `this` reference escapes during construction), all threads will see the correctly initialized values of its `final` fields without any explicit synchronization. This is Java's formal basis for safe publication of immutable objects.

```java
// Thread-safe without synchronization because all fields are final:
final class ImmutablePoint {
    final int x, y;
    ImmutablePoint(int x, int y) { this.x = x; this.y = y; }
}
```

This guarantee extends transitively to objects reachable through `final` fields (at least as up-to-date as when the constructor finished). `String` relies on this: its internal `byte[]` is `final`, so a `String`'s characters can never appear to change after construction, even under a data race — a critical security property.

**`ScopedValue`** (Java 21+, JEP 481) represents the modern evolution of immutability in Java — an explicitly immutable, bounded-lifetime context variable designed for virtual threads, replacing the mutable `ThreadLocal`:

```java
private static final ScopedValue<String> USER = ScopedValue.newInstance();

ScopedValue.runWhere(USER, "Alice", () -> {
    System.out.println(USER.get());  // "Alice"
    // USER cannot be mutated — only re-bound in a nested scope
});
```

> **Sources:** Horstmann (2024) Ch.3 pp. 41–52 · Bloch (2018) Item 17 pp. 80–86 · Evans et al. (2022) Ch.3 pp. 55–68 · Goetz et al. (2006) Ch.3 pp. 46–54 (§3.4–3.5 Immutability, Safe Publication) · Rahman (2025) Ch.5 pp. 217–230 · [JLS — final Variables](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.12.4) · [JLS — final Field Semantics](https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html#jls-17.5) · [JEP 395 — Records](https://openjdk.org/jeps/395) · [JEP 481 — Scoped Values](https://openjdk.org/jeps/481)

### Python: Mutable by Default, Immutability Through Type Choice

Python has **no language-level mechanism to prevent variable reassignment**. Variables are names (labels) bound to objects, not containers holding values. Immutability is a property of the *object*, not the *variable*.

```python
x = 5
x = "hello"       # perfectly valid — rebinding the name to a different object
x = [1, 2, 3]     # and again — Python does not constrain variable types
```

**Mutable vs immutable built-in types:**

| Immutable | Mutable |
|-----------|---------|
| `int`, `float`, `complex`, `bool` | `list` |
| `str`, `bytes` | `bytearray` |
| `tuple` | `dict` |
| `frozenset` | `set` |
| `None` | Most user-defined objects |

Immutable objects cannot be changed after creation. Mutable objects can. This distinction is fundamental to Python's data model.

**Object identity and reuse:** For immutable types, the runtime *may* return a reference to an existing object with the same type and value (e.g., `a = 256; b = 256; a is b` — may be `True` due to small integer caching). For mutable types, this never happens — `a = []; b = []` always creates distinct objects (`a is b` is always `False`).

```python
# Immutable — "modification" creates a new object
s = "hello"
id_before = id(s)
s = s + " world"       # new string object created
id_after = id(s)
print(id_before == id_after)  # False — different object

# Mutable — modification changes the same object
lst = [1, 2, 3]
id_before = id(lst)
lst.append(4)           # same list object modified in place
id_after = id(lst)
print(id_before == id_after)  # True — same object
```

**`typing.Final`** (PEP 591, Python 3.8+) provides an advisory annotation for type checkers:

```python
from typing import Final

MAX_SIZE: Final = 100
# MAX_SIZE = 200       # mypy error: Cannot assign to final name "MAX_SIZE"
                        # but Python runtime does NOT enforce this

class Config:
    DEBUG: Final[bool] = False
```

`typing.Final` tells mypy/pyright that a name should not be rebound, but it has **zero runtime effect**. There is no `const` keyword in Python.

**Mutable default arguments — the canonical Python pitfall:**

```python
# BUG: the default list is shared across all calls
def append_to(element, target=[]):
    target.append(element)
    return target

append_to(1)  # [1]
append_to(2)  # [1, 2] — not [2]! The default list is mutated

# FIX: use None as sentinel
def append_to(element, target=None):
    if target is None:
        target = []
    target.append(element)
    return target
```

This happens because default values are evaluated **once** at function definition time, not per call. The mutable default object is shared across all invocations.

**Mutable function arguments** — passing a mutable object to a function allows the function to modify the caller's data:

```python
def add_item(items, item):
    items.append(item)      # mutates the caller's list!

my_list = [1, 2, 3]
add_item(my_list, 4)
print(my_list)              # [1, 2, 3, 4] — modified by the function
```

Unlike Rust (where this would require `&mut`), Python provides no indication at the call site that data will be mutated. Defensive copying (`items = list(items)`) is the manual workaround.

> **Sources:** Ramalho (2022) Ch.6 pp. 201–212 · Martelli et al. (2023) Ch.3 pp. 33–60 · Viafore (2021) Ch.4 pp. 45–55 · Slatkin (2025) Item 30 pp. 135–137, Item 36 pp. 157–160 · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html) · [PEP 591 — Adding a final qualifier to typing](https://peps.python.org/pep-0591/) · [Python docs — typing.Final](https://docs.python.org/3/library/typing.html#typing.Final) · [mypy docs — Final names](https://mypy.readthedocs.io/en/stable/final_attrs.html)

### Mutability Defaults Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Variable default** | Immutable (`let`) | Mutable | Mutable (rebindable) |
| **Opt-in mechanism** | `let mut` | `final` (opt-out) | `typing.Final` (advisory only) |
| **Enforcement** | Compiler-enforced | Compiler-enforced (`final`) | Type checker only (no runtime) |
| **Field mutability** | Inherited from binding | Mutable unless `final` | Always mutable (by convention) |
| **Parameter mutability** | Immutable by default | Mutable by default | Always mutable (reference) |
| **Constant mechanism** | `const` (compile-time), `static` | `static final` | UPPER_CASE convention + `Final` |
| **Immutable class** | Default (no `mut`) | 5 rules (Bloch Item 17), records | `@dataclass(frozen=True)`, `tuple` |
| **Thread-safety implication** | `&T` safe to share (compiler-proven) | `final` fields safely published (JMM) | No formal guarantee |

---

## 2. Shared XOR Mutable — The Borrow Checker

The aliasing-plus-mutation problem: what happens when multiple parts of the code can see and modify the same data? Rust solves it at compile time, Java and Python cope at runtime.

### Rust: `&T` vs `&mut T` — Aliasing XOR Mutation

Rust enforces a fundamental invariant at compile time: **at any given time, you can have either one mutable reference (`&mut T`) or any number of shared references (`&T`), but not both**. This is the "shared XOR mutable" rule.

```rust
let mut s = String::from("hello");

// Multiple shared references — OK (aliasing without mutation)
let r1 = &s;
let r2 = &s;
println!("{}, {}", r1, r2);   // both valid simultaneously

// Mutable reference — OK (mutation without aliasing)
let r3 = &mut s;
r3.push_str(", world");
println!("{}", r3);

// Shared + mutable simultaneously — COMPILE ERROR
// let r4 = &s;
// let r5 = &mut s;           // ERROR: cannot borrow as mutable because
//                             // it is also borrowed as immutable
```

**What `&T` guarantees:** The referent will NOT change for the lifetime of the shared reference. This is a stronger guarantee than Java's `final` (which only prevents reassignment of the reference itself). If you hold `&Vec<String>`, neither the vector nor any string in it can be modified.

**What `&mut T` guarantees:** EXCLUSIVE access — no other reference (shared or mutable) to this data exists. The holder can read and write freely.

**Three categories of bugs eliminated at compile time:**

1. **Data races** — concurrent read + write to the same location is impossible because `&mut T` is exclusive:
```rust
use std::thread;
let mut data = vec![1, 2, 3];
// This would require sending &mut data to a thread while main still has &data
// The compiler prevents it
```

2. **Iterator invalidation** — you cannot modify a collection while iterating:
```rust
let mut v = vec![1, 2, 3];
for &item in &v {        // shared borrow of v
    // v.push(item * 2); // ERROR: cannot borrow v as mutable because
}                        // it is also borrowed as immutable (by the iterator)
```

3. **Aliased mutation** — you cannot modify data that another reference assumes is stable:
```rust
let mut s = String::from("hello");
let r = &s;              // shared borrow
// s.push_str(" world"); // ERROR: cannot borrow s as mutable while
println!("{}", r);       // shared borrow r is still in use
```

**Non-Lexical Lifetimes (NLL)** — since Rust 2018 (RFC 2094), borrows end at their *last use point*, not at the scope exit. This makes the borrow checker significantly more permissive:

```rust
let mut s = String::from("hello");
let r = &s;
println!("{}", r);       // r's last use — borrow ends here
s.push_str(" world");   // OK — no active shared borrows
```

**Borrow checker and data race prevention** (Bos): The aliasing rules that prevent iterator invalidation are the *same* rules that prevent data races. "Shared XOR mutable" is not two separate guarantees but one unified principle — if you can prove no aliased mutation, you automatically prove no data races.

> **Sources:** Klabnik & Nichols (2023) Ch.4 pp. 67–83 · Blandy & Orendorff (2017) Ch.5 pp. 100–121 · Gjengset (2022) Ch.1 pp. 5–8 · Bos (2023) Ch.1 pp. 7–12 · [Rustonomicon — Aliasing](https://doc.rust-lang.org/nomicon/aliasing.html) · [Rustonomicon — References](https://doc.rust-lang.org/nomicon/references.html) · [RFC 2094 — Non-lexical lifetimes](https://rust-lang.github.io/rfcs/2094-nll.html) · [Rust By Example — Borrowing](https://doc.rust-lang.org/rust-by-example/scope/borrow.html)

### Java: Unrestricted Aliasing, No Mutation Control

Java has **no aliasing restrictions**. Any number of variables can reference the same object, and any of them can mutate it at any time. The language provides no compile-time protection against aliased mutation.

```java
List<String> list1 = new ArrayList<>();
list1.add("hello");

List<String> list2 = list1;   // alias — same object
list2.add("world");
System.out.println(list1);    // [hello, world] — mutated through list2!
```

**Pass-by-value of references:** Java passes a *copy of the reference*, not the object. The called method can mutate the object through its copy of the reference, but cannot reassign the caller's variable:

```java
void addItem(List<String> items) {
    items.add("new");          // mutates the original object — visible to caller
    items = new ArrayList<>(); // reassigns local copy — caller unaffected
}
```

**Defensive copying** (Bloch Item 50): Since Java has no aliasing control, immutable classes must defensively copy mutable components on the way in and out:

```java
public final class Period {
    private final Date start;
    private final Date end;
    
    public Period(Date start, Date end) {
        // Defensive copies — protect against caller mutating after construction
        this.start = new Date(start.getTime());
        this.end = new Date(end.getTime());
        if (this.start.compareTo(this.end) > 0)
            throw new IllegalArgumentException();
    }
    
    public Date start() {
        return new Date(start.getTime());  // Defensive copy on the way out
    }
    
    public Date end() {
        return new Date(end.getTime());
    }
}
```

Without defensive copies, a caller could mutate the `Date` objects after construction, breaking the invariant that `start <= end`.

**Mutable objects as HashMap keys** — a subtle bug caused by aliased mutation (Valeev Ch.8):

```java
List<String> key = new ArrayList<>(List.of("a", "b"));
Map<List<String>, String> map = new HashMap<>();
map.put(key, "value");

key.add("c");           // mutates the key after insertion!
map.get(key);           // null — hashCode changed, key unfindable
map.get(List.of("a", "b")); // null — original hash bucket, wrong key
// The entry is effectively lost
```

**Unmodifiable collections are views, not copies:**

```java
List<String> original = new ArrayList<>(List.of("a", "b"));
List<String> unmod = Collections.unmodifiableList(original);

// unmod.add("c");       // throws UnsupportedOperationException
original.add("c");       // OK — modifies the underlying list
System.out.println(unmod); // [a, b, c] — the "unmodifiable" view reflects changes!
```

**Visibility problem in multi-threaded code** (Goetz Ch.3): Even without explicit aliasing, threads can see stale values because the JMM permits caching and reordering:

```java
// Thread A                          // Thread B
boolean ready = false;               // Both threads share 'ready' and 'number'
int number = 0;

// Thread A:                         // Thread B:
number = 42;                         while (!ready) Thread.yield();
ready = true;                        System.out.println(number);
// Thread B might print 0! — no happens-before relationship guarantees visibility
```

Without `volatile` or `synchronized`, thread B may never see `ready = true` or may see `ready = true` but `number` still as 0 due to reordering.

> **Sources:** Horstmann (2024) Ch.4 pp. 55–67 · Bloch (2018) Item 50 pp. 231–235, Item 78 pp. 311–316 · Goetz et al. (2006) Ch.3 pp. 33–45 · Valeev (2024) Ch.8 pp. 213–230 · [JLS — Assignment Expressions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.26)

### Python: Shared References Everywhere

Python's variable model is pure reference semantics — every variable is a name (label) pointing to an object. Assignment never copies the object:

```python
a = [1, 2, 3]
b = a               # b is now an alias for the same list object
b.append(4)
print(a)            # [1, 2, 3, 4] — mutated through b

print(a is b)       # True — same identity (same object in memory)
print(id(a) == id(b))  # True
```

**"Variables are not boxes"** (Ramalho): Think of Python variables as sticky notes attached to objects, not as boxes containing values. Multiple sticky notes can be attached to the same object.

**Identity vs equality:**

```python
a = [1, 2, 3]
b = [1, 2, 3]
print(a == b)     # True — equal values
print(a is b)     # False — different objects

c = a
print(a is c)     # True — same object (alias)
```

**Shallow and deep copies:**

```python
import copy

original = [[1, 2], [3, 4]]

shallow = copy.copy(original)      # or: list(original), original[:]
shallow[0].append(5)
print(original)   # [[1, 2, 5], [3, 4]] — inner list mutated!
# Shallow copy creates a new outer list but shares the inner lists

deep = copy.deepcopy(original)
deep[0].append(6)
print(original)   # [[1, 2, 5], [3, 4]] — unaffected by deep copy mutation
```

**Iterator invalidation in Python** — behavior varies by collection type:

```python
# list — silently produces wrong results (skips or repeats elements)
lst = [1, 2, 3, 4, 5]
for item in lst:
    if item == 2:
        lst.remove(item)
print(lst)  # [1, 3, 4, 5] — looks OK here, but...

lst = [1, 2, 2, 3]
for item in lst:
    if item == 2:
        lst.remove(item)
print(lst)  # [1, 2, 3] — missed the second 2!

# dict/set — RuntimeError since Python 3
d = {"a": 1, "b": 2, "c": 3}
for key in d:
    if d[key] == 2:
        del d[key]         # RuntimeError: dictionary changed size during iteration

# Fix: iterate over a copy
for key in list(d):        # snapshot of keys
    if d[key] == 2:
        del d[key]         # safe
```

**The mutable default argument bug** is Python's most famous aliased mutation trap:

```python
def bad_func(items=[]):
    items.append("x")
    return items

bad_func()   # ['x']
bad_func()   # ['x', 'x'] — the default list persists across calls!
bad_func()   # ['x', 'x', 'x']
```

> **Sources:** Ramalho (2022) Ch.6 pp. 212–228 · Martelli et al. (2023) Ch.8 pp. 247–265 · Slatkin (2025) Item 22 pp. 92–97 · [Python docs — copy module](https://docs.python.org/3/library/copy.html) · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)

### Aliasing & Mutation Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Aliasing control** | Compile-time: shared XOR mutable | None — unrestricted | None — unrestricted |
| **Multiple readers** | `&T` — any number allowed | Always allowed | Always allowed |
| **Exclusive writer** | `&mut T` — enforced by compiler | Not enforced | Not enforced |
| **Data race prevention** | Compile-time guarantee | Runtime: `synchronized`, `volatile` | GIL (CPython only, partial) |
| **Iterator invalidation** | Compile error | `ConcurrentModificationException` | Silent bugs or `RuntimeError` |
| **Defensive copying** | Not needed (`&T` is enough) | Manual (Bloch Item 50) | Manual (`copy.copy`/`deepcopy`) |
| **Cost of safety** | Restricted valid programs | Programmer discipline | Programmer discipline |

---

## 3. Shallow vs Deep Immutability

The critical distinction: does "immutable" mean just the top-level container, or the entire transitive object graph?

### Rust: Deep Immutability by Default Through Ownership

In Rust, immutability is **transitive** — when a binding is immutable, the entire ownership tree rooted at that binding is immutable. This is deep immutability by default.

```rust
let v: Vec<String> = vec![
    String::from("hello"),
    String::from("world"),
];

// All of these are compile errors:
// v.push(String::from("!"));     // cannot mutate the Vec
// v[0].push_str(" there");       // cannot mutate the String elements
// v[0].as_bytes_mut();           // cannot get mutable access to the bytes
```

A single `let` (without `mut`) freezes the entire tree: the `Vec`, its `String` elements, and the UTF-8 bytes within those strings. There is no way to "reach inside" and mutate a nested component.

**Shared references are transitively immutable:** If you have `&Vec<String>`, you cannot mutate the `Vec`, any `String` in it, or any byte in any string. The only way to get mutable access to nested data through a shared reference is through interior mutability types (covered in Section 4).

```rust
fn read_only(v: &Vec<String>) {
    // v.push(String::from("!"));  // ERROR: cannot borrow as mutable
    // v[0].push_str("!");         // ERROR: cannot borrow as mutable
    println!("{}", v[0]);          // reading is fine
}
```

**This deep immutability is what makes `&T` safe to share** — if you give out `&Vec<String>`, you know with certainty that no one holding that reference can modify any part of your data. No defensive copies needed.

**Mutable bindings are also transitively mutable:**

```rust
let mut v = vec![String::from("hello")];
v.push(String::from("world"));   // OK
v[0].push_str("!");              // OK — nested mutation through mut binding
```

**The only escape: interior mutability.** Types like `Cell<T>`, `RefCell<T>`, and `Mutex<T>` allow mutation through shared references, but they must be explicitly declared in the type. If a type contains no interior mutability, `&T` truly means "fully immutable."

> **Sources:** Klabnik & Nichols (2023) Ch.4 pp. 59–67 · Blandy & Orendorff (2017) Ch.5 pp. 93–100 · McNamara (2021) Ch.4 pp. 107–120 · [Rust API Guidelines — Predictability](https://rust-lang.github.io/api-guidelines/predictability.html)

### Java: `final` Is Shallow

Java's `final` prevents reassignment of the reference, but does NOT prevent mutation of the object behind it. All of Java's immutability mechanisms are shallow.

**`final` — prevents reassignment only:**

```java
final List<String> list = new ArrayList<>();
list.add("hello");          // OK — mutating the list's contents
list.add("world");          // OK
// list = new ArrayList<>(); // ERROR — cannot reassign the final reference
```

**`Collections.unmodifiableList` — a read-only view, not a deep freeze:**

```java
List<StringBuilder> original = new ArrayList<>();
original.add(new StringBuilder("hello"));

List<StringBuilder> unmod = Collections.unmodifiableList(original);
// unmod.add(new StringBuilder("world"));  // throws UnsupportedOperationException
unmod.get(0).append(" world");             // OK — the StringBuilder is mutable!
original.add(new StringBuilder("!"));      // OK — the original list is still mutable
System.out.println(unmod.size());           // 2 — reflects the change!
```

Key pitfall: `unmodifiableList` is a *view* — modifications to the backing list are visible through the wrapper.

**`List.of()` / `Set.of()` / `Map.of()` (Java 9+) — structurally immutable, but elements can still be mutable:**

```java
List<StringBuilder> immutable = List.of(new StringBuilder("hello"));
// immutable.add(new StringBuilder("world"));  // throws UnsupportedOperationException
immutable.get(0).append(" world");             // OK — element itself is mutable
System.out.println(immutable.get(0));           // "hello world"
```

`List.of()` creates a truly immutable collection structure (not a view — no backing list can change), but it does not deep-freeze the elements.

**Records — shallow immutability:**

```java
record Team(String name, List<String> members) {}

var team = new Team("Alpha", new ArrayList<>(List.of("Alice")));
team.members().add("Bob");    // Legal! The list inside the record is mutable
System.out.println(team.members()); // [Alice, Bob]

// Deeply immutable record — all components must be immutable types:
record Point(int x, int y) {} // truly immutable — int is a value type
```

**JMM `final` field initialization safety** (JLS 17.5, Goetz Ch.16): The Java Memory Model guarantees that if an object is properly constructed (the `this` reference does not escape during construction), all threads will see the correctly initialized values of `final` fields. But this guarantee is **shallow** — it only covers the reference stored in the `final` field, not the object graph:

```java
class SafePoint {
    final int x, y;                     // threads see correct values
    SafePoint(int x, int y) { this.x = x; this.y = y; }
}

class UnsafeTeam {
    final List<String> members;         // threads see the reference correctly
    UnsafeTeam(List<String> members) {  // but List contents can be mutated
        this.members = members;         // by anyone who has a reference
    }
}
```

**Making Java objects deeply immutable requires discipline:**

| Mechanism | Depth | Guarantees |
|-----------|-------|------------|
| `final` field | Shallow — reference only | JMM: safe publication of the reference |
| `Collections.unmodifiableList()` | Shallow — structure only, wraps mutable list | `UnsupportedOperationException` on add/remove |
| `List.of()` | Shallow — structure only | Truly immutable structure, but not elements |
| Record | Shallow — all fields `final` | Same as `final` fields — reference only |
| Bloch's 5 rules | Deep (if followed correctly) | Manual — defensive copies required |

> **Sources:** Bloch (2018) Item 17 pp. 80–86, Item 50 pp. 231–235 · Goetz et al. (2006) Ch.16 pp. 337–352 · Valeev (2024) Ch.8 pp. 213–248 · Evans et al. (2022) Ch.5 pp. 119–135 · [Java docs — Collections.unmodifiableList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html#unmodifiableList(java.util.List)) · [Java docs — List.of](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#of()) · [JEP 269 — Convenience Factory Methods for Collections](https://openjdk.org/jeps/269)

### Python: Structural Immutability With Mutable Elements

Python's immutable types — `tuple`, `frozenset`, `str`, `bytes`, `int`, `float` — are **structurally** immutable: their internal structure (which references they hold) cannot change. But this is shallow — the objects they reference can still be mutable.

**Tuples — "relative immutability":**

```python
t = ([1, 2], [3, 4])       # tuple containing two lists

# The tuple structure is immutable:
# t[0] = [5, 6]            # TypeError: 'tuple' object does not support item assignment
# t += ([5, 6],)           # creates a NEW tuple — doesn't modify t in place
#                          # (actually t = t + ([5,6],) — rebinding, not mutation)

# But the list elements are mutable:
t[0].append(5)
print(t)                    # ([1, 2, 5], [3, 4]) — the tuple "changed"!
```

The tuple itself hasn't changed — it still holds references to the same two list objects. But one of those list objects was mutated through its reference.

**Hashability implications:** An object is hashable only if its hash never changes during its lifetime. Since mutable objects can change, they are generally not hashable:

```python
# Tuple of immutables — hashable
hash((1, 2, "hello"))       # works

# Tuple containing a mutable — not hashable
hash(([1, 2], 3))           # TypeError: unhashable type: 'list'

# frozenset requires all elements to be hashable
frozenset([1, 2, 3])        # works — ints are hashable
frozenset([[1], [2]])        # TypeError: unhashable type: 'list'
```

**`@dataclass(frozen=True)` — shallow immutability:**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Team:
    name: str
    members: list  # mutable type!

team = Team("Alpha", ["Alice"])
# team.name = "Beta"          # FrozenInstanceError — cannot reassign attributes
# team.members = ["Bob"]      # FrozenInstanceError — cannot reassign

team.members.append("Bob")    # Works! The list itself is mutable
print(team.members)            # ["Alice", "Bob"]

# Consequence for hashing:
# hash(team)                  # TypeError — unhashable because members is a list
```

To achieve true deep immutability with frozen dataclasses, all fields must hold immutable types:

```python
@dataclass(frozen=True)
class ImmutableTeam:
    name: str               # immutable
    members: tuple[str, ...]  # immutable
    
team = ImmutableTeam("Alpha", ("Alice", "Bob"))
hash(team)                  # works — all fields are deeply immutable
```

**`frozenset` — immutable set:**

```python
fs = frozenset([1, 2, 3])
# fs.add(4)                  # AttributeError: 'frozenset' has no attribute 'add'
# fs |= {4}                  # creates a new frozenset — doesn't modify fs

# frozenset can be a dict key or set member (it's hashable)
d = {fs: "value"}
s = {frozenset([1, 2]), frozenset([3, 4])}
```

**`types.MappingProxyType` — read-only dict view:**

```python
from types import MappingProxyType

original = {"key": "value", "items": [1, 2, 3]}
proxy = MappingProxyType(original)

# proxy["key"] = "new"       # TypeError: 'mappingproxy' object does not support item assignment
# proxy["new_key"] = "x"     # TypeError

proxy["items"].append(4)      # Works! The list inside is still mutable
original["added"] = True      # The proxy reflects changes to the original
print(proxy["added"])         # True
```

`MappingProxyType` is analogous to Java's `Collections.unmodifiableMap` — it prevents structural modification through the proxy but does not deep-freeze values, and changes to the original are visible. Since Python 3.12, `MappingProxyType` is hashable (if all values are hashable), enabling its use as a dict key.

> **Sources:** Ramalho (2022) Ch.6 pp. 212–220, Ch.2 pp. 21–40, Ch.3 pp. 77–95, Ch.5 pp. 180–200 · Viafore (2021) Ch.9 pp. 123–134 · Slatkin (2025) Item 56 pp. 250–259 · [Python docs — tuple](https://docs.python.org/3/library/stdtypes.html#tuples) · [Python docs — frozenset](https://docs.python.org/3/library/stdtypes.html#frozenset) · [Python docs — types.MappingProxyType](https://docs.python.org/3/library/types.html#types.MappingProxyType) · [Python docs — dataclasses (frozen)](https://docs.python.org/3/library/dataclasses.html#frozen-instances) · [PEP 557 — Data Classes](https://peps.python.org/pep-0557/)

### Immutability Depth Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Default depth** | Deep (transitive through ownership) | Shallow (`final` = reference only) | Shallow (structural only) |
| **`let v = vec![String]`** | Vec + all Strings frozen | N/A | N/A |
| **`final List<String>`** | N/A | List ref frozen; list & strings mutable | N/A |
| **`t = (["a"],)`** | N/A | N/A | Tuple struct frozen; list mutable |
| **Read-only collection** | `&Vec<T>` — deep | `Collections.unmodifiableList` — view, shallow | `tuple` — shallow; `MappingProxyType` — view |
| **Truly immutable collection** | Any `&T` without interior mutability | `List.of()` — structure only | Only if all elements are immutable types |
| **Deep immutability recipe** | Default — just use `let` | Bloch's 5 rules + defensive copies | Use only immutable types in the graph |
| **Hashable guarantee** | Compiler-enforced (Hash trait) | Convention (equals/hashCode contract) | `TypeError` if mutable elements found |

**Concrete example — a team roster:**

```rust
// Rust: deeply immutable by default
let roster = Team {
    name: String::from("Alpha"),
    members: vec!["Alice".into(), "Bob".into()],
};
// roster.members.push("Charlie".into());  // COMPILE ERROR
// roster.members[0].push_str("!");        // COMPILE ERROR
```

```java
// Java: shallowly immutable
record Team(String name, List<String> members) {}
var team = new Team("Alpha", new ArrayList<>(List.of("Alice", "Bob")));
team.members().add("Charlie");  // Legal! Record is shallowly immutable
```

```python
# Python: shallowly immutable
@dataclass(frozen=True)
class Team:
    name: str
    members: list

team = Team("Alpha", ["Alice", "Bob"])
# team.members = []           # FrozenInstanceError
team.members.append("Charlie") # Legal! List is mutable
```

---

## 4. Interior Mutability Patterns

The controlled escape hatch: how to mutate data through an ostensibly immutable reference. In Rust this is a formal concept with dedicated types; in Java and Python the analogous patterns exist but without type-system enforcement.

### Rust: A Hierarchy of Interior Mutability Types

Interior mutability in Rust means **mutation through a shared reference (`&T`)**. It is not a hack — it is a deliberate, type-safe design pattern for cases where the shared-XOR-mutable rule is too restrictive (e.g., caches, reference counters, shared state in concurrent programs).

All interior mutability is built on one primitive: **`UnsafeCell<T>`** — the *only* type in Rust that permits aliased mutation. Every other interior mutability type (`Cell`, `RefCell`, `Mutex`, `RwLock`, `Atomic*`, `OnceCell`) wraps `UnsafeCell` and provides a safe API around it.

**The interior mutability hierarchy:**

```
                    UnsafeCell<T>
                    (the primitive — unsafe API)
                    ┌──────┴──────┐
                  Single-thread  Multi-thread
                    │               │
              ┌─────┤         ┌─────┤
              │     │         │     │
           Cell<T> RefCell<T> Mutex<T> RwLock<T>
           (Copy)  (any T)   (excl.)  (read/write)
                              │
                           Atomic*
                           (lock-free)
```

**`Cell<T>`** — zero-cost interior mutability for `Copy` types (single-threaded):

```rust
use std::cell::Cell;

let cell = Cell::new(5);    // note: no `mut` needed
cell.set(10);               // mutation through shared reference
let val = cell.get();       // returns a copy — 10

// Cell works by moving values in and out (get copies, set overwrites)
// No borrowing of the inner value — so no runtime checks needed
// Zero overhead — identical to raw memory access
```

- Works only with `Copy` types (cannot hand out references to the interior)
- `!Sync` — cannot be shared between threads
- Zero runtime overhead — no reference counting, no locks

**`RefCell<T>`** — runtime borrow checking for any type (single-threaded):

```rust
use std::cell::RefCell;

let cell = RefCell::new(vec![1, 2, 3]);

// Borrow checking happens at RUNTIME (panics on violation)
{
    let r1 = cell.borrow();          // shared borrow (Ref<Vec<i32>>)
    let r2 = cell.borrow();          // OK — multiple shared borrows
    println!("{:?}, {:?}", r1, r2);
}

{
    let mut r3 = cell.borrow_mut();  // exclusive borrow (RefMut<Vec<i32>>)
    r3.push(4);
}

// This PANICS at runtime:
// let r4 = cell.borrow();
// let r5 = cell.borrow_mut();  // panic: already borrowed
```

- Same rules as compile-time borrowing, but checked at runtime
- `borrow()` returns `Ref<T>` (shared), `borrow_mut()` returns `RefMut<T>` (exclusive)
- Panics if rules violated (use `try_borrow` / `try_borrow_mut` for non-panicking versions)
- `!Sync` — cannot be shared between threads

**Common pattern — `Rc<RefCell<T>>` for shared mutable state:**

```rust
use std::cell::RefCell;
use std::rc::Rc;

let shared = Rc::new(RefCell::new(vec![1, 2, 3]));

let clone1 = Rc::clone(&shared);   // another owner
let clone2 = Rc::clone(&shared);   // yet another

clone1.borrow_mut().push(4);       // mutate through first owner
clone2.borrow_mut().push(5);       // mutate through second owner

println!("{:?}", shared.borrow()); // [1, 2, 3, 4, 5]
```

**`Mutex<T>`** — mutual exclusion for multi-threaded code:

```rust
use std::sync::{Mutex, Arc};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    handles.push(thread::spawn(move || {
        let mut num = counter.lock().unwrap(); // acquires lock
        *num += 1;
        // lock is released when `num` (MutexGuard) is dropped
    }));
}

for handle in handles { handle.join().unwrap(); }
println!("Count: {}", *counter.lock().unwrap()); // 10
```

- `lock()` returns `MutexGuard<T>` — RAII guard that auto-releases
- `Sync` — safe to share between threads (via `Arc<Mutex<T>>`)
- Blocks the thread on contention (OS-level lock)
- `Mutex<T>` is the multi-threaded analogue of `RefCell<T>`
- `Arc<Mutex<T>>` is the multi-threaded analogue of `Rc<RefCell<T>>`

**`RwLock<T>`** — reader-writer lock (multi-threaded):

```rust
use std::sync::RwLock;

let lock = RwLock::new(vec![1, 2, 3]);

// Multiple readers simultaneously
{
    let r1 = lock.read().unwrap();
    let r2 = lock.read().unwrap();
    println!("{:?}, {:?}", r1, r2);  // both active
}

// Exclusive writer
{
    let mut w = lock.write().unwrap();
    w.push(4);
}
```

- Multiple `read()` locks OR one `write()` lock — the same rule as `&T`/`&mut T`
- More granular than `Mutex` for read-heavy workloads

**Atomic types** — lock-free interior mutability:

```rust
use std::sync::atomic::{AtomicI32, Ordering};

let counter = AtomicI32::new(0);
counter.fetch_add(1, Ordering::Relaxed);    // atomic increment
let val = counter.load(Ordering::Relaxed);   // atomic read

// compare_exchange for lock-free algorithms
let current = counter.load(Ordering::Relaxed);
counter.compare_exchange(current, current + 1, Ordering::AcqRel, Ordering::Relaxed);
```

- `AtomicBool`, `AtomicI32`, `AtomicU64`, `AtomicPtr<T>`, etc.
- No locks — uses hardware CAS (compare-and-swap) instructions
- Requires specifying memory ordering (`Relaxed`, `Acquire`, `Release`, `AcqRel`, `SeqCst`)

**`OnceCell<T>` / `OnceLock<T>`** — write-once interior mutability:

```rust
use std::sync::OnceLock;

static CONFIG: OnceLock<String> = OnceLock::new();

fn get_config() -> &'static str {
    CONFIG.get_or_init(|| {
        // expensive initialization — runs only once
        String::from("default_config")
    })
}
```

- `OnceCell<T>` — single-threaded (`!Sync`), replaces `lazy_static!` for local values
- `OnceLock<T>` — multi-threaded (`Sync`), safe for `static` items; never poisons on panic (unlike `Mutex`)
- Write exactly once, then read immutably forever
- Stabilized in Rust 1.70 (`OnceCell`) and 1.80 (`OnceLock`)

**`LazyCell<T,F>` / `LazyLock<T,F>`** — auto-initializing on first access via `Deref`:

```rust
use std::sync::LazyLock;

static LOGGER: LazyLock<Logger> = LazyLock::new(|| {
    Logger::init()   // runs on first access
});

fn main() {
    LOGGER.log("hello");   // first access triggers init via Deref
}
```

- `LazyCell` — single-threaded; `LazyLock` — multi-threaded
- Unlike `OnceCell`/`OnceLock`, the init closure is fixed at construction time

**Caching pattern with `OnceCell`** — a common interior mutability use case in logically-immutable methods:

```rust
use std::cell::OnceCell;

struct Graph {
    edges: Vec<(i32, i32)>,
    span_tree_cache: OnceCell<Vec<(i32, i32)>>,
}

impl Graph {
    fn minimum_spanning_tree(&self) -> &[(i32, i32)] {
        self.span_tree_cache.get_or_init(|| self.compute_mst())
    }
    fn compute_mst(&self) -> Vec<(i32, i32)> { /* expensive */ vec![] }
}
// Graph appears immutable (&self) but caches the MST on first call
```

**`Send` and `Sync` — the thread-safety markers:**

| Trait | Meaning | Examples |
|-------|---------|---------|
| `Send` | Can be transferred to another thread | Most types; `Rc` is `!Send` |
| `Sync` | Can be shared between threads via `&T` | `Mutex<T>`, `RwLock<T>`, `Atomic*`; `Cell<T>` and `RefCell<T>` are `!Sync` |

The compiler automatically prevents using `!Sync` types (like `RefCell`) in multi-threaded contexts. You must use `Mutex`/`RwLock`/atomics instead.

> **Sources:** Blandy & Orendorff (2017) Ch.9 pp. 200–209, Ch.19 pp. 457–480 · Klabnik & Nichols (2023) Ch.15 pp. 335–345, Ch.16 pp. 353–370 · Gjengset (2022) Ch.1 pp. 6–8 · Bos (2023) Ch.1 pp. 12–29, Ch.2 pp. 41–47, Ch.4 pp. 75–83, Ch.9 pp. 181–211 · [Rust Reference — Interior Mutability](https://doc.rust-lang.org/reference/interior-mutability.html) · [std docs — Cell module](https://doc.rust-lang.org/std/cell/index.html) · [std docs — UnsafeCell](https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html) · [std docs — OnceCell](https://doc.rust-lang.org/std/cell/struct.OnceCell.html) · [std docs — OnceLock](https://doc.rust-lang.org/std/sync/struct.OnceLock.html) · [std docs — Mutex](https://doc.rust-lang.org/std/sync/struct.Mutex.html) · [std docs — RwLock](https://doc.rust-lang.org/std/sync/struct.RwLock.html) · [Rustonomicon — Concurrency](https://doc.rust-lang.org/nomicon/concurrency.html)

### Java: volatile, Atomics, synchronized

Java does not have a formal "interior mutability" concept because all references allow mutation by default. However, the same problem arises for *thread-safe* mutation of shared state.

**`volatile`** — visibility guarantee across threads:

```java
volatile boolean running = true;

// Thread A:
running = false;  // write is immediately visible to all threads

// Thread B:
while (running) { /* ... */ }  // guaranteed to see the write
```

- Guarantees visibility: reads always see the latest write
- Prevents reordering: establishes happens-before relationship
- Does NOT provide atomicity for compound operations:

```java
volatile int count = 0;
// count++  is NOT atomic — it is: read count, add 1, write count
// Two threads doing count++ concurrently can lose an increment
```

**`AtomicInteger` / `AtomicReference<T>`** — lock-free atomic operations:

```java
import java.util.concurrent.atomic.AtomicInteger;

AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();            // atomic: read + increment + write
counter.addAndGet(5);                 // atomic add
counter.compareAndSet(6, 0);          // CAS: if current == 6, set to 0

// AtomicReference for reference types
AtomicReference<String> ref = new AtomicReference<>("initial");
ref.compareAndSet("initial", "updated");
```

- Built on hardware CAS (compare-and-swap)
- Lock-free — no blocking, no OS involvement
- `AtomicInteger`, `AtomicLong`, `AtomicBoolean`, `AtomicReference<V>`
- `LongAdder` and `LongAccumulator` for high-contention counters (striped cells)

**`synchronized`** — mutual exclusion and visibility:

```java
class Counter {
    private int count = 0;
    
    public synchronized void increment() {  // intrinsic lock on `this`
        count++;                              // atomic, visible
    }
    
    public synchronized int getCount() {     // same lock — sees latest value
        return count;
    }
}

// Or with explicit lock object:
Object lock = new Object();
synchronized (lock) {
    // critical section — only one thread at a time
}
```

- Provides both mutual exclusion and memory visibility
- Establishes a happens-before relationship between unlock and subsequent lock
- Reentrant — a thread can acquire the same lock multiple times

**`ReentrantLock`** — explicit lock with more features:

```java
import java.util.concurrent.locks.ReentrantLock;

ReentrantLock lock = new ReentrantLock();
lock.lock();
try {
    // critical section
} finally {
    lock.unlock();  // always unlock in finally!
}

// Features beyond synchronized:
lock.tryLock();                    // non-blocking attempt
lock.tryLock(1, TimeUnit.SECONDS); // timed attempt
lock.lockInterruptibly();          // interruptible acquisition
```

**`ReadWriteLock`** — multiple readers or one writer:

```java
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

ReadWriteLock rwLock = new ReentrantReadWriteLock();

// Reading (multiple readers allowed)
rwLock.readLock().lock();
try { /* read shared state */ }
finally { rwLock.readLock().unlock(); }

// Writing (exclusive access)
rwLock.writeLock().lock();
try { /* modify shared state */ }
finally { rwLock.writeLock().unlock(); }
```

**Mapping to Rust:**

| Rust Type | Java Equivalent | Scope |
|-----------|-----------------|-------|
| `Cell<T>` | No equivalent | Single-threaded, `Copy` only |
| `RefCell<T>` | Unsynchronized mutable field (no safety) | Single-threaded |
| `Mutex<T>` | `synchronized` / `ReentrantLock` | Multi-threaded |
| `RwLock<T>` | `ReadWriteLock` | Multi-threaded |
| `AtomicI32` | `AtomicInteger` | Multi-threaded, lock-free |
| `OnceLock<T>` | Double-checked locking / holder idiom | Lazy initialization |

The critical difference: Rust's type system **forces** you to use interior mutability wrappers — you cannot get `&mut T` from `&T` without them. Java relies entirely on the programmer to use the right tool. Nothing in Java's type system prevents reading a non-volatile, non-synchronized field from another thread.

> **Sources:** Bloch (2018) Item 78 pp. 311–316 · Goetz et al. (2006) Ch.3 pp. 33–40, Ch.15 pp. 319–336 · Evans et al. (2022) Ch.5 pp. 140–166, Ch.6 pp. 169–195 · [Java docs — java.util.concurrent.atomic](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/package-summary.html) · [Java docs — AtomicInteger](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/atomic/AtomicInteger.html) · [JLS — volatile fields](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.3.1.4) · [JLS — synchronized statement](https://docs.oracle.com/javase/specs/jls/se21/html/jls-14.html#jls-14.19)

### Python: Mutable Inside Immutable, and the GIL

Python has no formal interior mutability concept because it has no formal immutability enforcement. But the same patterns arise in practice.

**Mutable objects inside "immutable" containers:**

```python
t = ([1, 2], [3, 4])    # tuple of lists
t[0].append(5)           # "interior mutation" — the list is mutable
print(t)                  # ([1, 2, 5], [3, 4])

# This also triggers a famous oddity with += on tuples:
t[0] += [6, 7]           # raises TypeError AND mutates the list!
# Because: t[0].__iadd__([6, 7]) succeeds (mutates list in place)
#          t[0] = result fails (tuple doesn't support item assignment)
```

**Frozen dataclasses can be "mutated" through mutable attributes:**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Container:
    items: list

c = Container([1, 2, 3])
# c.items = [4, 5]       # FrozenInstanceError
c.items.append(4)         # works — the list is mutable
```

**Even frozen dataclasses can be mutated through `object.__setattr__`:**

```python
@dataclass(frozen=True)
class Point:
    x: int
    y: int

p = Point(1, 2)
# p.x = 10              # FrozenInstanceError

object.__setattr__(p, 'x', 10)  # bypasses the frozen check!
print(p.x)                       # 10
```

This is by design — Python's "we are all consenting adults" philosophy means there are always escape hatches.

**`threading.Lock` — mutual exclusion:**

```python
import threading

lock = threading.Lock()
counter = 0

def increment():
    global counter
    with lock:               # acquires lock on entry, releases on exit
        counter += 1         # safe — exclusive access

threads = [threading.Thread(target=increment) for _ in range(1000)]
for t in threads: t.start()
for t in threads: t.join()
print(counter)               # 1000 — correct
```

**The GIL (Global Interpreter Lock):** CPython's GIL ensures only one thread executes Python bytecode at a time. This provides some implicit safety — single bytecode operations are atomic. But compound operations (check-then-act, read-modify-write) are still vulnerable:

```python
# UNSAFE even with the GIL:
counter = 0

def increment():
    global counter
    for _ in range(100_000):
        counter += 1    # NOT atomic: LOAD_GLOBAL, +1, STORE_GLOBAL
                        # GIL can release between any of these steps

# Two threads running increment() will produce a result less than 200_000
```

The GIL is a CPython implementation detail, not a language guarantee. PyPy, GraalPy, and the experimental free-threaded CPython (PEP 703) do not have the same GIL behavior.

**`threading.RLock`** — reentrant lock (the same thread can acquire it multiple times without deadlocking):

```python
rlock = threading.RLock()

def recursive_func(n):
    with rlock:              # acquires — recursion level 1
        if n > 0:
            recursive_func(n - 1)  # re-acquires — level 2, 3, ...
    # each exit decrements the level; fully unlocked when level hits 0
```

Key difference from `Lock`: a thread that already holds a `Lock` will **deadlock** if it tries to acquire it again. `RLock` tracks ownership and recursion depth. Note that `Lock.release()` can be called from any thread, while `RLock.release()` must be called by the owning thread.

**Python has no equivalent of lock-free atomics** — the GIL makes them unnecessary for CPython, but `threading.Lock` is required for compound operations. For truly concurrent code, use `multiprocessing` (separate processes, no shared state) or `concurrent.futures`.

> **Sources:** Ramalho (2022) Ch.6 pp. 212–220 · Viafore (2021) Ch.10 pp. 135–152 · Martelli et al. (2023) Ch.3 pp. 55–75 · Slatkin (2025) Item 69 pp. 330–332 · [Python docs — threading](https://docs.python.org/3/library/threading.html) · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html#objects-values-and-types)

### Interior Mutability Comparison

| Pattern | Rust | Java | Python |
|---------|------|------|--------|
| **Zero-cost cell** | `Cell<T>` (`Copy` only, `!Sync`) | No equivalent | No equivalent |
| **Runtime borrow check** | `RefCell<T>` (panics on violation) | Unguarded mutable field (no safety) | N/A (no borrow checker) |
| **Mutual exclusion** | `Mutex<T>` | `synchronized` / `ReentrantLock` | `threading.Lock` |
| **Reentrant lock** | N/A (Mutex is not reentrant) | `ReentrantLock` / `synchronized` (reentrant) | `threading.RLock` |
| **Reader-writer lock** | `RwLock<T>` | `ReadWriteLock` | No stdlib equivalent |
| **Lock-free atomic** | `AtomicI32`, `AtomicBool`, ... | `AtomicInteger`, `AtomicReference`, ... | No equivalent (GIL suffices for CPython) |
| **Write-once init** | `OnceCell<T>` / `OnceLock<T>` | Holder idiom / `volatile` DCL | Module-level (runs on import) |
| **Lazy init (Deref)** | `LazyCell<T>` / `LazyLock<T>` | `lazy_static` equivalent | Module-level / `functools.cached_property` |
| **Type-system enforcement** | Yes — `&T` cannot mutate without wrapper | No — any reference can mutate | No |
| **Thread safety marker** | `Send` + `Sync` traits (compile-time) | Documentation / `@ThreadSafe` annotation | Convention only |

---

## 5. Copy-on-Write

Deferring the cost of copying until mutation is actually needed — the optimization pattern for "usually read-only, occasionally modified" data.

### Rust: `Cow<T>` — A Type-Level Borrowed-or-Owned Enum

`Cow<'a, B>` (Clone-on-Write) is an enum that transparently holds either a borrowed reference or an owned value, cloning only when mutation is needed:

```rust
use std::borrow::Cow;

enum Cow<'a, B: ?Sized + ToOwned> {
    Borrowed(&'a B),
    Owned(<B as ToOwned>::Owned),
}
```

**Basic usage:**

```rust
use std::borrow::Cow;

fn abs_all(input: &mut Cow<[i32]>) {
    for i in 0..input.len() {
        let v = input[i];
        if v < 0 {
            // to_mut() clones only on first mutation
            input.to_mut()[i] = -v;
        }
    }
}

// No negative values — no allocation
let slice = [1, 2, 3];
let mut input = Cow::from(&slice[..]);
abs_all(&mut input);
// input is still Borrowed — no clone happened

// Has negative values — clones on first call to to_mut()
let slice = [1, -2, 3];
let mut input = Cow::from(&slice[..]);
abs_all(&mut input);
// input is now Owned — clone happened once
```

**The classic use case — string processing:**

```rust
use std::borrow::Cow;

fn ensure_trailing_slash(path: &str) -> Cow<str> {
    if path.ends_with('/') {
        Cow::Borrowed(path)          // no allocation — return reference to input
    } else {
        let mut owned = path.to_owned();
        owned.push('/');
        Cow::Owned(owned)            // allocation only when needed
    }
}

let p1 = ensure_trailing_slash("/home/user/");  // Borrowed — free
let p2 = ensure_trailing_slash("/home/user");    // Owned — allocates
println!("{}, {}", p1, p2);
```

**Key methods:**
- `to_mut()` — returns `&mut Owned`; clones from borrowed to owned on first call
- `into_owned()` — consumes the `Cow`, returning the owned form; clones if borrowed
- `is_borrowed()` / `is_owned()` — variant checks

**`Cow` implements `Deref`**, so it can be used transparently as `&B` for reading:

```rust
fn print_path(path: &str) {
    println!("{}", path);
}

let cow: Cow<str> = Cow::Borrowed("hello");
print_path(&cow);  // Deref coercion — Cow<str> → &str
```

**The supporting traits:**

| Trait | Purpose | Example |
|-------|---------|---------|
| `Borrow<B>` | Unifies owned and borrowed forms | `String: Borrow<str>`, `Vec<T>: Borrow<[T]>` |
| `ToOwned` | Creates an owned form from a borrowed form | `str → String`, `[T] → Vec<T>` |

`Cow` uses `ToOwned::to_owned()` to perform the clone when `to_mut()` is called on a `Borrowed` variant.

**When to use `Cow`:**
- Functions that usually return input unchanged but sometimes modify it
- APIs that want to accept both borrowed and owned data without forcing allocation
- Parsing functions that may or may not need to unescape/transform input
- Configuration loading where most values use defaults (borrowed from `'static`)

> **Sources:** Blandy & Orendorff (2017) Ch.13 pp. 293–301 · Matthews (2024) Ch.5 pp. 112–118 · [std docs — Cow](https://doc.rust-lang.org/std/borrow/enum.Cow.html) · [std docs — Borrow trait](https://doc.rust-lang.org/std/borrow/trait.Borrow.html) · [std docs — ToOwned trait](https://doc.rust-lang.org/std/borrow/trait.ToOwned.html) · [Rust By Example — Cow](https://doc.rust-lang.org/rust-by-example/std/cow.html)

### Java: `CopyOnWriteArrayList` and Defensive Copying

Java has no general-purpose CoW abstraction like Rust's `Cow<T>`. Instead, it has a specific concurrent collection and a manual defensive copying pattern.

**`CopyOnWriteArrayList`** — a concurrent collection optimized for read-heavy workloads:

```java
import java.util.concurrent.CopyOnWriteArrayList;

CopyOnWriteArrayList<String> listeners = new CopyOnWriteArrayList<>();
listeners.add("listener1");
listeners.add("listener2");

// Reads are lock-free — operate on the current snapshot
for (String listener : listeners) {
    System.out.println(listener);    // iterator uses snapshot, never throws CME
}

// Writes copy the entire internal array
listeners.add("listener3");         // allocates new array, copies, adds, swaps reference
```

**Internal mechanism** (Goetz Ch.5):
- Holds a `volatile` reference to an immutable array snapshot
- **Reads:** return elements from the current array (no locking, no copying)
- **Writes:** acquire a `ReentrantLock`, copy the entire array, modify the copy, atomically swap the `volatile` reference
- **Iterators:** capture the array reference at creation time and never see subsequent modifications

**Trade-offs:**

| Operation | Cost | Locking |
|-----------|------|---------|
| `get(i)` | O(1) | None |
| `iterator()` | O(1) — snapshot of reference | None |
| `add(e)` | O(n) — full array copy | Writer lock |
| `set(i, e)` | O(n) — full array copy | Writer lock |
| `remove(i)` | O(n) — full array copy | Writer lock |

Best suited for event-listener lists, observer patterns, and similar read-heavy, write-rare workloads. Not appropriate for frequently modified lists.

**Memory consistency guarantee:** Actions in a thread prior to placing an object into a `CopyOnWriteArrayList` *happen-before* actions subsequent to accessing or removing that element in another thread.

**Additional APIs:** `addIfAbsent(E e)` adds an element only if not already present — useful for building unique listener registries without external synchronization. Null elements are permitted (unlike `List.of()`).

**Defensive copying** (Bloch Item 50) — Java's manual CoW pattern:

```java
public final class SafeList {
    private final List<String> items;
    
    public SafeList(List<String> items) {
        this.items = new ArrayList<>(items);   // copy on the way IN
    }
    
    public List<String> getItems() {
        return new ArrayList<>(items);          // copy on the way OUT
    }
}
```

This is "copy always" rather than "copy on write" — every access creates a new copy. More wasteful than true CoW, but simple and correct.

**`clone()` — shallow vs deep copying** (Bloch Item 13):

```java
ArrayList<StringBuilder> original = new ArrayList<>();
original.add(new StringBuilder("hello"));

ArrayList<StringBuilder> clone = (ArrayList<StringBuilder>) original.clone();
// Shallow copy — clone has a new ArrayList, but shares the StringBuilder objects
clone.get(0).append(" world");
System.out.println(original.get(0)); // "hello world" — shared reference!

// For deep copy, you must manually copy each element
```

> **Sources:** Goetz et al. (2006) Ch.5 pp. 79–86 · Evans et al. (2022) Ch.6 pp. 169–195 · Bloch (2018) Item 13 pp. 58–65, Item 50 pp. 231–235 · [Java docs — CopyOnWriteArrayList](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArrayList.html) · [Java docs — CopyOnWriteArraySet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArraySet.html)

### Python: `copy` Module, `os.fork()`, and Manual Patterns

Python has no explicit CoW type. The concept manifests through the `copy` module, OS-level mechanisms, and manual coding patterns.

**The `copy` module — explicit shallow and deep copies:**

```python
import copy

original = {"name": "Alice", "scores": [90, 85, 92]}

# Shallow copy — new dict, but shared inner objects
shallow = copy.copy(original)
shallow["scores"].append(88)
print(original["scores"])    # [90, 85, 92, 88] — shared list was mutated!

# Deep copy — independent copy of the entire object graph
deep = copy.deepcopy(original)
deep["scores"].append(100)
print(original["scores"])    # [90, 85, 92, 88] — unaffected
```

**Custom copy behavior:**

```python
class MyClass:
    def __copy__(self):
        # customize shallow copy
        return MyClass(self.data)
    
    def __deepcopy__(self, memo):
        # customize deep copy (memo dict prevents infinite recursion for cycles)
        return MyClass(copy.deepcopy(self.data, memo))
```

**Manual copy-on-write pattern:**

```python
def process(items):
    """Process items, returning modified copy only if changes needed."""
    for i, item in enumerate(items):
        if item < 0:
            # Copy only when mutation is needed
            items = list(items)    # snapshot — won't affect caller
            items[i] = -item
            for j in range(i + 1, len(items)):
                if items[j] < 0:
                    items[j] = -items[j]
            return items
    return items                    # no copy needed — return original

data = [1, 2, 3]
result = process(data)
print(result is data)      # True — no copy was made

data = [1, -2, 3]
result = process(data)
print(result is data)      # False — copy was made
```

**OS-level CoW via `os.fork()`:**

```python
import os

# fork() creates a child process that shares the parent's memory pages
# marked as copy-on-write by the OS kernel
pid = os.fork()
if pid == 0:
    # child process — shares parent's memory until it writes
    pass
else:
    # parent process
    os.waitpid(pid, 0)
```

The OS marks all memory pages as read-only after fork. When either process writes to a page, the CPU triggers a page fault, and the OS copies that specific page before allowing the write. This is true CoW at the hardware level.

**CPython caveat with fork:** Reference counting partially defeats OS-level CoW. When CPython traverses objects (e.g., during garbage collection or even simple iteration), it increments reference counts in each object's header. These writes trigger page copies even for "read-only" operations, reducing the effectiveness of fork-based CoW.

**NumPy views — implicit CoW for arrays:**

```python
import numpy as np

arr = np.array([1, 2, 3, 4, 5])
view = arr[1:4]              # view — shares memory with arr
print(view.base is arr)      # True

view[0] = 99                 # modifies arr too!
print(arr)                    # [ 1, 99,  3,  4,  5]

independent = arr[1:4].copy() # explicit copy — independent memory
independent[0] = 0
print(arr)                    # [ 1, 99,  3,  4,  5] — unaffected
```

NumPy views are not true CoW (writes modify the original), but they embody the same principle: defer copying until you know you need independence.

> **Sources:** Martelli et al. (2023) Ch.8 pp. 247–265 · Ramalho (2022) Ch.6 pp. 220–228 · [Python docs — copy module](https://docs.python.org/3/library/copy.html) · [Python docs — os.fork](https://docs.python.org/3/library/os.html#os.fork) · [PEP 509 — Add a private version to dict](https://peps.python.org/pep-0509/)

### Copy-on-Write Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **General-purpose CoW type** | `Cow<'a, B>` — zero-cost enum | None | None |
| **Concurrent CoW collection** | N/A (use `Arc<RwLock<Vec<T>>>`) | `CopyOnWriteArrayList` | None |
| **Manual CoW pattern** | Not needed — `Cow` covers it | Defensive copying (Bloch Item 50) | `copy-before-mutate` convention |
| **OS-level CoW** | Available via `fork()` | Available via `ProcessBuilder` | `os.fork()` (CPython refcounting defeats it) |
| **Copy granularity** | Type-level (per-value) | Collection-level or manual | Manual or library-specific (NumPy) |
| **Performance profile** | Zero-cost for reads; clone on first write | O(n) array copy on every write | Full copy (shallow or deep) when triggered |
| **Type-system visibility** | Yes — `Cow<str>` in the signature | No — implementation detail | No — convention only |

---

## Summary

| Concept | Rust | Java | Python |
|---------|------|------|--------|
| **Mutability default** | Immutable (`let`) | Mutable | Mutable |
| **Immutability mechanism** | `let` (deep), `&T` (transitive) | `final` (shallow), records | Immutable types (`tuple`, `frozenset`) |
| **Aliasing control** | Shared XOR mutable (compile-time) | None | None |
| **Interior mutability** | `Cell`/`RefCell`/`Mutex`/`RwLock` (type-encoded) | `volatile`/`AtomicInteger`/`synchronized` | Mutable inside immutable containers |
| **Copy-on-write** | `Cow<T>` (generic, zero-cost) | `CopyOnWriteArrayList` (specific) | Manual pattern |
| **Thread-safety encoding** | `Send`/`Sync` traits (compile-time) | Documentation/annotations | Convention only |
| **Philosophy** | Safety by default, opt-in to danger | Freedom by default, patterns for safety | Trust the programmer |

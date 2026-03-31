# Layer 2 · Topic 4 — Type System

> Comparative study of Rust, Java, and Python: how each language classifies, constrains, and reasons about data — from primitive scalars through generics and traits to advanced type-level programming.

---

## 1. Primitive & Scalar Types

How each language represents fundamental data — integers, floats, booleans, characters — and the critical distinction between Rust's zero-cost scalars, Java's primitive/boxed duality, and Python's "everything is an object" model.

### Rust: Zero-Cost Scalars

Rust scalars are stack-allocated, zero-overhead machine types with no boxing, no garbage collection, and no implicit conversions. The compiler enforces explicit conversions — `let x: i32 = 5; let y: i64 = x;` does not compile.

Rust provides four categories of scalar types:

| Category | Types | Size |
|----------|-------|------|
| **Signed integers** | `i8`, `i16`, `i32`, `i64`, `i128`, `isize` | 1–16 bytes |
| **Unsigned integers** | `u8`, `u16`, `u32`, `u64`, `u128`, `usize` | 1–16 bytes |
| **Floating-point** | `f32`, `f64` | 4, 8 bytes |
| **Other scalars** | `bool` (1 byte), `char` (4 bytes, Unicode scalar value) | — |

Integer overflow behavior depends on the build profile: **panics in debug mode** and **wraps in release mode**. For explicit control, Rust provides `wrapping_add`, `checked_add`, `saturating_add`, and `overflowing_add` methods on all integer types.

```rust
let x: u8 = 255;
let y = x.wrapping_add(1);    // 0 — wraps explicitly
let z = x.checked_add(1);     // None — returns Option<u8>
let w = x.saturating_add(1);  // 255 — clamps at max
```

`isize` and `usize` are pointer-sized integers (32-bit on 32-bit platforms, 64-bit on 64-bit platforms) and are used for indexing into collections. `char` is always 4 bytes — a Unicode scalar value (U+0000 to U+D7FF and U+E000 to U+10FFFF), not a UTF-8 byte.

> **Sources:** Klabnik & Nichols (2023) Ch.3 pp. 31–46 · Blandy & Orendorff (2017) Ch.3 pp. 43–55 · [Rust Reference — Types](https://doc.rust-lang.org/reference/types.html) · [Rust Reference — Scalar Types](https://doc.rust-lang.org/reference/types/numeric.html) · [Rust By Example — Primitives](https://doc.rust-lang.org/rust-by-example/primitives.html)

### Java: Primitives vs Boxed Types

Java has a dual type system — eight primitives live on the stack with no object overhead, while their boxed counterparts are heap-allocated objects.

| Primitive | Size | Boxed | Default |
|-----------|------|-------|---------|
| `byte` | 1 byte | `Byte` | 0 |
| `short` | 2 bytes | `Short` | 0 |
| `int` | 4 bytes | `Integer` | 0 |
| `long` | 8 bytes | `Long` | 0L |
| `float` | 4 bytes | `Float` | 0.0f |
| `double` | 8 bytes | `Double` | 0.0d |
| `char` | 2 bytes (UTF-16) | `Character` | '\u0000' |
| `boolean` | JVM-dependent | `Boolean` | false |

**Autoboxing/unboxing** bridges primitives and objects but introduces subtle bugs. The `==` operator on `Integer` compares references (not values) for values outside the cached range -128..127, and unboxing a `null` boxed type throws `NullPointerException`:

```java
Integer a = 200;
Integer b = 200;
System.out.println(a == b);      // false — different objects
System.out.println(a.equals(b)); // true  — value comparison

Integer c = null;
int d = c;  // NullPointerException — unboxing null
```

Widening conversions (`int` to `long`) are implicit but can lose precision (`int` to `float` loses bits for large integers). Narrowing conversions require explicit casts — `(byte)256` wraps silently to 0. Compound assignment operators perform hidden narrowing: `short s = 0; s += 1;` compiles (implicit cast), but `s = s + 1;` does not (result is `int`).

> **Sources:** Horstmann (2024) Ch.3 pp. 41–52 · Bloch (2018) Item 61 · Valeev (2024) Ch.4 pp. 96–110 · [JLS — Primitive Types and Values](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.2) · [JLS — Conversions and Contexts](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html) · [Oracle — Autoboxing and Unboxing](https://docs.oracle.com/javase/tutorial/java/data/autoboxing.html)

### Python: Everything Is an Object

Python has no primitive types — `int`, `float`, `bool`, `str`, and even `None` are all objects on the heap with reference counts, type pointers, and method tables. This uniformity simplifies the mental model but adds 28+ bytes overhead per integer object.

```python
>>> import sys
>>> sys.getsizeof(0)     # 28 bytes for int 0
28
>>> sys.getsizeof(True)  # 28 bytes — bool is a subclass of int
28
>>> True + True           # 2 — bool arithmetic works as int
2
>>> type(True).__mro__    # (<class 'bool'>, <class 'int'>, <class 'object'>)
```

Key characteristics:

- **`int`** has arbitrary precision — no overflow, integers grow as needed. `2 ** 1000` works without any special handling. CPython uses a small-integer cache for -5 through 256.
- **`float`** wraps a C `double` (64-bit IEEE 754). No `float32` equivalent in the standard library — use `numpy` for that.
- **`bool`** is a subclass of `int` — `True` is literally `1` and `False` is literally `0`. This is not just type coercion; `bool` inherits from `int`.
- **`None`** is a singleton of type `NoneType`. Identity check (`is None`) is preferred over equality (`== None`).
- **`complex`** is a built-in type: `3+4j`.

The Python Data Model defines how objects behave through special methods (`__add__`, `__eq__`, `__hash__`, `__repr__`, etc.). Every operation on every type — including arithmetic on integers — goes through method lookup and dispatch, which is why Python arithmetic is orders of magnitude slower than Rust or Java primitives.

> **Sources:** Martelli et al (2023) Ch.3 pp. 33–55 · Ramalho (2022) Ch.1 pp. 3–12 · Gorelick & Ozsvald (2020) Ch.3 pp. 65–70 · [Python docs — Built-in Types](https://docs.python.org/3/library/stdtypes.html) · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Integer sizes** | i8–i128, u8–u128 (explicit) | byte, short, int, long (fixed) | Arbitrary precision (unlimited) |
| **Float precision** | f32, f64 | float, double | float (C double only) |
| **Bool representation** | 1 byte, true/false | JVM-dependent, true/false | Subclass of int (True=1, False=0) |
| **Char / string unit** | char = 4 bytes (Unicode scalar) | char = 2 bytes (UTF-16 code unit) | No char type; str[0] = 1-char string |
| **Implicit conversions** | None — all conversions explicit | Widening primitives implicit | Numeric promotion in arithmetic only |
| **Overflow behavior** | Panic (debug) / wrap (release) | Wrap silently | No overflow (arbitrary precision) |
| **Memory per integer** | 1–16 bytes (stack, no overhead) | 4 bytes primitive / ~16 bytes boxed | 28+ bytes (heap object) |
| **Stack vs heap** | Stack (scalars) | Stack (primitives), heap (boxed) | Always heap |

---

## 2. Composite & Algebraic Types

How each language composes types into larger structures — structs, classes, records, enums — and how Rust's algebraic data types (sum types + product types) compare to Java's class-based and Python's duck-typed approaches.

### Rust: Structs and Enums as Algebraic Types

Rust's type system is algebraic — **structs** are product types (all fields present) and **enums** are sum types (exactly one variant active). There is no class inheritance; composition via structs + traits replaces it.

**Three struct variants:**

```rust
// Named-field struct (product type)
struct Point { x: f64, y: f64 }

// Tuple struct
struct Meters(f64);

// Unit struct (no data)
struct Marker;
```

**Enums as sum types** can carry different data per variant, enabling precise modeling of state machines, ASTs, and protocol messages:

```rust
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle { base: f64, height: f64 },
}

fn area(shape: &Shape) -> f64 {
    match shape {
        Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
        Shape::Rectangle { width, height } => width * height,
        Shape::Triangle { base, height } => 0.5 * base * height,
    }
}
```

The compiler guarantees **exhaustive matching** — if you add a new variant to `Shape`, every `match` must handle it or the code will not compile. There is no null — `Option<T>` (either `Some(T)` or `None`) forces explicit handling of absence. Methods are defined in separate `impl` blocks, not inside the type definition.

Structs and enums can be generic (`struct Pair<T> { first: T, second: T }`) and carry lifetime parameters (`struct Excerpt<'a> { text: &'a str }`). Common traits like `Debug`, `Clone`, `PartialEq`, and `Hash` can be auto-derived with `#[derive(...)]`.

> **Sources:** Klabnik & Nichols (2023) Ch.5 pp. 85–102, Ch.6 pp. 103–117 · Blandy & Orendorff (2017) Ch.9 pp. 193–209, Ch.10 pp. 211–233 · [Rust Reference — Struct Types](https://doc.rust-lang.org/reference/types/struct.html) · [Rust Reference — Enum Types](https://doc.rust-lang.org/reference/types/enum.html) · [Rust By Example — Custom Types](https://doc.rust-lang.org/rust-by-example/custom_types.html)

### Java: Classes, Records, Enums, Sealed Types

Java's composite types center on class inheritance, with modern additions (records, sealed classes, pattern matching) moving toward algebraic expressiveness.

**Classes** are the fundamental unit — they combine state (fields) and behavior (methods) with access modifiers, constructors, and inheritance:

```java
public class Point {
    private final double x;
    private final double y;
    public Point(double x, double y) { this.x = x; this.y = y; }
    // getters, equals, hashCode, toString...
}
```

**Records** (Java 16+) are transparent, immutable data carriers — product types with auto-generated constructors, accessors, `equals`, `hashCode`, and `toString`:

```java
public record Point(double x, double y) {}  // That's it
```

**Enums** are powerful — they can have fields, methods, and per-constant behavior — but they are not algebraic sum types because they cannot carry different data per variant like Rust enums:

```java
public enum Planet {
    MERCURY(3.303e+23, 2.4397e6),
    VENUS(4.869e+24, 6.0518e6);
    private final double mass, radius;
    Planet(double mass, double radius) { this.mass = mass; this.radius = radius; }
}
```

**Sealed classes** (Java 17+) combined with **pattern matching** (Java 21+) are the closest Java gets to Rust's enum pattern matching:

```java
public sealed interface Shape permits Circle, Rectangle {}
public record Circle(double radius) implements Shape {}
public record Rectangle(double width, double height) implements Shape {}

double area = switch (shape) {
    case Circle c -> Math.PI * c.radius() * c.radius();
    case Rectangle r -> r.width() * r.height();
    // exhaustive — compiler checks all permitted subtypes
};
```

> **Sources:** Horstmann (2024) Ch.4 pp. 55–68, Ch.5 pp. 70–82 · Evans (2022) Ch.3 pp. 55–77 · Bloch (2018) Ch.6 pp. 157–175 · [JEP 395 — Records](https://openjdk.org/jeps/395) · [JEP 409 — Sealed Classes](https://openjdk.org/jeps/409) · [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)

### Python: Classes, Dataclasses, NamedTuple, Enum

Python is maximally flexible — you can create product types via regular classes, `@dataclass`, or `NamedTuple`. There are no true sum types; the closest approximations are `Union` types with type checkers or `match` statements (Python 3.10+).

**`@dataclass`** (Python 3.7+) auto-generates `__init__`, `__repr__`, `__eq__`, and optionally `__hash__`, `__order__`:

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

@dataclass(frozen=True)  # immutable
class FrozenPoint:
    x: float
    y: float
```

**`typing.NamedTuple`** creates immutable tuple subclasses with named fields:

```python
from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float

p = Point(1.0, 2.0)
x, y = p  # unpacking works — it's a tuple
```

**`enum.Enum`** is simpler than Java's or Rust's — variants are named constants without associated data:

```python
from enum import Enum, auto

class Color(Enum):
    RED = auto()
    GREEN = auto()
    BLUE = auto()
```

**Approximating sum types** with `Union` and `match`:

```python
from dataclasses import dataclass
from typing import Union
import math

@dataclass
class Circle:
    radius: float

@dataclass
class Rectangle:
    width: float
    height: float

Shape = Union[Circle, Rectangle]  # or: Shape = Circle | Rectangle (3.10+)

def area(shape: Shape) -> float:
    match shape:
        case Circle(radius=r):
            return math.pi * r * r
        case Rectangle(width=w, height=h):
            return w * h
```

The key differences: `@dataclass` is mutable by default (use `frozen=True` for immutability), `NamedTuple` is always immutable, and regular classes offer full flexibility. Python's `match` statement does structural pattern matching but without compile-time exhaustiveness enforcement — a type checker like mypy can warn about missing cases.

> **Sources:** Ramalho (2022) Ch.5 pp. 163–200 · Martelli et al (2023) Ch.4 pp. 115–135 · Viafore (2021) Ch.8–9 pp. 111–134 · [Python docs — dataclasses](https://docs.python.org/3/library/dataclasses.html) · [Python docs — enum](https://docs.python.org/3/library/enum.html) · [PEP 557 — Data Classes](https://peps.python.org/pep-0557/)

### Algebraic Types Comparison

| Concept | Rust | Java | Python |
|---------|------|------|--------|
| **Product type** | `struct` (named, tuple, unit) | `class`, `record` (Java 16+) | `@dataclass`, `NamedTuple`, `class` |
| **Sum type** | `enum` (variants carry data) | `sealed interface` + `permits` (Java 17+) | `Union[A, B]` + type checker |
| **Pattern matching** | `match` (compile-time exhaustive) | `switch` with patterns (Java 21+, exhaustive for sealed) | `match` (Python 3.10+, not exhaustive) |
| **Immutability** | Default (use `mut` for mutable) | `record` is immutable; classes are not by default | `frozen=True` on dataclass; NamedTuple is immutable |
| **Inheritance** | None (composition via traits) | Single class + multiple interfaces | Multiple inheritance with C3 MRO |
| **Null/absence** | `Option<T>` — no null | `null` for any reference type | `None` — any variable can be None |

---

## 3. Generics & Parametric Polymorphism

Three fundamentally different approaches to generics — Rust's monomorphization (generates specialized code per type), Java's type erasure (compiles to a single generic version), and Python's runtime-erased type variables (purely static analysis).

### Rust: Monomorphized Generics

Rust generics are **monomorphized** — when you write a generic function, the compiler generates a separate, fully-optimized function for each concrete type used. This means zero runtime cost (no boxing, no vtables, full inlining) but larger binaries.

```rust
fn largest<T: PartialOrd>(a: T, b: T) -> T {
    if a >= b { a } else { b }
}

let x = largest(5_i32, 10_i32);   // generates largest::<i32>
let y = largest(1.0_f64, 2.0_f64); // generates largest::<f64>
```

**Trait bounds** constrain what operations are available on generic types. Multiple bounds and `where` clauses provide expressive constraints:

```rust
fn print_and_clone<T>(item: &T) -> T
where
    T: std::fmt::Display + Clone,
{
    println!("{}", item);
    item.clone()
}
```

**`impl Trait`** can be used in argument position (syntactic sugar for a trait bound) and in return position (opaque type — the caller cannot name the concrete type):

```rust
fn make_adder(x: i32) -> impl Fn(i32) -> i32 {
    move |y| x + y
}
```

Generic structs and enums follow the same monomorphization model. `Option<T>`, `Result<T, E>`, `Vec<T>`, `HashMap<K, V>` are all generic types that get specialized at compile time. There is no runtime overhead for generics — `Vec<i32>` and `Vec<String>` are completely different types in the compiled binary.

> **Sources:** Klabnik & Nichols (2023) Ch.10 pp. 181–200 · Blandy & Orendorff (2017) Ch.11 pp. 235–250 · Gjengset (2022) Ch.2 pp. 19–35 · [Rust Reference — Generic Parameters](https://doc.rust-lang.org/reference/items/generics.html) · [Rust By Example — Generics](https://doc.rust-lang.org/rust-by-example/generics.html)

### Java: Type-Erased Generics

Java generics use **type erasure** — `List<String>` and `List<Integer>` become the same `List<Object>` at runtime, with the compiler inserting casts. This was chosen for backwards compatibility with pre-generics Java code (Java 5).

```java
List<String> strings = new ArrayList<>();
strings.add("hello");
String s = strings.get(0);  // compiler inserts: (String) strings.get(0)

// At runtime, both are just ArrayList:
List<String> a = new ArrayList<>();
List<Integer> b = new ArrayList<>();
System.out.println(a.getClass() == b.getClass());  // true
```

Consequences of erasure:
- No `new T()` or `T.class` at runtime — the JVM does not know what `T` is
- No primitive type parameters — `List<int>` is illegal; must use `List<Integer>` (boxing overhead)
- Arrays are reified but generics are not — `List<String>[]` is problematic
- Cannot use `instanceof` with parameterized types — `x instanceof List<String>` does not compile

**Wildcards** and the **PECS principle** (Producer Extends, Consumer Super) govern generic flexibility:

```java
// Producer — reads from source (covariant)
void printAll(List<? extends Number> list) {
    for (Number n : list) System.out.println(n);
}

// Consumer — writes to destination (contravariant)
void addInts(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}
```

**Bounded type parameters** constrain what types can be used:

```java
public static <T extends Comparable<T>> T max(T a, T b) {
    return a.compareTo(b) >= 0 ? a : b;
}
```

Bridge methods are synthesized by the compiler to maintain polymorphism under erasure — when a generic class is extended with concrete types, the compiler generates bridge methods that perform the necessary casts.

> **Sources:** Horstmann (2024) Ch.8 pp. 104–116 · Bloch (2018) Ch.5 pp. 117–155 · Naftalin & Wadler (2024) Ch.1–3, Ch.5 · [JLS — Types, Values, Variables](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html) · [Oracle — Generics](https://docs.oracle.com/javase/tutorial/java/generics/index.html) · [Angelika Langer — Java Generics FAQ](http://www.angelikalanger.com/GenericsFAQ/JavaGenericsFAQ.html)

### Python: TypeVar and Generic

Python generics exist only for static type checkers (mypy, pyright) — they have **zero effect at runtime**. At runtime, `Stack[int]()` and `Stack[str]()` are the same class.

```python
from typing import TypeVar, Generic

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

s: Stack[int] = Stack()
s.push(42)
```

**Python 3.12+** adds cleaner syntax (PEP 695) that eliminates the verbose `TypeVar` declaration:

```python
class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

def first[T](items: list[T]) -> T:
    return items[0]
```

**Bounded TypeVar** constrains the type variable:

```python
from typing import TypeVar

T = TypeVar('T', bound=float)  # T must be float or a subclass

def add(a: T, b: T) -> T:
    return a + b

# Constrained TypeVar — T must be exactly one of these:
T = TypeVar('T', int, str)
```

Unlike Rust and Java, Python generics impose no constraints at runtime — they are purely a static analysis tool. The type checker verifies that `Stack[int].push("hello")` is a type error, but at runtime the code executes normally (unless the string causes an error elsewhere).

> **Sources:** Martelli et al (2023) Ch.5 pp. 171–185 · Ramalho (2022) Ch.8 pp. 253–280, Ch.15 pp. 519–540 · [Python docs — typing module](https://docs.python.org/3/library/typing.html) · [PEP 484 — Type Hints](https://peps.python.org/pep-0484/) · [PEP 695 — Type Parameter Syntax](https://peps.python.org/pep-0695/)

### Generics Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Implementation strategy** | Monomorphization (code per type) | Type erasure (single version + casts) | Static checking only (no runtime effect) |
| **Runtime type info** | Full (distinct types in binary) | Erased (no generic type info at runtime) | None (generics are advisory) |
| **Primitive type params** | Yes (`Vec<i32>` — native) | No (`List<int>` illegal — use `List<Integer>`) | Yes (annotations only — `list[int]`) |
| **Code generation** | Separate code per type | Shared code with inserted casts | No code generation |
| **Binary size impact** | Larger (duplicated code) | Minimal | None |
| **Boxing overhead** | None | Yes (primitives must be boxed) | N/A (everything is already an object) |
| **Type bounds syntax** | `T: Trait + Trait2` | `T extends Interface` / `? extends` / `? super` | `TypeVar('T', bound=Type)` |
| **Variance** | Lifetime/type variance (implicit) | Use-site wildcards (`? extends`, `? super`) | Declaration-site (`TypeVar(covariant=True)`) |

---

## 4. Traits, Interfaces & Protocols

How each language defines shared behavior contracts — Rust's traits (the central abstraction mechanism), Java's interfaces (evolved from abstract to rich), and Python's protocols (structural subtyping for a dynamic language).

### Rust: Traits and Dispatch

Traits are Rust's sole abstraction for shared behavior — there are no classes or inheritance. A trait defines a set of methods; types implement traits via separate `impl Trait for Type` blocks.

```rust
trait Area {
    fn area(&self) -> f64;
}

struct Circle { radius: f64 }
struct Rectangle { width: f64, height: f64 }

impl Area for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

impl Area for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}
```

Rust provides an explicit choice between **static dispatch** (monomorphized, zero-cost) and **dynamic dispatch** (vtable pointer, runtime flexibility):

```rust
// Static dispatch — monomorphized, no runtime cost
fn print_area(shape: &impl Area) {
    println!("Area: {}", shape.area());
}

// Dynamic dispatch — vtable-based, allows heterogeneous collections
fn print_area_dyn(shape: &dyn Area) {
    println!("Area: {}", shape.area());
}

// Heterogeneous collection requires dynamic dispatch:
let shapes: Vec<Box<dyn Area>> = vec![
    Box::new(Circle { radius: 1.0 }),
    Box::new(Rectangle { width: 2.0, height: 3.0 }),
];
```

**Key trait features:**

- **Default methods**: traits can provide default implementations that types can override
- **Associated types**: `type Item;` inside a trait binds a type to the implementation (avoids extra type parameters)
- **Supertraits**: `trait A: B` means implementing A requires implementing B
- **Operator overloading**: via `std::ops` traits (`Add`, `Mul`, `Index`, `Deref`, etc.)
- **Derive macros**: `#[derive(Debug, Clone, PartialEq)]` auto-implements common traits
- **Orphan rule**: you can only implement a trait if either the trait or the type is local to your crate — prevents conflicting implementations across crates

**Trait objects** (`dyn Trait`) use a **fat pointer** — two pointer widths: one to the data, one to the vtable. Not all traits are object-safe; traits with generic methods or methods returning `Self` cannot be used as trait objects.

> **Sources:** Blandy & Orendorff (2017) Ch.11 pp. 235–263, Ch.12 pp. 265–280 · Klabnik & Nichols (2023) Ch.10 pp. 200–213 · Gjengset (2022) Ch.2 pp. 19–35, Ch.3 pp. 37–56 · [Rust Reference — Traits](https://doc.rust-lang.org/reference/items/traits.html) · [Rust Reference — Trait Objects](https://doc.rust-lang.org/reference/types/trait-object.html)

### Java: Interfaces and Sealed Hierarchies

Java interfaces have evolved dramatically — from pure abstract contracts (pre-Java 8) to supporting default methods, private methods, and sealed hierarchies:

| Java Version | Interface Feature |
|-------------|-------------------|
| Java 1.0 | Abstract method declarations only |
| Java 8 | `default` methods, `static` methods |
| Java 9 | `private` methods |
| Java 17 | `sealed` interfaces with `permits` |
| Java 21 | Exhaustive pattern matching in `switch` |

```java
public sealed interface Shape permits Circle, Rectangle {
    double area();  // abstract method

    default String describe() {  // default implementation
        return "Shape with area " + area();
    }
}

public record Circle(double radius) implements Shape {
    @Override
    public double area() { return Math.PI * radius * radius; }
}

public record Rectangle(double width, double height) implements Shape {
    @Override
    public double area() { return width * height; }
}
```

Java uses **dynamic dispatch** (virtual method invocation) by default — all non-private, non-static, non-final methods are virtual. There is no explicit static dispatch equivalent to Rust's monomorphization for interface calls; **devirtualization is a JIT optimization** that the HotSpot C2 compiler may apply when profiling shows a call site is monomorphic (always the same type).

Key differences from Rust traits:
- A class can implement multiple interfaces but inherit from only one class
- Interfaces cannot have instance state (no fields, only constants)
- Abstract classes provide partial implementation with state
- No orphan rule — any class can implement any interface (no coherence restriction)
- No compile-time choice between static and dynamic dispatch

> **Sources:** Horstmann (2024) Ch.5 pp. 74–82 · Evans (2022) Ch.3 pp. 60–77 · Bloch (2018) Ch.6 pp. 175–191 · [JLS — Interfaces](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html) · [JEP 409 — Sealed Classes](https://openjdk.org/jeps/409) · [Oracle — Interfaces](https://docs.oracle.com/javase/tutorial/java/IandI/createinterface.html)

### Python: Duck Typing, ABCs, and typing.Protocol

Python has three layers of "interface" mechanisms, from most dynamic to most static:

**1. Duck typing** — no declaration needed. If an object has the right methods, it works:

```python
class MyFile:
    def read(self, n=-1):
        return "data"

def process(f):
    return f.read()  # works with any object that has read()

process(MyFile())         # works
process(open("file.txt")) # works — same interface, different type
```

**2. ABCs** (Abstract Base Classes) — explicit interface declaration with `@abstractmethod`:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float: ...

    def describe(self) -> str:  # concrete method with default
        return f"Shape with area {self.area()}"

class Circle(Shape):
    def __init__(self, radius: float):
        self.radius = radius

    def area(self) -> float:
        return 3.14159 * self.radius ** 2

# Shape()  # TypeError — can't instantiate abstract class
```

**3. `typing.Protocol`** (PEP 544) — structural subtyping for static checkers. A class satisfies a Protocol if it has the right methods, without inheriting from it. This is "static duck typing":

```python
from typing import Protocol

class HasArea(Protocol):
    def area(self) -> float: ...

class Circle:  # does NOT inherit from HasArea
    def __init__(self, radius: float):
        self.radius = radius
    def area(self) -> float:
        return 3.14159 * self.radius ** 2

def print_area(shape: HasArea) -> None:  # accepts anything with area()
    print(shape.area())

print_area(Circle(5.0))  # type-checks — Circle has area()
```

Python's `collections.abc` module provides standard ABCs: `Iterable`, `Iterator`, `Sequence`, `Mapping`, `MutableMapping`, `Callable`, `Hashable`, etc. Method resolution uses **always-dynamic dictionary lookup** — even with ABCs or Protocols, dispatch goes through `__dict__` and MRO at runtime.

> **Sources:** Ramalho (2022) Ch.13 pp. 431–486 · Martelli et al (2023) Ch.4 pp. 135–155 · Viafore (2021) Ch.12–13 pp. 171–197 · [Python docs — abc module](https://docs.python.org/3/library/abc.html) · [Python docs — typing.Protocol](https://docs.python.org/3/library/typing.html#typing.Protocol) · [PEP 544 — Protocols](https://peps.python.org/pep-0544/) · [PEP 3119 — ABCs](https://peps.python.org/pep-3119/)

### Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Abstraction mechanism** | Traits | Interfaces + abstract classes | Duck typing, ABCs, Protocol |
| **Method resolution** | Static (monomorphized) or dynamic (`dyn Trait`) — explicit choice | Always virtual (JIT may devirtualize) | Always dynamic (dict lookup + MRO) |
| **Multiple "interfaces"** | Multiple trait impls per type | Multiple interface impls per class | Multiple inheritance with C3 MRO |
| **Default methods** | Yes (in trait) | Yes (since Java 8) | Yes (concrete methods in ABC) |
| **State in interface** | No (traits have no fields) | No (interfaces have no instance fields) | Yes (ABCs can have instance fields) |
| **Retroactive impl** | Yes (impl trait for existing type, orphan-rule restricted) | No (must modify the class) | Yes (virtual subclass registration, or Protocol satisfies structurally) |
| **Structural subtyping** | No (must explicitly `impl Trait`) | No (must explicitly `implements`) | Yes (`typing.Protocol` — no inheritance needed) |

---

## 5. Type Inference & Type Annotations

How each language deduces types — Rust's bidirectional inference (strong, pervasive), Java's limited `var` keyword, and Python's gradual typing (optional annotations checked by external tools).

### Rust: Pervasive Type Inference

Rust uses a **bidirectional type inference** algorithm influenced by Hindley-Milner. The compiler infers types for local variables, closure parameters, and generic type arguments based on usage context — but function signatures always require explicit type annotations.

```rust
let x = 5;                    // inferred: i32 (default integer type)
let y = 2.0;                  // inferred: f64 (default float type)
let v = Vec::new();           // type inferred from later usage...
v.push(5);                    // ...now v is Vec<i32>

let s: Vec<String> = Vec::new();  // explicit when inference needs help

// Turbofish disambiguates when inference fails:
let n = "42".parse::<i32>().unwrap();

// Closures infer parameter and return types:
let add = |a, b| a + b;      // types inferred from first usage
let result = add(1_i32, 2);   // now add is |i32, i32| -> i32
```

**Function signatures are always explicit** — this is a deliberate design choice for readability and separate compilation:

```rust
// Parameters and return types always annotated:
fn add(a: i32, b: i32) -> i32 {
    a + b  // return type must match annotation
}

// Generic functions require explicit trait bounds:
fn largest<T: PartialOrd>(a: T, b: T) -> T {
    if a >= b { a } else { b }
}
```

The inference is local (within a function body) and does not cross function boundaries. This ensures that each function's type signature serves as documentation and that changes to a function body cannot accidentally change the types visible to callers.

> **Sources:** Klabnik & Nichols (2023) Ch.3 pp. 31–35 · Blandy & Orendorff (2017) Ch.6 pp. 123–130 · [Rust Reference — Type System](https://doc.rust-lang.org/reference/type-system.html) · [Rust By Example — Inference](https://doc.rust-lang.org/rust-by-example/types/inference.html)

### Java: var and Limited Inference

Java was explicitly typed for decades. Modern Java adds limited inference in specific contexts:

**`var`** (Java 10+) — local variable type inference only:

```java
var list = new ArrayList<String>();  // infers ArrayList<String>
var stream = list.stream();          // infers Stream<String>

// var CANNOT be used for:
// - Method parameters
// - Method return types
// - Instance/class fields
// - Lambda parameters (allowed since Java 11)
```

**Diamond operator `<>`** (Java 7+) — infers generic type arguments from the left-hand side:

```java
// Before Java 7:
Map<String, List<Integer>> map = new HashMap<String, List<Integer>>();
// After Java 7:
Map<String, List<Integer>> map = new HashMap<>();
```

**Lambda parameter types** are inferred from the functional interface context:

```java
List<String> names = List.of("Alice", "Bob", "Charlie");
names.sort((a, b) -> a.length() - b.length());  // a, b inferred as String
```

Compared to Rust, Java's inference is much more limited. Implicit type conversions in conditionals can also cause surprises — the ternary operator `cond ? a : b` follows complex promotion rules that may widen types unexpectedly.

> **Sources:** Evans (2022) Ch.1 pp. 3–25 · Valeev (2024) Ch.2 pp. 19–40 · [JEP 286 — Local-Variable Type Inference](https://openjdk.org/jeps/286) · [JLS — Type Inference](https://docs.oracle.com/javase/specs/jls/se21/html/jls-18.html)

### Python: Gradual Typing with Annotations

Python's type system is **gradual** — annotations are optional, and code runs identically with or without them. Type checking is performed by external tools (mypy, pyright), not the Python interpreter.

```python
# No annotations — works fine at runtime
def greet(name):
    return f"Hello, {name}!"

# With annotations — same runtime behavior, but now type-checkable
def greet(name: str) -> str:
    return f"Hello, {name}!"

# Variable annotations (PEP 526)
x: int = 42
names: list[str] = ["Alice", "Bob"]
```

**mypy** and **pyright** infer types for local variables within annotated functions:

```python
def process(data: list[int]) -> int:
    total = sum(data)       # mypy infers: int
    average = total / len(data)  # mypy infers: float
    return round(average)   # mypy infers: int
```

The gradual typing philosophy means you can add types incrementally to an existing codebase. The `typing` module provides annotation building blocks: `Optional`, `Union`, `Literal`, `Final`, `TypeGuard`, `TypeAlias`, `Annotated`, and more. `reveal_type(x)` shows the inferred type in mypy/pyright output.

**PEP 563** (Postponed Evaluation of Annotations) makes all annotations strings by default, avoiding runtime evaluation overhead and enabling forward references.

> **Sources:** Martelli et al (2023) Ch.5 pp. 171–194 · Ramalho (2022) Ch.8 pp. 253–302 · Viafore (2021) Ch.2–7 pp. 23–106 · [PEP 484 — Type Hints](https://peps.python.org/pep-0484/) · [PEP 526 — Variable Annotations](https://peps.python.org/pep-0526/) · [mypy documentation](https://mypy.readthedocs.io/en/stable/) · [pyright documentation](https://microsoft.github.io/pyright/)

### Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Inference scope** | Local variables, generics, closures | `var` (locals), diamond, lambdas | mypy infers within annotated functions |
| **Required annotations** | Function signatures (params + return) | Fields, parameters, return types | Nothing required — all optional |
| **Enforcement** | Built into compiler | Built into compiler | External tools (mypy, pyright, Pyre) |
| **Inference algorithm** | Bidirectional (Hindley-Milner-influenced) | Limited flow-sensitive | Dataflow within function bodies |
| **Gradual adoption** | No — fully typed or won't compile | No — types required everywhere | Yes — add types incrementally |
| **Runtime effect** | Types exist in compiled binary | Types exist in bytecode + runtime | Zero runtime effect |

---

## 6. Type Conversion & Casting

How each language converts between types — Rust's explicit trait-based conversions, Java's complex widening/narrowing/autoboxing rules, and Python's constructor-based and special-method-based coercion.

### Rust: From/Into, TryFrom/TryInto, and `as`

Rust conversions are explicit and trait-based. There are no implicit type conversions except for **Deref coercion** (e.g., `&String` auto-coerces to `&str`).

**`as` — primitive casts** (potentially lossy, no error):

```rust
let x: i32 = 300;
let y: u8 = x as u8;    // 44 — wraps silently (300 % 256)
let z: f64 = x as f64;  // 300.0 — lossless
let w: i32 = 3.99_f64 as i32;  // 3 — truncates toward zero
```

**`From<T>` / `Into<T>` — infallible conversions** (implementing `From` gives `Into` for free):

```rust
let s = String::from("hello");  // From<&str> for String
let n: i64 = i64::from(42_i32); // From<i32> for i64 — always safe

// Into is the reverse direction:
let n: i64 = 42_i32.into();
```

**`TryFrom<T>` / `TryInto<T>` — fallible conversions** (return `Result`):

```rust
use std::convert::TryFrom;

let big: i32 = 300;
let small: Result<u8, _> = u8::try_from(big);  // Err — 300 doesn't fit in u8

let valid: i32 = 42;
let byte: u8 = u8::try_from(valid).unwrap();    // Ok(42)
```

**Utility conversion traits:**

| Trait | Purpose | Example |
|-------|---------|---------|
| `From<T>` / `Into<T>` | Infallible conversion | `String::from("hi")` |
| `TryFrom<T>` / `TryInto<T>` | Fallible conversion (returns `Result`) | `u8::try_from(300_i32)` |
| `AsRef<T>` / `AsMut<T>` | Cheap reference conversion | `fn f(s: &impl AsRef<str>)` |
| `Borrow<T>` | Like AsRef but with hash/eq consistency | `HashMap` key lookups |
| `Deref` / `DerefMut` | Transparent smart pointer access | `&String` coerces to `&str` |
| `ToOwned` | Generalized `Clone` — `&str` to `String` | `"hello".to_owned()` |
| `Cow<T>` | Clone-on-write — delays allocation | `Cow<str>` for optional ownership |

> **Sources:** Matthews (2024) Ch.4 pp. 80–91 · Blandy & Orendorff (2017) Ch.6 pp. 130–142, Ch.13 pp. 281–301 · [Rust std — std::convert](https://doc.rust-lang.org/std/convert/index.html) · [Rust By Example — Casting](https://doc.rust-lang.org/rust-by-example/types/cast.html) · [Rust By Example — From and Into](https://doc.rust-lang.org/rust-by-example/conversion.html)

### Java: Widening, Narrowing, Autoboxing

Java has complex implicit conversion rules. The interaction between primitive conversions, autoboxing, and reference casting creates many pitfalls.

**Widening primitive conversions** (implicit, but not always safe):

```java
int i = 123_456_789;
float f = i;           // 1.23456792E8 — precision loss! (float has 24-bit mantissa)
long l = i;            // 123456789L — lossless
double d = i;          // 123456789.0 — lossless

// int → float loses precision for large values
// long → float and long → double also lose precision
```

**Narrowing conversions** require explicit casts and may lose data:

```java
int big = 256;
byte b = (byte) big;   // 0 — wraps silently (256 % 256)

double pi = 3.14159;
int truncated = (int) pi;  // 3 — truncates toward zero
```

**Compound assignment hides narrowing casts:**

```java
short s = 0;
s += 1;          // compiles — equivalent to: s = (short)(s + 1)
// s = s + 1;    // does NOT compile — (s + 1) is int
```

**Autoboxing/unboxing** (primitive ↔ wrapper object):

```java
Integer boxed = 42;         // autoboxing: int → Integer
int unboxed = boxed;        // unboxing: Integer → int
Integer nullable = null;
int crash = nullable;        // NullPointerException — unboxing null
```

**Reference casting** (up/down the class hierarchy):

```java
Object obj = "hello";
String s = (String) obj;     // downcast — succeeds at runtime
Integer n = (Integer) obj;   // ClassCastException at runtime

// Safe cast with instanceof:
if (obj instanceof String str) {
    System.out.println(str.length());  // pattern variable 'str' is already String
}
```

The interaction between generics type erasure and casts creates "unchecked cast" warnings that can mask actual type errors — the compiler cannot verify generic casts at runtime.

> **Sources:** Valeev (2024) Ch.2 pp. 19–60, Ch.4 pp. 96–123, Ch.5 pp. 124–154 · [JLS — Conversions and Contexts](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html) · [JLS — Widening Primitive Conversion](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.2) · [JLS — Narrowing Primitive Conversion](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.3)

### Python: Constructors and Special Methods

Python has no implicit type coercion between unrelated types — `"3" + 4` raises `TypeError`, unlike JavaScript. Conversion uses type constructors and special methods.

**Type constructors:**

```python
int("42")       # 42 — string to int
float("3.14")   # 3.14 — string to float
str(42)         # "42" — int to string
bool(0)         # False — truthiness
list("abc")     # ['a', 'b', 'c'] — iterable to list
tuple([1,2,3])  # (1, 2, 3) — list to tuple
```

**Implicit numeric promotion** (only within arithmetic):

```python
3 + 4.0      # 7.0 — int promoted to float
3 + 4j       # (3+4j) — int promoted to complex
True + 1     # 2 — bool (subclass of int) in arithmetic
```

**Special methods** for custom conversion:

```python
class Temperature:
    def __init__(self, celsius: float):
        self.celsius = celsius

    def __float__(self) -> float:
        return self.celsius

    def __int__(self) -> int:
        return round(self.celsius)

    def __bool__(self) -> bool:
        return self.celsius != 0.0

    def __str__(self) -> str:
        return f"{self.celsius}°C"

    def __repr__(self) -> str:
        return f"Temperature({self.celsius})"

t = Temperature(36.6)
float(t)  # 36.6
int(t)    # 37
bool(t)   # True
str(t)    # "36.6°C"
```

**Truthiness** is pervasive in Python — `bool()` coercion is called implicitly in `if`, `while`, `and`, `or`, and `not` contexts. Falsy values: `0`, `0.0`, `""`, `[]`, `{}`, `set()`, `None`, `False`. Everything else is truthy. Custom classes can define `__bool__()` or `__len__()` to control truthiness.

The `==` operator uses `__eq__` and can compare across types: `1 == 1.0 == True` is `True`. Identity (`is`) is separate from equality (`==`).

> **Sources:** Martelli et al (2023) Ch.3 pp. 45–55 · Ramalho (2022) Ch.6 pp. 201–228, Ch.16 pp. 561–590 · [Python docs — Built-in Functions](https://docs.python.org/3/library/functions.html) · [Python docs — Special method names](https://docs.python.org/3/reference/datamodel.html#special-method-names)

### Conversion Safety Spectrum

| Aspect | Rust (most explicit) | Java (mixed) | Python (dynamic) |
|--------|---------------------|--------------|------------------|
| **Implicit numeric widening** | None — all conversions explicit | Yes (`int→long`, `int→float`) | Yes in arithmetic (`int+float→float`) |
| **Overflow detection** | Panic (debug) / wrap (release) / `checked_*` | Wraps silently | No overflow (arbitrary precision) |
| **Precision loss** | `as` warns in clippy; `From` prevents | `int→float` loses silently | No implicit precision loss |
| **Null/None in conversion** | `Option` — must handle | `NullPointerException` on unbox | `TypeError` or `AttributeError` |
| **Conversion traits/methods** | `From`, `Into`, `TryFrom`, `TryInto` | Casts `(Type)`, autoboxing, constructors | `__int__`, `__float__`, `__bool__`, `__str__` |
| **Safe cast pattern** | `TryFrom` returns `Result` | `instanceof` check before cast | `isinstance()` check or try/except |

---

## 7. Advanced Types

Advanced type system features — Rust's newtype pattern, never type, and PhantomData; Java's type erasure internals, intersection types, and Valhalla roadmap; Python's TypedDict, `@overload`, variance, and ParamSpec.

### Rust: Newtype, Never Type, DSTs, PhantomData

**Newtype pattern** — wraps a type to create a distinct type with zero runtime cost:

```rust
struct Meters(f64);
struct Seconds(f64);

// These are different types — cannot accidentally mix them:
fn speed(distance: Meters, time: Seconds) -> f64 {
    distance.0 / time.0
}

// Compiler optimizes the wrapper away — same memory layout as f64
```

The newtype pattern enables: bypassing the orphan rule (implement foreign traits on foreign types by wrapping), encoding units in the type system, and creating type-safe wrappers with no runtime cost.

**Type aliases** — create synonyms, not new types:

```rust
type Kilometers = i32;
type Result<T> = std::result::Result<T, std::io::Error>;
// Kilometers and i32 are interchangeable — no type safety gained
```

**Never type `!`** — for functions that never return:

```rust
fn diverge() -> ! {
    panic!("this function never returns");
}

// Useful in match arms — `!` coerces to any type:
let value: i32 = match some_option {
    Some(v) => v,
    None => panic!("missing"),  // panic! returns !, coerces to i32
};
```

**Dynamically Sized Types (DSTs)** — types whose size is not known at compile time:

| DST | Description | Used as |
|-----|-------------|---------|
| `str` | String slice (UTF-8 bytes) | `&str` (fat pointer: ptr + length) |
| `[T]` | Slice of T | `&[T]` (fat pointer: ptr + length) |
| `dyn Trait` | Trait object | `&dyn Trait` (fat pointer: ptr + vtable) |

DSTs exist only behind pointers (`&`, `Box`, `Rc`, `Arc`). The `Sized` trait is an auto-trait that most types implement; DSTs do not. Generic parameters are `T: Sized` by default; use `T: ?Sized` to accept DSTs.

**`PhantomData<T>`** — tells the compiler a type "logically contains" a T without storing it. Used for variance annotation, lifetime markers, and type-state patterns:

```rust
use std::marker::PhantomData;

struct Slice<'a, T> {
    start: *const T,
    end: *const T,
    _lifetime: PhantomData<&'a T>,  // tells compiler this borrows T for 'a
}
```

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 419–458 · Blandy & Orendorff (2017) Ch.13 pp. 289–295 · Gjengset (2022) Ch.1 pp. 1–17, Ch.2 pp. 19–35 · [Rustonomicon — PhantomData](https://doc.rust-lang.org/nomicon/phantom-data.html) · [Rustonomicon — Subtyping and Variance](https://doc.rust-lang.org/nomicon/subtyping.html) · [Rust Reference — Never type](https://doc.rust-lang.org/reference/types/never.html) · [Rust Reference — DSTs](https://doc.rust-lang.org/reference/dynamically-sized-types.html) · [Rust Reference — Type aliases](https://doc.rust-lang.org/reference/items/type-aliases.html)

### Java: Erasure Internals, Intersection Types, Valhalla

**Type erasure in detail** — the compiler erases generic type information, replacing type parameters with their bounds (or `Object` if unbounded):

```java
// Source code:
public class Box<T> {
    private T value;
    public T get() { return value; }
}

// After erasure (what the JVM sees):
public class Box {
    private Object value;
    public Object get() { return value; }
}

// The compiler inserts casts at call sites:
Box<String> box = new Box<>();
String s = box.get();  // becomes: String s = (String) box.get();
```

**Bridge methods** are synthesized to maintain polymorphism under erasure. When a generic class is extended with concrete types, the compiler generates methods that perform the necessary casts:

```java
interface Comparable<T> {
    int compareTo(T o);
}

class Name implements Comparable<Name> {
    public int compareTo(Name o) { /* ... */ }
    // Compiler generates bridge method:
    // public int compareTo(Object o) { return compareTo((Name) o); }
}
```

**Intersection types** — multiple bounds on a type parameter:

```java
<T extends Serializable & Comparable<T>> void process(T item) {
    // T must implement both Serializable AND Comparable<T>
}
```

**Project Valhalla** (in progress) aims to fundamentally change Java's type system by introducing **value types** (inline classes) that:
- Can be generic type arguments without boxing — `List<int>` would finally be possible
- Are stored inline (no object header, no heap allocation for small values)
- Enable generic specialization — separate code for primitive types

This would eliminate the largest practical limitation of Java generics: the boxing overhead required for primitive types in generic containers.

> **Sources:** Horstmann (2024) Ch.8 pp. 110–116 · Bloch (2018) Ch.5 pp. 140–155 · Naftalin & Wadler (2024) Ch.5–6 · [JLS — Type Erasure](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.6) · [JLS — Intersection Types](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.9) · [JEP 218 — Generics over Primitive Types](https://openjdk.org/jeps/218)

### Python: TypedDict, @overload, Variance, ParamSpec

**`TypedDict`** — typed dictionary shapes for JSON-like data, where each key has a specific type:

```python
from typing import TypedDict

class Movie(TypedDict):
    name: str
    year: int
    rating: float

def display(movie: Movie) -> str:
    return f"{movie['name']} ({movie['year']}) - {movie['rating']}/10"

# Type checker ensures correct keys and value types:
m: Movie = {"name": "Blade Runner", "year": 1982, "rating": 8.1}
```

**`@overload`** — declares multiple type signatures for a single function. The type checker uses these to refine return types based on argument types:

```python
from typing import overload

@overload
def process(data: str) -> str: ...
@overload
def process(data: int) -> int: ...
@overload
def process(data: list[str]) -> list[str]: ...

def process(data):  # actual implementation
    if isinstance(data, str):
        return data.upper()
    elif isinstance(data, int):
        return data * 2
    elif isinstance(data, list):
        return [s.upper() for s in data]

reveal_type(process("hello"))  # str
reveal_type(process(42))       # int
```

**Variance in Python generics:**

| Variance | Meaning | Example |
|----------|---------|---------|
| **Invariant** (default) | `list[Dog]` is NOT a subtype of `list[Animal]` | `list`, `dict`, `set` |
| **Covariant** | `Sequence[Dog]` IS a subtype of `Sequence[Animal]` | `Sequence`, `FrozenSet`, `tuple` |
| **Contravariant** | `Callable[[Animal], None]` IS a subtype of `Callable[[Dog], None]` | `Callable` (in parameter position) |

```python
from typing import TypeVar

T_co = TypeVar('T_co', covariant=True)
T_contra = TypeVar('T_contra', contravariant=True)
```

**`ParamSpec`** (PEP 612) — captures function parameter types for accurate decorator typing:

```python
from typing import ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

def logged(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@logged
def add(a: int, b: int) -> int:
    return a + b

# Type checker knows: add(a: int, b: int) -> int — parameter types preserved!
```

**`Self` type** (PEP 673) — for methods that return the current class:

```python
from typing import Self

class Builder:
    def set_name(self, name: str) -> Self:
        self.name = name
        return self  # type checker knows this returns the actual subclass
```

> **Sources:** Ramalho (2022) Ch.8 pp. 280–302, Ch.15 pp. 519–560 · Viafore (2021) Ch.14 pp. 199–210 · [Python docs — typing.TypedDict](https://docs.python.org/3/library/typing.html#typing.TypedDict) · [Python docs — typing.overload](https://docs.python.org/3/library/typing.html#typing.overload) · [PEP 612 — ParamSpec](https://peps.python.org/pep-0612/) · [PEP 673 — Self Type](https://peps.python.org/pep-0673/) · [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/)

### Advanced Types Comparison

| Feature | Rust | Java | Python |
|---------|------|------|--------|
| **Zero-cost type wrapper** | Newtype pattern (`struct Meters(f64)`) | Value types (Valhalla, in progress) | `NewType` (static alias only) |
| **Never/bottom type** | `!` (never type) | None (closest: infinite loop, `System.exit`) | `NoReturn` / `Never` |
| **Variance mechanism** | Implicit from lifetime/type structure; `PhantomData` for annotation | Use-site wildcards (`? extends`, `? super`) | Declaration-site (`TypeVar(covariant=True)`) |
| **Type aliases** | `type Km = i32` (synonym, not new type) | None (until Valhalla) | `TypeAlias`, `type` statement (3.12+) |
| **Typed dict shapes** | N/A (use structs) | N/A (use records/POJOs) | `TypedDict` |
| **Overloaded signatures** | N/A (use generics + trait bounds) | Method overloading (actual dispatch) | `@overload` (static checker only) |
| **Decorator typing** | N/A | N/A | `ParamSpec` (PEP 612) |

---

## 8. Nullability & Option Types

How each language handles the absence of a value — Rust's zero-null design with `Option<T>` / `Result<T,E>`, Java's billion-dollar mistake with `null` and the `Optional` retrofit, and Python's `None` with `typing.Optional`.

### Rust: Option\<T\> and Result\<T, E\>

Rust has **no null**. Instead, `Option<T>` makes absence explicit in the type system — the compiler forces you to handle `None` before accessing the value.

```rust
enum Option<T> {
    Some(T),
    None,
}

fn find_user(id: u64) -> Option<String> {
    if id == 1 { Some("Alice".to_string()) } else { None }
}

// Must handle both cases:
match find_user(1) {
    Some(name) => println!("Found: {}", name),
    None => println!("User not found"),
}

// Concise alternatives:
let name = find_user(1).unwrap_or("Unknown".to_string());
let name = find_user(1).unwrap();  // panics if None — avoid in production

// if let for when you only care about Some:
if let Some(name) = find_user(1) {
    println!("Found: {}", name);
}
```

**`Result<T, E>`** extends the pattern to errors:

```rust
fn parse_port(s: &str) -> Result<u16, std::num::ParseIntError> {
    s.parse::<u16>()
}

// The ? operator propagates errors:
fn connect(addr: &str) -> Result<(), Box<dyn std::error::Error>> {
    let port = parse_port("8080")?;  // returns early if Err
    // ...
    Ok(())
}
```

**Combinators** enable ergonomic chaining without nested matches:

```rust
let email: Option<String> = find_user(1)
    .map(|name| format!("{}@example.com", name.to_lowercase()))
    .filter(|email| email.contains('@'));

// ok_or converts Option to Result:
let name = find_user(1).ok_or("user not found")?;
```

**Zero-cost abstraction**: `Option<&T>` is the same size as a raw pointer thanks to **niche optimization** — the null pointer value is used as the `None` discriminant, so `Option<&T>` occupies exactly one pointer width, not two.

> **Sources:** Klabnik & Nichols (2023) Ch.6 pp. 108–117 · Blandy & Orendorff (2017) Ch.10 pp. 220–230 · [Rust std — Option](https://doc.rust-lang.org/std/option/index.html) · [Rust std — Result](https://doc.rust-lang.org/std/result/index.html) · [Rust By Example — Option and unwrap](https://doc.rust-lang.org/rust-by-example/error/option_unwrap.html)

### Java: null, NullPointerException, Optional

Java's `null` is what Tony Hoare called his "billion-dollar mistake" — any reference type can be `null`, and dereferencing `null` throws `NullPointerException` (NPE). The fundamental problem: `null` is a subtype of every reference type, and the type system cannot distinguish `String` from `String-or-null`.

```java
String name = null;
int len = name.length();  // NullPointerException at runtime
```

**`Optional<T>`** (Java 8+) signals "might be absent" as a return-type convention:

```java
public Optional<String> findUser(long id) {
    if (id == 1) return Optional.of("Alice");
    return Optional.empty();
}

// Handling:
Optional<String> user = findUser(1);
String name = user.orElse("Unknown");
user.ifPresent(n -> System.out.println("Found: " + n));

// Chaining:
String email = findUser(1)
    .map(n -> n.toLowerCase() + "@example.com")
    .filter(e -> e.contains("@"))
    .orElse("no-email");
```

**Limitations of Optional:**
- **Not enforced** — you can still pass `null` instead of `Optional.empty()`
- **Heap-allocated** — unlike Rust's `Option`, Java's `Optional` is a wrapper object (until Valhalla)
- **Not recommended for fields or parameters** — per Bloch, `Optional` is intended only as a return type
- **API adds complexity** — `get()` throws `NoSuchElementException` if empty (as bad as NPE)

**Java 14+** provides "helpful NPEs" (JEP 358) with better error messages that pinpoint which part of a chain was null:

```
java.lang.NullPointerException: Cannot invoke "String.length()"
    because the return value of "Person.getName()" is null
```

Modern null-safety efforts (JSpecify, Checker Framework) add `@Nullable` and `@NonNull` annotations checked by static analysis tools, moving toward Rust-like explicitness without changing the language.

> **Sources:** Horstmann (2024) Ch.5 pp. 70–74 · Bloch (2018) Item 61 · Valeev (2024) Ch.7 pp. 177–212 · [Java docs — Optional](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) · [JEP 358 — Helpful NullPointerExceptions](https://openjdk.org/jeps/358)

### Python: None and typing.Optional

Python's `None` is a singleton object of type `NoneType`. Any variable can be `None` at runtime — the language has no null safety. Accessing an attribute of `None` raises `AttributeError`.

```python
name: str | None = None
print(name.upper())  # AttributeError: 'NoneType' object has no attribute 'upper'
```

**`typing.Optional[X]`** (equivalent to `X | None` in Python 3.10+) signals to type checkers that a value might be `None`:

```python
from typing import Optional

def find_user(user_id: int) -> Optional[str]:
    if user_id == 1:
        return "Alice"
    return None

# Type checker requires narrowing before use:
name = find_user(1)
# name.upper()  # mypy error: Item "None" of "str | None" has no attribute "upper"

if name is not None:
    print(name.upper())  # OK — type narrowed to str
```

**mypy's strict mode** can catch unguarded `None` access. The `is not None` check narrows the type from `Optional[str]` to `str`:

```python
def get_email(user_id: int) -> str:
    name = find_user(user_id)
    if name is None:
        return "unknown@example.com"
    return f"{name.lower()}@example.com"  # mypy knows: name is str here
```

Python's approach is middle ground: less safe than Rust (no compile-time enforcement at the language level) but type checkers catch many bugs. At runtime, `None` access still raises `AttributeError` — the safety net is entirely in static analysis tooling.

> **Sources:** Ramalho (2022) Ch.8 pp. 260–270 · Martelli et al (2023) Ch.5 pp. 178–185 · Viafore (2021) Ch.4 pp. 45–60 · [Python docs — typing.Optional](https://docs.python.org/3/library/typing.html#typing.Optional) · [PEP 484 — Type Hints](https://peps.python.org/pep-0484/) · [mypy docs — Optional types and None](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#optional-types-and-the-none-type)

### Nullability Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Null value** | Does not exist | `null` (any reference) | `None` (any variable) |
| **Absence type** | `Option<T>` (compiler-enforced) | `Optional<T>` (convention, not enforced) | `Optional[X]` / `X \| None` (type checker) |
| **Unhandled absence** | Does not compile | `NullPointerException` at runtime | `AttributeError` at runtime |
| **Overhead** | Zero-cost (niche optimization) | Heap-allocated wrapper object | N/A (None is a singleton) |
| **Propagation** | `?` operator, combinators | `map`, `flatMap`, `orElse` | `if x is not None` patterns |
| **Trend** | Already solved | Moving toward annotations (@Nullable, JSpecify) | Moving toward stricter mypy --strict |

The modern trend across all languages moves toward Rust's approach — making absence explicit in the type system. Kotlin's null safety, Swift's optionals, and Java's ongoing null-annotation efforts all aim to prevent null-related bugs at compile time rather than runtime.

---

## Sources

### Books

| Book | Relevant Sections | Path |
|------|-------------------|------|
| Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.3 pp. 31–58, Ch.5 pp. 85–102, Ch.6 pp. 103–117, Ch.10 pp. 181–213, Ch.15 pp. 315–351, Ch.19 pp. 419–458 | `books/Rust/Klabnik Nichols 2023 The Rust programming language.pdf` |
| Blandy & Orendorff (2017) — *Programming Rust* | Ch.3 pp. 43–69, Ch.5 pp. 93–121, Ch.6 pp. 123–142, Ch.9 pp. 193–209, Ch.10 pp. 211–233, Ch.11 pp. 235–263, Ch.12 pp. 265–280, Ch.13 pp. 281–301 | `books/Rust/Blandy Orendorff 2017 Programming Rust.pdf` |
| Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91, Ch.5 pp. 93–118 | `books/Rust/Matthews 2024 Code like a pro in Rust.pdf` |
| Gjengset (2022) — *Rust for Rustaceans* | Ch.1 pp. 1–17, Ch.2 pp. 19–35, Ch.3 pp. 37–56 | `books/Rust/Gjengset 2022 Rust for Rustaceans.pdf` |
| Horstmann (2024) — *Core Java, Vol. I* | Ch.3 pp. 41–52, Ch.4 pp. 55–68, Ch.5 pp. 70–82, Ch.8 pp. 104–116 | `books/Java/Horstmann 2024 Core Java vol I.pdf` |
| Bloch (2018) — *Effective Java* | Ch.5 pp. 117–155, Ch.6 pp. 157–191, Item 61 | `books/Java/Bloch 2018 Effective Java.pdf` |
| Evans (2022) — *The Well-Grounded Java Developer* | Ch.1 pp. 3–25, Ch.3 pp. 55–77 | `books/Java/Evans 2022 The well-grounded Java developer.pdf` |
| Valeev (2024) — *100 Java Mistakes* | Ch.2 pp. 19–60, Ch.4 pp. 96–123, Ch.5 pp. 124–154, Ch.7 pp. 177–212 | `books/Java/Valeev 2024 100 Java mistakes.pdf` |
| Naftalin & Wadler (2024) — *Java Generics and Collections* | Ch.1–3, Ch.5–6 | `books/Java/Naftalin Wadler 2024 Java generics and collections.pdf` |
| Martelli et al (2023) — *Python in a Nutshell* | Ch.3 pp. 33–113, Ch.4 pp. 115–169, Ch.5 pp. 171–194 | `books/Python/Martelli 2023 Python in a nutshell.pdf` |
| Ramalho (2022) — *Fluent Python* | Ch.1 pp. 3–20, Ch.2 pp. 21–76, Ch.3 pp. 77–116, Ch.4 pp. 117–162, Ch.5 pp. 163–200, Ch.6 pp. 201–228, Ch.8 pp. 253–302, Ch.13 pp. 431–486, Ch.15 pp. 519–560, Ch.16 pp. 561–590 | `books/Python/Ramalho 2022 Fluent Python.pdf` |
| Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.3 pp. 65–77 | `books/Python/Gorelick Ozsvald 2020 High performance Python.pdf` |
| Viafore (2021) — *Robust Python* | Ch.2–7 pp. 23–106, Ch.8–10 pp. 111–152, Ch.12–14 pp. 171–210 | `books/Python/Viafore 2021 Robust Python.pdf` |

### External Resources

**Rust**
- [Rust Reference — Types](https://doc.rust-lang.org/reference/types.html)
- [Rust Reference — Scalar Types](https://doc.rust-lang.org/reference/types/numeric.html)
- [Rust Reference — Struct Types](https://doc.rust-lang.org/reference/types/struct.html)
- [Rust Reference — Enum Types](https://doc.rust-lang.org/reference/types/enum.html)
- [Rust Reference — Generic Parameters](https://doc.rust-lang.org/reference/items/generics.html)
- [Rust Reference — Traits](https://doc.rust-lang.org/reference/items/traits.html)
- [Rust Reference — Trait Objects](https://doc.rust-lang.org/reference/types/trait-object.html)
- [Rust Reference — Type System](https://doc.rust-lang.org/reference/type-system.html)
- [Rust Reference — Never type](https://doc.rust-lang.org/reference/types/never.html)
- [Rust Reference — Dynamically Sized Types](https://doc.rust-lang.org/reference/dynamically-sized-types.html)
- [Rust Reference — Type aliases](https://doc.rust-lang.org/reference/items/type-aliases.html)
- [Rust Reference — Type cast expressions](https://doc.rust-lang.org/reference/expressions/operator-expr.html#type-cast-expressions)
- [Rust By Example — Primitives](https://doc.rust-lang.org/rust-by-example/primitives.html)
- [Rust By Example — Custom Types](https://doc.rust-lang.org/rust-by-example/custom_types.html)
- [Rust By Example — Enums](https://doc.rust-lang.org/rust-by-example/custom_types/enum.html)
- [Rust By Example — Generics](https://doc.rust-lang.org/rust-by-example/generics.html)
- [Rust By Example — Traits](https://doc.rust-lang.org/rust-by-example/trait.html)
- [Rust By Example — Inference](https://doc.rust-lang.org/rust-by-example/types/inference.html)
- [Rust By Example — Casting](https://doc.rust-lang.org/rust-by-example/types/cast.html)
- [Rust By Example — From and Into](https://doc.rust-lang.org/rust-by-example/conversion.html)
- [Rust By Example — Option and unwrap](https://doc.rust-lang.org/rust-by-example/error/option_unwrap.html)
- [Rust std — std::convert](https://doc.rust-lang.org/std/convert/index.html)
- [Rust std — Option](https://doc.rust-lang.org/std/option/index.html)
- [Rust std — Result](https://doc.rust-lang.org/std/result/index.html)
- [Rustonomicon — PhantomData](https://doc.rust-lang.org/nomicon/phantom-data.html)
- [Rustonomicon — Subtyping and Variance](https://doc.rust-lang.org/nomicon/subtyping.html)

**Java**
- [JLS — Primitive Types and Values](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.2)
- [JLS — Types, Values, Variables](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html)
- [JLS — Conversions and Contexts](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html)
- [JLS — Widening Primitive Conversion](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.2)
- [JLS — Narrowing Primitive Conversion](https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.3)
- [JLS — Enum Types](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.9)
- [JLS — Interfaces](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html)
- [JLS — Type Inference](https://docs.oracle.com/javase/specs/jls/se21/html/jls-18.html)
- [JLS — Type Erasure](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.6)
- [JLS — Intersection Types](https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.9)
- [Oracle — Primitive Data Types](https://docs.oracle.com/javase/tutorial/java/nutsandbolts/datatypes.html)
- [Oracle — Autoboxing and Unboxing](https://docs.oracle.com/javase/tutorial/java/data/autoboxing.html)
- [Oracle — Generics](https://docs.oracle.com/javase/tutorial/java/generics/index.html)
- [Oracle — Wildcards](https://docs.oracle.com/javase/tutorial/java/generics/wildcards.html)
- [Oracle — Interfaces](https://docs.oracle.com/javase/tutorial/java/IandI/createinterface.html)
- [Java docs — Optional](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html)
- [Angelika Langer — Java Generics FAQ](http://www.angelikalanger.com/GenericsFAQ/JavaGenericsFAQ.html)
- [JEP 286 — Local-Variable Type Inference](https://openjdk.org/jeps/286)
- [JEP 395 — Records](https://openjdk.org/jeps/395)
- [JEP 409 — Sealed Classes](https://openjdk.org/jeps/409)
- [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)
- [JEP 358 — Helpful NullPointerExceptions](https://openjdk.org/jeps/358)
- [JEP 218 — Generics over Primitive Types (Valhalla)](https://openjdk.org/jeps/218)

**Python**
- [Python docs — Built-in Types](https://docs.python.org/3/library/stdtypes.html)
- [Python docs — Numeric Types](https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex)
- [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)
- [Python docs — Special method names](https://docs.python.org/3/reference/datamodel.html#special-method-names)
- [Python docs — Built-in Functions](https://docs.python.org/3/library/functions.html)
- [Python docs — dataclasses](https://docs.python.org/3/library/dataclasses.html)
- [Python docs — typing.NamedTuple](https://docs.python.org/3/library/typing.html#typing.NamedTuple)
- [Python docs — enum module](https://docs.python.org/3/library/enum.html)
- [Python docs — typing module](https://docs.python.org/3/library/typing.html)
- [Python docs — typing.Protocol](https://docs.python.org/3/library/typing.html#typing.Protocol)
- [Python docs — typing.Optional](https://docs.python.org/3/library/typing.html#typing.Optional)
- [Python docs — typing.TypedDict](https://docs.python.org/3/library/typing.html#typing.TypedDict)
- [Python docs — typing.overload](https://docs.python.org/3/library/typing.html#typing.overload)
- [Python docs — abc module](https://docs.python.org/3/library/abc.html)
- [PEP 484 — Type Hints](https://peps.python.org/pep-0484/)
- [PEP 526 — Syntax for Variable Annotations](https://peps.python.org/pep-0526/)
- [PEP 544 — Protocols: Structural subtyping](https://peps.python.org/pep-0544/)
- [PEP 557 — Data Classes](https://peps.python.org/pep-0557/)
- [PEP 563 — Postponed Evaluation of Annotations](https://peps.python.org/pep-0563/)
- [PEP 612 — Parameter Specification Variables](https://peps.python.org/pep-0612/)
- [PEP 673 — Self Type](https://peps.python.org/pep-0673/)
- [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/)
- [PEP 695 — Type Parameter Syntax](https://peps.python.org/pep-0695/)
- [PEP 3119 — Introducing Abstract Base Classes](https://peps.python.org/pep-3119/)
- [mypy documentation](https://mypy.readthedocs.io/en/stable/)
- [mypy — Optional types and None](https://mypy.readthedocs.io/en/stable/kinds_of_types.html#optional-types-and-the-none-type)
- [pyright documentation](https://microsoft.github.io/pyright/)

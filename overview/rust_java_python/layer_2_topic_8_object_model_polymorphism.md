# Layer 2 · Topic 8 — Object Model & Polymorphism

> Comparative study of Rust, Java, and Python: how each language defines composite types, attaches behavior, and achieves polymorphism — from structs/classes and traits/interfaces/protocols through dynamic dispatch and operator overloading to data classes and pattern matching.

---

## 1. Classes, Structs, Objects: Fundamentals

The most basic question a language must answer: how do you define a new composite type that bundles data together? Rust uses structs with separate `impl` blocks, Java uses classes (and, since Java 16, records), and Python uses classes with a dynamic namespace model. These choices shape everything that follows — how behavior is attached, how encapsulation works, and what "an object" even means.

### Rust: Structs and `impl` Blocks

Rust has three kinds of structs — named-field, tuple-like, and unit — plus enums (covered in Session 9). Structs are **pure data definitions**: they declare fields and nothing else. Behavior is attached separately through `impl` blocks.

```rust
// Named-field struct
struct Point {
    x: f64,
    y: f64,
}

// Tuple struct (often used for newtype pattern)
struct Meters(f64);

// Unit struct (zero-sized, used as marker types)
struct Marker;

// Behavior is attached via impl blocks — separate from the data definition
impl Point {
    // Associated function (no self) — conventionally used as constructor
    fn new(x: f64, y: f64) -> Point {
        Point { x, y }
    }

    // Method — takes &self (immutable borrow of the instance)
    fn distance_from_origin(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }

    // Method — takes &mut self (mutable borrow)
    fn translate(&mut self, dx: f64, dy: f64) {
        self.x += dx;
        self.y += dy;
    }

    // Method — takes self (consumes the instance)
    fn into_tuple(self) -> (f64, f64) {
        (self.x, self.y)
    }
}
```

Key design principles:

- **No constructor keyword.** There is no `new` keyword in the language — `fn new()` is a naming convention for associated functions that return `Self`. You can have multiple constructors with different names (`fn from_polar()`, `fn origin()`).
- **Explicit receiver.** Methods declare `self`, `&self`, or `&mut self` as their first parameter. This makes the ownership/borrowing semantics visible at the call site: `&self` borrows immutably, `&mut self` borrows mutably, `self` consumes the instance (moves it into the method). There is no hidden `this` pointer.
- **Multiple `impl` blocks.** You can have any number of `impl` blocks for the same struct, spread across modules. This is essential for conditional trait implementations (e.g., `impl<T: Display> MyStruct<T>` in one block, `impl<T: Debug> MyStruct<T>` in another).
- **No inheritance.** Structs cannot extend other structs. There is no `struct Child extends Parent`. Code reuse comes from traits, generics, and composition.
- **All fields are private by default.** Fields without `pub` are visible only within the defining module. There are no `protected` or `package-private` access levels — only `pub` (public), `pub(crate)` (crate-visible), `pub(super)` (parent-module-visible), and private (default).
- **No null.** A `Point` always contains valid data. Optional values use `Option<Point>`.

> **Sources:** Klabnik & Nichols (2023) Ch.5 pp. 85–102 · Blandy & Orendorff (2017) Ch.9 pp. 193–209 · McNamara (2021) Ch.3 pp. 77–95 · [Rust Reference — Struct Types](https://doc.rust-lang.org/reference/types/struct.html) · [Rust Reference — Implementations](https://doc.rust-lang.org/reference/items/implementations.html) · [Rust By Example — Structures](https://doc.rust-lang.org/rust-by-example/custom_types/structs.html)

### Java: Classes, Constructors, and Records

Java's class is the fundamental unit of organization — it bundles fields, methods, constructors, and access control into a single declaration. Since Java 16, **records** provide a concise syntax for data-carrying types.

```java
// Traditional class
public class Point {
    private final double x;  // encapsulated, immutable
    private final double y;

    public Point(double x, double y) {
        this.x = x;
        this.y = y;
    }

    public double x() { return x; }
    public double y() { return y; }

    public double distanceFromOrigin() {
        return Math.sqrt(x * x + y * y);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Point p)) return false;
        return Double.compare(p.x, x) == 0 && Double.compare(p.y, y) == 0;
    }

    @Override
    public int hashCode() { return Objects.hash(x, y); }

    @Override
    public String toString() { return "Point[x=%f, y=%f]".formatted(x, y); }
}

// Equivalent record — all of the above in one line
public record Point(double x, double y) {
    // Compact constructor for validation
    public Point {
        if (Double.isNaN(x) || Double.isNaN(y))
            throw new IllegalArgumentException("NaN not allowed");
    }

    public double distanceFromOrigin() {
        return Math.sqrt(x * x + y * y);
    }
}
```

Key design principles:

- **Classes bundle everything.** Data (fields), behavior (methods), initialization (constructors), and access control (`private`/`protected`/`public`/package-private) are declared together in the class body.
- **Implicit `this`.** Instance methods have an implicit `this` reference to the current object. Unlike Rust, the receiver is not an explicit parameter.
- **Records (Java 16+).** `record Point(double x, double y) {}` auto-generates: canonical constructor, component accessor methods (`x()` and `y()`, not `getX()`), `equals()`, `hashCode()`, and `toString()`. Records are `final` (cannot be subclassed), their fields are `final` (immutable), and they cannot extend classes (but can implement interfaces). Records are "transparent carriers for shallowly immutable data" — their API is entirely determined by their components.
- **Four access levels.** `private` (class only), package-private (default, no keyword), `protected` (package + subclasses), `public` (everywhere). This is richer than Rust's module-based visibility.
- **Single inheritance, multiple interface implementation.** Every class extends exactly one class (`Object` by default). A class can implement any number of interfaces.
- **Null is always possible.** Any reference variable can be `null`. There is no `Option` type in the language (though `Optional<T>` exists in the library for return types).

> **Sources:** Horstmann (2024) Ch.4 pp. 55–68 · Bloch (2018) Ch.4 pp. 73–90 · Evans et al (2022) Ch.3 pp. 55–65 · [JLS Ch.8 — Classes](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html) · [JEP 395 — Records](https://openjdk.org/jeps/395) · [Brian Goetz — "Data Classes and Sealed Types for Java"](https://cr.openjdk.org/~briangoetz/amber/datum.html)

### Python: Classes as Dynamic Namespaces

Python classes are fundamentally **dynamic namespace objects**. A class body is a block of code that executes at definition time, producing a dictionary that becomes the class's `__dict__`. Instances are dictionaries too. The entire object model is built on attribute lookup through these dictionaries.

```python
class Point:
    """A 2D point with x and y coordinates."""

    def __init__(self, x: float, y: float) -> None:
        self.x = x  # instance attribute — stored in self.__dict__
        self.y = y

    def distance_from_origin(self) -> float:
        return (self.x ** 2 + self.y ** 2) ** 0.5

    def __repr__(self) -> str:
        return f"Point(x={self.x!r}, y={self.y!r})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Point):
            return NotImplemented
        return self.x == other.x and self.y == other.y

    def __hash__(self) -> int:
        return hash((self.x, self.y))
```

Key design principles:

- **`__init__` is an initializer, not a constructor.** The actual constructor is `__new__`, which creates the instance; `__init__` populates it. For most classes you only define `__init__`.
- **Explicit `self`.** Like Rust, Python methods receive the instance as an explicit first parameter (`self`). Unlike Rust, `self` has no ownership/borrowing semantics — it is always a reference to the object.
- **Special methods (dunder methods).** The Python data model defines dozens of `__dunder__` methods (`__repr__`, `__eq__`, `__hash__`, `__len__`, `__getitem__`, etc.) that integrate objects with built-in functions and operators. Implementing `__repr__` makes `repr(obj)` work; implementing `__eq__` makes `==` work.
- **No access modifiers.** Python has no `private` or `protected` keywords. Encapsulation is by convention: a leading underscore (`_private`) signals "internal," and a double underscore (`__mangled`) triggers name mangling (prepending `_ClassName`). "We're all consenting adults here."
- **Everything is an object.** Classes, functions, modules, and even types are objects with `__dict__`. You can add attributes to an instance at any time: `point.color = "red"` works even if `color` was never declared.
- **Dynamic by default.** Methods can be added, removed, or replaced on classes and instances at runtime. This is what makes monkey-patching possible.

> **Sources:** Ramalho (2022) Ch.1 pp. 3–20 · Martelli et al (2023) Ch.4 pp. 115–135 · Viafore (2021) Ch.10 pp. 135–145 · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html) · [Python docs — `__slots__`](https://docs.python.org/3/reference/datamodel.html#slots)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Primary type** | `struct` (+ `enum`) | `class` (+ `record`) | `class` |
| **Data and behavior** | Separate (`struct` + `impl`) | Combined (class body) | Combined (class body) |
| **Constructor** | Convention (`fn new()`) | Language keyword (`new`) | `__new__` + `__init__` |
| **Receiver** | Explicit (`self`, `&self`, `&mut self`) | Implicit (`this`) | Explicit (`self`) |
| **Access control** | `pub`/private (module-based) | `private`/default/`protected`/`public` | Convention (`_`, `__`) |
| **Inheritance** | None | Single class + multiple interfaces | Multiple |
| **Null/None** | No null; use `Option<T>` | Any reference can be `null` | Any variable can be `None` |
| **Mutability default** | Immutable unless `mut` | Mutable unless `final` | Mutable always |
| **Field declaration** | In struct definition | In class body | In `__init__` (dynamic) |
| **Auto-generated methods** | Via `#[derive]` | Via `record` | Via `@dataclass` |

---

## 2. Methods, Associated Functions, Static vs Instance

How behavior is attached to types differs fundamentally across the three languages — Rust uses `impl` blocks with an explicit receiver parameter, Java has four distinct method invocation types at the bytecode level, and Python's method binding is powered by the descriptor protocol.

### Rust: `impl` Blocks and Explicit Receivers

In Rust, all methods and associated functions live inside `impl` blocks. The distinction between a "method" and an "associated function" is whether the first parameter is a form of `self`:

```rust
struct Circle {
    center: Point,
    radius: f64,
}

impl Circle {
    // Associated function — no self, called as Circle::new(...)
    fn new(center: Point, radius: f64) -> Self {
        Circle { center, radius }
    }

    // Associated function — alternative constructor
    fn unit() -> Self {
        Circle { center: Point::new(0.0, 0.0), radius: 1.0 }
    }

    // Method — &self (immutable borrow)
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }

    // Method — &mut self (mutable borrow)
    fn scale(&mut self, factor: f64) {
        self.radius *= factor;
    }

    // Method — self (takes ownership, consumes the circle)
    fn into_center(self) -> Point {
        self.center
    }
}
```

The receiver type determines the call's ownership semantics:

| Receiver | Meaning | Calling convention |
|----------|---------|-------------------|
| `self` | Takes ownership (move) | `circle.into_center()` — `circle` is consumed |
| `&self` | Immutable borrow | `circle.area()` — `circle` remains usable |
| `&mut self` | Mutable borrow | `circle.scale(2.0)` — exclusive access required |
| `self: Box<Self>` | Takes ownership of a boxed instance | `boxed_circle.into_center()` |
| `self: Rc<Self>` | Shared ownership | `rc_circle.method()` |
| `self: Pin<&mut Self>` | Pinned mutable reference | Used in async / self-referential structs |

There is no method overloading — you cannot have two methods with the same name but different parameter types. Rust uses different names or trait-based generics instead.

Multiple `impl` blocks can exist for the same type:

```rust
impl Circle {
    fn area(&self) -> f64 { /* ... */ }
}

// Conditional implementation — only if T: Display
impl<T: Display> Container<T> {
    fn print_contents(&self) { /* ... */ }
}
```

This separation of data declaration from behavior is what makes traits possible — any `impl` block can implement a trait for a type, and the trait implementation does not need to be in the same file as the type definition (subject to the orphan rule).

> **Sources:** Klabnik & Nichols (2023) Ch.5 pp. 93–102 · Blandy & Orendorff (2017) Ch.9 pp. 196–209 · [Rust Reference — Associated Items](https://doc.rust-lang.org/reference/items/associated-items.html) · [Rust By Example — Methods](https://doc.rust-lang.org/rust-by-example/fn/methods.html)

### Java: Four Kinds of Method Invocation

At the source level, Java has instance methods, static methods, constructors, and (since Java 8) default interface methods. At the bytecode level, these map to four distinct invocation opcodes — understanding these opcodes reveals how polymorphism actually works in the JVM.

```java
public class Shape {
    // Instance method — invokevirtual (virtual dispatch through vtable)
    public double area() { return 0; }

    // Static method — invokestatic (no dispatch, direct call)
    public static Shape unit() { return new Shape(); }

    // Constructor — invokespecial (no virtual dispatch)
    public Shape() { /* ... */ }

    // Private method — invokespecial (no virtual dispatch)
    private void validate() { /* ... */ }
}

public interface Drawable {
    // Abstract method — invokeinterface (dispatch through itable)
    void draw();

    // Default method — invokeinterface
    default String description() { return "A drawable shape"; }

    // Static interface method — invokestatic
    static Drawable empty() { return () -> {}; }
}
```

The four invocation bytecodes:

| Bytecode | Used for | Dispatch mechanism |
|----------|----------|-------------------|
| `invokevirtual` | Instance methods on classes | Vtable lookup — O(1) index into method table |
| `invokeinterface` | Methods on interfaces | Itable search — slightly slower than vtable |
| `invokespecial` | Constructors, `super` calls, private methods | Direct call — no virtual dispatch |
| `invokestatic` | Static methods | Direct call — no dispatch |

There is a fifth opcode, `invokedynamic`, introduced for lambda expressions and method references (Java 8+). It allows the JVM to defer method linking to runtime, enabling the `LambdaMetafactory` to generate lightweight lambda implementations.

Default methods in interfaces (Java 8+) were a practical necessity for evolving the Java Collections Framework without breaking existing code. They allow interfaces to provide method implementations while maintaining backward compatibility. An interface can now contain: abstract methods, default methods, static methods, and private methods (Java 9+).

> **Sources:** Horstmann (2024) Ch.6 pp. 85–92 · Evans et al (2022) Ch.4 pp. 95–117 · Evans et al (2022) Ch.17 pp. 571–590 · [JLS 8.4.3.2 — Static Methods](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.3.2) · [JVM Specification — invokevirtual](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html#jvms-6.5.invokevirtual)

### Python: The Descriptor Protocol

Python has three kinds of methods — regular, class, and static — but they are all implemented through a single mechanism: the **descriptor protocol**. When you access an attribute on an instance, Python does not simply look it up in a dictionary — it invokes `__get__` on the attribute if it is a descriptor.

```python
class Circle:
    def __init__(self, radius: float) -> None:
        self.radius = radius

    # Regular method — function is a descriptor
    def area(self) -> float:
        import math
        return math.pi * self.radius ** 2

    # Class method — receives the class, not the instance
    @classmethod
    def unit(cls) -> "Circle":
        return cls(1.0)  # cls-aware: works correctly in subclasses

    # Static method — receives neither instance nor class
    @staticmethod
    def is_valid_radius(r: float) -> bool:
        return r > 0
```

How the descriptor protocol makes this work:

1. `Circle.area` is a plain function stored in `Circle.__dict__['area']`.
2. When you write `c.area()`, Python calls `type(c).__getattribute__(c, 'area')`.
3. `__getattribute__` finds `area` in `Circle.__dict__`, sees it has a `__get__` method (all functions are descriptors), and calls `area.__get__(c, Circle)`.
4. `function.__get__` returns a **bound method** — a partial application with `c` as the first argument.
5. The bound method is then called with `()`, which executes `area(c)`.

`@classmethod` and `@staticmethod` are **built-in descriptors** that override this binding:

| Decorator | `__get__` behavior | First argument |
|-----------|-------------------|----------------|
| (none) | Returns bound method `f(instance, ...)` | `self` (the instance) |
| `@classmethod` | Returns bound method `f(class, ...)` | `cls` (the class) |
| `@staticmethod` | Returns the raw function | (nothing) |

`@classmethod` is particularly powerful for polymorphic construction. Because it receives `cls` (the actual class, not hardcoded), a `@classmethod` on a base class creates instances of whatever subclass calls it:

```python
class Shape:
    @classmethod
    def from_json(cls, data: dict) -> "Shape":
        return cls(**data)  # creates a Circle if called on Circle

class Circle(Shape):
    def __init__(self, radius: float) -> None:
        self.radius = radius

c = Circle.from_json({"radius": 5.0})  # returns a Circle, not a Shape
```

> **Sources:** Martelli et al (2023) Ch.4 pp. 140–155 · Slatkin (2025) Ch.7 pp. 230–234 (Item 52) · [Python docs — Descriptor HowTo Guide](https://docs.python.org/3/howto/descriptor.html) · [Python docs — classmethod](https://docs.python.org/3/library/functions.html#classmethod) · [Python docs — staticmethod](https://docs.python.org/3/library/functions.html#staticmethod)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **"Static" method** | Associated function (no `self`) | `static` keyword | `@staticmethod` |
| **"Factory" method** | `fn new() -> Self` | Static factory or constructor | `@classmethod` |
| **Instance method** | `fn method(&self)` | `void method()` (implicit `this`) | `def method(self)` |
| **Method overloading** | Not supported | Supported (different param types) | Not supported (last definition wins) |
| **Binding mechanism** | Direct call (no binding) | JVM bytecode opcodes | Descriptor protocol (`__get__`) |
| **Polymorphic constructor** | Trait associated functions | Generics/reflection | `@classmethod` with `cls` |

---

## 3. Inheritance and Composition

The three languages take dramatically different stances on inheritance. Rust **has no inheritance at all** — behavior reuse comes entirely from traits and composition. Java allows **single class inheritance** plus multiple interface implementation, with sealed classes (Java 17+) restricting the hierarchy. Python supports **unrestricted multiple inheritance** with C3 linearization.

### Rust: No Inheritance — Traits and Composition

Rust deliberately chose not to support inheritance between structs. This is not a limitation but a design decision — inheritance creates tight coupling between parent and child, the fragile base class problem, and ambiguity in multiple inheritance scenarios. Rust instead provides three mechanisms for behavior reuse:

**1. Trait default methods** — shared behavior without shared state:

```rust
trait Describable {
    fn name(&self) -> &str;

    // Default implementation — types can override or use as-is
    fn description(&self) -> String {
        format!("I am {}", self.name())
    }
}

struct Dog { name: String }

impl Describable for Dog {
    fn name(&self) -> &str { &self.name }
    // description() uses the default implementation
}
```

**2. Composition** — embedding structs within structs:

```rust
struct Engine { horsepower: u32 }
struct Wheels { count: u8 }

struct Car {
    engine: Engine,    // Car HAS an engine
    wheels: Wheels,    // Car HAS wheels
    brand: String,
}

impl Car {
    fn power(&self) -> u32 { self.engine.horsepower }
}
```

**3. `Deref` coercion** — a limited form of delegation:

```rust
use std::ops::Deref;

struct MyVec(Vec<i32>);

impl Deref for MyVec {
    type Target = Vec<i32>;
    fn deref(&self) -> &Vec<i32> { &self.0 }
}

// Now MyVec transparently delegates to Vec<i32>
let v = MyVec(vec![1, 2, 3]);
println!("{}", v.len()); // calls Vec::len via Deref coercion
```

The Rust community generally advises against using `Deref` for general delegation (it is intended for smart pointer types), but it shows how Rust provides delegation without inheritance.

**Supertraits** provide "inheritance" for trait definitions (not for types):

```rust
trait Animal: Describable {
    // Any type implementing Animal must also implement Describable
    fn speak(&self) -> &str;
}
```

This means `Animal` **requires** `Describable`, but it is a constraint, not inheritance. `Animal` does not inherit state — it inherits a contract.

> **Sources:** Klabnik & Nichols (2023) Ch.17 pp. 375–396 · Gjengset (2022) Ch.3 pp. 37–56 · Blandy & Orendorff (2017) Ch.13 pp. 281–301 (Deref) · [Rust Blog — "Abstraction without overhead: traits in Rust"](https://blog.rust-lang.org/2015/05/11/traits.html) · [Rust By Example — Traits](https://doc.rust-lang.org/rust-by-example/trait.html)

### Java: Single Inheritance, Interfaces, Sealed Hierarchies

Java's inheritance model has evolved significantly over 30 years:

**Single class inheritance** — every class extends exactly one superclass:

```java
public abstract class Shape {
    public abstract double area();

    // Shared implementation for all shapes
    public String describe() {
        return "Shape with area " + area();
    }
}

public class Circle extends Shape {
    private final double radius;

    public Circle(double radius) { this.radius = radius; }

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}
```

**Bloch's Item 18: Favor composition over inheritance.** Inheritance violates encapsulation — a subclass depends on the implementation details of its superclass. The canonical example: `InstrumentedHashSet` extends `HashSet` and overrides `addAll()`, but `HashSet.addAll()` internally calls `add()`, leading to double-counting. The fix: composition with delegation.

```java
// Composition — the forwarding class
public class ForwardingSet<E> implements Set<E> {
    private final Set<E> delegate;
    public ForwardingSet(Set<E> s) { delegate = s; }
    public boolean add(E e) { return delegate.add(e); }
    public boolean addAll(Collection<? extends E> c) { return delegate.addAll(c); }
    // ... forward all Set methods
}

// Decorator wraps any Set implementation
public class InstrumentedSet<E> extends ForwardingSet<E> {
    private int addCount = 0;
    public InstrumentedSet(Set<E> s) { super(s); }
    @Override public boolean add(E e) { addCount++; return super.add(e); }
    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }
}
```

**Sealed classes (Java 17+, JEP 409)** restrict which classes can extend a type:

```java
public sealed interface Shape permits Circle, Rectangle, Triangle {}

public record Circle(double radius) implements Shape {}
public record Rectangle(double width, double height) implements Shape {}
public record Triangle(double a, double b, double c) implements Shape {}
```

Sealed interfaces combined with records enable **algebraic data types** in Java — a closed set of known variants that the compiler can reason about exhaustively (in `switch` expressions).

> **Sources:** Bloch (2018) Ch.4 pp. 90–115 · Horstmann (2024) Ch.5 pp. 70–82 · Evans et al (2022) Ch.3 pp. 60–77 · [JEP 409 — Sealed Classes](https://openjdk.org/jeps/409) · [JLS 8.4.8 — Inheritance, Overriding, and Hiding](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.8)

### Python: Multiple Inheritance, MRO, and Mixins

Python supports unrestricted multiple inheritance. Any class can inherit from any number of base classes:

```python
class Loggable:
    """Mixin: adds logging capability."""
    def log(self, message: str) -> None:
        print(f"[{self.__class__.__name__}] {message}")

class Serializable:
    """Mixin: adds JSON serialization."""
    def to_json(self) -> str:
        import json
        return json.dumps(self.__dict__)

class User(Loggable, Serializable):
    def __init__(self, name: str, email: str) -> None:
        self.name = name
        self.email = email

u = User("Alice", "alice@example.com")
u.log("created")          # from Loggable
print(u.to_json())        # from Serializable
```

The **Method Resolution Order (MRO)** determines the order in which base classes are searched when resolving a method. Python uses the **C3 linearization** algorithm, which respects two constraints:

1. **Monotonicity** — subclasses come before superclasses.
2. **Preservation of local order** — the order of base classes in the `class` statement is maintained.

```python
class A:
    def method(self): return "A"

class B(A):
    def method(self): return "B"

class C(A):
    def method(self): return "C"

class D(B, C):
    pass

print(D.__mro__)
# (D, B, C, A, object)

print(D().method())  # "B" — B comes before C in MRO
```

**`super()` follows the MRO, not the parent class.** This is the most commonly misunderstood aspect of Python's inheritance:

```python
class A:
    def __init__(self):
        print("A.__init__")
        super().__init__()

class B(A):
    def __init__(self):
        print("B.__init__")
        super().__init__()  # Goes to C, not A!

class C(A):
    def __init__(self):
        print("C.__init__")
        super().__init__()

class D(B, C):
    def __init__(self):
        print("D.__init__")
        super().__init__()

D()
# D.__init__
# B.__init__
# C.__init__  <-- super() in B goes to C, not A
# A.__init__
```

**Mixins** are the Python pattern for composition through multiple inheritance — small, focused classes that provide a single piece of reusable functionality. A good mixin:
- Has no `__init__` (or calls `super().__init__()` cooperatively)
- Provides a narrow, well-defined interface
- Does not maintain its own state (or minimally)
- Names itself with the `Mixin` suffix by convention

> **Sources:** Ramalho (2022) Ch.14 pp. 487–518 · Viafore (2021) Ch.12 pp. 171–185 · Slatkin (2025) Ch.7 pp. 235–244 (Items 53–54) · [Python docs — Multiple Inheritance](https://docs.python.org/3/tutorial/classes.html#multiple-inheritance) · [PEP 3135 — New Super](https://peps.python.org/pep-3135/) · [Michele Simionato — "The Python 2.3 MRO"](https://www.python.org/download/releases/2.3/mro/)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Class inheritance** | None | Single | Multiple |
| **Interface/trait inheritance** | Supertraits (constraint, not data) | Multiple interface implementation | Multiple |
| **Composition idiom** | Struct embedding + delegation | Forwarding class (Bloch Item 18) | Mixins |
| **Diamond problem** | Impossible (no inheritance) | Resolved by conflict rules | Resolved by C3 linearization |
| **Restricting subclasses** | Not applicable (no subclassing) | `sealed` keyword (Java 17+) | `__init_subclass__` hooks |
| **Fragile base class** | Not possible | Possible; Bloch Item 19 warns | Possible; Ramalho Ch.14 warns |
| **Philosophy** | Composition always | Composition preferred, inheritance for frameworks | Multiple inheritance common but mixins preferred |

---

## 4. Interfaces, Traits, Protocols: Abstract Polymorphism

This section covers the core abstraction mechanisms: Rust's **traits** (the foundation of the entire type system), Java's **interfaces** (evolved from simple contracts to rich abstractions), and Python's **protocols** and **ABCs** (bridging duck typing with static analysis).

### Rust: Traits as the Universal Abstraction

Traits are Rust's only mechanism for polymorphism. Unlike Java interfaces or Python ABCs, traits are used for *everything* — operator overloading, conversion, iteration, memory management, thread safety, formatting.

```rust
// Defining a trait
trait Shape {
    // Required method — implementors must provide
    fn area(&self) -> f64;

    // Default method — implementors can override or use as-is
    fn describe(&self) -> String {
        format!("Shape with area {:.2}", self.area())
    }
}

// Implementing a trait for a type
struct Circle { radius: f64 }

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
    // describe() uses the default
}

// Trait bounds — generic function constrained by trait
fn print_area(shape: &impl Shape) {
    println!("{}", shape.describe());
}

// Equivalent using where clause (preferred for complex bounds)
fn compare_areas<S1, S2>(a: &S1, b: &S2) -> std::cmp::Ordering
where
    S1: Shape,
    S2: Shape,
{
    a.area().partial_cmp(&b.area()).unwrap()
}
```

**Associated types** allow a trait to define placeholder types:

```rust
trait Iterator {
    type Item;  // Each implementor decides what Item is
    fn next(&mut self) -> Option<Self::Item>;
}
```

**Supertraits** express trait dependencies:

```rust
trait Display: fmt::Debug {
    // Implementing Display requires also implementing Debug
}
```

**Conditional implementations** (blanket impls):

```rust
// Implement ToString for anything that implements Display
impl<T: Display> ToString for T {
    fn to_string(&self) -> String {
        format!("{}", self)
    }
}
```

**Key traits in the standard library:**

| Trait | Purpose | Methods |
|-------|---------|---------|
| `Debug` | Developer-facing formatting | `fmt(&self, f: &mut Formatter)` |
| `Display` | User-facing formatting | `fmt(&self, f: &mut Formatter)` |
| `Clone` | Explicit duplication | `clone(&self) -> Self` |
| `Copy` | Implicit bitwise copy | Marker trait (no methods) |
| `PartialEq`/`Eq` | Equality comparison | `eq(&self, other: &Self) -> bool` |
| `PartialOrd`/`Ord` | Ordering | `partial_cmp`, `cmp` |
| `Hash` | Hashing | `hash(&self, state: &mut H)` |
| `Default` | Default value | `default() -> Self` |
| `From`/`Into` | Type conversion | `from(T) -> Self` |
| `Drop` | Destructor | `drop(&mut self)` |
| `Iterator` | Iteration | `next(&mut self) -> Option<Item>` |
| `Send` | Safe to transfer between threads | Marker trait |
| `Sync` | Safe to share reference between threads | Marker trait |

> **Sources:** Blandy & Orendorff (2017) Ch.11 pp. 235–263 · Klabnik & Nichols (2023) Ch.10 pp. 200–213 · Gjengset (2022) Ch.2 pp. 19–35 · Gjengset (2022) Ch.3 pp. 37–56 · [Rust Reference — Traits](https://doc.rust-lang.org/reference/items/traits.html) · [Rust Reference — Trait Objects](https://doc.rust-lang.org/reference/types/trait-object.html)

### Java: Interfaces, Abstract Classes, Default Methods

Java interfaces have evolved through four major phases:

| Java version | Interface capabilities |
|-------------|----------------------|
| 1.0–7 | Abstract methods only |
| 8 | + Default methods, static methods |
| 9 | + Private methods |
| 17 | + Sealed interfaces |

```java
// Modern interface with all capabilities
public sealed interface Shape permits Circle, Rectangle {

    // Abstract method — must be implemented
    double area();

    // Default method — provides implementation, can be overridden
    default String describe() {
        return "Shape with area " + area();
    }

    // Static method — utility on the interface
    static Shape larger(Shape a, Shape b) {
        return a.area() >= b.area() ? a : b;
    }

    // Private method — shared implementation for defaults
    private double normalized() {
        return area() / Math.PI;
    }
}
```

**Abstract classes vs interfaces:**

| Aspect | Abstract class | Interface |
|--------|---------------|-----------|
| State (fields) | Yes | No (only constants) |
| Constructors | Yes | No |
| Access modifiers | All four | `public` (and `private` since Java 9) |
| Inheritance | Single | Multiple |
| Default methods | Inherited methods | `default` keyword |
| Use case | Partial implementation + state | Contract + optional defaults |

**The skeletal implementation pattern** (Bloch Item 20): combine an interface with an abstract class.

```java
public interface Collection<E> {
    int size();
    Iterator<E> iterator();
    // ... many more methods
}

// Skeletal implementation — provides defaults based on size() and iterator()
public abstract class AbstractCollection<E> implements Collection<E> {
    @Override
    public boolean isEmpty() { return size() == 0; }
    @Override
    public boolean contains(Object o) {
        for (E e : this) if (Objects.equals(e, o)) return true;
        return false;
    }
    // Implementors only need to define size() and iterator()
}
```

> **Sources:** Horstmann (2024) Ch.5 pp. 74–82 · Horstmann (2024) Ch.6 pp. 85–92 · Bloch (2018) Ch.4 pp. 100–115 · Evans et al (2022) Ch.3 pp. 60–77 · [JLS Ch.9 — Interfaces](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html)

### Python: Duck Typing, ABCs, and `typing.Protocol`

Python has three layers of polymorphism, representing the language's evolution from fully dynamic to optionally static:

**Layer 1: Duck typing** — no declaration needed.

```python
# This function works with ANY object that has a .read() method
def read_all(source) -> str:
    return source.read()

# Works with files, StringIO, BytesIO, custom objects...
import io
read_all(io.StringIO("hello"))  # works
read_all(open("file.txt"))      # works
```

**Layer 2: Abstract Base Classes (ABCs)** — explicit contracts with enforcement.

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        """Must be implemented by subclasses."""
        ...

    def describe(self) -> str:
        return f"Shape with area {self.area():.2f}"

class Circle(Shape):
    def __init__(self, radius: float) -> None:
        self.radius = radius

    def area(self) -> float:
        import math
        return math.pi * self.radius ** 2

# Shape() would raise TypeError: Can't instantiate abstract class
```

ABCs also support **virtual subclasses** — retroactive conformance without inheritance:

```python
from collections.abc import Sized

class MyContainer:
    def __len__(self): return 42

# MyContainer doesn't inherit from Sized, but...
print(isinstance(MyContainer(), Sized))  # True!
# Because Sized checks for __len__ via __subclasshook__
```

**Layer 3: `typing.Protocol` (PEP 544)** — structural subtyping for static analysis.

```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Drawable(Protocol):
    def draw(self) -> None: ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Square:
    def draw(self) -> None:
        print("Drawing square")

# Both satisfy Drawable without inheriting from it
def render(shape: Drawable) -> None:
    shape.draw()

render(Circle())  # OK — Circle has .draw()
render(Square())  # OK — Square has .draw()

# With @runtime_checkable:
isinstance(Circle(), Drawable)  # True
```

`typing.Protocol` bridges duck typing with static type checking — it formalizes the "shape" that duck typing relies on, letting tools like `mypy` verify conformance at type-check time while remaining invisible at runtime (unless decorated with `@runtime_checkable`).

**`functools.singledispatch`** — function-based dispatch without class hierarchies:

```python
from functools import singledispatch

@singledispatch
def process(data):
    raise TypeError(f"Unsupported type: {type(data)}")

@process.register(str)
def _(data: str):
    return data.upper()

@process.register(list)
def _(data: list):
    return [process(item) for item in data]
```

> **Sources:** Ramalho (2022) Ch.13 pp. 431–486 · Viafore (2021) Ch.13 pp. 187–197 · Slatkin (2025) Ch.7 pp. 205–216 (Items 49–50) · [PEP 544 — Protocols: Structural subtyping](https://peps.python.org/pep-0544/) · [PEP 3119 — Introducing Abstract Base Classes](https://peps.python.org/pep-3119/) · [Python docs — abc module](https://docs.python.org/3/library/abc.html)

### Comparison Matrix

| Aspect | Rust traits | Java interfaces | Python Protocol/ABC |
|--------|------------|----------------|-------------------|
| **Typing model** | Bounded parametric | Nominal subtype | Structural (Protocol) / Nominal (ABC) |
| **Declaration** | `trait T { ... }` | `interface T { ... }` | `class T(Protocol): ...` or `class T(ABC): ...` |
| **Implementation** | `impl T for S { ... }` | `class S implements T` | Automatic (Protocol) or `class S(T)` (ABC) |
| **Retroactive impl** | Yes (orphan rule applies) | No (must modify class) | Yes (Protocol is structural; ABC has `register()`) |
| **Default methods** | Yes | Yes (since Java 8) | Yes (both Protocol and ABC) |
| **Associated types** | Yes (`type Item`) | No (use generics) | No |
| **Multiple** | Unlimited | Unlimited | Unlimited |
| **State** | No | No (constants only) | Yes (classes can have state) |
| **Enforcement** | Compile time | Compile time | Type checker (Protocol) or runtime (ABC) |

---

## 5. Dynamic Dispatch: Vtables, Trait Objects, Virtual Methods

When the concrete type is not known at compile time, the language must resolve method calls at runtime. Each language uses a fundamentally different mechanism: Rust uses **fat pointers with vtables** (`dyn Trait`), Java uses **class vtables and interface tables**, and Python uses **`__dict__` lookup through the MRO**.

### Rust: Trait Objects and Fat Pointers

Rust provides two forms of dispatch, and the programmer **explicitly chooses** between them:

**Static dispatch (monomorphization)** — the compiler generates a specialized copy of the function for each concrete type:

```rust
// Static dispatch: compiler generates print_area_Circle, print_area_Rectangle, etc.
fn print_area(shape: &impl Shape) {
    println!("{}", shape.area());
}
```

**Dynamic dispatch (`dyn Trait`)** — a runtime vtable lookup:

```rust
// Dynamic dispatch: one function body, vtable-based resolution
fn print_area(shape: &dyn Shape) {
    println!("{}", shape.area());
}
```

A `dyn Trait` reference is a **fat pointer** (also called a "wide pointer") — 16 bytes on 64-bit systems:

```
&dyn Shape = [data_ptr: *const (), vtable_ptr: *const ShapeVtable]

ShapeVtable {
    drop_in_place: fn(*mut ()),    // destructor
    size: usize,                    // size of the concrete type
    align: usize,                   // alignment of the concrete type
    area: fn(*const ()) -> f64,    // Shape::area
    describe: fn(*const ()) -> String, // Shape::describe
}
```

Each concrete type gets its own vtable instance (generated at compile time). When you call `shape.area()`, the compiler emits code equivalent to `(shape.vtable.area)(shape.data_ptr)`.

**Object safety rules** restrict which traits can be used as `dyn Trait`:

- No methods with `Self` in return position (the vtable cannot represent the return type).
- No generic methods (each generic instantiation would need its own vtable entry).
- No associated functions without a receiver (`self`, `&self`, `&mut self`).
- The trait must not require `Sized`.

```rust
// Object-safe trait
trait Drawable {
    fn draw(&self);
}

// NOT object-safe — returns Self
trait Cloneable {
    fn clone(&self) -> Self;
}

// NOT object-safe — generic method
trait Processor {
    fn process<T>(&self, input: T);
}
```

Common patterns with `dyn Trait`:

```rust
// Heterogeneous collection
let shapes: Vec<Box<dyn Shape>> = vec![
    Box::new(Circle { radius: 1.0 }),
    Box::new(Rectangle { width: 2.0, height: 3.0 }),
];

// Trait object as return type
fn make_shape(kind: &str) -> Box<dyn Shape> {
    match kind {
        "circle" => Box::new(Circle { radius: 1.0 }),
        "rect" => Box::new(Rectangle { width: 2.0, height: 3.0 }),
        _ => panic!("unknown shape"),
    }
}
```

> **Sources:** Klabnik & Nichols (2023) Ch.17 pp. 375–396 · Gjengset (2022) Ch.2 pp. 25–35 · Blandy & Orendorff (2017) Ch.11 pp. 235–263 · [Rustonomicon — Dynamically Sized Types](https://doc.rust-lang.org/nomicon/exotic-sizes.html) · [Rust Reference — Object Safety](https://doc.rust-lang.org/reference/items/traits.html#object-safety) · [Rustc Dev Guide — Monomorphization](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html)

### Java: Vtables, Itables, and JIT Devirtualization

In Java, all non-private, non-static, non-final instance methods are **virtual by default** — the programmer does not choose; the JVM handles dispatch automatically.

**Class vtables:** each class has a method table (vtable) — an array of method pointers. Subclass vtables extend the parent's: overridden methods replace the corresponding entry, new methods append to the end.

```
Object vtable:      [hashCode, equals, toString, ...]
Shape vtable:       [hashCode, equals, toString, ..., area, describe]
Circle vtable:      [hashCode, equals, toString, ..., area*, describe]
                                                        ^-- overridden
```

`invokevirtual` resolves a method in O(1) — the bytecode specifies an index into the vtable.

**Interface tables (itables):** interfaces cannot use fixed vtable indices because a class can implement interfaces in any order. The JVM maintains an itable (interface method table) per interface per class. `invokeinterface` must search the itable, making it slightly slower than `invokevirtual`.

**JIT devirtualization:** HotSpot's JIT compiler aggressively optimizes virtual calls:

| Call site profile | JIT optimization | Cost |
|-------------------|-----------------|------|
| **Monomorphic** (1 type seen) | Inline the method directly | Zero — same as static call |
| **Bimorphic** (2 types seen) | Type check + branch to inlined code | One comparison |
| **Megamorphic** (3+ types) | Full vtable lookup | One pointer indirection |

In practice, most call sites are monomorphic — the JIT eliminates virtual dispatch for the common case, making Java's "everything is virtual" design nearly free.

```java
// The JIT sees that shape is always a Circle at this call site
Shape shape = new Circle(5.0);
double a = shape.area();  // JIT inlines Circle.area() directly
```

> **Sources:** Evans et al (2022) Ch.4 pp. 95–117 · Evans et al (2022) Ch.17 pp. 571–590 · [JVM Specification — invokevirtual](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html#jvms-6.5.invokevirtual) · [Aleksey Shipilev — JVM Anatomy Quark #16: Megamorphic Virtual Calls](https://shipilev.net/jvm/anatomy-quarks/16-megamorphic-virtual-calls/) · [Oracle — HotSpot VM Performance Enhancements](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)

### Python: `__dict__` Lookup and MRO-Based Dispatch

Python's method dispatch is a **dictionary lookup chain** through the MRO. There is no vtable — every method call involves searching class dictionaries.

When you call `obj.method()`, Python executes `type(obj).__getattribute__(obj, 'method')`, which follows this search order:

1. **Data descriptors** in `type(obj).__mro__` — objects with both `__get__` and `__set__` (e.g., `property`).
2. **Instance dictionary** — `obj.__dict__`.
3. **Non-data descriptors** in `type(obj).__mro__` — objects with only `__get__` (e.g., regular functions).

```python
class A:
    def method(self):
        return "A"

class B(A):
    pass  # inherits method from A

b = B()
b.method()
# 1. Check B.__dict__ for 'method' — not found
# 2. Check A.__dict__ for 'method' — found! It's a function (non-data descriptor)
# 3. Call A.__dict__['method'].__get__(b, B) → bound method
# 4. Call the bound method → "A"
```

**CPython optimizations:**

- **Type attribute cache** — CPython caches method lookups per type. The cache is version-tagged: each class has a `tp_version_tag` that is incremented when the class is modified. Cache hits are O(1).
- **Per-opcode specialization (PEP 659, Python 3.11+)** — the adaptive interpreter rewrites bytecode to specialize method calls based on observed types (`LOAD_ATTR_METHOD` → specialized for bound methods).
- **`__slots__`** — replacing `__dict__` with fixed slots avoids dictionary overhead and enables faster attribute access:

```python
class Point:
    __slots__ = ('x', 'y')

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y
# Point instances have no __dict__ — attributes are stored in fixed slots
```

Despite these optimizations, Python's dispatch remains fundamentally slower than vtable-based dispatch — but it offers unmatched flexibility: methods can be added, replaced, or deleted at runtime on any class or instance.

> **Sources:** Martelli et al (2023) Ch.4 pp. 145–169 · [Python docs — Customizing attribute access](https://docs.python.org/3/reference/datamodel.html#customizing-attribute-access) · [Python docs — Descriptor HowTo Guide](https://docs.python.org/3/howto/descriptor.html)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Static dispatch** | `impl Trait` / generics (monomorphized) | `final`/`private`/`static` methods; JIT devirtualization | Not applicable (all dispatch is dynamic) |
| **Dynamic dispatch** | `dyn Trait` (explicit, fat pointer) | Virtual by default (`invokevirtual`) | Always dynamic (`__dict__` lookup) |
| **Dispatch data structure** | Vtable (per-type, compile-time) | Vtable + itable (per-class, runtime) | `__dict__` chain (per-class, runtime) |
| **Dispatch cost** | One indirection (fat pointer) | One indirection (vtable index) | Dict lookup through MRO (cached) |
| **Programmer choice** | Yes — `impl` vs `dyn` | Limited — `final` prevents override | No — always dynamic |
| **JIT optimization** | N/A (compiled ahead of time) | Monomorphic → inline, bimorphic → branch, megamorphic → vtable | Type attribute cache, PEP 659 specialization |
| **Can modify dispatch at runtime** | No | No (without bytecode manipulation) | Yes — monkey-patching, `setattr`, etc. |

---

## 6. Method Resolution Order and Coherence Rules

When multiple implementations of a method could apply, how does the language resolve the ambiguity? Rust uses **coherence rules** to prevent ambiguity entirely at compile time. Java uses a **class-wins rule** plus mandatory conflict resolution for interface defaults. Python uses the **C3 linearization** algorithm to produce a deterministic MRO.

### Rust: Coherence and the Orphan Rule

Rust's coherence rules guarantee that for any type + trait combination, there is **at most one implementation** anywhere in the entire program. This is enforced at compile time — there is no runtime ambiguity to resolve.

**The orphan rule:** You can implement a trait for a type only if your crate defines either the trait or the type:

```rust
// In your crate:
struct MyType;
trait MyTrait {}

// OK: your crate defines MyType
impl Display for MyType { /* ... */ }

// OK: your crate defines MyTrait
impl MyTrait for Vec<i32> { /* ... */ }

// ERROR: neither Display nor Vec<i32> belongs to your crate
// impl Display for Vec<i32> { /* ... */ }
```

**Nuances and exceptions:**

- **`#[fundamental]` types** like `&T` and `Box<T>` are treated as if they were the inner type `T` for coherence purposes. You can implement a foreign trait for `&MyType` because `MyType` is yours.
- **Uncovered type parameters** — `impl<T> ForeignTrait for ForeignType<T>` is allowed only if `T` is constrained to include a local type.
- **Blanket implementations** — `impl<T: Display> ToString for T` applies to all types satisfying the bound. Once a blanket impl exists, no one can provide a more specific implementation that conflicts.

**RFC 2451 (Re-rebalancing coherence)** relaxed some rules to allow more useful implementations while maintaining soundness:

```rust
// Before RFC 2451: illegal (ForeignTrait for ForeignType<LocalType>)
// After RFC 2451: allowed because LocalType is "covered"
impl ForeignTrait for ForeignType<LocalType> { /* ... */ }
```

The **newtype pattern** works around the orphan rule:

```rust
// Can't impl Display for Vec<String> directly
// Wrap it in a newtype:
struct Wrapper(Vec<String>);

impl Display for Wrapper {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "[{}]", self.0.join(", "))
    }
}
```

**Fully qualified syntax** resolves ambiguity when a type implements multiple traits with methods of the same name:

```rust
trait Pilot { fn fly(&self); }
trait Wizard { fn fly(&self); }

struct Human;
impl Pilot for Human { fn fly(&self) { println!("Captain speaking"); } }
impl Wizard for Human { fn fly(&self) { println!("Expecto patronum"); } }
impl Human { fn fly(&self) { println!("Waving arms"); } }

let h = Human;
h.fly();             // "Waving arms" — inherent method wins
Pilot::fly(&h);      // "Captain speaking"
Wizard::fly(&h);     // "Expecto patronum"
```

> **Sources:** Gjengset (2022) Ch.2 pp. 30–35 · Gjengset (2022) Ch.3 pp. 40–50 · [Rust Reference — Trait Implementations](https://doc.rust-lang.org/reference/items/implementations.html#trait-implementations) · [Rust RFC 2451 — Re-rebalancing coherence](https://rust-lang.github.io/rfcs/2451-re-rebalancing-coherence.html) · [Rust RFC 1023 — Rebalancing coherence](https://rust-lang.github.io/rfcs/1023-rebalancing-coherence.html)

### Java: Class Wins, Then Most Specific Interface

Java's method resolution uses simple, deterministic rules:

**Rule 1: Classes always win over interfaces.** If a class inherits a method from both a superclass and an interface default, the class method takes precedence.

```java
public interface Greeter {
    default String greet() { return "Hello from interface"; }
}

public class Base {
    public String greet() { return "Hello from class"; }
}

public class MyClass extends Base implements Greeter {
    // greet() resolves to Base.greet() — class wins
}
```

**Rule 2: More specific interface wins.** If two interfaces provide the same default method and one extends the other, the more specific (child) interface wins.

```java
public interface A {
    default String hello() { return "A"; }
}

public interface B extends A {
    default String hello() { return "B"; }
}

public class C implements A, B {
    // hello() resolves to B.hello() — B is more specific
}
```

**Rule 3: If ambiguous, you must resolve manually.** If two unrelated interfaces provide the same default method, the compiler reports an error and you must override:

```java
public interface Flyable {
    default String fly() { return "Flying"; }
}

public interface Swimmable {
    default String fly() { return "Swimming"; }
}

public class Duck implements Flyable, Swimmable {
    // COMPILE ERROR without this override:
    @Override
    public String fly() {
        return Flyable.super.fly();  // explicit delegation
    }
}
```

Java's resolution is simpler than Python's C3 linearization because **single class inheritance** means the class hierarchy is a simple chain — there is never more than one path to any superclass. Ambiguity only arises from interface default methods, and the rules above handle it.

> **Sources:** Horstmann (2024) Ch.5 pp. 74–82 · [JLS 15.12 — Method Invocation Expressions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.12) · [JLS 9.4 — Interface Multiple Inheritance](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.4)

### Python: C3 Linearization

Python uses the **C3 linearization** algorithm to compute the MRO for any class. The algorithm guarantees a consistent, predictable order that respects:

1. **Local precedence order** — the order of bases in the class definition.
2. **Monotonicity** — if `B` comes before `C` in the MRO of `D`, then `B` comes before `C` in the MRO of any subclass of `D`.

The algorithm works by repeatedly selecting the first class from the merge of all base MROs that does not appear in the tail of any other base MRO:

```python
class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass

# C3 computation:
# L(D) = D + merge(L(B), L(C), [B, C])
# L(B) = [B, A, object]
# L(C) = [C, A, object]
# merge([B, A, object], [C, A, object], [B, C])
#   → B (head of first, not in tail of any) → merge([A, object], [C, A, object], [C])
#   → C (A is in tail of second) → merge([A, object], [A, object])
#   → A → merge([object], [object])
#   → object
# L(D) = [D, B, C, A, object]

print(D.__mro__)  # (D, B, C, A, object)
```

**If C3 fails** (no consistent ordering exists), Python raises `TypeError` at class creation time:

```python
class X(A, B): pass
class Y(B, A): pass
# class Z(X, Y): pass  → TypeError: Cannot create a consistent MRO
```

**Cooperative `super()` and the MRO:** `super()` does not call "the parent class." It calls "the next class in the MRO." This is essential for cooperative multiple inheritance:

```python
class Base:
    def __init__(self, **kwargs):
        # Absorb any remaining kwargs — the "stop" class
        pass

class Named(Base):
    def __init__(self, name: str, **kwargs):
        super().__init__(**kwargs)  # Pass remaining kwargs up the MRO
        self.name = name

class Aged(Base):
    def __init__(self, age: int, **kwargs):
        super().__init__(**kwargs)
        self.age = age

class Person(Named, Aged):
    pass

p = Person(name="Alice", age=30)
# MRO: Person → Named → Aged → Base → object
# Person.__init__ calls Named.__init__(name="Alice", age=30)
# Named.__init__ calls Aged.__init__(age=30)  # super() goes to Aged, not Base!
# Aged.__init__ calls Base.__init__()
```

> **Sources:** Ramalho (2022) Ch.14 pp. 497–518 · Slatkin (2025) Ch.7 pp. 235–239 (Item 53) · [Michele Simionato — "The Python 2.3 MRO"](https://www.python.org/download/releases/2.3/mro/) · [Python docs — Method Resolution Order](https://docs.python.org/3/glossary.html#term-method-resolution-order) · [Python docs — super()](https://docs.python.org/3/library/functions.html#super)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Ambiguity strategy** | Prevent at compile time (coherence) | Rules + mandatory override | Algorithm (C3 linearization) |
| **Diamond problem** | Impossible (no inheritance) | Resolved by rules 1–3 | Resolved by C3 |
| **Can conflict at compile time?** | No (orphan rule prevents it) | Yes (unrelated interface defaults) | Yes (inconsistent MRO) |
| **Resolution syntax** | Fully qualified: `Trait::method(&x)` | `Interface.super.method()` | `super()` (follows MRO) |
| **Global uniqueness** | Yes (one impl per trait+type) | No (overriding is per-class) | No (MRO is per-class) |

---

## 7. Operator Overloading

Rust makes operators traits, Python makes operators dunder methods, and Java deliberately chose not to support operator overloading at all (with one exception). These decisions reflect deep philosophical differences about expressiveness vs. readability.

### Rust: Operators as Traits in `std::ops`

In Rust, every operator is a trait. `a + b` is syntactic sugar for `Add::add(a, b)`. This means operator overloading follows exactly the same rules as trait implementation — including the orphan rule, type inference, and generics.

```rust
use std::ops::{Add, Mul, Neg};

#[derive(Debug, Clone, Copy, PartialEq)]
struct Vec2 {
    x: f64,
    y: f64,
}

impl Add for Vec2 {
    type Output = Vec2;  // The return type of +
    fn add(self, rhs: Vec2) -> Vec2 {
        Vec2 { x: self.x + rhs.x, y: self.y + rhs.y }
    }
}

// Scalar multiplication — different RHS type
impl Mul<f64> for Vec2 {
    type Output = Vec2;
    fn mul(self, scalar: f64) -> Vec2 {
        Vec2 { x: self.x * scalar, y: self.y * scalar }
    }
}

// Unary negation
impl Neg for Vec2 {
    type Output = Vec2;
    fn neg(self) -> Vec2 {
        Vec2 { x: -self.x, y: -self.y }
    }
}

// Operators on references — avoid consuming the value
impl Add for &Vec2 {
    type Output = Vec2;
    fn add(self, rhs: &Vec2) -> Vec2 {
        Vec2 { x: self.x + rhs.x, y: self.y + rhs.y }
    }
}
```

**Key operator traits:**

| Operator | Trait | Method | Notes |
|----------|-------|--------|-------|
| `a + b` | `Add<Rhs>` | `add(self, rhs: Rhs) -> Output` | `Output` is an associated type |
| `a - b` | `Sub<Rhs>` | `sub` | |
| `a * b` | `Mul<Rhs>` | `mul` | |
| `a / b` | `Div<Rhs>` | `div` | |
| `a % b` | `Rem<Rhs>` | `rem` | |
| `-a` | `Neg` | `neg(self) -> Output` | Unary |
| `!a` | `Not` | `not(self) -> Output` | Bitwise/logical NOT |
| `a[i]` | `Index<Idx>` | `index(&self, idx: Idx) -> &Output` | Returns reference |
| `a[i] = v` | `IndexMut<Idx>` | `index_mut(&mut self, idx: Idx) -> &mut Output` | |
| `a += b` | `AddAssign<Rhs>` | `add_assign(&mut self, rhs: Rhs)` | In-place |
| `a == b` | `PartialEq<Rhs>` | `eq(&self, other: &Rhs) -> bool` | Derivable |
| `a < b` | `PartialOrd<Rhs>` | `partial_cmp` → `Option<Ordering>` | |

**`PartialEq` vs `Eq`, `PartialOrd` vs `Ord`:**

- `PartialEq` — reflexive, symmetric, transitive (but `NaN != NaN`, so `f64: PartialEq` but not `Eq`).
- `Eq` — `PartialEq` + reflexive for all values.
- `PartialOrd` — may return `None` for incomparable values (`NaN`).
- `Ord` — total ordering, always returns `Ordering`.

Most comparison traits can be `#[derive]`d — the compiler generates lexicographic comparison over fields in declaration order.

> **Sources:** Blandy & Orendorff (2017) Ch.12 pp. 265–280 · Klabnik & Nichols (2023) Ch.19 pp. 430–440 · [Rust std — std::ops](https://doc.rust-lang.org/std/ops/index.html) · [Rust std — std::cmp](https://doc.rust-lang.org/std/cmp/index.html) · [Rust By Example — Operator Overloading](https://doc.rust-lang.org/rust-by-example/trait/ops.html)

### Java: No Operator Overloading (Mostly)

Java deliberately chose not to support operator overloading. The only "overloaded" operator is `+` for String concatenation — handled by the compiler, not by user code.

Instead, Java relies on **named methods** for all operations:

```java
// Equality — must use .equals(), not ==
String a = new String("hello");
String b = new String("hello");
a == b;      // false — reference identity
a.equals(b); // true — value equality

// Comparison — use compareTo() or Comparator
record Point(double x, double y) implements Comparable<Point> {
    @Override
    public int compareTo(Point other) {
        int cmp = Double.compare(this.x, other.x);
        return cmp != 0 ? cmp : Double.compare(this.y, other.y);
    }
}

// Arithmetic — named methods
public record Vec2(double x, double y) {
    public Vec2 add(Vec2 other) {
        return new Vec2(x + other.x, y + other.y);
    }
    public Vec2 scale(double factor) {
        return new Vec2(x * factor, y * factor);
    }
}
```

**The `equals`/`hashCode` contract** is one of Java's most error-prone areas:

1. `equals` must be reflexive, symmetric, transitive, and consistent.
2. **If `a.equals(b)`, then `a.hashCode() == b.hashCode()`** — violating this breaks `HashMap`, `HashSet`, etc.
3. `equals` should compare using `instanceof` (supports subclass equality) or `getClass()` (strict type match). Bloch recommends the `instanceof` approach with `@Override`.

Common mistakes (documented by Valeev):
- Comparing with `==` instead of `equals()` for objects.
- Forgetting to override `hashCode()` when overriding `equals()`.
- Using mutable fields in `equals()`/`hashCode()` — the object can "move" in a `HashSet`.

Records eliminate these issues by auto-generating correct `equals()` and `hashCode()` implementations.

> **Sources:** Bloch (2018) Ch.3 pp. 37–71 · Valeev (2024) Ch.7 pp. 177–212 · [JLS 15.18.1 — String Concatenation Operator](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.18.1)

### Python: Dunder Methods for Everything

Python's operator overloading is one of its most distinctive features — operators are **dunder methods** (double-underscore special methods), and any class can implement them:

```python
from __future__ import annotations
from functools import total_ordering

@total_ordering
class Vec2:
    __slots__ = ('x', 'y')

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y

    def __add__(self, other: Vec2) -> Vec2:
        if not isinstance(other, Vec2):
            return NotImplemented
        return Vec2(self.x + other.x, self.y + other.y)

    def __radd__(self, other: Vec2) -> Vec2:
        return self.__add__(other)

    def __mul__(self, scalar: float) -> Vec2:
        if not isinstance(scalar, (int, float)):
            return NotImplemented
        return Vec2(self.x * scalar, self.y * scalar)

    def __rmul__(self, scalar: float) -> Vec2:
        return self.__mul__(scalar)

    def __neg__(self) -> Vec2:
        return Vec2(-self.x, -self.y)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Vec2):
            return NotImplemented
        return self.x == other.x and self.y == other.y

    def __lt__(self, other: Vec2) -> bool:
        if not isinstance(other, Vec2):
            return NotImplemented
        return (self.x, self.y) < (other.x, other.y)

    def __repr__(self) -> str:
        return f"Vec2({self.x}, {self.y})"

    def __hash__(self) -> int:
        return hash((self.x, self.y))
```

**Reflected operators:** When `a + b` is called and `a.__add__(b)` returns `NotImplemented`, Python tries `b.__radd__(a)`. This enables mixed-type operations:

```python
v = Vec2(1, 2)
result = 3.0 * v  # float.__mul__(3.0, v) → NotImplemented → v.__rmul__(3.0)
```

**Augmented assignment:** `a += b` calls `a.__iadd__(b)` if defined; otherwise falls back to `a = a.__add__(b)`. For mutable types, `__iadd__` should modify in place and return `self`:

```python
def __iadd__(self, other: Vec2) -> Vec2:
    self.x += other.x
    self.y += other.y
    return self  # Must return self for a += b assignment
```

**`@functools.total_ordering`** generates all six comparison methods from `__eq__` and one ordering method (`__lt__`, `__le__`, `__gt__`, or `__ge__`).

**Key operator dunder methods:**

| Operator | Method | Reflected | Augmented |
|----------|--------|-----------|-----------|
| `a + b` | `__add__` | `__radd__` | `__iadd__` |
| `a - b` | `__sub__` | `__rsub__` | `__isub__` |
| `a * b` | `__mul__` | `__rmul__` | `__imul__` |
| `a / b` | `__truediv__` | `__rtruediv__` | `__itruediv__` |
| `a // b` | `__floordiv__` | `__rfloordiv__` | `__ifloordiv__` |
| `a % b` | `__mod__` | `__rmod__` | `__imod__` |
| `a ** b` | `__pow__` | `__rpow__` | `__ipow__` |
| `-a` | `__neg__` | — | — |
| `a == b` | `__eq__` | — | — |
| `a < b` | `__lt__` | — | — |
| `a[i]` | `__getitem__` | — | — |
| `a[i] = v` | `__setitem__` | — | — |
| `len(a)` | `__len__` | — | — |
| `a in b` | `__contains__` | — | — |

> **Sources:** Ramalho (2022) Ch.16 pp. 561–590 · Ramalho (2022) Ch.12 pp. 397–430 · [Python docs — Emulating numeric types](https://docs.python.org/3/reference/datamodel.html#emulating-numeric-types) · [Python docs — Rich comparison methods](https://docs.python.org/3/reference/datamodel.html#object.__lt__) · [PEP 207 — Rich Comparisons](https://peps.python.org/pep-0207/)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Mechanism** | Traits in `std::ops` | Not supported (except `+` for String) | Dunder methods |
| **Return type** | Associated type `Output` | N/A (named methods return anything) | Returns new object (or `self` for `__iadd__`) |
| **Mixed types** | Different `impl` per Rhs type | N/A | Reflected methods (`__radd__`) |
| **Reference operators** | `impl Add for &T` | N/A | Not applicable |
| **Comparison** | `PartialEq`/`Eq`, `PartialOrd`/`Ord` | `equals()`, `compareTo()` | `__eq__`, `__lt__`, `@total_ordering` |
| **Derivable** | `#[derive(PartialEq, Eq, Hash)]` | `record` auto-generates | `@dataclass(eq=True)` |
| **Hazard** | Type system prevents most misuse | `==` vs `.equals()` trap | Forgetting `NotImplemented` return |

---

## 8. Data Classes, Records, and Derive

Every language has recognized that most types are "just data" — collections of fields that need equality, hashing, and string representation. Rust addresses this with `#[derive]`, Java with `record`, and Python with `@dataclass`. The mechanisms differ in when they execute (compile time vs runtime), how configurable they are, and what they generate.

### Rust: `#[derive]` and Derivable Traits

Rust's `#[derive]` attribute invokes **procedural macros** at compile time to generate trait implementations:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash, Default)]
struct Person {
    name: String,
    age: u32,
    email: String,
}

// The above generates implementations equivalent to:
// impl Debug for Person { fn fmt(&self, f: &mut Formatter) -> Result { ... } }
// impl Clone for Person { fn clone(&self) -> Self { ... } }
// impl PartialEq for Person { fn eq(&self, other: &Self) -> bool { ... } }
// impl Eq for Person {}  // marker trait
// impl Hash for Person { fn hash<H: Hasher>(&self, state: &mut H) { ... } }
// impl Default for Person { fn default() -> Self { ... } }
```

**Standard derivable traits:**

| Trait | What it generates |
|-------|------------------|
| `Debug` | `{:?}` formatting — shows all fields |
| `Clone` | `.clone()` — deep copy by cloning each field |
| `Copy` | Implicit bitwise copy (only if all fields are `Copy`) |
| `PartialEq` | `==` — field-by-field comparison |
| `Eq` | Marker: declares that `PartialEq` is reflexive for all values |
| `PartialOrd` | `<`, `>` — lexicographic comparison of fields in declaration order |
| `Ord` | Total ordering |
| `Hash` | Hashing — combines hash of each field |
| `Default` | `Default::default()` — defaults each field |

**Custom derives from external crates:**

```rust
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
struct Config {
    host: String,
    port: u16,
    #[serde(default)]
    debug: bool,
}
```

The `serde` crate's derive macros generate serialization/deserialization code at compile time — zero runtime reflection cost.

**Key property of derive:** it is **opt-in per trait**. You choose exactly which capabilities to derive, and you can manually implement any trait to customize its behavior. You can derive `PartialEq` but implement `Hash` manually if you need non-standard hashing. This granularity is unique to Rust — Java records and Python dataclasses are more all-or-nothing.

> **Sources:** Blandy & Orendorff (2017) Ch.9 pp. 200–209 · Matthews (2024) Ch.4 pp. 65–80 · [Rust Reference — Derive macros](https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros) · [Rust By Example — Derive](https://doc.rust-lang.org/rust-by-example/trait/derive.html)

### Java: Records

Records (Java 16+, JEP 395) are **transparent carriers for shallowly immutable data**:

```java
// Record declaration — one line
public record Person(String name, int age, String email) {
    // Compact constructor for validation
    public Person {
        if (name == null || name.isBlank())
            throw new IllegalArgumentException("Name required");
        if (age < 0)
            throw new IllegalArgumentException("Age must be non-negative");
    }

    // Additional methods
    public String displayName() {
        return name + " (" + age + ")";
    }
}
```

**What records auto-generate:**

| Generated | Details |
|-----------|---------|
| Constructor | Canonical constructor with all components |
| Accessors | `name()`, `age()`, `email()` (not `getName()`) |
| `equals()` | Component-by-component equality |
| `hashCode()` | Based on all components |
| `toString()` | `Person[name=Alice, age=30, email=alice@example.com]` |

**Constraints of records:**

- Records are `final` — they cannot be subclassed.
- Record fields are `final` — components are immutable.
- Records cannot extend classes (only implement interfaces).
- Records cannot declare additional instance fields (only record components).
- The record's API is entirely determined by its components — it is "transparent."

**Records vs traditional classes:**

```java
// Traditional: ~40 lines with constructor, getters, equals, hashCode, toString
// Record: 1 line for the same functionality
public record Point(double x, double y) {}
```

Records are not just syntactic sugar — they carry semantic meaning: "this type's identity is entirely determined by its data." This enables the compiler and tools to reason about records differently than general classes.

> **Sources:** Evans et al (2022) Ch.3 pp. 55–65 · Horstmann (2024) Ch.4 pp. 63–68 · [JEP 395 — Records](https://openjdk.org/jeps/395)

### Python: `@dataclass`, `NamedTuple`, and `attrs`

Python provides multiple mechanisms for data classes, each with different tradeoffs:

**`@dataclass` (Python 3.7+, PEP 557):**

```python
from dataclasses import dataclass, field

@dataclass(frozen=True)  # frozen=True → immutable (hashable)
class Person:
    name: str
    age: int
    email: str
    tags: list[str] = field(default_factory=list)

    def display_name(self) -> str:
        return f"{self.name} ({self.age})"
```

**What `@dataclass` generates:**

| Parameter | Generates |
|-----------|-----------|
| `init=True` (default) | `__init__` with parameters matching field declarations |
| `repr=True` (default) | `__repr__` showing all fields |
| `eq=True` (default) | `__eq__` comparing all fields |
| `order=True` | `__lt__`, `__le__`, `__gt__`, `__ge__` (lexicographic) |
| `frozen=True` | `__setattr__`/`__delattr__` that raise `FrozenInstanceError` |
| `hash=...` | `__hash__` (auto if `frozen=True` and `eq=True`) |
| `slots=True` (3.10+) | `__slots__` for memory efficiency |
| `match_args=True` (3.10+) | `__match_args__` for pattern matching |

**`__post_init__`** runs after `__init__` for derived fields:

```python
@dataclass
class Rectangle:
    width: float
    height: float
    area: float = field(init=False)

    def __post_init__(self):
        self.area = self.width * self.height
```

**`typing.NamedTuple`** — lighter-weight, always immutable:

```python
from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float
```

NamedTuple instances are tuples — they support indexing, unpacking, and are always immutable and hashable.

**Comparison of Python data type options:**

| Feature | `@dataclass` | `NamedTuple` | `dict` | `TypedDict` |
|---------|-------------|-------------|--------|-------------|
| Mutable | Yes (unless `frozen`) | No (always immutable) | Yes | Yes |
| Type checking | At definition time | At definition time | None | Static only |
| Memory | `__dict__` (or `__slots__`) | Tuple | Dict | Dict |
| Pattern matching | Yes (`__match_args__`) | Yes (positional) | Mapping patterns | Mapping patterns |
| Iteration | No | Yes (tuple iteration) | Yes | Yes |

> **Sources:** Ramalho (2022) Ch.5 pp. 163–200 · Viafore (2021) Ch.9 pp. 123–134 · Slatkin (2025) Ch.7 pp. 217–259 (Items 51, 56) · [Python docs — dataclasses](https://docs.python.org/3/library/dataclasses.html) · [PEP 557 — Data Classes](https://peps.python.org/pep-0557/) · [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/)

### Comparison Matrix

| Aspect | Rust `#[derive]` | Java `record` | Python `@dataclass` |
|--------|-----------------|--------------|-------------------|
| **Execution time** | Compile time (proc macro) | Compile time (language feature) | Runtime (decorator) |
| **Granularity** | Per-trait opt-in | All-or-nothing | Per-feature flags |
| **Immutability** | No `mut` binding (default) | Always (`final` fields) | `frozen=True` option |
| **Inheritance** | No inheritance | No (records are `final`) | Yes (but fragile) |
| **Extensible** | Custom derive macros (serde, etc.) | No | `field()` metadata, `__post_init__` |
| **Zero-cost** | Yes (compile-time generation) | Mostly (records are classes) | No (runtime decoration) |
| **Custom overrides** | Implement trait manually | Override methods | Override methods |

---

## 9. Pattern Matching

Pattern matching is the mechanism for inspecting and destructuring data — it complements the type system by letting you branch on the *shape* of values. Rust has the most mature implementation (exhaustive `match` on algebraic data types), Java has been rapidly adding support (Java 21 sealed types + switch), and Python added structural pattern matching in 3.10.

### Rust: `match`, `if let`, and Exhaustive Patterns

Pattern matching is a **core language feature** in Rust, deeply integrated with enums (algebraic data types). The compiler enforces **exhaustiveness** — every possible variant must be handled.

```rust
enum Shape {
    Circle(f64),                        // radius
    Rectangle { width: f64, height: f64 },
    Triangle(f64, f64, f64),            // three sides
}

fn area(shape: &Shape) -> f64 {
    match shape {
        Shape::Circle(r) => std::f64::consts::PI * r * r,
        Shape::Rectangle { width, height } => width * height,
        Shape::Triangle(a, b, c) => {
            let s = (a + b + c) / 2.0;
            (s * (s - a) * (s - b) * (s - c)).sqrt()
        }
    }
    // Removing any arm → compile error: non-exhaustive patterns
}
```

**Pattern types in Rust:**

| Pattern | Example | Binds |
|---------|---------|-------|
| Literal | `42`, `"hello"`, `true` | Nothing |
| Variable | `x` | Captures the value |
| Wildcard | `_` | Matches anything, binds nothing |
| Struct | `Point { x, y }` | Destructures fields |
| Tuple | `(a, b, c)` | Destructures elements |
| Enum variant | `Some(x)`, `Err(e)` | Destructures variant |
| Reference | `&x`, `&mut x` | Destructures through reference |
| Range | `1..=5` | Matches inclusive range |
| Or | `1 \| 2 \| 3` | Matches any alternative |
| Guard | `x if x > 0` | Additional condition |
| Binding | `e @ 1..=5` | Captures value AND tests range |
| Rest | `[first, .., last]` | Matches remaining elements |
| Nested | `Some(Point { x: 0, y })` | Nested destructuring |

**`if let` and `while let`** for single-pattern matching:

```rust
// if let — when you only care about one variant
if let Some(value) = optional {
    println!("Got: {}", value);
}

// while let — loop until pattern stops matching
while let Some(item) = stack.pop() {
    process(item);
}

// let-else (Rust 1.65+) — diverge if pattern doesn't match
let Some(value) = optional else {
    return Err("missing value");
};
```

**Irrefutable vs refutable patterns:**

- **Irrefutable** — always matches. Used in `let`, function parameters, `for` loops. Example: `let (x, y) = point;`
- **Refutable** — might not match. Used in `match`, `if let`, `while let`. Example: `if let Some(x) = opt { ... }`

> **Sources:** Blandy & Orendorff (2017) Ch.10 pp. 211–233 · Klabnik & Nichols (2023) Ch.6 pp. 103–117 · Klabnik & Nichols (2023) Ch.19 pp. 440–458 · [Rust Reference — Patterns](https://doc.rust-lang.org/reference/patterns.html) · [Rust By Example — match](https://doc.rust-lang.org/rust-by-example/flow_control/match.html)

### Java: Pattern Matching for `instanceof` and `switch`

Java's pattern matching has been added incrementally across multiple releases:

**Pattern matching for `instanceof` (Java 16, JEP 394):**

```java
// Before Java 16
if (obj instanceof String) {
    String s = (String) obj;
    System.out.println(s.length());
}

// Java 16+
if (obj instanceof String s) {
    System.out.println(s.length());  // s is already bound and typed
}

// With logical operators — flow-scoping
if (obj instanceof String s && s.length() > 5) {
    // s is in scope only where the pattern definitely matched
}
```

**Record patterns (Java 21, JEP 440):**

```java
record Point(double x, double y) {}

// Destructure records in instanceof
if (obj instanceof Point(var x, var y)) {
    System.out.println("x=" + x + ", y=" + y);
}

// Nested record patterns
record Line(Point start, Point end) {}

if (obj instanceof Line(Point(var x1, var y1), Point(var x2, var y2))) {
    double length = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
}
```

**Pattern matching for `switch` (Java 21, JEP 441):**

```java
sealed interface Shape permits Circle, Rectangle, Triangle {}
record Circle(double radius) implements Shape {}
record Rectangle(double width, double height) implements Shape {}
record Triangle(double a, double b, double c) implements Shape {}

double area(Shape shape) {
    return switch (shape) {
        case Circle(var r) -> Math.PI * r * r;
        case Rectangle(var w, var h) -> w * h;
        case Triangle(var a, var b, var c) -> {
            double s = (a + b + c) / 2;
            yield Math.sqrt(s * (s - a) * (s - b) * (s - c));
        }
    };
    // Exhaustive: compiler verifies all permits are covered
}

// Guarded patterns
String classify(Shape shape) {
    return switch (shape) {
        case Circle(var r) when r > 100 -> "large circle";
        case Circle c -> "small circle";
        case Rectangle r -> "rectangle";
        case Triangle t -> "triangle";
    };
}

// null handling
String describe(Object obj) {
    return switch (obj) {
        case null -> "null";
        case Integer i -> "integer: " + i;
        case String s -> "string: " + s;
        default -> "other: " + obj;
    };
}
```

**Exhaustiveness:** the compiler verifies exhaustiveness for sealed types — if a `switch` covers all `permits` classes, no `default` is needed. This is what makes sealed interfaces + records + pattern matching into a full algebraic data type system for Java.

> **Sources:** Evans et al (2022) Ch.3 pp. 65–77 · Horstmann (2024) Ch.5 pp. 76–82 · [JEP 394 — Pattern Matching for instanceof](https://openjdk.org/jeps/394) · [JEP 440 — Record Patterns](https://openjdk.org/jeps/440) · [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)

### Python: Structural Pattern Matching (`match`/`case`)

Python 3.10 introduced `match`/`case` (PEP 634) — structural pattern matching that aligns with Python's duck typing philosophy:

```python
from dataclasses import dataclass

@dataclass
class Circle:
    radius: float

@dataclass
class Rectangle:
    width: float
    height: float

@dataclass
class Triangle:
    a: float
    b: float
    c: float

type Shape = Circle | Rectangle | Triangle

def area(shape: Shape) -> float:
    match shape:
        case Circle(radius=r):
            return 3.14159 * r * r
        case Rectangle(width=w, height=h):
            return w * h
        case Triangle(a=a, b=b, c=c):
            s = (a + b + c) / 2
            return (s * (s - a) * (s - b) * (s - c)) ** 0.5
        case _:
            raise TypeError(f"Unknown shape: {shape}")
```

**Pattern types in Python:**

| Pattern | Example | Description |
|---------|---------|-------------|
| Literal | `42`, `"hello"`, `True` | Matches exact value |
| Capture | `x` | Binds value to name |
| Wildcard | `_` | Matches anything |
| Class | `Point(x=0, y=y)` | Matches class and destructures |
| Sequence | `[first, *rest]` | Matches sequences |
| Mapping | `{"action": "move", "x": x}` | Matches dictionaries |
| OR | `"yes" \| "y" \| "Y"` | Matches alternatives |
| Guard | `case x if x > 0` | Additional condition |
| Walrus | `case (x := Point(0, y))` | Named sub-pattern |

**Class patterns and `__match_args__`:**

```python
@dataclass
class Point:
    x: float
    y: float
    # @dataclass auto-generates __match_args__ = ('x', 'y')

# Positional matching (uses __match_args__)
match point:
    case Point(0, 0):
        print("origin")
    case Point(0, y):
        print(f"on y-axis at y={y}")
    case Point(x, 0):
        print(f"on x-axis at x={x}")
    case Point(x, y):
        print(f"at ({x}, {y})")
```

**Mapping patterns:**

```python
match command:
    case {"action": "move", "x": x, "y": y}:
        move(x, y)
    case {"action": "resize", "factor": f}:
        resize(f)
    case {"action": action}:
        print(f"Unknown action: {action}")
```

**Key difference from Rust:** Python's `match` is **not exhaustive**. The compiler does not verify that all cases are handled. If no pattern matches and there is no `case _:` wildcard, execution falls through silently (the `match` statement does nothing). This is consistent with Python's dynamic nature but means bugs can hide.

> **Sources:** Slatkin (2025) Item 9 pp. 30–39 · Viafore (2021) Ch.8 pp. 111–121 · [PEP 634 — Structural Pattern Matching: Specification](https://peps.python.org/pep-0634/) · [PEP 635 — Structural Pattern Matching: Motivation and Rationale](https://peps.python.org/pep-0635/) · [PEP 636 — Structural Pattern Matching: Tutorial](https://peps.python.org/pep-0636/)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Syntax** | `match expr { ... }` | `switch (expr) { case ... -> }` | `match expr: case ...` |
| **Exhaustiveness** | Enforced at compile time | Enforced for sealed types | Not enforced |
| **Destructuring** | Structs, enums, tuples, refs | Records, nested records | Classes, sequences, mappings |
| **Guards** | `if condition` after pattern | `when condition` after pattern | `if condition` after pattern |
| **Binding** | `x`, `x @ pattern` | `var x` | `x`, `:= x` |
| **Or patterns** | `A \| B` | `case A, B` (since Java 21) | `A \| B` |
| **Null handling** | No null (use `Option::None`) | `case null` is valid | `case None` |
| **Irrefutable patterns** | `let`, `for`, function params | Not applicable | Not applicable |
| **Maturity** | Core feature since 1.0 | Evolved across Java 16–21 | Added in Python 3.10 |

---

## 10. Synthesis: Design Patterns Across All Three Languages

Traditional OOP design patterns (GoF, 1994) were designed for class-based languages with single-dispatch virtual methods. Each language's object model reshapes — or eliminates — these patterns in distinctive ways. Rust's type system eliminates several patterns by encoding their intent directly. Java's evolution (sealed classes, records, lambdas) simplifies others. Python's dynamic nature makes many patterns trivial or unnecessary.

### Strategy Pattern

The Strategy pattern encapsulates an algorithm behind an interface so it can be swapped at runtime.

**Rust:** closures or trait objects — the pattern is almost invisible:

```rust
// Using closures (most common in Rust)
fn sort_with_strategy<T, F>(data: &mut [T], strategy: F)
where F: Fn(&T, &T) -> std::cmp::Ordering
{
    data.sort_by(strategy);
}

// Using trait objects (for more complex strategies)
trait Compressor {
    fn compress(&self, data: &[u8]) -> Vec<u8>;
}

fn process(data: &[u8], compressor: &dyn Compressor) -> Vec<u8> {
    compressor.compress(data)
}
```

**Java:** functional interfaces and lambdas:

```java
// Strategy = functional interface + lambda
List<String> names = List.of("Charlie", "Alice", "Bob");
names.sort(Comparator.naturalOrder());           // strategy: natural order
names.sort(Comparator.comparing(String::length)); // strategy: by length
names.sort((a, b) -> b.compareTo(a));            // strategy: reverse
```

**Python:** first-class functions — the "pattern" is just passing a function:

```python
data = ["Charlie", "Alice", "Bob"]
data.sort(key=str.lower)     # strategy: case-insensitive
data.sort(key=len)           # strategy: by length
data.sort(key=lambda s: s[::-1])  # strategy: by reversed string
```

### Visitor Pattern

The Visitor pattern separates operations from the data structure they operate on. It exists because traditional OOP languages lack pattern matching on closed type hierarchies.

**Rust:** eliminated by `enum` + `match`:

```rust
enum Expr {
    Lit(i64),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
}

// "Visiting" = pattern matching — no Visitor interface needed
fn eval(expr: &Expr) -> i64 {
    match expr {
        Expr::Lit(n) => *n,
        Expr::Add(a, b) => eval(a) + eval(b),
        Expr::Mul(a, b) => eval(a) * eval(b),
    }
}

fn pretty_print(expr: &Expr) -> String {
    match expr {
        Expr::Lit(n) => n.to_string(),
        Expr::Add(a, b) => format!("({} + {})", pretty_print(a), pretty_print(b)),
        Expr::Mul(a, b) => format!("({} * {})", pretty_print(a), pretty_print(b)),
    }
}
```

**Java:** sealed interfaces + pattern matching (Java 21+) also eliminate the need for traditional Visitor:

```java
sealed interface Expr permits Lit, Add, Mul {}
record Lit(long value) implements Expr {}
record Add(Expr left, Expr right) implements Expr {}
record Mul(Expr left, Expr right) implements Expr {}

static long eval(Expr expr) {
    return switch (expr) {
        case Lit(var n) -> n;
        case Add(var a, var b) -> eval(a) + eval(b);
        case Mul(var a, var b) -> eval(a) * eval(b);
    };
}
```

**Python:** `match`/`case` or `functools.singledispatch`:

```python
@dataclass
class Lit:
    value: int

@dataclass
class Add:
    left: object
    right: object

@dataclass
class Mul:
    left: object
    right: object

def eval_expr(expr) -> int:
    match expr:
        case Lit(value=n):
            return n
        case Add(left=a, right=b):
            return eval_expr(a) + eval_expr(b)
        case Mul(left=a, right=b):
            return eval_expr(a) * eval_expr(b)
        case _:
            raise TypeError(f"Unknown expr: {expr}")
```

### Builder Pattern

**Rust:** method chaining with move semantics:

```rust
struct RequestBuilder {
    url: String,
    method: String,
    headers: Vec<(String, String)>,
}

impl RequestBuilder {
    fn new(url: &str) -> Self {
        RequestBuilder { url: url.to_string(), method: "GET".into(), headers: vec![] }
    }

    fn method(mut self, m: &str) -> Self {
        self.method = m.to_string();
        self  // Returns self by value — move semantics
    }

    fn header(mut self, key: &str, value: &str) -> Self {
        self.headers.push((key.to_string(), value.to_string()));
        self
    }

    fn build(self) -> Request {
        Request { url: self.url, method: self.method, headers: self.headers }
    }
}

let req = RequestBuilder::new("https://example.com")
    .method("POST")
    .header("Content-Type", "application/json")
    .build();
```

**Java:** static inner class (Bloch Item 2):

```java
public class Request {
    private final String url;
    private final String method;
    private final Map<String, String> headers;

    private Request(Builder builder) { /* ... */ }

    public static class Builder {
        private final String url;
        private String method = "GET";
        private final Map<String, String> headers = new HashMap<>();

        public Builder(String url) { this.url = url; }
        public Builder method(String m) { this.method = m; return this; }
        public Builder header(String k, String v) { headers.put(k, v); return this; }
        public Request build() { return new Request(this); }
    }
}
```

**Python:** often unnecessary — keyword arguments and `@dataclass` serve the purpose:

```python
@dataclass
class Request:
    url: str
    method: str = "GET"
    headers: dict[str, str] = field(default_factory=dict)

# No builder needed — keyword arguments do the job
req = Request(
    url="https://example.com",
    method="POST",
    headers={"Content-Type": "application/json"},
)
```

### Observer Pattern and Registration

**Rust:** callback lists or channels:

```rust
type Callback = Box<dyn Fn(&Event)>;

struct EventEmitter {
    listeners: Vec<Callback>,
}

impl EventEmitter {
    fn on(&mut self, callback: impl Fn(&Event) + 'static) {
        self.listeners.push(Box::new(callback));
    }

    fn emit(&self, event: &Event) {
        for listener in &self.listeners {
            listener(event);
        }
    }
}
```

**Java:** listener interfaces:

```java
public interface EventListener {
    void onEvent(Event event);
}

public class EventEmitter {
    private final List<EventListener> listeners = new ArrayList<>();

    public void addListener(EventListener l) { listeners.add(l); }

    public void emit(Event event) {
        listeners.forEach(l -> l.onEvent(event));
    }
}
```

**Python:** `__init_subclass__` for automatic registration:

```python
class Plugin:
    _registry: list[type] = []

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        Plugin._registry.append(cls)

class AuthPlugin(Plugin): pass
class LogPlugin(Plugin): pass

print(Plugin._registry)  # [AuthPlugin, LogPlugin] — automatic!
```

### Newtype Pattern

**Rust:** zero-cost wrapper — the compiler erases it:

```rust
struct Meters(f64);
struct Seconds(f64);

// Cannot accidentally add meters to seconds — different types
// impl Add for Meters + Seconds would be a compile error
fn velocity(distance: Meters, time: Seconds) -> f64 {
    distance.0 / time.0
}
```

**Java:** records as lightweight wrappers (some overhead until Valhalla):

```java
record Meters(double value) {}
record Seconds(double value) {}
```

**Python:** `typing.NewType` — static only, no runtime enforcement:

```python
from typing import NewType
Meters = NewType("Meters", float)
Seconds = NewType("Seconds", float)

# mypy enforces: Meters and Seconds are distinct types
# At runtime: Meters(5.0) is just 5.0
```

> **Sources:** Naftalin & Wadler (2024) Ch.6 pp. 81–90 · Slatkin (2025) Ch.7 pp. 260–264 (Item 57) · Slatkin (2025) Ch.8 pp. 285–298 (Items 62–63) · [Rust Design Patterns book](https://rust-unofficial.github.io/patterns/) · [Refactoring Guru — Design Patterns](https://refactoring.guru/design-patterns)

### Meta-Pattern: How Each Language Reshapes OOP Design

| Pattern | Rust | Java | Python |
|---------|------|------|--------|
| **Strategy** | Closure / `dyn Fn(...)` | Functional interface + lambda | First-class function |
| **Visitor** | Eliminated: `enum` + `match` | Eliminated: sealed + switch (Java 21+) | `match`/`case` or `singledispatch` |
| **Builder** | Method chaining with moves | Static inner class (Bloch Item 2) | Usually unnecessary (`@dataclass` + kwargs) |
| **Observer** | `Vec<Box<dyn Fn(Event)>>` / channels | Listener interfaces / reactive `Flow` | Callback lists / `__init_subclass__` |
| **Newtype** | Zero-cost: `struct Name(Inner)` | Record wrapper (overhead) | `typing.NewType` (static only) |
| **State** | Type-state pattern (compile-time) | Interface + state objects | Duck typing / enum |
| **Factory** | Associated function / trait | Static factory method (Bloch Item 1) | `@classmethod` |
| **Singleton** | Module-level static / `once_cell` | Enum singleton (Bloch Item 3) | Module-level variable |

The meta-observation: **Rust eliminates patterns through its type system** (enums eliminate Visitor, closures eliminate Strategy, ownership prevents Observer memory leaks, type-state prevents invalid State transitions). **Java evolves toward Rust's approach** (sealed classes + records + pattern matching). **Python makes patterns trivial** through dynamic features (first-class functions, duck typing, keyword arguments) but sacrifices static guarantees.

---

## Sources

**Rust**
- [Rust Reference — Struct Types](https://doc.rust-lang.org/reference/types/struct.html)
- [Rust Reference — Implementations](https://doc.rust-lang.org/reference/items/implementations.html)
- [Rust Reference — Associated Items](https://doc.rust-lang.org/reference/items/associated-items.html)
- [Rust Reference — Traits](https://doc.rust-lang.org/reference/items/traits.html)
- [Rust Reference — Trait Objects](https://doc.rust-lang.org/reference/types/trait-object.html)
- [Rust Reference — Object Safety](https://doc.rust-lang.org/reference/items/traits.html#object-safety)
- [Rust Reference — Trait Implementations (coherence)](https://doc.rust-lang.org/reference/items/implementations.html#trait-implementations)
- [Rust Reference — Patterns](https://doc.rust-lang.org/reference/patterns.html)
- [Rust Reference — Derive macros](https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros)
- [Rustonomicon — Dynamically Sized Types](https://doc.rust-lang.org/nomicon/exotic-sizes.html)
- [Rustc Dev Guide — Monomorphization](https://rustc-dev-guide.rust-lang.org/backend/monomorph.html)
- [Rust By Example — Structures](https://doc.rust-lang.org/rust-by-example/custom_types/structs.html)
- [Rust By Example — Methods](https://doc.rust-lang.org/rust-by-example/fn/methods.html)
- [Rust By Example — Traits](https://doc.rust-lang.org/rust-by-example/trait.html)
- [Rust By Example — Operator Overloading](https://doc.rust-lang.org/rust-by-example/trait/ops.html)
- [Rust By Example — Derive](https://doc.rust-lang.org/rust-by-example/trait/derive.html)
- [Rust By Example — match](https://doc.rust-lang.org/rust-by-example/flow_control/match.html)
- [Rust std — std::ops](https://doc.rust-lang.org/std/ops/index.html)
- [Rust std — std::cmp](https://doc.rust-lang.org/std/cmp/index.html)
- [Rust Blog — "Abstraction without overhead: traits in Rust" (2015)](https://blog.rust-lang.org/2015/05/11/traits.html)
- [Rust RFC 1023 — Rebalancing coherence](https://rust-lang.github.io/rfcs/1023-rebalancing-coherence.html)
- [Rust RFC 2451 — Re-rebalancing coherence](https://rust-lang.github.io/rfcs/2451-re-rebalancing-coherence.html)
- [Rust Design Patterns book](https://rust-unofficial.github.io/patterns/)
- [Niko Matsakis — "dyn*: can we make dyn sized?" (2022)](https://smallcultfollowing.com/babysteps/blog/2022/03/29/dyn-can-we-make-dyn-sized/)

**Java**
- [JLS Ch.8 — Classes](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html)
- [JLS 8.4.3.2 — Static Methods](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.3.2)
- [JLS 8.4.8 — Inheritance, Overriding, and Hiding](https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.8)
- [JLS Ch.9 — Interfaces](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html)
- [JLS 9.4 — Interface Multiple Inheritance](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.4)
- [JLS 15.12 — Method Invocation Expressions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.12)
- [JLS 15.18.1 — String Concatenation Operator](https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.18.1)
- [JVM Specification — invokevirtual](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html#jvms-6.5.invokevirtual)
- [JEP 394 — Pattern Matching for instanceof](https://openjdk.org/jeps/394)
- [JEP 395 — Records](https://openjdk.org/jeps/395)
- [JEP 409 — Sealed Classes](https://openjdk.org/jeps/409)
- [JEP 440 — Record Patterns](https://openjdk.org/jeps/440)
- [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)
- [Brian Goetz — "Data Classes and Sealed Types for Java"](https://cr.openjdk.org/~briangoetz/amber/datum.html)
- [Aleksey Shipilev — JVM Anatomy Quark #16: Megamorphic Virtual Calls](https://shipilev.net/jvm/anatomy-quarks/16-megamorphic-virtual-calls/)
- [Oracle — HotSpot VM Performance Enhancements](https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html)

**Python**
- [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)
- [Python docs — `__slots__`](https://docs.python.org/3/reference/datamodel.html#slots)
- [Python docs — Customizing attribute access](https://docs.python.org/3/reference/datamodel.html#customizing-attribute-access)
- [Python docs — Emulating numeric types](https://docs.python.org/3/reference/datamodel.html#emulating-numeric-types)
- [Python docs — Rich comparison methods](https://docs.python.org/3/reference/datamodel.html#object.__lt__)
- [Python docs — Descriptor HowTo Guide](https://docs.python.org/3/howto/descriptor.html)
- [Python docs — abc module](https://docs.python.org/3/library/abc.html)
- [Python docs — dataclasses module](https://docs.python.org/3/library/dataclasses.html)
- [Python docs — classmethod](https://docs.python.org/3/library/functions.html#classmethod)
- [Python docs — staticmethod](https://docs.python.org/3/library/functions.html#staticmethod)
- [Python docs — super()](https://docs.python.org/3/library/functions.html#super)
- [Python docs — Method Resolution Order](https://docs.python.org/3/glossary.html#term-method-resolution-order)
- [Python docs — Multiple Inheritance](https://docs.python.org/3/tutorial/classes.html#multiple-inheritance)
- [PEP 207 — Rich Comparisons](https://peps.python.org/pep-0207/)
- [PEP 544 — Protocols: Structural subtyping](https://peps.python.org/pep-0544/)
- [PEP 557 — Data Classes](https://peps.python.org/pep-0557/)
- [PEP 634 — Structural Pattern Matching: Specification](https://peps.python.org/pep-0634/)
- [PEP 635 — Structural Pattern Matching: Motivation and Rationale](https://peps.python.org/pep-0635/)
- [PEP 636 — Structural Pattern Matching: Tutorial](https://peps.python.org/pep-0636/)
- [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/)
- [PEP 3119 — Introducing Abstract Base Classes](https://peps.python.org/pep-3119/)
- [PEP 3135 — New Super](https://peps.python.org/pep-3135/)
- [Michele Simionato — "The Python 2.3 MRO"](https://www.python.org/download/releases/2.3/mro/)

**Cross-Language**
- [Refactoring Guru — Design Patterns](https://refactoring.guru/design-patterns)

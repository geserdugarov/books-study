# Layer 2 · Topic 8 — Object Model & Polymorphism

> Comparative study of Rust, Java, and Python: how each language defines composite types, attaches behavior, and achieves polymorphism — from structs/classes and traits/interfaces/protocols through dynamic dispatch and operator overloading to data classes and pattern matching.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.5 pp. 85–102 | Structs (named-field, tuple, unit), method syntax with `impl`, associated functions, multiple `impl` blocks |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.6 pp. 103–117 | Enums as algebraic data types, `Option<T>`, pattern matching with `match` and `if let`, exhaustive matching |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.10 pp. 181–213 | Generic types, traits (defining, implementing, default implementations), trait bounds, `impl Trait` syntax, monomorphization |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.17 pp. 375–396 | OOP features of Rust, trait objects (`dyn Trait`), object safety, state pattern implementation, when to use trait objects vs enums |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.19 pp. 419–458 | Advanced traits (associated types, default type parameters, fully qualified syntax, supertraits, newtype pattern), operator overloading, advanced patterns (`@` bindings, match guards, `..`, nested patterns) |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.9 pp. 193–209 | Structs (named-field, tuple-like, unit-like), generic structs, deriving common traits, interior mutability with `Cell`/`RefCell` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.10 pp. 211–233 | Enums and patterns — algebraic data types, generic enums, pattern matching, references in patterns |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.11 pp. 235–263 | Traits and generics — trait objects, `dyn Trait`, fat pointers, vtable layout, static vs dynamic dispatch, associated types, `impl Trait`, fully qualified method calls |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.12 pp. 265–280 | Operator overloading via `std::ops` traits — arithmetic, bitwise, unary, comparison, `Index`/`IndexMut` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.13 pp. 281–301 | Utility traits — `Drop`, `Sized`, `Clone`, `Copy`, `Deref`/`DerefMut`, `Default`, `AsRef`/`AsMut`, `From`/`Into`, `Display` |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.2 pp. 19–35 | Types in memory, trait mechanics (static vs dynamic dispatch, coherence, orphan rule, marker traits), dynamically sized types, wide pointers |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.3 pp. 37–56 | Designing interfaces — API design principles, generic arguments, object safety, borrowed vs owned, `Borrow`/`AsRef` ergonomics |
| Rust | McNamara (2021) — *Rust in Action* | Ch.3 pp. 77–105 | Compound data types — structs with methods, enums, defining and implementing traits, visibility and encapsulation |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91 | Data structures — structs, enums, pattern matching, `From`/`Into`/`TryFrom`/`TryInto` conversions |
| Java | Bloch (2018) — *Effective Java* | Ch.3 pp. 37–71 | Methods common to all objects — `equals`, `hashCode`, `toString`, `clone`, `compareTo` contracts and implementation |
| Java | Bloch (2018) — *Effective Java* | Ch.4 pp. 73–115 | Classes and interfaces — minimize accessibility, immutability, composition over inheritance, design for inheritance, interfaces over abstract classes, tagged classes, class hierarchies |
| Java | Bloch (2018) — *Effective Java* | Ch.5 pp. 117–155 | Generics — raw types, unbounded wildcards, bounded wildcards (PECS), typesafe heterogeneous containers |
| Java | Bloch (2018) — *Effective Java* | Ch.6 pp. 157–191 | Enums and annotations — type-safe enums, enum methods, constant-specific behavior, `EnumSet`, `EnumMap`, extending enums with interfaces |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.3 pp. 55–77 | Java 17 features — records (nominal typing), sealed types (controlled inheritance), pattern matching with `instanceof`, switch expressions |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.4 pp. 81–117 | Class files and bytecode — class loading, bytecode opcodes for method invocation, reflection |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.17 pp. 571–607 | Modern internals — method invocation types (`invokevirtual`, `invokeinterface`, `invokespecial`, `invokestatic`), method handles, `invokedynamic` |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.4 pp. 55–68 | Objects and classes — constructors, static fields and methods, factory methods, records |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.5 pp. 70–82 | Inheritance — `Object` class, `equals`/`hashCode`/`toString`, abstract classes, enums, sealed classes, pattern matching |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.6 pp. 85–92 | Interfaces, lambda expressions, inner classes — default methods, static interface methods, functional interfaces, dynamic proxies |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.8 pp. 104–115 | Generic programming — generic classes and methods, type variable bounds, wildcard types, type erasure |
| Java | Naftalin & Wadler (2024) — *Java Generics and Collections* | Ch.1 pp. 26–36 | Subtyping and wildcards — Substitution Principle, wildcard types, PECS principle |
| Java | Naftalin & Wadler (2024) — *Java Generics and Collections* | Ch.2 pp. 38–48 | Comparison and bounds — `Comparable`/`Comparator`, bounded type parameters, bridge methods, covariant overriding |
| Java | Naftalin & Wadler (2024) — *Java Generics and Collections* | Ch.6 pp. 81–90 | Design patterns with generics — Visitor, Interpreter, Strategy, Observer, Factory |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.7 pp. 177–212 | Comparing objects — `equals()`, `hashCode()`, `compareTo()` pitfalls, type correctness in equality |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.4 pp. 115–169 | Object-oriented Python — classes and instances, special methods, inheritance and MRO (C3 linearization), class/static methods, properties, decorators, metaclasses |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.5 pp. 171–194 | Type annotations — gradual typing, `typing` module, `Protocol` for structural typing, `mypy` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.1 pp. 3–20 | Python data model — special methods as the foundation for Pythonic objects, operator overloading preview, consistency through the data model |
| Python | Ramalho (2022) — *Fluent Python* | Ch.5 pp. 163–200 | Data class builders — `collections.namedtuple`, `typing.NamedTuple`, `@dataclass`, field options, `__post_init__`, class-level customization |
| Python | Ramalho (2022) — *Fluent Python* | Ch.11 pp. 363–396 | A Pythonic object — `__repr__`, `__str__`, `__format__`, `__hash__`, `classmethod` vs `staticmethod`, `__slots__` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.12 pp. 397–430 | Special methods for sequences — `__getitem__`, `__len__`, `__contains__`, duck typing protocols, dynamic attribute access |
| Python | Ramalho (2022) — *Fluent Python* | Ch.13 pp. 431–486 | Interfaces, protocols, and ABCs — duck typing, goose typing, `abc.ABC`, virtual subclasses, `typing.Protocol`, structural subtyping |
| Python | Ramalho (2022) — *Fluent Python* | Ch.14 pp. 487–518 | Inheritance: for better or for worse — `super()` and MRO, multiple inheritance pitfalls, C3 linearization, mixins, `__init_subclass__` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.16 pp. 561–590 | Operator overloading — unary/infix operators, rich comparisons, augmented assignment, reflected operators (`__radd__`), `NotImplemented` sentinel |
| Python | Viafore (2021) — *Robust Python* | Ch.8 pp. 111–121 | Enums — `Enum`, `IntEnum`, `Flag`, `auto()`, type-safe constants |
| Python | Viafore (2021) — *Robust Python* | Ch.9 pp. 123–134 | Data classes — `@dataclass` usage, comparison with dict/TypedDict/namedtuple, field customization |
| Python | Viafore (2021) — *Robust Python* | Ch.10 pp. 135–152 | Classes — class anatomy, invariants, encapsulation conventions |
| Python | Viafore (2021) — *Robust Python* | Ch.12 pp. 171–185 | Subtyping — inheritance, Liskov Substitution Principle, composition over inheritance |
| Python | Viafore (2021) — *Robust Python* | Ch.13 pp. 187–197 | Protocols — structural subtyping with `typing.Protocol`, composite protocols, `@runtime_checkable` |
| Python | Slatkin (2025) — *Effective Python* | Ch.7 pp. 201–264 | Classes and interfaces — polymorphism over `isinstance` (Item 49), `functools.singledispatch` (Item 50), dataclasses (Items 51, 56), `@classmethod` polymorphism (Item 52), `super()` and MRO (Item 53), mix-in classes (Item 54), `collections.abc` (Item 57) |
| Python | Slatkin (2025) — *Effective Python* | Ch.8 pp. 265–318 | Metaclasses and attributes — descriptors (Item 60), `__init_subclass__` (Items 62–63), `__set_name__` (Item 64), class decorators vs metaclasses (Item 66) |
| Python | Slatkin (2025) — *Effective Python* | Item 9 pp. 30–39 | Pattern matching — `match`/`case` for destructuring, when to prefer `match` over `if` chains |

### Coverage Gaps

The owned books **do not** cover:

- **Vtable layout and dynamic dispatch internals at byte level across all three languages** — Blandy and Gjengset describe Rust's fat-pointer vtable (data pointer + vtable pointer) conceptually, and Evans covers Java's `invokevirtual`/`invokeinterface` at the bytecode level, but none of the owned books provide a byte-level comparison of Rust's vtable structure, Java's HotSpot vtable/itable mechanism, and Python's `__dict__`-based attribute lookup chain with type attribute caches; this requires the Rustonomicon, HotSpot source, and CPython `typeobject.c`
- **Trait coherence rules and the orphan rule in full depth** — Gjengset covers coherence and the orphan rule at the API-design level (Ch.2 pp. 30–35), but the full complexity — blanket implementations, the overlap check algorithm, `#[fundamental]` types, negative trait bounds, and the re-rebalancing rules — is only documented in Rust RFCs (RFC 1023, RFC 2451) and the Rust Reference
- **Sealed classes and interfaces as algebraic data types in Java 17+** — Evans covers sealed types at the feature level (Ch.3), but the interaction between sealed interfaces, records, and exhaustive pattern matching in switch expressions (Java 21+) as a complete system for encoding sum types is not explored in depth; this requires JEP 409, JEP 440, and JEP 441
- **Python descriptor protocol in complete depth** — Martelli covers descriptors briefly in Ch.4, Ramalho covers `__get__`/`__set__`/`__set_name__` in Ch.23, and Slatkin covers descriptors in Item 60, but the full protocol (data descriptors vs non-data descriptors, descriptor invocation from `type.__getattribute__`, how `property`/`classmethod`/`staticmethod` are implemented as descriptors) requires the Python Data Model documentation and the Descriptor HowTo Guide
- **Design patterns expressed idiomatically across all three languages** — Naftalin & Wadler Ch.6 covers patterns with Java generics, but there is no cross-language treatment of how Rust eliminates some patterns entirely (Visitor via `enum` + `match`, Strategy via closures), how Java's sealed classes reshape patterns, and how Python uses duck typing and first-class functions to simplify others; this requires supplemental design patterns resources
- **Pattern matching completeness and comparison across all three languages** — Klabnik covers Rust's `match` and `if let`, Evans covers Java's pattern matching, and Slatkin covers Python's `match`/`case`, but the full comparison of Rust's irrefutable vs refutable patterns with match guards and `@` bindings vs Java's pattern matching for switch with guarded patterns and record patterns vs Python's structural pattern matching (PEP 634) with class patterns, sequence patterns, and mapping patterns requires the language references and PEPs
- **Python metaclass mechanics and their interaction with `__init_subclass__`** — Martelli covers metaclasses in Ch.4, Slatkin covers `__init_subclass__` in Items 62–63 and metaclass alternatives in Item 66, but the interaction between metaclasses, `__set_name__`, `__init_subclass__`, and `__class_getitem__` as the Python object construction protocol requires the CPython source and PEP 487

---

## External Resources

### Sub-topic 1 — Structs, Classes, and Object Fundamentals

**Rust**
- The Rust Reference — Struct Types: `https://doc.rust-lang.org/reference/types/struct.html`
- The Rust Reference — Implementations: `https://doc.rust-lang.org/reference/items/implementations.html`
- Rust By Example — Structures: `https://doc.rust-lang.org/rust-by-example/custom_types/structs.html`

**Java**
- Java Language Specification — Classes (JLS Ch.8): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html`
- JEP 395 — Records: `https://openjdk.org/jeps/395`
- Brian Goetz — "Data Classes and Sealed Types for Java": `https://cr.openjdk.org/~briangoetz/amber/datum.html`

**Python**
- Python docs — Data Model: `https://docs.python.org/3/reference/datamodel.html`
- Python docs — `__slots__`: `https://docs.python.org/3/reference/datamodel.html#slots`
- Python docs — Descriptor HowTo Guide: `https://docs.python.org/3/howto/descriptor.html`

### Sub-topic 2 — Methods, Associated Functions, Static vs Instance

**Rust**
- The Rust Reference — Associated Items: `https://doc.rust-lang.org/reference/items/associated-items.html`
- Rust By Example — Methods: `https://doc.rust-lang.org/rust-by-example/fn/methods.html`

**Java**
- Java Language Specification — Static Methods (JLS 8.4.3.2): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.3.2`
- Java Language Specification — Static Initializers (JLS 8.7): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.7`

**Python**
- Python docs — classmethod: `https://docs.python.org/3/library/functions.html#classmethod`
- Python docs — staticmethod: `https://docs.python.org/3/library/functions.html#staticmethod`
- Python docs — Descriptor HowTo (classmethod/staticmethod internals): `https://docs.python.org/3/howto/descriptor.html#static-methods-and-class-methods`

### Sub-topic 3 — Inheritance and Composition

**Rust**
- Rust Blog — "Abstraction without overhead: traits in Rust" (2015): `https://blog.rust-lang.org/2015/05/11/traits.html`
- The Rust Reference — Traits: `https://doc.rust-lang.org/reference/items/traits.html`
- Rust By Example — Traits: `https://doc.rust-lang.org/rust-by-example/trait.html`

**Java**
- Java Language Specification — Inheritance, Overriding, and Hiding (JLS 8.4.8): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.4.8`
- JEP 409 — Sealed Classes: `https://openjdk.org/jeps/409`

**Python**
- Python docs — Multiple Inheritance: `https://docs.python.org/3/tutorial/classes.html#multiple-inheritance`
- PEP 3135 — New Super: `https://peps.python.org/pep-3135/`

### Sub-topic 4 — Interfaces, Traits, Protocols: Abstract Polymorphism

**Rust**
- The Rust Reference — Trait Objects: `https://doc.rust-lang.org/reference/types/trait-object.html`
- The Rust Reference — Object Safety: `https://doc.rust-lang.org/reference/items/traits.html#object-safety`

**Java**
- Java Language Specification — Interfaces (JLS Ch.9): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html`

**Python**
- PEP 544 — Protocols: Structural subtyping: `https://peps.python.org/pep-0544/`
- PEP 3119 — Introducing Abstract Base Classes: `https://peps.python.org/pep-3119/`
- Python docs — abc module: `https://docs.python.org/3/library/abc.html`

### Sub-topic 5 — Dynamic Dispatch: Vtables, Trait Objects, Virtual Methods

**Rust**
- The Rustonomicon — Dynamically Sized Types: `https://doc.rust-lang.org/nomicon/exotic-sizes.html`
- The Rustc Dev Guide — Monomorphization: `https://rustc-dev-guide.rust-lang.org/backend/monomorph.html`
- Niko Matsakis — "dyn*: can we make dyn sized?" (2022): `https://smallcultfollowing.com/babysteps/blog/2022/03/29/dyn-can-we-make-dyn-sized/`

**Java**
- JVM Specification — invokevirtual (JVMS 6.5): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-6.html#jvms-6.5.invokevirtual`
- Aleksey Shipilev — JVM Anatomy Quark #16: Megamorphic Virtual Calls: `https://shipilev.net/jvm/anatomy-quarks/16-megamorphic-virtual-calls/`
- Oracle HotSpot — VM Performance Enhancements: `https://docs.oracle.com/en/java/javase/21/vm/java-hotspot-virtual-machine-performance-enhancements.html`

**Python**
- Python docs — Customizing attribute access: `https://docs.python.org/3/reference/datamodel.html#customizing-attribute-access`

### Sub-topic 6 — Method Resolution Order and Coherence Rules

**Rust**
- Rust RFC 2451 — Re-rebalancing coherence: `https://rust-lang.github.io/rfcs/2451-re-rebalancing-coherence.html`
- Rust RFC 1023 — Rebalancing coherence: `https://rust-lang.github.io/rfcs/1023-rebalancing-coherence.html`
- The Rust Reference — Trait Implementations (coherence/orphan rules): `https://doc.rust-lang.org/reference/items/implementations.html#trait-implementations`

**Java**
- Java Language Specification — Method Invocation Expressions (JLS 15.12): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.12`
- Java Language Specification — Interface Multiple Inheritance (JLS 9.4): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.4`

**Python**
- Michele Simionato — "The Python 2.3 Method Resolution Order": `https://www.python.org/download/releases/2.3/mro/`
- Python docs — Method Resolution Order: `https://docs.python.org/3/glossary.html#term-method-resolution-order`
- Python docs — super(): `https://docs.python.org/3/library/functions.html#super`

### Sub-topic 7 — Operator Overloading

**Rust**
- Rust std docs — std::ops module: `https://doc.rust-lang.org/std/ops/index.html`
- Rust std docs — std::cmp module: `https://doc.rust-lang.org/std/cmp/index.html`
- Rust By Example — Operator Overloading: `https://doc.rust-lang.org/rust-by-example/trait/ops.html`

**Java**
- Java Language Specification — String Concatenation Operator (JLS 15.18.1): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-15.html#jls-15.18.1`

**Python**
- Python docs — Emulating numeric types: `https://docs.python.org/3/reference/datamodel.html#emulating-numeric-types`
- Python docs — Rich comparison methods: `https://docs.python.org/3/reference/datamodel.html#object.__lt__`
- PEP 207 — Rich Comparisons: `https://peps.python.org/pep-0207/`

### Sub-topic 8 — Data Classes, Records, and Derive

**Rust**
- The Rust Reference — Derive macros: `https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros`
- Rust By Example — Derive: `https://doc.rust-lang.org/rust-by-example/trait/derive.html`

**Java**
- JEP 395 — Records: `https://openjdk.org/jeps/395`

**Python**
- Python docs — dataclasses module: `https://docs.python.org/3/library/dataclasses.html`
- PEP 557 — Data Classes: `https://peps.python.org/pep-0557/`
- PEP 681 — Data Class Transforms: `https://peps.python.org/pep-0681/`

### Sub-topic 9 — Pattern Matching

**Rust**
- The Rust Reference — Patterns: `https://doc.rust-lang.org/reference/patterns.html`
- Rust By Example — match: `https://doc.rust-lang.org/rust-by-example/flow_control/match.html`

**Java**
- JEP 394 — Pattern Matching for instanceof: `https://openjdk.org/jeps/394`
- JEP 440 — Record Patterns: `https://openjdk.org/jeps/440`
- JEP 441 — Pattern Matching for switch: `https://openjdk.org/jeps/441`

**Python**
- PEP 634 — Structural Pattern Matching: Specification: `https://peps.python.org/pep-0634/`
- PEP 635 — Structural Pattern Matching: Motivation and Rationale: `https://peps.python.org/pep-0635/`
- PEP 636 — Structural Pattern Matching: Tutorial: `https://peps.python.org/pep-0636/`

### Sub-topic 10 — Design Patterns Across Languages

**General**
- Rust Design Patterns book (online): `https://rust-unofficial.github.io/patterns/`
- Refactoring Guru — Design Patterns: `https://refactoring.guru/design-patterns`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| General | Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides — *Design Patterns: Elements of Reusable Object-Oriented Software* (Addison-Wesley, 1994) | The foundational catalog of 23 design patterns (Strategy, Visitor, Observer, Factory, etc.) defined in terms of class-based OOP; essential context for understanding why Rust eliminates some patterns entirely (Visitor via enums, Strategy via closures) and how Python simplifies others (Strategy via first-class functions) |
| Rust | *Rust Design Patterns* (online book, community-maintained) | Covers idiomatic Rust patterns, anti-patterns, and design guidance (newtype, builder, type-state, RAII guards) that replace traditional OOP patterns; fills the gap between Rust's trait-based model and classical OOP pattern catalogs |
| General | Benjamin C. Pierce — *Types and Programming Languages* (MIT Press, 2002) | The foundational textbook on type theory: subtyping, polymorphism (parametric, ad-hoc, subtype), type inference, existential types; provides the theoretical framework for understanding why Rust's traits are bounded parametric polymorphism, Java interfaces are subtype polymorphism, and Python protocols are structural subtyping |
| Java | Venkat Subramaniam — *Design Patterns in Java* (Pragmatic, 2023) | Modern treatment of GoF patterns in Java with records, sealed classes, lambdas, and pattern matching; shows how Java 17+ features reshape classical patterns compared to the original GoF treatment |

---

## Study Plan — 10 Sessions

Estimated total: **20–25 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from fundamental type definition through polymorphism mechanisms to advanced patterns and synthesis.

---

### Session 1 — Classes, Structs, Objects: Fundamentals

**Goal:** understand how each language defines and instantiates composite data types — Rust's structs with `impl` blocks, Java's classes with constructors and records, Python's classes with `__init__` and data model methods.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: structs and impl blocks.** Read Klabnik Ch.5 pp. 85–102 (structs, method syntax, associated functions). Read Blandy Ch.9 pp. 193–209 (named-field, tuple-like, unit-like structs, generic structs, deriving traits). Read McNamara Ch.3 pp. 77–95 (compound data types, struct methods). Key insight: Rust structs are pure data with behavior attached externally via `impl` blocks. There is no constructor keyword — associated functions like `fn new()` are a convention. Multiple `impl` blocks can exist for the same struct (essential for conditional trait implementations). Structs have no inheritance — `&self` is an explicit parameter, not an implicit `this` pointer. The struct declaration and its methods are separate concerns, unlike Java/Python where data and behavior are declared together in the class body. |
| 1.2 | 30 min | **Java: classes, constructors, records.** Read Horstmann Ch.4 pp. 55–68 (objects and classes, constructors, static fields/methods, factory methods, records). Read Bloch Ch.4 pp. 73–90 (Items 15–22: minimize accessibility, accessor methods, immutability, prefer composition). Key insight: Java classes bundle data and behavior in a single unit with constructors, access modifiers (`private`, `protected`, `public`, package-private), and the implicit `this` pointer. Records (`record Point(double x, double y) {}`, Java 16+) are transparent data carriers that auto-generate canonical constructor, component accessors, `equals`, `hashCode`, and `toString`. Records are `final` and their fields are `final` — the closest Java gets to Rust's derive-friendly structs. The evolution from verbose classes to concise records mirrors the industry trend toward data-oriented programming. |
| 1.3 | 25 min | **Python: classes and the data model.** Read Ramalho Ch.1 pp. 3–20 (Python data model, special methods). Read Martelli Ch.4 pp. 115–135 (classes and instances, `__init__`, `__new__`, attribute access). Read Viafore Ch.10 pp. 135–145 (class anatomy, invariants). Key insight: Python classes are dynamic namespaces. `__init__` is not a constructor — it is an initializer; `__new__` is the actual constructor. Every attribute access goes through `type.__getattribute__`. Special methods (`__repr__`, `__str__`, `__eq__`, `__hash__`) define how objects behave with built-in functions and operators. Class bodies execute at definition time, creating a namespace dict that becomes the class's `__dict__`. There are no access modifiers — encapsulation relies on the name-mangling convention (`_private`, `__mangled`) and developer discipline. |
| 1.4 | 15 min | **Cross-language comparison.** Create a `Point` type in all three languages. Compare: what the language generates automatically, what you must write manually, memory layout, mutability defaults. Rust: `struct Point { x: f64, y: f64 }` + `impl` block — nothing auto-generated without `#[derive]`. Java: `record Point(double x, double y)` — constructor, accessors, equals/hashCode/toString all auto-generated. Python: `class Point:` with `__init__` — nothing auto-generated without `@dataclass`. Note the spectrum: Java records are the most concise for data-carrying types; Rust requires explicit `#[derive]` for each capability; Python requires either boilerplate or `@dataclass`. |

---

### Session 2 — Methods, Associated Functions, Static vs Instance

**Goal:** understand the different ways methods are attached to types — Rust's `impl` blocks with explicit `self`, Java's instance/static/default methods, Python's regular/class/static methods and the descriptor protocol that underpins them.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **Rust: methods and associated functions in impl blocks.** Read Klabnik Ch.5 pp. 93–102 (method syntax, associated functions). Read Blandy Ch.9 pp. 196–209 (impl blocks, methods, associated functions). Read the Rust Reference "Associated Items" section online. Key insight: methods take `self`, `&self`, or `&mut self` as the first parameter — the receiver is explicit and determines ownership/borrowing semantics. Associated functions without `self` (like `String::new()`) are equivalent to static methods. Multiple `impl` blocks allow separating functionality and are essential for conditional trait implementations (`impl<T: Display> MyStruct<T>`). Rust has no method overloading — each method name is unique within an `impl` block. The explicit receiver makes the cost of each call visible: `self` consumes, `&self` borrows immutably, `&mut self` borrows mutably. |
| 2.2 | 30 min | **Java: instance, static, default, and private interface methods.** Read Horstmann Ch.6 pp. 85–92 (interfaces, default methods, static interface methods). Read Evans Ch.17 pp. 571–590 (method invocation types: `invokevirtual`, `invokeinterface`, `invokespecial`, `invokestatic`). Key insight: Java has four method invocation bytecodes corresponding to four kinds of methods. `invokevirtual` dispatches instance methods through the class vtable. `invokeinterface` dispatches interface methods through the itable. `invokespecial` calls constructors, `super` methods, and private methods (no virtual dispatch). `invokestatic` calls static methods. Default methods in interfaces (Java 8+) enable interface evolution without breaking implementations — they have a body but no state. Static methods in interfaces provide namespace-scoped utilities. Private interface methods (Java 9+) allow code reuse within default method implementations. |
| 2.3 | 25 min | **Python: methods, classmethod, staticmethod, and descriptors.** Read Martelli Ch.4 pp. 140–155 (special methods, class/static methods). Read Slatkin Ch.7 pp. 230–234 (Item 52: `@classmethod` polymorphism for generic construction). Read the Python Descriptor HowTo Guide online (the section on classmethod/staticmethod internals). Key insight: Python methods are descriptors. A regular function stored in a class's `__dict__` becomes a bound method when accessed through an instance via `function.__get__`. `@classmethod` and `@staticmethod` are built-in descriptors that alter this binding. `@classmethod` passes the class as the first argument — enabling factory patterns and inheritance-aware constructors (Item 52: `@classmethod` on a base class returns instances of whatever subclass calls it). `@staticmethod` passes nothing — it is equivalent to a plain function in the class namespace. Understanding the descriptor protocol is key to understanding how all three work. |
| 2.4 | 15 min | **Comparison.** Map concepts across languages: Rust `fn new() -> Self` = Java static factory method = Python `@classmethod`. Rust `&self` method = Java instance method = Python regular method. Rust has no equivalent of Java's static fields — use module-level constants or `lazy_static!`/`once_cell`. Python's `@classmethod` is unique: it enables polymorphic construction that respects inheritance, something that Rust and Java achieve differently (Rust via trait associated functions, Java via generics or reflection). |

---

### Session 3 — Inheritance and Composition

**Goal:** understand why Rust explicitly rejects inheritance, how Java uses single inheritance plus interfaces, and how Python's multiple inheritance works with C3 linearization — and why composition is increasingly preferred across all three.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 30 min | **Rust: no inheritance, composition via traits and embedding.** Read Klabnik Ch.17 pp. 375–396 (OOP features, trait objects, when to use trait objects vs enums). Read Gjengset Ch.3 pp. 37–56 (designing interfaces, API design with traits). Key insight: Rust has no struct inheritance. Code reuse comes from: (1) trait default methods, (2) generic functions with trait bounds, (3) composition (struct contains another struct), (4) `Deref` coercion (delegation pattern). The deliberate absence of inheritance avoids the fragile base class problem, diamond inheritance, and tight coupling between parent and child. Rust's philosophy is that data definition (structs) and behavior definition (traits) are orthogonal — any struct can implement any trait, and traits can be implemented for existing types (subject to the orphan rule). |
| 3.2 | 30 min | **Java: single inheritance, interfaces, sealed hierarchies.** Read Bloch Ch.4 pp. 90–115 (Items 18–25: favor composition, design for inheritance, prefer interfaces, tagged classes vs class hierarchies). Read Horstmann Ch.5 pp. 70–82 (inheritance, `Object` class, abstract classes, sealed classes). Read Evans Ch.3 pp. 60–77 (sealed types with interfaces). Key insight: Bloch's Item 18 ("Favor composition over inheritance") is one of the most influential pieces of Java design advice. Java allows single class inheritance but multiple interface inheritance. Sealed classes (Java 17+, JEP 409) restrict which classes can extend a type — `sealed interface Shape permits Circle, Rectangle, Triangle` — enabling exhaustive pattern matching in `switch`. The evolution from inheritance-heavy design (pre-2000) to composition-heavy + sealed-type design mirrors Rust's philosophy. Abstract classes provide partial implementation with state; interfaces provide stateless contracts with default methods. |
| 3.3 | 25 min | **Python: multiple inheritance, MRO, and mixins.** Read Ramalho Ch.14 pp. 487–518 (full chapter: subclassing pitfalls, multiple inheritance, C3 linearization, mixins, `__init_subclass__`). Read Viafore Ch.12 pp. 171–185 (Liskov Substitution, composition over inheritance). Read Slatkin Ch.7 pp. 235–244 (Item 53: `super()` and MRO; Item 54: mix-in classes). Key insight: Python supports unrestricted multiple inheritance. The C3 linearization algorithm determines the Method Resolution Order — accessible via `cls.__mro__`. `super()` follows the MRO, not the parent class — in a diamond hierarchy, `super().method()` delegates to the next class in the MRO, which may not be the direct parent. Mixins are a Python pattern for composition: small classes that provide a single piece of reusable functionality (e.g., `JSONMixin`). Slatkin's Item 54 shows how mixins combine the benefits of code reuse with the safety of composition. |
| 3.4 | 15 min | **Composition vs inheritance comparison.** Design a logging + serializable entity in all three languages. Rust: use traits (`impl Log for Entity`, `impl Serialize for Entity`) + composition. Java: use interfaces + delegation (or sealed class hierarchy). Python: use multiple inheritance with mixins (`class Entity(LogMixin, SerializeMixin)`). Compare the tradeoffs: Rust's approach is the most explicit (each trait implementation is separate); Java's approach is evolving from inheritance to sealed types; Python's approach is the most flexible but risks MRO complexity. |

---

### Session 4 — Interfaces, Traits, Protocols: Abstract Polymorphism

**Goal:** master the three core abstraction mechanisms for defining shared behavior contracts — Rust traits (the foundation of the entire type system), Java interfaces (evolved from simple contracts to rich abstractions), Python protocols (bridging duck typing with static analysis).

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: traits as the universal abstraction.** Read Blandy Ch.11 pp. 235–263 (trait definition, default methods, trait bounds, trait objects, static vs dynamic dispatch, associated types, `impl Trait`). Read Klabnik Ch.10 pp. 200–213 (traits, trait bounds). Key insight: traits are Rust's only mechanism for polymorphism. They support: default method implementations, associated types (`type Item`), supertraits (`trait B: A`), generic methods, and conditional implementation (`impl<T: Display> ToString for T`). The orphan rule prevents implementing foreign traits on foreign types — this ensures global coherence (no conflicting implementations). Traits are used for everything: operator overloading (`Add`, `Mul`), conversion (`From`, `Into`), iteration (`Iterator`), memory management (`Drop`), thread safety (`Send`, `Sync`). Understanding traits is understanding Rust. |
| 4.2 | 30 min | **Java: interfaces, abstract classes, default methods.** Read Horstmann Ch.5 pp. 74–82 (abstract classes, `Object` methods). Read Horstmann Ch.6 pp. 85–92 (interfaces, default methods). Read Bloch Ch.4 pp. 100–115 (interfaces over abstract classes, skeletal implementations). Key insight: Java interfaces evolved from pure abstract contracts (pre-Java 8) to supporting default methods, private methods, and static methods. Abstract classes provide partial implementation with state — they can have fields and constructors. The "skeletal implementation" pattern (`AbstractList`, `AbstractSet`) combines interface + abstract class. Sealed interfaces restrict implementors for exhaustive matching. The key difference from Rust: Java interfaces participate in subtype polymorphism (an `ArrayList` **is-a** `List`), while Rust traits participate in bounded parametric polymorphism (a function accepts any `T: Display`). |
| 4.3 | 30 min | **Python: duck typing, ABCs, and typing.Protocol.** Read Ramalho Ch.13 pp. 431–486 (duck typing, goose typing, ABCs, virtual subclasses, `typing.Protocol`). Read Viafore Ch.13 pp. 187–197 (structural subtyping, composite protocols, `@runtime_checkable`). Read Slatkin Ch.7 pp. 205–216 (Item 49: polymorphism over `isinstance`; Item 50: `functools.singledispatch`). Key insight: Python has three layers of polymorphism. (1) Duck typing — no declaration needed; if it has `__len__`, it is a "sized" object. (2) ABCs (`abc.ABC` + `@abstractmethod`) — explicit contracts with enforcement at instantiation time; virtual subclasses (`register()`) allow retroactive conformance. (3) `typing.Protocol` (PEP 544) — structural subtyping for static checkers; satisfies a Protocol by having the right methods without inheriting from it. `@runtime_checkable` makes Protocols work with `isinstance()`. Slatkin's Item 50 adds a fourth option: `functools.singledispatch` for function-based dispatch without class hierarchies. |
| 4.4 | 15 min | **Three-way mapping.** Rust trait ≈ Java interface ≈ Python Protocol (structural). Compare retroactive implementation: Rust can `impl` a trait for any type (subject to orphan rules); Java requires modifying the class or using adapter/wrapper; Python Protocol works retroactively by design. Compare multiple implementation: Rust allows multiple traits, Java allows multiple interfaces, Python supports multiple ABCs and Protocols. Note the fundamental difference: Rust and Python Protocols are structural (satisfaction checked by shape), while Java interfaces are nominal (satisfaction declared by `implements`). |

---

### Session 5 — Dynamic Dispatch: Vtables, Trait Objects, Virtual Methods

**Goal:** understand the low-level mechanisms of dynamic dispatch — Rust's explicit `dyn Trait` with fat pointers and vtables, Java's implicit virtual dispatch with vtables and interface tables, Python's `__dict__` lookup chain.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 35 min | **Rust: trait objects, fat pointers, and vtable layout.** Read Klabnik Ch.17 pp. 375–396 (trait objects, `dyn Trait`, object safety rules). Read Gjengset Ch.2 pp. 25–35 (traits and dispatch, dynamically sized types, wide pointers, coherence). Read the Rustonomicon section on dynamically sized types online. Key insight: `dyn Trait` creates a trait object — a fat pointer containing (1) a pointer to the data and (2) a pointer to the vtable. The vtable is a static array of function pointers for each method in the trait, plus the type's `size`, `alignment`, and destructor. Object safety rules restrict which traits can become trait objects: no associated functions without `self`, no generic methods, no `Self` in return position (because the vtable cannot represent an unknown return type). The programmer explicitly chooses between static dispatch (`impl Trait` / generics → monomorphized at compile time, zero overhead) and dynamic dispatch (`dyn Trait` → one pointer indirection, no inlining). |
| 5.2 | 30 min | **Java: virtual method dispatch and devirtualization.** Read Evans Ch.4 pp. 95–117 (bytecode, virtual method invocation, reflection). Read Evans Ch.17 pp. 571–590 (method invocation types, `invokedynamic`, method handles). Read Aleksey Shipilev's JVM Anatomy Quark #16 (megamorphic virtual calls) online. Key insight: in Java, all non-private, non-static, non-final methods are virtual by default. The JVM maintains a vtable per class and an itable (interface method table) for each implemented interface. `invokevirtual` uses an index into the vtable for O(1) dispatch. `invokeinterface` searches the itable (slightly slower). HotSpot's JIT performs devirtualization: monomorphic call sites (one type seen) are inlined directly; bimorphic sites (two types) use a type check + branch; megamorphic sites (3+ types) fall back to full vtable lookup. This means Java pays the virtual dispatch cost only when the JIT cannot optimize — in practice, most call sites are monomorphic. |
| 5.3 | 25 min | **Python: attribute lookup, `__dict__`, and MRO-based dispatch.** Read Martelli Ch.4 pp. 145–169 (attribute access, `__getattribute__`, descriptors, `__getattr__`). Read the Python Descriptor HowTo Guide online. Key insight: Python method dispatch is a dictionary lookup chain. When you call `obj.method()`, Python calls `type(obj).__getattribute__(obj, 'method')`, which searches: (1) data descriptors in `type(obj).__mro__`, (2) `obj.__dict__`, (3) non-data descriptors in `type(obj).__mro__`. This is O(n) in MRO depth, not O(1) like vtable dispatch. CPython optimizes with type attribute caches (version-tagged) — the cache is invalidated when a class is modified. Despite caching, Python's dispatch is fundamentally slower than vtable-based dispatch but offers maximum flexibility: methods can be added, removed, or replaced at runtime on any class or instance. |
| 5.4 | 15 min | **Dispatch performance comparison.** Compare: Rust static dispatch (zero cost, inlinable, code duplication via monomorphization) vs Rust `dyn Trait` (one pointer indirection, no inlining) vs Java virtual dispatch (one indirection, JIT can devirtualize and inline) vs Python dict lookup (MRO traversal, cached but still slower). Note the design spectrum: Rust makes the cost explicit in the type system (`impl` vs `dyn`); Java hides it but the JIT optimizes aggressively; Python pays the highest cost but gains the ability to modify behavior at runtime. The tradeoff is static guarantees vs dynamic flexibility. |

---

### Session 6 — Method Resolution Order and Coherence Rules

**Goal:** understand how each language resolves ambiguity when multiple implementations exist — Rust's coherence rules and orphan rule, Java's single-inheritance resolution with default method conflict rules, Python's C3 linearization algorithm.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **Rust: coherence, orphan rule, and blanket implementations.** Read Gjengset Ch.2 pp. 30–35 (coherence, orphan rule). Read Gjengset Ch.3 pp. 40–50 (API design with traits, object safety). Read Rust RFC 2451 (re-rebalancing coherence) and the Rust Reference section on trait implementations online. Key insight: Rust's coherence rules ensure that for any type + trait combination, there is at most one implementation visible anywhere in the program. The orphan rule: you can implement a trait for a type only if your crate owns either the trait or the type (with nuances for `#[fundamental]` types like `&T` and `Box<T>`, and uncovered generic parameters). Blanket implementations (`impl<T: Display> ToString for T`) apply to all types that satisfy the bound. These rules prevent the "diamond problem" — there is no ambiguity because there can be at most one `impl` of any trait for any type. The cost is reduced flexibility: you cannot implement a foreign trait for a foreign type without the newtype pattern. |
| 6.2 | 30 min | **Java: method resolution with single inheritance and interfaces.** Read Horstmann Ch.5 pp. 74–82 (method resolution, overriding, `Object` methods). Read the JLS sections on method invocation expressions (JLS 15.12) and interface multiple inheritance (JLS 9.4) online. Key insight: Java resolves methods through the class hierarchy first (single inheritance path), then interfaces. Three rules handle conflicts: (1) Class methods always win over interface default methods ("class wins" rule). (2) If two interfaces provide default methods with the same signature and neither is more specific, the implementing class must override to resolve the conflict — otherwise compilation fails. (3) A more specific interface method wins over a less specific one (sub-interface methods override super-interface methods). Java avoids the complexity of C3 linearization by restricting class inheritance to single inheritance — the method lookup path is always a simple linear chain from subclass to `Object`. |
| 6.3 | 25 min | **Python: C3 linearization and super().** Read Ramalho Ch.14 pp. 497–518 (MRO, C3 linearization, `super()`, cooperative multiple inheritance). Read Slatkin Ch.7 pp. 235–239 (Item 53: initialize parent classes with `super()`). Read Michele Simionato's "The Python 2.3 Method Resolution Order" online. Key insight: Python's C3 linearization algorithm produces a consistent method resolution order for multiple inheritance that respects two constraints: (1) subclasses come before superclasses, (2) the order of base classes in the class definition is preserved. If no consistent ordering exists, Python raises `TypeError` at class creation time. `super()` delegates to the next class in the MRO, not the parent class — this enables cooperative multiple inheritance where each class calls `super()` to chain behavior. In a diamond `D(B, C)` where both `B` and `C` inherit from `A`, the MRO is `[D, B, C, A]` — `B.method()` calling `super().method()` goes to `C`, not `A`. |
| 6.4 | 15 min | **Comparison.** Write a diamond inheritance scenario in Python (`class D(B, C)` where both `B` and `C` inherit from `A`). Show the MRO with `D.__mro__`. Explain why this scenario is impossible in Rust (no inheritance; traits do not form inheritance hierarchies; trait coherence prevents conflicting implementations) and how Java handles the interface equivalent (explicit override required when two interfaces provide conflicting default methods). Note the fundamental difference: Rust prevents ambiguity at compile time via coherence rules; Java prevents it via the single-inheritance + conflict resolution rules; Python resolves it algorithmically via C3 linearization. |

---

### Session 7 — Operator Overloading

**Goal:** compare the three radically different approaches to operator overloading — Rust's trait-based system (operators are traits in `std::ops`), Java's near-absence of operator overloading, Python's dunder-method system.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 30 min | **Rust: operators as traits in `std::ops`.** Read Blandy Ch.12 pp. 265–280 (arithmetic operators, bitwise, unary, comparison, `Index`/`IndexMut`). Read Klabnik Ch.19 pp. 430–440 (operator overloading via associated types, default generic type parameters). Key insight: in Rust, every operator is a trait. `a + b` desugars to `Add::add(a, b)`. This means: (1) you can overload operators for any type by implementing the trait, (2) the return type can differ from the input types via the associated type `Output`, (3) you can implement operators for references (`impl Add for &Vec2`), (4) the orphan rule ensures you cannot overload operators for types you do not own. Comparison uses `PartialEq`/`Eq` and `PartialOrd`/`Ord` — the distinction between `Partial` and full is meaningful (floating-point `NaN` is not equal to itself, so `f64` implements `PartialEq` but not `Eq`). All comparison traits can be `#[derive]`d. |
| 7.2 | 25 min | **Java: no operator overloading (almost).** Read Bloch Ch.3 pp. 37–71 (`equals`, `hashCode`, `toString`, `clone`, `compareTo` contracts). Read Valeev Ch.7 pp. 177–212 (`equals`/`hashCode`/`compareTo` pitfalls). Key insight: Java deliberately chose not to support operator overloading (unlike C++). The only "overloaded" operator is `+` for String concatenation (handled by the compiler, compiled to `StringBuilder` or `invokedynamic` since Java 9). Comparison must use `equals()` (not `==`, which checks reference identity), `compareTo()` for ordering, and `hashCode()` for hash-based collections. The contract between `equals` and `hashCode` (equal objects must have equal hash codes) is a constant source of bugs — Valeev documents dozens of common mistakes. Java's choice limits DSL expressiveness but avoids the readability problems that C++ operator overloading can cause. |
| 7.3 | 25 min | **Python: dunder methods for everything.** Read Ramalho Ch.16 pp. 561–590 (unary operators, infix operators, rich comparison, augmented assignment, reflected operators). Read Ramalho Ch.12 pp. 397–430 (special methods for sequences: `__getitem__`, `__len__`, `__contains__`). Key insight: Python operators are dunder methods: `+` is `__add__`, `[]` is `__getitem__`, `in` is `__contains__`, `len()` is `__len__`. Python supports reflected operators (`__radd__` is tried when the left operand's `__add__` returns `NotImplemented`). Augmented assignment operators (`__iadd__`) enable in-place mutation for mutable types. The `@functools.total_ordering` decorator generates all six comparison methods from `__eq__` and one ordering method (e.g., `__lt__`). Python's operator overloading is pervasive — it is the foundation of the data model, not an optional feature. |
| 7.4 | 20 min | **Comparison.** Implement a `Vector2D` type with `+`, `-`, `*` (scalar), `==`, and `<` in all three languages. Rust: implement `Add`, `Sub`, `Mul<f64>`, `PartialEq`, `PartialOrd`. Java: implement `add()`, `subtract()`, `multiply()`, `equals()`, `compareTo()` named methods (no operator syntax). Python: implement `__add__`, `__sub__`, `__mul__`, `__eq__`, `__lt__` with `@total_ordering`. Note how Rust ties operators to the type system (each operator is a trait with an `Output` associated type), Python makes operators a convention (any class can define `__add__`), and Java avoids operators entirely, requiring named methods for all operations. |

---

### Session 8 — Data Classes, Records, and Derive

**Goal:** understand how each language reduces boilerplate for data-carrying types — Rust's `#[derive]` macro system, Java's records, Python's `@dataclass` — and the different levels of auto-generation each provides.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 30 min | **Rust: `#[derive]` and derivable traits.** Read Blandy Ch.9 pp. 200–209 (deriving common traits). Read Matthews Ch.4 pp. 65–80 (data structures, derive macros, `From`/`Into` conversions). Read the Rust By Example "Derive" page online. Key insight: `#[derive(Debug, Clone, PartialEq, Eq, Hash)]` auto-generates trait implementations based on the struct's fields. The derive macro system is extensible — crates like `serde` add `#[derive(Serialize, Deserialize)]`. Standard derivable traits: `Debug`, `Clone`, `Copy`, `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, `Default`. Derive macros are procedural macros that generate code at compile time — zero runtime cost. Unlike Java records or Python `@dataclass`, Rust's `#[derive]` is opt-in per trait: you choose exactly which capabilities to generate, and you can manually implement any trait to customize behavior. |
| 8.2 | 25 min | **Java: records and their design.** Read Evans Ch.3 pp. 55–65 (records as nominal tuples). Read Horstmann Ch.4 pp. 63–68 (records as data carriers). Read JEP 395 (Records) online. Key insight: Java records (`record Point(double x, double y) {}`) auto-generate: canonical constructor, component accessor methods (not `getX()`/`getY()` — just `x()` and `y()`), `equals()`, `hashCode()`, and `toString()`. Records are `final` (cannot be extended), their fields are `final` (immutable), and they cannot extend classes (but can implement interfaces). Records are "transparent carriers for shallowly immutable data" — their API is entirely determined by their components. You can customize the canonical constructor (compact constructor syntax for validation), add methods, and implement interfaces. Compared to Rust's derive, records are all-or-nothing: you get a fixed set of generated methods. Compared to Python's `@dataclass`, records are a language-level feature, not a decorator. |
| 8.3 | 25 min | **Python: @dataclass, NamedTuple, and attrs.** Read Ramalho Ch.5 pp. 163–200 (`collections.namedtuple`, `typing.NamedTuple`, `@dataclass`, field options, `__post_init__`). Read Viafore Ch.9 pp. 123–134 (dataclass vs dict vs TypedDict vs namedtuple). Read Slatkin Ch.7 pp. 217–229, 250–259 (Item 51: dataclasses for lightweight classes; Item 56: dataclasses for immutable objects). Key insight: `@dataclass` auto-generates `__init__`, `__repr__`, `__eq__` (and optionally `__hash__`, `__lt__`/`__le__`/`__gt__`/`__ge__` with `order=True`). `frozen=True` makes instances immutable by preventing attribute assignment. Fields support defaults, default factories (`field(default_factory=list)`), and metadata. `__post_init__` runs after `__init__` for derived field computation. `typing.NamedTuple` is lighter-weight and immutable by nature. Third-party `attrs` (predecessor to `@dataclass`) offers more features (validators, converters, slots). PEP 681 (Data Class Transforms) enables libraries like Pydantic to act as dataclass-like decorators recognized by type checkers. |
| 8.4 | 20 min | **Comparison.** Create `Person(name: str, age: int, email: str)` in all three languages with equality, hashing, string representation, and immutability. Rust: `#[derive(Debug, Clone, PartialEq, Eq, Hash)]` struct — immutable unless declared `mut`. Java: `record Person(String name, int age, String email)` — immutable by design, all methods auto-generated. Python: `@dataclass(frozen=True)` — immutable via `frozen`, equality and repr auto-generated, hashable because frozen. Compare: what is generated automatically, what requires explicit annotation, what is customizable. Note the philosophical differences: Rust's derive is compile-time code generation with opt-in granularity; Java's records are a language-level construct with fixed semantics; Python's `@dataclass` is a runtime decorator with extensive configuration options. |

---

### Session 9 — Pattern Matching

**Goal:** compare pattern matching across all three languages — Rust's exhaustive `match` as a core language feature, Java's evolving pattern matching for `switch`, Python's structural pattern matching (`match`/`case`).

| Step | Time | Activity |
|------|------|----------|
| 9.1 | 30 min | **Rust: match, if let, while let, and advanced patterns.** Read Blandy Ch.10 pp. 211–233 (enums and patterns, generic enums). Read Klabnik Ch.6 pp. 103–117 (`match`, `if let`). Read Klabnik Ch.19 pp. 440–458 (advanced patterns: `@` bindings, match guards, `..`, nested patterns, ref patterns). Read the Rust Reference "Patterns" section online. Key insight: Rust's `match` is exhaustive — the compiler ensures all variants are handled, or `_` is used as a wildcard. Patterns destructure enums, structs, tuples, and references. `if let` handles a single pattern concisely. Match guards (`if condition` after a pattern) add conditional logic. `@` bindings capture values while testing structure (`e @ 1..=5`). Irrefutable patterns (in `let`, function parameters) always match; refutable patterns (in `match`, `if let`) may not. Pattern matching is Rust's primary mechanism for working with enums (algebraic data types) — it replaces the Visitor pattern entirely. |
| 9.2 | 30 min | **Java: pattern matching for instanceof and switch.** Read Evans Ch.3 pp. 65–77 (pattern matching with `instanceof`, switch expressions). Read Horstmann Ch.5 pp. 76–82 (sealed classes with pattern matching). Read JEP 394 (Pattern Matching for instanceof), JEP 440 (Record Patterns), and JEP 441 (Pattern Matching for switch) online. Key insight: Java's pattern matching evolved across multiple releases. Pattern matching for `instanceof` (Java 16): `if (obj instanceof String s)` binds `s` in the true branch. Record patterns (Java 21): `if (obj instanceof Point(var x, var y))` destructures records. Pattern matching for `switch` (Java 21): exhaustive switch over sealed hierarchies with guarded patterns (`case Circle c when c.radius() > 0`). Null handling: `case null` is now a valid switch label. Combined with sealed interfaces and records, Java's pattern matching enables encoding algebraic data types: `sealed interface Shape permits Circle, Rectangle` + `switch (shape) { case Circle c -> ...; case Rectangle r -> ...; }` — exhaustiveness is compiler-verified. |
| 9.3 | 25 min | **Python: structural pattern matching (match/case).** Read Slatkin Ch.1 pp. 30–39 (Item 9: `match` for destructuring). Read PEP 636 (tutorial) and PEP 634 (specification) online. Read Viafore Ch.8 pp. 111–121 (enums). Key insight: Python 3.10 added `match`/`case` (PEP 634). Pattern types: literal, capture, wildcard (`_`), class patterns (`case Point(x=0, y=y)`), sequence patterns (`case [first, *rest]`), mapping patterns (`case {"action": "move", "x": x}`), OR patterns (`|`), guard clauses (`if condition`). Pattern matching is NOT exhaustive — Python does not enforce that all cases are covered (unlike Rust). Class patterns use `__match_args__` to map positional arguments to attributes; `@dataclass` and `NamedTuple` set `__match_args__` automatically. Python's `match` is structural (matches on shape), not nominal (does not require inheritance), similar to Python's duck typing philosophy. |
| 9.4 | 15 min | **Comparison.** Implement a simple expression evaluator with `Add`, `Mul`, `Lit` nodes using pattern matching in all three languages. Rust: `enum Expr { Lit(i64), Add(Box<Expr>, Box<Expr>), Mul(Box<Expr>, Box<Expr>) }` with `match`. Java: `sealed interface Expr permits Lit, Add, Mul` with records and `switch`. Python: `@dataclass` classes with `match`/`case`. Compare: exhaustiveness checking (Rust: enforced at compile time; Java: enforced for sealed types in switch; Python: not enforced), destructuring depth (all three support nested destructuring), and ergonomics. Note how pattern matching over sealed type hierarchies brings all three languages toward the same expressive power, despite very different type system foundations. |

---

### Session 10 — Synthesis: Design Patterns Across All Three Languages

**Goal:** apply all previous sessions' knowledge to see how classic design patterns (Strategy, Visitor, Observer, Builder) are expressed idiomatically in each language, and understand how each language's object model shapes — or eliminates — traditional OOP patterns.

| Step | Time | Activity |
|------|------|----------|
| 10.1 | 30 min | **Strategy and Visitor patterns.** Read Naftalin & Wadler Ch.6 pp. 81–90 (design patterns with generics: Visitor, Strategy, Observer, Factory). Read the Rust Design Patterns book "Behavioural Patterns" section online. Key insight: Strategy in Rust is a closure or trait object (`Box<dyn Fn(...)>` or a generic parameter `F: Fn(...)`), in Java is a functional interface/lambda (e.g., `Comparator<T>`), in Python is a first-class function passed as an argument. Visitor in Rust is typically eliminated entirely by `enum` + `match` — the "sealed" sum type handles all cases with exhaustive pattern matching. In Java, Visitor traditionally uses interfaces and double dispatch, but sealed classes + pattern matching in `switch` (Java 21+) now offer a direct alternative. In Python, Visitor can use `functools.singledispatch` or `match`/`case`. The Visitor pattern exists because languages historically lacked pattern matching on closed type hierarchies — Rust's enums solve the underlying problem directly. |
| 10.2 | 25 min | **Builder and Newtype patterns.** Read the Rust Design Patterns book "Builder" and "Newtype" patterns online. Key insight: Builder in Rust uses method chaining with `self` consumption — move semantics enforce that the builder is used linearly, preventing partial construction bugs at compile time. In Java, Builder is a separate static inner class (Bloch Item 2) — more verbose but handles optional parameters well. In Python, Builder is often unnecessary — keyword arguments with defaults and `@dataclass` serve the same purpose. Newtype in Rust (`struct Meters(f64)`) provides zero-cost type safety — the wrapper is erased at compile time. In Java, records can serve as newtypes (`record Meters(double value) {}`), though with some overhead before Project Valhalla. In Python, `typing.NewType` is purely a typing construct with no runtime enforcement. |
| 10.3 | 30 min | **Observer and State patterns.** Read Slatkin Ch.7 pp. 260–264 (Item 57: inherit from `collections.abc` for custom containers). Read Slatkin Ch.8 pp. 285–298 (Items 62–63: `__init_subclass__` for registration/plugin patterns). Key insight: Observer in Rust uses `Vec<Box<dyn Fn(Event)>>` or channels (`mpsc::Sender`) — ownership rules prevent dangling observer references by construction. In Java, Observer uses listener interfaces (e.g., `ActionListener`) or `Flow` (reactive streams). In Python, Observer can use callback lists, `__init_subclass__` for automatic registration (Slatkin Item 63), or third-party signal libraries. State pattern: Rust can encode states as types (type-state pattern) with compile-time state transition validation — illegal transitions are type errors. Java uses interface + concrete state classes. Python uses duck typing or enum-based state machines. |
| 10.4 | 20 min | **Final synthesis and cross-language mapping table.** Create a comprehensive table with rows = all major concepts (struct/class, inheritance, trait/interface/protocol, static dispatch, dynamic dispatch, MRO/coherence, operator overloading, data classes, pattern matching) and columns = Rust/Java/Python. For each cell, note the mechanism, the key tradeoff, and the idiomatic approach. Identify the meta-pattern: Rust eliminates many traditional design patterns through its type system (enums eliminate Visitor, closures eliminate Strategy, ownership prevents Observer memory leaks, type-state prevents invalid State transitions); Java is evolving toward Rust's approach (sealed classes, records, pattern matching); Python offers maximum flexibility at the cost of static guarantees but compensates with `typing.Protocol` and `match`/`case` for optional static analysis. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Classes, structs, objects | Klabnik 85–102, Blandy 193–209, McNamara 77–95, Horstmann 55–68, Bloch 73–90, Ramalho 3–20, Martelli 115–135, Viafore 135–145 | Rust Reference implementations, JEP 395 (Records), Python Data Model docs |
| 2 | Methods, associated functions, static vs instance | Klabnik 93–102, Blandy 196–209, Horstmann 85–92, Evans 571–590, Martelli 140–155, Slatkin 230–234 | Rust Reference associated items, JLS 8.4.3.2, Python Descriptor HowTo |
| 3 | Inheritance and composition | Klabnik 375–396, Gjengset 37–56, Bloch 90–115, Horstmann 70–82, Evans 60–77, Ramalho 487–518, Viafore 171–185, Slatkin 235–244 | Rust Blog traits (2015), JEP 409 (Sealed Classes), PEP 3135 |
| 4 | Interfaces, traits, protocols | Blandy 235–263, Klabnik 200–213, Horstmann 74–92, Bloch 100–115, Ramalho 431–486, Viafore 187–197, Slatkin 205–216 | Rust Reference trait objects, JLS Ch.9, PEP 544, PEP 3119 |
| 5 | Dynamic dispatch: vtables, trait objects, virtual methods | Klabnik 375–396, Gjengset 25–35, Evans 95–117 + 571–590, Martelli 145–169 | Rustonomicon DSTs, Shipilev Anatomy Quark #16, JVM Spec invokevirtual |
| 6 | Method resolution order and coherence | Gjengset 30–50, Horstmann 74–82, Ramalho 497–518, Slatkin 235–239 | Rust RFC 2451, JLS 15.12 + 9.4, Simionato MRO article |
| 7 | Operator overloading | Blandy 265–280, Klabnik 430–440, Bloch 37–71, Valeev 177–212, Ramalho 397–430 + 561–590 | std::ops docs, JLS 15.18.1, PEP 207, Python numeric types docs |
| 8 | Data classes, records, derive | Blandy 200–209, Matthews 65–80, Evans 55–65, Horstmann 63–68, Ramalho 163–200, Viafore 123–134, Slatkin 217–259 | Rust By Example derive, JEP 395, PEP 557, PEP 681 |
| 9 | Pattern matching | Blandy 211–233, Klabnik 103–117 + 440–458, Evans 65–77, Horstmann 76–82, Viafore 111–121, Slatkin 30–39 | Rust Reference patterns, JEP 394/440/441, PEP 634/636 |
| 10 | Synthesis: design patterns | Naftalin & Wadler 81–90, Slatkin 260–264 + 285–298, all previous sessions | Rust Design Patterns book, Refactoring Guru |

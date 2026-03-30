# Layer 2 · Topic 4 — Type System

> Comparative study of Rust, Java, and Python: how each language classifies, constrains, and reasons about data — from primitive scalars through generics and traits to advanced type-level programming.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.3 pp. 31–58 | Data Types — scalar types (integers, floats, bool, char), compound types (tuples, arrays) |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.5 pp. 85–102 | Structs — three variants (named, tuple, unit), methods, associated functions |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.6 pp. 103–117 | Enums — algebraic data types, Option\<T\>, pattern matching with `match` and `if let` |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.10 pp. 181–213 | Generics, Traits, Lifetimes — generic functions/structs, trait bounds, lifetime annotations |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.15 pp. 315–351 | Smart Pointers — Box, Deref, Drop, Rc, RefCell, Weak |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.19 pp. 419–458 | Advanced Traits, Advanced Types — newtype pattern, type aliases, never type `!`, DSTs, associated types, operator overloading |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.3 pp. 43–69 | Basic Types — machine types, pointer types, arrays/vectors/slices, strings, type aliases |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.5 pp. 93–121 | References — shared/mutable references, lifetime parameters, the borrow checker |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.6 pp. 123–142 | Expressions — type casts with `as`, type inference in expressions |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.9 pp. 193–209 | Structs — generic structs, lifetime parameters in structs, deriving common traits |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.10 pp. 211–233 | Enums and Patterns — algebraic data types, generic enums, pattern matching |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.11 pp. 235–263 | Traits and Generics — trait objects, `dyn Trait`, static vs dynamic dispatch, associated types, `impl Trait` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.12 pp. 265–280 | Operator Overloading — via traits (`std::ops`), arithmetic, comparison, Index |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.13 pp. 281–301 | Utility Traits — Drop, Sized, Clone, Copy, Deref/DerefMut, From/Into, ToOwned, Cow, Borrow/AsRef |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91 | Data Structures — String types, slices, arrays, vectors, HashMaps, From/Into, TryFrom/TryInto conversions |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.5 pp. 93–118 | Ownership, Copying — Copy vs Clone, smart pointers (Box, Rc, Arc, RefCell) |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.3 pp. 41–52 | Data Types — primitives (int, double, char, boolean), operators, type conversions, BigInteger/BigDecimal, arrays |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.4 pp. 55–68 | Classes and Objects — constructors, static fields/methods, records (Java 16+), access modifiers |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.5 pp. 70–82 | Inheritance — Object class, equals/hashCode, abstract classes, enums, sealed classes (Java 17+), pattern matching (Java 21+) |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.8 pp. 104–116 | Generic Programming — type parameters, type bounds, erasure, wildcards, PECS, restrictions on generics |
| Java | Bloch (2018) — *Effective Java* | Ch.5 pp. 117–155 | Generics — raw types, unchecked warnings, lists vs arrays, bounded wildcards, PECS principle, typesafe heterogeneous containers |
| Java | Bloch (2018) — *Effective Java* | Ch.6 pp. 157–191 | Enums and Annotations — enum types, methods on enums, EnumSet, EnumMap, annotation types |
| Java | Bloch (2018) — *Effective Java* | Item 61 | Prefer primitive types to boxed primitives — autoboxing pitfalls |
| Java | Evans (2022) — *The Well-Grounded Java Developer* | Ch.1 pp. 3–25 | Enhanced type inference — `var` keyword (Java 10+), local variable type inference |
| Java | Evans (2022) — *The Well-Grounded Java Developer* | Ch.3 pp. 55–77 | Records, Sealed Types, Pattern Matching — `record` types, `sealed` classes/interfaces, `instanceof` pattern matching |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.2 pp. 19–60 | Implicit type conversion in conditionals, type casting pitfalls |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.4 pp. 96–123 | Numeric conversions — widening with precision loss, unconditional narrowing, implicit conversion in compound assignments |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.5 pp. 124–154 | ClassCastException — unsafe casts, generic type safety |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.7 pp. 177–212 | equals() and hashCode() contracts — type correctness in equality |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.3 pp. 33–113 | Data Types — numbers, strings, bytes, tuples, lists, dicts, sets, variables and references, mutability |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.4 pp. 115–169 | Classes — special methods, inheritance, metaclasses, descriptors |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.5 pp. 171–194 | Type Annotations — mypy, pyright, typing module, Generic, Optional, Union, TypeVar, Protocol, TypedDict |
| Python | Ramalho (2022) — *Fluent Python* | Ch.1 pp. 3–20 | Python Data Model — special methods, how Python objects behave |
| Python | Ramalho (2022) — *Fluent Python* | Ch.2 pp. 21–76 | Sequence types — list, tuple, str, bytes; unpacking, slicing |
| Python | Ramalho (2022) — *Fluent Python* | Ch.3 pp. 77–116 | Dict and set types — hashable protocol, dict internals |
| Python | Ramalho (2022) — *Fluent Python* | Ch.4 pp. 117–162 | str vs bytes — text vs binary data, encoding |
| Python | Ramalho (2022) — *Fluent Python* | Ch.5 pp. 163–200 | Data Class Builders — namedtuple, typing.NamedTuple, @dataclass |
| Python | Ramalho (2022) — *Fluent Python* | Ch.6 pp. 201–228 | Object References — mutability, identity vs equality, copies, del |
| Python | Ramalho (2022) — *Fluent Python* | Ch.8 pp. 253–302 | Type Hints in Functions — gradual typing, typing module, @overload |
| Python | Ramalho (2022) — *Fluent Python* | Ch.13 pp. 431–486 | Interfaces, Protocols, ABCs — duck typing, goose typing, typing.Protocol, structural subtyping |
| Python | Ramalho (2022) — *Fluent Python* | Ch.15 pp. 519–560 | More About Type Hints — @overload, TypedDict, generics, variance (covariance/contravariance) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.16 pp. 561–590 | Operator Overloading — unary/infix operators, rich comparison, augmented assignment |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.3 pp. 65–77 | Lists vs Tuples — type implications for performance, memory layout |

### Coverage Gaps

The owned books **do not** cover:

- **Formal type theory foundations** — no book explains the theoretical underpinnings (Hindley-Milner type inference, System F, algebraic type theory) that inform Rust's and Java's type systems; the books are practical, not theoretical
- **Rust's PhantomData and zero-sized types in depth** — Klabnik mentions DSTs and the never type; Blandy covers Sized; but PhantomData usage patterns for variance annotation and type-level state machines are not explored
- **Java Project Valhalla (value types)** — the upcoming fundamental change to Java's type system (inline classes, primitive objects) that will blur the primitive/reference divide is not covered in any owned book
- **Python ParamSpec and Concatenate** — the newer typing constructs for decorators and higher-order function typing (PEP 612) are not covered in Ramalho or Martelli
- **Cross-language variance comparison** — no book compares covariance/contravariance rules across all three languages side by side; Ramalho covers Python variance, Bloch covers Java wildcards, but the Rust lifetime variance story requires the Rustonomicon
- **Refinement types and dependent types** — advanced type system concepts (e.g., types that encode value constraints) are not covered; relevant as context for understanding what Rust's type system cannot express
- **TypeGuard and type narrowing** — Python's TypeGuard (PEP 647) and TypeIs (PEP 742) for custom type narrowing in control flow are not covered in the owned books

---

## External Resources

### Sub-topic 1 — Primitive & Scalar Types

**Rust**
- The Rust Reference — Types: `https://doc.rust-lang.org/reference/types.html`
- The Rust Reference — Scalar Types: `https://doc.rust-lang.org/reference/types/numeric.html`
- Rust By Example — Primitives: `https://doc.rust-lang.org/rust-by-example/primitives.html`

**Java**
- Java Language Specification — Primitive Types and Values: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.2`
- Java Language Specification — Conversions and Contexts: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html`
- Oracle Java Tutorials — Primitive Data Types: `https://docs.oracle.com/javase/tutorial/java/nutsandbolts/datatypes.html`
- Oracle Java Tutorials — Autoboxing and Unboxing: `https://docs.oracle.com/javase/tutorial/java/data/autoboxing.html`

**Python**
- Python docs — Built-in Types: `https://docs.python.org/3/library/stdtypes.html`
- Python docs — Numeric Types: `https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex`
- Python docs — Data Model (objects, values, types): `https://docs.python.org/3/reference/datamodel.html`

### Sub-topic 2 — Composite & Algebraic Types

**Rust**
- The Rust Reference — Struct Types: `https://doc.rust-lang.org/reference/types/struct.html`
- The Rust Reference — Enum Types: `https://doc.rust-lang.org/reference/types/enum.html`
- Rust By Example — Custom Types: `https://doc.rust-lang.org/rust-by-example/custom_types.html`
- Rust By Example — Enums: `https://doc.rust-lang.org/rust-by-example/custom_types/enum.html`

**Java**
- Java Language Specification — Enum Types: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-8.html#jls-8.9`
- JEP 395 — Records: `https://openjdk.org/jeps/395`
- JEP 409 — Sealed Classes: `https://openjdk.org/jeps/409`
- JEP 441 — Pattern Matching for switch: `https://openjdk.org/jeps/441`

**Python**
- Python docs — dataclasses: `https://docs.python.org/3/library/dataclasses.html`
- Python docs — typing.NamedTuple: `https://docs.python.org/3/library/typing.html#typing.NamedTuple`
- Python docs — enum module: `https://docs.python.org/3/library/enum.html`
- PEP 557 — Data Classes: `https://peps.python.org/pep-0557/`

### Sub-topic 3 — Generics & Parametric Polymorphism

**Rust**
- The Rust Reference — Generic Parameters: `https://doc.rust-lang.org/reference/items/generics.html`
- Rust By Example — Generics: `https://doc.rust-lang.org/rust-by-example/generics.html`
- The Rustonomicon — Subtyping and Variance: `https://doc.rust-lang.org/nomicon/subtyping.html`

**Java**
- Java Language Specification — Chapter 4 (Types, Values, Variables): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html`
- Oracle Java Tutorials — Generics: `https://docs.oracle.com/javase/tutorial/java/generics/index.html`
- Oracle Java Tutorials — Wildcards: `https://docs.oracle.com/javase/tutorial/java/generics/wildcards.html`
- Angelika Langer — Java Generics FAQ: `http://www.angelikalanger.com/GenericsFAQ/JavaGenericsFAQ.html`

**Python**
- Python docs — typing module: `https://docs.python.org/3/library/typing.html`
- Python docs — typing.TypeVar: `https://docs.python.org/3/library/typing.html#typing.TypeVar`
- Python docs — typing.Generic: `https://docs.python.org/3/library/typing.html#typing.Generic`
- PEP 484 — Type Hints: `https://peps.python.org/pep-0484/`
- PEP 695 — Type Parameter Syntax (Python 3.12+): `https://peps.python.org/pep-0695/`

### Sub-topic 4 — Traits, Interfaces & Protocols

**Rust**
- The Rust Reference — Traits: `https://doc.rust-lang.org/reference/items/traits.html`
- The Rust Reference — Trait Objects: `https://doc.rust-lang.org/reference/types/trait-object.html`
- Rust By Example — Traits: `https://doc.rust-lang.org/rust-by-example/trait.html`

**Java**
- Java Language Specification — Interfaces: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html`
- JEP 409 — Sealed Classes: `https://openjdk.org/jeps/409`
- Oracle Java Tutorials — Interfaces: `https://docs.oracle.com/javase/tutorial/java/IandI/createinterface.html`

**Python**
- Python docs — abc module: `https://docs.python.org/3/library/abc.html`
- Python docs — typing.Protocol: `https://docs.python.org/3/library/typing.html#typing.Protocol`
- PEP 544 — Protocols: Structural subtyping (static duck typing): `https://peps.python.org/pep-0544/`
- PEP 3119 — Introducing Abstract Base Classes: `https://peps.python.org/pep-3119/`

### Sub-topic 5 — Type Inference & Type Annotations

**Rust**
- The Rust Reference — Type Inference: `https://doc.rust-lang.org/reference/type-system.html`
- Rust By Example — Inference: `https://doc.rust-lang.org/rust-by-example/types/inference.html`

**Java**
- JEP 286 — Local-Variable Type Inference (var): `https://openjdk.org/jeps/286`
- Java Language Specification — Type Inference: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-18.html`

**Python**
- mypy documentation: `https://mypy.readthedocs.io/en/stable/`
- pyright documentation: `https://microsoft.github.io/pyright/`
- PEP 484 — Type Hints: `https://peps.python.org/pep-0484/`
- PEP 526 — Syntax for Variable Annotations: `https://peps.python.org/pep-0526/`
- PEP 563 — Postponed Evaluation of Annotations: `https://peps.python.org/pep-0563/`

### Sub-topic 6 — Type Conversion & Casting

**Rust**
- The Rust Reference — Type cast expressions: `https://doc.rust-lang.org/reference/expressions/operator-expr.html#type-cast-expressions`
- Rust By Example — Casting: `https://doc.rust-lang.org/rust-by-example/types/cast.html`
- Rust By Example — From and Into: `https://doc.rust-lang.org/rust-by-example/conversion.html`
- Rust std docs — std::convert: `https://doc.rust-lang.org/std/convert/index.html`

**Java**
- Java Language Specification — Conversions and Contexts: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html`
- Java Language Specification — Widening Primitive Conversion: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.2`
- Java Language Specification — Narrowing Primitive Conversion: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-5.html#jls-5.1.3`

**Python**
- Python docs — Built-in Functions (int, float, str, etc.): `https://docs.python.org/3/library/functions.html`
- Python docs — Special method names for type conversion: `https://docs.python.org/3/reference/datamodel.html#special-method-names`

### Sub-topic 7 — Advanced Types

**Rust**
- The Rustonomicon — PhantomData: `https://doc.rust-lang.org/nomicon/phantom-data.html`
- The Rustonomicon — Subtyping and Variance: `https://doc.rust-lang.org/nomicon/subtyping.html`
- The Rust Reference — Never type: `https://doc.rust-lang.org/reference/types/never.html`
- The Rust Reference — Dynamically Sized Types: `https://doc.rust-lang.org/reference/dynamically-sized-types.html`
- The Rust Reference — Type aliases: `https://doc.rust-lang.org/reference/items/type-aliases.html`

**Java**
- JEP 218 — Generics over Primitive Types (Valhalla, draft): `https://openjdk.org/jeps/218`
- Java Language Specification — Intersection Types: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.9`
- Java Language Specification — Type Erasure: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.6`

**Python**
- Python docs — typing.TypedDict: `https://docs.python.org/3/library/typing.html#typing.TypedDict`
- Python docs — typing.overload: `https://docs.python.org/3/library/typing.html#typing.overload`
- PEP 612 — Parameter Specification Variables: `https://peps.python.org/pep-0612/`
- PEP 673 — Self Type: `https://peps.python.org/pep-0673/`
- PEP 681 — Data Class Transforms: `https://peps.python.org/pep-0681/`

### Sub-topic 8 — Nullability & Option Types

**Rust**
- Rust std docs — Option: `https://doc.rust-lang.org/std/option/index.html`
- Rust std docs — Result: `https://doc.rust-lang.org/std/result/index.html`
- Rust By Example — Option and unwrap: `https://doc.rust-lang.org/rust-by-example/error/option_unwrap.html`

**Java**
- Java docs — java.util.Optional: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html`
- JEP 358 — Helpful NullPointerExceptions: `https://openjdk.org/jeps/358`

**Python**
- Python docs — typing.Optional: `https://docs.python.org/3/library/typing.html#typing.Optional`
- PEP 484 — Type Hints (None type section): `https://peps.python.org/pep-0484/`
- mypy docs — Optional types and None: `https://mypy.readthedocs.io/en/stable/kinds_of_types.html#optional-types-and-the-none-type`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Rust | Jon Gjengset — *Rust for Rustaceans* (No Starch Press, 2021) | Advanced type system patterns: trait design, generics strategies, PhantomData, variance, type-state pattern, advanced lifetime usage — fills the gap between introductory books and real-world Rust type system mastery |
| Java | Maurice Naftalin & Philip Wadler — *Java Generics and Collections* (O'Reilly, 2006) | The canonical deep dive into Java generics: wildcards, bounds, erasure, PECS, bridge methods, reification — written by the generics specification co-author; despite age, the fundamentals remain accurate |
| Python | Patrick Viafore — *Robust Python* (O'Reilly, 2021) | Dedicated to making Python code more type-safe: typing module deep dive, user-defined types, runtime type checking, design patterns for type safety in a dynamically typed language |
| General | Benjamin C. Pierce — *Types and Programming Languages* (MIT Press, 2002) | The foundational textbook on type theory: type safety proofs, subtyping, polymorphism, type inference algorithms — provides the theoretical framework for understanding why each language's type system works the way it does |
| General | Benjamin C. Pierce — *Advanced Topics in Types and Programming Languages* (MIT Press, 2004) | Covers dependent types, effect systems, linear types (which inspired Rust's ownership), existential types, module systems — deeper theory for understanding the cutting edge of type system design |

---

## Study Plan — 8 Sessions

Estimated total: **16–20 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from primitive types through generics and traits to advanced type-level programming and nullability.

---

### Session 1 — Primitive & Scalar Types

**Goal:** understand how each language represents fundamental data — integers, floats, booleans, characters — and the critical distinction between Rust's zero-cost scalars, Java's primitive/boxed duality, and Python's "everything is an object" model.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: scalar types.** Read Klabnik Ch.3 pp. 31–46 (integer types i8–i128/u8–u128, float types f32/f64, bool, char; integer overflow behavior, type annotations). Then read Blandy Ch.3 pp. 43–55 (machine types, bool, char, pointer types, integer/float details). Key insight: Rust scalars are stack-allocated, zero-overhead machine types with no boxing, no garbage collection, and no implicit conversions. The type system enforces explicit conversions — `let x: i32 = 5; let y: i64 = x;` does not compile. Integer overflow panics in debug mode and wraps in release mode. `char` is always 4 bytes (Unicode scalar value). |
| 1.2 | 30 min | **Java: primitives vs boxed types.** Read Horstmann Ch.3 pp. 41–52 (eight primitives: byte/short/int/long/float/double/char/boolean, operators, type conversions, BigInteger/BigDecimal). Read Bloch Item 61 (prefer primitive types to boxed primitives). Read Valeev Ch.4 pp. 96–110 (widening with precision loss, implicit conversions). Key insight: Java has a dual type system — primitives (int, double, etc.) live on the stack with no object overhead, while boxed types (Integer, Double, etc.) are heap-allocated objects. Autoboxing/unboxing bridges them but introduces subtle bugs: `==` on Integer compares references (not values) for values outside -128..127, and unboxing null throws NullPointerException. Widening conversions (int→long) are implicit but can lose precision (int→float). |
| 1.3 | 25 min | **Python: everything is an object.** Read Martelli Ch.3 pp. 33–55 (numbers: int, float, complex; bool as int subclass; None). Read Ramalho Ch.1 pp. 3–12 (data model, how special methods make objects behave). Read Gorelick Ch.3 pp. 65–70 (how Python stores data vs machine types). Key insight: Python has no primitive types — `int`, `float`, `bool`, `str`, and even `None` are all objects on the heap with reference counts, type pointers, and method tables. `int` has arbitrary precision (no overflow). `bool` is a subclass of `int` (`True + True == 2`). `float` is a C double wrapper. This uniformity simplifies the mental model but adds 28+ bytes overhead per integer object. |
| 1.4 | 15 min | **Cross-language comparison.** Create a comparison table: rows = {integer sizes, float precision, bool representation, char/string unit, implicit conversions, overflow behavior, memory per integer, stack vs heap}, columns = {Rust, Java, Python}. Note the fundamental tradeoff: Rust gives maximum control and zero overhead; Java splits into fast primitives and flexible objects; Python unifies everything as objects at the cost of memory and performance. Read Rust Reference "Types" online for the canonical type list. |

---

### Session 2 — Composite & Algebraic Types

**Goal:** understand how each language composes types into larger structures — structs, classes, records, enums — and how Rust's algebraic data types (sum types + product types) compare to Java's class-based and Python's duck-typed approaches.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **Rust: structs and enums as algebraic types.** Read Klabnik Ch.5 pp. 85–102 (three struct variants: named-field, tuple, unit; methods with `impl`; associated functions). Read Klabnik Ch.6 pp. 103–117 (enums as sum types, variants with data, Option\<T\>, pattern matching with `match` and `if let`). Then read Blandy Ch.9 pp. 193–209 (generic structs, lifetime parameters in structs) and Ch.10 pp. 211–233 (enum design patterns, generic enums like Option and Result). Key insight: Rust's type system is algebraic — structs are product types (all fields present), enums are sum types (exactly one variant active). This means you can model state machines, ASTs, and protocol messages with enums where the compiler guarantees exhaustive handling. There is no null — Option\<T\> (Some(T) or None) forces explicit handling. Rust has no class inheritance; composition via structs + traits replaces it. |
| 2.2 | 30 min | **Java: classes, records, enums, sealed types.** Read Horstmann Ch.4 pp. 55–68 (classes, constructors, records as transparent data carriers). Read Horstmann Ch.5 pp. 70–82 (inheritance, Object class, abstract classes, enums with methods, sealed classes, pattern matching). Read Evans Ch.3 pp. 55–77 (records, sealed types, pattern matching with `instanceof`). Read Bloch Ch.6 pp. 157–175 (enum best practices, EnumSet, EnumMap). Key insight: Java's composite types center on class inheritance. Records (Java 16+) add product types (immutable data carriers). Enums are powerful (can have fields, methods, and per-constant behavior) but are not algebraic sum types — they cannot carry different data per variant like Rust enums. Sealed classes (Java 17+) + pattern matching (Java 21+) move Java toward sum-type expressiveness: `sealed interface Shape permits Circle, Rectangle` with exhaustive `switch` is the closest Java gets to Rust's enum pattern matching. |
| 2.3 | 25 min | **Python: classes, dataclasses, NamedTuple, enum.** Read Ramalho Ch.5 pp. 163–200 (data class builders: collections.namedtuple, typing.NamedTuple, @dataclass — when to use each). Read Martelli Ch.4 pp. 115–135 (classes, special methods, inheritance). Read the Python docs on the `enum` module online. Key insight: Python is maximally flexible — you can create product types via regular classes, @dataclass (auto-generates __init__, __repr__, __eq__), or NamedTuple (immutable). Python's `enum.Enum` is simpler than Java's or Rust's — variants are named constants without associated data. There are no true sum types in Python; the closest approximation is `Union[Circle, Rectangle]` with type checkers enforcing exhaustive handling, or `match` statements (Python 3.10+). |
| 2.4 | 15 min | **Algebraic types comparison.** Map the concepts: product types (Rust struct = Java record/class = Python @dataclass), sum types (Rust enum = Java sealed interface + permits = Python Union + match). Write code for a `Shape` type in all three languages: a sum type with Circle(radius) and Rectangle(width, height), with an `area()` method. Note how Rust enforces exhaustive matching at compile time, Java achieves it with sealed classes + switch, and Python relies on type checker warnings. |

---

### Session 3 — Generics & Parametric Polymorphism

**Goal:** understand the three fundamentally different approaches to generics — Rust's monomorphization (generates specialized code), Java's type erasure (compiles to a single generic version), and Python's runtime-checked type variables.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Rust: monomorphized generics.** Read Klabnik Ch.10 pp. 181–200 (generic functions, generic structs, trait bounds, `where` clauses). Read Blandy Ch.11 pp. 235–250 (generic functions, type parameters, trait bounds, `impl Trait` return types). Key insight: Rust generics are monomorphized — when you write `fn max<T: Ord>(a: T, b: T) -> T`, the compiler generates a separate, fully-optimized function for each concrete type used (e.g., `max_i32`, `max_String`). This means zero runtime cost (no boxing, no vtables, full inlining) but larger binaries. Trait bounds constrain what operations are available on generic types — `T: Display + Clone` means T must implement both traits. Rust generics with trait bounds are equivalent to bounded parametric polymorphism in type theory. |
| 3.2 | 35 min | **Java: type-erased generics.** Read Horstmann Ch.8 pp. 104–116 (type parameters, bounds, erasure, wildcards, restrictions). Read Bloch Ch.5 pp. 117–155 (raw types, unchecked warnings, lists vs arrays, bounded wildcards, PECS principle, typesafe heterogeneous containers). Key insight: Java generics use type erasure — `List<String>` and `List<Integer>` become the same `List<Object>` at runtime, with the compiler inserting casts. This means: (1) no `new T()` or `T.class` at runtime, (2) no primitive type parameters (`List<int>` is illegal — must use `List<Integer>`), (3) arrays are reified but generics are not (hence `List<String>[]` is problematic). The PECS principle (Producer Extends, Consumer Super) governs wildcard usage: `? extends T` for reading, `? super T` for writing. Type erasure was chosen for backwards compatibility with pre-generics Java code. |
| 3.3 | 25 min | **Python: TypeVar and Generic.** Read Martelli Ch.5 pp. 171–185 (typing module, Generic, TypeVar, Optional, Union). Read Ramalho Ch.8 pp. 253–280 (gradual typing, TypeVar, bounded TypeVar, constrained TypeVar). Read Ramalho Ch.15 pp. 519–540 (generic classes, variance in generics). Read PEP 484 and PEP 695 (new type parameter syntax) online. Key insight: Python generics exist only for static type checkers (mypy, pyright) — they have zero effect at runtime. `T = TypeVar('T')` creates a type variable; `class Stack(Generic[T])` creates a generic class. At runtime, `Stack[int]()` and `Stack[str]()` are the same class. Python 3.12+ adds `def foo[T](x: T) -> T` syntax (PEP 695), eliminating the verbose TypeVar declaration. Unlike Rust/Java, Python generics impose no constraints at runtime — they are purely a static analysis tool. |
| 3.4 | 15 min | **Three-way comparison.** Create a feature matrix: rows = {implementation strategy, runtime type info, primitive type params, code generation, binary size impact, boxing overhead, type bounds syntax, variance annotation}, columns = {Rust, Java, Python}. Write a generic `Stack<T>` in all three languages. Note: Rust monomorphization = best performance but largest binary; Java erasure = backwards compatible but lossy; Python typing = purely advisory with no runtime cost or benefit. |

---

### Session 4 — Traits, Interfaces & Protocols

**Goal:** understand how each language defines shared behavior contracts — Rust's traits (the central abstraction mechanism), Java's interfaces (evolved from abstract to rich), and Python's protocols (structural subtyping for a dynamic language).

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: traits, static dispatch, dynamic dispatch.** Read Blandy Ch.11 pp. 235–263 (full chapter: trait definition, default methods, trait bounds, trait objects `dyn Trait`, static vs dynamic dispatch, associated types, `impl Trait`). Read Klabnik Ch.10 pp. 200–213 (traits, trait bounds, lifetimes in trait bounds). Read Blandy Ch.12 pp. 265–280 (operator overloading via `std::ops` traits). Key insight: Traits are Rust's sole abstraction for shared behavior — there are no classes or inheritance. A trait defines a set of methods; types implement traits via separate `impl Trait for Type` blocks (coherence rules prevent conflicting implementations). Static dispatch (`fn foo(x: impl Display)`) monomorphizes; dynamic dispatch (`fn foo(x: &dyn Display)`) uses vtable pointers at runtime. Associated types (`type Item`) and default methods make traits expressive. Orphan rules prevent implementing foreign traits on foreign types. |
| 4.2 | 30 min | **Java: interfaces and sealed hierarchies.** Read Horstmann Ch.5 pp. 74–82 (abstract classes, interfaces, sealed classes). Read Evans Ch.3 pp. 60–77 (sealed types, pattern matching). Read Bloch Ch.6 pp. 175–191 (annotations as marker interfaces alternative). Key insight: Java interfaces have evolved dramatically — from pure abstract contracts (pre-Java 8) to supporting default methods (Java 8), private methods (Java 9), and sealed hierarchies (Java 17). Interfaces support multiple inheritance of type (a class can implement many interfaces) but not of state. Abstract classes provide partial implementation with state. Java uses dynamic dispatch (virtual method invocation) by default — all non-private, non-static methods are virtual. There is no static dispatch equivalent to Rust's monomorphization for interface calls; devirtualization is a JIT optimization. |
| 4.3 | 30 min | **Python: duck typing, ABCs, typing.Protocol.** Read Ramalho Ch.13 pp. 431–486 (comprehensive: duck typing philosophy, ABCs, virtual subclasses, typing.Protocol for structural subtyping). Read Martelli Ch.4 pp. 135–155 (special methods, inheritance). Read PEP 544 (Protocols: Structural subtyping) online. Key insight: Python has three layers of "interface" mechanisms. (1) Duck typing — no declaration needed; if an object has a `read()` method, it is "file-like." (2) ABCs (Abstract Base Classes) — explicit interface declaration with `@abstractmethod`; classes must explicitly inherit from the ABC. (3) `typing.Protocol` (PEP 544) — structural subtyping for static checkers; a class satisfies a Protocol if it has the right methods, without inheriting from it. Protocol bridges duck typing and static type checking — it is "static duck typing." Python's `collections.abc` module provides standard ABCs (Iterable, Sequence, Mapping, etc.). |
| 4.4 | 15 min | **Comparison and synthesis.** Map the concepts: Rust trait = Java interface ≈ Python Protocol (structural). Rust `dyn Trait` ≈ Java interface reference ≈ Python ABC instance. Compare: (1) how each language resolves method calls (Rust static/dynamic explicit choice, Java always virtual except final/private, Python always dynamic dictionary lookup), (2) multiple inheritance (Rust — multiple trait impl, Java — multiple interface impl, Python — multiple class inheritance with C3 MRO), (3) retroactive implementation (Rust — implement trait for existing type, Java — impossible without modifying class, Python — register virtual subclass or rely on Protocol). |

---

### Session 5 — Type Inference & Type Annotations

**Goal:** understand how each language deduces types — Rust's bidirectional inference (strong, pervasive), Java's limited `var` keyword, and Python's gradual typing (optional annotations checked by external tools).

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: pervasive type inference.** Read Klabnik Ch.3 pp. 31–35 (type annotations on variables, when inference needs help). Read Blandy Ch.6 pp. 123–130 (expressions, type inference in context). Read the Rust Reference "Type System" section and Rust By Example "Inference" online. Key insight: Rust uses a bidirectional type inference algorithm influenced by Hindley-Milner. The compiler infers types for local variables, closure parameters, and generic type arguments based on usage context — `let v = Vec::new(); v.push(5);` infers `Vec<i32>`. However, function signatures always require explicit type annotations (no global inference). Turbofish syntax (`::<Type>`) disambiguates when inference fails: `"42".parse::<i32>()`. The inference is local (within a function body) — deliberate design choice for readability and compilation speed. |
| 5.2 | 25 min | **Java: var and limited inference.** Read Evans Ch.1 pp. 3–25 (enhanced type inference, var keyword). Read JEP 286 (Local-Variable Type Inference) online. Read Valeev Ch.2 pp. 19–40 (implicit type conversion surprises in conditionals). Key insight: Java was explicitly typed for decades. Java 10 added `var` for local variable type inference only — `var list = new ArrayList<String>()` infers `ArrayList<String>`. `var` cannot be used for method parameters, return types, or fields. Java also infers generic type arguments (diamond operator `<>` since Java 7) and lambda parameter types. Compared to Rust, Java's inference is much more limited — most types are explicitly declared. This is partly historical (Java predates widespread type inference) and partly by design (enterprise readability). |
| 5.3 | 30 min | **Python: gradual typing with annotations.** Read Martelli Ch.5 pp. 171–194 (full chapter: type annotations, mypy, pyright, typing module). Read Ramalho Ch.8 pp. 253–302 (type hints in functions, gradual typing, when and how to use annotations). Read PEP 484 (Type Hints) and PEP 526 (Variable Annotations) online. Key insight: Python's type system is gradual — annotations are optional, and code runs identically with or without them. `def greet(name: str) -> str:` is a hint for static checkers (mypy, pyright) but has zero runtime effect. mypy infers types for local variables within annotated functions. The gradual typing philosophy means you can add types incrementally to an existing codebase. `reveal_type(x)` (mypy) and `reveal_type(x)` (pyright) show inferred types. The typing module provides all the annotation building blocks: Optional, Union, Literal, TypeGuard, Final, etc. |
| 5.4 | 15 min | **Comparative analysis.** Compare: (1) where inference applies (Rust — locals and generics; Java — var, diamond, lambdas; Python — mypy infers within annotated code), (2) where explicit types are required (Rust — function signatures; Java — fields, parameters, return types; Python — nowhere, all optional), (3) tooling (Rust — built into compiler; Java — built into compiler; Python — external tools mypy/pyright). Note the philosophical spectrum: Rust requires most type information at API boundaries; Java requires types almost everywhere; Python requires types nowhere but benefits from them. |

---

### Session 6 — Type Conversion & Casting

**Goal:** understand how each language converts between types — Rust's explicit trait-based conversions, Java's complex widening/narrowing/autoboxing rules, and Python's constructor-based and magic-method-based coercion.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **Rust: From/Into, TryFrom/TryInto, as.** Read Matthews Ch.4 pp. 80–91 (From/Into, TryFrom/TryInto conversions). Read Blandy Ch.13 pp. 281–301 (utility traits: From, Into, ToOwned, Cow, Borrow, AsRef). Read Blandy Ch.6 pp. 130–142 (type casts with `as`). Key insight: Rust conversions are explicit and trait-based. `as` performs primitive casts (potentially lossy: `300i32 as u8` silently wraps to 44). `From<T>/Into<T>` traits provide infallible conversions (implementing `From` gives you `Into` for free). `TryFrom<T>/TryInto<T>` return `Result` for fallible conversions (e.g., `u32::try_from(-1i32)` returns `Err`). There are no implicit type conversions except for Deref coercion (e.g., `&String` auto-coerces to `&str`). This explicitness prevents the subtle conversion bugs common in Java and C. |
| 6.2 | 30 min | **Java: widening, narrowing, autoboxing.** Read Valeev Ch.4 pp. 96–123 (widening with precision loss, unconditional narrowing, implicit conversion in compound assignments). Read Valeev Ch.5 pp. 124–154 (ClassCastException, unsafe casts). Read Valeev Ch.2 pp. 19–40 (type conversion surprises in conditionals). Read the Java Language Specification Chapter 5 "Conversions and Contexts" online. Key insight: Java has complex implicit conversion rules. Widening primitive conversions (int→long) are safe but int→float can lose precision silently. Narrowing conversions require explicit casts (`(byte)256` wraps silently). Autoboxing/unboxing (int↔Integer) adds another dimension — compound assignment `Integer i = 0; i += 1;` involves unbox, add, box. Reference casting (`(String)obj`) can throw ClassCastException at runtime. The interaction between generics type erasure and casts creates "unchecked cast" warnings that can mask actual type errors. |
| 6.3 | 25 min | **Python: constructors and special methods.** Read Martelli Ch.3 pp. 45–55 (type constructors: int(), float(), str(), bool()). Read Ramalho Ch.16 pp. 561–590 (operator overloading, __int__, __float__, __bool__, __str__, __repr__). Read Ramalho Ch.6 pp. 201–228 (object references, identity vs equality). Key insight: Python has no implicit type coercion between unrelated types — `"3" + 4` raises TypeError, unlike JavaScript. Conversion uses type constructors: `int("42")`, `float(3)`, `str(42)`. Special methods enable custom conversions: `__int__()`, `__float__()`, `__bool__()`, `__str__()`, `__repr__()`. However, Python does have implicit coercion in arithmetic: `3 + 4.0` promotes to float. `bool()` coercion is pervasive (truthiness: 0, empty containers, None are falsy). The `==` operator uses `__eq__` and can compare across types (1 == 1.0 == True). |
| 6.4 | 15 min | **Comparison: safety spectrum.** Rank the languages by conversion safety: Rust (most explicit — trait-based, compile-time checked) > Java (mix of implicit and explicit — many pitfalls documented by Valeev) > Python (dynamic — most conversions explicit but type errors deferred to runtime). Write examples of the same conversion bug in each language: integer overflow, precision loss, and null/None/Option handling during conversion. |

---

### Session 7 — Advanced Types

**Goal:** explore advanced type system features — Rust's newtype pattern, never type, and PhantomData; Java's type erasure internals, intersection types, and Valhalla roadmap; Python's TypedDict, @overload, variance, and ParamSpec.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 35 min | **Rust: newtype, type aliases, never type, DSTs, PhantomData.** Read Klabnik Ch.19 pp. 419–458 (advanced traits: associated types, default type params, fully qualified syntax, supertraits, newtype pattern; advanced types: type aliases, never type `!`, DSTs, `Sized` trait). Read Blandy Ch.13 pp. 289–295 (Sized trait, Borrow/AsRef, Cow). Read the Rustonomicon sections on PhantomData and Subtyping/Variance online. Key insight: The newtype pattern (`struct Meters(f64)`) wraps a type to create a distinct type with zero runtime cost — the compiler optimizes it away. Type aliases (`type Kilometers = i32`) create synonyms, not new types. The never type `!` (for functions that never return) enables exhaustive matching. DSTs (dynamically sized types like `str`, `[T]`, `dyn Trait`) exist behind pointers only. PhantomData\<T\> tells the compiler a type "logically contains" a T without storing it — used for variance annotation, lifetime markers, and type-state patterns. |
| 7.2 | 30 min | **Java: erasure internals, intersection types, Valhalla.** Read Horstmann Ch.8 pp. 110–116 (type erasure details, restrictions on generics, reflection with generics). Read Bloch Ch.5 pp. 140–155 (typesafe heterogeneous containers, erasure workarounds). Read the Java Language Specification sections on Type Erasure and Intersection Types online. Read JEP 218 (Generics over Primitive Types) online. Key insight: Type erasure means `List<String>` becomes `List` at runtime — the JVM has no concept of generic type arguments. Bridge methods are synthesized to maintain polymorphism under erasure. Intersection types (`T extends Serializable & Comparable<T>`) allow multiple bounds. Java cannot have `List<int>` because primitives are not objects — Project Valhalla aims to fix this with value types (inline classes) that can be generic type arguments without boxing, fundamentally changing Java's type system. |
| 7.3 | 30 min | **Python: TypedDict, @overload, variance, ParamSpec.** Read Ramalho Ch.15 pp. 519–560 (TypedDict, @overload, generic classes, variance — covariant/contravariant/invariant). Read Ramalho Ch.8 pp. 280–302 (@overload for static type checkers). Read PEP 612 (ParamSpec) and PEP 673 (Self type) online. Key insight: TypedDict provides typed dictionary shapes for JSON-like data — each key has a specific type, checked statically. `@overload` lets you declare multiple type signatures for a function that the type checker uses to refine return types based on argument types (runtime dispatch remains single-implementation). Variance in Python generics: `list` is invariant (Sequence is covariant), `Callable` is contravariant in arguments and covariant in return. ParamSpec (PEP 612) captures function parameter types for accurate decorator typing. |
| 7.4 | 15 min | **Cross-language synthesis.** Compare advanced type features: (1) zero-cost type wrappers (Rust newtype vs Java value types planned vs Python NewType), (2) never/bottom type (Rust `!` vs Java — none, closest is infinite loop / System.exit vs Python NoReturn), (3) variance (Rust — lifetime/type variance via PhantomData, Java — use-site variance via wildcards, Python — declaration-site variance via TypeVar). Note what is inexpressible: Rust cannot do reflection; Java cannot avoid erasure (yet); Python cannot enforce types at runtime without extra libraries. |

---

### Session 8 — Nullability & Option Types

**Goal:** understand how each language handles the absence of a value — Rust's zero-null design with Option\<T\>/Result\<T,E\>, Java's billion-dollar mistake with null and the Optional retrofit, and Python's None with typing.Optional.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 30 min | **Rust: Option\<T\> and Result\<T,E\>.** Read Klabnik Ch.6 pp. 108–117 (Option\<T\> — Some/None, pattern matching, `if let`, `while let`). Read Blandy Ch.10 pp. 220–230 (Option and Result as generic enums, `?` operator, combinators). Read the Rust std docs for Option and Result online. Key insight: Rust has no null. Instead, `Option<T>` (either `Some(value)` or `None`) makes absence explicit in the type system. You cannot accidentally dereference a null pointer — the compiler forces you to handle `None` via `match`, `if let`, `unwrap()` (panics), or `?` (propagates). This is the single biggest safety improvement over Java and Python. Option\<T\> is a zero-cost abstraction — `Option<&T>` is the same size as `*T` thanks to niche optimization (null pointer is used as the None discriminant). Result\<T,E\> extends this pattern to errors. The combinators (`map`, `and_then`, `unwrap_or`, `ok_or`) enable ergonomic chaining without nested matches. |
| 8.2 | 30 min | **Java: null, NullPointerException, Optional.** Read Horstmann Ch.5 pp. 70–74 (Object class, equality, null). Read Valeev Ch.7 pp. 177–212 (equals/hashCode contracts — null handling). Read Bloch Item 61 (boxed primitives and null). Read the Java docs for java.util.Optional online. Read JEP 358 (Helpful NullPointerExceptions) online. Key insight: Java's `null` is the "billion-dollar mistake" (Tony Hoare's words) — any reference type can be null, and dereferencing null throws NullPointerException (NPE). Java 8 added `Optional<T>` as a return-type convention to signal "might be absent," but it is not enforced — you can still pass null anywhere. Optional is heap-allocated (unlike Rust's Option), should not be used for fields or parameters (per Bloch), and adds API complexity. Java 14+ provides "helpful NPEs" (JEP 358) with better error messages. The fundamental problem remains: null is a subtype of every reference type, and the type system cannot distinguish `String` from `String-or-null`. |
| 8.3 | 25 min | **Python: None and Optional typing.** Read Ramalho Ch.8 pp. 260–270 (Optional in type annotations). Read Martelli Ch.5 pp. 178–185 (Optional, Union, None type). Read the mypy docs on Optional types and None online. Key insight: Python's `None` is a singleton object of type `NoneType`. Any variable can be `None` at runtime — the language has no null safety. `typing.Optional[str]` (equivalent to `str | None` in Python 3.10+) signals to type checkers that a value might be None. mypy's strict mode can catch "unguarded None access" — `if x is not None:` narrows the type from `Optional[str]` to `str`. However, this is purely static — at runtime, accessing an attribute of None still raises AttributeError. Python's approach is middle ground: less safe than Rust (no compile-time enforcement), but type checkers catch many bugs that Java's type system alone cannot (since Java Optional is not enforced). |
| 8.4 | 15 min | **Comparative synthesis.** Compare nullability approaches: (1) null elimination (Rust — no null at all, Option forces handling), (2) null coexistence (Java — null everywhere, Optional as convention, no type-system enforcement), (3) gradual null safety (Python — None everywhere at runtime, Optional + type checkers for static analysis). Write the same function in all three: "find a user by ID, return their email or handle absence." Compare the type signatures, the handling code, and what happens when the caller ignores the absence case. Note the trend: modern language features move toward Rust's approach — Kotlin's null safety, Swift's optionals, and Java's ongoing null-annotation efforts (JSR 305, JSpecify) all aim to make null explicit in the type system. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Primitive & scalar types | Klabnik 31–46, Blandy 43–55, Horstmann 41–52, Bloch Item 61, Valeev 96–110, Martelli 33–55, Ramalho 3–12, Gorelick 65–70 | Rust Reference types, JLS Chapter 4 + 5, Python docs built-in types + data model |
| 2 | Composite & algebraic types | Klabnik 85–117, Blandy 193–233, Horstmann 55–82, Evans 55–77, Bloch 157–175, Ramalho 163–200, Martelli 115–135 | Rust By Example custom types, JEP 395 (Records), JEP 409 (Sealed Classes), JEP 441 (Pattern Matching), PEP 557 (dataclasses), Python enum docs |
| 3 | Generics & parametric polymorphism | Klabnik 181–200, Blandy 235–250, Horstmann 104–116, Bloch 117–155, Martelli 171–185, Ramalho 253–280 + 519–540 | Rust Reference generics, Rustonomicon variance, JLS Chapter 4, Oracle generics tutorial, Angelika Langer FAQ, PEP 484, PEP 695 |
| 4 | Traits, interfaces & protocols | Blandy 235–280, Klabnik 200–213, Horstmann 74–82, Evans 60–77, Bloch 175–191, Ramalho 431–486, Martelli 135–155 | Rust Reference traits + trait objects, JLS Chapter 9, JEP 409, PEP 544 (Protocols), PEP 3119 (ABCs), Python abc docs |
| 5 | Type inference & annotations | Klabnik 31–35, Blandy 123–130, Evans 3–25, Valeev 19–40, Martelli 171–194, Ramalho 253–302 | Rust By Example inference, JEP 286 (var), JLS Chapter 18, PEP 484, PEP 526, PEP 563, mypy docs, pyright docs |
| 6 | Type conversion & casting | Matthews 80–91, Blandy 130–142 + 281–301, Valeev 19–60 + 96–154, Martelli 45–55, Ramalho 201–228 + 561–590 | Rust std::convert docs, Rust By Example casting/conversion, JLS Chapter 5, Python docs built-in functions |
| 7 | Advanced types | Klabnik 419–458, Blandy 289–295, Horstmann 110–116, Bloch 140–155, Ramalho 280–302 + 519–560 | Rustonomicon PhantomData + variance, JLS erasure + intersection types, JEP 218 (Valhalla), PEP 612 (ParamSpec), PEP 673 (Self) |
| 8 | Nullability & option types | Klabnik 108–117, Blandy 220–230, Horstmann 70–74, Bloch Item 61, Valeev 177–212, Ramalho 260–270, Martelli 178–185 | Rust std Option + Result docs, Java Optional docs, JEP 358 (Helpful NPEs), mypy Optional docs, PEP 484 |

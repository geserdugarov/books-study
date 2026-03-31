# Layer 3 · Topic 11 — Metaprogramming

> Extending or generating code at compile time and runtime — macros, reflection, annotations, decorators, metaclasses, and AST manipulation across Rust, Java, and Python.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.19 pp. 419–458 | Macros: declarative macros with `macro_rules!`, procedural macros for custom derive, attribute-like macros, function-like macros |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Appendix C pp. 507–510 | Derivable traits: `Debug`, `Clone`, `Copy`, `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, `Default` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.20 pp. 499–523 | Comprehensive macros: `macro_rules!` expansion mechanics, repetition patterns, fragment types (`expr`, `ty`, `ident`, `tt`), json! macro example, recursion in macros, scoping and hygiene, built-in macros, introduction to procedural macros |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.7 pp. 101–115 | Declarative macros (when to use, how they work), procedural macros (types, compilation cost, when to use), token trees, hygiene, the proc-macro ecosystem, practical guidance on choosing between declarative and procedural |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.11 pp. 140–149 | Annotations: using and defining annotations, standard annotations (`@Override`, `@Deprecated`, `@SuppressWarnings`, `@FunctionalInterface`), runtime annotation processing with reflection, source-level annotation processing, bytecode engineering |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.5.10 pp. 80–81 | Reflection: `Class` objects, `Method`/`Field`/`Constructor` access, dynamic method invocation |
| Java | Bloch (2018) — *Effective Java* | Item 39 pp. 180–187 | Prefer annotations to naming patterns — annotations as replacement for reflection-based conventions |
| Java | Bloch (2018) — *Effective Java* | Item 65 p. 283 | Prefer interfaces to reflection — discusses when reflection is and is not appropriate |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.4 pp. 81–117 | Class loading and class objects, examining class files with `javap`, bytecode opcodes, reflection APIs, combining reflection with class loading, performance costs of reflection |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.17 pp. 571–607 | Reflection internals, method handles (`MethodHandle`, `MethodType`), `invokedynamic` bytecode instruction, lambda implementation via invokedynamic, Unsafe API and VarHandles |
| Python | Ramalho (2022) — *Fluent Python* | Ch.9 pp. 303–340 | Decorators and closures: decorators as syntactic sugar for higher-order functions, closures, `nonlocal`, `functools.cache`, `lru_cache`, `singledispatch`, parameterized decorators (function-based and class-based) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.22 pp. 835–878 | Dynamic attributes and properties: `__getattr__`, `__new__`, `@property` for computed/validated attributes, property caching with `functools`, attribute handling via `__dict__`, `vars()`, `getattr()`, `setattr()` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.23 pp. 879–906 | Attribute descriptors: descriptor protocol (`__get__`, `__set__`, `__delete__`), overriding vs nonoverriding descriptors, methods as descriptors, attribute validation with descriptors |
| Python | Ramalho (2022) — *Fluent Python* | Ch.24 pp. 907–956 | Class metaprogramming: classes as objects, `type` as a factory, `__init_subclass__` for customizing subclass creation, class decorators as metaclass alternatives, metaclasses 101, `__prepare__`, modern features that simplify or replace metaclasses |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.4 pp. 115–169 | Object-oriented Python: special methods, decorators, metaclasses for class creation customization, properties |
| Python | Slatkin (2025) — *Effective Python* | Item 38 p. 166 | Define function decorators with `functools.wraps` — preserving decorated function metadata |
| Python | Slatkin (2025) — *Effective Python* | Ch.8 pp. 265–318 | Metaclasses and attributes: `@property` vs plain attributes (Items 58–59), descriptors for reusable property logic (Item 60), `__getattr__`/`__getattribute__`/`__setattr__` for lazy attributes (Item 61), `__init_subclass__` for validation and registration (Items 62–63), `__set_name__` for annotation (Item 64), class body definition order (Item 65), class decorators vs metaclasses (Item 66) |
| Python | Shaw (2021) — *CPython Internals* | Ch.5 pp. 91–117 | Lexing and parsing with syntax trees: tokenization, concrete syntax tree (CST), abstract syntax tree (AST) generation |
| Python | Shaw (2021) — *CPython Internals* | Ch.6 pp. 118–150 | The compiler: compilation from AST to bytecode, symbol tables, code object creation, assembly |
| Python | Shaw (2021) — *CPython Internals* | Ch.7 pp. 151–175 | The evaluation loop: frame objects, bytecode execution, the value stack |

### Coverage Gaps

The owned books **do not** cover:

- **The Little Book of Rust Macros and advanced `macro_rules!` patterns** — Blandy Ch.20 and Gjengset Ch.7 cover `macro_rules!` well, but neither addresses advanced techniques such as TT munchers, push-down accumulation, internal rules, or the `macro_metavar_expr` nightly feature; the community-maintained *The Little Book of Rust Macros* (online) is the definitive reference for these patterns
- **Building procedural macros from scratch (full worked examples)** — Klabnik Ch.19 shows the structure, Gjengset Ch.7 explains when to use them, but neither provides a complete walkthrough of writing a derive macro with `syn`, `quote`, and `proc-macro2` from an empty crate to a working published macro; David Tolnay's `proc-macro-workshop` on GitHub and the `syn` crate documentation fill this gap
- **Java annotation processing API in depth (`javax.annotation.processing`)** — Horstmann Ch.11 introduces source-level annotation processing but does not cover the `AbstractProcessor` lifecycle, `RoundEnvironment`, multi-round processing, or generating source files via `Filer`; the Oracle Annotation Processing tutorial and the `javax.annotation.processing` Javadoc are needed
- **Lombok internals and compile-time bytecode manipulation** — none of the owned Java books explain how Project Lombok works (annotation processing + AST modification via internal `javac` API), or alternatives like Google Auto, Immutables, or MapStruct; these require the Lombok documentation and blog posts on annotation processor architecture
- **Java bytecode engineering libraries (ASM, Byte Buddy, cglib)** — Evans Ch.4 covers bytecode at the conceptual level, and Horstmann Ch.11 mentions bytecode engineering briefly, but no owned book demonstrates using ASM or Byte Buddy to generate or transform classes at runtime; the ASM Guide (online PDF) and Byte Buddy documentation are needed
- **Python `ast` module for programmatic code analysis and transformation** — Shaw covers CPython's internal AST representation during compilation, but no owned book covers the user-facing `ast` module (`ast.parse()`, `ast.NodeVisitor`, `ast.NodeTransformer`, `compile()`, `exec()`) for runtime code inspection and rewriting; the Python `ast` module documentation and Green Tree Snakes tutorial are needed
- **Python `inspect` module for runtime introspection** — none of the owned books cover `inspect.signature()`, `inspect.getsource()`, `inspect.getmembers()`, frame introspection, or how libraries use `inspect` to implement dependency injection and API documentation; the Python `inspect` module documentation is needed
- **`importlib` and import hooks for metaprogramming** — Python's import machinery (`importlib`, `sys.meta_path`, finder/loader protocol) enables powerful metaprogramming (e.g., lazy imports, source transformation on import) but is not covered in any owned book; the Python importlib documentation and PEP 302/PEP 451 are needed
- **Cross-language comparison of compile-time vs runtime metaprogramming tradeoffs** — no single owned book compares the metaprogramming philosophies: Rust's compile-time-only approach (macros generate code before type checking), Java's dual approach (compile-time annotation processing + runtime reflection), and Python's runtime-first approach (everything is mutable at runtime); this requires synthesis from multiple sources

---

## External Resources

### Sub-topic 1 — Decorators, Closures, and Function Transformers

**Rust**
- The Rust Reference — Attributes: `https://doc.rust-lang.org/reference/attributes.html`
- The Rust Reference — Procedural Macros (attribute macros): `https://doc.rust-lang.org/reference/procedural-macros.html#attribute-macros`
- Rust By Example — Attributes: `https://doc.rust-lang.org/rust-by-example/attribute.html`

**Java**
- Java Language Specification — Annotations (JLS Ch.9.7): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.7`
- Oracle Tutorial — Annotations: `https://docs.oracle.com/javase/tutorial/java/annotations/`
- Baeldung — Custom Annotations in Java: `https://www.baeldung.com/java-custom-annotation`

**Python**
- Python docs — Compound statements (function and class decorators): `https://docs.python.org/3/reference/compound_stmts.html#function-definitions`
- PEP 318 — Decorators for Functions and Methods: `https://peps.python.org/pep-0318/`
- PEP 3129 — Class Decorators: `https://peps.python.org/pep-3129/`
- Python docs — `functools.wraps`: `https://docs.python.org/3/library/functools.html#functools.wraps`
- Python docs — `functools.singledispatch`: `https://docs.python.org/3/library/functools.html#functools.singledispatch`

### Sub-topic 2 — Declarative Macros (`macro_rules!`)

**Rust**
- The Rust Reference — Macros By Example: `https://doc.rust-lang.org/reference/macros-by-example.html`
- The Little Book of Rust Macros: `https://veykril.github.io/tlborm/`
- Rust By Example — macro_rules!: `https://doc.rust-lang.org/rust-by-example/macros.html`
- Rust Blog — "Macros in Rust: A tutorial with examples" (LogRocket, 2023): `https://blog.logrocket.com/macros-in-rust-a-tutorial-with-examples/`

**Java**
- (Java has no compile-time macro system; see annotation processing in sub-topic 5 for the closest equivalent)

**Python**
- (Python has no compile-time macro system; decorators and metaclasses serve a similar role at runtime)

### Sub-topic 3 — Procedural Macros, Derive, and Compile-time Code Generation

**Rust**
- The Rust Reference — Procedural Macros: `https://doc.rust-lang.org/reference/procedural-macros.html`
- The Rust Reference — Derive macros: `https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros`
- David Tolnay — `proc-macro-workshop` (hands-on exercises): `https://github.com/dtolnay/proc-macro-workshop`
- `syn` crate documentation: `https://docs.rs/syn/latest/syn/`
- `quote` crate documentation: `https://docs.rs/quote/latest/quote/`
- `proc-macro2` crate documentation: `https://docs.rs/proc-macro2/latest/proc_macro2/`
- Rust By Example — Derive: `https://doc.rust-lang.org/rust-by-example/trait/derive.html`

**Java**
- Oracle — Annotation Processing Tool (apt) Tutorial: `https://docs.oracle.com/javase/8/docs/technotes/guides/apt/`
- Baeldung — Java Annotation Processing and Creating a Builder: `https://www.baeldung.com/java-annotation-processing-builder`
- `javax.annotation.processing` Javadoc: `https://docs.oracle.com/en/java/javase/21/docs/api/java.compiler/javax/annotation/processing/package-summary.html`

**Python**
- PEP 3129 — Class Decorators: `https://peps.python.org/pep-3129/`
- Python docs — `dataclasses` module (a class decorator for code generation): `https://docs.python.org/3/library/dataclasses.html`

### Sub-topic 4 — Reflection and Runtime Introspection

**Rust**
- Rust docs — `std::any::Any` (limited runtime type identification): `https://doc.rust-lang.org/std/any/trait.Any.html`
- Rust docs — `std::any::TypeId`: `https://doc.rust-lang.org/std/any/struct.TypeId.html`
- Rust internals discussion — "Why Rust doesn't have reflection": `https://internals.rust-lang.org/`

**Java**
- Oracle Tutorial — The Reflection API: `https://docs.oracle.com/javase/tutorial/reflect/`
- Java docs — `java.lang.reflect` package: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/reflect/package-summary.html`
- Java docs — `java.lang.Class`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Class.html`
- Baeldung — Guide to Java Reflection: `https://www.baeldung.com/java-reflection`

**Python**
- Python docs — `inspect` module: `https://docs.python.org/3/library/inspect.html`
- Python docs — Built-in functions (`type`, `dir`, `getattr`, `hasattr`, `isinstance`, `vars`): `https://docs.python.org/3/library/functions.html`
- Python docs — Data Model (special attribute access): `https://docs.python.org/3/reference/datamodel.html`

### Sub-topic 5 — Annotation and Attribute Systems Compared

**Rust**
- The Rust Reference — Attributes (outer and inner): `https://doc.rust-lang.org/reference/attributes.html`
- The Rust Reference — Derive macro helper attributes: `https://doc.rust-lang.org/reference/procedural-macros.html#derive-macro-helper-attributes`
- serde documentation — Using derive: `https://serde.rs/derive.html`
- serde documentation — Attributes (container, variant, field): `https://serde.rs/attributes.html`

**Java**
- Java Language Specification — Annotation Types (JLS 9.6): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.6`
- Project Lombok — Features: `https://projectlombok.org/features/`
- Baeldung — Introduction to Project Lombok: `https://www.baeldung.com/intro-to-project-lombok`
- Google Auto — AutoValue: `https://github.com/google/auto/tree/main/value`

**Python**
- PEP 557 — Data Classes: `https://peps.python.org/pep-0557/`
- PEP 681 — Data Class Transforms: `https://peps.python.org/pep-0681/`
- Python docs — `@property`: `https://docs.python.org/3/library/functions.html#property`
- `attrs` library documentation: `https://www.attrs.org/en/stable/`

### Sub-topic 6 — Descriptors, Properties, and Attribute Access Protocols

**Rust**
- Rust docs — `Deref` trait: `https://doc.rust-lang.org/std/ops/trait.Deref.html`
- Rust docs — `DerefMut` trait: `https://doc.rust-lang.org/std/ops/trait.DerefMut.html`
- Rust By Example — Operator Overloading: `https://doc.rust-lang.org/rust-by-example/trait/ops.html`

**Java**
- Java docs — `java.beans` package (JavaBeans property conventions): `https://docs.oracle.com/en/java/javase/21/docs/api/java.desktop/java/beans/package-summary.html`
- Oracle Tutorial — Properties (JavaBeans): `https://docs.oracle.com/javase/tutorial/javabeans/writing/properties.html`

**Python**
- Python docs — Descriptor HowTo Guide: `https://docs.python.org/3/howto/descriptor.html`
- Python docs — Data Model (implementing descriptors): `https://docs.python.org/3/reference/datamodel.html#implementing-descriptors`
- Python docs — `property` built-in: `https://docs.python.org/3/library/functions.html#property`
- Raymond Hettinger — "Descriptor HowTo Guide" (the definitive tutorial): `https://docs.python.org/3/howto/descriptor.html`

### Sub-topic 7 — Metaclasses and Class Construction Machinery

**Rust**
- The Rust Reference — Items (how types are defined): `https://doc.rust-lang.org/reference/items.html`
- (Rust has no metaclass concept; type definition is static and final at compile time)

**Java**
- Java docs — `java.lang.ClassLoader`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ClassLoader.html`
- JVM Specification — Loading, Linking, and Initializing (JVMS Ch.5): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html`
- Baeldung — Java Class Loaders: `https://www.baeldung.com/java-classloaders`

**Python**
- Python docs — Data Model (metaclasses): `https://docs.python.org/3/reference/datamodel.html#metaclasses`
- PEP 3115 — Metaclasses in Python 3000: `https://peps.python.org/pep-3115/`
- PEP 487 — Simpler customisation of class creation: `https://peps.python.org/pep-0487/`
- Python docs — `type` built-in (as metaclass): `https://docs.python.org/3/library/functions.html#type`

### Sub-topic 8 — AST Manipulation and Code Generation

**Rust**
- `proc_macro` standard library docs: `https://doc.rust-lang.org/proc_macro/`
- `syn` crate — parsing Rust code into AST: `https://docs.rs/syn/latest/syn/`
- `quote` crate — turning AST back into tokens: `https://docs.rs/quote/latest/quote/`
- Rust `build.rs` build scripts: `https://doc.rust-lang.org/cargo/reference/build-scripts.html`

**Java**
- ASM bytecode engineering library — Guide (PDF): `https://asm.ow2.io/asm4-guide.pdf`
- Byte Buddy — Tutorial: `https://bytebuddy.net/#/tutorial`
- `javassist` library: `https://www.javassist.org/`
- JVM Specification — Class File Format (JVMS Ch.4): `https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html`

**Python**
- Python docs — `ast` module: `https://docs.python.org/3/library/ast.html`
- Green Tree Snakes — the missing Python AST docs: `https://greentreesnakes.readthedocs.io/en/latest/`
- Python docs — `compile` built-in: `https://docs.python.org/3/library/functions.html#compile`
- Python docs — `exec` built-in: `https://docs.python.org/3/library/functions.html#exec`
- Python docs — `dis` module (bytecode disassembler): `https://docs.python.org/3/library/dis.html`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Rust | *The Little Book of Rust Macros* (community-maintained, online) | The definitive reference for `macro_rules!` patterns — covers TT munchers, push-down accumulation, internal rules, fragment specifier edge cases, and debugging techniques that no print book addresses; essential for anyone writing non-trivial declarative macros |
| Rust | David Tolnay — *proc-macro-workshop* (GitHub, hands-on exercises) | Five progressive exercises (derive builder, derive debug, seq!, sorted, bitfield) that teach procedural macro development from scratch using `syn`/`quote`; the best practical resource for learning to build proc macros since no owned book provides complete worked examples |
| Java | Cay S. Horstmann — *Core Java, Volume II — Advanced Features* (Prentice Hall, 2022) | Extends Vol. I's annotation chapter with deeper coverage of annotation processing, scripting engines, and the compiler API (`javax.tools`) for programmatic compilation and code generation |
| Java | Rafael Winterhalter — *Byte Buddy* documentation and blog posts | The author of Byte Buddy (the most popular Java bytecode generation library) provides tutorials and explanations of runtime class generation, method interception, and Java agent instrumentation — fills the bytecode engineering gap |
| Python | David Beazley — *Python Distilled* (Addison-Wesley, 2021) | Covers metaprogramming with exceptional clarity: decorators, descriptors, metaclasses, import system hooks, and code inspection — a more concise and modern treatment than Martelli, from the author of many advanced Python talks |
| Python | David Beazley & Brian K. Jones — *Python Cookbook, 3rd Edition* (O'Reilly, 2013) | Chapter 9 "Metaprogramming" provides 25+ practical recipes for decorators (with/without arguments, class-based), metaclasses, descriptors, code generation, and execution with `exec()`; while Python 3.3 era, the metaprogramming patterns remain valid |

---

## Study Plan — 8 Sessions

Estimated total: **18–24 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from function-level metaprogramming (decorators) through compile-time code generation (macros, annotation processing) to runtime introspection (reflection, metaclasses) and AST manipulation.

---

### Session 1 — Decorators, Closures, and Function Transformers

**Goal:** understand Python's decorator pattern as the most accessible entry point to metaprogramming — functions that transform other functions — and compare with Rust's attribute macros and Java's annotation system as metadata-driven function/method modification.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 35 min | **Python: decorators and closures.** Read Ramalho Ch.9 pp. 303–340 (decorators 101: registration vs modification patterns, variable scope and closures, `nonlocal`, standard library decorators `functools.cache`, `lru_cache`, `singledispatch`, parameterized decorators). Read Slatkin Item 38 p. 166 (`functools.wraps` for preserving metadata). Key insight: a decorator is syntactic sugar — `@deco` above `def f()` is equivalent to `f = deco(f)`. Decorators are just higher-order functions that receive a function and return a (usually modified) function. Closures enable decorators to carry state. `functools.wraps` copies `__name__`, `__doc__`, and `__module__` from the original function to the wrapper, preserving introspection. Parameterized decorators like `@lru_cache(maxsize=128)` are decorator factories: functions that return decorators. `@singledispatch` shows how decorators can implement a form of method overloading in Python. |
| 1.2 | 25 min | **Python: class decorators.** Read Ramalho Ch.24 pp. 907–920 (class decorators as metaclass alternatives). Read Slatkin Item 66 pp. 310–318 (prefer class decorators over metaclasses for composable extensions). Key insight: class decorators (`@decorator` above `class C`) receive the class object and return a (possibly modified) class. They are simpler than metaclasses for adding/modifying class attributes, registering classes, or wrapping methods. `@dataclass` is the most prominent class decorator — it inspects type annotations and generates `__init__`, `__repr__`, `__eq__`, etc. Class decorators compose naturally (stack multiple decorators), while metaclasses have the limitation that a class can only have one metaclass. |
| 1.3 | 25 min | **Java: annotations as metadata markers.** Read Horstmann Ch.11 pp. 140–144 (using and defining annotations, standard annotations). Read Bloch Item 39 pp. 180–187 (prefer annotations to naming patterns). Key insight: Java annotations (`@Override`, `@Deprecated`, `@SuppressWarnings`) are metadata markers — they do not transform code by themselves. They require a separate processing step: either a runtime reflection-based processor (reading annotations with `getAnnotation()`) or a compile-time annotation processor (`javax.annotation.processing`). Unlike Python decorators, Java annotations are passive metadata — they declare intent, and separate tooling acts on that intent. This is a fundamentally different philosophy: Python's decorators are active (they execute code), while Java's annotations are declarative (they mark code for processing). |
| 1.4 | 20 min | **Rust: attribute macros as function transformers.** Read Klabnik Ch.19 pp. 440–450 (attribute-like macros). Read the Rust Reference "Attribute Macros" section online. Key insight: Rust's attribute macros (`#[my_attribute]`) are the closest analogue to Python decorators — they receive the annotated item's token stream and return a new token stream. However, they execute at compile time, not runtime. The `#[test]`, `#[tokio::main]`, and `#[derive(...)]` attributes are the most common examples. Unlike Python decorators which are simple function calls, Rust attribute macros operate on the token-level representation of code and can rewrite it completely. Unlike Java annotations which are passive metadata, Rust attribute macros are active code generators. |
| 1.5 | 15 min | **Cross-language comparison.** Compare decorator/annotation application across all three: Python `@lru_cache` (wraps function at runtime, adds caching behavior), Java `@Cacheable` from Spring (annotation marker, separate framework processes it), Rust `#[cached]` from the `cached` crate (compile-time macro generates caching wrapper). Map the spectrum: Python decorators are runtime function composition; Java annotations are passive metadata processed separately; Rust attribute macros are compile-time code generators. Note how all three achieve similar end results (adding behavior to functions/methods) through fundamentally different mechanisms. |

---

### Session 2 — Declarative Macros in Rust (`macro_rules!`)

**Goal:** master Rust's `macro_rules!` system — pattern matching on syntax trees, repetition, fragment specifiers, hygiene, and scoping — and understand why this form of compile-time metaprogramming has no equivalent in Java or Python.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 40 min | **Rust: `macro_rules!` fundamentals.** Read Blandy Ch.20 pp. 499–515 (macro expansion mechanics, repetition patterns `$(...)*` and `$(...)+`, fragment types: `expr`, `ty`, `ident`, `stmt`, `block`, `item`, `tt`, `pat`, `path`, `meta`, `literal`; the `json!` macro as a worked example). Key insight: `macro_rules!` macros are "macros by example" — they pattern-match on token trees and produce new token trees. Fragment specifiers (`$x:expr`, `$T:ty`) tell the parser how to parse each captured piece. Repetition (`$($x:expr),*`) handles variadic inputs. Macros expand before type checking — they operate on syntax, not semantics. The `json!` example demonstrates building a complex DSL within Rust: `json!({"name": "Alice", "age": 30})` compiles to valid Rust code that constructs a JSON value. |
| 2.2 | 30 min | **Rust: hygiene, scoping, and recursion.** Read Blandy Ch.20 pp. 515–523 (scoping and hygiene, built-in macros, recursion, import/export of macros). Read Gjengset Ch.7 pp. 101–108 (declarative macros: when to use, practical guidance, hygiene). Key insight: Rust macros are partially hygienic — local variables introduced inside a macro do not leak into the caller's scope, preventing accidental name collisions (unlike C preprocessor macros). However, macros can reference items from the caller's scope. `#[macro_export]` makes a macro available at the crate root. Recursive macros enable complex patterns but can be hard to debug. The `cargo expand` tool (via `cargo-expand` crate) shows the expanded output of macros, essential for debugging. Compare with C/C++ `#define`: C macros are textual substitution (no hygiene, no type awareness, operates on raw text), while Rust macros operate on parsed token trees with hygiene. |
| 2.3 | 25 min | **Rust: advanced `macro_rules!` patterns.** Read *The Little Book of Rust Macros* online: "Macros by Example" and "Patterns" sections. Key insight: advanced patterns include TT munchers (recursive macros that consume one token at a time), push-down accumulation (building up a result through recursive calls), internal rules (`@inner` convention for helper patterns within a macro), and callbacks (passing a macro name as an argument to another macro). The `tt` fragment specifier is the most flexible — it matches any single token tree (a token or a group in `()`, `[]`, or `{}`). Understanding these patterns enables building complex DSLs. However, Gjengset's advice applies: prefer procedural macros for complex code generation, and use `macro_rules!` for simpler pattern-based transformations. |
| 2.4 | 15 min | **Why Java and Python lack compile-time macros.** Java's philosophy: the language should be readable without knowing what transformations are applied — annotations are visible but passive, and all code generation happens through explicit tooling (annotation processors, build plugins). Python's philosophy: the language is dynamic enough that runtime metaprogramming (decorators, metaclasses, `exec()`) achieves what compile-time macros would — there is no separate compilation step in the traditional sense, so "compile-time" is a thin layer. Rust's philosophy: zero-cost abstractions require compile-time code generation — runtime reflection would violate the "you don't pay for what you don't use" principle, so macros provide metaprogramming without runtime cost. The three philosophies are consistent with each language's core values: Java values readability and explicit tooling; Python values runtime flexibility; Rust values compile-time safety and zero overhead. |

---

### Session 3 — Procedural Macros, Derive, and Compile-time Code Generation

**Goal:** understand Rust's procedural macros as compiler plugins that generate code from token streams — derive macros, attribute macros, and function-like macros — and compare with Java's annotation processing pipeline and Python's class decorators.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Rust: procedural macros overview.** Read Klabnik Ch.19 pp. 440–458 (three kinds: custom derive, attribute-like, function-like; the `TokenStream` type; writing a simple derive macro). Read Gjengset Ch.7 pp. 108–115 (procedural macros: types, compilation cost, `syn`/`quote`/`proc-macro2` ecosystem, when to use). Key insight: procedural macros are Rust functions compiled into a separate crate (`proc-macro = true` in `Cargo.toml`) that take a `TokenStream` as input and return a `TokenStream` as output. They run at compile time as compiler plugins. The `syn` crate parses `TokenStream` into a structured AST (`DeriveInput`, `ItemFn`, etc.), `quote!` turns Rust code back into a `TokenStream`, and `proc-macro2` provides a testable wrapper. Compilation cost: proc macros add compile time because they are separate crates compiled before the crate that uses them. Three types: (1) derive macros (`#[derive(MyTrait)]`) add implementations; (2) attribute macros (`#[my_attr]`) transform items; (3) function-like macros (`my_macro!(...)`) look like function calls. |
| 3.2 | 30 min | **Rust: derive macros in practice — serde as case study.** Read Klabnik Appendix C pp. 507–510 (standard derivable traits). Read the serde documentation online (derive usage, container/variant/field attributes). Key insight: `#[derive(Serialize, Deserialize)]` from serde is the most widely used procedural macro in the Rust ecosystem. It inspects the struct/enum definition and generates serialization/deserialization code at compile time — zero runtime reflection needed. serde attributes (`#[serde(rename = "name")]`, `#[serde(skip)]`, `#[serde(default)]`) customize the generated code. This pattern — derive macro + helper attributes — is the idiomatic Rust approach to code generation. Other examples: `#[derive(Debug)]` generates `fmt::Debug` implementations, `#[derive(Clone)]` generates `Clone` implementations by recursively cloning each field. The derive system is Rust's answer to Java's reflection-based serialization and Python's runtime introspection for data classes. |
| 3.3 | 25 min | **Java: annotation processing at compile time.** Read Horstmann Ch.11 pp. 145–149 (source-level annotation processing, bytecode engineering). Read the Baeldung tutorial on Java annotation processing online. Key insight: Java's annotation processing API (`javax.annotation.processing`) enables compile-time code generation. An `AbstractProcessor` declares which annotations it handles via `@SupportedAnnotationTypes`. During compilation, `javac` invokes processors in rounds — each round can generate new source files via `Filer`, which may themselves contain annotations triggering further rounds. Unlike Rust proc macros, Java annotation processors cannot modify existing classes — they can only generate new source files. Lombok circumvents this by using internal `javac` APIs to modify the AST directly, which is technically unsupported. Google AutoValue, Dagger, and MapStruct are well-known annotation processors that follow the standard API. |
| 3.4 | 20 min | **Python: class decorators as code generators.** Read Ramalho Ch.24 pp. 907–920 (class decorators). Read the `dataclasses` module documentation online. Key insight: Python's `@dataclass` decorator inspects the class body (specifically type-annotated fields), and generates `__init__`, `__repr__`, `__eq__`, and optionally `__hash__`, `__lt__`/etc. at class creation time. This is runtime code generation — the decorator receives the class object, creates new methods as function objects, and attaches them to the class. Compared to Rust's `#[derive]` (compile-time, generates Rust source) and Java's annotation processing (compile-time, generates separate source files), Python's approach is runtime and in-place — it modifies the existing class object. The tradeoff: Python's approach is more flexible (can use runtime information) but has startup cost and no compile-time error checking of the generated code. |
| 3.5 | 15 min | **Comparison: code generation pipelines.** Map the three pipelines: Rust: source → `proc-macro` crate parses tokens → generates new tokens → compiler compiles result → binary (all at compile time, zero runtime cost). Java: source → `javac` + annotation processors → new source files generated → compiled together → bytecode (compile time, but processors are limited to generating new files). Python: source → interpreter loads module → `@dataclass` decorator runs → modifies class object in memory (runtime, visible via `inspect`). Note the trade-off triangle: Rust maximizes performance (compile-time, zero-cost); Java maximizes safety (compile-time, but cannot modify existing code); Python maximizes flexibility (runtime, can do anything). |

---

### Session 4 — Reflection and Runtime Introspection

**Goal:** compare runtime introspection capabilities — Java's rich reflection API, Python's pervasive introspection (`type()`, `dir()`, `inspect`), and Rust's deliberate near-absence of runtime reflection — understanding the design philosophy behind each choice.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Java: the Reflection API.** Read Horstmann Ch.5.10 pp. 80–81 (reflection basics). Read Evans Ch.4 pp. 111–117 (reflection APIs, combining with class loading, performance costs). Read Bloch Item 65 p. 283 (prefer interfaces to reflection). Key insight: Java's `java.lang.reflect` package provides `Class`, `Method`, `Field`, `Constructor` objects for runtime type inspection and dynamic invocation. `Class.forName("com.example.Foo")` loads a class by name. `getDeclaredMethods()` lists all methods including private. `method.invoke(obj, args)` calls a method dynamically. Reflection is the foundation of Java frameworks (Spring dependency injection, JPA/Hibernate ORM, JUnit test discovery). However, Bloch warns: reflection breaks compile-time type safety, reduces readability, and has significant performance overhead (100x–1000x slower than direct calls for unoptimized reflection). Best practice: use reflection for framework/library code (loading plugins, deserializing data) but not for application logic. |
| 4.2 | 30 min | **Java: method handles and `invokedynamic`.** Read Evans Ch.17 pp. 578–602 (reflection internals, method handles, invokedynamic). Key insight: `java.lang.invoke.MethodHandle` (Java 7+) is a modern, type-safe, JIT-optimizable alternative to reflection. A `MethodHandle` is a directly executable reference to a method, constructor, or field accessor. Unlike `Method.invoke()`, method handles can be inlined by the JIT compiler. `invokedynamic` (Java 7+) is a bytecode instruction that defers method resolution to a bootstrap method at first call — it is how lambdas are implemented (no anonymous inner class generated; instead, `invokedynamic` calls `LambdaMetafactory` to generate an implementation at first invocation). Understanding `invokedynamic` is key to understanding modern JVM metaprogramming: it enables runtime code generation without bytecode manipulation libraries. |
| 4.3 | 30 min | **Python: pervasive introspection.** Read Ramalho Ch.22 pp. 835–850 (dynamic attribute access, `__getattr__`). Read the Python `inspect` module documentation online. Key insight: everything in Python is introspectable at runtime. `type(obj)` returns the class. `dir(obj)` lists all attributes. `getattr(obj, 'name')` accesses attributes by name. `hasattr(obj, 'name')` checks existence. `vars(obj)` returns `__dict__`. The `inspect` module provides deeper introspection: `inspect.signature(fn)` returns parameter information, `inspect.getsource(fn)` retrieves source code, `inspect.getmembers(obj)` lists members with predicates, `inspect.stack()` inspects the call stack. Python's introspection is so pervasive that it is the basis of all Python frameworks: Flask discovers routes via decorators + introspection, pytest discovers tests via naming conventions + introspection, Pydantic validates data via type annotation introspection. The cost: attribute access is a dictionary lookup, and introspection calls add overhead — but Python's philosophy is that developer productivity matters more than raw performance. |
| 4.4 | 20 min | **Rust: the deliberate absence of reflection.** Read the Rust docs for `std::any::Any` and `std::any::TypeId` online. Key insight: Rust has no general reflection API — you cannot enumerate a struct's fields or methods at runtime. This is by design: reflection would require storing type metadata in the binary (increasing size), would break the zero-cost abstraction principle, and would undermine the borrow checker's compile-time guarantees. `std::any::Any` provides limited type identification: `TypeId::of::<T>()` returns a unique identifier for type `T`, and `Any::downcast_ref::<T>()` enables type-safe downcasting. Beyond this, Rust relies entirely on compile-time metaprogramming (macros) for code generation and the type system (generics, traits) for polymorphism. Libraries that need serialization use `#[derive(Serialize)]` instead of reflection. This means Rust cannot implement Spring-style dependency injection or JUnit-style test discovery via reflection — these patterns use different mechanisms (proc macros, `cargo test` integration, static registration). |
| 4.5 | 15 min | **Comparison: reflection spectrum.** Map the spectrum: Python (maximum reflection — everything is introspectable, even source code and call stacks) → Java (rich but bounded — `java.lang.reflect` provides class/method/field inspection, but modules can restrict access since Java 9) → Rust (near-zero — only `TypeId` for dynamic type checks, no field/method introspection). Note the correlation: the more reflection a language provides, the more runtime overhead it incurs and the less static optimization is possible. Rust trades runtime flexibility for compile-time guarantees and performance. Java occupies the middle ground: reflection exists but best practice limits its use. Python embraces reflection as a core language feature. |

---

### Session 5 — Annotation and Attribute Systems Compared

**Goal:** compare declarative metadata systems across all three languages — Rust's `#[attributes]`, Java's `@annotations`, Python's decorators-as-annotations — and how each language uses metadata to drive code generation and behavior.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: the attribute system.** Read the Rust Reference "Attributes" section online. Read the serde documentation for container, variant, and field attributes online. Key insight: Rust attributes come in two forms: outer attributes (`#[attr]` before an item) and inner attributes (`#![attr]` inside a module/crate). Built-in attributes include: `#[derive(...)]` (code generation), `#[cfg(...)]` (conditional compilation), `#[allow(...)]`/`#[warn(...)]`/`#[deny(...)]` (lint control), `#[inline]` (optimization hints), `#[test]` (test marking), `#[repr(...)]` (memory layout control). Custom attributes are implemented via procedural macros. The serde ecosystem demonstrates the power of the attribute system: `#[serde(rename_all = "camelCase")]` on a struct changes all field names during serialization, `#[serde(tag = "type")]` controls enum representation, `#[serde(skip_serializing_if = "Option::is_none")]` conditionally omits fields. Attributes are resolved at compile time — no runtime cost. |
| 5.2 | 25 min | **Java: the annotation system.** Read Horstmann Ch.11 pp. 140–145 (using and defining annotations, standard annotations). Read Bloch Item 39 pp. 180–187. Key insight: Java annotations are defined as special interfaces (`@interface`). They support element types: primitives, `String`, `Class`, enums, annotations, and arrays thereof. Retention policies control when annotations are available: `SOURCE` (discarded by compiler), `CLASS` (in bytecode but not at runtime), `RUNTIME` (available via reflection). `@Target` restricts where annotations can appear (methods, fields, types, parameters, etc.). Standard annotations: `@Override` (compile-time check), `@Deprecated` (documentation + warning), `@SuppressWarnings` (lint control), `@FunctionalInterface` (compile-time check). Custom annotations combined with processing (compile-time or runtime) enable powerful patterns: `@Autowired` (Spring DI), `@Entity`/`@Column` (JPA ORM), `@Test`/`@BeforeEach` (JUnit), `@GET`/`@Path` (JAX-RS). The annotation is passive metadata; the processing framework does the work. |
| 5.3 | 25 min | **Python: decorators and type annotations as metadata.** Read Martelli Ch.4 pp. 130–145 (decorators, special methods as metadata). Read the `dataclasses` and `attrs` documentation online. Key insight: Python lacks a formal annotation system separate from decorators. Instead, Python uses: (1) decorators as active metadata (`@dataclass`, `@property`, `@app.route`), (2) type annotations (PEP 526: `name: str = "default"`) as inspectable metadata that tools like `dataclasses` and Pydantic read at runtime, (3) `__annotations__` dict on classes and functions to store type hints. Unlike Java where annotations are a language-level metadata system with formal retention policies, Python's "annotations" are ad hoc — type hints, decorators, and class/function attributes serve the same purpose through different mechanisms. The `typing` module provides `Annotated[int, Gt(0)]` (PEP 593) for attaching arbitrary metadata to type hints, which is the closest Python gets to Java-style annotations. |
| 5.4 | 20 min | **Comparison: metadata-driven code generation.** Build a serializable data type with validation in all three languages. Rust: `#[derive(Serialize, Deserialize)] struct User { #[serde(rename = "user_name")] name: String, #[validate(range(min = 0))] age: u32 }` — compile-time code generation, zero runtime cost. Java: `@Entity public class User { @Column(name = "user_name") String name; @Min(0) int age; }` — annotations processed by JPA (runtime reflection) and Bean Validation (runtime). Python: `@dataclass class User: name: str; age: int` with Pydantic `@validator` or `Annotated[int, Gt(0)]` — runtime decorator + type annotation introspection. Compare: who processes the metadata, when (compile-time vs runtime), and at what cost. Note the convergence: all three ecosystems are moving toward declarative, metadata-driven programming — they differ in when and how the metadata is processed. |

---

### Session 6 — Descriptors, Properties, and Attribute Access Protocols

**Goal:** deep-dive into Python's descriptor protocol as a fundamental metaprogramming mechanism, compare with Rust's `Deref`/`DerefMut` traits for smart pointer ergonomics, and understand Java's lack of a property protocol.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 35 min | **Python: the descriptor protocol.** Read Ramalho Ch.23 pp. 879–906 (descriptor protocol: `__get__`, `__set__`, `__delete__`, `__set_name__`; overriding vs nonoverriding descriptors; methods as descriptors; validation with descriptors). Read Slatkin Item 60 pp. 274–279 (descriptors for reusable `@property` methods). Key insight: a descriptor is any object that defines `__get__`, `__set__`, or `__delete__`. When a class attribute is a descriptor, attribute access on instances triggers the descriptor's methods instead of simple dictionary lookup. Data descriptors (with `__set__` or `__delete__`) take priority over instance `__dict__`; non-data descriptors (only `__get__`) do not. This is how `@property`, `@classmethod`, `@staticmethod`, and regular methods work: they are all descriptors. `property` is a data descriptor; functions are non-data descriptors (their `__get__` returns a bound method). `__set_name__` (PEP 487) is called when a descriptor is assigned to a class attribute, receiving the owner class and attribute name — enabling descriptors that know their own name without explicit configuration. |
| 6.2 | 25 min | **Python: `@property` and dynamic attribute access.** Read Ramalho Ch.22 pp. 835–878 (dynamic attributes, `@property`, `__getattr__`, `__getattribute__`, `__setattr__`). Read Slatkin Items 58–59 pp. 265–274 (plain attributes vs setters/getters; `@property` for gradual refactoring). Read Slatkin Item 61 pp. 279–285 (`__getattr__`, `__getattribute__`, `__setattr__` for lazy attributes). Key insight: `@property` enables computed attributes that look like plain attribute access — `obj.area` can compute and return a value without the caller knowing it is not stored. `__getattr__` is called only when normal attribute lookup fails (useful for delegation and proxy patterns). `__getattribute__` intercepts every attribute access (dangerous — easy to create infinite recursion). `__setattr__` intercepts every attribute assignment. These dunder methods enable transparent proxying, lazy loading, and ORM-style field mapping. The power spectrum: `@property` is the simplest (one attribute), descriptors are reusable (shared across attributes), `__getattr__` is the catch-all (any attribute name). |
| 6.3 | 20 min | **Rust: `Deref` and `DerefMut` as smart pointer protocols.** Read the Rust docs for `std::ops::Deref` and `std::ops::DerefMut` online. Read Blandy Ch.13 pp. 285–290 (Deref/DerefMut traits). Key insight: Rust's `Deref` trait enables "deref coercion" — when a type implements `Deref<Target = T>`, references to it can be automatically coerced to `&T`. This is how `Box<String>` can be passed where `&str` is expected (`Box` → `String` → `str` via deref coercions). While not a property system, `Deref`/`DerefMut` serve a similar purpose to Python descriptors: they customize how accessing the inner value works. However, Rust's approach is compile-time and type-directed, while Python's descriptor protocol is runtime and name-directed. Rust explicitly discourages using `Deref` for general-purpose "smart properties" — the convention is to use `Deref` only for smart pointers, not for custom attribute access patterns. |
| 6.4 | 15 min | **Java: getter/setter conventions and `java.beans`.** Read the Oracle JavaBeans properties tutorial online. Key insight: Java has no language-level property protocol. Instead, it relies on the JavaBeans naming convention: `getX()`/`setX()` methods signal properties to frameworks. The `java.beans.Introspector` uses reflection to discover properties from getter/setter names. Java records (JEP 395) partially address this with auto-generated accessor methods (`point.x()` instead of `point.getX()`). Lombok's `@Getter`/`@Setter` generates these methods at compile time. Project Valhalla (value types) may further change how properties work. The key difference: Python's descriptors are a language-level protocol that any object can participate in transparently; Java's properties are a naming convention that requires explicit framework support. |
| 6.5 | 15 min | **Comparison.** Build a validated `Temperature` type with a `celsius` property that enforces a minimum value (-273.15). Python: use `@property` with a setter that validates, then refactor to a reusable `ValidatedFloat` descriptor. Rust: use a newtype `struct Celsius(f64)` with a constructor that validates — no runtime property protocol needed because the type system enforces invariants at construction time. Java: use a private field with a `getCelsius()`/`setCelsius()` pair that validates. Compare: Python customizes access to existing attributes; Rust prevents invalid values from existing; Java wraps access in methods by convention. |

---

### Session 7 — Metaclasses and Class Construction Machinery

**Goal:** understand how classes themselves are created — Python's metaclass system (`type` as the default metaclass, custom metaclasses, `__init_subclass__`, `__prepare__`), Java's class loading mechanism, and Rust's static type definition — and when each language's class construction can be customized.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 40 min | **Python: metaclasses.** Read Ramalho Ch.24 pp. 920–956 (metaclasses 101: `type` as metaclass, custom metaclasses via `__new__` and `__init__`, `__prepare__` for custom namespace, how metaclasses interact with `__init_subclass__`). Read Martelli Ch.4 pp. 155–169 (metaclasses for class creation customization). Key insight: in Python, classes are instances of their metaclass. `type` is the default metaclass — `class Foo: pass` is equivalent to `Foo = type('Foo', (), {})`. A custom metaclass inherits from `type` and overrides `__new__` (to control class creation) or `__init__` (to customize after creation). `__prepare__` returns the namespace dict used during class body execution — returning an `OrderedDict` or custom mapping enables tracking definition order or transforming assignments. Metaclasses are used in production by: Django models (`ModelBase` metaclass creates database mappings from field definitions), `abc.ABCMeta` (enforces abstract methods), `enum.EnumMeta` (transforms class body into enum members). However, Ramalho and Slatkin both emphasize that metaclasses should be a last resort — `__init_subclass__` and class decorators solve most problems more simply. |
| 7.2 | 25 min | **Python: `__init_subclass__` and `__set_name__` as metaclass alternatives.** Read Slatkin Items 62–63 pp. 285–299 (`__init_subclass__` for subclass validation and registration). Read Slatkin Item 64 pp. 299–303 (`__set_name__` for descriptor annotation). Read PEP 487 online. Key insight: PEP 487 (Python 3.6) introduced `__init_subclass__` as a simpler alternative to metaclasses for the common case of customizing subclass creation. `__init_subclass__(cls, **kwargs)` is called on the parent class whenever a subclass is defined — no custom metaclass needed. Use cases: automatic registration (plugin systems), validation of subclass structure, setting class-level attributes. `__set_name__` is called on descriptors when assigned to a class attribute, eliminating the need for metaclasses to wire up descriptor names. Together, `__init_subclass__`, `__set_name__`, and class decorators cover ~90% of use cases that previously required metaclasses. |
| 7.3 | 25 min | **Java: class loading and runtime class creation.** Read Evans Ch.4 pp. 81–101 (class loading: loading, linking, initialization; custom class loaders; examining class files with `javap`). Read the JVM Specification chapter 5 on loading, linking, and initializing online. Key insight: Java's class loading mechanism is its form of "class construction." The bootstrap class loader loads core classes (`java.lang.*`), the platform class loader loads standard library, and the application class loader loads user code. Custom class loaders enable: loading classes from non-standard locations (network, databases), hot-reloading (application servers like Tomcat use separate class loaders per webapp), instrumentation (Java agents modify class bytes during loading via `java.lang.instrument`). The class loading lifecycle — load (read bytes) → link (verify, prepare, resolve) → initialize (run `<clinit>`) — provides hooks for metaprogramming. Since Java 9, modules restrict reflective access across module boundaries, changing the class loading landscape. |
| 7.4 | 15 min | **Rust: static type definitions.** Key insight: Rust has no metaclass concept. Types (structs, enums, traits) are defined statically in source code and fully resolved at compile time. There is no runtime "class object" to inspect or customize. The closest Rust has to class construction customization is: (1) derive macros that add implementations at compile time, (2) the `Default` trait providing a standard constructor, (3) builder patterns for complex construction. The absence of metaclasses is a feature, not a limitation — Rust achieves the same goals through different means: plugin registration uses `inventory` or `linkme` crates (compile-time or link-time registration instead of runtime), validation uses the type system (invalid states are unrepresentable), and customization uses macros (code generation at compile time instead of runtime class mutation). |
| 7.5 | 15 min | **Comparison.** Implement a plugin registration system in all three: Python: use `__init_subclass__` — any subclass of `Plugin` is automatically registered in a class-level list. Java: use `ServiceLoader` (the standard plugin mechanism) — services declared in `META-INF/services/` are discovered at runtime via class loading. Rust: use the `inventory` crate — `inventory::submit!` registers items at link time, `inventory::iter::<T>()` iterates them. Compare: Python's approach is the most magical (implicit registration via subclassing), Java's is the most explicit (declaration in manifest files + reflection), Rust's is compile/link-time (zero runtime discovery cost). |

---

### Session 8 — AST Manipulation, Bytecode Engineering, and Synthesis

**Goal:** understand how each language enables programmatic code analysis and generation at the deepest level — Python's `ast` module, Rust's proc-macro token streams, Java's bytecode engineering libraries — and synthesize the compile-time vs runtime metaprogramming spectrum.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 30 min | **Python: the `ast` module and code analysis.** Read Shaw Ch.5 pp. 91–117 (CPython's lexing, parsing, and AST generation). Read the Python `ast` module documentation and Green Tree Snakes tutorial online. Key insight: Python's `ast` module provides programmatic access to the abstract syntax tree. `ast.parse(source)` returns an AST, `ast.NodeVisitor` enables walking the tree (for analysis), `ast.NodeTransformer` enables modifying nodes (for transformation), and `compile(tree, filename, mode)` compiles a modified AST into a code object for execution with `exec()`. Use cases: linting tools (pylint, flake8 inspect ASTs), code formatting (black parses and regenerates from ASTs), test coverage (coverage.py instruments AST nodes), security analysis (detecting dangerous patterns). The AST is a faithful representation of the source — but formatting is lost (AST is structural, not textual). `ast.unparse()` (Python 3.9+) converts an AST back to source code. Compare with Rust: Python's AST is available at runtime and can be manipulated by user code; Rust's AST is only available during compilation within proc macros. |
| 8.2 | 25 min | **Rust: proc-macro token streams and `syn`/`quote`.** Read the `proc_macro` standard library documentation online. Read the `syn` and `quote` crate documentation online. Key insight: Rust's proc macros operate on `TokenStream` — a sequence of token trees (identifiers, literals, punctuation, groups). The `syn` crate parses a `TokenStream` into strongly-typed AST nodes (`syn::DeriveInput`, `syn::ItemFn`, `syn::Expr`, etc.) with full span information for error reporting. The `quote!` macro provides quasi-quoting: `quote! { impl #name { fn new() -> Self { ... } } }` generates a `TokenStream` with interpolated values. Together, `syn` + `quote` provide a complete code-analysis-and-generation pipeline at compile time. Rust's `build.rs` scripts provide another code generation path: they run before compilation and can generate `.rs` files from schemas, protobufs, or other inputs. Unlike Python's `ast` module (which users can call at runtime), Rust's proc macros run only during compilation — user code cannot parse or generate Rust code at runtime. |
| 8.3 | 30 min | **Java: bytecode engineering with ASM and Byte Buddy.** Read Evans Ch.4 pp. 90–111 (examining class files, bytecode opcodes). Read Horstmann Ch.11 pp. 148–149 (bytecode engineering mention). Read the ASM Guide (online PDF, first 20 pages) and Byte Buddy tutorial online. Key insight: Java bytecode engineering libraries enable creating and modifying classes at the bytecode level — below the source code, at the JVM instruction level. ASM is the lowest-level library: it provides a visitor-based API for reading/writing class files, used internally by many frameworks (Spring, Hibernate, Mockito). Byte Buddy is a higher-level API built on ASM: `new ByteBuddy().subclass(Object.class).method(named("toString")).intercept(FixedValue.value("Hello")).make()` creates a new class at runtime. Java agents (`java.lang.instrument`) use bytecode engineering to transform classes as they are loaded — enabling profiling, monitoring, and AOP (aspect-oriented programming). This is a unique capability: Java can create entirely new classes at runtime from bytecode, something neither Rust nor Python can do natively (Python can use `type()` to create classes but not from bytecode). |
| 8.4 | 20 min | **Python: `dis`, bytecode inspection, and `exec`/`eval`.** Read Shaw Ch.6 pp. 118–150 (compilation to bytecode, code objects). Read Shaw Ch.7 pp. 151–175 (evaluation loop). Read the Python `dis` module documentation online. Key insight: `dis.dis(fn)` disassembles a function's bytecode, revealing CPython's stack-based virtual machine instructions (`LOAD_FAST`, `CALL_FUNCTION`, `RETURN_VALUE`, etc.). `exec(code_string)` compiles and executes a string as Python code. `eval(expression_string)` evaluates a single expression. `compile(source, filename, mode)` creates code objects without executing them. These functions enable powerful runtime code generation — but `exec()`/`eval()` are security risks (code injection) and debugging nightmares (no source mapping). In practice, prefer `ast.parse()` + `compile()` + `exec()` over raw `exec(string)` for safer code generation. Libraries like Numba use bytecode analysis to JIT-compile Python to machine code. |
| 8.5 | 20 min | **Synthesis: the metaprogramming spectrum.** Create a comprehensive comparison across all eight sessions' topics. The metaprogramming spectrum: **Rust** — compile-time only; macros (`macro_rules!` and proc macros) generate code before type checking; zero runtime cost; no reflection; the programmer explicitly opts into every piece of code generation via `#[derive]` or macro invocations. **Java** — dual approach; annotations provide compile-time metadata for annotation processors (code generation) and runtime metadata for reflection-based frameworks; bytecode engineering enables runtime class creation; `invokedynamic` bridges compile-time and runtime. **Python** — runtime-first; decorators, metaclasses, descriptors, `ast` module, `exec()` all operate at runtime; everything is introspectable and mutable; maximum flexibility at the cost of performance and static analysis. The key insight: metaprogramming is about which layer of the language is programmable — Rust makes the compiler programmable (via macros), Java makes the class loader and bytecode programmable (via reflection and bytecode engineering), Python makes everything programmable (the language itself is a mutable runtime). Each approach reflects the language's core values: Rust's safety and performance, Java's platform stability, Python's flexibility and expressiveness. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Decorators, closures, function transformers | Ramalho 303–340, 907–920; Slatkin 166, 310–318; Horstmann 140–144; Bloch 180–187; Klabnik 440–450 | PEP 318, PEP 3129, Rust Reference attributes, Oracle Annotations tutorial |
| 2 | Declarative macros (`macro_rules!`) | Blandy 499–523; Gjengset 101–108 | The Little Book of Rust Macros, Rust Reference macros-by-example |
| 3 | Procedural macros, derive, compile-time codegen | Klabnik 440–458, 507–510; Gjengset 108–115; Horstmann 145–149; Ramalho 907–920 | `proc-macro-workshop`, `syn`/`quote` docs, serde docs, Baeldung annotation processing |
| 4 | Reflection and runtime introspection | Horstmann 80–81; Evans 81–117, 571–607; Bloch 283; Ramalho 835–850 | Oracle Reflection tutorial, `java.lang.reflect` docs, Python `inspect` docs, `std::any` docs |
| 5 | Annotation and attribute systems compared | Horstmann 140–145; Bloch 180–187; Martelli 130–145 | Rust Reference attributes, serde attributes, JLS 9.6, Lombok docs, PEP 557, `attrs` docs |
| 6 | Descriptors, properties, attribute access | Ramalho 835–906; Slatkin 265–285; Blandy 285–290 | Python Descriptor HowTo, `Deref` docs, JavaBeans tutorial |
| 7 | Metaclasses and class construction | Ramalho 920–956; Martelli 155–169; Slatkin 285–303; Evans 81–101 | PEP 487, PEP 3115, JVMS Ch.5, `inventory` crate |
| 8 | AST manipulation, bytecode, synthesis | Shaw 91–175; Evans 90–111; Horstmann 148–149 | Python `ast` docs, Green Tree Snakes, `syn`/`quote` docs, ASM Guide, Byte Buddy tutorial |

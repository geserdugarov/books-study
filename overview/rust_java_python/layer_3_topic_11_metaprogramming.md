# Layer 3 · Topic 11 — Metaprogramming

> Extending or generating code at compile time and runtime — macros, reflection, annotations, decorators, metaclasses, and AST manipulation across Rust, Java, and Python.

---

## 1. Decorators, Closures, and Function Transformers

The most accessible entry point to metaprogramming is the idea of functions that transform other functions. Python makes this explicit with decorators, Java approaches it through annotations as passive metadata markers, and Rust uses attribute macros that rewrite code at compile time. All three achieve similar results — adding behavior to functions and methods — through fundamentally different mechanisms.

### Python: Decorators and Closures

A decorator is syntactic sugar for higher-order function application: `@deco` above `def f()` is equivalent to `f = deco(f)`. Decorators are functions that receive a function and return a (usually modified) function. Closures enable decorators to carry state between calls.

```python
import functools
import time

# A simple decorator that measures execution time
def timer(func):
    @functools.wraps(func)  # preserves __name__, __doc__, __module__
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)

# Parameterized decorator (decorator factory)
def retry(max_attempts=3):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception:
                    if attempt == max_attempts - 1:
                        raise
        return wrapper
    return decorator

@retry(max_attempts=5)
def unreliable_call():
    ...
```

Key concepts:

- **`functools.wraps`** copies `__name__`, `__doc__`, and `__module__` from the original function to the wrapper, preserving introspection capabilities.
- **Parameterized decorators** like `@lru_cache(maxsize=128)` are decorator factories — functions that return decorators.
- **`@functools.singledispatch`** shows how decorators can implement a form of method overloading: dispatching based on the first argument's type.
- **`@functools.cache`** and **`@functools.lru_cache`** add memoization by wrapping the function with a dictionary-based cache.
- **Closures** are the mechanism that makes decorators work — the inner `wrapper` function closes over the `func` variable from the enclosing scope. The `nonlocal` keyword enables closures to modify variables from enclosing scopes.

**Class decorators** receive a class object and return a (possibly modified) class. They are simpler than metaclasses for adding or modifying class attributes, registering classes, or wrapping methods.

```python
from dataclasses import dataclass

# @dataclass is the most prominent class decorator — it inspects type
# annotations and generates __init__, __repr__, __eq__, etc.
@dataclass
class Point:
    x: float
    y: float

# Class decorators compose naturally (stack multiple decorators)
@dataclass(frozen=True)
class ImmutablePoint:
    x: float
    y: float
```

Class decorators compose naturally — you can stack multiple decorators — while metaclasses have the limitation that a class can only have one metaclass.

> **Sources:** Ramalho (2022) Ch.9 pp. 303–340 · Ramalho (2022) Ch.24 pp. 907–920 · Slatkin (2025) Item 38 p. 166 · Slatkin (2025) Item 66 pp. 310–318 · [PEP 318 — Decorators for Functions and Methods](https://peps.python.org/pep-0318/) · [PEP 3129 — Class Decorators](https://peps.python.org/pep-3129/) · [Python docs — `functools.wraps`](https://docs.python.org/3/library/functools.html#functools.wraps) · [Python docs — `functools.singledispatch`](https://docs.python.org/3/library/functools.html#functools.singledispatch)

### Java: Annotations as Metadata Markers

Java annotations (`@Override`, `@Deprecated`, `@SuppressWarnings`) are metadata markers — they do not transform code by themselves. They require a separate processing step: either a runtime reflection-based processor or a compile-time annotation processor.

```java
// Standard annotations — passive metadata
public class Example {

    @Override  // compile-time check: method must override a superclass method
    public String toString() {
        return "Example";
    }

    @Deprecated(since = "2.0", forRemoval = true)  // warning + documentation
    public void oldMethod() { }

    @SuppressWarnings("unchecked")  // suppress specific compiler warnings
    public void riskyMethod() { }
}

// Defining a custom annotation
@Retention(RetentionPolicy.RUNTIME)  // available via reflection
@Target(ElementType.METHOD)           // can only be placed on methods
public @interface Test {
    String description() default "";
    long timeout() default 0L;
}

// Using the custom annotation
public class MyTests {
    @Test(description = "validates user input", timeout = 5000)
    public void testValidation() { /* ... */ }
}
```

Key concepts:

- **Annotations are passive metadata** — they declare intent, and separate tooling acts on that intent. This is fundamentally different from Python decorators, which are active (they execute code).
- **Retention policies** control when annotations are available: `SOURCE` (discarded by compiler), `CLASS` (in bytecode but not at runtime), `RUNTIME` (available via reflection).
- **`@Target`** restricts where annotations can appear: methods, fields, types, parameters, local variables, etc.
- **Bloch's rule (Item 39):** prefer annotations to naming patterns. JUnit 3 used naming conventions (`testXxx`) to discover test methods; JUnit 4+ uses `@Test` annotations — more reliable, less error-prone, tooling-friendly.

> **Sources:** Horstmann (2024) Ch.11 pp. 140–144 · Bloch (2018) Item 39 pp. 180–187 · [Java Language Specification — Annotations (JLS 9.7)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.7) · [Oracle Tutorial — Annotations](https://docs.oracle.com/javase/tutorial/java/annotations/) · [Baeldung — Custom Annotations in Java](https://www.baeldung.com/java-custom-annotation)

### Rust: Attribute Macros as Function Transformers

Rust's attribute macros (`#[my_attribute]`) are the closest analogue to Python decorators — they receive the annotated item's token stream and return a new token stream. However, they execute at compile time, not runtime.

```rust
// Built-in attributes
#[test]          // marks a function as a test case
fn test_addition() {
    assert_eq!(2 + 2, 4);
}

#[derive(Debug, Clone, PartialEq)]  // generates trait implementations
struct Point {
    x: f64,
    y: f64,
}

// Attribute macro from tokio — transforms an async main function
#[tokio::main]
async fn main() {
    println!("Hello from async runtime!");
}

// Conditional compilation — an attribute controlling inclusion
#[cfg(target_os = "linux")]
fn linux_only() {
    println!("Running on Linux");
}
```

Key concepts:

- **Attribute macros operate on token-level representation** and can rewrite code completely — unlike Java annotations which are passive metadata.
- **`#[test]`**, **`#[tokio::main]`**, and **`#[derive(...)]`** are the most common examples.
- **Compile-time execution** means zero runtime cost — the generated code is compiled normally.
- Unlike Python decorators (simple function calls), Rust attribute macros operate on parsed token trees and require the proc-macro infrastructure.

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 440–450 · [The Rust Reference — Attributes](https://doc.rust-lang.org/reference/attributes.html) · [The Rust Reference — Procedural Macros (attribute macros)](https://doc.rust-lang.org/reference/procedural-macros.html#attribute-macros) · [Rust By Example — Attributes](https://doc.rust-lang.org/rust-by-example/attribute.html)

### Cross-Language Comparison

The decorator/annotation spectrum:

| Aspect | Python decorators | Java annotations | Rust attribute macros |
|--------|------------------|------------------|-----------------------|
| **When** | Runtime | Compile-time or runtime | Compile-time only |
| **Nature** | Active — executes code | Passive — metadata marker | Active — generates code |
| **Mechanism** | Function composition | Separate processing framework | Token stream transformation |
| **Example** | `@lru_cache` wraps function | `@Cacheable` marker, Spring processes | `#[cached]` macro generates wrapper |
| **Cost** | Runtime overhead | Depends on processing strategy | Zero runtime cost |

Python decorators are runtime function composition; Java annotations are passive metadata processed separately; Rust attribute macros are compile-time code generators. All three achieve similar results through fundamentally different mechanisms.

---

## 2. Declarative Macros in Rust (`macro_rules!`)

Rust's `macro_rules!` system is a form of compile-time metaprogramming with no equivalent in Java or Python. Declarative macros pattern-match on syntax trees and produce new token trees — operating on syntax, not semantics — before type checking occurs.

### Rust: `macro_rules!` Fundamentals

Declarative macros are "macros by example" — they define patterns and corresponding expansions. Fragment specifiers tell the parser how to parse each captured piece, and repetition syntax handles variadic inputs.

```rust
// Simple macro: create a HashMap with literal entries
macro_rules! hashmap {
    // Match: comma-separated key => value pairs
    ( $( $key:expr => $value:expr ),* $(,)? ) => {
        {
            let mut map = std::collections::HashMap::new();
            $( map.insert($key, $value); )*
            map
        }
    };
}

let scores = hashmap! {
    "Alice" => 100,
    "Bob" => 85,
    "Charlie" => 92,
};

// The vec! macro from the standard library works similarly
macro_rules! my_vec {
    // Repeated element: vec![0; 5] => five zeros
    ( $elem:expr ; $n:expr ) => {
        std::vec::from_elem($elem, $n)
    };
    // List of elements: vec![1, 2, 3]
    ( $( $x:expr ),* $(,)? ) => {
        <[_]>::into_vec(Box::new([ $( $x ),* ]))
    };
}
```

**Fragment specifiers** — the types that `macro_rules!` can match:

| Specifier | Matches | Example |
|-----------|---------|---------|
| `expr` | Expression | `2 + 3`, `foo.bar()` |
| `ty` | Type | `i32`, `Vec<String>` |
| `ident` | Identifier | `my_var`, `MyStruct` |
| `stmt` | Statement | `let x = 5;` |
| `block` | Block | `{ println!("hi"); }` |
| `item` | Item | `fn foo() {}`, `struct S;` |
| `tt` | Token tree | Any single token or group |
| `pat` | Pattern | `Some(x)`, `_` |
| `path` | Path | `std::io::Result` |
| `meta` | Meta item | `derive(Debug)` |
| `literal` | Literal | `42`, `"hello"` |

**Repetition** uses `$(...)*` (zero or more) and `$(...)+` (one or more) with optional separators:

```rust
// A macro that generates an enum with Display implementation
macro_rules! define_errors {
    ( $( $variant:ident => $msg:expr ),+ $(,)? ) => {
        #[derive(Debug)]
        enum AppError {
            $( $variant, )+
        }

        impl std::fmt::Display for AppError {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                match self {
                    $( AppError::$variant => write!(f, $msg), )+
                }
            }
        }
    };
}

define_errors! {
    NotFound => "resource not found",
    Unauthorized => "access denied",
    Timeout => "request timed out",
}
```

> **Sources:** Blandy & Orendorff (2017) Ch.20 pp. 499–515 · Klabnik & Nichols (2023) Ch.19 pp. 419–440 · [The Rust Reference — Macros By Example](https://doc.rust-lang.org/reference/macros-by-example.html) · [Rust By Example — macro_rules!](https://doc.rust-lang.org/rust-by-example/macros.html) · [LogRocket — "Macros in Rust: A tutorial with examples"](https://blog.logrocket.com/macros-in-rust-a-tutorial-with-examples/)

### Rust: Hygiene, Scoping, and Recursion

Rust macros are **partially hygienic** — local variables introduced inside a macro do not leak into the caller's scope, preventing accidental name collisions (unlike C preprocessor macros). However, macros can reference items from the caller's scope.

```rust
macro_rules! make_adder {
    ($x:expr) => {
        {
            // This 'result' is hygienic — it won't collide with a
            // 'result' variable in the caller's scope
            let result = $x + 1;
            result
        }
    };
}

let result = 10;  // caller's 'result'
let val = make_adder!(5);  // macro's 'result' is separate
assert_eq!(result, 10);  // caller's 'result' is untouched
assert_eq!(val, 6);
```

Key concepts:

- **`#[macro_export]`** makes a macro available at the crate root, usable from other crates.
- **Recursive macros** enable complex patterns but can be hard to debug. The `cargo expand` tool (via the `cargo-expand` crate) shows the expanded output of macros — essential for debugging.
- **Compare with C/C++ `#define`:** C macros are textual substitution (no hygiene, no type awareness, operating on raw text), while Rust macros operate on parsed token trees with hygiene.

> **Sources:** Blandy & Orendorff (2017) Ch.20 pp. 515–523 · Gjengset (2022) Ch.7 pp. 101–108

### Rust: Advanced `macro_rules!` Patterns

Advanced patterns extend what `macro_rules!` can accomplish:

- **TT munchers** — recursive macros that consume one token tree at a time from the input, processing each piece before recursing on the rest.
- **Push-down accumulation** — building up a result through recursive calls, passing an accumulator as a parameter.
- **Internal rules** — the `@inner` convention for helper patterns within a macro, keeping them out of the public API.
- **Callbacks** — passing a macro name as an argument to another macro, enabling composition.

The `tt` fragment specifier is the most flexible — it matches any single token tree (a token or a group in `()`, `[]`, or `{}`). Understanding `tt` is essential for building complex DSLs.

**Practical guidance (Gjengset):** prefer procedural macros for complex code generation, and use `macro_rules!` for simpler pattern-based transformations. If a `macro_rules!` macro becomes hard to maintain, it is time to convert to a proc macro.

> **Sources:** Gjengset (2022) Ch.7 pp. 101–108 · [The Little Book of Rust Macros](https://veykril.github.io/tlborm/)

### Why Java and Python Lack Compile-Time Macros

The absence of compile-time macros in Java and Python is deliberate, reflecting core language philosophies:

- **Java:** the language should be readable without knowing what transformations are applied. Annotations are visible but passive, and all code generation happens through explicit tooling (annotation processors, build plugins). Readability and explicit tooling are valued over concise metaprogramming.
- **Python:** the language is dynamic enough that runtime metaprogramming (decorators, metaclasses, `exec()`) achieves what compile-time macros would. There is no separate compilation step in the traditional sense, so "compile-time" is a thin layer.
- **Rust:** zero-cost abstractions require compile-time code generation. Runtime reflection would violate the "you don't pay for what you don't use" principle, so macros provide metaprogramming without runtime cost.

---

## 3. Procedural Macros, Derive, and Compile-time Code Generation

Procedural macros are Rust compiler plugins that generate code from token streams at compile time. Java's annotation processing pipeline and Python's class decorators serve similar purposes through different mechanisms.

### Rust: Procedural Macros

Procedural macros are Rust functions compiled into a separate crate (`proc-macro = true` in `Cargo.toml`) that take a `TokenStream` as input and return a `TokenStream` as output. They run at compile time as compiler plugins.

```rust
// In a proc-macro crate (Cargo.toml: [lib] proc-macro = true)
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

// A derive macro that generates a "describe" method
#[proc_macro_derive(Describe)]
pub fn derive_describe(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;

    let expanded = quote! {
        impl #name {
            pub fn describe() -> &'static str {
                stringify!(#name)
            }
        }
    };

    TokenStream::from(expanded)
}

// Usage in another crate:
// #[derive(Describe)]
// struct MyStruct;
// assert_eq!(MyStruct::describe(), "MyStruct");
```

Three types of procedural macros:

| Type | Syntax | Purpose |
|------|--------|---------|
| **Derive macros** | `#[derive(MyTrait)]` | Add trait implementations to structs/enums |
| **Attribute macros** | `#[my_attr]` | Transform any item (functions, structs, modules) |
| **Function-like macros** | `my_macro!(...)` | Called like functions but operate on token streams |

The **proc-macro ecosystem** — three essential crates:

- **`syn`** — parses `TokenStream` into a structured AST (`DeriveInput`, `ItemFn`, `Expr`, etc.) with full span information for error reporting.
- **`quote`** — quasi-quoting: `quote! { impl #name { ... } }` generates a `TokenStream` with interpolated values.
- **`proc-macro2`** — provides a testable wrapper around `proc_macro` types (the standard `proc_macro` types can only exist within a proc-macro crate).

**Compilation cost:** proc macros add compile time because they are separate crates compiled before the crate that uses them.

> **Sources:** Klabnik & Nichols (2023) Ch.19 pp. 440–458 · Gjengset (2022) Ch.7 pp. 108–115 · [The Rust Reference — Procedural Macros](https://doc.rust-lang.org/reference/procedural-macros.html) · [`syn` crate documentation](https://docs.rs/syn/latest/syn/) · [`quote` crate documentation](https://docs.rs/quote/latest/quote/) · [`proc-macro2` crate documentation](https://docs.rs/proc-macro2/latest/proc_macro2/) · [proc-macro-workshop](https://github.com/dtolnay/proc-macro-workshop)

### Rust: Derive Macros in Practice — serde as Case Study

`#[derive(Serialize, Deserialize)]` from serde is the most widely used procedural macro in the Rust ecosystem. It inspects the struct/enum definition and generates serialization/deserialization code at compile time — zero runtime reflection needed.

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
struct User {
    #[serde(rename = "user_name")]
    name: String,

    #[serde(skip_serializing_if = "Option::is_none")]
    email: Option<String>,

    #[serde(default)]
    active: bool,
}

// Standard derivable traits from the language:
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Default)]
struct Coordinate {
    x: i32,
    y: i32,
}
```

The **derive + helper attributes** pattern (`#[serde(rename = "...")]`) is the idiomatic Rust approach to code generation. This is Rust's answer to Java's reflection-based serialization and Python's runtime introspection for data classes.

> **Sources:** Klabnik & Nichols (2023) Appendix C pp. 507–510 · [serde — Using derive](https://serde.rs/derive.html) · [serde — Attributes](https://serde.rs/attributes.html) · [Rust By Example — Derive](https://doc.rust-lang.org/rust-by-example/trait/derive.html)

### Java: Annotation Processing at Compile Time

Java's annotation processing API (`javax.annotation.processing`) enables compile-time code generation. An `AbstractProcessor` declares which annotations it handles, and `javac` invokes processors in rounds during compilation.

```java
// Defining an annotation for processing
@Retention(RetentionPolicy.SOURCE)  // only needed at compile time
@Target(ElementType.TYPE)
public @interface GenerateBuilder {
}

// Usage
@GenerateBuilder
public class User {
    private String name;
    private int age;
}
// The annotation processor generates UserBuilder.java
// in a separate source file during compilation
```

Key concepts:

- **Round-based processing:** each round can generate new source files via `Filer`, which may themselves contain annotations triggering further rounds.
- **Cannot modify existing classes** — annotation processors can only generate new source files. This is a deliberate design constraint for safety.
- **Lombok circumvents this** by using internal `javac` APIs to modify the AST directly, which is technically unsupported.
- **Well-known annotation processors:** Google AutoValue, Dagger (dependency injection), MapStruct (object mapping) — all follow the standard API and generate new files.

> **Sources:** Horstmann (2024) Ch.11 pp. 145–149 · [Oracle — Annotation Processing Tool Tutorial](https://docs.oracle.com/javase/8/docs/technotes/guides/apt/) · [Baeldung — Java Annotation Processing and Creating a Builder](https://www.baeldung.com/java-annotation-processing-builder) · [`javax.annotation.processing` Javadoc](https://docs.oracle.com/en/java/javase/21/docs/api/java.compiler/javax/annotation/processing/package-summary.html)

### Python: Class Decorators as Code Generators

Python's `@dataclass` decorator inspects the class body (specifically type-annotated fields) and generates `__init__`, `__repr__`, `__eq__`, and optionally `__hash__`, comparison methods, etc. at class creation time.

```python
from dataclasses import dataclass, field

@dataclass(frozen=True, order=True)
class User:
    name: str
    age: int
    tags: list[str] = field(default_factory=list)

# The decorator generates at runtime:
# - __init__(self, name: str, age: int, tags: list[str] = ...)
# - __repr__(self) -> str
# - __eq__(self, other) -> bool
# - __hash__(self) -> int        (because frozen=True)
# - __lt__, __le__, __gt__, __ge__  (because order=True)

# Compared to Rust #[derive] (compile-time) and Java annotation
# processing (compile-time), Python's approach is runtime and in-place
```

The tradeoff: Python's approach is more flexible (can use runtime information) but has startup cost and no compile-time error checking of the generated code.

> **Sources:** Ramalho (2022) Ch.24 pp. 907–920 · [Python docs — `dataclasses` module](https://docs.python.org/3/library/dataclasses.html) · [PEP 3129 — Class Decorators](https://peps.python.org/pep-3129/)

### Cross-Language Comparison: Code Generation Pipelines

| Pipeline | Rust | Java | Python |
|----------|------|------|--------|
| **Flow** | Source → proc-macro parses tokens → generates new tokens → compiler compiles result → binary | Source → `javac` + annotation processors → new source files → compiled together → bytecode | Source → interpreter loads module → decorator runs → modifies class in memory |
| **When** | Compile time | Compile time | Runtime |
| **Can modify existing code?** | Yes (attribute macros) | No (only generate new files) | Yes (modify class object) |
| **Runtime cost** | Zero | Zero (compile-time) or reflection overhead (runtime) | Startup cost |
| **Trade-off** | Maximum performance | Maximum safety | Maximum flexibility |

---

## 4. Reflection and Runtime Introspection

Runtime introspection — the ability to examine types, methods, and fields at runtime — varies dramatically across the three languages. Java provides a rich reflection API, Python makes everything introspectable, and Rust deliberately provides almost no runtime reflection.

### Java: The Reflection API

Java's `java.lang.reflect` package provides `Class`, `Method`, `Field`, and `Constructor` objects for runtime type inspection and dynamic invocation.

```java
import java.lang.reflect.*;

public class ReflectionDemo {
    public static void main(String[] args) throws Exception {
        // Get a Class object
        Class<?> clazz = Class.forName("java.util.ArrayList");

        // Inspect methods
        Method[] methods = clazz.getDeclaredMethods();
        for (Method m : methods) {
            System.out.printf("%s %s(%s)%n",
                m.getReturnType().getSimpleName(),
                m.getName(),
                Arrays.stream(m.getParameterTypes())
                      .map(Class::getSimpleName)
                      .collect(Collectors.joining(", ")));
        }

        // Dynamic invocation
        Object list = clazz.getDeclaredConstructor().newInstance();
        Method add = clazz.getMethod("add", Object.class);
        add.invoke(list, "hello");       // list.add("hello")
        Method size = clazz.getMethod("size");
        int s = (int) size.invoke(list); // list.size() => 1

        // Access private fields
        Field elementData = clazz.getDeclaredField("elementData");
        elementData.setAccessible(true);  // bypass access control
        Object[] data = (Object[]) elementData.get(list);
    }
}
```

Key concepts:

- **Reflection is the foundation of Java frameworks:** Spring dependency injection, JPA/Hibernate ORM, JUnit test discovery, Jackson serialization — all rely on reflection to discover and invoke code dynamically.
- **Performance cost:** unoptimized reflection is 100x–1000x slower than direct calls. The JIT compiler cannot inline reflected calls as easily.
- **Bloch's rule (Item 65):** prefer interfaces to reflection. Use reflection for framework/library code (loading plugins, deserializing data) but not for application logic.
- **Module system (Java 9+):** modules can restrict reflective access across module boundaries, limiting reflection's reach.

> **Sources:** Horstmann (2024) Ch.5.10 pp. 80–81 · Evans et al (2022) Ch.4 pp. 111–117 · Bloch (2018) Item 65 p. 283 · [Oracle Tutorial — The Reflection API](https://docs.oracle.com/javase/tutorial/reflect/) · [Java docs — `java.lang.reflect`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/reflect/package-summary.html) · [Java docs — `java.lang.Class`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Class.html) · [Baeldung — Guide to Java Reflection](https://www.baeldung.com/java-reflection)

### Java: Method Handles and `invokedynamic`

`java.lang.invoke.MethodHandle` (Java 7+) is a modern, type-safe, JIT-optimizable alternative to traditional reflection.

```java
import java.lang.invoke.*;

public class MethodHandleDemo {
    public static void main(String[] args) throws Throwable {
        MethodHandles.Lookup lookup = MethodHandles.lookup();

        // Create a method handle for String.length()
        MethodType mt = MethodType.methodType(int.class);
        MethodHandle lengthHandle = lookup.findVirtual(String.class, "length", mt);

        // Invoke — type-safe, JIT-optimizable
        int len = (int) lengthHandle.invoke("hello");  // => 5

        // MethodHandle for a static method
        MethodHandle valueOf = lookup.findStatic(
            String.class, "valueOf",
            MethodType.methodType(String.class, int.class)
        );
        String s = (String) valueOf.invoke(42);  // => "42"
    }
}
```

Key concepts:

- **Method handles can be inlined by the JIT compiler**, unlike `Method.invoke()` which requires boxing and access checks on every call.
- **`invokedynamic`** (Java 7+) is a bytecode instruction that defers method resolution to a bootstrap method at first call. This is how lambdas are implemented — no anonymous inner class is generated; instead, `invokedynamic` calls `LambdaMetafactory` at first invocation.
- Understanding `invokedynamic` is key to modern JVM metaprogramming: it enables runtime code generation without bytecode manipulation libraries.

> **Sources:** Evans et al (2022) Ch.17 pp. 578–602

### Python: Pervasive Introspection

Everything in Python is introspectable at runtime. The language provides built-in functions for attribute access and the `inspect` module for deeper introspection.

```python
import inspect

class Calculator:
    """A simple calculator."""

    def add(self, a: int, b: int) -> int:
        """Add two numbers."""
        return a + b

    def multiply(self, a: int, b: int) -> int:
        return a * b

calc = Calculator()

# Built-in introspection
type(calc)            # <class 'Calculator'>
dir(calc)             # ['__class__', ..., 'add', 'multiply']
getattr(calc, 'add')  # <bound method Calculator.add of ...>
hasattr(calc, 'add')  # True
vars(calc)            # {} (instance __dict__, empty here)
vars(Calculator)      # {'add': <function ...>, 'multiply': <function ...>, ...}

# inspect module — deeper introspection
sig = inspect.signature(calc.add)
print(sig)                  # (a: int, b: int) -> int
print(sig.parameters)       # OrderedDict of Parameter objects

source = inspect.getsource(Calculator)  # retrieves actual source code
members = inspect.getmembers(calc, predicate=inspect.ismethod)
# [('add', <bound method ...>), ('multiply', <bound method ...>)]

stack = inspect.stack()  # inspect the call stack — frames, filenames, line numbers
```

Key concepts:

- **Python's introspection is pervasive** — it is the basis of all Python frameworks. Flask discovers routes via decorators + introspection, pytest discovers tests via naming conventions + introspection, Pydantic validates data via type annotation introspection.
- **`__getattr__`** is called only when normal attribute lookup fails — useful for delegation and proxy patterns.
- **`__getattribute__`** intercepts every attribute access — powerful but dangerous (easy to create infinite recursion).
- **Cost:** attribute access is a dictionary lookup, and introspection calls add overhead — but Python's philosophy is that developer productivity matters more than raw performance.

> **Sources:** Ramalho (2022) Ch.22 pp. 835–850 · [Python docs — `inspect` module](https://docs.python.org/3/library/inspect.html) · [Python docs — Built-in functions](https://docs.python.org/3/library/functions.html) · [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)

### Rust: The Deliberate Absence of Reflection

Rust has no general reflection API — you cannot enumerate a struct's fields or methods at runtime. This is by design.

```rust
use std::any::{Any, TypeId};

fn print_if_string(value: &dyn Any) {
    // TypeId provides limited runtime type identification
    if TypeId::of::<String>() == value.type_id() {
        println!("It's a String!");
    }

    // Type-safe downcasting via Any
    if let Some(s) = value.downcast_ref::<String>() {
        println!("String value: {}", s);
    } else if let Some(n) = value.downcast_ref::<i32>() {
        println!("i32 value: {}", n);
    }
}
```

Key concepts:

- **No field or method introspection at runtime.** Reflection would require storing type metadata in the binary (increasing size), would break the zero-cost abstraction principle, and would undermine the borrow checker's compile-time guarantees.
- **`std::any::Any`** provides limited type identification: `TypeId::of::<T>()` returns a unique identifier, and `Any::downcast_ref::<T>()` enables type-safe downcasting.
- **Libraries that need serialization use `#[derive(Serialize)]`** instead of reflection — compile-time code generation replaces runtime introspection.
- **Cannot implement Spring-style DI or JUnit-style test discovery via reflection.** These patterns use different mechanisms in Rust: proc macros, `cargo test` integration, and static registration (e.g., `inventory` crate).

> **Sources:** [Rust docs — `std::any::Any`](https://doc.rust-lang.org/std/any/trait.Any.html) · [Rust docs — `std::any::TypeId`](https://doc.rust-lang.org/std/any/struct.TypeId.html)

### Cross-Language Comparison: The Reflection Spectrum

| Capability | Python | Java | Rust |
|-----------|--------|------|------|
| List fields/methods | `dir()`, `vars()`, `inspect` | `Class.getDeclaredFields/Methods()` | Not possible |
| Get source code | `inspect.getsource()` | Not standard | Not possible |
| Dynamic invocation | `getattr(obj, name)()` | `Method.invoke()` | Not possible |
| Type identification | `type()`, `isinstance()` | `instanceof`, `Class.isInstance()` | `TypeId`, `Any::downcast_ref` |
| Access private members | Always (no enforcement) | `setAccessible(true)` | Not possible at runtime |
| Framework discovery | Decorators + introspection | Reflection + annotations | Macros + static registration |

The correlation: the more reflection a language provides, the more runtime overhead it incurs and the less static optimization is possible. Rust trades runtime flexibility for compile-time guarantees and performance. Java occupies the middle ground. Python embraces reflection as a core feature.

---

## 5. Annotation and Attribute Systems Compared

Declarative metadata systems — Rust's `#[attributes]`, Java's `@annotations`, Python's decorators-as-annotations — drive code generation and behavior in each language. This section compares how each language attaches metadata to code and how that metadata is processed.

### Rust: The Attribute System

Rust attributes come in two forms: outer attributes (`#[attr]` before an item) and inner attributes (`#![attr]` inside a module/crate).

```rust
// Inner attribute — applies to the enclosing item (crate-level)
#![allow(dead_code)]
#![warn(missing_docs)]

// Outer attributes — apply to the following item
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ApiResponse {
    #[serde(rename = "statusCode")]
    status_code: u32,

    #[serde(skip_serializing_if = "Option::is_none")]
    error_message: Option<String>,

    #[serde(default)]
    data: Vec<Item>,
}

// Conditional compilation
#[cfg(test)]
mod tests {
    #[test]
    fn test_something() {
        assert!(true);
    }
}

// Optimization hints
#[inline(always)]
fn hot_function() -> i32 { 42 }

// Memory layout control
#[repr(C)]
struct FFIStruct {
    x: i32,
    y: f64,
}
```

Built-in attribute categories:

| Category | Examples | Purpose |
|----------|----------|---------|
| Code generation | `#[derive(...)]` | Generate trait implementations |
| Conditional compilation | `#[cfg(...)]`, `#[cfg_attr(...)]` | Include/exclude code based on conditions |
| Lint control | `#[allow(...)]`, `#[warn(...)]`, `#[deny(...)]` | Control compiler warnings |
| Optimization | `#[inline]`, `#[cold]`, `#[must_use]` | Hint to the compiler |
| Testing | `#[test]`, `#[bench]`, `#[ignore]` | Mark test functions |
| Layout | `#[repr(C)]`, `#[repr(packed)]` | Control memory layout |

All attributes are resolved at compile time — no runtime cost.

> **Sources:** [The Rust Reference — Attributes](https://doc.rust-lang.org/reference/attributes.html) · [The Rust Reference — Derive macro helper attributes](https://doc.rust-lang.org/reference/procedural-macros.html#derive-macro-helper-attributes) · [serde — Using derive](https://serde.rs/derive.html) · [serde — Attributes](https://serde.rs/attributes.html)

### Java: The Annotation System

Java annotations are defined as special interfaces (`@interface`) with formal retention policies, targets, and element types.

```java
// Defining an annotation with elements
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.FIELD})
public @interface Column {
    String name() default "";
    boolean nullable() default true;
    int length() default 255;
}

// Using annotations for ORM mapping (JPA-style)
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_name", nullable = false, length = 100)
    private String name;

    @Column(nullable = false)
    @Min(0)
    private int age;
}

// Standard annotations
@FunctionalInterface  // compile-time check: interface has exactly one abstract method
interface Processor<T> {
    T process(T input);
}
```

Key concepts:

- **Element types** supported: primitives, `String`, `Class`, enums, annotations, and arrays thereof.
- **Retention policies:** `SOURCE` (discarded by compiler — e.g., `@Override`), `CLASS` (in bytecode but not at runtime), `RUNTIME` (available via reflection — e.g., `@Entity`).
- **The annotation is passive metadata; the processing framework does the work.** `@Autowired` does nothing alone — Spring's DI container reads it via reflection and injects the dependency.
- **Well-known annotation-driven frameworks:** Spring (`@Autowired`, `@Component`), JPA (`@Entity`, `@Column`), JUnit (`@Test`, `@BeforeEach`), JAX-RS (`@GET`, `@Path`).

> **Sources:** Horstmann (2024) Ch.11 pp. 140–145 · Bloch (2018) Item 39 pp. 180–187 · [Java Language Specification — Annotation Types (JLS 9.6)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.6) · [Project Lombok — Features](https://projectlombok.org/features/) · [Baeldung — Introduction to Project Lombok](https://www.baeldung.com/intro-to-project-lombok) · [Google Auto — AutoValue](https://github.com/google/auto/tree/main/value)

### Python: Decorators and Type Annotations as Metadata

Python lacks a formal annotation system separate from decorators. Instead, it uses multiple mechanisms: decorators as active metadata, type annotations as inspectable metadata, and `__annotations__` dicts.

```python
from typing import Annotated, get_type_hints
from dataclasses import dataclass

# Type annotations as inspectable metadata
@dataclass
class User:
    name: str
    age: Annotated[int, "must be positive"]  # PEP 593: arbitrary metadata on types
    email: str = ""

# Inspect annotations at runtime
hints = get_type_hints(User, include_extras=True)
# {'name': <class 'str'>,
#  'age': typing.Annotated[int, 'must be positive'],
#  'email': <class 'str'>}

# Framework-style: Pydantic uses type annotations for validation
from pydantic import BaseModel, Field

class Product(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    price: float = Field(gt=0)
    tags: list[str] = Field(default_factory=list)
```

Key concepts:

- **Type hints** (PEP 526: `name: str = "default"`) serve as inspectable metadata that tools like `dataclasses` and Pydantic read at runtime.
- **`Annotated[int, Gt(0)]`** (PEP 593) attaches arbitrary metadata to type hints — the closest Python gets to Java-style annotations.
- **`__annotations__`** dict on classes and functions stores type hints, readable at runtime.
- Unlike Java's formal retention policies, Python's "annotations" are ad hoc — type hints, decorators, and class/function attributes serve the same purpose through different mechanisms.

> **Sources:** Martelli et al (2023) Ch.4 pp. 130–145 · [PEP 557 — Data Classes](https://peps.python.org/pep-0557/) · [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/) · [Python docs — `@property`](https://docs.python.org/3/library/functions.html#property) · [`attrs` library documentation](https://www.attrs.org/en/stable/)

### Cross-Language Comparison: Metadata-Driven Code Generation

A serializable data type with validation in all three languages:

**Rust** — compile-time code generation, zero runtime cost:
```rust
#[derive(Serialize, Deserialize)]
struct User {
    #[serde(rename = "user_name")]
    name: String,
    #[validate(range(min = 0))]
    age: u32,
}
```

**Java** — annotations processed by JPA (runtime reflection) and Bean Validation (runtime):
```java
@Entity
public class User {
    @Column(name = "user_name")
    String name;
    @Min(0)
    int age;
}
```

**Python** — runtime decorator + type annotation introspection:
```python
@dataclass
class User:
    name: str
    age: Annotated[int, Gt(0)]
```

All three ecosystems are converging toward declarative, metadata-driven programming. They differ in when and how the metadata is processed.

---

## 6. Descriptors, Properties, and Attribute Access Protocols

Python's descriptor protocol is a fundamental metaprogramming mechanism that controls how attribute access works. Rust's `Deref`/`DerefMut` traits serve a narrower but analogous purpose for smart pointers. Java relies on getter/setter naming conventions rather than a language-level protocol.

### Python: The Descriptor Protocol

A descriptor is any object that defines `__get__`, `__set__`, or `__delete__`. When a class attribute is a descriptor, attribute access on instances triggers the descriptor's methods instead of simple dictionary lookup.

```python
# A reusable validation descriptor
class Validated:
    def __init__(self, min_value=None, max_value=None):
        self.min_value = min_value
        self.max_value = max_value

    def __set_name__(self, owner, name):
        # PEP 487: called when descriptor is assigned to a class attribute
        self.storage_name = f"_{name}"

    def __get__(self, instance, owner):
        if instance is None:
            return self  # accessed from the class, not an instance
        return getattr(instance, self.storage_name, None)

    def __set__(self, instance, value):
        if self.min_value is not None and value < self.min_value:
            raise ValueError(f"Value must be >= {self.min_value}")
        if self.max_value is not None and value > self.max_value:
            raise ValueError(f"Value must be <= {self.max_value}")
        setattr(instance, self.storage_name, value)

class Temperature:
    celsius = Validated(min_value=-273.15)  # descriptor instance

    def __init__(self, celsius):
        self.celsius = celsius  # triggers Validated.__set__

t = Temperature(25.0)     # OK
t.celsius = -300           # raises ValueError
```

Key concepts:

- **Data descriptors** (with `__set__` or `__delete__`) take priority over instance `__dict__`; **non-data descriptors** (only `__get__`) do not.
- **`@property`**, **`@classmethod`**, **`@staticmethod`**, and regular methods are all descriptors. `property` is a data descriptor; functions are non-data descriptors (their `__get__` returns a bound method).
- **`__set_name__`** (PEP 487) is called when a descriptor is assigned to a class attribute, receiving the owner class and attribute name — enabling descriptors that know their own name without explicit configuration.

> **Sources:** Ramalho (2022) Ch.23 pp. 879–906 · Slatkin (2025) Item 60 pp. 274–279 · [Python docs — Descriptor HowTo Guide](https://docs.python.org/3/howto/descriptor.html) · [Python docs — Data Model (implementing descriptors)](https://docs.python.org/3/reference/datamodel.html#implementing-descriptors)

### Python: `@property` and Dynamic Attribute Access

`@property` enables computed attributes that look like plain attribute access — `obj.area` can compute and return a value without the caller knowing it is not stored.

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        return self._radius

    @radius.setter
    def radius(self, value):
        if value < 0:
            raise ValueError("Radius cannot be negative")
        self._radius = value

    @property
    def area(self):
        import math
        return math.pi * self._radius ** 2

c = Circle(5)
print(c.area)    # 78.54... — looks like an attribute, but is computed
c.radius = -1    # raises ValueError


# Proxy pattern with __getattr__
class LazyProxy:
    def __init__(self, factory):
        self._factory = factory
        self._obj = None

    def __getattr__(self, name):
        # Called only when normal lookup fails
        if self._obj is None:
            self._obj = self._factory()
        return getattr(self._obj, name)
```

The power spectrum: `@property` is the simplest (one attribute), descriptors are reusable (shared across attributes), `__getattr__` is the catch-all (any attribute name).

> **Sources:** Ramalho (2022) Ch.22 pp. 835–878 · Slatkin (2025) Items 58–59 pp. 265–274 · Slatkin (2025) Item 61 pp. 279–285 · [Python docs — `property` built-in](https://docs.python.org/3/library/functions.html#property)

### Rust: `Deref` and `DerefMut` as Smart Pointer Protocols

Rust's `Deref` trait enables "deref coercion" — when a type implements `Deref<Target = T>`, references to it can be automatically coerced to `&T`.

```rust
use std::ops::{Deref, DerefMut};

// A newtype wrapper that validates on construction
struct NonEmptyString(String);

impl NonEmptyString {
    fn new(s: &str) -> Result<Self, &'static str> {
        if s.is_empty() {
            Err("String must not be empty")
        } else {
            Ok(NonEmptyString(s.to_string()))
        }
    }
}

impl Deref for NonEmptyString {
    type Target = str;
    fn deref(&self) -> &str {
        &self.0
    }
}

// Now NonEmptyString can be used wherever &str is expected
let name = NonEmptyString::new("Alice").unwrap();
println!("Length: {}", name.len());  // deref coercion: &NonEmptyString → &str
```

Key concepts:

- **Deref coercion:** `Box<String>` can be passed where `&str` is expected (`Box` → `String` → `str` via chain of deref coercions).
- **Not a general property system.** Rust explicitly discourages using `Deref` for general-purpose "smart properties" — the convention is to use `Deref` only for smart pointers.
- **Compile-time and type-directed**, while Python's descriptor protocol is runtime and name-directed.

> **Sources:** [Rust docs — `Deref` trait](https://doc.rust-lang.org/std/ops/trait.Deref.html) · [Rust docs — `DerefMut` trait](https://doc.rust-lang.org/std/ops/trait.DerefMut.html) · [Rust By Example — Operator Overloading](https://doc.rust-lang.org/rust-by-example/trait/ops.html)

### Java: Getter/Setter Conventions and JavaBeans

Java has no language-level property protocol. Instead, it relies on the JavaBeans naming convention: `getX()`/`setX()` methods signal properties to frameworks.

```java
// Traditional JavaBeans pattern
public class Temperature {
    private double celsius;

    public Temperature(double celsius) {
        setCelsius(celsius);  // validate in setter
    }

    public double getCelsius() {
        return celsius;
    }

    public void setCelsius(double celsius) {
        if (celsius < -273.15) {
            throw new IllegalArgumentException("Below absolute zero");
        }
        this.celsius = celsius;
    }
}

// Java records: auto-generated accessors (different naming convention)
public record Point(double x, double y) {
    // Accessor methods: point.x(), point.y() — not getX(), getY()
}

// Lombok generates getters/setters at compile time
@Data  // generates getters, setters, equals, hashCode, toString
public class User {
    private String name;
    private int age;
}
```

Key concepts:

- **`java.beans.Introspector`** uses reflection to discover properties from getter/setter names.
- **No transparent computed properties.** Java requires calling `temp.getCelsius()` explicitly — there is no way to make `temp.celsius` invoke a method transparently.
- Python's descriptors are a language-level protocol that any object can participate in transparently; Java's properties are a naming convention that requires explicit framework support.

> **Sources:** [Java docs — `java.beans` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.desktop/java/beans/package-summary.html) · [Oracle Tutorial — Properties (JavaBeans)](https://docs.oracle.com/javase/tutorial/javabeans/writing/properties.html)

### Cross-Language Comparison

Implementing a validated `Temperature` type with a `celsius` property that enforces a minimum value:

| Approach | Mechanism | Transparency |
|----------|-----------|-------------|
| **Python** | `@property` with a setter that validates, or reusable `ValidatedFloat` descriptor | Fully transparent: `t.celsius = value` |
| **Rust** | Newtype `struct Celsius(f64)` with constructor validation | No runtime protocol needed — invalid values cannot exist |
| **Java** | Private field with `getCelsius()`/`setCelsius()` pair | Requires explicit method calls |

Python customizes access to existing attributes; Rust prevents invalid values from existing; Java wraps access in methods by convention.

---

## 7. Metaclasses and Class Construction Machinery

How are classes themselves created? Python has a full metaclass system where `type` is the default metaclass and custom metaclasses can control every aspect of class creation. Java's class loading mechanism provides hooks during class initialization. Rust's types are defined statically and fully resolved at compile time.

### Python: Metaclasses

In Python, classes are instances of their metaclass. `type` is the default metaclass — `class Foo: pass` is equivalent to `Foo = type('Foo', (), {})`.

```python
# type is the metaclass of all classes
class Foo:
    pass

print(type(Foo))    # <class 'type'>
print(type(type))   # <class 'type'> — type is its own metaclass

# Creating a class dynamically with type()
Bar = type('Bar', (object,), {
    'greet': lambda self: "Hello!",
    'x': 42,
})
b = Bar()
b.greet()  # "Hello!"


# Custom metaclass
class ValidatedMeta(type):
    def __new__(mcs, name, bases, namespace):
        # Enforce that all subclasses define a 'validate' method
        cls = super().__new__(mcs, name, bases, namespace)
        if bases:  # skip the base class itself
            if 'validate' not in namespace:
                raise TypeError(f"{name} must define a validate() method")
        return cls

class BaseModel(metaclass=ValidatedMeta):
    def validate(self):
        pass

class UserModel(BaseModel):
    def validate(self):
        # validates user data
        pass

# class BadModel(BaseModel):  # TypeError: BadModel must define validate()
#     pass


# __prepare__ for custom namespace during class body execution
from collections import OrderedDict

class OrderedMeta(type):
    @classmethod
    def __prepare__(mcs, name, bases):
        return OrderedDict()  # class body uses OrderedDict as namespace

    def __new__(mcs, name, bases, namespace):
        cls = super().__new__(mcs, name, bases, dict(namespace))
        cls._field_order = list(namespace.keys())
        return cls
```

Key concepts:

- **`__new__`** controls class creation; **`__init__`** customizes after creation.
- **`__prepare__`** returns the namespace dict used during class body execution — returning an `OrderedDict` or custom mapping enables tracking definition order or transforming assignments.
- **Production usage:** Django models (`ModelBase` metaclass creates database mappings from field definitions), `abc.ABCMeta` (enforces abstract methods), `enum.EnumMeta` (transforms class body into enum members).
- **Metaclasses should be a last resort** — `__init_subclass__` and class decorators solve most problems more simply (Ramalho, Slatkin).

> **Sources:** Ramalho (2022) Ch.24 pp. 920–956 · Martelli et al (2023) Ch.4 pp. 155–169 · [Python docs — Data Model (metaclasses)](https://docs.python.org/3/reference/datamodel.html#metaclasses) · [PEP 3115 — Metaclasses in Python 3000](https://peps.python.org/pep-3115/) · [Python docs — `type` built-in](https://docs.python.org/3/library/functions.html#type)

### Python: `__init_subclass__` and `__set_name__` as Metaclass Alternatives

PEP 487 (Python 3.6) introduced `__init_subclass__` as a simpler alternative to metaclasses for the common case of customizing subclass creation.

```python
# Plugin registration without a metaclass
class PluginBase:
    _registry: dict[str, type] = {}

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        # Automatically register every subclass
        PluginBase._registry[cls.__name__] = cls

class JSONPlugin(PluginBase):
    pass

class XMLPlugin(PluginBase):
    pass

print(PluginBase._registry)
# {'JSONPlugin': <class 'JSONPlugin'>, 'XMLPlugin': <class 'XMLPlugin'>}


# Validation at subclass definition time
class Serializable:
    def __init_subclass__(cls, format: str = "json", **kwargs):
        super().__init_subclass__(**kwargs)
        if format not in ("json", "xml", "csv"):
            raise ValueError(f"Unsupported format: {format}")
        cls._format = format

class Report(Serializable, format="csv"):
    pass

print(Report._format)  # "csv"
```

Key concepts:

- **`__init_subclass__(cls, **kwargs)`** is called on the parent class whenever a subclass is defined — no custom metaclass needed.
- **`__set_name__`** is called on descriptors when assigned to a class attribute, eliminating the need for metaclasses to wire up descriptor names.
- Together, `__init_subclass__`, `__set_name__`, and class decorators cover ~90% of use cases that previously required metaclasses.

> **Sources:** Slatkin (2025) Items 62–63 pp. 285–299 · Slatkin (2025) Item 64 pp. 299–303 · [PEP 487 — Simpler customisation of class creation](https://peps.python.org/pep-0487/)

### Java: Class Loading and Runtime Class Creation

Java's class loading mechanism is its form of "class construction." The lifecycle — load (read bytes) → link (verify, prepare, resolve) → initialize (run `<clinit>`) — provides hooks for metaprogramming.

```java
// Custom class loader — loading classes from non-standard locations
public class PluginClassLoader extends ClassLoader {
    private final Path pluginDir;

    public PluginClassLoader(Path pluginDir, ClassLoader parent) {
        super(parent);
        this.pluginDir = pluginDir;
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        try {
            Path classFile = pluginDir.resolve(
                name.replace('.', '/') + ".class"
            );
            byte[] bytes = Files.readAllBytes(classFile);
            return defineClass(name, bytes, 0, bytes.length);
        } catch (IOException e) {
            throw new ClassNotFoundException(name, e);
        }
    }
}

// ServiceLoader — the standard plugin discovery mechanism
// META-INF/services/com.example.Plugin lists implementation classes
ServiceLoader<Plugin> plugins = ServiceLoader.load(Plugin.class);
for (Plugin p : plugins) {
    p.execute();
}
```

Key concepts:

- **Three class loaders:** bootstrap (core `java.lang.*`), platform (standard library), application (user code).
- **Custom class loaders enable:** loading from non-standard locations, hot-reloading (Tomcat uses separate loaders per webapp), instrumentation (Java agents modify class bytes during loading via `java.lang.instrument`).
- **Since Java 9,** modules restrict reflective access across module boundaries, changing the class loading landscape.

> **Sources:** Evans et al (2022) Ch.4 pp. 81–101 · [Java docs — `java.lang.ClassLoader`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ClassLoader.html) · [JVM Specification — Loading, Linking, and Initializing (Ch.5)](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html) · [Baeldung — Java Class Loaders](https://www.baeldung.com/java-classloaders)

### Rust: Static Type Definitions

Rust has no metaclass concept. Types are defined statically in source code and fully resolved at compile time. There is no runtime "class object" to inspect or customize.

```rust
// The closest Rust has to class construction customization:

// 1. Derive macros add implementations at compile time
#[derive(Debug, Clone, Default)]
struct Config {
    host: String,
    port: u16,
}

// 2. Builder pattern for complex construction
struct ServerBuilder {
    host: String,
    port: u16,
}

impl ServerBuilder {
    fn new() -> Self {
        ServerBuilder { host: "localhost".into(), port: 8080 }
    }
    fn host(mut self, host: &str) -> Self {
        self.host = host.into();
        self
    }
    fn port(mut self, port: u16) -> Self {
        self.port = port;
        self
    }
    fn build(self) -> Server {
        Server { host: self.host, port: self.port }
    }
}

// 3. Plugin registration via inventory crate (link-time)
// inventory::submit! registers items at link time
// inventory::iter::<T>() iterates them — zero runtime discovery cost
```

The absence of metaclasses is a feature, not a limitation. Rust achieves the same goals through different means: plugin registration uses `inventory` or `linkme` crates, validation uses the type system (invalid states are unrepresentable), and customization uses macros.

> **Sources:** [The Rust Reference — Items](https://doc.rust-lang.org/reference/items.html)

### Cross-Language Comparison: Plugin Registration

| Language | Mechanism | When |
|----------|-----------|------|
| **Python** | `__init_subclass__` — subclass of `Plugin` auto-registered | Runtime (class definition time) |
| **Java** | `ServiceLoader` — declarations in `META-INF/services/` | Runtime (discovered via class loading) |
| **Rust** | `inventory` crate — `inventory::submit!` | Link time (zero runtime discovery cost) |

Python's approach is the most implicit (automatic via subclassing), Java's is the most explicit (manifest files + reflection), Rust's is compile/link-time (zero runtime cost).

---

## 8. AST Manipulation, Bytecode Engineering, and Synthesis

The deepest level of metaprogramming: programmatic code analysis and generation. Python's `ast` module provides runtime access to abstract syntax trees, Rust's proc-macro system operates on token streams during compilation, and Java's bytecode engineering libraries enable creating and modifying classes at the JVM instruction level.

### Python: The `ast` Module and Code Analysis

Python's `ast` module provides programmatic access to the abstract syntax tree at runtime. Source code can be parsed, analyzed, transformed, and recompiled.

```python
import ast

# Parse source code into an AST
source = """
def greet(name):
    return f"Hello, {name}!"
"""

tree = ast.parse(source)
print(ast.dump(tree, indent=2))
# Module(body=[
#   FunctionDef(name='greet', args=..., body=[
#     Return(value=JoinedStr(values=[...]))
#   ])
# ])


# NodeVisitor — walk the tree for analysis
class FunctionCounter(ast.NodeVisitor):
    def __init__(self):
        self.count = 0

    def visit_FunctionDef(self, node):
        self.count += 1
        self.generic_visit(node)  # continue visiting children

counter = FunctionCounter()
counter.visit(tree)
print(f"Found {counter.count} functions")  # 1


# NodeTransformer — modify the tree
class ConstantFolder(ast.NodeTransformer):
    def visit_BinOp(self, node):
        self.generic_visit(node)  # transform children first
        if isinstance(node.left, ast.Constant) and isinstance(node.right, ast.Constant):
            # Evaluate constant expressions at "compile" time
            result = eval(compile(ast.Expression(body=node), '<ast>', 'eval'))
            return ast.Constant(value=result)
        return node

# Compile and execute a modified AST
modified_tree = ConstantFolder().visit(ast.parse("x = 2 + 3"))
ast.fix_missing_locations(modified_tree)
code = compile(modified_tree, '<ast>', 'exec')
exec(code)  # x is now 5, but 2+3 was folded at parse time


# ast.unparse() — convert AST back to source code (Python 3.9+)
source_back = ast.unparse(tree)
```

Key concepts:

- **`ast.parse(source)`** → AST, **`ast.NodeVisitor`** for analysis, **`ast.NodeTransformer`** for modification, **`compile(tree, filename, mode)`** → code object for `exec()`.
- **Use cases:** linting (pylint, flake8), formatting (black), test coverage (coverage.py), security analysis (detecting dangerous patterns).
- **AST is structural, not textual** — formatting is lost; `ast.unparse()` regenerates clean source.
- Compare with Rust: Python's AST is available at runtime and can be manipulated by user code; Rust's AST is only available during compilation within proc macros.

> **Sources:** Shaw (2021) Ch.5 pp. 91–117 · [Python docs — `ast` module](https://docs.python.org/3/library/ast.html) · [Green Tree Snakes — the missing Python AST docs](https://greentreesnakes.readthedocs.io/en/latest/)

### Python: `dis`, Bytecode Inspection, and `exec`/`eval`

CPython compiles source to bytecode for its stack-based virtual machine. The `dis` module enables bytecode inspection, and `exec()`/`eval()` enable runtime code execution.

```python
import dis

def add(a, b):
    return a + b

# Disassemble to see bytecode
dis.dis(add)
#   LOAD_FAST    0 (a)
#   LOAD_FAST    1 (b)
#   BINARY_ADD
#   RETURN_VALUE

# exec() — compile and execute a string as Python code
exec("result = 2 + 3")
print(result)  # 5

# eval() — evaluate a single expression
value = eval("2 ** 10")  # 1024

# Safer: parse first, then compile and execute
tree = ast.parse("x = [i**2 for i in range(10)]", mode='exec')
code = compile(tree, '<string>', 'exec')
exec(code)
print(x)  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

Key concepts:

- **`exec()`/`eval()` are security risks** (code injection) and debugging nightmares (no source mapping). Prefer `ast.parse()` + `compile()` + `exec()` for safer code generation.
- **Libraries like Numba** use bytecode analysis to JIT-compile Python to machine code.
- CPython bytecode is an implementation detail — not a stable API across versions.

> **Sources:** Shaw (2021) Ch.6 pp. 118–150 · Shaw (2021) Ch.7 pp. 151–175 · [Python docs — `compile` built-in](https://docs.python.org/3/library/functions.html#compile) · [Python docs — `exec` built-in](https://docs.python.org/3/library/functions.html#exec) · [Python docs — `dis` module](https://docs.python.org/3/library/dis.html)

### Rust: Proc-Macro Token Streams and `syn`/`quote`

Rust's proc macros operate on `TokenStream` — a sequence of token trees. The `syn` crate parses them into strongly-typed AST nodes, and `quote!` generates new token streams via quasi-quoting.

```rust
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput, Data, Fields};

// A derive macro that generates a method listing field names
#[proc_macro_derive(FieldNames)]
pub fn derive_field_names(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;

    // Extract field names from the struct
    let field_names: Vec<String> = match &input.data {
        Data::Struct(data) => match &data.fields {
            Fields::Named(fields) => fields.named.iter()
                .map(|f| f.ident.as_ref().unwrap().to_string())
                .collect(),
            _ => vec![],
        },
        _ => panic!("FieldNames can only be derived for structs"),
    };

    let expanded = quote! {
        impl #name {
            pub fn field_names() -> &'static [&'static str] {
                &[#(#field_names),*]
            }
        }
    };

    TokenStream::from(expanded)
}
```

Key concepts:

- **`syn`** provides parsing into `DeriveInput`, `ItemFn`, `Expr`, etc. with full span information for error reporting.
- **`quote!`** quasi-quoting: `quote! { impl #name { fn new() -> Self { ... } } }` generates a `TokenStream` with interpolated values. Repetition: `#(#items),*` expands a collection.
- **`build.rs` scripts** provide another code generation path: they run before compilation and can generate `.rs` files from schemas, protobufs, or other inputs.
- Unlike Python's `ast` module (runtime), Rust's proc macros run only during compilation — user code cannot parse or generate Rust code at runtime.

> **Sources:** [`proc_macro` standard library docs](https://doc.rust-lang.org/proc_macro/) · [`syn` crate](https://docs.rs/syn/latest/syn/) · [`quote` crate](https://docs.rs/quote/latest/quote/) · [Rust `build.rs` build scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)

### Java: Bytecode Engineering with ASM and Byte Buddy

Java bytecode engineering libraries enable creating and modifying classes at the JVM instruction level — below source code, at the bytecode level.

```java
// Byte Buddy — high-level bytecode generation API
import net.bytebuddy.ByteBuddy;
import net.bytebuddy.implementation.FixedValue;
import static net.bytebuddy.matcher.ElementMatchers.named;

// Create a new class at runtime
Class<?> dynamicType = new ByteBuddy()
    .subclass(Object.class)
    .name("com.example.Generated")
    .method(named("toString"))
    .intercept(FixedValue.value("Hello from generated class!"))
    .make()
    .load(getClass().getClassLoader())
    .getLoaded();

Object instance = dynamicType.getDeclaredConstructor().newInstance();
System.out.println(instance);  // "Hello from generated class!"


// Java agents — transform classes as they are loaded
// (in a premain or agentmain method)
import java.lang.instrument.*;

public class ProfilingAgent {
    public static void premain(String args, Instrumentation inst) {
        inst.addTransformer((loader, className, classBeingRedefined,
                            protectionDomain, classfileBuffer) -> {
            // Transform bytecode here (using ASM or Byte Buddy)
            // Add timing code to every method, for example
            return classfileBuffer;  // return modified bytes
        });
    }
}
```

Key concepts:

- **ASM** is the lowest-level library — visitor-based API for reading/writing class files, used internally by Spring, Hibernate, Mockito.
- **Byte Buddy** is a higher-level API built on ASM — more readable, safer, preferred for most use cases.
- **Java agents** (`java.lang.instrument`) use bytecode engineering to transform classes as they are loaded — enabling profiling, monitoring, and AOP (aspect-oriented programming).
- **Unique capability:** Java can create entirely new classes at runtime from bytecode — something neither Rust (no runtime code generation) nor Python (creates classes via `type()` but not from bytecode) can do natively.

> **Sources:** Evans et al (2022) Ch.4 pp. 90–111 · Horstmann (2024) Ch.11 pp. 148–149 · [ASM bytecode engineering library — Guide](https://asm.ow2.io/asm4-guide.pdf) · [Byte Buddy — Tutorial](https://bytebuddy.net/#/tutorial) · [`javassist` library](https://www.javassist.org/) · [JVM Specification — Class File Format (Ch.4)](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html)

### Synthesis: The Metaprogramming Spectrum

The three languages represent distinct philosophies about which layer of the language is programmable:

**Rust — compile-time only.** Macros (`macro_rules!` and proc macros) generate code before type checking. Zero runtime cost. No reflection. The programmer explicitly opts into every piece of code generation via `#[derive]` or macro invocations. The compiler is the programmable layer.

**Java — dual approach.** Annotations provide compile-time metadata for annotation processors (code generation) and runtime metadata for reflection-based frameworks. Bytecode engineering enables runtime class creation. `invokedynamic` bridges compile-time and runtime. The class loader and bytecode are the programmable layers.

**Python — runtime-first.** Decorators, metaclasses, descriptors, `ast` module, `exec()` all operate at runtime. Everything is introspectable and mutable. Maximum flexibility at the cost of performance and static analysis. The language itself is a mutable runtime — the entire object model is programmable.

| Dimension | Rust | Java | Python |
|-----------|------|------|--------|
| **Primary approach** | Compile-time macros | Annotations + reflection + bytecode | Runtime decorators, metaclasses, AST |
| **Programmable layer** | The compiler | Class loader and bytecode | The entire runtime |
| **Reflection** | Near-zero (`TypeId` only) | Rich (`java.lang.reflect`) | Pervasive (`inspect`, `dir`, `getattr`) |
| **Code generation** | Proc macros, `build.rs` | Annotation processors, Byte Buddy | Decorators, `exec()`, `ast` module |
| **Runtime cost** | Zero | Moderate (reflection overhead) | Highest (everything is dynamic) |
| **Static analysis** | Maximum (all types resolved at compile time) | Good (annotations checked, reflection escapes) | Limited (dynamic typing) |
| **Core value** | Safety and performance | Platform stability | Flexibility and expressiveness |

The key insight: metaprogramming is about which layer of the language is programmable. Each approach reflects the language's core values — and each trade-off is deliberate.

---

## Sources

### Books

**Rust**
- Klabnik & Nichols (2023) — *The Rust Programming Language*: Ch.19 pp. 419–458 (macros), Appendix C pp. 507–510 (derivable traits)
- Blandy & Orendorff (2017) — *Programming Rust*: Ch.20 pp. 499–523 (macros), Ch.13 pp. 285–290 (Deref)
- Gjengset (2022) — *Rust for Rustaceans*: Ch.7 pp. 101–115 (declarative and procedural macros)

**Java**
- Horstmann (2024) — *Core Java, Vol. I*: Ch.11 pp. 140–149 (annotations), Ch.5.10 pp. 80–81 (reflection)
- Bloch (2018) — *Effective Java*: Item 39 pp. 180–187 (annotations vs naming patterns), Item 65 p. 283 (interfaces vs reflection)
- Evans et al (2022) — *The Well-Grounded Java Developer*: Ch.4 pp. 81–117 (class loading, reflection), Ch.17 pp. 571–607 (method handles, invokedynamic)

**Python**
- Ramalho (2022) — *Fluent Python*: Ch.9 pp. 303–340 (decorators), Ch.22 pp. 835–878 (dynamic attributes), Ch.23 pp. 879–906 (descriptors), Ch.24 pp. 907–956 (metaclasses)
- Martelli et al (2023) — *Python in a Nutshell*: Ch.4 pp. 115–169 (OOP, decorators, metaclasses)
- Slatkin (2025) — *Effective Python*: Item 38 p. 166 (functools.wraps), Ch.8 pp. 265–318 (metaclasses and attributes)
- Shaw (2021) — *CPython Internals*: Ch.5 pp. 91–117 (AST), Ch.6 pp. 118–150 (compiler), Ch.7 pp. 151–175 (evaluation loop)

### External Resources

**Rust**
- [The Rust Reference — Attributes](https://doc.rust-lang.org/reference/attributes.html)
- [The Rust Reference — Macros By Example](https://doc.rust-lang.org/reference/macros-by-example.html)
- [The Rust Reference — Procedural Macros](https://doc.rust-lang.org/reference/procedural-macros.html)
- [The Rust Reference — Procedural Macros (attribute macros)](https://doc.rust-lang.org/reference/procedural-macros.html#attribute-macros)
- [The Rust Reference — Derive macro helper attributes](https://doc.rust-lang.org/reference/procedural-macros.html#derive-macro-helper-attributes)
- [The Rust Reference — Items](https://doc.rust-lang.org/reference/items.html)
- [The Little Book of Rust Macros](https://veykril.github.io/tlborm/)
- [Rust By Example — Attributes](https://doc.rust-lang.org/rust-by-example/attribute.html)
- [Rust By Example — macro_rules!](https://doc.rust-lang.org/rust-by-example/macros.html)
- [Rust By Example — Derive](https://doc.rust-lang.org/rust-by-example/trait/derive.html)
- [Rust By Example — Operator Overloading](https://doc.rust-lang.org/rust-by-example/trait/ops.html)
- [Rust docs — `std::any::Any`](https://doc.rust-lang.org/std/any/trait.Any.html)
- [Rust docs — `std::any::TypeId`](https://doc.rust-lang.org/std/any/struct.TypeId.html)
- [Rust docs — `Deref` trait](https://doc.rust-lang.org/std/ops/trait.Deref.html)
- [Rust docs — `DerefMut` trait](https://doc.rust-lang.org/std/ops/trait.DerefMut.html)
- [`proc_macro` standard library docs](https://doc.rust-lang.org/proc_macro/)
- [`syn` crate documentation](https://docs.rs/syn/latest/syn/)
- [`quote` crate documentation](https://docs.rs/quote/latest/quote/)
- [`proc-macro2` crate documentation](https://docs.rs/proc-macro2/latest/proc_macro2/)
- [David Tolnay — `proc-macro-workshop`](https://github.com/dtolnay/proc-macro-workshop)
- [serde — Using derive](https://serde.rs/derive.html)
- [serde — Attributes](https://serde.rs/attributes.html)
- [Rust `build.rs` build scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)
- [LogRocket — "Macros in Rust: A tutorial with examples"](https://blog.logrocket.com/macros-in-rust-a-tutorial-with-examples/)

**Java**
- [Java Language Specification — Annotations (JLS 9.7)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.7)
- [Java Language Specification — Annotation Types (JLS 9.6)](https://docs.oracle.com/javase/specs/jls/se21/html/jls-9.html#jls-9.6)
- [JVM Specification — Loading, Linking, and Initializing (Ch.5)](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-5.html)
- [JVM Specification — Class File Format (Ch.4)](https://docs.oracle.com/javase/specs/jvms/se21/html/jvms-4.html)
- [Oracle Tutorial — Annotations](https://docs.oracle.com/javase/tutorial/java/annotations/)
- [Oracle Tutorial — The Reflection API](https://docs.oracle.com/javase/tutorial/reflect/)
- [Oracle — Annotation Processing Tool Tutorial](https://docs.oracle.com/javase/8/docs/technotes/guides/apt/)
- [Oracle Tutorial — Properties (JavaBeans)](https://docs.oracle.com/javase/tutorial/javabeans/writing/properties.html)
- [Java docs — `java.lang.reflect`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/reflect/package-summary.html)
- [Java docs — `java.lang.Class`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Class.html)
- [Java docs — `java.lang.ClassLoader`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/ClassLoader.html)
- [Java docs — `java.beans` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.desktop/java/beans/package-summary.html)
- [`javax.annotation.processing` Javadoc](https://docs.oracle.com/en/java/javase/21/docs/api/java.compiler/javax/annotation/processing/package-summary.html)
- [Baeldung — Custom Annotations in Java](https://www.baeldung.com/java-custom-annotation)
- [Baeldung — Java Annotation Processing and Creating a Builder](https://www.baeldung.com/java-annotation-processing-builder)
- [Baeldung — Guide to Java Reflection](https://www.baeldung.com/java-reflection)
- [Baeldung — Introduction to Project Lombok](https://www.baeldung.com/intro-to-project-lombok)
- [Baeldung — Java Class Loaders](https://www.baeldung.com/java-classloaders)
- [Project Lombok — Features](https://projectlombok.org/features/)
- [Google Auto — AutoValue](https://github.com/google/auto/tree/main/value)
- [ASM bytecode engineering library — Guide](https://asm.ow2.io/asm4-guide.pdf)
- [Byte Buddy — Tutorial](https://bytebuddy.net/#/tutorial)
- [`javassist` library](https://www.javassist.org/)

**Python**
- [Python docs — Compound statements (function and class decorators)](https://docs.python.org/3/reference/compound_stmts.html#function-definitions)
- [Python docs — Data Model](https://docs.python.org/3/reference/datamodel.html)
- [Python docs — Data Model (metaclasses)](https://docs.python.org/3/reference/datamodel.html#metaclasses)
- [Python docs — Data Model (implementing descriptors)](https://docs.python.org/3/reference/datamodel.html#implementing-descriptors)
- [Python docs — Descriptor HowTo Guide](https://docs.python.org/3/howto/descriptor.html)
- [Python docs — `functools.wraps`](https://docs.python.org/3/library/functools.html#functools.wraps)
- [Python docs — `functools.singledispatch`](https://docs.python.org/3/library/functools.html#functools.singledispatch)
- [Python docs — `inspect` module](https://docs.python.org/3/library/inspect.html)
- [Python docs — `ast` module](https://docs.python.org/3/library/ast.html)
- [Python docs — `dis` module](https://docs.python.org/3/library/dis.html)
- [Python docs — `dataclasses` module](https://docs.python.org/3/library/dataclasses.html)
- [Python docs — Built-in functions](https://docs.python.org/3/library/functions.html)
- [Python docs — `property` built-in](https://docs.python.org/3/library/functions.html#property)
- [Python docs — `type` built-in](https://docs.python.org/3/library/functions.html#type)
- [Python docs — `compile` built-in](https://docs.python.org/3/library/functions.html#compile)
- [Python docs — `exec` built-in](https://docs.python.org/3/library/functions.html#exec)
- [PEP 318 — Decorators for Functions and Methods](https://peps.python.org/pep-0318/)
- [PEP 487 — Simpler customisation of class creation](https://peps.python.org/pep-0487/)
- [PEP 557 — Data Classes](https://peps.python.org/pep-0557/)
- [PEP 681 — Data Class Transforms](https://peps.python.org/pep-0681/)
- [PEP 3115 — Metaclasses in Python 3000](https://peps.python.org/pep-3115/)
- [PEP 3129 — Class Decorators](https://peps.python.org/pep-3129/)
- [`attrs` library documentation](https://www.attrs.org/en/stable/)
- [Green Tree Snakes — the missing Python AST docs](https://greentreesnakes.readthedocs.io/en/latest/)

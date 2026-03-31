# Layer 2 · Topic 7 — Error Handling

> Comparative study of Rust, Java, and Python: how each language represents, propagates, and recovers from errors — from Rust's type-driven `Result<T, E>` and `?` operator through Java's checked/unchecked exception hierarchy to Python's EAFP-oriented exception model and modern exception groups.

---

## 1. Error Philosophy: Exceptions vs Values

The most fundamental design choice in error handling is whether errors are **values** (data returned from functions) or **events** (control-flow disruptions that unwind the call stack). Rust chose values; Java and Python chose exceptions — but for different reasons and with different tradeoffs.

### Rust: Errors as Values in the Type System

Rust has no exceptions. Every function that can fail returns `Result<T, E>` — an enum with two variants: `Ok(T)` for success and `Err(E)` for failure. The compiler enforces error handling through the `#[must_use]` attribute on `Result`: ignoring a `Result` produces a compiler warning.

This design follows directly from Rust's core philosophy — **zero hidden control flow**. When you read a Rust function, every possible error path is visible in the types. A function signature `fn read_file(path: &str) -> Result<String, io::Error>` tells you exactly what can go wrong and what the error type is. There are no invisible `throws` declarations and no exceptions that might fly out of any function call.

Rust divides errors into two categories:
- **Recoverable errors** — represented by `Result<T, E>`. File not found, invalid input, network timeout. The caller decides how to handle them.
- **Unrecoverable errors** — represented by `panic!`. Programming bugs, violated invariants, states that should never occur. The thread terminates.

```rust
use std::fs::File;

fn main() {
    // The return type tells you this can fail
    let file: Result<File, std::io::Error> = File::open("hello.txt");

    match file {
        Ok(f) => println!("Opened: {:?}", f),
        Err(e) => println!("Error: {}", e),
    }
}
```

The Rust Book describes this as making "error handling a first-class part of your program's logic rather than an afterthought." The compiler warns when code ignores a `Result` — you must explicitly handle, propagate, or discard the error.

> **Sources:** Klabnik & Nichols (2023) Ch.9 pp. 161–163 · Blandy & Orendorff (2017) Ch.7 pp. 145–148 · [Rust Book — Error Handling](https://doc.rust-lang.org/book/ch09-00-error-handling.html) · [Rust By Example — Error handling](https://doc.rust-lang.org/rust-by-example/error.html) · [Andrew Gallant — "Error Handling in Rust"](https://blog.burntsushi.net/rust-error-handling/)

### Java: Checked and Unchecked Exceptions

Java chose exceptions as its primary error mechanism, with a unique twist — **checked exceptions** enforce compile-time handling. The Java Language Specification (§11) defines the exception class hierarchy:

```
Throwable
├── Error (unchecked — unrecoverable: OutOfMemoryError, StackOverflowError)
└── Exception
    ├── RuntimeException (unchecked — programming errors)
    │   ├── NullPointerException
    │   ├── IllegalArgumentException
    │   ├── IndexOutOfBoundsException
    │   └── ClassCastException
    └── IOException, SQLException, ... (checked — recoverable)
```

**Checked exceptions** (all `Exception` subclasses except `RuntimeException`) must be either caught with `try`/`catch` or declared with `throws`. This is the compiler's way of enforcing error acknowledgment — conceptually similar to Rust's `#[must_use]` on `Result`, but enforced at the method level rather than at each call site.

**Unchecked exceptions** (`RuntimeException` subclasses) represent programming errors — calling a method with invalid arguments, dereferencing null, accessing an array out of bounds. The JLS rationale for not requiring these in `throws` clauses: "declaring them would not aid significantly in establishing the correctness of programs."

**Errors** (`Error` subclasses) represent conditions that a reasonable application should not try to recover from — the JVM running out of memory, stack overflow, internal errors.

```java
// Checked exception — compiler enforces handling
public String readFile(String path) throws IOException {
    return new String(Files.readAllBytes(Paths.get(path)));
}

// Caller must handle or propagate
try {
    String content = readFile("data.txt");
} catch (IOException e) {
    System.err.println("Failed to read: " + e.getMessage());
}
```

Bloch's *Effective Java* (Item 69) states the fundamental rule: "exceptions are, as their name implies, to be used only for exceptional conditions; they should never be used for ordinary control flow." This stands in sharp contrast to Python's philosophy.

> **Sources:** Bloch (2018) Ch.10 pp. 293–296 (Items 69–70) · Horstmann (2024) Ch.7 pp. 94–98 · [JLS §11 — Exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html) · [Oracle Tutorial — Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/index.html)

### Python: EAFP and Exceptions as Normal Control Flow

Python takes the opposite stance from Java's Item 69 — exceptions are a **normal control flow mechanism**, not reserved for exceptional conditions. This is codified in the Python glossary as **EAFP** (Easier to Ask for Forgiveness than Permission):

> A common Python coding style which assumes the existence of valid keys or attributes and catches exceptions if the assumption proves false. This clean and fast style is characterized by the presence of many `try` and `except` statements.

The alternative style, **LBYL** (Look Before You Leap), checks preconditions before acting:

```python
# LBYL — check first, then act
if key in mapping:
    return mapping[key]

# EAFP — act first, handle failure
try:
    return mapping[key]
except KeyError:
    return default_value
```

EAFP is preferred in Python for three reasons: (1) it avoids the double-lookup in LBYL, (2) it complements duck typing — you don't care about the type, you care about whether the operation works, and (3) it is **thread-safe** — LBYL introduces a race condition between the check and the action.

Python's exception hierarchy descends from `BaseException`:

```
BaseException
├── BaseExceptionGroup          (3.11+)
├── GeneratorExit
├── KeyboardInterrupt
├── SystemExit
└── Exception
    ├── ArithmeticError (ZeroDivisionError, OverflowError)
    ├── AttributeError
    ├── EOFError
    ├── ExceptionGroup          (3.11+)
    ├── ImportError (ModuleNotFoundError)
    ├── LookupError (IndexError, KeyError)
    ├── MemoryError
    ├── NameError (UnboundLocalError)
    ├── OSError (FileNotFoundError, PermissionError, TimeoutError, ...)
    ├── RuntimeError (NotImplementedError, RecursionError)
    ├── StopIteration
    ├── StopAsyncIteration
    ├── TypeError
    ├── ValueError (UnicodeError)
    └── Warning (DeprecationWarning, RuntimeWarning, ...)
```

Python has **no checked exceptions** — all exceptions are unchecked. There is no `throws` equivalent. The canonical example of exceptions as control flow: `StopIteration` signals the end of iteration in every `for` loop. Every `for x in collection:` internally catches `StopIteration` — exceptions are the mechanism, not the anomaly.

> **Sources:** Martelli et al (2023) Ch.6 pp. 195–200 · [Python docs — Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html) · [Python docs — Built-in Exceptions](https://docs.python.org/3/library/exceptions.html) · [Python Glossary — EAFP](https://docs.python.org/3/glossary.html#term-EAFP) · [Python Glossary — LBYL](https://docs.python.org/3/glossary.html#term-LBYL)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Error representation** | Values (`Result<T, E>`, `Option<T>`) | Events (exceptions + `throws`) | Events (exceptions) |
| **Compiler enforcement** | `#[must_use]` warns on ignored Result | Checked exceptions must be caught/declared | None — all exceptions are unchecked |
| **Hidden control flow** | None — `?` is visible in code | Yes — any method can throw unchecked exceptions | Yes — any function can raise anything |
| **Philosophy** | Errors are expected outcomes | Exceptions are for exceptional conditions | Exceptions are normal control flow (EAFP) |
| **Can errors be silently ignored?** | Warning on ignored Result; `.ok()` is explicit | Empty `catch {}` silences | Bare `except: pass` silences |
| **Performance cost model** | Zero-cost when no error; enum discriminant check | Zero cost on success path; expensive stack unwinding on throw | Zero cost on success path; moderate cost on raise |

---

## 2. Basic Error Handling Syntax

The fundamental mechanisms: `Result<T, E>` with `match`/`unwrap`/`expect` in Rust, `try`/`catch`/`finally` in Java, and `try`/`except`/`else`/`finally` in Python.

### Rust: `Result<T, E>` and `Option<T>`

`Result<T, E>` is an enum defined in the standard library:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

**Pattern matching** is the most explicit way to handle a `Result`:

```rust
use std::fs::File;
use std::io::ErrorKind;

let file = match File::open("hello.txt") {
    Ok(file) => file,
    Err(error) => match error.kind() {
        ErrorKind::NotFound => match File::create("hello.txt") {
            Ok(fc) => fc,
            Err(e) => panic!("Could not create file: {e:?}"),
        },
        other => panic!("Could not open file: {other:?}"),
    },
};
```

**Shortcut methods** for common patterns:

| Method | Behavior on Err/None | Use When |
|--------|---------------------|----------|
| `unwrap()` | Panics with generic message | Tests, prototypes |
| `expect("msg")` | Panics with custom message | Impossible failures with context |
| `unwrap_or(default)` | Returns default value | Known fallback exists |
| `unwrap_or_default()` | Returns `T::default()` | Type has sensible Default |
| `unwrap_or_else(f)` | Calls closure for default | Fallback needs computation |

**Combinator methods** on `Result` enable functional-style chaining:

```rust
let content: Result<usize, io::Error> = std::fs::read_to_string("file.txt")
    .map(|s| s.len())               // transform Ok value
    .map_err(|e| {                   // transform Err value
        eprintln!("Warning: {e}");
        e
    });
```

Key combinators: `map`, `map_err`, `and_then` (flatmap for chaining fallible operations), `or_else` (try alternative on error), `ok()` (convert to `Option<T>`), `transpose()` (swap `Result<Option<T>, E>` ↔ `Option<Result<T, E>>`).

**`Option<T>`** is the parallel type for absent values — `Some(T)` or `None`. It has the same combinator API shape as `Result`. Converting between them:

```rust
let opt: Option<i32> = Some(42);
let res: Result<i32, &str> = opt.ok_or("value was None");

let res: Result<i32, &str> = Ok(42);
let opt: Option<i32> = res.ok();  // discards the error
```

**Null Pointer Optimization:** For types like `&T`, `Box<T>`, and `NonZero*`, `Option<T>` has the same size as `T` — zero memory overhead.

**Collecting into Result:**

```rust
let results = vec![Ok(1), Ok(2), Err("bad"), Ok(4)];
let collected: Result<Vec<i32>, &str> = results.into_iter().collect();
assert_eq!(collected, Err("bad")); // stops at first error
```

> **Sources:** Klabnik & Nichols (2023) Ch.9 pp. 164–172 · Blandy & Orendorff (2017) Ch.7 pp. 148–155 · [Rust std — Result](https://doc.rust-lang.org/std/result/index.html) · [Rust std — Option](https://doc.rust-lang.org/std/option/index.html) · [Rust By Example — Result](https://doc.rust-lang.org/rust-by-example/error/result.html)

### Java: try / catch / finally

Java's fundamental error handling construct is `try`/`catch`/`finally`:

```java
try {
    // Code that might throw
    String content = Files.readString(Path.of("data.txt"));
    process(content);
} catch (FileNotFoundException e) {
    // Specific exception first
    System.err.println("File missing: " + e.getMessage());
} catch (IOException e) {
    // More general exception second
    System.err.println("I/O error: " + e.getMessage());
} finally {
    // Always executes — cleanup code
    System.out.println("Done.");
}
```

**Key rules:**

- **Catch order matters** — more specific exceptions must come before more general ones. `catch (IOException e)` before `catch (FileNotFoundException e)` is a compile-time error (FileNotFoundException is unreachable).
- **Multi-catch** (Java 7+) handles multiple unrelated exceptions: `catch (IOException | SQLException e)`. The catch parameter is effectively `final`.
- **finally always executes** — even if `try` or `catch` contains `return`. But if `finally` contains `return`, it overrides any prior `return`. If `finally` throws, the original exception is **lost** (this is a critical flaw fixed by try-with-resources).
- **Polymorphic catching** — `catch (Exception e)` catches `Exception` and all its subclasses. This is the Java equivalent of Python's `except Exception:`.

**Common anti-patterns** identified by Bloch and Valeev:

```java
// Anti-pattern 1: swallowing exceptions
try { riskyOp(); } catch (Exception e) { }  // NEVER do this

// Anti-pattern 2: catching too broadly
try { riskyOp(); } catch (Throwable t) { }  // catches OutOfMemoryError!

// Anti-pattern 3: using exceptions for control flow
try {
    int i = 0;
    while(true) array[i++]++;  // uses ArrayIndexOutOfBoundsException to exit
} catch (ArrayIndexOutOfBoundsException e) { }
```

> **Sources:** Horstmann (2024) Ch.7 pp. 96–102 · Valeev (2024) Ch.5 pp. 124–140 · Bloch (2018) Ch.10 pp. 293–296 · [Oracle Tutorial — Catching and Handling](https://docs.oracle.com/javase/tutorial/essential/exceptions/handling.html) · [JLS §11 — Exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html)

### Python: try / except / else / finally

Python's `try` statement has a unique `else` clause not found in Java or Rust:

```python
try:
    file = open("data.txt")
    content = file.read()
except FileNotFoundError:
    print("File not found")
except PermissionError as e:
    print(f"Permission denied: {e}")
else:
    # Runs ONLY if try completed without exception
    # Exceptions here are NOT caught by the above except clauses
    process(content)
finally:
    # Always runs
    print("Done.")
```

**Execution flow:**
1. Execute `try` block
2. If no exception → skip `except` → run `else` → run `finally`
3. If exception → check `except` clauses in order → first `isinstance` match wins → run `finally`
4. `finally` always runs regardless of exceptions, `return`, `break`, or `continue`

**The `else` clause** is Python's unique contribution. It separates "code that might fail" (in `try`) from "code that should run on success" (in `else`). Exceptions raised in `else` are not caught by the preceding `except` handlers — this prevents accidentally catching unrelated exceptions.

**Exception matching uses `isinstance()`** — catching a parent class catches all children:

```python
try:
    int("abc")
except (ValueError, TypeError):  # tuple for multiple types
    print("Bad input")

# Catching base class catches subclasses
try:
    open("/nonexistent")
except OSError:  # catches FileNotFoundError, PermissionError, etc.
    print("OS error")
```

**Critical anti-patterns:**

```python
# NEVER: catches KeyboardInterrupt and SystemExit
except:
    pass

# BAD: silences all exceptions
except Exception:
    pass

# OK: catches all exceptions with logging
except Exception as e:
    logger.exception("Unexpected error: %s", e)
    raise  # re-raise after logging
```

**The `as` keyword** captures the exception object. The variable is **deleted** at the end of the `except` clause (to break reference cycles with the traceback):

```python
except ValueError as e:
    saved = e       # save reference if needed outside the block
    print(e)
# e is deleted here
```

> **Sources:** Martelli et al (2023) Ch.6 pp. 200–210 · [Python docs — The try statement](https://docs.python.org/3/reference/compound_stmts.html#the-try-statement) · [Python docs — Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Primary construct** | `match` on `Result`/`Option` | `try`/`catch`/`finally` | `try`/`except`/`else`/`finally` |
| **Error type** | `Result<T, E>` (explicit enum) | Exception class hierarchy | Exception class hierarchy |
| **Success-only block** | Pattern match on `Ok(value)` | No equivalent | `else` clause |
| **Cleanup block** | Automatic via Drop (RAII) | `finally` | `finally` |
| **Ignored error detection** | Compiler warning (`#[must_use]`) | None (empty catch compiles) | None (bare except compiles) |
| **Matching specificity** | `match` is exhaustive | Most specific catch first | `isinstance` matching, first match wins |
| **Multi-error handling** | `match` with `\|` patterns | Multi-catch: `catch (A \| B e)` | Tuple: `except (A, B) as e:` |

---

## 3. Unrecoverable Errors: panic!, Error, and Fatal Exceptions

Every language needs a mechanism for errors that cannot be recovered from — programming bugs, violated invariants, and catastrophic failures.

### Rust: panic! and unwinding

`panic!` terminates the current thread by unwinding the stack — calling destructors for all local variables in reverse declaration order. This ensures resources are released even on unrecoverable errors.

```rust
fn main() {
    panic!("crash and burn");  // explicit panic

    let v = vec![1, 2, 3];
    v[99];  // implicit panic: index out of bounds
}
```

**Unwinding vs aborting:** By default, panic unwinds the stack (calling destructors). You can configure `panic = 'abort'` in `Cargo.toml` to immediately terminate without unwinding — smaller binaries, faster crashes, but no cleanup:

```toml
[profile.release]
panic = 'abort'
```

**`catch_unwind`** can catch panics at boundaries (FFI, thread pools) but is not for general error handling:

```rust
use std::panic;

let result = panic::catch_unwind(|| {
    panic!("oh no!");
});
assert!(result.is_err());

// Critical: unwinding across FFI boundaries is undefined behavior!
```

`catch_unwind` only catches unwinding panics (not abort panics). The closure must be `UnwindSafe` — use `AssertUnwindSafe` wrapper if needed. Custom panic hooks can be installed with `set_hook()` for logging or error reporting before the unwind.

**When to panic vs when to return Result:**

| Situation | Use |
|-----------|-----|
| Expected failure (file not found, parse error, network timeout) | `Result<T, E>` |
| Programming bug (invariant violation, unreachable code) | `panic!` |
| Tests and prototypes | `unwrap()` / `expect()` |
| Hardcoded valid values: `"127.0.0.1".parse::<IpAddr>()` | `expect()` |
| Library code | Almost always `Result` |
| Constructor with validation | `panic!` if invariant is type-level (e.g., `Guess::new(val)`) |

**Encoding invariants in types** avoids runtime error handling entirely:

```rust
pub struct Guess {
    value: i32,  // private field
}

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 || value > 100 {
            panic!("Guess must be 1–100, got {value}.");
        }
        Guess { value }
    }
    pub fn value(&self) -> i32 { self.value }
}
// Functions accepting Guess need no further validation
```

> **Sources:** Klabnik & Nichols (2023) Ch.9 pp. 161–164, 175–179 · Blandy & Orendorff (2017) Ch.7 pp. 145–148 · [Rust Book — Unrecoverable Errors with panic!](https://doc.rust-lang.org/book/ch09-01-unrecoverable-errors-with-panic.html) · [Rust Book — To panic! or Not to panic!](https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html) · [Rust std — std::panic](https://doc.rust-lang.org/std/panic/index.html) · [Rust std — catch_unwind](https://doc.rust-lang.org/std/panic/fn.catch_unwind.html) · [Rustonomicon — Unwinding](https://doc.rust-lang.org/nomicon/unwinding.html)

### Java: Error Hierarchy and RuntimeException

Java's Throwable hierarchy creates a three-tier system for unrecoverable errors:

**Tier 1: `Error`** — JVM-level catastrophic failures. Should never be caught:

```java
// These represent catastrophic JVM states
OutOfMemoryError        // heap exhausted
StackOverflowError      // infinite recursion
InternalError           // JVM bug
VirtualMachineError     // JVM cannot continue
```

**Tier 2: `RuntimeException`** — programming errors that indicate bugs:

```java
NullPointerException            // dereferencing null
IllegalArgumentException        // invalid method argument
IllegalStateException           // object in wrong state for operation
IndexOutOfBoundsException       // array/list access out of range
ClassCastException              // invalid type cast
ConcurrentModificationException // collection modified during iteration
UnsupportedOperationException   // operation not supported
NumberFormatException           // string-to-number parse failure
ArithmeticException             // e.g., integer division by zero
```

Bloch (Item 70) maps this directly to Rust's categories: "Use checked exceptions for conditions from which the caller can reasonably be expected to recover. Use runtime exceptions to indicate programming errors."

**Tier 3: Checked exceptions** — recoverable failures (covered in §2 above).

Common `RuntimeException` pitfalls from Valeev:

```java
// NullPointerException: unboxing null
Integer boxed = null;
int primitive = boxed;  // NPE!

// ClassCastException: type erasure hiding bad casts
List raw = new ArrayList();
raw.add("string");
List<Integer> typed = raw;  // compiles with warning
int val = typed.get(0);     // ClassCastException at runtime

// StackOverflowError: accidental recursion
class Node {
    Node parent;
    @Override
    public String toString() {
        return "Node(parent=" + parent + ")";  // infinite if parent references back
    }
}
```

> **Sources:** Bloch (2018) Ch.10 pp. 296–298 (Item 70) · Valeev (2024) Ch.5 pp. 124–154 · [JLS §11 — Exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html) · [Java docs — Error](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Error.html)

### Python: BaseException and Fatal Exceptions

Python's "unrecoverable" exceptions bypass `except Exception:` by inheriting directly from `BaseException`:

```python
BaseException
├── KeyboardInterrupt   # Ctrl-C — user interruption
├── SystemExit          # sys.exit() — clean shutdown
├── GeneratorExit       # generator/coroutine cleanup
└── Exception           # everything else
```

These three exceptions are specifically excluded from `Exception` so that `except Exception:` — the broadest reasonable catch — does not intercept user interrupts or shutdown signals:

```python
# This correctly lets Ctrl-C terminate the program:
try:
    long_running_operation()
except Exception as e:
    handle_error(e)
# KeyboardInterrupt propagates through, terminating the program

# This is WRONG — catches Ctrl-C:
try:
    long_running_operation()
except:       # bare except catches BaseException!
    pass      # silences KeyboardInterrupt and SystemExit
```

Python does not formally distinguish "programming error" exceptions from "expected failure" exceptions — `TypeError`, `ValueError`, and `AttributeError` can represent both, depending on context. The convention is to let unexpected exceptions propagate to the top level and crash with a full traceback, analogous to Rust's panic:

```python
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("division by zero")  # expected failure
    return a / b

# vs. a programming bug — just let it crash:
result = my_list[999]  # IndexError propagates naturally
```

> **Sources:** Martelli et al (2023) Ch.6 pp. 210–215 · [Python docs — Built-in Exceptions](https://docs.python.org/3/library/exceptions.html) · [Python docs — SystemExit](https://docs.python.org/3/library/exceptions.html#SystemExit)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Unrecoverable mechanism** | `panic!` (thread terminates) | `Error` subclasses (should not be caught) | `BaseException` minus `Exception` |
| **Programming bugs** | `panic!` / `unwrap` / `expect` | `RuntimeException` subclasses | No formal category — convention |
| **Stack cleanup** | Unwinding calls Drop (or abort) | Stack unwinding + finally blocks | Stack unwinding + finally blocks |
| **Can be caught?** | Yes — `catch_unwind` (limited) | Yes — `catch (Error e)` (discouraged) | Yes — `except BaseException:` (discouraged) |
| **Encoding invariants** | Newtype with validating constructor | Validating constructor + private fields | Validating `__init__` (not enforced) |
| **Out-of-bounds access** | Panics (prevents buffer overread) | `ArrayIndexOutOfBoundsException` | `IndexError` |

---

## 4. Error Propagation

How errors travel up the call stack — from the point of failure to the handler. Rust requires explicit propagation at every level; Java requires partial declaration; Python propagates automatically.

### Rust: The ? Operator and From-Based Conversion

The `?` operator is Rust's primary error propagation mechanism. It is syntactic sugar for early return with automatic type conversion:

```rust
// Without ? — verbose match chains
fn read_username() -> Result<String, io::Error> {
    let mut file = match File::open("username.txt") {
        Ok(f) => f,
        Err(e) => return Err(e),
    };
    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}

// With ? — concise and chainable
fn read_username() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("username.txt")?.read_to_string(&mut s)?;
    Ok(s)
}
```

**How `?` works:** `expr?` evaluates `expr`. If `Ok(value)`, it extracts `value` and continues. If `Err(e)`, it calls `From::from(e)` to convert the error type, then returns early with `Err(converted)`.

The implicit `From::from()` call is the key to error composition. If function A returns `Result<_, MyError>` and calls function B which returns `Result<_, io::Error>`, then `?` works automatically if you implement `From<io::Error> for MyError`:

```rust
#[derive(Debug)]
enum AppError {
    Io(io::Error),
    Parse(std::num::ParseIntError),
}

impl From<io::Error> for AppError {
    fn from(e: io::Error) -> Self { AppError::Io(e) }
}

impl From<std::num::ParseIntError> for AppError {
    fn from(e: std::num::ParseIntError) -> Self { AppError::Parse(e) }
}

fn load_config() -> Result<i32, AppError> {
    let content = std::fs::read_to_string("config.txt")?;  // io::Error → AppError
    let port = content.trim().parse::<i32>()?;              // ParseIntError → AppError
    Ok(port)
}
```

**`?` with `Option<T>`** works the same way — `None` causes an early return of `None`:

```rust
fn last_char_of_first_line(text: &str) -> Option<char> {
    text.lines().next()?.chars().last()
}
```

You cannot mix `?` on `Result` and `Option` in the same function. Convert with `opt.ok_or(err)` (Option → Result) or `res.ok()` (Result → Option).

**`main` returning Result:**

```rust
fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hello.txt")?;
    Ok(())
}
```

> **Sources:** Klabnik & Nichols (2023) Ch.9 pp. 168–175 · Matthews (2024) Ch.4 pp. 65–80 · McNamara (2021) Ch.3 pp. 77–100 · [Rust Book — Propagating Errors](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#propagating-errors) · [Rust By Example — The ? operator](https://doc.rust-lang.org/rust-by-example/error/result/enter_question_mark.html)

### Java: throws Declarations and Exception Translation

Java propagation differs for checked and unchecked exceptions:

- **Checked exceptions** must be declared with `throws` — the compiler enforces that every caller either catches or re-declares:

```java
// Each level in the call stack must declare or catch
public byte[] readData(String path) throws IOException {
    return Files.readAllBytes(Paths.get(path));
}

public Config loadConfig() throws IOException {
    byte[] data = readData("config.json");  // propagates IOException
    return parseConfig(data);
}
```

- **Unchecked exceptions** propagate silently — no declaration required:

```java
public int parse(String s) {
    return Integer.parseInt(s);  // NumberFormatException is unchecked
}
```

**Exception translation** (Bloch Item 73) is the practice of catching a lower-level exception and throwing a higher-level one appropriate to the abstraction:

```java
public User getUser(long id) throws ServiceException {
    try {
        return database.query("SELECT ...", id);
    } catch (SQLException e) {
        throw new ServiceException("Failed to load user " + id, e);
        // Original exception preserved as the "cause"
    }
}
```

The original exception is preserved via the `cause` parameter — Java's equivalent of Rust's `From` conversion and error wrapping. `getCause()` traverses the chain; `printStackTrace()` displays the full chain.

**The checked exception controversy:** Checked exceptions were designed to enforce error acknowledgment at compile time, but they create friction with generics and lambdas. A `Stream<T>` pipeline cannot propagate checked exceptions because `Function<T, R>` does not declare any:

```java
// This does not compile — lambda cannot throw checked IOException
list.stream()
    .map(path -> Files.readString(path))  // IOException!
    .collect(toList());
```

This is why modern Java libraries and frameworks (Spring, most newer APIs) increasingly use unchecked exceptions. Java has no equivalent of Rust's `?` operator — every propagation or translation is explicit code.

> **Sources:** Bloch (2018) Ch.10 pp. 298–304 (Items 71, 73, 74) · Horstmann (2024) Ch.7 pp. 94–96 · [Oracle Tutorial — Specifying Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/declaring.html) · [JLS §11 — Exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html)

### Python: Automatic Bubbling and Exception Chaining

Python exceptions propagate automatically — if not caught, they bubble up through the entire call stack to the top level, where the program terminates with a traceback. No syntax or declaration is needed:

```python
def function_c():
    raise ValueError("bad data")

def function_b():
    function_c()  # exception propagates automatically

def function_a():
    function_b()  # exception propagates automatically

function_a()  # ValueError traceback shows full chain: a → b → c
```

**Explicit exception chaining** (PEP 3134) preserves the original error when wrapping:

```python
try:
    config = json.loads(raw_data)
except json.JSONDecodeError as e:
    raise ConfigError("Invalid config file") from e
    # Sets __cause__ — displayed as:
    # "The above exception was the direct cause of the following exception:"
```

**Implicit chaining** happens automatically when an exception is raised inside an `except` or `finally` block:

```python
try:
    open("nonexistent")
except FileNotFoundError:
    1 / 0  # ZeroDivisionError.__context__ = FileNotFoundError
    # Displayed as:
    # "During handling of the above exception, another exception occurred:"
```

**Suppressing the chain:**

```python
raise RuntimeError("clean message") from None
# Sets __suppress_context__ = True — hides the original exception
```

**Three exception attributes for chaining:**

| Attribute | Set By | Purpose |
|-----------|--------|---------|
| `__cause__` | `raise X from Y` (explicit) | Declared direct cause |
| `__context__` | Interpreter (implicit) | Exception being handled when this one occurred |
| `__traceback__` | Interpreter | Traceback object for this exception |
| `__suppress_context__` | `raise X from None` | If True, hides `__context__` in display |

> **Sources:** Martelli et al (2023) Ch.6 pp. 206–210 · [Python docs — The raise statement](https://docs.python.org/3/reference/simple_stmts.html#the-raise-statement) · [PEP 3134 — Exception Chaining](https://peps.python.org/pep-3134/)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Propagation syntax** | `?` operator (explicit per call) | `throws` declaration (per method) | Automatic (no syntax needed) |
| **Type conversion** | `From::from()` via `?` | Exception translation (manual catch + throw) | `raise New from Old` |
| **Chain access** | `Error::source()` | `Throwable.getCause()` | `__cause__` / `__context__` |
| **Visibility** | Fully visible — `?` in code | Partially visible — `throws` in signature | Invisible — silent propagation |
| **Lambda/closure support** | `?` works inside closures | Checked exceptions break lambdas | No issue — no checked exceptions |
| **Compiler enforcement** | Return type must be `Result` for `?` | `throws` required for checked exceptions | None |

---

## 5. Resource Management: RAII, try-with-resources, Context Managers

Ensuring resources (files, locks, connections, memory) are released even when errors occur. Each language takes a fundamentally different approach.

### Rust: RAII via Drop — Automatic and Invisible

Rust's RAII (Resource Acquisition Is Initialization) model makes error handling and resource cleanup **orthogonal** — you never need special syntax for cleanup in error paths because `Drop` runs automatically when values go out of scope:

```rust
fn process_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;     // File acquired
    let mut contents = String::new();
    // If read_to_string fails and ? returns early,
    // `file` is dropped automatically, closing the file descriptor
    file.read_to_string(&mut contents)?;
    Ok(contents)
}   // file dropped here on success path too
```

There is no `try-with-resources` or `with` statement in Rust because none is needed. Drop runs in all cases:
- Normal scope exit
- Early return via `?`
- Panic (during unwinding, unless `panic = "abort"`)

**Drop order is well-defined:**

| Context | Drop Order |
|---------|------------|
| Local variables | Reverse declaration order |
| Struct fields | Declaration order |
| Tuple elements | Declaration order |
| Function parameters | Reverse declaration order (after locals) |
| Closure captures | Unspecified |

```rust
struct Guard(&'static str);
impl Drop for Guard {
    fn drop(&mut self) { println!("drop({})", self.0); }
}

fn main() {
    let _a = Guard("first");
    let _b = Guard("second");
}
// Output: drop(second), drop(first) — reverse order
```

**Suppressing destructors:** `std::mem::forget(value)` or `ManuallyDrop::new(value)` — rarely needed, primarily for FFI or unsafe code.

> **Sources:** Blandy & Orendorff (2017) Ch.7 pp. 155–158 · [Rust Reference — Destructors](https://doc.rust-lang.org/reference/destructors.html) · [Rust std — Drop trait](https://doc.rust-lang.org/std/ops/trait.Drop.html) · [Rust By Example — RAII](https://doc.rust-lang.org/rust-by-example/scope/raii.html)

### Java: try-with-resources and AutoCloseable

Before Java 7, resource cleanup required `finally` blocks, which had a critical flaw — an exception in `finally` overwrites the original exception:

```java
// Pre-Java 7 — flawed pattern
FileReader reader = null;
try {
    reader = new FileReader("file.txt");
    // use reader...
} finally {
    if (reader != null) reader.close(); // if close() throws, original exception is LOST
}
```

**try-with-resources** (Java 7+) solves this with automatic closing and **suppressed exceptions**:

```java
// Java 7+ — correct pattern
try (FileReader reader = new FileReader("file.txt");
     BufferedReader br = new BufferedReader(reader)) {
    String line = br.readLine();
    // Multiple resources: closed in reverse declaration order
}
// br.close() and reader.close() called automatically
```

Resources must implement `AutoCloseable` (or its subinterface `Closeable`). When both the try block and `close()` throw exceptions, the try-block exception is the primary one, and the close() exception is added as a **suppressed exception**:

```java
try (var resource = new MyResource()) {
    throw new Exception("from try");
} // resource.close() throws Exception("from close")
// Result: Exception("from try") with suppressed Exception("from close")
// Access via: exception.getSuppressed()
```

Bloch (Item 9) states definitively: "Always use try-with-resources in preference to try-finally when working with resources that must be closed."

**Finalization is deprecated.** `Object.finalize()` was Java's original automatic cleanup mechanism, but it was deeply flawed — unpredictable timing, performance overhead (7–11x slower), security vulnerabilities from partially-constructed objects, and unspecified threading. JEP 421 deprecates it for removal. Use try-with-resources for timely cleanup and `Cleaner` (Java 9+) as a safety net.

> **Sources:** Horstmann (2024) Ch.7 pp. 99–102 · Bloch (2018) Ch.2 pp. 33–35 (Item 9) · [Oracle Tutorial — try-with-resources](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html) · [Java docs — AutoCloseable](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html) · [JEP 421 — Deprecate Finalization](https://openjdk.org/jeps/421)

### Python: Context Managers and the with Statement

Python's `with` statement (PEP 343) provides a protocol for resource management:

```python
with open("data.txt") as f:
    content = f.read()
# f.close() called automatically, even if an exception occurred
```

**The protocol:** Any object with `__enter__` and `__exit__` methods is a context manager:

```python
class ManagedFile:
    def __init__(self, name):
        self.name = name

    def __enter__(self):
        self.file = open(self.name)
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.file.close()
        return False  # do not suppress exceptions
        # return True would suppress the exception
```

The semantic expansion of `with EXPR as VAR: BLOCK` is:

```python
mgr = EXPR
exit_fn = type(mgr).__exit__
value = type(mgr).__enter__(mgr)
exc = True
try:
    try:
        VAR = value
        BLOCK
    except:
        exc = False
        if not exit_fn(mgr, *sys.exc_info()):
            raise
finally:
    if exc:
        exit_fn(mgr, None, None, None)
```

**`contextlib` utilities** simplify writing context managers:

```python
from contextlib import contextmanager, suppress, ExitStack

# Generator-based context manager
@contextmanager
def managed_resource(name):
    resource = acquire(name)
    try:
        yield resource
    finally:
        release(resource)

# Suppress specific exceptions
with suppress(FileNotFoundError):
    os.remove("temp.txt")

# Dynamic number of context managers
with ExitStack() as stack:
    files = [stack.enter_context(open(f)) for f in filenames]
    # All files closed on exit, even if one close() fails
```

**Reuse categories:**

| Type | Reusable? | Reentrant? | Examples |
|------|-----------|------------|----------|
| Single-use | No | No | `open()`, `@contextmanager` |
| Reusable | Yes | No | `threading.Lock`, `ExitStack` |
| Reentrant | Yes | Yes | `threading.RLock`, `suppress()` |

> **Sources:** Ramalho (2022) Ch.18 pp. 657–694 · Martelli et al (2023) Ch.6 pp. 213–219 · [PEP 343 — The "with" Statement](https://peps.python.org/pep-0343/) · [Python docs — contextlib](https://docs.python.org/3/library/contextlib.html) · [Python docs — Context Manager Types](https://docs.python.org/3/reference/datamodel.html#context-managers)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Mechanism** | RAII — Drop trait (automatic) | try-with-resources (explicit) | `with` statement (explicit) |
| **Opt-in required?** | No — always automatic | Yes — every use site | Yes — every use site |
| **Interface** | `impl Drop for T` | `implements AutoCloseable` | `__enter__` / `__exit__` |
| **Cleanup on error** | Drop runs on `?` return and panic | `close()` called; exception suppressed | `__exit__` called with exception info |
| **Multiple resources** | Nested scopes (reverse drop order) | Multi-resource try declaration | `ExitStack` or nested `with` |
| **Cleanup failure** | Drop must not panic (double panic = abort) | Suppressed exception (`getSuppressed()`) | `__exit__` exception replaces original |
| **Legacy mechanism** | N/A | `finalize()` — deprecated (JEP 421) | `__del__` — unreliable |

---

## 6. Custom Error Types and Error Composition

Designing error types that accurately represent what can go wrong, preserve causal chains, and enable callers to react appropriately.

### Rust: Error Enums, std::error::Error, and From

A Rust library's error type is part of its API surface. The standard approach is an enum with one variant per error source:

```rust
use std::fmt;
use std::io;
use std::num::ParseIntError;

#[derive(Debug)]
enum ConfigError {
    Io(io::Error),
    Parse(ParseIntError),
    Validation(String),
}

impl fmt::Display for ConfigError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ConfigError::Io(e) => write!(f, "I/O error: {e}"),
            ConfigError::Parse(e) => write!(f, "parse error: {e}"),
            ConfigError::Validation(msg) => write!(f, "validation error: {msg}"),
        }
    }
}

impl std::error::Error for ConfigError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            ConfigError::Io(e) => Some(e),
            ConfigError::Parse(e) => Some(e),
            ConfigError::Validation(_) => None,
        }
    }
}

// From implementations enable ? operator
impl From<io::Error> for ConfigError {
    fn from(e: io::Error) -> Self { ConfigError::Io(e) }
}

impl From<ParseIntError> for ConfigError {
    fn from(e: ParseIntError) -> Self { ConfigError::Parse(e) }
}
```

**The `std::error::Error` trait:**

```rust
pub trait Error: Debug + Display {
    fn source(&self) -> Option<&(dyn Error + 'static)> { None }
}
```

Only `Debug` and `Display` are required. The `source()` method enables error chain traversal. **Critical rule from the docs:** include a lower-level error either in the `Display` output or via `source()`, but **not both** — doing both causes duplicate messages in error reports.

**The design question** (Gjengset): are your callers going to programmatically match on error variants? If yes → enumerated errors (library code). If no → opaque errors like `Box<dyn Error>` or `anyhow::Error` (application code).

**Rust API Guidelines requirements:**
- All error types in `Result<T, E>` must implement `std::error::Error`
- Error types should implement `Send + Sync` for thread safety
- Never use `()` as an error type — no `Error` impl, no `Display`, meaningless
- Error messages: lowercase, no trailing punctuation, concise

> **Sources:** Gjengset (2022) Ch.4 pp. 57–65 · Blandy & Orendorff (2017) Ch.7 pp. 153–158 · McNamara (2021) Ch.8 pp. 251–291 · [Rust std — Error trait](https://doc.rust-lang.org/std/error/trait.Error.html) · [Rust API Guidelines — Error handling](https://rust-lang.github.io/api-guidelines/interoperability.html#c-good-err)

### Java: Custom Exceptions and Chained Exceptions

Java custom exceptions extend `Exception` (checked) or `RuntimeException` (unchecked):

```java
// Checked — caller must handle or declare
public class ServiceException extends Exception {
    public ServiceException(String message) {
        super(message);
    }
    public ServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Unchecked — no handling requirement
public class InvalidConfigException extends RuntimeException {
    private final String key;
    public InvalidConfigException(String key, String message) {
        super(message);
        this.key = key;
    }
    public String getKey() { return key; }
}
```

**Design guidelines from Oracle and Bloch:**

Create custom exceptions when you need to differentiate your errors from standard ones, or when multiple related exceptions should share a hierarchy. Keep the hierarchy shallow. Name classes with the "Exception" suffix.

**Exception chaining** preserves the original cause:

```java
try {
    database.query(sql);
} catch (SQLException e) {
    throw new ServiceException("query failed", e);
    // e is preserved as the "cause"
}

// Access the chain:
ServiceException se = ...;
Throwable cause = se.getCause();       // the original SQLException
se.printStackTrace();                   // prints full chain
```

Bloch (Item 72) advises reusing standard exceptions when possible:

| Exception | Use When |
|-----------|----------|
| `IllegalArgumentException` | Non-null parameter value is inappropriate |
| `IllegalStateException` | Object state is inappropriate for invocation |
| `NullPointerException` | Parameter value is null where prohibited |
| `IndexOutOfBoundsException` | Index parameter is out of range |
| `UnsupportedOperationException` | Object does not support the method |
| `ConcurrentModificationException` | Concurrent modification detected |
| `ArithmeticException` | Arithmetic error (e.g., division by zero) |

> **Sources:** Bloch (2018) Ch.10 pp. 299–303 (Items 72–73) · Horstmann (2024) Ch.7 pp. 96–98 · [Oracle Tutorial — Creating Exception Classes](https://docs.oracle.com/javase/tutorial/essential/exceptions/creating.html) · [Java docs — Throwable.getCause](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Throwable.html#getCause())

### Python: Custom Exceptions and Exception Hierarchy

Custom Python exceptions inherit from `Exception`:

```python
# Package base exception
class MyLibError(Exception):
    """Base exception for mylib."""
    pass

# Specific exceptions
class ConfigError(MyLibError):
    """Configuration is invalid."""
    def __init__(self, key: str, message: str):
        self.key = key
        super().__init__(f"config key '{key}': {message}")

class ConnectionError(MyLibError):
    """Failed to connect to service."""
    def __init__(self, host: str, port: int, cause: Exception | None = None):
        self.host = host
        self.port = port
        msg = f"cannot connect to {host}:{port}"
        super().__init__(msg)
        if cause:
            self.__cause__ = cause
```

**Best practices:**
- Define a base exception for your package — callers can catch `MyLibError` to catch all your errors
- Name exceptions with the "Error" suffix
- Store relevant context as attributes — error codes, field names, offending values
- Use `raise ... from` for explicit chaining

**Exception chaining in practice:**

```python
import json

def load_config(path: str) -> dict:
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError as e:
        raise ConfigError("path", f"file not found: {path}") from e
    except json.JSONDecodeError as e:
        raise ConfigError("format", f"invalid JSON in {path}") from e
```

Unlike Rust's enum-based errors where the caller uses `match` on variants, Python callers use multiple `except` clauses to match on exception type:

```python
try:
    config = load_config("settings.json")
except ConfigError as e:
    print(f"Config error ({e.key}): {e}")
    if e.__cause__:
        print(f"  Caused by: {e.__cause__}")
```

> **Sources:** Martelli et al (2023) Ch.6 pp. 215–219 · [Python docs — User-defined Exceptions](https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions) · [Python docs — Exception hierarchy](https://docs.python.org/3/library/exceptions.html#exception-hierarchy) · [PEP 3134 — Exception Chaining](https://peps.python.org/pep-3134/)

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Error type** | Enum with variants | Class hierarchy | Class hierarchy |
| **Required trait/interface** | `std::error::Error` (+ `Debug`, `Display`) | Extends `Exception`/`RuntimeException` | Extends `Exception` |
| **Causal chain** | `Error::source()` | `Throwable.getCause()` | `__cause__` / `__context__` |
| **Caller matching** | `match` on enum variants (exhaustive) | Multiple `catch` (polymorphic) | Multiple `except` (`isinstance`) |
| **Auto-conversion** | `From<T>` enables `?` | Manual catch + throw | `raise ... from` |
| **Structured data** | Enum variants carry typed data | Exception fields + getters | Exception attributes |
| **Library convention** | Typed enum + thiserror | Checked or unchecked hierarchy | Package base exception + subclasses |

---

## 7. Error Handling Ecosystem: thiserror, anyhow, Standard Patterns

Ecosystem tools and established patterns that reduce boilerplate and enforce best practices.

### Rust: thiserror for Libraries

`thiserror` is a derive macro that generates `Display`, `Error`, and `From` implementations — eliminating the boilerplate from §6 while remaining invisible in your public API:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DataStoreError {
    #[error("data store disconnected")]
    Disconnect(#[from] io::Error),

    #[error("the data for key `{0}` is not available")]
    Redaction(String),

    #[error("invalid index {idx}, expected {lo}..{hi}")]
    OutOfBounds {
        idx: usize,
        #[source]
        source: io::Error,
        lo: usize,
        hi: usize,
    },
}
```

**Key attributes:**

| Attribute | Generated Code |
|-----------|---------------|
| `#[error("...")]` | `impl Display` with field interpolation (`{0}`, `{field}`, `{field:?}`) |
| `#[from]` | `impl From<T>` for the variant (implies `#[source]`) |
| `#[source]` | `Error::source()` returns this field |
| `#[error(transparent)]` | Forwards both `Display` and `source()` to inner error |

`thiserror` generates zero runtime overhead — it is purely compile-time code generation. The generated code is identical to hand-written implementations. Use it for **library code** where callers need typed error enums to match on.

> **Sources:** Gjengset (2022) Ch.4 pp. 59–62 · [thiserror crate docs](https://docs.rs/thiserror/latest/thiserror/)

### Rust: anyhow for Applications

`anyhow` provides an opaque error type for application code where callers just need human-readable error messages, not typed matching:

```rust
use anyhow::{Context, Result, bail, ensure};

fn load_config(path: &str) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read config from {path}"))?;

    let config: Config = serde_json::from_str(&content)
        .context("failed to parse config as JSON")?;

    ensure!(config.port > 0, "port must be positive, got {}", config.port);

    Ok(config)
}

fn main() -> Result<()> {
    let config = load_config("app.json")?;
    // If any step fails, the error chain is displayed:
    // Error: failed to read config from app.json
    //
    // Caused by:
    //     No such file or directory (os error 2)
    Ok(())
}
```

**Key features:**

| Feature | Description |
|---------|-------------|
| `anyhow::Error` | Wraps any `std::error::Error` with context chain |
| `anyhow::Result<T>` | Alias for `Result<T, anyhow::Error>` |
| `.context("msg")` | Add context to an error (like Rust's `From` but with a message) |
| `.with_context(\|\| format!(...))` | Lazy context — computed only on error |
| `bail!("msg {}", val)` | Early return: `return Err(anyhow!(...))` |
| `ensure!(cond, "msg")` | Conditional bail: `if !cond { bail!(...) }` |
| `error.downcast_ref::<T>()` | Runtime type recovery for matching |

**The key distinction:** `thiserror` = library (typed errors for callers to match on), `anyhow` = application (opaque errors for humans to read). They work well together — a library defines errors with `thiserror`, and an application wraps them with `anyhow`.

> **Sources:** Gjengset (2022) Ch.4 pp. 62–65 · [anyhow crate docs](https://docs.rs/anyhow/latest/anyhow/) · [Andrew Gallant — "Error Handling in Rust"](https://blog.burntsushi.net/rust-error-handling/)

### Java: Standard Exception Patterns and Best Practices

Bloch's *Effective Java* Chapter 10 provides the definitive Java error handling guidelines (Items 69–77):

| Item | Rule | Rationale |
|------|------|-----------|
| 69 | Use exceptions only for exceptional conditions | Never use exceptions for ordinary control flow |
| 70 | Use checked for recoverable, unchecked for programming errors | Checked = caller can recover; unchecked = caller has a bug |
| 71 | Avoid unnecessary checked exceptions | If the caller cannot recover, use unchecked |
| 72 | Favor standard exceptions | `IllegalArgumentException`, `IllegalStateException`, `NullPointerException`, `UnsupportedOperationException` |
| 73 | Throw exceptions appropriate to the abstraction | Exception translation: catch low-level, throw high-level |
| 74 | Document all exceptions with `@throws` | Both checked and unchecked |
| 75 | Include failure-capture information in messages | "index 7, size 5" not just "index out of bounds" |
| 76 | Strive for failure atomicity | Object should remain in a usable state after exception |
| 77 | Don't ignore exceptions | Never write empty catch blocks |

**Failure atomicity** (Item 76) means that a failed method should leave the object in the state it was in prior to invocation. Strategies: (1) operate on immutable objects, (2) check parameters before modifying state, (3) perform operations on a temporary copy, (4) write recovery code in the catch block (rare).

**Modern patterns:** Sealed classes with records (Java 17+/21+) can model Result-like types:

```java
public sealed interface Result<T> permits Success, Failure {
    record Success<T>(T value) implements Result<T> {}
    record Failure<T>(Exception error) implements Result<T> {}
}

// Pattern matching
switch (result) {
    case Success<String> s -> process(s.value());
    case Failure<String> f -> log.error("Failed", f.error());
}
```

This pattern, inspired by Rust's `Result`, is not yet idiomatic Java but is gaining adoption.

> **Sources:** Bloch (2018) Ch.10 pp. 293–309 (Items 69–77) · Valeev (2024) Ch.5 pp. 124–154 · [Oracle Tutorial — Advantages of Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/advantages.html)

### Python: Exception Hierarchy Conventions

Python's rich built-in exception hierarchy handles most error cases:

| Exception | Common Use |
|-----------|-----------|
| `ValueError` | Right type, wrong value: `int("abc")` |
| `TypeError` | Wrong type: `len(42)` |
| `KeyError` | Missing dictionary key |
| `AttributeError` | Missing attribute/method |
| `IndexError` | List/tuple index out of range |
| `FileNotFoundError` | File does not exist (subclass of `OSError`) |
| `PermissionError` | Insufficient permissions (subclass of `OSError`) |
| `RuntimeError` | Generic runtime error |
| `NotImplementedError` | Abstract method not overridden |
| `StopIteration` | Iterator exhausted (used by `for` loops) |

**Best practices:**
- Catch specific exceptions — never bare `except:` or `except Exception:` unless logging and re-raising
- Use the exception hierarchy for package-level grouping
- Python's "not found" varies by context: `KeyError` for dicts, `IndexError` for sequences, `AttributeError` for objects, `FileNotFoundError` for files, `None` return for some APIs (`dict.get()`)

Compare with Rust, where all these would be `Result` or `Option` return values — no exceptions needed, no hidden control flow.

> **Sources:** Martelli et al (2023) Ch.6 pp. 195–200, 215–219 · Viafore (2021) Ch.20 pp. 285–296 · [Python docs — Built-in Exceptions](https://docs.python.org/3/library/exceptions.html) · [Python docs — warnings module](https://docs.python.org/3/library/warnings.html)

---

## 8. ExceptionGroup, except*, and Error Handling in Concurrent Code

Modern concurrent programming often produces multiple simultaneous errors. Each language addresses this differently.

### Python: ExceptionGroup and except* (3.11+)

`ExceptionGroup` (PEP 654) wraps multiple exceptions that occurred concurrently, and `except*` selectively handles subsets:

```python
# Raising an exception group
raise ExceptionGroup("multiple errors", [
    ValueError("bad value"),
    TypeError("wrong type"),
    OSError("disk full"),
])
```

**`except*` semantics** — each clause receives the matching subgroup:

```python
try:
    async with asyncio.TaskGroup() as tg:
        tg.create_task(task_a())  # may raise ValueError
        tg.create_task(task_b())  # may raise TypeError
        tg.create_task(task_c())  # may raise ValueError
except* ValueError as eg:
    # eg is ExceptionGroup containing ALL ValueErrors
    for e in eg.exceptions:
        print(f"Value error: {e}")
except* TypeError as eg:
    # eg is ExceptionGroup containing ALL TypeErrors
    for e in eg.exceptions:
        print(f"Type error: {e}")
# Unmatched exceptions (e.g., OSError) propagate automatically
```

**Key rules:**
- A `try` block can have **either** `except` or `except*`, never both
- Multiple `except*` clauses can all match on the same `ExceptionGroup` (unlike regular `except`, where only the first match runs)
- Naked (non-group) exceptions caught by `except*` are automatically wrapped in `ExceptionGroup('', [exc])`
- `break`, `continue`, `return` are **forbidden** inside `except*`
- Bare `except*:` (no type) is a SyntaxError

**Structured operations on groups:**

```python
eg = ExceptionGroup("errors", [
    TypeError(1),
    ExceptionGroup("nested", [TypeError(2), ValueError(3)]),
    ExceptionGroup("other", [OSError(4)]),
])

# subgroup — extract matching, preserving nesting
type_errors = eg.subgroup(TypeError)
# ExceptionGroup("errors", [TypeError(1), ExceptionGroup("nested", [TypeError(2)])])

# split — partition into (match, rest)
type_errors, rest = eg.split(TypeError)
```

The `exceptiongroup` backport package provides these features for Python 3.7+.

> **Sources:** Martelli et al (2023) Ch.6 pp. 215–219 · [PEP 654 — Exception Groups and except*](https://peps.python.org/pep-0654/) · [Python docs — ExceptionGroup](https://docs.python.org/3/library/exceptions.html#ExceptionGroup)

### Java: Structured Concurrency (JEP 453)

Java's traditional `ExecutorService` has a fundamental error handling problem — when one task fails, other tasks continue running (thread leak), and exceptions are wrapped in `ExecutionException`:

```java
// Unstructured — problematic
Future<String>  user  = executor.submit(() -> findUser());
Future<Integer> order = executor.submit(() -> fetchOrder());
String theUser  = user.get();   // blocks; wraps exception in ExecutionException
int    theOrder = order.get();  // if findUser() failed, fetchOrder() still runs
```

**`StructuredTaskScope`** (Java 21 preview, JEP 453) confines subtask lifetimes to the parent scope:

```java
Response handle() throws ExecutionException, InterruptedException {
    try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
        Supplier<String>  user  = scope.fork(() -> findUser());
        Supplier<Integer> order = scope.fork(() -> fetchOrder());

        scope.join()           // wait for both
             .throwIfFailed(); // propagate first failure

        return new Response(user.get(), order.get());
    }
    // If findUser() fails, fetchOrder() is automatically cancelled
    // All threads terminate before scope closes (guaranteed)
}
```

**Two built-in policies:**

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `ShutdownOnFailure` | Cancel siblings on first failure; `throwIfFailed()` propagates | Invoke-all: need all results |
| `ShutdownOnSuccess` | Cancel siblings on first success; `result()` returns winner | Invoke-any: need first result |

**Error handling properties:**
- `ShutdownOnFailure` reports only the **first** failure — unlike Python's `ExceptionGroup`, Java does not aggregate multiple concurrent errors
- `fork()` returns `Subtask` (not `Future`) — `Subtask.get()` never blocks, throws `IllegalStateException` if called before `join()` or on failure
- Custom policies can be written by extending `StructuredTaskScope` and overriding `handleComplete()`

Java's `CompletableFuture` provides functional-style exception handling for unstructured concurrency:

```java
CompletableFuture.supplyAsync(() -> fetchData())
    .thenApply(data -> process(data))
    .exceptionally(ex -> {
        log.error("Pipeline failed", ex);
        return fallbackData();
    });
```

> **Sources:** Evans et al (2022) Ch.5 pp. 119–166 · [JEP 453 — Structured Concurrency](https://openjdk.org/jeps/453)

### Rust: Error Handling in Async Tasks

In Rust, `tokio::spawn()` returns a `JoinHandle<T>`. Errors have two layers — the join layer and the application layer:

```rust
use tokio::task;

// If the task returns Result<T, E>:
let handle = task::spawn(async {
    std::fs::read_to_string("config.txt")  // Returns Result<String, io::Error>
});

// handle.await returns Result<Result<String, io::Error>, JoinError>
//                         ^--- join error (panic)   ^--- app error
match handle.await {
    Ok(Ok(content)) => println!("Got: {content}"),
    Ok(Err(io_err)) => println!("I/O error: {io_err}"),
    Err(join_err) => println!("Task panicked: {join_err}"),
}
```

**`JoinSet`** manages multiple concurrent tasks:

```rust
use tokio::task::JoinSet;

let mut set = JoinSet::new();
set.spawn(async { fetch_user().await });
set.spawn(async { fetch_order().await });

let mut errors = Vec::new();
while let Some(result) = set.join_next().await {
    match result {
        Ok(Ok(value)) => process(value),
        Ok(Err(app_err)) => errors.push(app_err),
        Err(join_err) => errors.push(anyhow::anyhow!(join_err)),
    }
}
// errors collected manually — no ExceptionGroup equivalent
```

Rust does not have a built-in ExceptionGroup. You collect errors manually into a `Vec<Error>` or define a custom aggregate error type. The `?` operator does not compose over multiple concurrent errors — this is a genuine ergonomic gap compared to Python's `except*`.

> **Sources:** [Tokio docs — JoinError](https://docs.rs/tokio/latest/tokio/task/struct.JoinError.html) · [Tokio docs — JoinSet](https://docs.rs/tokio/latest/tokio/task/struct.JoinSet.html) · Gjengset (2022) Ch.4 pp. 57–65

### Comparison Matrix

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Multiple concurrent errors** | Manual `Vec<Error>` collection | First failure only (`ShutdownOnFailure`) | `ExceptionGroup` + `except*` |
| **Structured concurrency** | `tokio::task::JoinSet` | `StructuredTaskScope` (preview) | `asyncio.TaskGroup` |
| **Error aggregation** | No built-in | No built-in | `ExceptionGroup` (native, 3.11+) |
| **Task cancellation on failure** | Manual (abort handles) | Automatic (`ShutdownOnFailure`) | Automatic (`TaskGroup`) |
| **Nested error groups** | Custom types | Not supported | `ExceptionGroup` nesting |

---

## 9. Cross-Language Patterns, Anti-Patterns, and Best Practices

### Best Practices Summary

**Rust:**
1. Library crates: define error enum + use `thiserror` + implement `std::error::Error`
2. Application crates: use `anyhow` for opaque error context
3. Never `unwrap()` in library code — use `expect()` with a message if panic is intentional
4. Use `?` for propagation; implement `From` for type conversion
5. `panic!` is for bugs only — violated invariants, unreachable states, never for expected failures
6. At FFI boundaries: `catch_unwind` to prevent panics from crossing language boundaries
7. In `main()`: return `Result<(), Box<dyn Error>>` or `anyhow::Result<()>`
8. Error messages: lowercase, no trailing punctuation, concise

**Java:**
1. Use exceptions only for exceptional conditions — never for control flow (Item 69)
2. Checked exceptions for recoverable conditions; unchecked for programming errors (Item 70)
3. Avoid unnecessary checked exceptions — if the caller cannot recover, use unchecked (Item 71)
4. Favor standard exceptions before creating custom ones (Item 72)
5. Throw exceptions appropriate to the abstraction — use exception translation (Item 73)
6. Document all exceptions with `@throws` — both checked and unchecked (Item 74)
7. Include failure-capture information in messages — "index 7, size 5" (Item 75)
8. Strive for failure atomicity — leave objects in consistent state after exception (Item 76)
9. Never ignore exceptions — never empty catch blocks (Item 77)
10. Always prefer try-with-resources over try-finally for `AutoCloseable` resources

**Python:**
1. Embrace EAFP — try the operation, catch the exception
2. Catch specific exceptions — never bare `except:`
3. Use `except Exception:` only with logging/re-raising; never `except BaseException:`
4. Use `with` statements for all resource management
5. Define package base exception + specific subclasses
6. Use `raise ... from` for explicit exception chaining
7. Use the `else` clause to separate protected code from success-path code
8. Use `ExceptionGroup` and `except*` for concurrent error handling (3.11+)
9. Use type annotations + mypy/pyright to catch potential errors statically
10. Never silence exceptions without logging

### Anti-Pattern Catalog

| Anti-Pattern | Rust | Java | Python |
|--------------|------|------|--------|
| **Swallowing errors** | `.ok()` discarding error info | Empty `catch (Exception e) {}` | `except: pass` |
| **Overly broad handling** | `Box<dyn Error>` in library code | `catch (Throwable t)` | `except Exception:` without re-raise |
| **Lost error context** | `map_err(\|_\| MyError)` without `source()` | Rethrowing without wrapping cause | `raise New` without `from Old` |
| **Exceptions for control flow** | N/A (no exceptions) | `catch (ArrayIndexOutOfBoundsException)` to exit loop | Rare (but EAFP uses exceptions normally) |
| **Panic for expected failures** | `unwrap()` on user input | N/A | N/A |
| **Ignoring compiler warnings** | Ignoring `#[must_use]` warning | N/A (no equivalent warning) | N/A |
| **Catching fatal errors** | `catch_unwind` for normal flow | `catch (OutOfMemoryError)` | `except BaseException:` |

### Grand Comparison: Error Handling Lifecycle

| Stage | Rust | Java | Python |
|-------|------|------|--------|
| **Signal error** | Return `Err(e)` | `throw new Exception(msg)` | `raise Exception(msg)` |
| **Signal bug** | `panic!("msg")` | `throw new RuntimeException(msg)` | `raise RuntimeError(msg)` (convention) |
| **Propagate** | `?` operator (explicit) | `throws` declaration (checked) / silent (unchecked) | Automatic bubbling |
| **Handle** | `match` on `Result` | `catch (Type e)` | `except Type as e:` |
| **Clean up resources** | Drop (automatic RAII) | try-with-resources | `with` statement |
| **Add context** | `.context("msg")` (anyhow) | `new Higher(msg, cause)` | `raise New from original` |
| **Define custom errors** | Error enum + thiserror | Exception class hierarchy | Exception class hierarchy |
| **Ignore (explicit)** | `let _ = result;` | Empty catch (anti-pattern) | `except: pass` (anti-pattern) |
| **Log and continue** | `if let Err(e) = result { log(e) }` | `catch (E e) { log(e); }` | `except E as e: log(e)` |
| **Concurrent errors** | Manual `Vec<Error>` | First failure (`ShutdownOnFailure`) | `ExceptionGroup` + `except*` |

---

## Sources

### Books

| Book | Relevant Sections | Path |
|------|-------------------|------|
| Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.9 pp. 161–179 | `books/Rust/Klabnik Nichols 2023 The Rust programming language.pdf` |
| Blandy & Orendorff (2017) — *Programming Rust* | Ch.7 pp. 145–158 | `books/Rust/Blandy Orendorff 2017 Programming Rust.pdf` |
| Gjengset (2022) — *Rust for Rustaceans* | Ch.4 pp. 57–65 | `books/Rust/Gjengset 2022 Rust for Rustaceans.pdf` |
| Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91 | `books/Rust/Matthews 2024 Code like a pro in Rust.pdf` |
| McNamara (2021) — *Rust in Action* | Ch.3 pp. 77–105, Ch.8 pp. 251–291 | `books/Rust/McNamara 2021 Rust in action.pdf` |
| Bloch (2018) — *Effective Java* | Ch.10 pp. 293–309 (Items 69–77) | `books/Java/Bloch 2018 Effective Java.pdf` |
| Horstmann (2024) — *Core Java, Vol. I* | Ch.7 pp. 94–102 | `books/Java/Horstmann 2024 Core Java vol I.pdf` |
| Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.5 pp. 119–166 | `books/Java/Evans 2022 The well-grounded Java developer.pdf` |
| Valeev (2024) — *100 Java Mistakes* | Ch.5 pp. 124–154 | `books/Java/Valeev 2024 100 Java mistakes.pdf` |
| Martelli et al (2023) — *Python in a Nutshell* | Ch.6 pp. 195–219 | `books/Python/Martelli 2023 Python in a nutshell.pdf` |
| Ramalho (2022) — *Fluent Python* | Ch.18 pp. 657–694 | `books/Python/Ramalho 2022 Fluent Python.pdf` |
| Viafore (2021) — *Robust Python* | Ch.14 pp. 199–210, Ch.20 pp. 285–296 | `books/Python/Viafore 2021 Robust Python.pdf` |

### External Resources

**Rust**
- [Rust Book — Error Handling](https://doc.rust-lang.org/book/ch09-00-error-handling.html)
- [Rust Book — Unrecoverable Errors with panic!](https://doc.rust-lang.org/book/ch09-01-unrecoverable-errors-with-panic.html)
- [Rust Book — Recoverable Errors with Result](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html)
- [Rust Book — To panic! or Not to panic!](https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html)
- [Rust By Example — Error handling](https://doc.rust-lang.org/rust-by-example/error.html)
- [Rust By Example — Result](https://doc.rust-lang.org/rust-by-example/error/result.html)
- [Rust By Example — Option and unwrap](https://doc.rust-lang.org/rust-by-example/error/option_unwrap.html)
- [Rust By Example — The ? operator](https://doc.rust-lang.org/rust-by-example/error/result/enter_question_mark.html)
- [Rust By Example — Multiple error types](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types.html)
- [Rust By Example — Defining an error type](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/define_error_type.html)
- [Rust By Example — RAII](https://doc.rust-lang.org/rust-by-example/scope/raii.html)
- [Rust std — Result](https://doc.rust-lang.org/std/result/index.html)
- [Rust std — Option](https://doc.rust-lang.org/std/option/index.html)
- [Rust std — Error trait](https://doc.rust-lang.org/std/error/trait.Error.html)
- [Rust std — Drop trait](https://doc.rust-lang.org/std/ops/trait.Drop.html)
- [Rust std — std::panic](https://doc.rust-lang.org/std/panic/index.html)
- [Rust std — catch_unwind](https://doc.rust-lang.org/std/panic/fn.catch_unwind.html)
- [Rust Reference — Destructors](https://doc.rust-lang.org/reference/destructors.html)
- [Rustonomicon — Unwinding](https://doc.rust-lang.org/nomicon/unwinding.html)
- [Rust API Guidelines — Error handling](https://rust-lang.github.io/api-guidelines/interoperability.html#c-good-err)
- [thiserror crate docs](https://docs.rs/thiserror/latest/thiserror/)
- [anyhow crate docs](https://docs.rs/anyhow/latest/anyhow/)
- [Andrew Gallant — "Error Handling in Rust"](https://blog.burntsushi.net/rust-error-handling/)
- [Jane Lusby — "Error handling isn't all about errors" (RustConf 2020)](https://www.youtube.com/watch?v=rAF8mLI0naQ)
- [Tokio docs — JoinError](https://docs.rs/tokio/latest/tokio/task/struct.JoinError.html)
- [Tokio docs — JoinSet](https://docs.rs/tokio/latest/tokio/task/struct.JoinSet.html)

**Java**
- [JLS §11 — Exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html)
- [Oracle Tutorial — Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/index.html)
- [Oracle Tutorial — Catching and Handling Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/handling.html)
- [Oracle Tutorial — Specifying Exceptions Thrown by a Method](https://docs.oracle.com/javase/tutorial/essential/exceptions/declaring.html)
- [Oracle Tutorial — try-with-resources](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html)
- [Oracle Tutorial — Creating Exception Classes](https://docs.oracle.com/javase/tutorial/essential/exceptions/creating.html)
- [Oracle Tutorial — Advantages of Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/advantages.html)
- [Java docs — AutoCloseable](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html)
- [Java docs — Throwable.getCause](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Throwable.html#getCause())
- [Java docs — Error class](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Error.html)
- [Java docs — java.lang package summary](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/package-summary.html)
- [JEP 421 — Deprecate Finalization for Removal](https://openjdk.org/jeps/421)
- [JEP 453 — Structured Concurrency](https://openjdk.org/jeps/453)
- [Baeldung — Exception Handling in Java](https://www.baeldung.com/java-exceptions)
- [Baeldung — Checked vs Unchecked Exceptions](https://www.baeldung.com/java-checked-unchecked-exceptions)
- [Baeldung — Error vs Exception](https://www.baeldung.com/java-error-vs-exception)
- [Baeldung — Custom Exception](https://www.baeldung.com/java-new-custom-exception)
- [Baeldung — Common Exceptions](https://www.baeldung.com/java-common-exceptions)
- [Baeldung — CompletableFuture Exception Handling](https://www.baeldung.com/java-completablefuture-exception-handling)

**Python**
- [Python docs — Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)
- [Python docs — Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)
- [Python docs — The try statement](https://docs.python.org/3/reference/compound_stmts.html#the-try-statement)
- [Python docs — The raise statement](https://docs.python.org/3/reference/simple_stmts.html#the-raise-statement)
- [Python docs — Context Manager Types](https://docs.python.org/3/reference/datamodel.html#context-managers)
- [Python docs — contextlib](https://docs.python.org/3/library/contextlib.html)
- [Python docs — ExceptionGroup](https://docs.python.org/3/library/exceptions.html#ExceptionGroup)
- [Python docs — warnings module](https://docs.python.org/3/library/warnings.html)
- [Python docs — logging module](https://docs.python.org/3/library/logging.html)
- [Python Glossary — EAFP](https://docs.python.org/3/glossary.html#term-EAFP)
- [Python Glossary — LBYL](https://docs.python.org/3/glossary.html#term-LBYL)
- [PEP 343 — The "with" Statement](https://peps.python.org/pep-0343/)
- [PEP 3134 — Exception Chaining and Embedded Tracebacks](https://peps.python.org/pep-3134/)
- [PEP 654 — Exception Groups and except*](https://peps.python.org/pep-0654/)
- [Real Python — Python Exceptions](https://realpython.com/python-exceptions/)
- [Real Python — Context Managers](https://realpython.com/python-with-statement/)
- [Real Python — Raising Exceptions](https://realpython.com/python-raise-exception/)

**Cross-Language**
- [Joe Duffy — "The Error Model"](http://joeduffyblog.com/2016/02/07/the-error-model/)

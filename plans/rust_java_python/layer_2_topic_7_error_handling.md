# Layer 2 · Topic 7 — Error Handling

> Comparative study of Rust, Java, and Python: how each language represents, propagates, and recovers from errors — from Rust's type-driven `Result<T, E>` and `?` operator through Java's checked/unchecked exception hierarchy to Python's EAFP-oriented exception model and modern exception groups.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.9 pp. 161–179 | Unrecoverable errors with `panic!`, recoverable errors with `Result<T, E>`, `unwrap`, `expect`, the `?` operator, when to use `panic!` vs `Result` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.7 pp. 145–158 | Panic (unwinding, aborting), `Result<T, E>`, catching errors, ignoring errors, handling errors in `main`, custom error types, why Results |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.4 pp. 57–65 | Representing errors (enumeration vs opaque errors), propagating errors, `Box<dyn Error>` vs typed errors, special error cases |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91 | Result type, `From`/`Into` for error conversion, `TryFrom`/`TryInto`, converting between error types |
| Rust | McNamara (2021) — *Rust in Action* | Ch.3 pp. 77–105 | Returning errors from functions, error propagation strategies |
| Rust | McNamara (2021) — *Rust in Action* | Ch.8 pp. 251–291 | Ergonomic error handling for libraries, designing error types for public APIs |
| Java | Bloch (2018) — *Effective Java* | Ch.10 pp. 293–309 | Items 69–77: use exceptions only for exceptional conditions, checked for recoverable / runtime for programming errors, avoid unnecessary checked exceptions, favor standard exceptions, throw exceptions appropriate to the abstraction, document exceptions, include failure-capture information, failure atomicity, don't ignore exceptions |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.7 pp. 94–102 | Exception classification (Throwable hierarchy), declaring/throwing/catching exceptions, try-with-resources, stack trace API, assertions, logging, debugging tips |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.5 pp. 119–166 | Exception handling in concurrent code, `ExecutorService` exception propagation, `Future.get()` and `ExecutionException` |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.5 pp. 124–154 | Common exception pitfalls: `NullPointerException`, `IndexOutOfBoundsException`, `ClassCastException`, `StackOverflowError`, swallowed exceptions |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.6 pp. 195–219 | `try`/`except`/`else`/`finally`, `raise`, `with` statement, generators and exceptions, `ExceptionGroup`, `except*`, custom exception classes, error-checking strategies (LBYL vs EAFP) |
| Python | Ramalho (2022) — *Fluent Python* | Ch.18 pp. 657–694 | Context managers and `with` blocks, `contextlib.contextmanager` decorator, `else` clause in `for`/`while`/`try`, `@contextmanager` patterns |
| Python | Viafore (2021) — *Robust Python* | Ch.14 pp. 199–210 | Pydantic validators for data validation, runtime error detection strategies |
| Python | Viafore (2021) — *Robust Python* | Ch.20 pp. 285–296 | Static analysis for error detection, using type checkers to prevent errors |

### Coverage Gaps

The owned books **do not** cover:

- **`thiserror` and `anyhow` crates in depth** — Gjengset briefly discusses the distinction between enumerated errors and opaque errors (pp. 57–65) but none of the owned Rust books provide a thorough tutorial on `thiserror` derive macros, `anyhow::Context`, and when to choose one over the other; the crate documentation and Andrew Gallant's "Error Handling in Rust" blog post are the primary sources
- **`ExceptionGroup` and `except*` beyond introductory coverage** — Martelli covers ExceptionGroup and `except*` (Ch.6), but none of the owned books provide in-depth treatment of PEP 654's design rationale, handling patterns for grouped exceptions in structured concurrency, or the `exceptiongroup` backport for Python < 3.11
- **Error handling in async/concurrent code across all three languages** — Evans covers exception propagation in Java's executor framework, but there is no systematic treatment of how Rust's `tokio`/`async-std` handle errors in spawned tasks, how Java's `CompletableFuture` exception chaining works, or how Python's `asyncio` propagates exceptions through `TaskGroup`
- **Structured concurrency error handling** — the relationship between error handling and structured concurrency (Java's `StructuredTaskScope`, Python's `asyncio.TaskGroup`, Rust's `tokio::task::JoinSet`) is not covered in any owned book; this is a rapidly evolving area documented primarily in JEPs, PEPs, and crate documentation
- **LBYL vs EAFP philosophy comparison across languages** — Martelli mentions LBYL vs EAFP briefly, but none of the owned books provide a cross-language analysis of when each philosophy is appropriate or how Rust's `Result`-based approach relates to these paradigms
- **Modern Java error handling patterns with sealed classes** — none of the owned Java books cover using sealed interfaces + records as an alternative to exceptions for expected domain errors (a pattern inspired by Rust's `Result`), or how pattern matching with `switch` (Java 21+) can make these patterns ergonomic
- **Error handling at production scale** — none of the owned books cover error reporting libraries (`sentry`), structured error logging, error budgets, or how error handling strategies change at scale across all three ecosystems
- **Rust's `std::panic::catch_unwind` and panic hooks** — the distinction between panics (which can be caught) and aborts, and the `catch_unwind` API used at FFI boundaries, is mentioned minimally in the owned books; the Rustonomicon and std docs are the primary sources

---

## External Resources

### Sub-topic 1 — Error Philosophy: Exceptions vs Values

**Rust**
- The Rust Book (online) — Error Handling: `https://doc.rust-lang.org/book/ch09-00-error-handling.html`
- Rust By Example — Error handling: `https://doc.rust-lang.org/rust-by-example/error.html`
- Andrew Gallant (burntsushi) — "Error Handling in Rust": `https://blog.burntsushi.net/rust-error-handling/`

**Java**
- Oracle Java Tutorials — Exceptions: `https://docs.oracle.com/javase/tutorial/essential/exceptions/index.html`
- Java Language Specification — Exceptions (Chapter 11): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-11.html`

**Python**
- Python docs — Errors and Exceptions tutorial: `https://docs.python.org/3/tutorial/errors.html`
- Python docs — Built-in Exceptions: `https://docs.python.org/3/library/exceptions.html`
- Python Glossary — EAFP: `https://docs.python.org/3/glossary.html#term-EAFP`
- Python Glossary — LBYL: `https://docs.python.org/3/glossary.html#term-LBYL`

### Sub-topic 2 — Basic Error Handling: Result/Option, try/catch, try/except

**Rust**
- Rust std docs — Result: `https://doc.rust-lang.org/std/result/index.html`
- Rust std docs — Option: `https://doc.rust-lang.org/std/option/index.html`
- Rust By Example — Result: `https://doc.rust-lang.org/rust-by-example/error/result.html`
- Rust By Example — Option and unwrap: `https://doc.rust-lang.org/rust-by-example/error/option_unwrap.html`

**Java**
- Oracle Java Tutorials — Catching and Handling Exceptions: `https://docs.oracle.com/javase/tutorial/essential/exceptions/handling.html`
- Baeldung — Exception Handling in Java: `https://www.baeldung.com/java-exceptions`

**Python**
- Python docs — The try statement: `https://docs.python.org/3/reference/compound_stmts.html#the-try-statement`
- Real Python — Python Exceptions: An Introduction: `https://realpython.com/python-exceptions/`

### Sub-topic 3 — panic!, unwrap, and Unrecoverable Errors

**Rust**
- The Rust Book (online) — Unrecoverable Errors with panic!: `https://doc.rust-lang.org/book/ch09-01-unrecoverable-errors-with-panic.html`
- The Rust Book (online) — To panic! or Not to panic!: `https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html`
- Rust std docs — std::panic: `https://doc.rust-lang.org/std/panic/index.html`
- Rust std docs — catch_unwind: `https://doc.rust-lang.org/std/panic/fn.catch_unwind.html`

**Java**
- Java docs — Error class (unrecoverable): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Error.html`
- Baeldung — Java Error vs Exception: `https://www.baeldung.com/java-error-vs-exception`

**Python**
- Python docs — SystemExit: `https://docs.python.org/3/library/exceptions.html#SystemExit`
- Python docs — KeyboardInterrupt: `https://docs.python.org/3/library/exceptions.html#KeyboardInterrupt`

### Sub-topic 4 — Error Propagation and the ? Operator

**Rust**
- The Rust Book (online) — Propagating Errors with ?: `https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#propagating-errors`
- Rust By Example — The ? operator: `https://doc.rust-lang.org/rust-by-example/error/result/enter_question_mark.html`
- Rust By Example — Multiple error types: `https://doc.rust-lang.org/rust-by-example/error/multiple_error_types.html`

**Java**
- Oracle Java Tutorials — Specifying Exceptions Thrown by a Method: `https://docs.oracle.com/javase/tutorial/essential/exceptions/declaring.html`
- Baeldung — Checked vs Unchecked Exceptions in Java: `https://www.baeldung.com/java-checked-unchecked-exceptions`

**Python**
- Python docs — Exception chaining (raise ... from ...): `https://docs.python.org/3/reference/simple_stmts.html#the-raise-statement`
- PEP 3134 — Exception Chaining and Embedded Tracebacks: `https://peps.python.org/pep-3134/`

### Sub-topic 5 — Resource Management: RAII, try-with-resources, Context Managers

**Rust**
- The Rust Reference — Destructors: `https://doc.rust-lang.org/reference/destructors.html`
- Rust std docs — Drop trait: `https://doc.rust-lang.org/std/ops/trait.Drop.html`
- Rust By Example — RAII: `https://doc.rust-lang.org/rust-by-example/scope/raii.html`

**Java**
- Oracle Java Tutorials — The try-with-resources Statement: `https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html`
- Java docs — AutoCloseable: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/AutoCloseable.html`
- JEP 421 — Deprecate Finalization for Removal: `https://openjdk.org/jeps/421`

**Python**
- PEP 343 — The "with" Statement: `https://peps.python.org/pep-0343/`
- Python docs — contextlib: `https://docs.python.org/3/library/contextlib.html`
- Python docs — Context Manager Types: `https://docs.python.org/3/reference/datamodel.html#context-managers`
- Real Python — Context Managers and the with Statement: `https://realpython.com/python-with-statement/`

### Sub-topic 6 — Custom Error Types and Error Composition

**Rust**
- Rust std docs — std::error::Error trait: `https://doc.rust-lang.org/std/error/trait.Error.html`
- thiserror crate documentation: `https://docs.rs/thiserror/latest/thiserror/`
- anyhow crate documentation: `https://docs.rs/anyhow/latest/anyhow/`
- Rust By Example — Defining an error type: `https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/define_error_type.html`

**Java**
- Oracle Java Tutorials — Creating Exception Classes: `https://docs.oracle.com/javase/tutorial/essential/exceptions/creating.html`
- Java docs — Throwable.getCause (chained exceptions): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Throwable.html#getCause()`
- Baeldung — Create a Custom Exception in Java: `https://www.baeldung.com/java-new-custom-exception`

**Python**
- Python docs — User-defined Exceptions: `https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions`
- Python docs — Exception hierarchy: `https://docs.python.org/3/library/exceptions.html#exception-hierarchy`
- PEP 3134 — Exception Chaining: `https://peps.python.org/pep-3134/`

### Sub-topic 7 — Error Handling Ecosystem: thiserror/anyhow, Standard Exceptions, Exception Hierarchy

**Rust**
- Andrew Gallant (burntsushi) — "Error Handling in Rust" (updated): `https://blog.burntsushi.net/rust-error-handling/`
- Jane Lusby (yaahc) — "Error handling isn't all about errors" (RustConf 2020): `https://www.youtube.com/watch?v=rAF8mLI0naQ`
- Rust Error Handling Working Group: `https://blog.rust-lang.org/inside-rust/2020/11/23/What-the-error-handling-project-group-is-working-on.html`

**Java**
- Baeldung — Common Java Exceptions: `https://www.baeldung.com/java-common-exceptions`
- Java docs — java.lang exception summary: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/package-summary.html`

**Python**
- Python docs — warnings module: `https://docs.python.org/3/library/warnings.html`
- Python docs — Exception hierarchy tree: `https://docs.python.org/3/library/exceptions.html#exception-hierarchy`

### Sub-topic 8 — ExceptionGroup, except*, and Modern Error Patterns

**Rust**
- Tokio docs — JoinError: `https://docs.rs/tokio/latest/tokio/task/struct.JoinError.html`
- Tokio docs — JoinSet: `https://docs.rs/tokio/latest/tokio/task/struct.JoinSet.html`

**Java**
- JEP 453 — Structured Concurrency (Preview): `https://openjdk.org/jeps/453`
- Java docs — StructuredTaskScope: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html`
- Baeldung — CompletableFuture Exception Handling: `https://www.baeldung.com/java-completablefuture-exception-handling`

**Python**
- PEP 654 — Exception Groups and except*: `https://peps.python.org/pep-0654/`
- Python docs — ExceptionGroup: `https://docs.python.org/3/library/exceptions.html#ExceptionGroup`
- Python docs — except* clause: `https://docs.python.org/3/reference/compound_stmts.html#the-try-statement`

### Sub-topic 9 — Cross-Language Patterns, Anti-Patterns, and Best Practices

**Rust**
- Rust API Guidelines — Error handling: `https://rust-lang.github.io/api-guidelines/interoperability.html#c-good-err`
- The Rustonomicon — Unwinding: `https://doc.rust-lang.org/nomicon/unwinding.html`

**Java**
- Oracle Java Tutorials — Advantages of Exceptions: `https://docs.oracle.com/javase/tutorial/essential/exceptions/advantages.html`

**Python**
- Real Python — Python's raise: Effectively Raising Exceptions in Your Code: `https://realpython.com/python-raise-exception/`
- Python docs — logging module (structured error reporting): `https://docs.python.org/3/library/logging.html`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| General | Joe Duffy — *"The Error Model"* (blog post, 2016) | A comprehensive cross-language analysis of error handling models (return codes, exceptions, Result types, effect systems) by the lead of Microsoft's Midori project; provides the theoretical framework for understanding why Rust chose values over exceptions and the tradeoffs of each approach; available at `http://joeduffyblog.com/2016/02/07/the-error-model/` |
| Rust | *The Rustonomicon* (online, continuously updated) | Covers `catch_unwind`, panic hooks, unwinding vs aborting, and how Rust's error handling interacts with unsafe code and FFI boundaries — none of the owned books treat these topics in depth |
| Rust | Rust Error Handling Working Group — *project group reports* (blog posts, 2020–present) | Documents the evolving best practices and proposed language changes for error handling, including the stabilization of `Error` in `core`, `Backtrace`, and the `provide` API — fills the gap between book-level coverage and the current state of Rust error handling |
| Java | Brian Goetz et al — *Java Concurrency in Practice* (Addison-Wesley, 2006) | Chapter 5 (Task Execution) and Chapter 6 (Cancellation and Shutdown) cover exception handling in concurrent Java code more thoroughly than any owned book; despite its age, the patterns for `ExecutorService` exception handling and thread interruption remain the standard reference |
| Python | Brett Cannon — *CPython Developer Guide: Exception handling internals* (online) | Official documentation of how CPython implements exceptions at the C level, including the frame-based exception state, traceback object construction, and the `except*` implementation — fills the gap between Martelli's user-level coverage and implementation-level understanding |

---

## Study Plan — 9 Sessions

Estimated total: **18–22 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from error philosophy through basic handling and propagation to resource management, custom error types, ecosystem tools, modern concurrent patterns, and cross-language best practices.

---

### Session 1 — Error Philosophy: Exceptions vs Values

**Goal:** understand the fundamental philosophical divide in error handling — exceptions (Java, Python) vs error-as-values (Rust) — and how each language's design goals led to its error model.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust: errors as values.** Read Klabnik Ch.9 pp. 161–163 (introduction to error handling in Rust — the two categories: unrecoverable errors with `panic!` and recoverable errors with `Result<T, E>`). Read Blandy Ch.7 pp. 145–148 (panic and Result overview, the design philosophy of "why Results"). Read the Rust By Example "Error handling" overview page online. Key insight: Rust's error handling is built on the type system, not on control flow. Errors are values of type `Result<T, E>` that must be explicitly handled — the compiler refuses to compile code that ignores a `Result`. This is a deliberate design choice: errors are not exceptional events that disrupt normal flow; they are expected outcomes encoded in the return type. This forces the programmer to decide at every call site whether to handle, propagate, or panic on an error. There is no hidden control flow — unlike exceptions, a function that can fail always declares this in its return type. |
| 1.2 | 30 min | **Java: the exception model.** Read Bloch Ch.10 pp. 293–296 (Item 69: use exceptions only for exceptional conditions — exceptions are designed for exceptional conditions, not for ordinary control flow; Item 70: use checked exceptions for recoverable conditions and runtime exceptions for programming errors). Read Horstmann Ch.7 pp. 94–98 (the exception classification: Throwable hierarchy — Error, Exception, RuntimeException; checked vs unchecked). Read the Java Language Specification Chapter 11 online. Key insight: Java chose exceptions as its primary error mechanism, dividing them into checked exceptions (compiler-enforced — must be caught or declared with `throws`) and unchecked exceptions (`RuntimeException` subclasses — no compiler enforcement). Checked exceptions were an experiment: the idea that the compiler should enforce error handling. In practice, checked exceptions have been controversial — they add verbosity, encourage swallowing, and do not compose well with generics or lambdas. Modern Java code increasingly uses unchecked exceptions. The `Error` hierarchy (OutOfMemoryError, StackOverflowError) represents unrecoverable conditions that should not be caught. |
| 1.3 | 25 min | **Python: EAFP and the exception hierarchy.** Read Martelli Ch.6 pp. 195–200 (try/except introduction, error-checking strategies — LBYL vs EAFP). Read the Python docs "Built-in Exceptions" page and the exception hierarchy tree online. Key insight: Python embraces EAFP (Easier to Ask Forgiveness than Permission) — try the operation, catch the exception if it fails. This is the opposite of LBYL (Look Before You Leap), where you check preconditions first. Python has no checked exceptions — all exceptions are unchecked. The exception hierarchy descends from `BaseException`: `Exception` (for catchable errors), `KeyboardInterrupt`, `SystemExit`, and `GeneratorExit` inherit directly from `BaseException`. User exceptions should inherit from `Exception`. Python's philosophy: exceptions are not exceptional — they are a normal control flow mechanism. `StopIteration` ending a for loop is the canonical example. This is fundamentally different from Java's Item 69 advice. |
| 1.4 | 15 min | **Cross-language comparison.** Read Joe Duffy's "The Error Model" blog post online. Create a comparison table: rows = {error representation, compiler enforcement, hidden control flow, error handling is opt-in/opt-out, LBYL vs EAFP, can errors be ignored silently, performance cost model}, columns = {Rust, Java, Python}. Key takeaway: Rust treats errors as data (values in the type system); Java treats errors as events (control flow disruption with partial compiler enforcement); Python treats errors as events (control flow disruption with no compiler enforcement but cultural embrace). The spectrum is: Rust (most explicit, compiler-enforced) → Java checked exceptions (partially compiler-enforced) → Java unchecked / Python (no enforcement, cultural convention). |

---

### Session 2 — Basic Error Handling: Result, try/catch, try/except

**Goal:** master the basic error handling syntax and semantics in all three languages — `Result<T, E>` with `match`/`unwrap`/`expect` in Rust, `try`/`catch`/`finally` in Java, and `try`/`except`/`else`/`finally` in Python.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 35 min | **Rust: Result and Option fundamentals.** Read Klabnik Ch.9 pp. 164–172 (recoverable errors with `Result<T, E>` — `match` on Result, `unwrap`, `expect`, the `?` operator introduction). Read Blandy Ch.7 pp. 148–155 (Result — catching errors, the `?` operator, error type requirements, type aliases for Result). Key insight: `Result<T, E>` is an enum with two variants: `Ok(T)` for success and `Err(E)` for failure. Pattern matching with `match` is the most explicit handling. `unwrap()` extracts the value or panics — appropriate only in tests, prototypes, or when failure is logically impossible. `expect("message")` is unwrap with a context message — preferred over bare unwrap. The `#[must_use]` attribute on Result means the compiler warns if you discard a Result without handling it. `Option<T>` (`Some`/`None`) handles the "absent value" case and has the same combinator patterns as Result. `ok_or()` and `ok_or_else()` convert between Option and Result. |
| 2.2 | 30 min | **Java: try/catch/finally.** Read Horstmann Ch.7 pp. 96–102 (declaring exceptions, throwing exceptions, catching exceptions, the finally clause, try-with-resources, the stack trace). Read Valeev Ch.5 pp. 124–140 (NullPointerException patterns, IndexOutOfBoundsException, ClassCastException — common mistakes in catch blocks). Key insight: Java's `try { } catch (ExceptionType e) { } finally { }` is the fundamental error handling construct. The `catch` block catches by exception type — polymorphic catching (catching a supertype catches all subtypes). Multi-catch syntax `catch (IOException | SQLException e)` avoids code duplication (Java 7+). The `finally` block always executes (even if `return` or another exception occurs in try/catch), making it the pre-try-with-resources cleanup mechanism. Common anti-patterns: empty catch blocks (silently swallowing exceptions), catching `Exception` or `Throwable` too broadly, catching and rethrowing without wrapping. |
| 2.3 | 25 min | **Python: try/except/else/finally.** Read Martelli Ch.6 pp. 200–210 (try/except/else/finally in full detail, raising exceptions, the `else` clause semantics, exception matching rules). Key insight: Python's `try`/`except` is similar to Java's `try`/`catch` but with important differences. The `else` clause (unique to Python) runs only if the try block completes without an exception — this is valuable for separating "protected code" from "success code" that should not have its exceptions caught by the same handler. `finally` works like Java's. Exception matching uses `isinstance()` checking, so catching a parent class catches all children. Bare `except:` (no type) catches everything including `KeyboardInterrupt` and `SystemExit` — this is always wrong; use `except Exception:` instead. The `as` keyword captures the exception object: `except ValueError as e:`. |
| 2.4 | 15 min | **Three-way comparison.** Write the same function in all three languages: read an integer from a string, return it doubled, handle the parse failure. Compare: (1) how each language signals failure (Rust: `Result::Err`, Java: throws `NumberFormatException`, Python: raises `ValueError`), (2) how the caller handles it (Rust: `match`/`?`, Java: `catch`, Python: `except`), (3) what happens if the error is not handled (Rust: compile error on unused Result, Java: unchecked exception propagates, Python: exception propagates and crashes). |

---

### Session 3 — panic!, unwrap, and Unrecoverable Errors

**Goal:** understand the boundary between recoverable and unrecoverable errors — when `panic!` is appropriate in Rust, how Java's `Error` hierarchy represents unrecoverable conditions, and how Python handles fatal exceptions.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Rust: panic!, unwrap, and when to panic.** Read Klabnik Ch.9 pp. 161–164 (unrecoverable errors with `panic!` — what panic does, unwinding vs aborting, RUST_BACKTRACE). Read Klabnik Ch.9 pp. 175–179 (when to use `panic!` vs `Result` — examples, prototyping, tests, when you have more information than the compiler, guidelines for library code). Read Blandy Ch.7 pp. 145–148 (panic — stack unwinding, `catch_unwind`). Read the Rust std docs for `std::panic` and `catch_unwind` online. Key insight: `panic!` unwinds the stack (calling destructors) and terminates the thread. Panic is for bugs (logic errors, invariant violations), not for expected failures (file not found, network timeout). The `unwrap()`/`expect()` methods panic on `Err`/`None` — use them when failure means the program has a bug. `catch_unwind` can catch panics (useful at FFI boundaries and in thread pools), but it is not a general error handling mechanism. Library code should almost never panic — use `Result` instead. Application code may panic for truly unrecoverable situations. The `panic = "abort"` profile setting skips unwinding for smaller binaries and faster panics. |
| 3.2 | 25 min | **Java: Error hierarchy and unrecoverable conditions.** Read Bloch Ch.10 pp. 296–298 (Item 70: use checked exceptions for recoverable conditions and runtime exceptions for programming errors). Read Valeev Ch.5 pp. 146–154 (StackOverflowError, OutOfMemoryError pitfalls). Read the Java docs for `java.lang.Error` online. Key insight: Java's `Error` subclasses represent conditions that a reasonable application should not try to recover from: `OutOfMemoryError`, `StackOverflowError`, `InternalError`. These are analogous to Rust's `panic!`. `RuntimeException` subclasses (NullPointerException, IllegalArgumentException, IndexOutOfBoundsException) represent programming errors — also analogous to panic, but catchable and frequently caught in practice (which Bloch discourages for most cases). The key distinction: checked exceptions = recoverable (like Rust's Result), unchecked RuntimeException = programming errors (like Rust's panic), Error = fatal conditions (like Rust's panic with abort). |
| 3.3 | 20 min | **Python: fatal exceptions and sys.exit.** Read Martelli Ch.6 pp. 210–215 (exception hierarchy — BaseException vs Exception, KeyboardInterrupt, SystemExit, GeneratorExit). Read the Python docs "Built-in Exceptions" hierarchy tree online. Key insight: Python's "unrecoverable" exceptions inherit from `BaseException` but not from `Exception`: `KeyboardInterrupt` (Ctrl-C), `SystemExit` (sys.exit()), `GeneratorExit` (generator cleanup). These bypass `except Exception:` handlers by design. Python has no formal distinction between "programming error" exceptions and "expected failure" exceptions — `TypeError`, `ValueError`, `AttributeError` can represent both bugs and expected conditions depending on context. The convention is to let unexpected exceptions propagate to the top level and crash with a traceback, similar to Rust's panic. |
| 3.4 | 15 min | **Comparison: when should code crash?** Compare the three philosophies: Rust has a clear compile-time boundary (Result = recoverable, panic! = unrecoverable). Java has a type hierarchy boundary (checked = recoverable, unchecked = programming error, Error = fatal), but it is blurred in practice. Python has no formal boundary — convention and documentation guide the distinction. Write a "validate positive integer" function in all three: Rust returns `Result`, Java throws `IllegalArgumentException` (unchecked), Python raises `ValueError`. Discuss: should the validation function crash or return an error? |

---

### Session 4 — Error Propagation: the ? Operator, throws, and Exception Bubbling

**Goal:** understand how errors travel up the call stack — Rust's explicit `?` operator with `From` conversion, Java's `throws` declarations and exception translation, and Python's automatic exception bubbling.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: the ? operator and From-based conversion.** Read Klabnik Ch.9 pp. 168–175 (the `?` operator in full — how it works, chaining, use in `main`, `?` with `Option<T>`). Read Matthews Ch.4 pp. 65–80 (Result type, `From`/`Into` for error conversion, the role of `From` in `?`). Read McNamara Ch.3 pp. 77–100 (returning errors from functions, propagation patterns). Key insight: the `?` operator is syntactic sugar: `expr?` evaluates `expr`, returns `Ok(value)` if Ok, or early-returns `Err(From::from(err))` if Err. The implicit `From::from()` call is critical — it automatically converts between error types. If function A returns `Result<_, MyError>` and calls function B which returns `Result<_, io::Error>`, then `?` works if `impl From<io::Error> for MyError` exists. This is how error types compose in Rust — `From` implementations define the conversion graph. Without `?`, error propagation requires verbose `match` blocks. `?` also works on `Option<T>`, converting `None` to an early return. |
| 4.2 | 30 min | **Java: throws declarations and exception translation.** Read Bloch Ch.10 pp. 299–304 (Item 73: throw exceptions appropriate to the abstraction — exception translation; Item 74: document all exceptions thrown by each method; Item 71: avoid unnecessary use of checked exceptions). Read Horstmann Ch.7 pp. 94–96 (declaring exceptions with `throws`). Key insight: Java's `throws` keyword declares which checked exceptions a method can throw: `public void read() throws IOException`. The compiler enforces that callers either catch or re-declare these exceptions. Exception translation (Bloch Item 73) is the practice of catching a lower-level exception and throwing a higher-level one: `catch (SQLException e) { throw new DataAccessException(e); }` — the original exception is preserved as the cause. This is Java's equivalent of Rust's `From` conversion. Java does not have an equivalent of `?` — every propagation or translation is explicit code. The verbosity of checked exceptions is why many modern Java libraries use unchecked exceptions exclusively. |
| 4.3 | 25 min | **Python: exception bubbling and chaining.** Read Martelli Ch.6 pp. 206–210 (raise statement, `raise ExceptionType from original_exception`, implicit exception chaining via `__context__`). Read PEP 3134 (Exception Chaining and Embedded Tracebacks) online. Key insight: Python exceptions propagate automatically — if an except block does not catch an exception, it bubbles up to the next enclosing try or to the top level. This is implicit propagation, unlike Rust's explicit `?`. Exception chaining (Python 3): `raise NewException("message") from original` sets `__cause__` for explicit chaining. If an exception is raised inside an except block, `__context__` is set automatically (implicit chaining). `raise NewException("message") from None` suppresses chaining. The traceback object, attached to each exception via `__traceback__`, records the full call stack. Python's propagation model is the most "hands-off" — errors propagate without any syntax or declaration by the programmer. |
| 4.4 | 15 min | **Three-way comparison of propagation.** Compare the same 3-layer call stack (function C calls B calls A, A fails) in all three languages. Rust: A returns `Result`, B uses `?` with a `From` conversion, C uses `?` or `match`. Java: A throws checked `IOException`, B catches and translates to `ServiceException`, C catches `ServiceException`. Python: A raises `ValueError`, B either catches and wraps with `raise ServiceError() from e` or lets it bubble unchanged, C catches `ServiceError`. Key insight: Rust's propagation is explicit at every level (the `?` is visible); Java's is partially explicit (throws declares, catch translates); Python's is fully implicit (exceptions bubble without any code). |

---

### Session 5 — Resource Management: RAII, try-with-resources, Context Managers

**Goal:** understand how each language ensures resources (files, locks, connections) are released even when errors occur — Rust's automatic RAII via Drop, Java's try-with-resources, and Python's context managers.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: RAII and Drop for error-safe cleanup.** Read Blandy Ch.7 pp. 155–158 (error handling and resource cleanup, why Result + RAII makes cleanup automatic). Cross-reference with Topic 5 material on RAII/Drop (Rust Reference — Destructors online, std docs — Drop trait online). Read the Rust By Example "RAII" page online. Key insight: Rust's RAII model means error handling and resource cleanup are orthogonal — you do not need special syntax for cleanup in error paths because Drop runs automatically when values go out of scope, regardless of whether the scope exits normally or via `?` early return. This is unique among the three languages: there is no `try-with-resources` or `with` statement in Rust because none is needed. When `?` causes an early return from a function, all local variables are dropped in reverse declaration order, closing files, releasing locks, and freeing memory automatically. The only caveat: `panic!` also unwinds and calls Drop, unless `panic = "abort"` is configured. |
| 5.2 | 30 min | **Java: try-with-resources.** Read Horstmann Ch.7 pp. 99–102 (try-with-resources statement, multiple resources, suppressed exceptions). Cross-reference with Bloch Ch.2 pp. 33–35 (Item 9: prefer try-with-resources to try-finally). Read the Oracle Java Tutorials "The try-with-resources Statement" page and the Java docs for `AutoCloseable` online. Key insight: Java's try-with-resources (`try (var conn = getConnection()) { ... }`) guarantees that `conn.close()` is called at block exit. The resource must implement `AutoCloseable`. If both the try block and `close()` throw exceptions, the try-block exception is the primary one and the close() exception is added as a "suppressed" exception (retrievable via `getSuppressed()`). Before Java 7, the try-finally pattern was used, which had the critical flaw of swallowing the original exception if finally also threw. try-with-resources is the correct approach, but it requires explicit syntax at every use site — unlike Rust's automatic Drop. Multiple resources can be declared in a single try-with-resources statement; they are closed in reverse declaration order. |
| 5.3 | 30 min | **Python: context managers and the with statement.** Read Ramalho Ch.18 pp. 657–694 (full chapter: context managers, `__enter__`/`__exit__`, the `contextlib` module, `@contextmanager` decorator, nesting, `contextlib.ExitStack`). Read Martelli Ch.6 pp. 213–219 (the with statement, generators and exceptions in context managers). Key insight: Python's `with` statement invokes `__enter__()` on entry and `__exit__(exc_type, exc_val, exc_tb)` on exit. If an exception occurs, `__exit__` receives the exception info; if it returns `True`, the exception is suppressed. `contextlib.contextmanager` allows writing context managers as generators: code before `yield` is `__enter__`, code after `yield` is `__exit__`. `contextlib.ExitStack` manages dynamic numbers of context managers. Like Java's try-with-resources, `with` requires explicit syntax at every call site. The `else` clause in `try`/`except`/`else`/`finally` interacts with context managers — `else` runs only if the `try` block succeeds, before `finally`. |
| 5.4 | 15 min | **Three-way comparison.** Write the same file-processing function in all three languages, showing how cleanup happens on both success and error paths. Rust: `File::open()` returns `Result`, the `File` is dropped automatically on function exit. Java: `try (var f = new FileReader(...))` with AutoCloseable. Python: `with open(...) as f:`. Compare: (1) who must opt in (Rust: nobody — automatic; Java/Python: every call site), (2) what happens if cleanup itself fails (Rust: Drop must not panic; Java: suppressed exceptions; Python: `__exit__` exception replaces original unless handled), (3) composition (Rust: nested scopes; Java: multi-resource try; Python: `ExitStack`). |

---

### Session 6 — Custom Error Types and Error Composition

**Goal:** learn to design custom error types — Rust's enum-based error types with `std::error::Error` and `From` impls, Java's custom exception hierarchies with chained exceptions, and Python's custom exception classes.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 35 min | **Rust: defining custom error types.** Read Gjengset Ch.4 pp. 57–65 (representing errors: enumeration vs opaque, propagating errors, `Box<dyn Error>`, when to use each strategy). Read Blandy Ch.7 pp. 153–158 (custom error types, implementing `std::fmt::Display` and `std::error::Error`, the `source()` method for error chains). Read McNamara Ch.8 pp. 251–291 (ergonomic error handling for libraries — designing error types for public APIs, composing errors from multiple subsystems). Key insight: a Rust library's public error type is part of its API surface. The enumerated approach (`enum MyError { Io(io::Error), Parse(ParseIntError) }`) gives callers exhaustive matching — they can handle each variant differently. This requires `impl Display` (for human-readable messages), `impl Error` (for the error trait), and `impl From<io::Error> for MyError` (for `?` to work). The opaque approach (`Box<dyn Error>` or `anyhow::Error`) hides the internal error structure — simpler for applications but less useful for library consumers. The key design question: are your callers going to programmatically match on error variants? If yes, use enumerated errors. If no (application code), use opaque errors. |
| 6.2 | 25 min | **Java: custom exception classes and chaining.** Read Bloch Ch.10 pp. 299–303 (Item 72: favor the use of standard exceptions; Item 73: throw exceptions appropriate to the abstraction — exception translation and chaining). Read Horstmann Ch.7 pp. 96–98 (defining custom exception classes). Key insight: custom Java exceptions extend `Exception` (checked) or `RuntimeException` (unchecked). Best practice: keep the hierarchy shallow, reuse standard exceptions when possible (IllegalArgumentException, IllegalStateException, UnsupportedOperationException). Exception chaining via the `cause` constructor parameter preserves the original exception: `throw new ServiceException("failed", ioe)`. The `initCause()` method chain-links exceptions after construction. `getCause()` and `printStackTrace()` traverse the chain. Bloch's Item 73 is the Java equivalent of Rust's `From` — translate low-level exceptions to domain-appropriate exceptions at abstraction boundaries. |
| 6.3 | 25 min | **Python: custom exception classes.** Read Martelli Ch.6 pp. 215–219 (custom exception classes, exception groups). Read the Python docs "User-defined Exceptions" tutorial online. Key insight: custom Python exceptions inherit from `Exception` (or a more specific built-in exception). Best practice: define a base exception for your package (`class MyLibError(Exception): pass`), then specific subclasses (`class ConfigError(MyLibError): pass`). Exception chaining: `raise ConfigError("bad config") from original_exception` sets `__cause__`. Custom exceptions should store relevant context as attributes. Unlike Rust, Python exceptions are classes with methods and attributes, so you can add structured error information (error codes, field names, etc.) as instance attributes. Unlike Java, there is no checked/unchecked distinction — all custom exceptions are unchecked. |
| 6.4 | 15 min | **Cross-language comparison.** Design the same error type in all three languages: a "data pipeline error" that can be a parse error, a validation error, or an I/O error, each with context information. Compare: (1) how the type is defined (Rust: enum with variants, Java: exception hierarchy, Python: exception class hierarchy), (2) how the original error is preserved (Rust: enum variant wrapping + `source()`, Java: `cause` constructor, Python: `__cause__` / `__context__`), (3) how callers match on error type (Rust: `match`, Java: multiple `catch`, Python: multiple `except`). |

---

### Session 7 — Error Handling Ecosystem: thiserror, anyhow, Standard Exceptions

**Goal:** master the Rust ecosystem tools for error handling (`thiserror` for libraries, `anyhow` for applications), and compare with Java's standard exception patterns and Python's exception hierarchy conventions.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 35 min | **Rust: thiserror.** Read the thiserror crate documentation online (`https://docs.rs/thiserror`). Read Gjengset Ch.4 pp. 59–62 (enumeration approach to errors — context for when thiserror is appropriate). Key insight: `thiserror` is a derive macro that automates implementing `Display`, `Error`, and `From` for custom error enums. `#[derive(thiserror::Error)]` with `#[error("message")]` attributes generates the boilerplate. `#[from]` on a variant generates `From` implementations for `?` propagation. `#[source]` marks the field that `Error::source()` returns. thiserror is for library code where you want a typed, public error enum. It generates zero runtime overhead — it is purely a compile-time code generation tool. The key benefit: you get proper error chains (`source()`), display messages, and `From` implementations from a few derive attributes. |
| 7.2 | 30 min | **Rust: anyhow.** Read the anyhow crate documentation online (`https://docs.rs/anyhow`). Read Gjengset Ch.4 pp. 62–65 (opaque errors — when to use `Box<dyn Error>` / `anyhow::Error`). Read Andrew Gallant's "Error Handling in Rust" blog post online for the practical workflow. Key insight: `anyhow::Error` is an opaque error type that wraps any `std::error::Error` and adds context chaining via `.context("what we were doing")`. Functions return `anyhow::Result<T>` instead of `Result<T, MyError>`. `anyhow` is for application code where callers do not need to programmatically match on error variants — they just need a human-readable error chain for logging or display. The `bail!` macro is like `return Err(anyhow!(...))`. The `ensure!` macro is a conditional bail. The `?` operator automatically wraps any error in `anyhow::Error`. The key distinction: thiserror = library (typed errors for callers to match on), anyhow = application (opaque errors for humans to read). |
| 7.3 | 20 min | **Java: standard exception patterns.** Read Bloch Ch.10 pp. 297–299 (Item 72: favor the use of standard exceptions — IllegalArgumentException, IllegalStateException, NullPointerException, UnsupportedOperationException, ConcurrentModificationException). Read Valeev Ch.5 pp. 124–154 (common exception patterns and anti-patterns). Key insight: Java's standard library defines a rich exception hierarchy that covers most error cases. Best practices: reuse standard exceptions before creating custom ones; prefer unchecked exceptions for programming errors; use checked exceptions only when the caller can reasonably recover. Anti-patterns: catching and ignoring, catching too broadly, using exceptions for flow control, declaring `throws Exception` instead of specific types. Modern Java increasingly favors unchecked exceptions (following the Kotlin, Scala, and Rust influence), with checked exceptions mainly surviving in the I/O and JDBC APIs. |
| 7.4 | 20 min | **Python: exception hierarchy conventions.** Read Martelli Ch.6 pp. 195–200 and 215–219 (exception hierarchy, custom exceptions, error-checking strategies). Read the Python docs exception hierarchy tree online. Key insight: Python's built-in exception hierarchy is well-designed for common use cases. `ValueError` (wrong value), `TypeError` (wrong type), `KeyError` (missing key), `AttributeError` (missing attribute), `FileNotFoundError` (subclass of `OSError`). Best practice: catch specific exceptions, not broad `except Exception`. Use exception hierarchy for package-level error grouping (define a package base exception). Python's convention for "not found" varies: `KeyError` for dicts, `StopIteration` for iterators, return `None` for some APIs (like `dict.get()`). Compare with Rust's approach where all these would be `Result` or `Option` return values. |

---

### Session 8 — ExceptionGroup, except*, and Error Handling in Concurrent Code

**Goal:** understand modern error handling patterns for concurrent code — Python 3.11+'s ExceptionGroup and `except*`, Java's structured concurrency error handling, and Rust's approach to errors in spawned tasks.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 30 min | **Python: ExceptionGroup and except*.** Read Martelli Ch.6 pp. 215–219 (ExceptionGroup, `except*` syntax). Read PEP 654 (Exception Groups and except*) online in full. Key insight: `ExceptionGroup` (Python 3.11+) wraps multiple exceptions that occurred concurrently. `except*` is a new clause that matches subgroups of exceptions within a group — each `except*` handler can match a subset of the exceptions, and unmatched exceptions continue propagating. This was designed for `asyncio.TaskGroup` and other structured concurrency APIs where multiple concurrent tasks can each fail independently. Example: `async with asyncio.TaskGroup() as tg: ...` raises `ExceptionGroup` if any tasks fail. `except* ValueError as eg:` catches all `ValueError` instances in the group. Multiple `except*` clauses can all match on the same `ExceptionGroup` (unlike regular `except`, where only the first match runs). `ExceptionGroup` can be nested (group within a group). The `exceptiongroup` backport package provides this for Python 3.7+. |
| 8.2 | 30 min | **Java: exception handling in concurrent code.** Read Evans Ch.5 pp. 119–166 (exception handling in concurrency — ExecutorService, `Future.get()` and ExecutionException). Read JEP 453 (Structured Concurrency) online. Read the Baeldung article on CompletableFuture exception handling online. Key insight: Java's `Future.get()` wraps the task's exception in `ExecutionException` — the caller must call `getCause()` to access the original exception. This is exception translation forced by the concurrency API. `CompletableFuture` provides `exceptionally()`, `handle()`, and `whenComplete()` for functional-style error handling. Java 21's `StructuredTaskScope` (preview) provides structured concurrency: `ShutdownOnFailure` cancels sibling tasks when one fails and rethrows the first exception; `ShutdownOnSuccess` cancels remaining tasks when one succeeds. Unlike Python's `ExceptionGroup`, Java does not (yet) have a built-in mechanism for aggregating multiple concurrent failures — `StructuredTaskScope.ShutdownOnFailure` reports only the first failure. |
| 8.3 | 25 min | **Rust: error handling in async tasks.** Read the Tokio docs on JoinError, JoinSet, and task error handling online. Cross-reference with Gjengset Ch.4 pp. 57–65 for general error composition patterns. Key insight: in Rust, `tokio::spawn(async { ... })` returns `JoinHandle<T>`. If the spawned task panics, `handle.await` returns `Err(JoinError)`. If the task returns `Result<T, E>`, the handle produces `Result<Result<T, E>, JoinError>` — a nested Result (outer for join/panic, inner for application error). `tokio::task::JoinSet` manages a set of spawned tasks and yields results as they complete. Error handling requires unwrapping both layers. Rust does not have an ExceptionGroup equivalent — you collect errors from multiple tasks into a `Vec<Error>` or use a custom aggregate error type. The `?` operator does not compose over multiple concurrent errors — this is a genuine ergonomic gap compared to Python's `except*`. |
| 8.4 | 20 min | **Cross-language comparison of concurrent error handling.** Write the same scenario in all three: launch 3 concurrent tasks, 2 of which fail, collect results. Python: `asyncio.TaskGroup` + `ExceptionGroup` + `except*`. Java: `StructuredTaskScope.ShutdownOnFailure` (first-failure-only) or manual `CompletableFuture.allOf()` with aggregation. Rust: `tokio::task::JoinSet` + manual `Vec<anyhow::Error>` collection. Key takeaway: Python 3.11+ has the most native support for multiple concurrent errors (ExceptionGroup). Java is evolving toward this with structured concurrency. Rust requires manual aggregation but provides compile-time safety for the error types. |

---

### Session 9 — Cross-Language Patterns, Anti-Patterns, and Best Practices

**Goal:** synthesize everything learned into practical error handling guidelines — what to do, what to avoid, and how the three languages' best practices compare.

| Step | Time | Activity |
|------|------|----------|
| 9.1 | 30 min | **Rust best practices.** Re-read Gjengset Ch.4 pp. 57–65 (complete re-read with fresh eyes after Sessions 1–8). Read the Rust API Guidelines "Error handling" section online. Read The Rustonomicon "Unwinding" section online. Key insight synthesis: (1) Library crates should define their own error enum, use `thiserror`, and implement `std::error::Error`. (2) Application crates should use `anyhow` or a similar opaque error type. (3) Never `unwrap()` in library code — use `expect()` with a message if panic is intentional. (4) Use `?` for propagation, implement `From` for conversion. (5) `panic!` is for bugs (violated invariants, unreachable states), never for expected failures. (6) At FFI boundaries, use `catch_unwind` to prevent panics from crossing language boundaries. (7) In `main()`, return `Result<(), Box<dyn Error>>` or `anyhow::Result<()>` for clean error reporting. |
| 9.2 | 25 min | **Java best practices.** Re-read Bloch Ch.10 pp. 293–309 (all Items 69–77 re-read as a complete guide). Key insight synthesis: (1) Use exceptions only for exceptional conditions (Item 69). (2) Use checked exceptions for recoverable conditions, unchecked for programming errors (Item 70). (3) Avoid unnecessary checked exceptions (Item 71) — if the caller cannot reasonably recover, use unchecked. (4) Favor standard exceptions (Item 72). (5) Throw exceptions appropriate to the abstraction — use exception translation (Item 73). (6) Document all exceptions with `@throws` (Item 74). (7) Include failure-capture information in exception messages (Item 75). (8) Strive for failure atomicity — leave objects in a consistent state (Item 76). (9) Never ignore exceptions (Item 77). Modern addition: prefer try-with-resources for all `AutoCloseable` resources. |
| 9.3 | 25 min | **Python best practices.** Re-read Martelli Ch.6 pp. 195–219 (full chapter re-read). Read Viafore Ch.20 pp. 285–296 (static analysis for error detection). Key insight synthesis: (1) Embrace EAFP — try the operation, catch the exception. (2) Catch specific exceptions, never bare `except:`. (3) Use `except Exception:` if you must catch broadly, never `except BaseException:`. (4) Use `with` statements for all resource management. (5) Define custom exceptions inheriting from `Exception`, with a package base exception. (6) Use `raise ... from` for explicit exception chaining. (7) Use `else` clause to separate protected code from success-path code. (8) Use `ExceptionGroup` and `except*` for concurrent error handling (Python 3.11+). (9) Use type annotations (mypy/pyright) to catch potential errors statically. (10) Never silence exceptions without logging or handling. |
| 9.4 | 25 min | **Grand synthesis and anti-pattern catalog.** Create a comprehensive comparison table: rows = {how to handle expected errors, how to handle bugs, how to propagate errors, how to clean up resources, how to define custom errors, how to chain errors, how to handle concurrent errors, common anti-patterns}, columns = {Rust, Java, Python}. Catalog anti-patterns across all three: (1) swallowing errors silently (Java empty catch, Python bare except, Rust `.ok()` discarding error info), (2) overly broad error handling (Java catching Throwable, Python `except Exception` in the wrong place, Rust `Box<dyn Error>` in library code), (3) not preserving error context (Java rethrowing without cause, Python raise without from, Rust converting without `source()`), (4) using exceptions for control flow (Java, Python) or panic for expected failures (Rust). |

# Code Like a Pro in Rust

## Book Metadata
- **Title:** Code Like a Pro in Rust
- **Author:** Brenden Matthews
- **Publisher:** Manning Publications
- **Year:** 2024
- **Pages:** 265
- **ISBN:** 9781617299643

## Target Audience and Prerequisites
- Beginner to intermediate Rust programmers already familiar with basics
- Developers looking to improve professional Rust practices
- Requires prior knowledge of Rust fundamentals (syntax, basic concepts)
- New to Rust? Start with "Rust in Action" or the official Rust book first

## Overall Focus
Practical, professional-level Rust development rather than introductory syntax. Focuses on navigating the Rust ecosystem, understanding when to use Rust, and mastering strategies for productivity. Supplements official documentation with lessons and patterns not readily found elsewhere. Organized in 5 parts: project management, core data, correctness, async Rust, and optimizations.

---

## Table of Contents

### Chapter 1: Feelin' Rusty (pp. 1-8)
- What's Rust? What's unique? (safe, modern, vs other languages)
- When should you use Rust? (use cases, open source)
- Tools you'll need

**Summary:** Positioning Rust within the language landscape. Safety guarantees, performance characteristics, comparison with C/C++/Python/Go, and when Rust is the right choice.

---

### Part 1: Pro Rust (pp. 9-62)

#### Chapter 2: Project Management with Cargo (pp. 11-42)
- Cargo tour (creating projects, building/running/testing, toolchains)
- Dependency management (Cargo.lock)
- Feature flags
- Patching dependencies (indirect, best practices)
- Publishing crates (CI/CD integration)
- Linking to C libraries
- Binary distribution (cross-compilation, static linking)
- Documenting Rust projects (code examples in docs)
- Modules, Workspaces, Custom build scripts
- Rust in embedded environments

**Summary:** Comprehensive Cargo guide: project creation, dependency management, feature flags, crate publishing, CI/CD, FFI linking, cross-compilation, documentation, modules, workspaces, and embedded development.

#### Chapter 3: Rust Tooling (pp. 43-62)
- rust-analyzer (IDE integration, magic completions)
- rustfmt (code formatting, configuration)
- Clippy (lints, configuration, auto-applying, CI/CD)
- sccache (compilation time reduction)
- IDE integration (VS Code and others)
- Stable vs nightly toolchains
- Additional tools: cargo-update, cargo-expand, cargo-fuzz, cargo-watch, cargo-tree

**Summary:** Rust tooling ecosystem: rust-analyzer for IDE support, rustfmt for formatting, Clippy for linting, sccache for faster builds. Covers stable vs nightly tradeoffs and essential cargo extensions (expand, fuzz, watch, tree).

---

### Part 2: Core Data (pp. 63-118)

#### Chapter 4: Data Structures (pp. 65-91)
- Demystifying String types (String vs str vs &str vs &'static str)
- Slices and arrays
- Vectors (Vec, related types, wrapping, custom hashing)
- Maps (HashMap, BTreeMap, hashable types)
- Rust types (primitives, structs, enums, aliases)
- Error handling with Result
- Type conversion (From/Into, TryFrom/TryInto)
- FFI compatibility

**Summary:** Detailed type system exploration. String variants explained, slices/arrays/vectors, maps with custom hashing, structs/enums, Result/Option for error handling, type conversion traits, and FFI type compatibility.

#### Chapter 5: Working with Memory (pp. 93-118)
- Heap and stack
- Ownership (copies, borrowing, references, moves)
- Deep copying
- Avoiding copies
- Smart pointers: Box, Rc, Arc
- Reference counting (single-threaded Rc, multi-threaded Arc)
- Clone on write (Cow)
- Custom allocators (protected memory)

**Summary:** In-depth memory management. Heap/stack, ownership semantics, smart pointers (Box, Rc, Arc), reference counting, Cow pattern, and custom allocators. Critical for writing efficient and safe Rust code.

---

### Part 3: Correctness (pp. 119-154)

#### Chapter 6: Unit Testing (pp. 121-140)
- How testing is different in Rust
- Built-in testing features
- Testing frameworks
- What not to test (compiler knows better)
- Parallel test special cases and global state
- Refactoring tools (rename, reformat, relocate, rewrite)
- Code coverage

**Summary:** Rust's built-in testing and how the compiler prevents certain bugs. Covers when testing is needed vs compiler-guaranteed, parallel test handling, refactoring strategies, and coverage measurement. Emphasizes testing for confidence in changes.

#### Chapter 7: Integration Testing (pp. 141-154)
- Unit vs integration testing strategies
- Built-in vs external integration testing
- Libraries: assert_cmd (CLI testing), proptest (property-based)
- Fuzz testing

**Summary:** Integration testing beyond unit tests. Built-in and external approaches, CLI testing with assert_cmd, property-based testing with proptest, and fuzz testing strategies.

---

### Part 4: Asynchronous Rust (pp. 155-216)

#### Chapter 8: Async Rust (pp. 157-180)
- Runtimes (Tokio)
- Thinking asynchronously
- Futures and the Future trait
- async/.await keywords
- Concurrency and parallelism with async
- Implementing an async observer
- Mixing sync and async
- When to avoid async
- Tracing and debugging async code
- Testing async code

**Summary:** Async Rust with Tokio runtime. Covers async/await syntax, futures, task scheduling, blocking vs non-blocking I/O, async observer pattern, mixing sync/async code, and debugging with tracing.

#### Chapter 9: Building an HTTP REST API Service (pp. 182-203)
- Choosing a web framework (Axum)
- Architecture (load balancer, API, database)
- API design (CRUD endpoints, health checks)
- Application scaffolding, Data modeling (SQL)
- Route declaration and implementation
- Error handling, Running the service

**Summary:** Complete async HTTP REST API with Axum. Architecture decisions, CRUD endpoints, SQLite database integration, JSON serialization, health checks, CORS, error responses, and logging/tracing.

#### Chapter 10: Building an HTTP REST API CLI (pp. 204-216)
- Tool/library selection
- CLI design, Command declaration and implementation
- HTTP requests, Error handling
- Testing CLI applications

**Summary:** Async HTTP client CLI complementing the API service. Command-line argument parsing, HTTP client implementation, error handling, and CLI testing with assert_cmd.

---

### Part 5: Optimizations (pp. 217-231)

#### Chapter 11: Optimizations (pp. 219-231)
- Zero-cost abstractions
- Vector optimization (allocation, iterators, fast copies with slices)
- SIMD (Single Instruction Multiple Data)
- Parallelization with Rayon
- Using Rust to accelerate other languages (FFI)

**Summary:** Performance optimization: zero-cost abstractions, vector/iterator performance, SIMD instructions, data parallelism with Rayon, and using Rust via FFI to accelerate Python/other languages. Emphasizes measuring before optimizing.

### Appendix: Installing Tools (pp. 233-235)

---

## Key Topics and Concepts

### Project Management & Tooling
- Cargo (dependencies, features, workspaces, publishing)
- rust-analyzer, rustfmt, Clippy, sccache
- Cross-compilation, static linking
- CI/CD integration
- cargo extensions (expand, fuzz, watch, tree)

### Data Structures & Types
- String types (String, str, &str, &'static str)
- Vectors, slices, arrays
- HashMap, BTreeMap (custom hashing)
- Enums with pattern matching
- Result/Option, From/Into/TryFrom/TryInto
- FFI type compatibility

### Memory Management
- Ownership, borrowing, moves
- Smart pointers (Box, Rc, Arc)
- Cow (clone on write)
- Custom allocators

### Testing
- Unit testing (#[test], what not to test)
- Property-based testing (proptest)
- Integration testing, CLI testing (assert_cmd)
- Fuzz testing, Code coverage

### Async Programming
- Tokio runtime, async/await, Futures
- Axum web framework
- HTTP REST APIs (server + client)
- Mixing sync and async code
- Tracing and debugging async

### Performance
- Zero-cost abstractions
- SIMD vectorization
- Rayon (data parallelism)
- FFI for accelerating other languages

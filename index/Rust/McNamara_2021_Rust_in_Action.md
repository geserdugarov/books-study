# Rust in Action

## Book Metadata
- **Title:** Rust in Action: Systems Programming Concepts and Techniques
- **Author:** Tim McNamara
- **Publisher:** Manning Publications
- **Year:** 2021
- **Pages:** 456
- **ISBN:** 978-1-617-29455-6

## Target Audience and Prerequisites
- Programmers wanting to learn Rust through practical, systems-level projects
- Developers from other languages interested in systems programming concepts
- No prior Rust or systems programming experience required
- Some general programming experience recommended

## Overall Focus
A project-driven introduction to Rust that teaches both the language and systems programming concepts simultaneously. Through building practical projects — a database, a CPU emulator, an operating system kernel, a network client, and more — readers learn Rust's ownership model, type system, and low-level capabilities. Unique in bridging the gap between learning Rust syntax and understanding how computers actually work at the hardware level.

---

## Table of Contents

### Chapter 1: Introducing Rust (pp. 1-27)
- Where is Rust used?
- Advocating for Rust at work
- A taste of the language (Hello World, first Rust program)
- What does Rust look and feel like?
- What is Rust? (Safety, Productivity, Control)
- Rust's big features (performance, concurrency, memory efficiency)
- Downsides of Rust (cyclic data structures, compile times, strictness)
- TLS security case studies (Heartbleed, Goto fail)
- Where does Rust fit best?

**Summary:** Motivates why Rust exists and where it excels. Covers Rust's three goals — safety, productivity, and control — and demonstrates its applicability across domains from CLI tools to embedded systems. Uses real-world TLS vulnerabilities (Heartbleed, Goto fail) to illustrate why memory safety matters.

### Part 1: Rust Language Distinctives (pp. 29-133)

### Chapter 2: Language Foundations (pp. 31-75)
- Creating a running program (rustc, cargo)
- A glance at Rust's syntax (variables, functions)
- Numbers (integers, floats, base notation, comparing, rational/complex numbers)
- Flow control (for, continue, while, loop, break, if/else, match)
- Defining functions
- Using references
- Project: Rendering the Mandelbrot set
- Advanced function definitions (lifetime annotations, generic functions)
- Creating grep-lite
- Making lists of things with arrays, slices, and vectors
- Including third-party code
- Supporting command-line arguments
- Reading from files and stdin

**Summary:** Comprehensive foundation covering Rust syntax, numeric types, control flow, and functions. Progresses from basics through practical projects (Mandelbrot renderer, grep-lite) to introduce references, generics, and the crate ecosystem.

### Chapter 3: Compound Data Types (pp. 77-105)
- Using plain functions to experiment with an API
- Modeling files with struct
- Adding methods to a struct with impl
- Returning errors
- Defining and making use of an enum
- Defining common behavior with traits
- Exposing your types to the world (protecting private data)
- Creating inline documentation for your projects

**Summary:** Teaches Rust's compound types — structs, enums, and traits — through building a file abstraction. Covers method definition with impl blocks, error handling with Result, visibility rules, and documentation with rustdoc.

### Chapter 4: Lifetimes, Ownership, and Borrowing (pp. 107-133)
- Implementing a mock CubeSat ground station
- Guide to the figures in this chapter
- What is an owner? Does it have any responsibilities?
- How ownership moves
- Resolving ownership issues (references, fewer long-lived values, duplicating values, wrapping data in specialty types)

**Summary:** Deep dive into Rust's unique ownership system through a satellite ground station project. Explains ownership rules, move semantics, and strategies for resolving ownership conflicts: borrowing, cloning, and using Rc/Arc wrapper types.

### Part 2: Demystifying Systems Programming (pp. 135-417)

### Chapter 5: Data in Depth (pp. 137-173)
- Bit patterns and types
- Life of an integer (endianness)
- Representing decimal numbers
- Floating-point numbers (f32 internals, sign bit, exponent, mantissa)
- Fixed-point number formats
- Generating random probabilities from random bytes
- Implementing a CPU to establish that functions are also data

**Summary:** Explores how data is represented at the hardware level. Covers integer encoding, endianness, IEEE 754 floating-point internals, fixed-point arithmetic, and culminates in building a CPU emulator to demonstrate that code is data.

### Chapter 6: Memory (pp. 175-211)
- Pointers
- Exploring Rust's reference and pointer types (raw pointers, pointer ecosystem, smart pointer building blocks)
- Providing programs with memory for their data (stack, heap, dynamic memory allocation)
- Virtual memory (scanning process memory, translating virtual to physical addresses, working with OS address space)

**Summary:** Comprehensive treatment of memory management: pointers (raw, references, smart pointers), stack vs. heap allocation, dynamic memory allocation analysis, and virtual memory with practical examples of scanning and manipulating process memory.

### Chapter 7: Files and Storage (pp. 212-249)
- What is a file format?
- Creating your own file formats for data storage (serde, bincode)
- Implementing a hexdump clone
- File operations in Rust (opening files, filesystem interaction with std::fs::Path)
- Implementing a key-value store with a log-structured, append-only storage architecture
- Actionkv v1: The front-end code
- Understanding the core of actionkv: The libactionkv crate
- Working with keys and values with HashMap and BTreeMap

**Summary:** File I/O and storage systems. Builds a complete key-value database (actionkv) with log-structured storage, covering serialization with serde, binary formats, checksums, and comparing HashMap vs BTreeMap performance characteristics.

### Chapter 8: Networking (pp. 251-291)
- All of networking in seven paragraphs
- Generating an HTTP GET request with reqwest
- Trait objects
- TCP (ports, hostname resolution)
- Ergonomic error handling for libraries
- MAC addresses
- Implementing state machines with Rust's enums
- Raw TCP, creating a virtual networking device, "Raw" HTTP

**Summary:** Networking from high to low level. Starts with HTTP via reqwest, progresses through trait objects for polymorphism, TCP socket programming, custom error types, and culminates in implementing raw TCP/HTTP and virtual networking devices.

### Chapter 9: Time and Timekeeping (pp. 293-327)
- Background and sources of time
- Definitions and encoding time (time zones)
- clock v0.1.0: Teaching an application how to tell the time
- clock v0.1.1: Formatting timestamps to comply with ISO 8601
- clock v0.1.2: Setting the time (libc, cross-platform)
- Improving error handling
- clock v0.1.3: Resolving differences between clocks with NTP

**Summary:** Time representation and synchronization through building a progressively more sophisticated clock application. Covers time zones, ISO 8601 formatting, cross-platform system clock manipulation via libc/FFI, and NTP protocol implementation.

### Chapter 10: Processes, Threads, and Containers (pp. 328-363)
- Anonymous functions (closures)
- Spawning threads (closures, few/many threads, reproducing results, shared variables)
- Differences between closures and functions
- Procedurally generated avatars from a multithreaded parser and code generator
- Concurrency and task virtualization (threads, context switching, processes, WebAssembly, containers)

**Summary:** Concurrency in Rust: closures, thread spawning with controlled sharing, and a multithreaded avatar generator project. Covers the spectrum of concurrency abstractions from OS threads to WebAssembly and containers.

### Chapter 11: Kernel (pp. 365-387)
- A fledgling operating system (FledgeOS)
- Fledgeos-0: Getting something working (first boot, compilation, panic handling, VGA text mode)
- fledgeos-1: Avoiding a busy loop (interacting with CPU directly)
- fledgeos-2: Custom exception handling
- fledgeos-3: Text output (VGA frame buffer, enums for color)
- fledgeos-4: Custom panic handling (core::fmt::Write)

**Summary:** Building a minimal operating system kernel (FledgeOS) in Rust. Progressively adds boot sequence, CPU interaction, exception handling, VGA text output, and custom panic handlers — demonstrating Rust's no_std capabilities for bare-metal programming.

### Chapter 12: Signals, Interrupts, and Exceptions (pp. 390-417)
- Glossary (signals vs. interrupts)
- How interrupts affect applications
- Software interrupts and hardware interrupts
- Signal handling (default behavior, suspend/resume, listing signals)
- Handling signals with custom actions (global variables)
- Sending application-defined signals (function pointers)
- Ignoring signals
- Shutting down from deeply nested call stacks (setjmp/longjmp)
- Applying these techniques to platforms without signals
- Revising exceptions

**Summary:** Low-level signal and interrupt handling in Rust. Covers Unix signals, custom signal handlers with global state, function pointers, and implementing non-local jumps (setjmp/longjmp) via FFI — bridging Rust's safety guarantees with OS-level mechanisms.

---

## Key Topics and Concepts

### Systems Programming
- CPU emulation and instruction sets
- Memory layout (stack, heap, virtual memory)
- OS kernel development (bare-metal Rust, no_std)
- Signals, interrupts, and exception handling
- Process and thread management

### Rust Core Concepts
- Ownership, borrowing, and lifetimes
- Structs, enums, and traits
- Error handling with Result and custom error types
- Smart pointers and reference types
- Closures and trait objects

### Data and Storage
- Bit-level data representation (integers, floats, endianness)
- File I/O and binary formats (serde, bincode)
- Key-value store implementation (log-structured storage)
- HashMap vs BTreeMap

### Networking and Time
- HTTP, TCP, and raw networking
- NTP protocol implementation
- Cross-platform time handling via FFI
- State machines with enums

### Concurrency
- Thread spawning and shared state
- Closures vs functions
- Multithreaded code generation
- WebAssembly and containers

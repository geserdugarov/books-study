# Rust Atomics and Locks

## Book Metadata
- **Title:** Rust Atomics and Locks: Low-Level Concurrency in Practice
- **Author:** Mara Bos
- **Publisher:** O'Reilly Media
- **Year:** 2023
- **Pages:** 221
- **ISBN:** 978-1-098-11944-7
- **Foreword by:** Paul E. McKenney (Meta Platforms Kernel Team)

## Target Audience and Prerequisites
- Rust developers who want to learn about low-level concurrency
- Developers from other languages wanting to understand low-level concurrency from a Rust perspective
- Assumes basic Rust knowledge (compiling with cargo, basic syntax)
- No prior knowledge of Rust concurrency required
- Author is team lead of the Rust standard library team and founder/CTO at Fusion Engineering
- Code examples use Rust 1.66.0+

## Overall Focus
A hands-on guide to low-level concurrency in Rust, covering atomics, memory ordering, and how they combine with OS primitives to build synchronization tools like mutexes and condition variables. Unique in connecting abstract memory model theory to real hardware behavior (x86-64, ARM64) and OS kernel APIs (Linux futex, POSIX, Windows). Progressively builds spin locks, channels, Arc, and full mutex/condvar/rwlock implementations from scratch.

---

## Table of Contents

### Chapter 1: Basics of Rust Concurrency (pp. 1-29)
- Threads in Rust
- Scoped Threads
- Shared Ownership and Reference Counting (statics, leaking, reference counting)
- Borrowing and Data Races
- Interior Mutability (Cell, RefCell, Mutex and RwLock, Atomics, UnsafeCell)
- Thread Safety: Send and Sync
- Locking: Mutexes and RwLocks (Rust's Mutex, lock poisoning, reader-writer lock)
- Waiting: Parking and Condition Variables (thread parking, condition variables)

**Summary:** Foundational chapter covering all Rust concurrency primitives needed for the rest of the book. Introduces threads (regular and scoped), shared ownership (Arc, static, leaking), borrowing rules that prevent data races, interior mutability types (Cell, RefCell, Mutex, RwLock, Atomics, UnsafeCell), the Send and Sync marker traits, Mutex and RwLock usage, and thread synchronization via parking and condition variables.

### Chapter 2: Atomics (pp. 31-47)
- Atomic Load and Store Operations (stop flag, progress reporting, lazy initialization examples)
- Fetch-and-Modify Operations (progress from multiple threads, statistics, ID allocation examples)
- Compare-and-Exchange Operations (ID allocation without overflow, lazy one-time initialization examples)

**Summary:** Rust's atomic types and all their operations, explored through practical examples. Covers load/store for stop flags and progress reporting, fetch_add/fetch_sub for statistics and ID allocation, and compare_exchange/compare_exchange_weak for overflow-safe ID allocation and lazy initialization. Only uses relaxed memory ordering, deferring ordering to Chapter 3.

### Chapter 3: Memory Ordering (pp. 49-73)
- Reordering and Optimizations
- The Memory Model
- Happens-Before Relationship (spawning and joining)
- Relaxed Ordering
- Release and Acquire Ordering (locking example, lazy initialization with indirection example)
- Consume Ordering
- Sequentially Consistent Ordering
- Fences
- Common Misconceptions

**Summary:** The most conceptually challenging chapter, covering the abstract memory model. Explains instruction reordering, the happens-before relationship, and each memory ordering level: Relaxed, Release/Acquire, Consume (not yet usefully available), and SeqCst. Covers memory fences as an alternative to per-operation ordering, and addresses common misconceptions about what memory ordering guarantees.

### Chapter 4: Building Our Own Spin Lock (pp. 75-83)
- A Minimal Implementation
- An Unsafe Spin Lock
- A Safe Interface Using a Lock Guard

**Summary:** First hands-on implementation chapter. Builds a spin lock from scratch, progressing from a minimal unsafe version to a safe, ergonomic implementation using a lock guard (RAII pattern). Demonstrates release/acquire ordering in practice and Rust's type system for enforcing safe usage.

### Chapter 5: Building Our Own Channels (pp. 85-104)
- A Simple Mutex-Based Channel
- An Unsafe One-Shot Channel
- Safety Through Runtime Checks
- Safety Through Types
- Borrowing to Avoid Allocation
- Blocking

**Summary:** Implements several variations of a one-shot channel (send one value from one thread to another). Progresses from a simple Mutex-based version through unsafe implementations with runtime checks, then type-system-enforced safety, borrowing optimizations to avoid allocation, and finally a blocking variant using thread parking.

### Chapter 6: Building Our Own "Arc" (pp. 105-125)
- Basic Reference Counting (testing, mutation)
- Weak Pointers (testing)
- Optimizing

**Summary:** Implements atomic reference counting (Arc) from scratch. Builds basic reference counting with proper memory ordering, adds weak pointer support, and optimizes the final version. The result is practically identical to the standard library's std::sync::Arc, demonstrating real-world application of atomics and memory ordering.

### Chapter 7: Understanding the Processor (pp. 127-159)
- Processor Instructions (load and store, read-modify-write, load-linked and store-conditional)
- Caching (cache coherence, impact on performance)
- Reordering
- Memory Ordering (x86-64: strongly ordered, ARM64: weakly ordered, an experiment, memory fences)

**Summary:** Deep dive into how atomics map to actual hardware. Covers processor instructions for atomic operations on x86-64 and ARM64, the MESI cache coherence protocol, performance implications of cache line contention, hardware instruction reordering, and how memory ordering translates to specific instructions on strongly-ordered (x86-64) vs weakly-ordered (ARM64) architectures.

### Chapter 8: Operating System Primitives (pp. 161-179)
- Interfacing with the Kernel
- POSIX (wrapping in Rust)
- Linux (futex, futex operations, priority inheritance futex operations)
- macOS (os_unfair_lock)
- Windows (heavyweight kernel objects, lighter-weight objects, address-based waiting)

**Summary:** OS-level concurrency primitives needed for building real synchronization tools. Covers syscall interfaces, POSIX pthreads (mutex, rwlock, condvar), Linux futex (the fundamental building block), macOS os_unfair_lock, and Windows synchronization objects (SRWLock, WaitOnAddress), with Rust wrapper patterns for each.

### Chapter 9: Building Our Own Locks (pp. 181-211)
- Mutex (avoiding syscalls, optimizing further, benchmarking)
- Condition Variable (avoiding syscalls, avoiding spurious wake-ups)
- Reader-Writer Lock (avoiding busy-looping writers, avoiding writer starvation)

**Summary:** Culminating implementation chapter. Builds production-quality mutex, condition variable, and reader-writer lock from scratch using atomics and OS primitives. Each starts with a minimal correct implementation, then is optimized to avoid unnecessary syscalls. Includes benchmarking to validate optimization trade-offs and discusses design decisions around fairness and starvation.

### Chapter 10: Ideas and Inspiration (pp. 213-219)
- Semaphore
- RCU (Read-Copy-Update)
- Lock-Free Linked List
- Queue-Based Locks
- Parking Lot-Based Locks
- Sequence Lock
- Teaching Materials

**Summary:** Pointers to further exploration after mastering the book's content. Briefly describes advanced concurrency primitives (semaphores, RCU, lock-free linked lists, MCS/CLH queue-based locks, parking lot locks, sequence locks) as inspiration for further study, plus recommended teaching materials.

---

## Key Topics and Concepts

### Rust Concurrency Primitives
- Threads (regular, scoped), Send and Sync traits
- Interior mutability (Cell, RefCell, UnsafeCell)
- Arc, Mutex, RwLock, Condvar, thread parking
- Borrowing rules and data race prevention

### Atomic Operations
- Load/store, fetch-and-modify, compare-and-exchange
- AtomicBool, AtomicI*/AtomicU*, AtomicPtr
- Practical patterns: stop flags, progress reporting, lazy initialization, ID allocation

### Memory Ordering
- Relaxed, Release/Acquire, SeqCst orderings
- Happens-before relationships
- Memory fences (compiler and hardware)
- Common misconceptions

### Hardware and OS
- x86-64 (strongly ordered) vs ARM64 (weakly ordered) memory models
- Cache coherence (MESI protocol) and performance implications
- Linux futex, POSIX pthreads, macOS os_unfair_lock, Windows SRWLock/WaitOnAddress
- Syscall avoidance optimizations

### Building Concurrency Primitives
- Spin lock with lock guard (RAII)
- One-shot channel (multiple designs: unsafe, type-safe, borrowing, blocking)
- Arc with weak pointer support
- Mutex, condition variable, reader-writer lock (with benchmarking)

### Advanced Topics
- RCU, lock-free linked lists, queue-based locks
- Parking lot-based locks, sequence locks

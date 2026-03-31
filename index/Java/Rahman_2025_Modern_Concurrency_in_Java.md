# Modern Concurrency in Java

## Book Metadata
- **Title:** Modern Concurrency in Java: Virtual Threads, Structured Concurrency, and Beyond
- **Author:** A N M Bazlur Rahman
- **Publisher:** O'Reilly Media
- **Year:** 2025
- **Pages:** 313
- **ISBN:** 978-1-098-16541-3

## Target Audience and Prerequisites
- Mid- to senior-level Java developers aiming to modernize their concurrent code
- Architects designing scalable systems
- Performance-oriented engineers building robust concurrent applications
- Requires foundational understanding of concurrency and multithreading (Thread, ExecutorService, synchronization, locks)
- Covers Java 21+ features; JDK 24/25 recommended for preview features
- Not a beginner's guide -- refers readers to "Java Concurrency in Practice" by Goetz for fundamentals

## Overall Focus
A practical guide to Java's modern concurrency model introduced by Project Loom. Takes readers from the evolution of Java threading (platform threads, Executor framework, Fork/Join, CompletableFuture, reactive programming) to mastering virtual threads, structured concurrency (StructuredTaskScope), and scoped values. Bridges the gap between learning these new features and applying them in production with Spring Boot, Quarkus, and Jakarta EE.

---

## Table of Contents

### Chapter 1: Introduction (pp. 1-30)
- A Brief History of Threads in Java (Java is Made of Threads, Threads as backbone of Java Platform)
- The Genesis of Java 1.0 Threads (starting threads)
- Understanding the Hidden Costs of Threads (how many threads can you create?)
- Resource Efficiency in High-Scale Applications (parallel execution strategy, Executor framework, remaining challenges)
- Beyond Basic Thread Pools (cache affinity, work-stealing, CompletableFuture)
- A Different Paradigm for Asynchronous Programming (drawbacks of reactive frameworks)
- Revolutionizing Concurrency in Java (the promise of virtual threads, seamless integration, intelligent blocking)

**Summary:** Historical overview of Java concurrency evolution from Java 1.0 threads through java.util.concurrent (Java 5), Fork/Join (Java 7), CompletableFuture (Java 8), and reactive programming, culminating in the motivation for Project Loom and virtual threads. Explains why each previous approach had limitations that virtual threads address.

### Chapter 2: Understanding Virtual Threads (pp. 31-89)
- What Is a Virtual Thread? (two kinds of threads, key differences from platform threads)
- Setting Up Your Environment for Virtual Threads (creating virtual threads in Java)
- Adapting to Virtual Threads
- Demonstrating Virtual Thread Creation (throughput, scalability, fundamental principle behind scalability, practical implications)
- How Virtual Threads Work Under the Hood (stack frames, memory management, carrier threads, OS involvement, handling blocking, transparency, simplifying async operations, promise of structured concurrency)
- Managing Resource Constraints with Rate Limiting (semaphores)
- Limitations of Virtual Threads (pinning, addressing pinning with ReentrantLock, native method invocation)
- The Conundrum of ThreadLocal Variables in Virtual Threads (challenges)
- Monitoring (ThreadLocals, pinning, viewing in jcmd thread dumps, HotSpotDiagnosticsMXBean)
- Practical Tips for Migrating to Virtual Threads (benefits, scalability)

**Summary:** Comprehensive treatment of virtual threads: what they are, how they differ from platform threads, their internal implementation (stack frames, carrier threads, parking/unparking), and practical usage. Covers critical limitations (pinning on synchronized blocks and native methods), monitoring and debugging techniques, rate limiting with Semaphores, and migration strategies.

### Chapter 3: The Mechanics of Modern Concurrency in Java (pp. 91-123)
- Thread Pool (why we need one, building a simple thread pool)
- The Executor Framework (Callable and Future: handling task results)
- The ForkJoinPool (why ForkJoinPool for virtual threads?)
- Continuation (building our own virtual threads from scratch, virtual threads and I/O polling)

**Summary:** Deep dive into the concurrency infrastructure underpinning virtual threads. Explores thread pool construction, the Executor framework, Callable/Future, and ForkJoinPool as the scheduler for virtual threads. Highlights building a virtual thread implementation from scratch using continuations, providing understanding of the internal mechanics.

### Chapter 4: Structured Concurrency (pp. 125-214)
- The Challenge of Unstructured Concurrency
- The Promise of Structured Concurrency
- Understanding the API (StructuredTaskScope, scopes and subtasks, relationship and lifecycle)
- Joining Policies with Joiner (common joining policies)
- Exception Handling in StructuredTaskScope
- Configuration
- Custom Joiners
- Memory Consistency Effects
- Nested Scopes
- Observability

**Summary:** One of Project Loom's most significant innovations: StructuredTaskScope. Covers the problems of unstructured concurrency, how structured concurrency enforces parent-child task relationships, joining policies (ShutdownOnFailure, ShutdownOnSuccess, custom joiners), exception handling, configuration, nested scopes, memory consistency guarantees, and observability. Note: structured concurrency was still in preview at time of writing.

### Chapter 5: Scoped Values (pp. 217-245)
- The Burden of Passing Context (parameter pollution, interface brittleness, coupling and testability)
- Introducing ThreadLocal (limitations of ThreadLocal variables, toward lightweight sharing)
- Core Components of ScopedValue (running ScopedValue, ScopedValue and structured concurrency, performance considerations, usability and API design, migrating to scoped values)

**Summary:** Scoped values as a superior alternative to ThreadLocal for virtual threads. Explains the context-passing problem, ThreadLocal's limitations (mutability, unbounded lifetime, memory leaks with thread pools), and how ScopedValue provides immutable, bounded, inheritable context with better performance. Covers practical migration from ThreadLocal.

### Chapter 6: The Relevance of Reactive Java in Light of Virtual Threads (pp. 247-294)
- Understanding Reactive Programming in Java (blocking vs non-blocking I/O, event-driven architecture, asynchronous APIs)
- Reactive Programming in Java (understanding reactive streams, backpressure, benefits and downsides)

**Summary:** Compares virtual threads with reactive programming approaches. Examines blocking vs non-blocking I/O, event-driven architecture, asynchronous APIs, reactive streams, and backpressure. Helps readers make informed decisions about when to use virtual threads versus reactive frameworks.

### Chapter 7: Modern Frameworks Utilizing Virtual Threads (pp. 297-309)
- Spring Boot (manual configuration)
- Quarkus
- Jakarta EE

**Summary:** Practical integration of virtual threads into production frameworks. Covers Spring Boot (auto-configuration and manual setup), Quarkus, and Jakarta EE, bridging the gap between learning virtual threads and deploying them in real applications.

### Chapter 8: Conclusion and Takeaways (pp. 311-312)

**Summary:** Key insights and a forward-looking perspective on the future of concurrent programming in Java.

---

## Key Topics and Concepts

### Virtual Threads
- Virtual vs platform threads (lightweight, user-mode, multiplexed on carrier threads)
- Stack frames and memory management
- Throughput and scalability improvements
- Pinning problem (synchronized blocks, native methods, ReentrantLock as alternative)
- Monitoring and diagnostics (jcmd, thread dumps, HotSpotDiagnosticsMXBean)
- Migration strategies from platform threads

### Structured Concurrency
- StructuredTaskScope API
- Joining policies (ShutdownOnFailure, ShutdownOnSuccess, custom Joiners)
- Exception handling and propagation
- Nested scopes and lifecycle management
- Memory consistency effects

### Scoped Values
- ScopedValue vs ThreadLocal
- Immutability and bounded lifetime
- Integration with structured concurrency
- Performance advantages

### Concurrency Evolution
- Java 1.0 threads through java.util.concurrent
- Executor framework, Fork/Join, CompletableFuture
- Reactive programming trade-offs
- Project Loom rationale

### Framework Integration
- Spring Boot virtual thread support
- Quarkus virtual thread integration
- Jakarta EE concurrency updates

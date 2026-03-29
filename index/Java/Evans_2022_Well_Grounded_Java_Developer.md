# The Well-Grounded Java Developer (Second Edition)

## Book Metadata
- **Title:** The Well-Grounded Java Developer, Second Edition
- **Authors:** Benjamin J. Evans, Jason R. Clark, Martijn Verburg
- **Publisher:** Manning Publications
- **Year:** 2022
- **Pages:** 702
- **ISBN:** 9781617298875

## Target Audience and Prerequisites
- Intermediate to advanced Java developers seeking to "level up"
- Developers on professional Java projects
- Teams evaluating alternative JVM languages
- Requires several years of Java experience
- Assumes knowledge of core Java syntax, OOP, basic concurrency

## Overall Focus
Bridges the gap between intermediate and expert-level Java development. Covers modern Java features (8-17), JVM internals (bytecode, GC, JIT), alternative JVM languages (Kotlin, Clojure), build/deployment practices, testing strategies, and future directions of the platform. Originally written as training notes for bank FX developers.

---

## Table of Contents

### Part 1: From 8 to 11 and Beyond! (pp. 1-77)

#### Chapter 1: Introducing Modern Java (pp. 3-25)
- 1.1 The language and the platform
- 1.2 The new Java release model (six-month cycle)
- 1.3 Enhanced type inference (var keyword)
- 1.4 Changing the language and platform (JSRs, JEPs, incubating features)
- 1.5 Small changes in Java 11 (collection factories, HTTP/2, single-file programs)

**Summary:** Evolution of Java from version 8 onwards. Covers the six-month release cadence, type inference with var, and key Java 11 improvements every developer should know.

#### Chapter 2: Java Modules (pp. 26-54)
- 2.1 Setting the scene (Project Jigsaw, module graph, access control)
- 2.2 Basic modules syntax (exporting, requiring, transitivity)
- 2.3 Platform modules (application modules, unnamed module)
- 2.4 Building a first modular app (command-line switches, reflection)
- 2.5 Architecting for modules (split packages, multi-release JARs)

**Summary:** Comprehensive guide to Java 9's module system (Project Jigsaw). Covers syntax, module graph architecture, building modular applications, and practical migration considerations.

#### Chapter 3: Java 17 (pp. 55-77)
- 3.1 Text Blocks
- 3.2 Switch Expressions
- 3.3 Records (nominal typing, compact constructors)
- 3.4 Sealed Types
- 3.5 New form of instanceof
- 3.6 Pattern Matching and preview features

**Summary:** Major language features in Java 17: records for data transfer objects, sealed types for controlled inheritance, switch expressions, and pattern matching. Significant modernization of Java's syntax and type system.

---

### Part 2: Under the Hood (pp. 79-246)

#### Chapter 4: Class Files and Bytecode (pp. 81-117)
- 4.1 Class loading and class objects (loading, linking, custom class loading)
- 4.2 Examining class files (javap, constant pool, method signatures)
- 4.3 Bytecode (opcodes: load/store, arithmetic, flow control, invocation)
- 4.4 Reflection (APIs, combining with class loading, performance costs)

**Summary:** Deep dive into Java's execution model at the bytecode level. Understanding class loading mechanics, examining bytecode with javap, interpreting opcode sequences, and practical reflection usage.

#### Chapter 5: Java Concurrency Fundamentals (pp. 119-166)
- 5.1 Concurrency theory primer (hardware, Amdahl's law, threading model)
- 5.2 Design concepts (safety, liveness, performance, reusability)
- 5.3 Block-structured concurrency (synchronization, volatile, deadlocks, immutability)
- 5.4 The Java Memory Model (JMM)
- 5.5 Understanding concurrency through bytecode (lost updates, race conditions)

**Summary:** Foundational concurrency principles: threading models, synchronization primitives, the Java Memory Model, and examination of concurrency behavior at the bytecode level. Critical for correct multithreaded code.

#### Chapter 6: JDK Concurrency Libraries (pp. 169-205)
- 6.1 Building blocks for concurrent applications
- 6.2 Atomic classes
- 6.3 Lock classes and conditions
- 6.4 CountDownLatch
- 6.5 ConcurrentHashMap
- 6.6 CopyOnWriteArrayList
- 6.7 Blocking queues
- 6.8 Futures and CompletableFuture
- 6.9 Tasks and execution (Executors framework, thread pools)

**Summary:** Practical toolkit from java.util.concurrent. Covers atomic operations, locks, concurrent collections, blocking queues, futures/CompletableFuture, and executor-based task scheduling.

#### Chapter 7: Understanding Java Performance (pp. 207-246)
- 7.1 Performance terminology (latency, throughput, utilization, scalability)
- 7.2 Pragmatic approach to performance analysis
- 7.3 Hardware considerations (Moore's law, memory latency)
- 7.4 Why Java performance tuning is hard (time, cache misses)
- 7.5 Garbage collection (mark-sweep, generations, G1, parallel GC)
- 7.6 JIT compilation with HotSpot (inlining, monomorphic calls, deoptimization)
- 7.7 JDK Flight Recorder and Mission Control

**Summary:** Comprehensive Java performance analysis. Covers terminology, measurement methodology, GC mechanics (G1 default), JIT compilation behavior, and profiling with JDK Flight Recorder.

---

### Part 3: Non-Java Languages on the JVM (pp. 249-341)

#### Chapter 8: Alternative JVM Languages (pp. 251-268)
- 8.1 Language zoology (interpreted/compiled, static/dynamic, imperative/functional)
- 8.2 Polyglot programming on the JVM
- 8.3 How to choose a non-Java language (risk, interop, tooling, learning curve)
- 8.4 How the JVM supports alternative languages

**Summary:** Strategic overview of polyglot JVM programming. Addresses language selection criteria and explains why Kotlin (not Scala) is the focus for modern Java developers.

#### Chapter 9: Kotlin (pp. 270-297)
- 9.1 Why use Kotlin
- 9.2 Convenience and conciseness (variables, type inference, functions, collections)
- 9.3 Classes and objects (data classes, nominal typing)
- 9.4 Safety (null safety, smart casting)
- 9.5 Concurrency (Kotlin coroutines)
- 9.6 Java interoperability

**Summary:** Kotlin as a pragmatic JVM language by JetBrains. Covers safety (null safety, smart casts), conciseness (data classes, type inference), and excellent Java interoperability.

#### Chapter 10: Clojure (pp. 299-341)
- 10.1 Introducing Clojure (REPL, syntax)
- 10.2 Syntax and semantics (special forms, data structures, functions, reader macros)
- 10.3 Functional programming and closures
- 10.4 Clojure sequences
- 10.5 Interoperating between Clojure and Java
- 10.6 Macros (metaprogramming)

**Summary:** Lisp-based functional language on the JVM. Introduces S-expressions, immutable data structures, and Java interoperability. Represents a fundamentally different programming philosophy from Java.

---

### Part 4: Build and Deployment (pp. 343-494)

#### Chapter 11: Building with Gradle and Maven (pp. 345-399)
- 11.2 Maven (lifecycle, POM, dependencies, plugins)
- 11.3 Gradle (tasks, plugins, dependencies, Kotlin support, customization)

**Summary:** Comprehensive comparison of Maven and Gradle. Covers build lifecycles, dependency management, testing integration, multi-language support, and module system configuration.

#### Chapter 12: Running Java in Containers (pp. 401-434)
- 12.1 Why containers matter (VMs vs containers)
- 12.2-12.3 Docker fundamentals and building images (Compose, debugging, logging)
- 12.4 Kubernetes (orchestration)
- 12.5 Observability and performance in containers

**Summary:** Modern deployment with containers. Docker image creation, Docker Compose for local dev, Kubernetes orchestration, and observability/performance considerations for containerized Java.

#### Chapter 13: Testing Fundamentals (pp. 437-465)
- 13.1-13.2 Why and how we test
- 13.3 Test-driven development (TDD)
- 13.4 Test doubles (dummy, stub, fake, mock)
- 13.5 From JUnit 4 to 5 (lambda assertions, assertThrows)

**Summary:** Testing fundamentals: TDD methodology, test doubles (mocks, stubs, fakes), and JUnit 5 migration with modern assertion patterns.

#### Chapter 14: Testing Beyond JUnit (pp. 466-493)
- 14.1 Integration testing with Testcontainers (Redis, PostgreSQL, Selenium)
- 14.2 Specification-style testing with Spek and Kotlin (BDD)
- 14.3 Property-based testing with Clojure (clojure.spec, test.check)

**Summary:** Advanced testing: integration testing with containerized databases via Testcontainers, BDD-style testing, and property-based testing for finding edge cases.

---

### Part 5: Java Frontiers (pp. 495-638)

#### Chapter 15: Advanced Functional Programming (pp. 497-536)
- 15.1 FP concepts (pure functions, immutability, HOFs, recursion, currying, laziness)
- 15.2 Limitations of Java as FP language
- 15.3 Kotlin FP (tail recursion, sequences, lazy evaluation)
- 15.4 Clojure FP (comprehensions, lazy sequences)

**Summary:** Functional programming across Java, Kotlin, and Clojure. Covers FP concepts and how different JVM languages handle them with varying degrees of support.

#### Chapter 16: Advanced Concurrent Programming (pp. 537-570)
- 16.1 Fork/Join framework (work-stealing)
- 16.2 Concurrency and functional programming (CompletableFuture, parallel streams)
- 16.3 Kotlin coroutines (scoping, dispatching)
- 16.4 Concurrent Clojure (persistent data structures, STM, agents)

**Summary:** Advanced concurrency: Fork/Join parallelism, functional approaches, Kotlin coroutines, and Clojure's STM and agent-based models.

#### Chapter 17: Modern Internals (pp. 571-607)
- 17.1 Method invocation (virtual, interface, special, final)
- 17.2 Reflection internals
- 17.3 Method handles (MethodHandle, MethodType)
- 17.4 Invokedynamic (lambda implementation)
- 17.5 Small changes (string concatenation optimization, compact strings, nestmates)
- 17.6 Unsafe API
- 17.7 Replacing Unsafe (VarHandles, hidden classes)

**Summary:** Deep JVM internals: method invocation mechanisms, reflection, method handles, invokedynamic bytecode instruction, and modern replacements for Unsafe operations.

#### Chapter 18: Future Java (pp. 609-638)
- 18.1 Project Amber (language modernization)
- 18.2 Project Panama (Foreign Function and Memory API)
- 18.3 Project Loom (virtual threads)
- 18.4 Project Valhalla (value objects, inline classes)
- 18.5 Java 18 features
- 18.6 Selecting your Java version

**Summary:** Future Java directions: Amber (records, pattern matching), Panama (native interop), Loom (virtual threads for scalability), and Valhalla (value objects).

### Appendix B: Recap of Streams in Java 8 (pp. 640-648)

---

## Key Topics and Concepts

### Modern Language Features
- Type inference (var), Records, Sealed types, Pattern matching
- Text blocks, Switch expressions, Modules (Project Jigsaw)

### JVM Internals
- Class loading and bytecode, Method invocation mechanisms
- Reflection and method handles, Invokedynamic
- Unsafe API and VarHandles

### Concurrency & Performance
- Java Memory Model, Synchronization and locks
- java.util.concurrent (atomics, executors, futures)
- GC mechanisms (G1), JIT compilation, JDK Flight Recorder

### Alternative JVM Languages
- Kotlin (null safety, data classes, coroutines)
- Clojure (functional, immutable data, STM)

### Build, Deploy, Test
- Maven vs Gradle, Docker/Kubernetes
- JUnit 5, Testcontainers, TDD, Property-based testing

### Future Java
- Project Loom (virtual threads), Panama (FFI), Valhalla (value types), Amber (syntax)

# Java Performance (Second Edition)

## Book Metadata
- **Title:** Java Performance: In-Depth Advice for Tuning and Programming Java 8, 11, and Beyond
- **Author:** Scott Oaks
- **Publisher:** O'Reilly Media
- **Year:** 2020 (Second Edition)
- **Pages:** 443
- **ISBN:** 978-1-492-05611-9

## Target Audience and Prerequisites
- Java developers and architects who need to tune application performance
- DevOps engineers responsible for JVM configuration in production
- Performance engineers and benchmarking specialists
- Requires solid Java programming knowledge; no performance tuning background needed

## Overall Focus
The definitive guide to Java performance tuning covering JVM internals from the JIT compiler to garbage collection algorithms. Provides both the theory behind JVM optimizations and practical tuning advice with specific flags and techniques for Java 8, 11, and beyond. Emphasizes measurement-driven optimization with JMH benchmarking and proper performance testing methodology.

---

## Table of Contents

### Chapter 1: Introduction (pp. 1-13)
- A Brief Outline
- Platforms and Conventions (Java platforms, hardware platforms)
- The Complete Performance Story (write better algorithms, write less code, prematurely optimize, the database is always the bottleneck, optimize for the common case)

**Summary:** Sets the performance optimization philosophy. Argues that performance is a holistic concern spanning algorithms, code volume, JVM tuning, and system architecture. Establishes that premature optimization is sometimes appropriate and that the "database bottleneck" is a myth.

### Chapter 2: An Approach to Performance Testing (pp. 15-48)
- Test a Real Application (microbenchmarks, macrobenchmarks, mesobenchmarks)
- Understand Throughput, Batching, and Response Time (elapsed time, throughput measurements, response-time tests)
- Understand Variability
- Test Early, Test Often
- Benchmark Examples (Java Microbenchmark Harness, common code examples)

**Summary:** Rigorous performance testing methodology. Distinguishes micro/macro/mesobenchmarks, covers throughput vs response-time measurement, statistical variability analysis, and introduces JMH as the standard Java benchmarking tool with practical examples.

### Chapter 3: A Java Performance Toolbox (pp. 49-88)
- Operating System Tools and Analysis (CPU usage, CPU run queue, disk usage, network usage)
- Java Monitoring Tools (basic VM information, thread information, class information, live GC analysis, heap dump postprocessing)
- Profiling Tools (sampling profilers, instrumented profilers, blocking methods and thread timelines, native profilers)
- Java Flight Recorder (Java Mission Control, JFR overview, enabling JFR, selecting JFR events)

**Summary:** Comprehensive toolkit for Java performance analysis. Covers OS-level monitoring (CPU, disk, network), JVM monitoring tools (jstat, jmap, jstack), profiling approaches (sampling vs instrumented), and Java Flight Recorder/Mission Control for production diagnostics.

### Chapter 4: Working with the JIT Compiler (pp. 89-120)
- Just-in-Time Compilers: An Overview (HotSpot compilation)
- Tiered Compilation
- Common Compiler Flags (tuning the code cache, inspecting compilation process, tiered compilation levels, deoptimization)
- Advanced Compiler Flags (compilation thresholds, compilation threads, inlining, escape analysis, CPU-specific code)
- Tiered Compilation Trade-offs
- The GraalVM
- Precompilation (ahead-of-time compilation, GraalVM native compilation)

**Summary:** Deep dive into HotSpot's JIT compilation pipeline. Covers C1/C2 tiered compilation, code cache tuning, inlining decisions, escape analysis, deoptimization triggers, and newer approaches including GraalVM and ahead-of-time compilation.

### Chapter 5: An Introduction to Garbage Collection (pp. 121-152)
- Garbage Collection Overview (generational garbage collectors, GC algorithms, choosing a GC algorithm)
- Basic GC Tuning (sizing the heap, sizing the generations, sizing metaspace, controlling parallelism)
- GC Tools (enabling GC logging in JDK 8 and JDK 11)

**Summary:** Foundational GC concepts: generational hypothesis, mark-sweep-compact algorithms, and choosing between collectors. Covers essential tuning parameters — heap sizing, generation ratios, metaspace — and GC logging for diagnostics.

### Chapter 6: Garbage Collection Algorithms (pp. 153-201)
- Understanding the Throughput Collector (adaptive and static heap size tuning)
- Understanding the G1 Garbage Collector (tuning G1 GC)
- Understanding the CMS Collector (tuning concurrent mode failures)
- Advanced Tunings (tenuring and survivor spaces, allocating large objects, AggressiveHeap, full control over heap size)
- Experimental GC Algorithms (ZGC and Shenandoah, Epsilon GC)

**Summary:** Detailed analysis of each GC algorithm: Parallel (throughput), G1 (balanced latency/throughput), CMS (legacy low-latency), and experimental collectors (ZGC, Shenandoah for ultra-low latency; Epsilon for no-GC scenarios). Provides specific tuning parameters for each.

### Chapter 7: Heap Memory Best Practices (pp. 203-248)
- Heap Analysis (heap histograms, heap dumps, out-of-memory errors)
- Using Less Memory (reducing object size, lazy initialization, immutable and canonical objects)
- Object Life-Cycle Management (object reuse, soft/weak/other references, compressed oops)

**Summary:** Practical heap optimization strategies. Covers heap analysis tools (histograms, dumps), reducing memory footprint through object size optimization and lazy initialization, and advanced techniques like soft/weak references and compressed ordinary object pointers.

### Chapter 8: Native Memory Best Practices (pp. 249-265)
- Footprint (measuring, minimizing, native memory tracking, shared library native memory)
- JVM Tunings for the Operating System (large pages)

**Summary:** Managing JVM native (off-heap) memory. Covers measuring and minimizing native memory footprint with Native Memory Tracking (NMT), shared library memory impact, and OS-level tuning with large pages for performance improvement.

### Chapter 9: Threading and Synchronization Performance (pp. 267-306)
- Threading and Hardware
- Thread Pools and ThreadPoolExecutors (setting max/min threads, thread pool task sizes, sizing)
- The ForkJoinPool (work stealing, automatic parallelization)
- Thread Synchronization (costs, avoiding synchronization, false sharing)
- JVM Thread Tunings (thread stack sizes, biased locking, thread priorities)
- Monitoring Threads and Locks (thread visibility, blocked thread visibility)

**Summary:** Threading performance from hardware to JVM. Covers ThreadPoolExecutor sizing strategies, ForkJoinPool with work stealing, synchronization costs and avoidance patterns, false sharing on cache lines, and thread monitoring techniques.

### Chapter 10: Java Servers (pp. 307-327)
- Java NIO Overview
- Server Containers (tuning server thread pools, async REST servers)
- Asynchronous Outbound Calls (asynchronous HTTP)
- JSON Processing (parsing and marshaling overview, JSON objects, JSON parsing)

**Summary:** Server-side Java performance. Covers NIO for non-blocking I/O, servlet container thread pool tuning, async REST server patterns, asynchronous HTTP clients, and JSON processing performance (parsing strategies, object vs streaming APIs).

### Chapter 11: Database Performance Best Practices (pp. 329-361)
- Sample Database
- JDBC (JDBC drivers, connection pools, prepared statements and statement pooling, transactions, result set processing)
- JPA (optimizing JPA writes and reads, JPA caching)
- Spring Data

**Summary:** Database access performance in Java. Covers JDBC tuning (driver types, connection pooling, prepared statements, transaction isolation levels, result set fetching), JPA/Hibernate optimization (write batching, read strategies, second-level caching), and Spring Data considerations.

### Chapter 12: Java SE API Tips (pp. 363-411)
- Strings (compact strings, duplicate strings and string interning, string concatenation)
- Buffered I/O
- Classloading (class data sharing)
- Random Numbers
- Java Native Interface
- Exceptions
- Logging
- Java Collections API (synchronized vs unsynchronized, collection sizing, collections and memory efficiency)
- Lambdas and Anonymous Classes
- Stream and Filter Performance (lazy traversal)
- Object Serialization (transient fields, overriding default, compressing, keeping track of duplicates)

**Summary:** Performance tips for core Java SE APIs. Covers string optimization (compact strings, interning, concatenation), buffered I/O, classloading with CDS, collections sizing and memory efficiency, lambda vs anonymous class overhead, stream laziness, and serialization optimization.

### Appendix A: Summary of Tuning Flags (pp. 413-421)

---

## Key Topics and Concepts

### JIT Compilation
- HotSpot C1/C2 tiered compilation
- Code cache tuning
- Inlining and escape analysis
- Deoptimization
- GraalVM and AOT compilation

### Garbage Collection
- Generational GC theory
- Parallel (Throughput) collector
- G1 garbage collector
- CMS collector (legacy)
- ZGC and Shenandoah (experimental/low-latency)
- Heap sizing and generation tuning

### Memory Management
- Heap analysis (histograms, dumps)
- Object size reduction
- Soft, weak, and phantom references
- Compressed oops
- Native memory tracking
- Large pages

### Threading and Concurrency
- ThreadPoolExecutor sizing
- ForkJoinPool and work stealing
- Synchronization costs
- False sharing
- Thread monitoring

### Performance Testing
- JMH benchmarking
- Micro/macro/mesobenchmarks
- Throughput vs response-time testing
- Statistical variability
- Java Flight Recorder

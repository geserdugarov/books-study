# JVM Performance Engineering

## Book Metadata
- **Title:** JVM Performance Engineering: Inside OpenJDK and the HotSpot Java Virtual Machine
- **Author:** Monica Beckwith
- **Publisher:** Addison-Wesley (Oracle Press)
- **Year:** 2024
- **Pages:** 352
- **ISBN:** 978-0-13-465987-9

## Target Audience and Prerequisites
- Java developers and software engineers enhancing their JVM internals knowledge
- System architects and designers seeking JVM performance insights
- Performance engineers and JVM tuners
- Computer science students in advanced courses on programming languages, systems, and architectures
- Requires solid Java programming background

## Overall Focus
A modern, in-depth guide to JVM performance engineering from a Java Champion with over 20 years of experience. Covers the evolution of Java from JDK 1.1 through Java 17+, HotSpot VM compilation strategies, advanced garbage collection (G1, ZGC), memory management, JMH benchmarking methodology, runtime optimizations (strings, locks, threads), start-up optimization (GraalVM, CRaC), and exotic hardware integration. Emphasizes a systematic, engineering-driven approach to performance diagnostics and optimization.

---

## Table of Contents

### Chapter 1: The Performance Evolution of Java: The Language and the Virtual Machine (pp. 1-42)
- A New Ecosystem Is Born / A Few Pages from History
- Understanding Java HotSpot VM and Its Compilation Strategies (evolution of the HotSpot execution engine, interpreter and JIT compilation, print compilation, tiered compilation, client and server compilers, segmented code cache, adaptive optimization and deoptimization)
- HotSpot Garbage Collector: Memory Management Unit (generational GC, stop-the-world, concurrent algorithms, young collections and weak generational hypothesis, old-generation collection and reclamation triggers, parallel and concurrent GC threads)
- The Evolution of the Java Programming Language and Its Ecosystem (Java 1.1 through Java 17)
- Embracing Evolution for Enhanced Performance

**Summary:** Traces Java's performance evolution from inception to Java 17. Covers HotSpot VM compilation strategies (interpreter, JIT, tiered compilation, client/server compilers), garbage collection foundations (generational hypothesis, concurrent algorithms), and key language milestones across 25+ years of Java releases.

### Chapter 2: Performance Implications of Java's Type System Evolution (pp. 43-68)
- Java's Primitive Types and Literals Prior to J2SE 5.0
- Java's Reference Types Prior to J2SE 5.0 (interface types, class types, array types)
- Java's Type System Evolution from J2SE 5.0 until Java SE 8 (enumerations, annotations, other enhancements)
- Java's Type System Evolution: Java 9 and Java 10 (variable handle typed reference)
- Java's Type System Evolution: Java 11 to Java 17 (switch expressions, sealed classes, records)
- Beyond Java 17: Project Valhalla (performance implications, value classes, redefining generics with primitive support)

**Summary:** Analyzes Java's type system from a performance perspective. Covers the evolution of primitive and reference types, generics, enumerations, annotations, records, sealed classes, and looks ahead to Project Valhalla's value classes and specialized generics for eliminating boxing overhead.

### Chapter 3: From Monolithic to Modular Java: A Retrospective and Ongoing Evolution (pp. 69-97)
- Understanding the Java Platform Module System (demystifying modules, compilation and run details)
- From Monolithic to Modular: The Evolution of the JDK
- Implementing Modular Services with JDK 17 (service provider, service consumer)
- JAR Hell Versioning Problem and Jigsaw Layers
- Open Services Gateway Initiative (OSGi comparison)
- Introduction to Jdeps, Jlink, Jdeprscan, and Jmod
- Performance Implications and Future Developments

**Summary:** Java's transition to modular architecture via JPMS. Covers module system fundamentals, practical service implementation with JDK 17, JAR hell solutions with Jigsaw layers, OSGi comparison, and modular tooling (jdeps, jlink, jmod) with their performance implications.

### Chapter 4: The Unified Java Virtual Machine Logging Interface (pp. 99-113)
- The Need for Unified Logging
- Unification and Infrastructure (performance metrics)
- Tags in the Unified Logging System (log tags, specific tags, identifying missing information)
- Diving into Levels, Outputs, and Decorators
- Practical Examples of Using the Unified Logging System (benchmarking and performance testing)
- Asynchronous Logging and the Unified Logging System
- Understanding the Enhancements in JDK 11 and JDK 17

**Summary:** JVM's unified logging infrastructure for performance diagnostics. Covers the log tag system, levels, outputs, decorators, practical usage for benchmarking, asynchronous logging for minimal performance impact, and JDK 11/17 enhancements.

### Chapter 5: End-to-End Java Performance Optimization: Engineering Techniques and Micro-benchmarking with JMH (pp. 115-175)
- Performance Engineering: A Central Pillar of Software Engineering
- Metrics for Measuring Java Performance (footprint, responsiveness, throughput, availability)
- The Role of Hardware in Performance (hardware-software dynamics, memory models, concurrent hardware)
- Performance Engineering Methodology (experimental design, bottom-up and top-down methodology, statement of work)
- The Importance of Performance Benchmarking (key metrics, JMH benchmarking, JVM benchmarking with JMH, profiling JMH benchmarks with perfasm)

**Summary:** Comprehensive performance engineering methodology. Covers performance metrics (footprint, responsiveness, throughput, availability), hardware-software interaction (memory models, NUMA), systematic engineering methodologies (top-down, bottom-up), and practical JMH micro-benchmarking with profiler integration.

### Chapter 6: Advanced Memory Management and Garbage Collection in OpenJDK (pp. 177-217)
- Overview of Garbage Collection in Java
- Thread-Local Allocation Buffers and Promotion-Local Allocation Buffers
- Optimizing Memory Access with NUMA-Aware Garbage Collection
- Exploring Garbage Collection Improvements (G1 GC deep dive, regionalized heap, optimizing G1 parameters, Z Garbage Collector)
- Future Trends in Garbage Collection
- Practical Tips for Evaluating GC Performance (transactional workloads: OLAP, OLTP, HTAP)
- Live Data Set Pressure (data lifespan patterns, impact on different GC algorithms)

**Summary:** Advanced GC internals in OpenJDK. Covers TLABs/PLABs for allocation optimization, NUMA-aware GC, deep dives into G1 (regionalized heap, parameter tuning) and ZGC (adaptive optimization, multi-terabyte heaps), GC evaluation across OLAP/OLTP/HTAP workloads, and data lifespan analysis.

### Chapter 7: Runtime Performance Optimizations: A Focus on Strings, Locks, and Beyond (pp. 219-270)
- String Optimizations (literal and interned string optimization in HotSpot, string deduplication with G1 GC, reducing string footprint)
- Enhanced Multithreading Performance: Java Thread Synchronization (monitor locks, lock types in HotSpot, advancements in locking mechanisms, optimizing contention)
- Transitioning from the Thread-per-Task Model to More Scalable Models (one-to-one thread mapping, thread-per-request model, virtual threads)

**Summary:** Runtime optimization covering strings and concurrency. Details string interning, deduplication, and compact strings optimization; lock evolution in HotSpot (biased, thin, fat locks); contention optimization; and the transition from traditional threading to virtual threads for scalable concurrency.

### Chapter 8: Accelerating Time to Steady State with OpenJDK HotSpot VM (pp. 273-306)
- JVM Start-up and Warm-up Optimization Techniques
- Decoding Time to Steady State in Java Applications (phases of JVM start-up, reaching steady state, application life cycle)
- Managing State at Start-up and Ramp-up (class data sharing, ahead-of-time compilation)
- GraalVM: Revolutionizing Java's Time to Steady State
- Emerging Technologies: CRIU and Project CRaC for Checkpoint/Restore
- Start-up and Ramp-up Optimization in Serverless and Other Environments
- Boosting Warm-up Performance with OpenJDK HotSpot VM (compiler enhancements, segmented code cache, Project Leyden, PermGen to Metaspace evolution)

**Summary:** Optimizing JVM start-up and warm-up for modern deployment. Covers JVM lifecycle phases, Class Data Sharing (CDS), AOT compilation, GraalVM native image, checkpoint/restore with CRIU/CRaC, serverless/container optimization strategies, and Project Leyden's future improvements.

### Chapter 9: Harnessing Exotic Hardware: The Future of JVM Performance Engineering (pp. 307-336)
- Introduction to Exotic Hardware and the JVM
- Exotic Hardware in the Cloud (hardware heterogeneity, API compatibility, performance trade-offs)
- The Role of Language Design and Toolchains
- Case Studies (LWJGL, Aparapi and OpenCL, Project Sumatra, TornadoVM, Project Panama)
- Envisioning the Future of JVM and Project Panama (high-level APIs, Vector API, accelerator descriptors)

**Summary:** JVM integration with specialized hardware (GPUs, FPGAs, accelerators). Covers cloud hardware challenges, case studies of Java-GPU bridges (Aparapi, TornadoVM, Project Panama), the Vector API for SIMD, and the future of hardware-accelerated Java computing.

---

## Key Topics and Concepts

### JVM Compilation and Execution
- HotSpot execution engine evolution
- Tiered compilation (C1/C2)
- Adaptive optimization and deoptimization
- GraalVM and AOT compilation
- Project Leyden

### Garbage Collection
- G1 Garbage Collector internals (regionalized heap)
- Z Garbage Collector (multi-terabyte, low-latency)
- TLABs and PLABs
- NUMA-aware garbage collection
- GC evaluation for OLAP/OLTP/HTAP workloads

### Memory and Runtime
- String optimization (interning, deduplication, compact strings)
- Lock optimization in HotSpot (biased, thin, fat locks)
- Virtual threads
- Start-up optimization (CDS, CRIU, CRaC)
- Metaspace evolution

### Performance Methodology
- JMH micro-benchmarking
- Top-down and bottom-up methodologies
- Performance metrics (footprint, responsiveness, throughput, availability)
- Hardware-software dynamics and memory models

### Java Evolution and Future
- Type system evolution through Java 17
- Project Valhalla (value classes, specialized generics)
- Java Platform Module System (JPMS)
- Project Panama (foreign function and memory API)
- Exotic hardware integration (GPUs, Vector API)

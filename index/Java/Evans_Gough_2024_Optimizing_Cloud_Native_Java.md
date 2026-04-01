# Optimizing Cloud Native Java (Second Edition)

## Book Metadata
- **Title:** Optimizing Cloud Native Java: Practical Techniques for Improving JVM Application Performance (Second Edition)
- **Authors:** Benjamin J. Evans, James Gough
- **Publisher:** O'Reilly Media
- **Year:** 2024
- **Pages:** 455
- **ISBN:** 978-1-098-14934-5

## Target Audience and Prerequisites
- Intermediate to advanced Java developers working with cloud platforms
- Performance engineers and site reliability engineers
- Requires solid understanding of Java fundamentals, JVM basics, and cloud deployment concepts
- Not for complete beginners

## Overall Focus
A practical guide to tuning Java applications for high performance in cloud environments. Covers the full stack from JVM internals (garbage collection, JIT compilation) through hardware and OS interactions to cloud-native deployment, observability, and distributed systems patterns. Emphasizes a quantitative, experimental approach to performance rather than guesswork.

---

## Table of Contents

### Chapter 1: Optimization and Performance Defined (p. 1)
- Java Performance the Wrong Way (2)
- Java Performance Overview (4)
- Performance as an Experimental Science (5)
- A Taxonomy for Performance (7)
  - Throughput (7), Latency (8), Capacity (8), Utilization (8), Efficiency (9), Scalability (9), Degradation (9)
  - Correlations Between the Observables (10)
- Reading Performance Graphs (11)
- Performance in Cloud Systems (14)

**Summary:** Establishes the foundational vocabulary for performance work — throughput, latency, capacity, utilization, efficiency, scalability, and degradation — and how they interrelate. Argues for treating performance tuning as an experimental science with measurable, repeatable results rather than relying on folklore.

### Chapter 2: Performance Testing Methodology (p. 17)
- Types of Performance Tests (17)
  - Latency Test (18), Throughput Test (19), Stress Test (19), Load Test (20), Endurance Test (20), Capacity Planning Test (20), Degradation Test (21)
- Best Practices Primer (22)
  - Top-Down Performance (22), Creating a Test Environment (23), Identifying Performance Requirements (24), Performance Testing as Part of the SDLC (25), Java-Specific Issues (25)
- Causes of Performance Antipatterns (26)
  - Boredom (27), Resume Padding (27), Social Pressure (27), Lack of Understanding (28), Misunderstood/Nonexistent Problem (28)
- Statistics for JVM Performance (29)
  - Types of Error (29), Non-Normal Statistics (33)
- Interpretation of Statistics (37)
  - Spurious Correlation (38), The Hat/Elephant Problem (41)
- Cognitive Biases and Performance Testing (44)
  - Reductionist Thinking (45), Confirmation Bias (45), Fog of War (Action Bias) (46), Risk Bias (46)

**Summary:** Covers the methodology of performance testing: types of tests, best practices for creating reproducible environments, statistical analysis of JVM metrics (including non-normal distributions), and cognitive biases that lead engineers astray during performance work.

### Chapter 3: Overview of the JVM (p. 49)
- Interpreting and Classloading (49)
- Executing Bytecode (52)
- Introducing HotSpot (56)
- Introducing Just-in-Time Compilation (58)
- JVM Memory Management (60)
- Threading and the Java Memory Model (61)
- Monitoring and Tooling for the JVM (62)
- Java Implementations, Distributions, and Releases (68)
  - Choosing a Distribution (69), The Java Release Cycle (73)

**Summary:** A concise tour of JVM internals: classloading, bytecode execution, the HotSpot VM, JIT compilation, memory management, threading, and the Java Memory Model. Also covers the landscape of JVM distributions and the modern Java release cadence.

### Chapter 4: Understanding Garbage Collection (p. 75)
- Introducing Mark and Sweep (77)
- Garbage Collection Glossary (79)
- Introducing the HotSpot Runtime (80)
  - Representing Objects at Runtime (81), GC Roots (84)
- Allocation and Lifetime (85)
- Weak Generational Hypothesis (86)
- Production GC Techniques in HotSpot (87)
  - Thread-Local Allocation (87), Hemispheric Collection (88), The "Classic" HotSpot Heap (90)
- The Parallel Collectors (92)
  - Young Parallel Collections (93), Old Parallel Collections (94), Serial and SerialOld (95), Limitations of Parallel Collectors (96)
- The Role of Allocation (97)

**Summary:** Foundational garbage collection concepts — mark and sweep, generational hypothesis, object layout in HotSpot, thread-local allocation, and the parallel/serial collectors. Explains how allocation patterns and object lifetimes drive GC behavior.

### Chapter 5: Advanced Garbage Collection (p. 105)
- Tradeoffs and Pluggable Collectors (105)
- Concurrent GC Theory (107)
  - JVM Safepoints (108), Tri-Color Marking (110), Forwarding Pointers (113)
- G1 (114)
  - G1 Heap Layout and Regions (115), G1 Collections (117), G1 Mixed Collections (118), Remembered Sets (119), Full Collections (120), JVM Config Flags for G1 (121)
- Shenandoah (122)
  - Concurrent Evacuation (123), JVM Config Flags for Shenandoah (123), Shenandoah's Evolution (124)
- ZGC (125)
- Balanced (Eclipse OpenJ9) (128)
  - OpenJ9 Object Headers (129), Large Arrays in Balanced (130), NUMA and Balanced (131)
- Niche HotSpot Collectors (132)
  - CMS (132), Epsilon (134)

**Summary:** Deep dive into advanced garbage collectors: G1, Shenandoah, ZGC, and Balanced (OpenJ9). Covers concurrent GC theory including safepoints, tri-color marking, and forwarding pointers. Compares collector tradeoffs and configuration flags.

### Chapter 6: Code Execution on the JVM (p. 137)
- Lifecycle of a Traditional Java Application (138)
- Overview of Bytecode Interpretation (140)
  - Introduction to JVM Bytecode (142), Simple Interpreters (149), HotSpot-Specific Details (150)
- JIT Compilation in HotSpot (152)
  - Profile-Guided Optimization (152), Klass Words, Vtables, and Pointer Swizzling (154), Compilers Within HotSpot (156), The Code Cache (157), Logging JIT Compilation (159), Simple JIT Tuning (161)
- Evolving Java Program Execution (162)
  - Ahead-of-Time (AOT) Compilation (163), Quarkus (164), GraalVM (167)

**Summary:** How Java code executes on the JVM — from bytecode interpretation through JIT compilation with profile-guided optimization. Covers HotSpot internals (code cache, compiler tiers, vtables) and modern alternatives like AOT compilation, Quarkus, and GraalVM.

### Chapter 7: Hardware and Operating Systems (p. 169)
- Introduction to Modern Hardware (170)
- Memory (171)
- Memory Caches (172)
- Modern Processor Features (177)
  - Translation Lookaside Buffer (177), Branch Prediction and Speculative Execution (177), Hardware Memory Models (178)
- Operating Systems (179)
  - The Scheduler (180), The JVM and the Operating System (182), Context Switches (183)
- A Simple System Model (184)
  - Utilizing the CPU (186), Garbage Collection (188), I/O (189), Mechanical Sympathy (190)

**Summary:** The hardware and OS foundations that affect Java performance: CPU caches, TLB, branch prediction, memory models, OS scheduling, and context switching. Introduces the concept of mechanical sympathy — writing software that works with the hardware rather than against it.

### Chapter 8: Components of the Cloud Stack (p. 193)
- Java Standards for the Cloud Stack (194)
- Cloud Native Computing Foundation (195)
  - Kubernetes (197), Prometheus (197), OpenTelemetry (197)
- Virtualization (198)
  - Choosing the Right Virtual Machines (200), Virtualization Considerations (201)
- Images and Containers (202)
  - Image Structure (202), Building Images (203), Running Containers (205)
- Networking (205)
- Introducing the Fighting Animals Example (206)

**Summary:** Overview of the cloud-native ecosystem relevant to Java developers: CNCF projects (Kubernetes, Prometheus, OpenTelemetry), virtualization considerations, container image building and operation, and networking. Introduces the "Fighting Animals" example application used throughout the book.

### Chapter 9: Deploying Java in the Cloud (p. 211)
- Working Locally with Containers (212)
  - Docker Compose (212), Tilt (214)
- Container Orchestration (215)
  - Deployments (216), Sharing Within Pods (217), Container and Pod Lifecycles (218), Services (219), Connecting to Services on the Cluster (220), Challenges with Containers and Scheduling (221), Working with Remote Containers Using "Remocal" Development (223)
- Deployment Techniques (223)
  - Blue/Green Deployments (224), Canary Deployments (226), Evolutionary Architecture and Feature Flagging (229)
- Java-Specific Concerns (232)
  - Containers and GC (232), Memory and OOMEs (233)

**Summary:** Practical guide to deploying Java applications in cloud environments — local development with Docker Compose and Tilt, Kubernetes orchestration (pods, services, deployments), deployment strategies (blue/green, canary), and Java-specific container concerns like GC tuning and memory limits.

### Chapter 10: Introduction to Observability (p. 235)
- The What and the Why of Observability (235)
  - What Is Observability? (236), Why Observability? (237)
- The Three Pillars (238)
  - Metrics (238), Logs (241), Traces (243), The Pillars as Data Sources (247), Profiling — A Fourth Pillar? (248)
- Observability Architecture Patterns and Antipatterns (249)
  - Architectural Patterns for Metrics (249), Manual Versus Automatic Instrumentation (250), Antipattern: Shoehorn Data into Metrics (252), Antipattern: Abusing Correlated Logs (253)
- Diagnosing Application Problems Using Observability (254)
  - Performance Regressions (254), Unstable Components (256), Repartitioning and "Split-Brain" (256), Thundering Herd (258), Cascading Failure (259), Compound Failures (260)
- Vendor or OSS Solution? (261)

**Summary:** Introduces observability concepts: the three pillars (metrics, logs, traces) and profiling as a potential fourth. Covers architectural patterns and antipatterns for instrumentation, and how to use observability to diagnose common distributed system problems like cascading failures, thundering herds, and split-brain scenarios.

### Chapter 11: Implementing Observability in Java (p. 265)
- Introducing Micrometer (266)
  - Meters and Registries (266), Counters (268), Gauges (269), Meter Filters (271), Timers (273), Distribution Summaries (274), Runtime Metrics (277)
- Introducing Prometheus for Java Developers (278)
  - Prometheus Architecture Overview (278), Using Prometheus with Micrometer (280)
- Introducing OpenTelemetry (285)
  - What Is OpenTelemetry? (286), Why Choose OTel? (288), OTLP (289), The Collector (290)
- OpenTelemetry Tracing in Java (292)
  - Manual Tracing (292), Automatic Tracing (296), Sampling Traces (297)
- OpenTelemetry Metrics in Java (298)
- OpenTelemetry Logs in Java (300)

**Summary:** Hands-on implementation of observability in Java using Micrometer (counters, gauges, timers, distribution summaries), Prometheus integration, and OpenTelemetry (tracing, metrics, logs, OTLP, the Collector). Covers both manual and automatic instrumentation approaches.

### Chapter 12: Profiling (p. 305)
- Introduction to Profiling (306)
- GUI Profiling Tools (308)
  - VisualVM (308), JDK Mission Control (310)
- Sampling and Safepointing Bias (314)
- Modern Profilers (316)
  - perf (316), Async Profiler (319)
- JDK Flight Recorder (JFR) (321)
- Operational Aspects of Profiling (325)
  - Using JFR As an Operational Tool (325), Red Hat Cryostat (326), JFR and OTel Profiling (327), Choosing a Profiler (328)
- Memory Profiling (329)
  - Allocation Profiling (329), Heap Dumps (332)

**Summary:** Comprehensive guide to Java profiling tools and techniques: GUI tools (VisualVM, JDK Mission Control), modern profilers (perf, Async Profiler), JDK Flight Recorder, and memory profiling (allocation analysis, heap dumps). Addresses sampling bias and operational profiling in production.

### Chapter 13: Concurrent Performance Techniques (p. 335)
- Introduction to Parallelism (337)
  - Amdahl's Law (338), Fundamental Java Concurrency (339)
- Understanding the JMM (342)
- Building Concurrency Libraries (347)
  - Method and Var Handles (348), Atomics and CAS (353), Locks and Spinlocks (354)
- Summary of Concurrent Libraries (355)
  - Locks in java.util.concurrent (356), Read/Write Locks (358), Semaphores (359), Concurrent Collections (359), Latches and Barriers (360)
- Executors and Task Abstraction (362)
  - Introducing Asynchronous Execution (362), Selecting an ExecutorService (363), Fork/Join and Parallel Streams (364), Actor-Based Techniques (367)
- Virtual Threads (368)
  - Introduction to Virtual Threads (369), Virtual Thread Concurrency Patterns (373)

**Summary:** Java concurrency from a performance perspective: Amdahl's Law, the Java Memory Model, low-level primitives (atomics, CAS, locks), java.util.concurrent utilities, executor frameworks, Fork/Join, and the new virtual threads. Covers both theory and practical performance implications.

### Chapter 14: Distributed Systems Techniques and Patterns (p. 377)
- Basic Distributed Data Structures (378)
  - Clocks, IDs, and Write-Ahead Logs (378), Two-Phase Commit (379), Object Serialization (381), Data Partitioning and Replication (382), CAP Theorem (383)
- Consensus Protocols (384)
  - Paxos (384), Raft (386)
- Distributed Systems Examples (388)
  - Distributed Database — Cassandra (389), In-Memory Data Grid — Infinispan (391), Event Streaming — Kafka (391)
- Enhancing Fighting Animals (393)
  - Introducing Kafka to Fighting Animals (394), A Simple Hospital Service (397), An Active Hospital (400)

**Summary:** Distributed systems fundamentals relevant to Java cloud applications: distributed data structures, consensus protocols (Paxos, Raft), CAP theorem, and practical examples with Cassandra, Infinispan, and Kafka. Extends the book's example application with event streaming.

### Chapter 15: Modern Performance and The Future (p. 405)
- New Concurrency Patterns (405)
  - Structured Concurrency (405), Scoped Values (409)
- Panama (412)
- Leyden (414)
  - Images, Constraints, and Condensers (415), Leyden Premain (418)
- Valhalla (420)
- Conclusions (425)

**Summary:** Forward-looking chapter covering upcoming Java features that will impact performance: structured concurrency and scoped values (Project Loom), foreign function access (Project Panama), startup optimization (Project Leyden), and value types (Project Valhalla).

### Appendix A: Microbenchmarking (p. 427)

### Appendix B: Performance Antipatterns Catalog (p. 443)

### Back Matter
- Index (455)

---

## Key Topics and Concepts

### Performance Fundamentals
- Performance taxonomy (throughput, latency, capacity, utilization, efficiency)
- Performance testing methodology and types
- Statistics for JVM performance (non-normal distributions)
- Cognitive biases in performance work

### JVM Internals
- Bytecode execution and interpretation
- JIT compilation and profile-guided optimization
- HotSpot architecture (code cache, compiler tiers)
- AOT compilation, Quarkus, GraalVM

### Garbage Collection
- Mark and sweep, generational hypothesis
- Parallel, G1, Shenandoah, ZGC collectors
- Concurrent GC theory (safepoints, tri-color marking)
- GC tuning and configuration flags

### Hardware and OS
- CPU caches, TLB, branch prediction
- Hardware memory models
- OS scheduling and context switches
- Mechanical sympathy

### Cloud Native Deployment
- Kubernetes orchestration (pods, services, deployments)
- Container images and Docker
- Blue/green and canary deployments
- Java-specific container concerns (GC, memory limits)

### Observability
- Three pillars: metrics, logs, traces
- Micrometer, Prometheus, OpenTelemetry
- Manual vs automatic instrumentation
- Diagnosing distributed system problems

### Profiling
- VisualVM, JDK Mission Control, Async Profiler
- JDK Flight Recorder (JFR)
- Sampling bias and safepointing
- Memory and allocation profiling

### Concurrency
- Java Memory Model
- Atomics, CAS, locks, concurrent collections
- Executors, Fork/Join, parallel streams
- Virtual threads and structured concurrency

### Distributed Systems
- CAP theorem, consensus protocols (Paxos, Raft)
- Cassandra, Infinispan, Kafka
- Two-phase commit, data partitioning

### Future Java Performance
- Project Loom (structured concurrency, scoped values)
- Project Panama (foreign function access)
- Project Leyden (startup optimization)
- Project Valhalla (value types)

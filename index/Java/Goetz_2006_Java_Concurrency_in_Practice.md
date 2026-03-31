# Java Concurrency in Practice

## Book Metadata
- **Title:** Java Concurrency in Practice
- **Author:** Brian Goetz with Tim Peierls, Joshua Bloch, Joseph Bowbeer, David Holmes, and Doug Lea
- **Publisher:** Addison-Wesley
- **Year:** 2006
- **Pages:** 384
- **ISBN:** 0-321-34960-1

## Target Audience and Prerequisites
- Java developers building concurrent and multithreaded applications
- Developers wanting to understand the design rules behind safe concurrent code
- Not an introduction to concurrency -- assumes familiarity with basic threading concepts
- Assumes Java 5.0 or later (code examples use java.util.concurrent)
- Authors are primary members of the JCP Expert Group that created Java's concurrency facilities

## Overall Focus
A comprehensive guide to writing correct, performant concurrent programs in Java. Presents a simplified set of design rules and mental models for building thread-safe classes and applications, bridging the gap between low-level mechanisms (synchronization, condition waits) and high-level design policies. Written by the architects of Java's concurrency libraries (java.util.concurrent).

---

## Table of Contents

### Chapter 1: Introduction (pp. 1-12)
- 1.1 A (very) brief history of concurrency
- 1.2 Benefits of threads
- 1.3 Risks of threads
- 1.4 Threads are everywhere

**Summary:** Motivates why concurrency matters and why it is inherently difficult. Covers the historical shift from single-threaded to multithreaded programming, the benefits (exploiting multiprocessors, simplified modeling, simplified handling of asynchronous events), and the risks (safety hazards, liveness hazards, performance hazards).

### Part I: Fundamentals (pp. 13-110)

### Chapter 2: Thread Safety (pp. 15-32)
- 2.1 What is thread safety?
- 2.2 Atomicity
- 2.3 Locking
- 2.4 Guarding state with locks
- 2.5 Liveness and performance

**Summary:** Defines thread safety as correctness under concurrent access. Introduces atomicity, race conditions (check-then-act, read-modify-write), intrinsic locking (synchronized), reentrancy, and the trade-off between over-synchronizing (liveness) and under-synchronizing (safety).

### Chapter 3: Sharing Objects (pp. 33-54)
- 3.1 Visibility
- 3.2 Publication and escape
- 3.3 Thread confinement
- 3.4 Immutability
- 3.5 Safe publication

**Summary:** Techniques for sharing objects safely between threads. Covers visibility guarantees of synchronized and volatile, the dangers of publishing mutable state, thread confinement (stack confinement, ThreadLocal), immutability as a safety strategy, and safe publication idioms.

### Chapter 4: Composing Objects (pp. 55-78)
- 4.1 Designing a thread-safe class
- 4.2 Instance confinement
- 4.3 Delegating thread safety
- 4.4 Adding functionality to existing thread-safe classes
- 4.5 Documenting synchronization policies

**Summary:** Patterns for composing thread-safe classes from smaller components. Covers the Java monitor pattern, instance confinement, delegation to thread-safe building blocks, client-side locking, composition wrappers, and the importance of documenting synchronization policies.

### Chapter 5: Building Blocks (pp. 79-110)
- 5.1 Synchronized collections
- 5.2 Concurrent collections
- 5.3 Blocking queues and the producer-consumer pattern
- 5.4 Blocking and interruptible methods
- 5.5 Synchronizers (latches, FutureTask, semaphores, barriers)
- 5.6 Building an efficient, scalable result cache

**Summary:** The concurrent building blocks provided by the Java platform libraries. Covers ConcurrentHashMap, CopyOnWriteArrayList, BlockingQueue, CountDownLatch, Semaphore, CyclicBarrier, and FutureTask. Concludes with a practical cache-building exercise (Memoizer) that progressively improves from naive to production-quality.

### Part II: Structuring Concurrent Applications (pp. 111-202)

### Chapter 6: Task Execution (pp. 113-134)
- 6.1 Executing tasks in threads
- 6.2 The Executor framework
- 6.3 Finding exploitable parallelism

**Summary:** Structuring applications around task execution. Covers the problems with unbounded thread creation, the Executor framework as a decoupled producer-consumer pattern, ExecutorService lifecycle, Callable/Future, CompletionService, and time-limited tasks.

### Chapter 7: Cancellation and Shutdown (pp. 135-166)
- 7.1 Task cancellation
- 7.2 Stopping a thread-based service
- 7.3 Handling abnormal thread termination
- 7.4 JVM shutdown

**Summary:** Mechanisms for cooperative task cancellation and clean shutdown. Covers interruption as the standard cancellation mechanism, interrupt policies, responding to interruption, cancelling tasks via Future, handling non-interruptible blocking, poison pills, ExecutorService shutdown, UncaughtExceptionHandler, and shutdown hooks.

### Chapter 8: Applying Thread Pools (pp. 167-188)
- 8.1 Implicit couplings between tasks and execution policies
- 8.2 Sizing thread pools
- 8.3 Configuring ThreadPoolExecutor
- 8.4 Extending ThreadPoolExecutor
- 8.5 Parallelizing recursive algorithms

**Summary:** Advanced thread pool configuration and usage. Covers task dependencies that constrain execution policies, thread pool sizing formulas, configuring work queues and saturation policies, custom ThreadFactory, extending ThreadPoolExecutor with hooks (beforeExecute, afterExecute), and parallelizing recursive computations.

### Chapter 9: GUI Applications (pp. 189-202)
- 9.1 Why are GUIs single-threaded?
- 9.2 Short-running GUI tasks
- 9.3 Long-running GUI tasks
- 9.4 Shared data models
- 9.5 Other forms of single-threaded subsystems

**Summary:** Applying concurrency patterns to GUI frameworks. Explains why GUIs are single-threaded, how to offload long-running tasks to background threads, SwingWorker/BackgroundTask patterns for progress and completion notification, and thread-safe data models.

### Part III: Liveness, Performance, and Testing (pp. 203-272)

### Chapter 10: Avoiding Liveness Hazards (pp. 205-220)
- 10.1 Deadlock (lock-ordering, dynamic lock order, between cooperating objects, open calls)
- 10.2 Avoiding and diagnosing deadlocks
- 10.3 Other liveness hazards (starvation, livelock)

**Summary:** Identifying and preventing liveness failures. Covers lock-ordering deadlocks, dynamic lock-ordering deadlocks, the open call principle, deadlock analysis with thread dumps, timed lock attempts, and starvation/livelock hazards.

### Chapter 11: Performance and Scalability (pp. 221-246)
- 11.1 Thinking about performance
- 11.2 Amdahl's law
- 11.3 Costs introduced by threads (context switching, memory synchronization, blocking)
- 11.4 Reducing lock contention (narrowing lock scope, lock splitting, lock striping, avoiding hot fields)
- 11.5 Example: Comparing Map performance
- 11.6 Reducing context switch overhead

**Summary:** Analyzing and improving concurrent performance. Covers Amdahl's law for quantifying scalability limits, thread overhead costs, and techniques for reducing lock contention: narrowing lock scope, splitting locks, striping locks (as in ConcurrentHashMap), and avoiding hot fields.

### Chapter 12: Testing Concurrent Programs (pp. 247-272)
- 12.1 Testing for correctness
- 12.2 Testing for performance
- 12.3 Avoiding performance testing pitfalls
- 12.4 Complementary testing approaches

**Summary:** Testing strategies for concurrent code. Covers building correct concurrent tests (BoundedBuffer example), safety and liveness tests, testing with barriers for interleaving, performance benchmarks, avoiding pitfalls (dead code elimination, dynamic compilation, GC), and complementary approaches (code review, static analysis, aspect-oriented testing).

### Part IV: Advanced Topics (pp. 275-352)

### Chapter 13: Explicit Locks (pp. 277-290)
- 13.1 Lock and ReentrantLock
- 13.2 Performance considerations
- 13.3 Fairness
- 13.4 Choosing between synchronized and ReentrantLock
- 13.5 Read-write locks

**Summary:** The java.util.concurrent.locks framework as an alternative to intrinsic locking. Covers ReentrantLock features (timed/polled/interruptible acquisition, non-block-structured locking), fairness trade-offs, when to prefer ReentrantLock over synchronized, and ReadWriteLock for read-dominated workloads.

### Chapter 14: Building Custom Synchronizers (pp. 291-318)
- 14.1 Managing state dependence
- 14.2 Using condition queues
- 14.3 Explicit condition objects
- 14.4 Anatomy of a synchronizer
- 14.5 AbstractQueuedSynchronizer
- 14.6 AQS in java.util.concurrent synchronizer classes

**Summary:** Low-level synchronizer construction. Covers condition queues (wait/notify/notifyAll), explicit Condition objects, the canonical state-dependent method pattern, and AbstractQueuedSynchronizer (AQS) as the foundation for ReentrantLock, Semaphore, CountDownLatch, and FutureTask.

### Chapter 15: Atomic Variables and Nonblocking Synchronization (pp. 319-336)
- 15.1 Disadvantages of locking
- 15.2 Hardware support for concurrency (CAS)
- 15.3 Atomic variable classes
- 15.4 Nonblocking algorithms (nonblocking stack, nonblocking linked list, ABA problem)

**Summary:** Lock-free programming with atomic variables. Covers compare-and-swap (CAS) as the hardware foundation, AtomicInteger/AtomicReference and their operations, nonblocking algorithms (Treiber stack, Michael-Scott queue), and the ABA problem.

### Chapter 16: The Java Memory Model (pp. 337-352)
- 16.1 What is a memory model, and why would I want one?
- 16.2 Publication (unsafe publication, safe publication, safe initialization, double-checked locking)
- 16.3 Initialization safety

**Summary:** The formal Java Memory Model (JMM) and its practical implications. Covers the happens-before relationship, piggyback synchronization, unsafe lazy initialization, the double-checked locking antipattern, initialization-on-demand holder idiom, and initialization safety guarantees for final fields.

### Appendix A: Annotations for Concurrency (pp. 353-354)
- A.1 Class annotations (@ThreadSafe, @NotThreadSafe, @Immutable)
- A.2 Field and method annotations (@GuardedBy)

---

## Key Topics and Concepts

### Thread Safety Fundamentals
- Atomicity, visibility, and ordering guarantees
- Intrinsic locking (synchronized) and reentrancy
- Volatile variables and their limitations
- Thread confinement (stack, ThreadLocal)
- Immutability and safe publication idioms

### Concurrent Building Blocks
- ConcurrentHashMap, CopyOnWriteArrayList
- BlockingQueue and producer-consumer pattern
- Synchronizers: CountDownLatch, Semaphore, CyclicBarrier, FutureTask
- Executor framework and ExecutorService

### Structuring Concurrent Applications
- Task execution and the Executor abstraction
- Cancellation and interruption policies
- Thread pool sizing and configuration
- Parallelizing recursive algorithms

### Liveness and Performance
- Deadlock (lock ordering, open calls)
- Amdahl's law and scalability analysis
- Lock contention reduction (splitting, striping)
- Context switch overhead

### Advanced Concurrency
- ReentrantLock and ReadWriteLock
- Condition queues and AbstractQueuedSynchronizer (AQS)
- Atomic variables and CAS-based nonblocking algorithms
- Java Memory Model (happens-before, initialization safety)

### Testing
- Correctness testing for concurrent programs
- Performance benchmarking pitfalls
- Static analysis and code review

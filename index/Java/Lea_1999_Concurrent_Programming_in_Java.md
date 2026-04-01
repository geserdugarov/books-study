# Concurrent Programming in Java (Second Edition)

## Book Metadata
- **Title:** Concurrent Programming in Java: Design Principles and Patterns
- **Author:** Doug Lea
- **Publisher:** Addison-Wesley
- **Year:** 1999 (Second Edition)
- **Pages:** 432
- **ISBN:** 0-201-31009-0

## Target Audience and Prerequisites
- Intermediate to advanced Java programmers interested in mastering concurrent programming
- Developers familiar with object-oriented programming but with little exposure to concurrency
- Readers with concurrency experience in other languages transitioning to Java
- Takes a design pattern approach to creating and implementing concurrent components
- Assumes familiarity with basic Java and OO concepts

## Overall Focus
A design-pattern-oriented guide to concurrent programming in Java. Organized around the three kinds of concurrency constructs in Java -- exclusion (synchronized), state dependence (wait/notify), and thread creation (Thread) -- the book presents high-level design principles, technical details surrounding constructs, utilities that encapsulate common usages, and associated design patterns that address particular concurrency problems. The second edition is thoroughly updated for the Java 2 platform with new or expanded coverage of the memory model, cancellation, portable parallel programming, and utility classes for concurrency control.

---

## Table of Contents

### Chapter 1: Concurrent Object-Oriented Programming (pp. 1-56)
- 1.1 Using Concurrency Constructs
- 1.2 Objects and Concurrency
- 1.3 Design Forces
- 1.4 Before/After Patterns

**Summary:** Establishes the conceptual basis for concurrent OO programming. Introduces basic concurrency constructs by example (ParticleApplet), discusses how concurrency and objects fit together, examines design forces that impact construction of concurrent classes and components, and presents common before/after design patterns for structuring solutions.

### Chapter 2: Exclusion (pp. 57-148)
- 2.1 Immutability
- 2.2 Synchronization
- 2.3 Confinement
- 2.4 Structuring and Refactoring Classes
- 2.5 Using Lock Utilities

**Summary:** Maintaining consistent states of objects by preventing unwanted interference among concurrent activities. Covers immutability as the simplest exclusion technique, synchronization via the synchronized keyword, thread confinement strategies, structuring classes for safe concurrent access, and lock utility classes for more flexible locking beyond intrinsic locks.

### Chapter 3: State Dependence (pp. 149-290)
- 3.1 Dealing with Failure
- 3.2 Guarded Methods
- 3.3 Structuring and Refactoring Classes
- 3.4 Using Concurrency Control Utilities
- 3.5 Joint Actions
- 3.6 Transactions
- 3.7 Implementing Utilities

**Summary:** Triggering, preventing, postponing, or recovering from actions depending on whether objects are in states in which these actions could or did succeed. Covers failure handling, guarded methods using monitor methods (wait, notify, notifyAll), class refactoring for state dependence, concurrency control utilities (semaphores, latches, barriers), joint actions across multiple objects, transactional patterns, and implementing custom utility classes.

### Chapter 4: Creating Threads (pp. 291-382)
- 4.1 Oneway Messages
- 4.2 Composing Oneway Messages
- 4.3 Services in Threads
- 4.4 Parallel Decomposition
- 4.5 Active Objects

**Summary:** Establishing and managing concurrency using Thread objects. Covers oneway (fire-and-forget) message patterns, composing oneway messages into workflows, structuring thread-based services, parallel decomposition of computational tasks, and the active object pattern for encapsulating threads within objects.

---

## Key Topics and Concepts

### Exclusion and Thread Safety
- Immutability as a safety strategy
- Synchronization (synchronized keyword, intrinsic locks)
- Thread confinement
- Lock utilities and flexible locking
- Structuring and refactoring classes for concurrency

### State Dependence
- Guarded methods (wait/notify/notifyAll)
- Monitor-based coordination
- Concurrency control utilities (semaphores, latches, barriers)
- Joint actions across multiple participants
- Transactional patterns

### Thread Management
- Oneway message passing
- Thread-based services
- Parallel decomposition
- Active objects pattern
- Thread lifecycle management

### Design Patterns and Principles
- Before/after patterns
- Design forces in concurrent OO programming
- Producer-consumer patterns
- Balancing safety, liveness, and performance
- Java Memory Model implications

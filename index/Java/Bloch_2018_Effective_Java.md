# Effective Java (Third Edition)

## Book Metadata
- **Title:** Effective Java (Third Edition)
- **Author:** Joshua Bloch
- **Publisher:** Addison-Wesley Professional
- **Year:** 2018
- **Pages:** 413
- **ISBN:** 978-0-13-468599-1

## Target Audience and Prerequisites
- Intermediate to advanced Java developers
- Software architects and technical leads
- Requires solid understanding of Java fundamentals (OOP, collections, basic generics)
- Not for complete beginners

## Overall Focus
A definitive guide of 90 concrete best-practice "items" for writing robust, maintainable, and efficient Java code. Updated for Java 7, 8, and 9 features (lambdas, streams, modules). Serves as both a learning resource and a reference guide.

---

## Table of Contents

### Chapter 1: Introduction (p. 1)

### Chapter 2: Creating and Destroying Objects (pp. 5-35)
- Item 1: Consider static factory methods instead of constructors (5)
- Item 2: Consider a builder when faced with many constructor parameters (10)
- Item 3: Enforce the singleton property with a private constructor or an enum type (17)
- Item 4: Enforce noninstantiability with a private constructor (19)
- Item 5: Prefer dependency injection to hardwiring resources (20)
- Item 6: Avoid creating unnecessary objects (22)
- Item 7: Eliminate obsolete object references (26)
- Item 8: Avoid finalizers and cleaners (29)
- Item 9: Prefer try-with-resources to try-finally (34)

**Summary:** Best practices for object instantiation and lifecycle management. Covers patterns like static factory methods and Builder as alternatives to constructors, resource management through try-with-resources, and strategies for avoiding unnecessary object creation and memory leaks.

### Chapter 3: Methods Common to All Objects (pp. 37-71)
- Item 10: Obey the general contract when overriding equals (37)
- Item 11: Always override hashCode when you override equals (50)
- Item 12: Always override toString (55)
- Item 13: Override clone judiciously (58)
- Item 14: Consider implementing Comparable (66)

**Summary:** Proper implementation of core Object methods: equals, hashCode, toString, clone, and compareTo. Emphasizes the contracts that each method must satisfy and the severe consequences of incorrect implementations for collections and hash-based structures.

### Chapter 4: Classes and Interfaces (pp. 73-115)
- Item 15: Minimize the accessibility of classes and members (73)
- Item 16: In public classes, use accessor methods, not public fields (78)
- Item 17: Minimize mutability (80)
- Item 18: Favor composition over inheritance (87)
- Item 19: Design and document for inheritance or else prohibit it (93)
- Item 20: Prefer interfaces to abstract classes (99)
- Item 21: Design interfaces for posterity (104)
- Item 22: Use interfaces only to define types (107)
- Item 23: Prefer class hierarchies to tagged classes (109)
- Item 24: Favor static member classes over nonstatic (112)
- Item 25: Limit source files to a single top-level class (115)

**Summary:** Object-oriented design principles including encapsulation, immutability, composition over inheritance, and proper use of interfaces. Covers API evolution considerations and class hierarchy design strategies.

### Chapter 5: Generics (pp. 117-155)
- Item 26: Don't use raw types (117)
- Item 27: Eliminate unchecked warnings (123)
- Item 28: Prefer lists to arrays (126)
- Item 29: Favor generic types (130)
- Item 30: Favor generic methods (135)
- Item 31: Use bounded wildcards to increase API flexibility (139)
- Item 32: Combine generics and varargs judiciously (146)
- Item 33: Consider typesafe heterogeneous containers (151)

**Summary:** Proper use of Java's type system for reusable, type-safe code. Covers bounded wildcards (PECS: Producer-Extends, Consumer-Super), type erasure implications, and creating flexible generic APIs.

### Chapter 6: Enums and Annotations (pp. 157-191)
- Item 34: Use enums instead of int constants (157)
- Item 35: Use instance fields instead of ordinals (168)
- Item 36: Use EnumSet instead of bit fields (169)
- Item 37: Use EnumMap instead of ordinal indexing (171)
- Item 38: Emulate extensible enums with interfaces (176)
- Item 39: Prefer annotations to naming patterns (180)
- Item 40: Consistently use the Override annotation (188)
- Item 41: Use marker interfaces to define types (191)

**Summary:** Type-safe alternatives to int constants using enums, with EnumSet and EnumMap for collections. Annotations as a powerful replacement for reflection-based naming patterns.

### Chapter 7: Lambdas and Streams (pp. 193-225)
- Item 42: Prefer lambdas to anonymous classes (193)
- Item 43: Prefer method references to lambdas (197)
- Item 44: Favor the use of standard functional interfaces (199)
- Item 45: Use streams judiciously (203)
- Item 46: Prefer side-effect-free functions in streams (210)
- Item 47: Prefer Collection to Stream as a return type (216)
- Item 48: Use caution when making streams parallel (222)

**Summary:** Functional programming features in Java 8+. When to use lambdas vs method references, proper use of standard functional interfaces, and judicious application of the Streams API with emphasis on side-effect-free operations.

### Chapter 8: Methods (pp. 227-259)
- Item 49: Check parameters for validity (227)
- Item 50: Make defensive copies when needed (231)
- Item 51: Design method signatures carefully (236)
- Item 52: Use overloading judiciously (238)
- Item 53: Use varargs judiciously (245)
- Item 54: Return empty collections or arrays, not nulls (247)
- Item 55: Return optionals judiciously (249)
- Item 56: Write doc comments for all exposed API elements (254)

**Summary:** Method design including parameter validation, defensive copying, proper use of overloading and varargs, return value handling (prefer empty collections and optionals over nulls), and Javadoc documentation.

### Chapter 9: General Programming (pp. 261-291)
- Item 57: Minimize the scope of local variables (261)
- Item 58: Prefer for-each loops to traditional for loops (264)
- Item 59: Know and use the libraries (267)
- Item 60: Avoid float and double if exact answers are required (270)
- Item 61: Prefer primitive types to boxed primitives (273)
- Item 62: Avoid strings where other types are more appropriate (276)
- Item 63: Beware the performance of string concatenation (279)
- Item 64: Refer to objects by their interfaces (280)
- Item 65: Prefer interfaces to reflection (282)
- Item 66: Use native methods judiciously (285)
- Item 67: Optimize judiciously (286)
- Item 68: Adhere to generally accepted naming conventions (289)

**Summary:** General practices covering variable scope, loop idioms, library usage, numeric precision (BigDecimal), primitive vs boxed types, string handling performance, and naming conventions.

### Chapter 10: Exceptions (pp. 293-309)
- Item 69: Use exceptions only for exceptional conditions (293)
- Item 70: Use checked exceptions for recoverable conditions and runtime exceptions for programming errors (296)
- Item 71: Avoid unnecessary use of checked exceptions (298)
- Item 72: Favor the use of standard exceptions (300)
- Item 73: Throw exceptions appropriate to the abstraction (302)
- Item 74: Document all exceptions thrown by each method (304)
- Item 75: Include failure-capture information in detail messages (306)
- Item 76: Strive for failure atomicity (308)
- Item 77: Don't ignore exceptions (310)

**Summary:** Proper exception usage as a communication mechanism. Distinguishes checked vs unchecked exceptions, when each is appropriate, and how to design exception hierarchies with meaningful messages.

### Chapter 11: Concurrency (pp. 311-337)
- Item 78: Synchronize access to shared mutable data (311)
- Item 79: Avoid excessive synchronization (317)
- Item 80: Prefer executors, tasks, and streams to threads (323)
- Item 81: Prefer concurrency utilities to wait and notify (325)
- Item 82: Document thread safety (330)
- Item 83: Use lazy initialization judiciously (333)
- Item 84: Don't depend on the thread scheduler (336)

**Summary:** Multi-threaded programming best practices. Covers proper synchronization, the Executor Framework, concurrent collections and synchronizers from java.util.concurrent, thread safety documentation, and lazy initialization patterns.

### Chapter 12: Serialization (pp. 339-365)
- Item 85: Prefer alternatives to Java serialization (339)
- Item 86: Implement Serializable with great caution (343)
- Item 87: Consider using a custom serialized form (346)
- Item 88: Write readObject methods defensively (353)
- Item 89: For instance control, prefer enum types to readResolve (359)
- Item 90: Consider serialization proxies instead of serialized instances (363)

**Summary:** Risks and complexities of Java serialization. Advocates preferring alternatives (JSON, Protocol Buffers) due to security and maintenance issues. When serialization is necessary, covers defensive techniques and serialization proxies.

### Back Matter
- Items Corresponding to Second Edition (367)
- References (371)
- Index (377)

---

## Key Topics and Concepts

### Design Principles
- Composition over inheritance
- Favor immutability
- Encapsulation and information hiding
- Interface-based design
- Dependency injection

### Type System
- Generics and type erasure
- Bounded wildcards (PECS)
- Enum types and EnumSet/EnumMap
- Annotations

### Functional Programming (Java 8+)
- Lambdas and functional interfaces
- Method references
- Streams API
- Side-effect-free operations

### API Design
- Static factory methods
- Builder pattern
- Defensive copying
- Optional return types

### Concurrency
- Executor Framework
- Concurrent collections
- Synchronizers (CountDownLatch, Semaphore)
- Thread safety documentation

### Performance and Correctness
- Avoiding unnecessary object creation
- String concatenation performance
- Primitive vs boxed types
- BigDecimal for exact calculations

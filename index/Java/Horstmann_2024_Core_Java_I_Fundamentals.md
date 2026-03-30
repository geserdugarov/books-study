# Core Java, Volume I — Fundamentals (Thirteenth Edition)

## Book Metadata
- **Title:** Core Java, Volume I — Fundamentals
- **Author:** Cay S. Horstmann
- **Publisher:** Pearson (Oracle Press)
- **Year:** 2024 (Thirteenth Edition)
- **ISBN:** 978-0-13-532837-8
- **Java Version:** Java 21

## Target Audience and Prerequisites
- Serious programmers who want to put Java to work on real projects
- Programmers with a solid background in a programming language other than Java
- Not for complete beginners — assumes prior programming experience
- Companion to Volume II: Advanced Features

## Overall Focus
A comprehensive, authoritative guide to the fundamental concepts of the Java language, updated for Java 21. Covers the core language from introduction through generics, collections, concurrency, annotations, and the module system. Emphasizes practical, real-world code with thorough explanations of Java's design decisions and evolution.

---

## Table of Contents

### Chapter 1: An Introduction to Java
- 1.1 Java as a Programming Platform
- 1.2 The Java "White Paper" Buzzwords
- 1.3 Java Applets and the Internet
- 1.4 A Short History of Java
- 1.5 Common Misconceptions about Java

**Summary:** Java's philosophy and history. Covers the original design goals (simple, object-oriented, distributed, robust, secure, architecture-neutral, portable, interpreted, high-performance, multithreaded, dynamic), the evolution from Green Project through Java 21, and dispels common misconceptions.

### Chapter 2: The Java Programming Environment
- 2.1 Installing the Java Development Kit
- 2.2 Using the Command-Line Tools
- 2.3 Using an Integrated Development Environment
- 2.4 JShell

**Summary:** Setting up the Java development environment. JDK installation, compiling and running from the command line, IDE setup, and using JShell for interactive Java exploration.

### Chapter 3: Fundamental Programming Structures in Java
- 3.1 A Simple Java Program
- 3.2 Comments
- 3.3 Data Types
- 3.4 Variables and Constants
- 3.5 Operators
- 3.6 Strings
- 3.7 Input and Output
- 3.8 Control Flow
- 3.9 Big Numbers
- 3.10 Arrays

**Summary:** Core language syntax and types. Primitive types (int, double, char, boolean), strings (immutable, StringBuilder), operators, control flow (if/switch/loops), BigInteger/BigDecimal for arbitrary precision, and arrays. Covers Java-specific syntax differences from C/C++.

### Chapter 4: Objects and Classes
- 4.1 Introduction to Object-Oriented Programming
- 4.2 Using Predefined Classes
- 4.3 Defining Your Own Classes
- 4.4 Static Fields and Methods
- 4.5 Method Parameters
- 4.6 Object Construction
- 4.7 Records
- 4.8 Packages
- 4.9 JAR Files
- 4.10 Documentation Comments
- 4.11 Class Design Hints

**Summary:** Object-oriented fundamentals. OOP concepts, using and defining classes, static members, parameter passing (always by value in Java), constructors, Java records (data carriers), packages for organization, JAR files, and Javadoc.

### Chapter 5: Inheritance
- 5.1 Classes, Superclasses, and Subclasses
- 5.2 Object: The Cosmic Superclass
- 5.3 Generic Array Lists
- 5.4 Object Wrappers and Autoboxing
- 5.5 Methods with a Variable Number of Arguments
- 5.6 Abstract Classes
- 5.7 Enumeration Classes
- 5.8 Sealed Classes
- 5.9 Pattern Matching
- 5.10 Reflection
- 5.11 Design Hints for Inheritance

**Summary:** Inheritance and polymorphism. The Object class (equals, hashCode, toString), ArrayList, autoboxing, varargs, abstract classes, enums, sealed classes (Java 17), pattern matching (instanceof with patterns), and reflection. Includes modern Java features alongside traditional OOP.

### Chapter 6: Interfaces, Lambda Expressions, and Inner Classes
- 6.1 Interfaces
- 6.2 Lambda Expressions
- 6.3 Inner Classes
- 6.4 Service Loaders
- 6.5 Proxies

**Summary:** Abstraction mechanisms. Interfaces (default methods, static methods), lambda expressions and functional interfaces, inner classes (member, local, anonymous, static nested), the ServiceLoader API, and dynamic proxies for runtime interface implementation.

### Chapter 7: Exceptions, Assertions, and Logging
- 7.1 Dealing with Errors
- 7.2 Catching Exceptions
- 7.3 Tips for Using Exceptions
- 7.4 Using Assertions
- 7.5 Logging
- 7.6 Debugging Tips

**Summary:** Error handling and diagnostics. The exception hierarchy (checked vs unchecked), try-catch-finally, try-with-resources, best practices for exceptions, assertions for invariant checking, the java.util.logging framework, and debugging techniques.

### Chapter 8: Generic Programming
- 8.1 Why Generic Programming?
- 8.2 Defining a Simple Generic Class
- 8.3 Generic Methods
- 8.4 Bounds for Type Variables
- 8.5 Generic Code and the Virtual Machine
- 8.6 Inheritance Rules for Generic Types
- 8.7 Wildcard Types
- 8.8 Restrictions and Limitations
- 8.9 Reflection and Generics

**Summary:** Java's type-safe generics system. Defining generic classes and methods, type variable bounds, type erasure (how generics work at the JVM level), wildcard types (? extends, ? super — PECS principle), restrictions (no primitive type parameters, no instanceof), and using reflection with generics.

### Chapter 9: Collections
- 9.1 The Java Collections Framework
- 9.2 Interfaces in the Collections Framework
- 9.3 Concrete Collections
- 9.4 Maps
- 9.5 Copies and Views
- 9.6 Algorithms
- 9.7 Legacy Collections

**Summary:** The Collections Framework in depth. Collection interfaces (Collection, List, Set, Queue, Map), concrete implementations (ArrayList, LinkedList, HashSet, TreeSet, HashMap, TreeMap, PriorityQueue), unmodifiable copies and views, utility algorithms (sort, binary search, shuffle), and legacy classes (Vector, Hashtable).

### Chapter 10: Concurrency
- 10.1 Running Threads
- 10.2 Thread States
- 10.3 Thread Properties
- 10.4 Coordinating Tasks
- 10.5 Synchronization
- 10.6 Thread-Safe Collections
- 10.7 Asynchronous Computations
- 10.8 Processes

**Summary:** Multithreaded programming. Thread lifecycle and states, task coordination, synchronization mechanisms (locks, conditions, synchronized keyword), thread-safe collections (ConcurrentHashMap, blocking queues), CompletableFuture for asynchronous programming, and process management.

### Chapter 11: Annotations
- 11.1 Using Annotations
- 11.2 Defining Annotations
- 11.3 Annotations in the Java API
- 11.4 Processing Annotations at Runtime
- 11.5 Source-Level Annotation Processing
- 11.6 Bytecode Engineering

**Summary:** Java's metadata system. Using and defining annotations, standard annotations (@Override, @Deprecated, @SuppressWarnings, @FunctionalInterface), runtime annotation processing with reflection, source-level annotation processors, and bytecode engineering for instrumentation.

### Chapter 12: The Java Platform Module System
- 12.1 The Module Concept
- 12.2 Naming Modules
- 12.3 The Modular "Hello, World!" Program
- 12.4 Requiring Modules
- 12.5 Exporting Packages
- 12.6 Modular JARs
- 12.7 Modules and Reflective Access
- 12.8 Automatic Modules
- 12.9 The Unnamed Module
- 12.10 Command-Line Flags for Migration
- 12.11 Transitive and Static Requirements
- 12.12 Qualified Exporting and Opening
- 12.13 Service Loading
- 12.14 Tools for Working with Modules

**Summary:** The Java Platform Module System (JPMS, introduced in Java 9). Module declarations (module-info.java), requires/exports directives, modular JARs, migration strategies (automatic modules, unnamed module), transitive dependencies, qualified exports, and service loading with modules.

---

## Key Topics and Concepts

### Language Fundamentals
- Primitive types and operators
- Strings (immutable, StringBuilder)
- Arrays and control flow
- Big numbers (BigInteger, BigDecimal)

### Object-Oriented Programming
- Classes, inheritance, polymorphism
- Records (Java 16+)
- Sealed classes (Java 17)
- Pattern matching (Java 16+)
- Abstract classes and interfaces
- Design hints for inheritance

### Type System
- Generics and type erasure
- Wildcard types (PECS principle)
- Enumerations
- Annotations

### Functional Programming
- Lambda expressions
- Functional interfaces
- Method references

### Collections Framework
- List, Set, Queue, Map interfaces
- Concrete implementations (ArrayList, HashMap, TreeMap, etc.)
- Algorithms and views

### Concurrency
- Thread management and lifecycle
- Synchronization (locks, conditions, synchronized)
- Thread-safe collections
- CompletableFuture (asynchronous programming)

### Advanced
- Reflection and proxies
- Exception handling (checked vs unchecked)
- The Java Platform Module System (JPMS)
- Logging and debugging

### Java History and Philosophy
- Design goals (White Paper buzzwords)
- Evolution from Green Project through Java 21
- Release model and backwards compatibility

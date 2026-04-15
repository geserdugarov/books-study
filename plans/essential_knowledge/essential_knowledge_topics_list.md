# Essential Knowledge — Study Plan

> A structured curriculum covering the fundamental concepts, principles, and practices every software engineer should deeply understand — independent of any specific language or technology stack.
>
> Topics are organized into progressive layers. Each layer builds on the previous, so they should be studied roughly in order.

---

## Layer 1: Types, Data, and Abstractions

> The building blocks — how data is classified, structured, and generalized. Everything else depends on fluency with these ideas.

### 1. Data Structures (Usage-Oriented)

- Arrays, linked lists, stacks, queues, deques
- Hash maps / hash sets — hashing, collisions, load factors
- Trees: binary search trees, balanced trees (AVL, red-black), B-trees, tries
- Heaps and priority queues
- Graphs: adjacency list vs matrix, traversal (BFS, DFS)
- Choosing the right data structure: time/space tradeoff reasoning
- Standard library collections in your language — know the API, know the complexity

### 2. Type Systems: Nominal, Structural, Variance

- What a type system is and what it guarantees
- Static vs dynamic typing, strong vs weak typing
- Nominal typing (Java, Rust) vs structural typing (TypeScript, Go interfaces)
- Gradual typing (Python with mypy/pyright)
- Type inference — local (Rust, Kotlin) vs global (Haskell, ML)
- Variance: covariance, contravariance, invariance — in generics and function types
- Subtyping vs subclassing — the distinction matters
- Type soundness and type safety

### 3. Abstract Data Types (ADT)

- What ADTs are: specification by behavior, not implementation
- Classic ADTs: Stack, Queue, Map, Set, Priority Queue
- Sum types (tagged unions / discriminated unions) and product types (tuples, records)
- Algebraic data types in functional languages vs enums/sealed classes in OOP
- ADTs as a design tool — encoding domain invariants in types
- The relationship between ADTs and interfaces/protocols

### 4. Generics (Generic Programming)

- The problem generics solve: type-safe code reuse
- Bounded generics / constrained type parameters (trait bounds, type classes, interfaces)
- Monomorphization (Rust, C++) vs type erasure (Java) vs duck typing (Python)
- Generic functions, generic types, generic interfaces/traits
- Higher-kinded types (brief introduction — Haskell, Scala)
- Generics and variance — how they interact
- The expression problem and how generics help (partially) solve it

---

## Layer 2: Polymorphism and Composition

> How to make code flexible — reusing behavior through polymorphism and assembling complex systems from simple parts.

### 5. Polymorphism (Ad-hoc, Subtype, Parametric, etc.)

- Parametric polymorphism — generics, universally quantified types
- Ad-hoc polymorphism — overloading, type classes, traits, protocols
- Subtype polymorphism — inheritance, Liskov Substitution Principle
- Row polymorphism and structural polymorphism (Go, TypeScript)
- Coercion polymorphism — implicit type conversions
- When to use which form — tradeoffs in flexibility, safety, performance
- Polymorphism and the Open/Closed Principle

### 6. Structural Composition, Aggregation, Delegation

- Composition over inheritance — why and when
- Aggregation: "has-a" with independent lifetimes
- Composition: "has-a" with owned lifetimes
- Delegation: forwarding behavior to contained objects
- Mixins and traits as composition tools
- Entity-Component-System (ECS) as a composition paradigm
- When inheritance is still the right answer

### 7. Dispatch and Dynamic Dispatch

- Static dispatch — resolved at compile time (monomorphization, inlining)
- Dynamic dispatch — resolved at runtime (vtables, function pointers)
- Single dispatch (most OOP languages) vs multiple dispatch (Julia, Common Lisp, Python via `functools.singledispatch`)
- Trait objects / interface references as dynamic dispatch mechanisms
- Performance implications: branch prediction, cache behavior, devirtualization
- The visitor pattern as manual double dispatch
- Tag-based dispatch vs vtable-based dispatch

### 8. Modularity System (In Your Language)

- Modules, packages, namespaces — encapsulation at the file/directory level
- Visibility / access control: public, private, package-private, internal
- Dependency management: what you expose vs what you consume
- Circular dependency detection and prevention
- Module cohesion — what belongs together
- Re-exports, barrel files, facade modules
- How your language's module system enforces (or fails to enforce) boundaries

---

## Layer 3: Functional Thinking

> Techniques from functional programming that improve code in any paradigm — purity, composition, immutability, and declarative style.

### 9. Functional Composition, Pure Functions

- What makes a function pure: no side effects, deterministic output for given input
- Referencing transparency and substitution model
- Function composition: `f(g(x))`, pipelines, chaining
- Higher-order functions: functions that take or return functions
- Closures and lexical scoping
- Partial application and currying
- Point-free style — when it helps, when it hurts readability

### 10. Referential Transparency

- Definition: an expression can be replaced by its value without changing behavior
- The relationship to pure functions and immutability
- How referential transparency enables reasoning, testing, and parallelism
- Breaking referential transparency: I/O, mutation, exceptions, time
- The Haskell approach: monads as a way to sequence effects while preserving RT
- Practical referential transparency in non-pure languages — isolating side effects

### 11. Lazy Evaluation

- Eager (strict) vs lazy (non-strict) evaluation strategies
- Call-by-value vs call-by-need vs call-by-name
- Lazy evaluation in practice: iterators, generators, streams
- Infinite data structures made possible by laziness
- Thunks and memoization
- Lazy evaluation pitfalls: space leaks, unpredictable evaluation order
- Short-circuit evaluation as a form of laziness

### 12. Declarative vs Imperative Style

- Imperative: step-by-step instructions (how to do it)
- Declarative: describing what the result should be (what to compute)
- SQL, HTML, CSS, regex as declarative languages
- Declarative patterns in general-purpose languages: list comprehensions, LINQ, stream API
- Configuration as code (Terraform, Nix, Kubernetes YAML)
- Tradeoffs: debuggability, performance control, abstraction leaks
- The spectrum: most code is a mix — choosing the right level

### 13. Recursion versus Loops

- Recursion: base case, recursive case, the call stack
- Tail recursion and tail-call optimization (TCO) — which languages support it
- Mutual recursion
- Converting recursion to iteration and vice versa
- When recursion is natural: tree/graph traversal, divide-and-conquer, parsing
- Stack overflow risks and mitigations (trampolining, explicit stack)
- Recursive data structures (linked lists, trees) and recursive algorithms

### 14. Mutable vs Immutable Data

- What immutability means: shallow vs deep
- Immutable values: strings, tuples, frozen sets, value objects
- Persistent data structures: structural sharing (Clojure, Haskell, Immer.js)
- Copy-on-write semantics
- Benefits: thread safety, easier reasoning, undo/redo, caching
- Costs: allocation pressure, copying overhead
- Language defaults: immutable-by-default (Rust, Haskell) vs mutable-by-default (Java, Python)
- Practical patterns: builder pattern, immutable records with `with`/`copy`

### 15. Idempotent Operations

- Definition: applying an operation multiple times produces the same result as applying it once
- Idempotency in mathematics: `f(f(x)) = f(x)`
- Idempotency in APIs: safe retries, at-least-once delivery
- Idempotent HTTP methods: GET, PUT, DELETE (but not POST)
- Idempotency keys and deduplication strategies
- Database operations: UPSERT as an idempotent pattern
- Why idempotency matters for distributed systems and fault tolerance

---

## Layer 4: Design Principles and Architecture

> The principles that guide how systems are structured — boundaries, dependencies, responsibilities, and state management.

### 16. Abstraction Layers Separation

- What an abstraction layer is: hiding complexity behind a simpler interface
- The layered architecture: presentation, business logic, data access
- Leaky abstractions — Joel Spolsky's Law of Leaky Abstractions
- Over-abstraction vs under-abstraction — finding the right level
- The cost of wrong abstractions: indirection, cognitive overhead
- Clean Architecture, Hexagonal Architecture (Ports & Adapters), Onion Architecture
- Abstraction in libraries and frameworks: what to expose, what to hide

### 17. Law of Demeter

- "Don't talk to strangers" — the principle of least knowledge
- Formal definition: a method should only call methods on its direct collaborators
- Train wreck anti-pattern: `a.getB().getC().doSomething()`
- How LoD reduces coupling and improves encapsulation
- The tension between LoD and convenience (fluent APIs, method chaining)
- Facade pattern as a structural application of LoD
- When violating LoD is acceptable (data transfer objects, internal code)

### 18. Separation of Concerns

- The principle: each module/class/function addresses one concern
- SRP (Single Responsibility Principle) as a class-level expression
- Horizontal concerns: UI, business logic, persistence
- Cross-cutting concerns: logging, authentication, transactions — and how to handle them (AOP, middleware, decorators)
- Separation by feature vs separation by layer
- The relationship to modularity and cohesion
- MVC, MVP, MVVM as patterns for separating UI concerns

### 19. Isolation, Interfaces, Architectural Boundaries

- Interfaces as contracts: what they promise, what they don't
- Programming to an interface, not an implementation
- Boundary objects and anti-corruption layers
- API boundaries: public API surface, backward compatibility
- Physical boundaries: separate processes, network, microservices
- The Dependency Rule (Clean Architecture): dependencies point inward
- Bounded Contexts (Domain-Driven Design)
- Feature flags and versioned interfaces for evolving boundaries

### 20. Dependency Injection and Inversion of Control

- Inversion of Control (IoC): the framework calls you, you don't call the framework
- Dependency Injection (DI): providing dependencies from outside rather than creating them inside
- Constructor injection, setter injection, interface injection
- DI containers / frameworks: Spring (Java), Dagger, .NET DI, Python `inject`
- Manual DI ("poor man's DI") — when a framework is overkill
- Service locator pattern — and why it's usually worse than DI
- DI and testability: injecting mocks and fakes

### 21. Coupling and Cohesion

- Coupling: the degree to which modules depend on each other
- Types of coupling: content, common, control, stamp, data, message (from worst to best)
- Cohesion: the degree to which elements within a module belong together
- Types of cohesion: coincidental, logical, temporal, procedural, communicational, sequential, functional (from worst to best)
- High cohesion + low coupling = well-designed modules
- Measuring coupling: afferent and efferent coupling, instability metric
- Connascence as a unified framework for coupling

### 22. Hidden and Explicit State

- What state is: data that persists across operations
- Explicit state: function parameters, return values, clearly owned data
- Hidden state: global variables, singletons, static mutable fields, closures capturing mutable state
- State machines as a way to make state transitions explicit
- The trouble with hidden state: testing, debugging, concurrency
- Making state explicit: passing context objects, using monads (Reader, State), event sourcing
- Stateless vs stateful services — implications for scaling

---

## Layer 5: Code Quality and Engineering Practice

> The day-to-day practices that determine whether code is maintainable, correct, and robust.

### 23. Naming Conventions

- Why naming matters: code is read far more than it is written
- Language conventions: camelCase, snake_case, PascalCase, SCREAMING_SNAKE_CASE
- Naming things well: intention-revealing names, avoiding abbreviations
- Domain vocabulary: ubiquitous language (DDD concept)
- Anti-patterns: Hungarian notation (in most contexts), single-letter variables (except conventions like `i`, `x`)
- Naming scope rules: short names for small scopes, descriptive names for large scopes
- Consistency within a codebase — more important than any specific convention

### 24. Error Handling

- Errors vs exceptions vs panics — when to use which
- Checked vs unchecked exceptions (Java debate)
- Result/Either types (Rust, Haskell, functional style) vs exceptions (Java, Python, C++)
- Error propagation: `?` operator, `throws`, `raise`, error chaining
- Fail-fast vs fault-tolerant approaches
- Error handling at boundaries: validation, sanitization, user-facing messages
- Defensive programming vs offensive programming (assert and crash vs handle everything)
- The error kernel pattern — concentrating error handling in a narrow layer

### 25. Refactoring, Code Review Process

- Refactoring: improving structure without changing behavior
- Key refactorings: extract method/function, rename, inline, move, pull up/push down
- Martin Fowler's refactoring catalog — essential moves
- Red-green-refactor cycle (TDD)
- Code smells: long methods, large classes, feature envy, shotgun surgery, primitive obsession
- Code review: what to look for (correctness, design, clarity, tests, edge cases)
- Code review culture: constructive feedback, asking questions vs prescribing solutions
- Pair programming and mob programming as continuous review

### 26. Tests (Unit Testing, Coverage, End-to-End)

- The testing pyramid: unit, integration, end-to-end (E2E)
- Unit testing: isolated, fast, focused on one unit of behavior
- Test doubles: mocks, stubs, fakes, spies — when to use which
- Integration tests: verifying component interactions
- End-to-end tests: full system paths, browser automation, API testing
- Test coverage: line, branch, condition — what it tells you and what it doesn't
- Property-based testing: generating inputs to find edge cases
- Test-Driven Development (TDD): write the test first
- Testing anti-patterns: testing implementation details, brittle tests, slow test suites

### 27. Contract Programming

- Design by Contract (DbC): preconditions, postconditions, invariants
- Eiffel as the origin language — Bertrand Meyer
- Assertions as lightweight contracts
- Runtime contract checking: `assert`, `require`, invariant checks
- Contracts and type systems: dependent types, refinement types (the academic frontier)
- Interface contracts: what an API promises (Javadoc `@throws`, Python docstrings)
- Contracts in distributed systems: API contracts, schema validation, consumer-driven contracts (Pact)

---

## Layer 6: Advanced Paradigms and Techniques

> Going beyond the basics — metaprogramming, concurrency, DSLs, and working across paradigms.

### 28. Multiparadigm Programming

- What multiparadigm means: OOP + FP + procedural in one language
- Languages that blend paradigms: Scala, Kotlin, Python, Rust, modern Java, C++
- When to think in objects vs when to think in functions vs when to think in data
- Pattern matching as a paradigm bridge
- The "choose the right tool for the sub-problem" mindset
- Avoiding paradigm wars: understanding what each paradigm does well
- Transitioning between paradigms within a single codebase

### 29. Metaprogramming (Code Generation and Dynamic)

- What metaprogramming is: programs that write or modify programs
- Compile-time metaprogramming: macros (Rust, Lisp, Elixir), templates (C++), annotation processing (Java)
- Runtime metaprogramming: reflection (Java), metaclasses/decorators (Python), dynamic method definition (Ruby)
- Code generation: source generators, template engines, scaffold tools
- AST manipulation for code transformation
- Risks: complexity, debugging difficulty, tooling breakage (IDE support, refactoring)
- When metaprogramming is worth the cost — and when it's not

### 30. Domain-Specific Language (DSL), Interpreter, AST

- Internal DSLs: embedded in a host language (builder patterns, fluent APIs, Kotlin DSLs)
- External DSLs: separate syntax and parser (SQL, regex, Gradle Groovy DSL, Terraform HCL)
- Abstract Syntax Trees (AST): the intermediate representation of parsed code
- Parsing basics: lexer (tokenizer) -> parser -> AST
- Interpreter pattern: walking and evaluating an AST
- DSL design: balancing expressiveness with simplicity
- Real-world DSLs: query builders, configuration languages, testing DSLs (Cucumber/Gherkin)

### 31. Concurrency and Asynchronous Programming

- Concurrency vs parallelism — the distinction
- Threads: OS threads, green threads, virtual threads (Java Loom)
- Shared-state concurrency: mutexes, locks, semaphores, condition variables
- Message-passing concurrency: channels, actors (Erlang/Akka), CSP (Go goroutines)
- Async/await: event loops, futures/promises, non-blocking I/O
- Data races vs race conditions — different problems, different solutions
- Synchronization primitives: atomics, CAS, memory ordering
- Deadlock, livelock, starvation — detection and prevention
- Structured concurrency: scoped tasks, cancellation propagation
- The colored function problem (sync vs async)

---

## Layer 7: Systems Thinking and Modern Practice

> The meta-level — how to think about platforms, systems, language itself, and the evolving role of AI.

### 32. Platform-Agnostic, Framework-Agnostic Approach

- Framework lock-in: the cost of coupling to a specific framework
- Hexagonal Architecture / Ports and Adapters: core logic independent of infrastructure
- The Dependency Rule: business logic should not know about frameworks
- Abstracting over platforms: file systems, networking, UI
- Cross-platform development: runtime abstraction (JVM, .NET, WASM)
- When coupling to a framework is acceptable (rapid prototyping, framework-native code)
- Designing libraries that don't impose a framework

### 33. Separation of System and Applied Code

- System code: infrastructure, frameworks, I/O, networking, OS interaction
- Applied (domain) code: business rules, domain logic, algorithms
- Why they should be separated: testability, portability, clarity
- Clean Architecture's dependency rule applied
- Infrastructure as a plugin — domain at the center
- Side-effect boundaries: functional core, imperative shell
- Anti-pattern: domain logic scattered in controllers, handlers, and database queries

### 34. Language and Semantics

- Syntax vs semantics — form vs meaning
- Operational semantics: how code executes step by step
- Denotational semantics: what expressions "mean" mathematically
- Formal grammars: BNF, EBNF, context-free grammars
- Semantic analysis: type checking, scope resolution, name binding
- Language design tradeoffs: expressiveness vs safety vs learnability
- Understanding language specifications and RFCs
- How learning multiple languages deepens understanding of each

### 35. AI-Assisted Engineering

- AI code generation: capabilities, limitations, and responsible use
- LLM-based tools: code completion (Copilot), code review, test generation, refactoring
- Prompt engineering for code: being specific, providing context, iterating
- AI for learning: explaining code, exploring alternatives, rubber-duck debugging
- Risks: hallucinated APIs, subtle bugs, security vulnerabilities in generated code
- Verification of AI-generated code: review, testing, and understanding before committing
- The evolving role of the engineer: from writing every line to directing and verifying
- When not to use AI: critical security code, novel algorithms, domain-specific edge cases
- AI-assisted documentation, migration, and legacy code understanding

---

## Study Approach

> Recommended practices for working through this plan.

1. **Study in order by layer** — later topics assume earlier ones. Within a layer, topics can be studied in any order.
2. **Use your primary language** — implement examples in the language you know best, then contrast with other languages where relevant.
3. **Code every concept** — reading is not enough. Write small programs that demonstrate each idea.
4. **Connect the dots** — many topics overlap (e.g., immutability connects to referential transparency, concurrency, and idempotency). Actively look for connections.
5. **Refactor old code** — revisit earlier exercises as you learn new principles. Apply separation of concerns, dependency injection, or better error handling to code you wrote for earlier topics.
6. **Discuss and review** — explain concepts to others or write short notes. If a concept isn't clear enough to explain, study it more.

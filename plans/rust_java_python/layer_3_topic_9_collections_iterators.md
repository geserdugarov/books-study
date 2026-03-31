# Layer 3 · Topic 9 — Collections & Iterators

> Comparative study of Rust, Java, and Python: standard collection types and their internal data structures, iterator protocols and lazy evaluation, functional combinators versus comprehensions, ownership semantics during iteration, and specialized/concurrent collections — the data structures and traversal patterns you use every day.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.8 pp. 141–159 | Common collections: `Vec<T>`, `String`, `HashMap<K,V>` — creation, updating, reading, iteration |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.13 pp. 273–294 | Closures and iterators: `Iterator` trait, `next` method, consuming adaptors (`sum`, `collect`), producing adaptors (`map`, `filter`), closures capturing environment, loops vs iterators performance comparison |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.15 pp. 321–357 | Iterators in depth: `Iterator` and `IntoIterator` traits, `iter()` / `iter_mut()` / `into_iter()` / `drain()`, adaptors (`map`, `filter`, `chain`, `zip`, `enumerate`, `take`, `skip`, `peekable`, `cloned`, `cycle`), consumers (`count`, `sum`, `product`, `fold`, `collect`, `any`, `all`, `find`, `position`, `partition`), implementing custom iterators |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.16 pp. 359–389 | Collections: `Vec<T>`, `VecDeque<T>`, `LinkedList<T>`, `BinaryHeap<T>`, `HashMap<K,V>`, `BTreeMap<K,V>`, `HashSet<T>`, `BTreeSet<T>`, `Entry` API, set operations, invalidation error prevention |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.2 pp. 19–35 | Dynamically sized types, wide pointers, trait bounds — foundational for understanding collection type constraints |
| Rust | McNamara (2021) — *Rust in Action* | Ch.2 pp. 31–75 | Arrays, slices, and vectors basics |
| Rust | McNamara (2021) — *Rust in Action* | Ch.7 pp. 212–249 | Practical usage of `HashMap` and `BTreeMap` |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.4 pp. 65–91 | Slices, arrays, `Vec`, `HashMap`, `BTreeMap`, custom hashing |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.11 pp. 219–231 | Vector optimization: allocation, iterators, fast copies with slices |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.9 pp. 117–127 | Java Collections Framework: interfaces (`Collection`, `List`, `Set`, `Map`, `Queue`), concrete collections (`ArrayList`, `LinkedList`, `HashSet`, `TreeSet`, `HashMap`, `TreeMap`, `PriorityQueue`), views, algorithms, legacy collections |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.8 pp. 104–114 | Generic programming: generic classes, generic methods, type variable bounds, wildcard types, type erasure — essential for understanding collection type parameters |
| Java | Horstmann (2024) — *Core Java, Vol. II* | Ch.1 pp. 24–39 | Streams: stream creation, `filter`/`map`/`flatMap`, extracting/combining substreams, reductions, `Optional`, collecting results into maps, grouping/partitioning, downstream collectors, reduction operations, primitive type streams, parallel streams |
| Java | Bloch (2018) — *Effective Java* | Ch.5 pp. 117–155 | Generics best practices: raw types, unchecked warnings, lists vs arrays, generic types/methods, bounded wildcards (PECS), typesafe heterogeneous containers |
| Java | Bloch (2018) — *Effective Java* | Ch.6 pp. 169–179 (Items 36–37) | `EnumSet` instead of bit fields, `EnumMap` instead of ordinal indexing |
| Java | Bloch (2018) — *Effective Java* | Ch.7 pp. 193–225 | Lambdas and streams: lambdas vs anonymous classes, method references, standard functional interfaces, streams judiciously, side-effect-free functions, `Collection` vs `Stream` return types, parallel stream caution |
| Java | Naftalin & Wadler (2024) — *Java Generics and Collections* | Part 2 Chs. 7–17 | Complete coverage of Java Collections Framework implementations: lists, queues, sets, maps — design rationale, performance characteristics, and generic typing |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.6 pp. 169–205 | Concurrent collections: `ConcurrentHashMap`, `CopyOnWriteArrayList`, blocking queues |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.16 pp. 537–570 | Fork/Join framework, parallel streams, `CompletableFuture` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.2 pp. 21–76 | Array of sequences: list comprehensions, generator expressions, tuples as records and immutable lists, unpacking, slicing, `+` and `*` with sequences, `list.sort` vs `sorted`, arrays, memory views, NumPy, `deque` |
| Python | Ramalho (2022) — *Fluent Python* | Ch.3 pp. 77–116 | Dictionaries and sets: dict comprehensions, unpacking, merging, `defaultdict`, `__missing__`, `OrderedDict`, `ChainMap`, `Counter`, `UserDict`, set theory and operations |
| Python | Ramalho (2022) — *Fluent Python* | Ch.17 pp. 593–656 | Iterators, generators, and classic coroutines: iterator protocol (`__iter__`, `__next__`), `Sentence` class examples, generator functions (`yield`), lazy evaluation, `itertools` module (filtering, mapping, merging), `yield from`, classic coroutines |
| Python | Slatkin (2025) — *Effective Python* | Ch.3 pp. 77–108 | Loops and iterators: `enumerate`, `zip`, defensive iteration, avoid modifying containers during iteration, `any`/`all` for short-circuiting, `itertools` |
| Python | Slatkin (2025) — *Effective Python* | Ch.4 pp. 109–134 | Dictionaries: insertion ordering, `get` vs `in`, `defaultdict` vs `setdefault`, `__missing__`, composing classes instead of nesting collections |
| Python | Slatkin (2025) — *Effective Python* | Ch.6 pp. 173–200 | Comprehensions and generators: comprehensions vs `map`/`filter`, generator expressions, `yield from`, passing iterators as arguments, iterative state transitions |
| Python | Slatkin (2025) — *Effective Python* | Ch.7 pp. 257–264 (Item 57) | Inheriting from `collections.abc` for custom container types |
| Python | Slatkin (2025) — *Effective Python* | Ch.12 pp. 493–532 | Data structures and algorithms: `sort`/`sorted` with `key`, `bisect`, `deque` for producer-consumer, `heapq` for priority queues |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.3 pp. 33–113 | Data types (tuples, lists, dicts, sets), sequence/set/dict operations, generators, lambda |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.8 pp. 247–279 | Built-in functions (`len`, `range`, `zip`, `map`, `filter`, `sorted`, `enumerate`), `collections` module, `functools` module, `heapq`, `itertools` |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.3 pp. 65–77 | Lists as dynamic arrays, tuples as static arrays — allocation and resize behavior |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.4 pp. 79–95 | Dictionaries and sets: hash table internals, probing strategies, custom hash functions, resize mechanics |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.5 pp. 97–107 | Iterators for infinite series, lazy generator evaluation, memory efficiency |
| Python | Viafore (2021) — *Robust Python* | Ch.5 pp. 61–76 | Annotating collections, homogeneous vs heterogeneous, `TypedDict`, creating new collection types with generics and ABCs |

### Coverage Gaps

The owned books **do not** cover:

- **Internal data structures of Java collections at the implementation level** — Horstmann and Naftalin & Wadler describe the interfaces and usage of `ArrayList`, `HashMap`, `TreeMap`, etc., but do not detail internal mechanics (array resizing factors, red-black tree rebalancing, hash bucket structure with treeification since Java 8); these details require the OpenJDK source code and the `java.util` Javadoc implementation notes
- **Rust's hashing algorithm choices and `HashMap` internals** — Blandy and Matthews cover `HashMap` usage and the `Entry` API, but the switch from SipHash to `hashbrown` (SwissTable-based), the probe sequence strategy, and SIMD-accelerated lookup are only documented in the `hashbrown` crate documentation and Rust standard library source
- **Java `SequencedCollection` interface (Java 21+)** — none of the owned books cover the new `SequencedCollection`, `SequencedSet`, and `SequencedMap` interfaces introduced in JEP 431 that unify first/last element access across ordered collections
- **Python 3.12+ iterator improvements and PEP 709 (inlined comprehensions)** — the owned books cover Python iterators and generators comprehensively through Python 3.10/3.11, but comprehension inlining (3.12+), `itertools.batched` (3.12+), and other recent additions require the Python changelog and PEP documents
- **Comparative performance benchmarks across all three languages** — each language's books benchmark within that language, but no cross-language comparison of equivalent collection operations (hash map lookup latency, vector append amortized cost, iterator pipeline throughput) is provided; this requires independent benchmarking and research papers
- **Rust `std::collections` module design rationale** — the standard library documentation contains extensive performance guarantees and design notes (when to use `BTreeMap` vs `HashMap`, why `LinkedList` is almost never the right choice) that go beyond what the books cover
- **Java Streams vs Rust iterators deep comparison** — while the owned books cover each separately, the semantic differences (Java streams are single-use and optionally parallel; Rust iterators are composable and always lazy; Python generators are single-use and pull-based) require cross-referencing all three sets of documentation
- **Thread-safe iteration patterns and `Spliterator`** — Evans covers `ConcurrentHashMap` and parallel streams, but the `Spliterator` interface design, fork/join splitting strategies, and how they compare to Rust's `rayon::ParallelIterator` require Java API documentation and Rayon's docs

---

## External Resources

### Sub-topic 1 — Sequence Collections: Vectors, Lists, Arrays

**Rust**
- Rust std docs — `Vec<T>`: `https://doc.rust-lang.org/std/vec/struct.Vec.html`
- Rust std docs — `VecDeque<T>`: `https://doc.rust-lang.org/std/collections/struct.VecDeque.html`
- Rust std docs — Slice primitives: `https://doc.rust-lang.org/std/primitive.slice.html`
- Rust std docs — `std::collections` module overview (when to use each collection): `https://doc.rust-lang.org/std/collections/index.html`

**Java**
- Java SE API — `ArrayList`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayList.html`
- Java SE API — `LinkedList`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedList.html`
- JEP 431 — Sequenced Collections: `https://openjdk.org/jeps/431`
- Dev.java — Collections Framework overview: `https://dev.java/learn/api/collections-framework/`

**Python**
- Python docs — `list`: `https://docs.python.org/3/library/stdtypes.html#list`
- Python docs — `array` module: `https://docs.python.org/3/library/array.html`
- Python docs — `collections.deque`: `https://docs.python.org/3/library/collections.html#collections.deque`
- Python Wiki — TimeComplexity of operations: `https://wiki.python.org/moin/TimeComplexity`

### Sub-topic 2 — Associative Collections: Maps, Dicts, Sets

**Rust**
- Rust std docs — `HashMap<K,V>`: `https://doc.rust-lang.org/std/collections/struct.HashMap.html`
- Rust std docs — `BTreeMap<K,V>`: `https://doc.rust-lang.org/std/collections/struct.BTreeMap.html`
- Rust std docs — `HashSet<T>`: `https://doc.rust-lang.org/std/collections/struct.HashSet.html`
- hashbrown crate docs (SwissTable implementation): `https://docs.rs/hashbrown/latest/hashbrown/`

**Java**
- Java SE API — `HashMap`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html`
- Java SE API — `TreeMap`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeMap.html`
- Java SE API — `EnumMap`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumMap.html`
- Java SE API — `EnumSet`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumSet.html`

**Python**
- Python docs — `dict`: `https://docs.python.org/3/library/stdtypes.html#dict`
- Python docs — `set` / `frozenset`: `https://docs.python.org/3/library/stdtypes.html#set`
- Python docs — `collections` module (`defaultdict`, `OrderedDict`, `Counter`, `ChainMap`): `https://docs.python.org/3/library/collections.html`
- Python docs — `__hash__` data model: `https://docs.python.org/3/reference/datamodel.html#object.__hash__`

### Sub-topic 3 — Iterator Protocols

**Rust**
- Rust std docs — `Iterator` trait: `https://doc.rust-lang.org/std/iter/trait.Iterator.html`
- Rust std docs — `IntoIterator` trait: `https://doc.rust-lang.org/std/iter/trait.IntoIterator.html`
- Rust std docs — `std::iter` module (overview, patterns, performance): `https://doc.rust-lang.org/std/iter/index.html`
- Rust By Example — Iterators: `https://doc.rust-lang.org/rust-by-example/trait/iter.html`
- The Rust Reference — `for` loops and `IntoIterator`: `https://doc.rust-lang.org/reference/expressions/loop-expr.html#iterator-loops`

**Java**
- Java SE API — `Iterable<T>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Iterable.html`
- Java SE API — `Iterator<E>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Iterator.html`
- Java SE API — `ListIterator<E>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ListIterator.html`
- Java Language Specification — Enhanced `for` statement (JLS 14.14.2): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-14.html#jls-14.14.2`

**Python**
- Python docs — Iterator types: `https://docs.python.org/3/library/stdtypes.html#iterator-types`
- Python docs — `__iter__` and `__next__` data model: `https://docs.python.org/3/reference/datamodel.html#object.__iter__`
- Python docs — `iter()` built-in: `https://docs.python.org/3/library/functions.html#iter`
- Python Glossary — iterator, iterable, generator: `https://docs.python.org/3/glossary.html#term-iterator`

### Sub-topic 4 — Lazy Evaluation: Iterators, Streams, Generators

**Rust**
- Rust std docs — Iterator adaptors (lazy by default): `https://doc.rust-lang.org/std/iter/trait.Iterator.html#provided-methods`
- Rust Blog — "Iterators" (Rust by Example, chaining and laziness): `https://doc.rust-lang.org/rust-by-example/trait/iter.html`

**Java**
- Java SE API — `Stream<T>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html`
- Java SE API — `java.util.stream` package overview: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/package-summary.html`
- Java SE API — `Spliterator<T>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Spliterator.html`
- Dev.java — Streams tutorial: `https://dev.java/learn/api/streams/`

**Python**
- Python docs — Generator expressions: `https://docs.python.org/3/reference/expressions.html#generator-expressions`
- Python docs — `yield` expressions: `https://docs.python.org/3/reference/expressions.html#yield-expressions`
- PEP 255 — Simple Generators: `https://peps.python.org/pep-0255/`
- PEP 289 — Generator Expressions: `https://peps.python.org/pep-0289/`
- PEP 380 — Syntax for Delegating to a Subgenerator (`yield from`): `https://peps.python.org/pep-0380/`

### Sub-topic 5 — Functional Combinators: map/filter/fold, Streams, Comprehensions

**Rust**
- Rust std docs — `Iterator::map`: `https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.map`
- Rust std docs — `Iterator::filter`: `https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.filter`
- Rust std docs — `Iterator::fold`: `https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.fold`
- Rust std docs — `Iterator::collect`: `https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect`
- Rust std docs — `FromIterator` trait: `https://doc.rust-lang.org/std/iter/trait.FromIterator.html`

**Java**
- Java SE API — `Collectors` class: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Collectors.html`
- Java SE API — `Optional<T>`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html`
- Java SE API — `java.util.function` package (functional interfaces): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/package-summary.html`

**Python**
- Python docs — List comprehensions: `https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions`
- Python docs — `map`, `filter`, `zip`, `enumerate` built-ins: `https://docs.python.org/3/library/functions.html`
- Python docs — `functools.reduce`: `https://docs.python.org/3/library/functools.html#functools.reduce`
- PEP 709 — Inlined Comprehensions (Python 3.12+): `https://peps.python.org/pep-0709/`

### Sub-topic 6 — Ownership in Collections (Rust Focus)

**Rust**
- The Rustonomicon — Ownership and lifetimes: `https://doc.rust-lang.org/nomicon/ownership.html`
- Rust std docs — `Cow<T>` (clone-on-write): `https://doc.rust-lang.org/std/borrow/enum.Cow.html`
- Rust std docs — `Vec::drain`: `https://doc.rust-lang.org/std/vec/struct.Vec.html#method.drain`
- Rust std docs — `HashMap::entry` (Entry API): `https://doc.rust-lang.org/std/collections/struct.HashMap.html#method.entry`
- Rust By Example — Ownership: `https://doc.rust-lang.org/rust-by-example/scope/move.html`

**Java**
- Java SE API — `Collections.unmodifiableList` (immutable views): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html#unmodifiableList(java.util.List)`
- Java SE API — `List.copyOf` (Java 10+, immutable copies): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#copyOf(java.util.Collection)`

**Python**
- Python docs — `copy` module (shallow vs deep copy): `https://docs.python.org/3/library/copy.html`
- Python docs — Mutable sequence operations: `https://docs.python.org/3/library/stdtypes.html#mutable-sequence-types`

### Sub-topic 7 — Specialized and Concurrent Collections

**Rust**
- Rust std docs — `BinaryHeap<T>`: `https://doc.rust-lang.org/std/collections/struct.BinaryHeap.html`
- Rust std docs — `LinkedList<T>`: `https://doc.rust-lang.org/std/collections/struct.LinkedList.html`
- Rayon crate docs — parallel iterators: `https://docs.rs/rayon/latest/rayon/`
- crossbeam crate docs — concurrent data structures: `https://docs.rs/crossbeam/latest/crossbeam/`
- dashmap crate docs — concurrent `HashMap`: `https://docs.rs/dashmap/latest/dashmap/`

**Java**
- Java SE API — `ConcurrentHashMap`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html`
- Java SE API — `CopyOnWriteArrayList`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArrayList.html`
- Java SE API — `BlockingQueue` interface: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html`
- Java SE API — `ConcurrentSkipListMap`: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html`
- Java SE API — `java.util.concurrent` package overview: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/package-summary.html`

**Python**
- Python docs — `queue` module (thread-safe queues): `https://docs.python.org/3/library/queue.html`
- Python docs — `multiprocessing.Queue`: `https://docs.python.org/3/library/multiprocessing.html#multiprocessing.Queue`
- Python docs — `heapq` module: `https://docs.python.org/3/library/heapq.html`
- Python docs — `bisect` module: `https://docs.python.org/3/library/bisect.html`

### Sub-topic 8 — Custom Collections and Iterator Implementations

**Rust**
- Rust std docs — implementing `Iterator`: `https://doc.rust-lang.org/std/iter/index.html#implementing-iterator`
- Rust std docs — `DoubleEndedIterator`: `https://doc.rust-lang.org/std/iter/trait.DoubleEndedIterator.html`
- Rust std docs — `ExactSizeIterator`: `https://doc.rust-lang.org/std/iter/trait.ExactSizeIterator.html`
- Rust std docs — `Index` and `IndexMut` traits: `https://doc.rust-lang.org/std/ops/trait.Index.html`

**Java**
- Java SE API — `AbstractList` (skeletal implementation): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/AbstractList.html`
- Java SE API — `AbstractMap` (skeletal implementation): `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/AbstractMap.html`
- Dev.java — Implementing custom collections: `https://dev.java/learn/api/collections-framework/implementing-a-collection/`

**Python**
- Python docs — `collections.abc` — abstract base classes for containers: `https://docs.python.org/3/library/collections.abc.html`
- Python docs — Emulating container types (`__getitem__`, `__len__`, `__contains__`, `__iter__`): `https://docs.python.org/3/reference/datamodel.html#emulating-container-types`
- Python docs — `itertools` module: `https://docs.python.org/3/library/itertools.html`

### Sub-topic 9 — Performance Characteristics

**General**
- Wikipedia — Amortized analysis: `https://en.wikipedia.org/wiki/Amortized_analysis`
- Wikipedia — Hash table: `https://en.wikipedia.org/wiki/Hash_table`
- Wikipedia — Red–black tree: `https://en.wikipedia.org/wiki/Red%E2%80%93black_tree`
- Wikipedia — B-tree: `https://en.wikipedia.org/wiki/B-tree`

**Rust**
- Rust std docs — `std::collections` performance guarantees: `https://doc.rust-lang.org/std/collections/index.html#performance`

**Java**
- Aleksey Shipilev — JVM Anatomy Quarks (collection-related entries): `https://shipilev.net/jvm/anatomy-quarks/`

**Python**
- Python Wiki — TimeComplexity: `https://wiki.python.org/moin/TimeComplexity`
- Python docs — `sys.getsizeof`: `https://docs.python.org/3/library/sys.html#sys.getsizeof`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Java | Maurice Naftalin — *Java Streams, Collectors, and Optionals* (Addison-Wesley, 2025) | Dedicated deep-dive into the Java Stream API, collectors, and `Optional` patterns beyond what Core Java II covers; fills the gap on advanced collector composition, custom collectors, and stream performance pitfalls |
| General | Thomas H. Cormen et al — *Introduction to Algorithms* (MIT Press, 2022, 4th ed.) | The foundational algorithms textbook covering hash tables, balanced trees (red-black, B-trees), heaps, and amortized analysis — provides the theoretical underpinning for understanding *why* each collection has its performance characteristics |
| Rust | Jon Gjengset — *Crust of Rust* (YouTube series) | Free video series with episodes on iterators, lifetimes in collections, smart pointers, and `HashMap` internals — the iterator and lifetime episodes provide understanding that goes beyond the owned books |
| Python | David Beazley, Brian K. Jones — *Python Cookbook* (O'Reilly, 2013, 3rd ed.) | Rich collection of practical recipes for iterators, generators, data structures, and functional programming in Python; covers advanced patterns like coroutine pipelines, custom containers, and `itertools` recipes not fully addressed in the owned books |

---

## Study Plan — 10 Sessions

Estimated total: **20–25 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from fundamental collection types through iterator protocols, lazy evaluation, and functional combinators, to ownership semantics, specialized collections, and cross-language synthesis.

---

### Session 1 — Sequence Collections: Vectors, Lists, Arrays

**Goal:** understand the primary sequence collection in each language — Rust's `Vec<T>`, Java's `ArrayList<E>`, Python's `list` — their internal data structure (dynamic array), growth strategy, and basic operations.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 35 min | **Rust: `Vec<T>`, arrays, slices, `VecDeque`.** Read Klabnik Ch.8 pp. 141–150 (vectors: creating, updating, reading, iterating). Read Blandy Ch.16 pp. 359–375 (`Vec<T>`, `VecDeque<T>`, `LinkedList<T>`, `BinaryHeap<T>`). Read Matthews Ch.4 pp. 65–78 (slices, arrays, vectors). Read the `std::collections` module overview online (the "When should you use which collection?" section). Key insight: `Vec<T>` is a growable array on the heap — it stores a pointer, length, and capacity. When `len == capacity`, it reallocates (typically doubling). Slices (`&[T]`) are fat pointers (pointer + length) into contiguous memory — they borrow from arrays, vectors, or other slices without owning. `VecDeque<T>` is a ring buffer for O(1) push/pop at both ends. `LinkedList<T>` exists but is almost never the right choice (poor cache locality, no random access). Rust's `Vec` differs from Java/Python: it owns its elements, and removing an element moves it out — there is no null gap left behind. |
| 1.2 | 30 min | **Java: `ArrayList`, `LinkedList`, arrays, `SequencedCollection`.** Read Horstmann Ch.9 pp. 117–123 (Collections Framework interfaces, concrete collections). Read Naftalin & Wadler Part 2 chapters on lists. Read JEP 431 (Sequenced Collections) online. Key insight: `ArrayList<E>` is backed by an `Object[]` array that grows by 50% when full (unlike Rust's doubling). `LinkedList<E>` implements both `List` and `Deque` — it is a doubly-linked list, rarely used in practice due to poor cache performance. Java arrays are covariant (`String[]` is a subtype of `Object[]`), which allows runtime `ArrayStoreException` — one of the reasons Bloch says "prefer lists to arrays" (Item 28). Java 21 introduced `SequencedCollection` (JEP 431), unifying `getFirst()`/`getLast()`/`reversed()` across ordered collections. Generics use type erasure — `ArrayList<Integer>` and `ArrayList<String>` are the same class at runtime, unlike Rust's monomorphization. |
| 1.3 | 25 min | **Python: `list`, `tuple`, `array.array`, `deque`.** Read Ramalho Ch.2 pp. 21–50 (list comprehensions, generator expressions, tuples, unpacking, slicing). Read Gorelick & Ozsvald Ch.3 pp. 65–77 (lists as dynamic arrays, tuples as static arrays). Read Slatkin Ch.12 pp. 521–528 (Item 103: `deque` for producer-consumer queues). Key insight: Python's `list` is a dynamic array of `PyObject*` pointers — it stores references, not values directly (unlike Rust's `Vec<T>` which stores values inline). Growth factor is roughly 1.125x for large lists (more conservative than Rust or Java). `tuple` is immutable and has a fixed size — CPython caches small tuples for reuse. `array.array` stores typed values compactly (like C arrays) but is rarely used because NumPy is preferred for numerical work. `collections.deque` is a doubly-linked list of fixed-size blocks — O(1) append/pop at both ends, O(n) random access. List comprehensions are the idiomatic way to create lists — they are faster than equivalent `for` loops because the bytecode is optimized. |
| 1.4 | 15 min | **Cross-language comparison.** Compare: (1) Memory layout — Rust `Vec<i64>` stores values contiguously; Java `ArrayList<Long>` stores pointers to boxed `Long` objects (until Valhalla); Python `list` stores `PyObject*` pointers. (2) Growth factors — Rust ~2x, Java ~1.5x, Python ~1.125x. (3) Null/None handling — Rust has no null (use `Vec<Option<T>>`); Java allows null elements; Python allows `None` elements. (4) Type safety — Rust monomorphized at compile time; Java erased at runtime; Python untyped at runtime. Create a benchmark concept: appending N elements to an empty collection in all three languages — predict the allocation patterns. |

---

### Session 2 — Associative Collections: Maps, Dicts, Sets, Hashing

**Goal:** understand hash maps, tree maps, and sets across all three languages — hash function choices, collision resolution strategies, and the `Eq`/`Hash`/`equals`/`hashCode`/`__hash__`/`__eq__` contracts.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 35 min | **Rust: `HashMap`, `BTreeMap`, `HashSet`, `BTreeSet`.** Read Blandy Ch.16 pp. 375–389 (`HashMap<K,V>`, `BTreeMap<K,V>`, `HashSet<T>`, `BTreeSet<T>`, `Entry` API, set operations). Read Matthews Ch.4 pp. 78–91 (HashMap, BTreeMap, custom hashing). Read McNamara Ch.7 pp. 212–249 (practical HashMap and BTreeMap usage). Read the `hashbrown` crate docs online. Key insight: Rust's `HashMap` uses the `hashbrown` crate internally — a SwissTable implementation with SIMD-accelerated probing. The default hasher is `SipHash-1-3` (DoS-resistant but not the fastest); you can substitute `FxHashMap` or `AHashMap` for performance-critical code. Keys must implement `Eq + Hash`. `BTreeMap` uses a B-tree (not red-black tree) — better cache locality than a binary tree. The `Entry` API (`map.entry(key).or_insert(default)`) avoids double lookup for insert-or-update patterns. Set operations (`union`, `intersection`, `difference`, `symmetric_difference`) return lazy iterators. |
| 2.2 | 30 min | **Java: `HashMap`, `TreeMap`, `LinkedHashMap`, `EnumMap`.** Read Horstmann Ch.9 pp. 123–127 (maps, views, algorithms). Read Bloch Ch.6 Items 36–37 (EnumSet, EnumMap). Read the `HashMap` Javadoc online (implementation notes about treeification). Key insight: Java's `HashMap` uses an array of buckets with separate chaining. Since Java 8, when a bucket exceeds 8 entries, it converts from a linked list to a balanced tree (treeification) — this prevents O(n) worst-case lookup from adversarial hash collisions. `TreeMap` uses a red-black tree for O(log n) operations in sorted order. `LinkedHashMap` maintains insertion order (or access order for LRU caches). `EnumMap` is backed by an array indexed by enum ordinal — extremely fast and compact. The `equals`/`hashCode` contract is critical: if `a.equals(b)` then `a.hashCode() == b.hashCode()` — violating this breaks all hash-based collections. `Map.of()` and `Map.copyOf()` create unmodifiable maps (Java 9+). |
| 2.3 | 25 min | **Python: `dict`, `set`, `frozenset`, `defaultdict`, `Counter`.** Read Ramalho Ch.3 pp. 77–116 (dict comprehensions, unpacking, merging, `defaultdict`, `__missing__`, `OrderedDict`, `ChainMap`, `Counter`, `UserDict`, sets). Read Gorelick & Ozsvald Ch.4 pp. 79–95 (hash table internals, probing, resize). Read Slatkin Ch.4 pp. 109–134 (dict ordering, `get`, `defaultdict`, `__missing__`). Key insight: Python's `dict` uses open addressing with a compact layout (since Python 3.6, dicts preserve insertion order — formalized in 3.7). The hash table stores indices separately from key-value pairs for cache efficiency. `dict` resize triggers when 2/3 full. Keys must be hashable (implement `__hash__` and `__eq__`; mutable objects like `list` are unhashable). `defaultdict` calls a factory function for missing keys. `Counter` is a multiset. `ChainMap` chains multiple dicts for layered lookups. `frozenset` is hashable (can be a dict key or set element). Dict merge operators `|` and `|=` were added in Python 3.9. |
| 2.4 | 15 min | **Hashing contract comparison.** Map the hashing contract across languages: Rust requires `Eq + Hash` (both must be consistent); Java requires `equals()` + `hashCode()` consistency (Bloch Items 10–11); Python requires `__eq__` + `__hash__` consistency (objects that compare equal must have the same hash). Compare collision resolution: Rust uses open addressing (SwissTable probing); Java uses separate chaining with treeification; Python uses open addressing with perturbation-based probing. Note that Rust and Python both use open addressing but with very different probe sequences. Compare sorted alternatives: Rust `BTreeMap` (B-tree), Java `TreeMap` (red-black tree), Python has no built-in sorted map (use `sortedcontainers` third-party library). |

---

### Session 3 — Iterator Protocols

**Goal:** master the iterator protocol in each language — Rust's `Iterator`/`IntoIterator` trait system, Java's `Iterable`/`Iterator` interface pair, Python's `__iter__`/`__next__` dunder protocol — and understand how `for` loops desugar in each.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 35 min | **Rust: `Iterator`, `IntoIterator`, and the three iteration methods.** Read Klabnik Ch.13 pp. 273–285 (Iterator trait, `next` method, consuming adaptors, producing adaptors). Read Blandy Ch.15 pp. 321–335 (`Iterator` and `IntoIterator` traits, `iter()` / `iter_mut()` / `into_iter()` / `drain()`). Read the `std::iter` module documentation online. Key insight: Rust has three ways to iterate over a collection: `iter()` yields `&T` (borrows immutably), `iter_mut()` yields `&mut T` (borrows mutably), `into_iter()` yields `T` (consumes the collection). A `for` loop desugars to `IntoIterator::into_iter()` + repeated `Iterator::next()` calls. `IntoIterator` is implemented for `&Vec<T>` (calls `iter()`), `&mut Vec<T>` (calls `iter_mut()`), and `Vec<T>` (calls `into_iter()`). The `Iterator` trait has one required method (`next`) and ~75 provided adaptor methods. All adaptors are lazy — no work happens until a consumer (`collect`, `sum`, `for_each`, `count`) drives the chain. This is fundamentally different from Java streams (which are separate objects) and Python generators (which use `yield`). |
| 3.2 | 30 min | **Java: `Iterable`, `Iterator`, `ListIterator`, and enhanced `for`.** Read Horstmann Ch.9 pp. 117–120 (collection interfaces, iterators). Read Naftalin & Wadler Ch.7 (main interfaces of Java Collections Framework). Read JLS 14.14.2 (enhanced `for` statement) online. Key insight: Java's `Iterable<T>` has one method: `iterator()` returning an `Iterator<T>`. `Iterator<T>` has `hasNext()`, `next()`, and `remove()`. The enhanced `for` loop (`for (var x : collection)`) desugars to `iterator()` + `hasNext()`/`next()` calls. `ListIterator<E>` extends `Iterator` with bidirectional traversal, `add()`, and `set()`. Java iterators are fail-fast — modifying the collection during iteration throws `ConcurrentModificationException` (detected via a modification counter). Note the key difference from Rust: Java's `Iterator` is a separate object from the collection — it does not own or borrow the collection, just holds a cursor position. This means Java cannot prevent concurrent modification at compile time (unlike Rust's borrow checker). |
| 3.3 | 25 min | **Python: `__iter__`, `__next__`, and the iterator protocol.** Read Ramalho Ch.17 pp. 593–625 (iterator protocol, `Sentence` class examples, iterable vs iterator distinction). Read Slatkin Ch.3 pp. 77–90 (Item 17: `enumerate`; Item 18: `zip`; Item 21: defensive iteration). Read Martelli Ch.3 pp. 80–100 (sequence operations, iteration). Key insight: Python's iterator protocol: an iterable has `__iter__()` returning an iterator; an iterator has `__next__()` returning the next value or raising `StopIteration`. `for x in obj:` desugars to `iter(obj)` + repeated `next()` calls catching `StopIteration`. Iterables and iterators are distinct: a `list` is an iterable (can produce multiple independent iterators); a file object is its own iterator (single-pass). Slatkin's Item 21 warns about passing iterators where iterables are expected — an iterator is exhausted after one pass. The `iter()` built-in also has a two-argument sentinel form: `iter(callable, sentinel)` reads until the sentinel value is returned. |
| 3.4 | 15 min | **Protocol comparison.** Compare the three iterator protocols side by side. Rust: `IntoIterator::into_iter() -> Iterator`, `Iterator::next() -> Option<T>` (no exception, just `None`). Java: `Iterable::iterator() -> Iterator`, `Iterator::hasNext() -> boolean` + `Iterator::next() -> T` (two methods, throws `NoSuchElementException`). Python: `__iter__() -> iterator`, `__next__() -> T` (raises `StopIteration`). Note: Rust's `Option<T>` return eliminates the need for a separate `hasNext` check — it is more ergonomic and avoids the Java pitfall of calling `next()` without `hasNext()`. Python uses an exception for flow control (controversial but idiomatic). All three use the "external iterator" pattern — the caller drives iteration. |

---

### Session 4 — Lazy Evaluation: Rust Iterators, Java Streams, Python Generators

**Goal:** understand lazy evaluation mechanisms — how Rust iterator adaptors, Java streams, and Python generators defer computation until results are needed, and the fundamental differences in their execution models.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: iterator adaptors are lazy.** Read Blandy Ch.15 pp. 335–357 (adaptors: `map`, `filter`, `chain`, `zip`, `enumerate`, `take`, `skip`, `peekable`, `cloned`, `cycle`, `flat_map`; consumers: `count`, `sum`, `product`, `fold`, `collect`, `any`, `all`, `find`, `position`, `partition`). Read Klabnik Ch.13 pp. 285–294 (closures capturing environment, improving I/O project with iterators, loops vs iterators performance). Key insight: every Rust iterator adaptor returns a new iterator struct that wraps the previous one — `v.iter().map(f).filter(g)` builds a nested struct `Filter<Map<Iter<T>>>`. No work happens until a consumer calls `next()`. The compiler can inline the entire chain, often producing code as fast as a hand-written loop (zero-cost abstraction). `collect()` is the most versatile consumer — it uses the `FromIterator` trait to build any collection from an iterator. The turbofish syntax (`collect::<Vec<_>>()`) or type annotation tells `collect` what to build. Unlike Java streams, Rust iterators are reusable types — you can store an iterator adaptor chain in a variable and pass it around (though you cannot restart it). |
| 4.2 | 30 min | **Java: streams as lazy pipelines.** Read Horstmann Ch.1 (Core Java II) pp. 24–39 (stream creation, `filter`/`map`/`flatMap`, reductions, `Optional`, collecting, grouping, parallel streams). Read Bloch Ch.7 pp. 193–225 (Items 42–48: lambdas, streams judiciously, side-effect-free functions, `Collection` vs `Stream` return types, parallel stream caution). Key insight: Java streams are a separate abstraction from collections — you create a stream from a collection, apply intermediate operations (lazy), and terminate with a terminal operation (eager). Streams are single-use: after a terminal operation, the stream is consumed. Intermediate operations (`filter`, `map`, `sorted`, `distinct`, `limit`) build a pipeline. Terminal operations (`collect`, `forEach`, `reduce`, `count`, `findFirst`) execute the pipeline. Streams can be parallelized with `.parallelStream()` or `.parallel()` — this uses the ForkJoinPool. Bloch warns: streams are not always clearer than loops (Item 45) and parallel streams can cause bugs or slowdowns if used carelessly (Item 48). `Collectors` provides rich terminal operations (`toList`, `groupingBy`, `partitioningBy`, `joining`). |
| 4.3 | 25 min | **Python: generators and generator expressions.** Read Ramalho Ch.17 pp. 625–656 (generator functions, `yield`, lazy evaluation, `itertools`, `yield from`). Read Slatkin Ch.6 pp. 173–200 (Item 43: generators instead of returning lists; Item 44: generator expressions for large comprehensions; Item 45: `yield from`; Item 46: passing iterators as arguments). Read Gorelick & Ozsvald Ch.5 pp. 97–107 (lazy generator evaluation, memory efficiency). Key insight: a Python function containing `yield` becomes a generator function — calling it returns a generator object (a lazy iterator). Each `yield` suspends the function, preserving its local state on the stack frame. Generator expressions (`(x*x for x in range(10))`) are the lazy equivalent of list comprehensions. `yield from subgen` delegates to a sub-generator, flattening nested iteration. Generators are single-use — once exhausted, they cannot be restarted. The `itertools` module provides composable lazy building blocks: `chain`, `islice`, `takewhile`, `dropwhile`, `groupby`, `product`, `permutations`, `combinations`, `starmap`, `tee`. |
| 4.4 | 15 min | **Laziness comparison.** Compare: Rust iterator adaptors (struct composition, zero-cost, reusable type but single-pass) vs Java streams (pipeline object, single-use, optionally parallel) vs Python generators (suspended stack frame, single-use, memory-efficient). Key distinction: Rust's laziness is structural (each adaptor is a type); Java's laziness is behavioral (stream pipeline records operations); Python's laziness is coroutine-based (`yield` suspends a real stack frame). All three prevent materializing intermediate results. Rust and Python are pull-based (caller drives `next()`); Java streams can be push-based internally (the `Spliterator` decides how to split and push). Only Java streams have built-in parallelism — Rust uses `rayon` and Python uses `multiprocessing` or `concurrent.futures`. |

---

### Session 5 — Functional Combinators: map/filter/fold vs Streams vs Comprehensions

**Goal:** master the functional programming patterns for transforming, filtering, and reducing collections — and understand the idiomatic style in each language.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: map, filter, fold, collect, and closures.** Read Blandy Ch.15 pp. 335–357 (the full adaptor and consumer catalog, with examples). Read Klabnik Ch.13 pp. 273–285 (closures: `Fn`, `FnMut`, `FnOnce`, capturing by reference vs move). Key insight: Rust closures are anonymous structs implementing `Fn`, `FnMut`, or `FnOnce` traits — the compiler infers which based on how the closure uses captured variables. `map(|x| x * 2)` borrows nothing (stateless). `filter(|x| x > &threshold)` borrows `threshold` immutably. `fold(0, |acc, x| acc + x)` is the most general consumer — `sum`, `product`, `count` are specializations. `collect()` with turbofish can build `Vec`, `HashMap`, `HashSet`, `String`, `BTreeMap`, and any type implementing `FromIterator`. The `?` operator works inside closures with `try_fold` and `Iterator::try_for_each`. Method chaining is the idiomatic Rust style for data transformation. |
| 5.2 | 30 min | **Java: Stream API, Collectors, and Optional.** Read Horstmann Ch.1 (Core Java II) pp. 30–39 (collecting results, grouping, partitioning, downstream collectors, reduction, primitive streams). Read Bloch Ch.7 Items 45–47 (streams judiciously, side-effect-free functions, `Collection` vs `Stream` return). Key insight: Java's `Collectors` class provides a rich vocabulary: `toList()`, `toSet()`, `toMap()`, `groupingBy()`, `partitioningBy()`, `joining()`, `summarizingInt()`. Downstream collectors compose: `groupingBy(City::country, counting())` or `groupingBy(City::country, mapping(City::name, toList()))`. `Optional<T>` replaces null returns in stream operations — `findFirst()`, `findAny()`, `min()`, `max()` all return `Optional`. `reduce(identity, accumulator)` is Java's fold. Primitive streams (`IntStream`, `LongStream`, `DoubleStream`) avoid boxing overhead with `mapToInt()`, `sum()`, `average()`. The Stream API deliberately avoids the term "lazy" — it uses "intermediate" vs "terminal" to describe the evaluation model. |
| 5.3 | 25 min | **Python: comprehensions, generator expressions, and built-in functionals.** Read Slatkin Ch.6 pp. 173–188 (Item 40: comprehensions vs `map`/`filter`; Item 41: avoid complex comprehensions; Item 42: walrus operator in comprehensions). Read Ramalho Ch.2 pp. 21–35 (list comprehensions, generator expressions, set and dict comprehensions). Read Martelli Ch.8 pp. 247–265 (`map`, `filter`, `zip`, `enumerate`, `functools.reduce`). Key insight: Python's idiomatic style prefers comprehensions over `map`/`filter` — `[x*2 for x in xs if x > 0]` is clearer than `list(map(lambda x: x*2, filter(lambda x: x > 0, xs)))`. Dict comprehensions (`{k: v for k, v in pairs}`) and set comprehensions (`{x*x for x in xs}`) follow the same pattern. Generator expressions use parentheses and are lazy — `sum(x*x for x in xs)` never materializes the list. `functools.reduce` is Python's fold but is considered unpythonic for most cases — explicit loops or `sum`/`max`/`min` are preferred. The walrus operator (`:=`, Python 3.8+) enables assignment inside comprehensions for reuse of intermediate values. Python 3.12+ inlines comprehension scoping (PEP 709) for a performance boost. |
| 5.4 | 15 min | **Idiom comparison.** Solve three problems in all three languages: (1) Transform a list of strings to uppercase, filtering those longer than 3 characters. (2) Group items by a key function and count occurrences per group. (3) Find the maximum element by a derived key. Compare the idiomatic solution in each: Rust (iterator chain with `map`/`filter`/`collect`), Java (stream pipeline with `Collectors.groupingBy`), Python (comprehension + `Counter` or `max` with `key`). Note how Python's approach is often the most concise, Java's is the most explicitly typed, and Rust's sits between — concise with type inference but explicit about ownership. |

---

### Session 6 — Ownership in Collections: Borrow, Consume, Drain

**Goal:** understand how Rust's ownership system interacts with collections and iteration — what happens when you iterate by reference vs by value, the `drain` pattern, the Entry API — and how Java and Python handle the equivalent scenarios (concurrent modification, defensive copying).

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 35 min | **Rust: ownership and borrowing during iteration.** Read Blandy Ch.15 pp. 321–335 (`iter()` borrows `&T`, `iter_mut()` borrows `&mut T`, `into_iter()` moves `T`, `drain()` removes and yields). Read Blandy Ch.16 pp. 359–365 (collections and ownership, invalidation prevention). Read Gjengset Ch.2 pp. 19–35 (types in memory, trait bounds as collection constraints). Key insight: Rust's borrow checker prevents iterator invalidation at compile time. You cannot modify a `Vec` while iterating over it with `iter()` — the immutable borrow prevents it. `drain(range)` removes elements from a collection and yields them as owned values — useful for transferring elements between collections. `retain(|x| predicate)` filters a collection in place. The `Entry` API (`map.entry(key).or_insert_with(|| default)`) avoids the "check-then-insert" anti-pattern that requires two lookups. `Cow<[T]>` (clone-on-write) defers cloning until mutation is needed. These patterns are unique to Rust — Java and Python allow iterator invalidation at runtime. |
| 6.2 | 25 min | **Java: ConcurrentModificationException and defensive copies.** Read Horstmann Ch.9 pp. 123–127 (views, unmodifiable collections). Read Bloch Ch.7 Items 45–47 (streams and collections interplay). Read the `Collections.unmodifiableList` and `List.copyOf` Javadocs online. Key insight: Java's fail-fast iterators throw `ConcurrentModificationException` if the collection is modified during iteration (except through the iterator's own `remove()` method). This is a runtime check, not a compile-time guarantee. Defensive copies (`List.copyOf()`, `Collections.unmodifiableList()`) create immutable views or shallow copies to prevent external modification. Stream operations must not modify the underlying collection (side-effect-free requirement). Java 10+ `List.copyOf()`, `Set.copyOf()`, `Map.copyOf()` create truly immutable collections — subsequent attempts to modify throw `UnsupportedOperationException`. The upcoming Project Valhalla will enable value types in collections (eliminating boxing overhead for `ArrayList<int>`). |
| 6.3 | 25 min | **Python: mutation during iteration and copy strategies.** Read Slatkin Ch.3 pp. 95–100 (Item 22: never modify containers while iterating). Read Ramalho Ch.2 pp. 50–65 (augmented assignment with sequences, `+` and `*` with mutable/immutable). Read the `copy` module docs online. Key insight: Python does not prevent mutation during iteration at the language level. Modifying a `dict` during iteration raises `RuntimeError` (since Python 3.0), but modifying a `list` during iteration silently produces wrong results (skipped or duplicated elements). The idiomatic solution: iterate over a copy (`for x in list(original):`) or build a new collection. `copy.copy()` creates a shallow copy; `copy.deepcopy()` recursively copies. Tuple and frozenset are immutable — they guarantee no mutation but only at the top level (a tuple of lists can have its lists mutated). Python has no equivalent of Rust's borrow checker — defensive copying and discipline are the programmer's responsibility. |
| 6.4 | 15 min | **Ownership comparison.** Compare how each language prevents (or fails to prevent) iterator invalidation. Rust: compile-time prevention via borrow checker — the strongest guarantee, zero runtime cost. Java: runtime detection via `ConcurrentModificationException` — catches many bugs but not all (concurrent access from another thread is not always detected). Python: partial runtime detection (dicts throw, lists don't) — the weakest guarantee, relies on programmer discipline. Compare the `drain` concept: Rust has `drain()` as a first-class method; Java's closest equivalent is `Iterator.remove()` or `removeIf()`; Python's closest is `pop()` in a loop or list comprehension reassignment. |

---

### Session 7 — Specialized and Concurrent Collections

**Goal:** explore specialized collection types beyond the standard map/list/set — priority queues, enum-specialized collections, concurrent/thread-safe collections — and understand when to use each.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 30 min | **Rust: `BinaryHeap`, `BTreeMap`/`BTreeSet`, and concurrent crate ecosystem.** Read Blandy Ch.16 pp. 380–389 (`BinaryHeap`, `BTreeMap`, `BTreeSet`, set operations). Read Matthews Ch.11 pp. 219–231 (vector and collection optimization). Read the `crossbeam`, `dashmap`, and `rayon` crate docs online. Key insight: `BinaryHeap<T>` is a max-heap (for min-heap, use `Reverse` wrapper or `std::cmp::Reverse`). `BTreeMap`/`BTreeSet` provide ordered iteration and range queries — use them when you need sorted keys or range scans. Rust's standard library deliberately excludes concurrent collections — this is delegated to the crate ecosystem. `dashmap` provides a concurrent `HashMap` using sharded locking. `crossbeam` provides lock-free queues, deques, and epoch-based memory reclamation. `rayon` provides parallel iterators (`par_iter()`) that automatically split work across threads. The design choice: Rust's `Send`/`Sync` marker traits ensure that non-thread-safe collections cannot be shared across threads — the type system prevents data races by construction. |
| 7.2 | 30 min | **Java: `ConcurrentHashMap`, blocking queues, `CopyOnWriteArrayList`, `EnumSet`/`EnumMap`.** Read Evans Ch.6 pp. 169–205 (`ConcurrentHashMap`, `CopyOnWriteArrayList`, blocking queues). Read Bloch Ch.6 Items 36–37 (`EnumSet`, `EnumMap`). Read the `java.util.concurrent` package overview online. Key insight: `ConcurrentHashMap` uses a segmented (striped) locking design — concurrent reads require no locking, and writes lock only the affected segment. It supports atomic compound operations (`computeIfAbsent`, `merge`). `CopyOnWriteArrayList` is optimized for read-heavy, write-rare workloads — every write creates a new internal array copy. `BlockingQueue` implementations (`ArrayBlockingQueue`, `LinkedBlockingQueue`, `PriorityBlockingQueue`) are the backbone of producer-consumer patterns. `EnumSet` uses a bit vector internally — operations are a single machine word AND/OR. `EnumMap` uses an array indexed by ordinal — no hashing overhead. `PriorityQueue` is a min-heap. `ConcurrentSkipListMap` is a concurrent sorted map based on skip lists. |
| 7.3 | 25 min | **Python: `heapq`, `bisect`, `queue.Queue`, `collections` specialties.** Read Slatkin Ch.12 pp. 521–532 (Item 103: `deque`; Item 104: `heapq`). Read Slatkin Ch.4 pp. 115–134 (Item 27: `defaultdict`; Item 28: `__missing__`; Item 29: composing classes over nested dicts). Read Ramalho Ch.3 pp. 95–116 (`OrderedDict`, `ChainMap`, `Counter`, `UserDict`, set operations). Read the `queue`, `heapq`, and `bisect` module docs online. Key insight: Python has no built-in concurrent dict — the GIL makes many dict operations effectively atomic in CPython, but this is an implementation detail, not a guarantee. `queue.Queue` is thread-safe (uses locks internally) for producer-consumer patterns. `heapq` provides heap operations on a plain `list` (not a separate type) — `heappush`, `heappop`, `nlargest`, `nsmallest`. `bisect` provides binary search for sorted lists — `insort` maintains sorted order during insertion. `Counter` supports arithmetic (`+`, `-`, `&`, `|`) for multiset operations. `ChainMap` enables layered lookup (useful for variable scoping, template contexts). `UserDict` is the recommended base class for custom dict-like classes (inheriting from `dict` directly can cause issues with `__missing__`). |
| 7.4 | 15 min | **Specialized collections comparison.** Compare concurrent approaches: Rust relies on `Send`/`Sync` + external crates (compile-time safety, no built-in concurrent collections); Java has a rich `java.util.concurrent` package (runtime thread safety, well-tested JDK implementations); Python relies on the GIL + `queue.Queue` (limited true concurrency, simpler model). Compare priority queues: Rust `BinaryHeap` (max-heap, separate type), Java `PriorityQueue` (min-heap, separate type), Python `heapq` (min-heap, functions on a list). Compare enum-specialized collections: Rust has no dedicated enum collections (use `HashMap` with enum keys, or arrays indexed by discriminant); Java has `EnumSet`/`EnumMap` (optimized bit-vector/array); Python has no equivalent (use `dict` with enum keys). |

---

### Session 8 — Custom Collections and Iterator Implementations

**Goal:** learn how to create custom collection types and custom iterators in each language — implementing the required traits/interfaces/protocols to make your types work with `for` loops, iterator adaptors, and the standard library.

| Step | Time | Activity |
|------|------|----------|
| 8.1 | 30 min | **Rust: implementing `Iterator`, `IntoIterator`, `FromIterator`, `Index`.** Read Blandy Ch.15 pp. 348–357 (implementing custom iterators). Read Klabnik Ch.13 pp. 285–290 (creating custom iterators). Read the `Iterator`, `DoubleEndedIterator`, `ExactSizeIterator`, `FromIterator`, and `Index`/`IndexMut` docs online. Key insight: to make a custom type iterable, implement `IntoIterator` — its `into_iter` method returns your iterator type. The iterator type implements `Iterator` with a `next()` method. You often need a separate struct for the iterator (holding a reference or index into the collection). `DoubleEndedIterator` enables `rev()` and `next_back()`. `ExactSizeIterator` enables `len()` on iterators. `FromIterator` enables `collect()` into your type. `Index`/`IndexMut` enable `collection[index]` syntax. A common pattern: implement `IntoIterator` for `&MyCollection`, `&mut MyCollection`, and `MyCollection` to support all three iteration modes. |
| 8.2 | 25 min | **Java: extending `AbstractList`, `AbstractMap`, implementing `Iterable`.** Read Naftalin & Wadler Part 2 Ch.7 (main interfaces). Read the `AbstractList` and `AbstractMap` Javadocs online. Read Bloch Ch.4 Item 20 (prefer interfaces to abstract classes) and Ch.5 Item 31 (bounded wildcards). Key insight: Java's skeletal implementations (`AbstractList`, `AbstractSet`, `AbstractMap`) minimize the work needed for a custom collection. For `AbstractList`, implement `get(int)` and `size()` to get a read-only list; add `set(int, E)` for mutability; add `add(int, E)` and `remove(int)` for full mutability. For `AbstractMap`, implement `entrySet()`. The `Iterable` interface requires only `iterator()`. The `Spliterator` interface (for parallel streams) requires `tryAdvance()` and `trySplit()`. Custom collections automatically work with streams, enhanced `for` loops, and all `Collections` utility methods. Type safety is enforced through generics — your custom collection is parametric in its element type. |
| 8.3 | 25 min | **Python: `collections.abc` and emulating container types.** Read Slatkin Ch.7 pp. 257–264 (Item 57: inherit from `collections.abc`). Read Ramalho Ch.12 pp. 397–430 (`__getitem__`, `__len__`, `__contains__`, duck typing protocols). Read Viafore Ch.5 pp. 68–76 (creating new collections with ABCs and generics). Read the `collections.abc` docs online. Key insight: `collections.abc` provides abstract base classes that define the minimal interface for each container type: `Iterable` (`__iter__`), `Iterator` (`__next__`), `Sized` (`__len__`), `Container` (`__contains__`), `Sequence` (`__getitem__` + `__len__`), `MutableSequence` (adds `__setitem__`, `__delitem__`, `insert`), `Mapping`, `MutableMapping`, etc. Inheriting from these ABCs provides mixin methods for free — `Sequence` gives you `__contains__`, `__iter__`, `__reversed__`, `index`, `count` from just `__getitem__` and `__len__`. Duck typing means you can also skip the ABC and just implement the methods — but ABCs give you `isinstance` support and catch missing methods early. `UserDict`, `UserList`, `UserString` are recommended over subclassing built-in `dict`/`list`/`str` because built-ins sometimes bypass custom `__getitem__`/`__setitem__` in C-level code. |
| 8.4 | 20 min | **Custom iterator comparison.** Implement a `Range` (custom numeric range) type in all three languages that supports: creation with start/stop/step, `for` loop iteration, length query, and containment check. Rust: struct with `Iterator + ExactSizeIterator + DoubleEndedIterator` implementations. Java: class implementing `Iterable<Integer>` with a custom `Iterator`. Python: class with `__iter__`, `__next__`, `__len__`, `__contains__`. Compare: Rust requires separate iterator and collection types (borrow rules enforce this); Java requires a separate `Iterator` class (interface design enforces this); Python can combine iterable and iterator in one class (but shouldn't for reusability — Ramalho's Sentence examples show why). |

---

### Session 9 — Performance Characteristics and Optimization

**Goal:** understand the time and space complexity of operations across all collection types, cache effects, allocation patterns, and optimization techniques specific to each language.

| Step | Time | Activity |
|------|------|----------|
| 9.1 | 30 min | **Rust: collection performance, allocation, and zero-cost iteration.** Read Matthews Ch.11 pp. 219–231 (vector optimization, allocation, iterators, fast copies). Read Klabnik Ch.13 pp. 290–294 (loops vs iterators performance). Read the `std::collections` module performance table online. Key insight: Rust iterators compile to the same machine code as hand-written loops — the `Filter<Map<Iter<T>>>` struct chain is fully inlined and optimized away. `Vec::with_capacity(n)` avoids reallocations when the size is known. `extend()` is faster than repeated `push()` because it can bulk-allocate. `collect()` uses `size_hint()` from `ExactSizeIterator` to pre-allocate the destination. `Vec<T>` stores elements inline (not boxed) — a `Vec<u64>` is a contiguous array of `u64` values with no pointer indirection (unlike Java's `ArrayList<Long>`). `clone()` on a `Vec` deep-copies all elements. `drain()` + `extend()` is faster than clone-and-filter. `BTreeMap` has better cache locality than a pointer-heavy tree because B-tree nodes store multiple keys per node. |
| 9.2 | 25 min | **Java: collection performance, boxing, and JIT effects.** Read Bloch Ch.7 Item 48 (use caution when making streams parallel). Read Evans Ch.16 pp. 537–555 (Fork/Join, parallel stream performance). Read Shipilev's JVM Anatomy Quarks online (relevant entries on collections). Key insight: Java's biggest performance issue with collections is autoboxing — `ArrayList<Integer>` stores boxed `Integer` objects, each with a 16-byte object header + 4-byte value + 4-byte alignment = 24 bytes per element (vs 4 bytes for a plain `int`). `IntStream`, `LongStream`, `DoubleStream` avoid boxing for streams. `ArrayList` resize is 1.5x growth factor — more memory-efficient than 2x but more frequent reallocation. `HashMap` load factor is 0.75 — resize when 75% full. JIT optimization can eliminate iterator object allocation via escape analysis (the iterator never escapes the loop). Parallel streams are effective only for large datasets (>10K elements) and CPU-bound operations — I/O-bound or small collections are slower with parallelism due to ForkJoinPool overhead. |
| 9.3 | 25 min | **Python: collection performance, CPython internals, and optimization.** Read Gorelick & Ozsvald Ch.3 pp. 65–77 (list/tuple allocation, resize behavior). Read Gorelick & Ozsvald Ch.4 pp. 79–95 (dict/set hash table internals). Read Gorelick & Ozsvald Ch.5 pp. 97–107 (iterator/generator memory efficiency). Read the Python Wiki TimeComplexity page online. Key insight: Python `list` over-allocates by ~12.5% for large lists (growth pattern: 0, 4, 8, 16, 24, 32, 40, 52, 64, ...). `tuple` has no over-allocation (fixed size) and CPython caches small tuples (length 0–20). `dict` resize at 2/3 load — hash table size always a power of 2. Generator expressions use O(1) memory vs list comprehension O(n) — critical for large datasets. `collections.deque` is O(1) for append/pop at both ends, O(n) for random access. `sorted()` uses TimSort (hybrid merge-insertion sort) — O(n log n) worst case, O(n) for partially sorted data. Key optimization: use `dict` (hash-based O(1) lookup) instead of `list` (linear scan O(n)) for membership testing. `set` operations (`intersection`, `union`) are faster than manual loops. |
| 9.4 | 20 min | **Performance comparison table.** Build a comprehensive table comparing time complexity for: append, prepend, random access, search, insert at index, delete, iteration, sort — across `Vec`/`ArrayList`/`list`, `HashMap`/`HashMap`/`dict`, `BTreeMap`/`TreeMap`/–, `VecDeque`/`ArrayDeque`/`deque`, `BinaryHeap`/`PriorityQueue`/`heapq`. Note constant factors: Rust's inline storage vs Java's boxing overhead vs Python's interpreter overhead. Memory per element: Rust `Vec<i64>` = 8 bytes; Java `ArrayList<Long>` ≈ 24 bytes; Python `list` of `int` ≈ 36 bytes (28 for `int` object + 8 for pointer). Note the qualitative differences: Rust is predictable (no GC pauses, no JIT warmup); Java is fast after warmup (JIT optimizes hot paths); Python is the slowest but most productive for prototyping. |

---

### Session 10 — Capstone: Cross-Language Idioms and Synthesis

**Goal:** synthesize all sessions into a unified understanding — compare idiomatic data processing pipelines across all three languages, understand when each language's collection/iterator model shines, and build a reference table for daily use.

| Step | Time | Activity |
|------|------|----------|
| 10.1 | 30 min | **Idiomatic data processing pipelines.** Solve a realistic problem (e.g., parse a log file, group entries by severity, count occurrences, find the top N most frequent entries) in all three languages using each language's idiomatic style. Rust: `lines.iter().filter_map(parse).fold(HashMap::new(), count).into_iter().sorted_by_key(|&(_, c)| Reverse(c)).take(n).collect()`. Java: `lines.stream().map(this::parse).flatMap(Optional::stream).collect(groupingBy(Entry::severity, counting())).entrySet().stream().sorted(Map.Entry.<String, Long>comparingByValue().reversed()).limit(n).collect(toList())`. Python: `Counter(parse(line) for line in lines if parse(line)).most_common(n)`. Key insight: Python is often the most concise for data munging (built-in `Counter.most_common`). Java is the most explicit and self-documenting (every step is named). Rust strikes a balance and offers the best performance — the entire pipeline compiles to a tight loop with no heap allocation for intermediate results. |
| 10.2 | 25 min | **When to use which collection.** Create a decision flowchart for each language: need ordered keys → `BTreeMap`/`TreeMap`/`sorted` or `SortedDict`; need O(1) lookup → `HashMap`/`HashMap`/`dict`; need FIFO queue → `VecDeque`/`ArrayDeque`/`deque`; need priority queue → `BinaryHeap`/`PriorityQueue`/`heapq`; need concurrent map → `dashmap`/`ConcurrentHashMap`/`dict` with GIL (or `multiprocessing.Manager().dict()`); need immutable sequence → `&[T]`/`List.of()`/`tuple`; need unique elements → `HashSet`/`HashSet`/`set`. Understand the tradeoffs: memory footprint, cache locality, thread safety, and API ergonomics. |
| 10.3 | 25 min | **Iterator pattern comparison.** Revisit the three iterator models and compare: (1) Rust iterators are zero-cost, type-safe, and composable — but the type signatures of complex chains can be long (`impl Iterator<Item = T>` hides this). (2) Java streams are single-use, support parallelism, and integrate with the type system — but are verbose and easy to misuse (side effects, parallel pitfalls). (3) Python generators are memory-efficient, simple to write (`yield`), and compose with `itertools` — but are single-pass and untyped. Compare the "pipeline" metaphor: Rust builds a nested struct (static dispatch); Java builds a pipeline object (dynamic dispatch to lambda); Python builds a chain of suspended stack frames. |
| 10.4 | 20 min | **Final synthesis table.** Create a comprehensive reference table mapping all concepts across languages. Columns: Concept, Rust, Java, Python, Key Difference. Rows: dynamic array, linked list, hash map, sorted map, hash set, sorted set, priority queue, double-ended queue, iterator protocol, lazy evaluation, functional combinators, parallel iteration, concurrent collections, custom collections, ownership during iteration, collection immutability. This table serves as a quick reference for daily use when switching between languages. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Sequence collections | Klabnik 141–150, Blandy 359–375, Matthews 65–78, Horstmann I 117–123, Naftalin & Wadler Part 2, Ramalho 21–50, Gorelick 65–77, Slatkin 521–528 | Rust `std::collections` docs, JEP 431, Python Wiki TimeComplexity |
| 2 | Associative collections & hashing | Blandy 375–389, Matthews 78–91, McNamara 212–249, Horstmann I 123–127, Bloch Items 36–37, Ramalho 77–116, Gorelick 79–95, Slatkin 109–134 | `hashbrown` crate docs, `HashMap` Javadoc (treeification notes), Python `collections` docs |
| 3 | Iterator protocols | Klabnik 273–285, Blandy 321–335, Horstmann I 117–120, Naftalin & Wadler Ch.7, Ramalho 593–625, Slatkin 77–90, Martelli 80–100 | Rust `std::iter` docs, JLS 14.14.2, Python iterator types docs |
| 4 | Lazy evaluation | Blandy 335–357, Klabnik 285–294, Horstmann II 24–39, Bloch Items 42–48, Ramalho 625–656, Slatkin 173–200, Gorelick 97–107 | Rust `Iterator` provided methods, `java.util.stream` package docs, PEP 255/289/380 |
| 5 | Functional combinators | Blandy 335–357, Klabnik 273–285, Horstmann II 30–39, Bloch Items 45–47, Slatkin 173–188, Ramalho 21–35, Martelli 247–265 | `FromIterator` docs, `Collectors` Javadoc, PEP 709 |
| 6 | Ownership in collections | Blandy 321–335 + 359–365, Gjengset 19–35, Horstmann I 123–127, Bloch Items 45–47, Slatkin 95–100, Ramalho 50–65 | Rustonomicon ownership, `Collections.unmodifiableList` Javadoc, Python `copy` docs |
| 7 | Specialized & concurrent collections | Blandy 380–389, Matthews 219–231, Evans 169–205, Bloch Items 36–37, Slatkin 521–532 + 115–134, Ramalho 95–116 | `crossbeam`/`dashmap`/`rayon` docs, `java.util.concurrent` package, Python `queue`/`heapq`/`bisect` docs |
| 8 | Custom collections & iterators | Blandy 348–357, Klabnik 285–290, Naftalin & Wadler Ch.7, Ramalho 397–430, Slatkin 257–264, Viafore 68–76 | `DoubleEndedIterator`/`FromIterator`/`Index` docs, `AbstractList` Javadoc, `collections.abc` docs |
| 9 | Performance & optimization | Matthews 219–231, Klabnik 290–294, Bloch Item 48, Evans 537–555, Gorelick 65–107 | Rust `std::collections` perf table, Shipilev JVM Anatomy Quarks, Python Wiki TimeComplexity |
| 10 | Capstone: cross-language synthesis | All previous sessions | Rust Design Patterns book, Dev.java streams tutorial, Python `itertools` docs |

# Layer 3 · Topic 9 — Collections & Iterators

> Comparative study of Rust, Java, and Python: standard collection types and their internal data structures, iterator protocols and lazy evaluation, functional combinators versus comprehensions, ownership semantics during iteration, and specialized/concurrent collections — the data structures and traversal patterns you use every day.

---

## 1. Sequence Collections: Vectors, Lists, Arrays

Every language needs a go-to ordered, indexable, growable container. Rust has `Vec<T>`, Java has `ArrayList<E>`, and Python has `list`. All three are dynamic arrays under the hood, but they differ fundamentally in memory layout, growth strategy, and type safety.

### Rust: `Vec<T>`, Arrays, Slices, `VecDeque`

Rust's `Vec<T>` is a heap-allocated, growable array that stores elements **inline** — a `Vec<i64>` is a contiguous block of `i64` values with no pointer indirection. Internally, a `Vec` is three fields: a pointer to the heap allocation, a `len` (number of elements), and a `capacity` (allocated slots).

```rust
let mut v: Vec<i32> = Vec::new();        // empty, capacity = 0
v.push(1);                                // allocates, capacity grows
v.push(2);
v.push(3);

let v2 = vec![10, 20, 30];               // macro shorthand

// Accessing elements
let third: &i32 = &v[2];                 // panics on out-of-bounds
let third: Option<&i32> = v.get(2);      // returns None on out-of-bounds

// Iteration
for val in &v {                           // borrows immutably: &i32
    println!("{val}");
}
```

When `len == capacity`, `Vec` reallocates — typically **doubling** the capacity. This gives amortized O(1) `push`. `Vec::with_capacity(n)` pre-allocates to avoid repeated resizing when the final size is known.

**Slices** (`&[T]` and `&mut [T]`) are fat pointers (pointer + length) that borrow a contiguous region of memory. They can refer to part of a `Vec`, an array, or another slice. Slices never own their data.

```rust
let arr: [i32; 5] = [1, 2, 3, 4, 5];    // fixed-size array on the stack
let slice: &[i32] = &arr[1..4];          // borrows [2, 3, 4]
let vec_slice: &[i32] = &v[..];          // slice of entire Vec
```

**`VecDeque<T>`** is a ring buffer — O(1) push/pop at **both** ends. It is the right choice when you need a FIFO queue or a double-ended queue. Elements are stored contiguously in a circular buffer but are not guaranteed to be in a single contiguous slice (use `make_contiguous()` if needed).

**`LinkedList<T>`** exists in the standard library but is almost never the right choice — poor cache locality and no O(1) random access. The `std::collections` documentation explicitly advises against it for most use cases.

### Java: `ArrayList`, `LinkedList`, Arrays, `SequencedCollection`

Java's `ArrayList<E>` is backed by an `Object[]` array. Unlike Rust's `Vec`, it stores **references** (pointers) to objects, not the objects themselves. For primitive types like `int`, autoboxing wraps them in `Integer` objects — each with a 16-byte object header.

```java
List<String> names = new ArrayList<>();
names.add("Alice");
names.add("Bob");
names.add("Charlie");

String second = names.get(1);             // "Bob"

// Iteration with enhanced for loop
for (String name : names) {
    System.out.println(name);
}

// Immutable list factory (Java 9+)
List<String> immutable = List.of("x", "y", "z");
```

`ArrayList` grows by **50%** when full (more memory-efficient than Rust's 2x, but more frequent reallocation). It provides O(1) random access and amortized O(1) append, but O(n) insertion at arbitrary positions.

**`LinkedList<E>`** implements both `List` and `Deque`. It is a doubly-linked list — O(1) add/remove at both ends, but O(n) random access and terrible cache locality. Rarely used in practice.

Java arrays are **covariant**: `String[]` is a subtype of `Object[]`. This enables runtime `ArrayStoreException` — a flaw that Bloch identifies as a reason to prefer lists over arrays (Item 28).

**Java 21** introduced the `SequencedCollection` interface (JEP 431), unifying `getFirst()`, `getLast()`, and `reversed()` across all ordered collections — `List`, `Deque`, `SortedSet`, `LinkedHashSet`, etc.

```java
SequencedCollection<String> seq = new ArrayList<>(List.of("a", "b", "c"));
String first = seq.getFirst();            // "a"
String last = seq.getLast();              // "c"
SequencedCollection<String> rev = seq.reversed();  // ["c", "b", "a"]
```

Generics use **type erasure**: `ArrayList<Integer>` and `ArrayList<String>` are the same class at runtime (unlike Rust's monomorphization, which generates distinct machine code for each type parameter).

### Python: `list`, `tuple`, `array.array`, `deque`

Python's `list` is a dynamic array of **`PyObject*` pointers** — every element is a reference to a heap-allocated Python object. Even integers are full objects with reference counts, type pointers, and the actual value.

```python
names = ["Alice", "Bob", "Charlie"]
names.append("Diana")

second = names[1]                         # "Bob"
subset = names[1:3]                       # ["Bob", "Charlie"] — new list

# List comprehension — the idiomatic way to create lists
squares = [x * x for x in range(10)]

# Iteration
for name in names:
    print(name)
```

Python's `list` growth factor is roughly **1.125x** for large lists (growth pattern: 0, 4, 8, 16, 24, 32, 40, 52, 64, ...) — more conservative than Rust or Java, resulting in less wasted space but more frequent reallocations.

**`tuple`** is an immutable, fixed-size sequence. CPython caches small tuples (length 0–20) for reuse. Tuples have no over-allocation — they use exactly the memory needed.

```python
point = (3.0, 4.0)                        # tuple as record
x, y = point                              # unpacking
```

**`array.array`** stores typed values compactly (like C arrays), but is rarely used because NumPy is preferred for numerical work.

**`collections.deque`** is a doubly-linked list of fixed-size blocks — O(1) append/pop at both ends, O(n) random access. It supports an optional `maxlen` for bounded buffers.

```python
from collections import deque
d = deque([1, 2, 3], maxlen=5)
d.appendleft(0)                           # [0, 1, 2, 3]
d.append(4)                               # [0, 1, 2, 3, 4]
```

### Cross-Language Comparison

| Aspect | Rust `Vec<i64>` | Java `ArrayList<Long>` | Python `list` of `int` |
|--------|-----------------|------------------------|------------------------|
| **Memory layout** | Values stored contiguously (inline) | Pointers to boxed `Long` objects | `PyObject*` pointers to `int` objects |
| **Bytes per element** | 8 | ~24 (16 header + 4 value + 4 align) | ~36 (28 for `int` + 8 for pointer) |
| **Growth factor** | ~2x | ~1.5x | ~1.125x |
| **Null/None elements** | No null; use `Vec<Option<T>>` | Allows `null` elements | Allows `None` elements |
| **Type safety** | Monomorphized at compile time | Erased at runtime | Untyped at runtime |
| **Immutable variant** | `&[T]` (slice) | `List.of()`, `List.copyOf()` | `tuple` |
| **Double-ended queue** | `VecDeque<T>` | `ArrayDeque<E>` | `collections.deque` |

---

## 2. Associative Collections: Maps, Dicts, Sets

Hash maps and sets are the workhorses of day-to-day programming. All three languages provide hash-based and (in Rust/Java) ordered/sorted variants, but the internal implementations, hashing strategies, and collision resolution differ significantly.

### Rust: `HashMap`, `BTreeMap`, `HashSet`, `BTreeSet`

Rust's `HashMap<K, V>` uses the `hashbrown` crate internally — a **SwissTable** implementation with SIMD-accelerated probing (open addressing). The default hasher is `SipHash-1-3`, which is DoS-resistant but not the fastest. For performance-critical code, you can substitute `FxHashMap` or `AHashMap`.

```rust
use std::collections::HashMap;

let mut scores: HashMap<String, i32> = HashMap::new();
scores.insert("Alice".to_string(), 95);
scores.insert("Bob".to_string(), 87);

// Entry API — avoids double lookup for insert-or-update
scores.entry("Charlie".to_string()).or_insert(0);
*scores.entry("Alice".to_string()).or_insert(0) += 5;  // Alice: 100

// Iteration (order is not guaranteed)
for (name, score) in &scores {
    println!("{name}: {score}");
}
```

Keys must implement `Eq + Hash`. If you derive `Hash`, you must also derive `PartialEq` and `Eq` — the contract is: if `a == b`, then `hash(a) == hash(b)`.

**`BTreeMap<K, V>`** uses a B-tree (not a red-black tree) — it stores multiple keys per node for better cache locality. It provides ordered iteration and range queries. Keys must implement `Ord`.

```rust
use std::collections::BTreeMap;

let mut map = BTreeMap::new();
map.insert(3, "c");
map.insert(1, "a");
map.insert(2, "b");

// Iteration is in sorted key order: 1, 2, 3
for (k, v) in &map {
    println!("{k}: {v}");
}

// Range queries
for (k, v) in map.range(1..=2) {
    println!("{k}: {v}");       // 1: a, 2: b
}
```

**`HashSet<T>`** and **`BTreeSet<T>`** are wrappers around the corresponding maps with `()` values. Set operations (`union`, `intersection`, `difference`, `symmetric_difference`) return lazy iterators.

```rust
use std::collections::HashSet;

let a: HashSet<i32> = [1, 2, 3].into_iter().collect();
let b: HashSet<i32> = [2, 3, 4].into_iter().collect();

let union: HashSet<_> = a.union(&b).copied().collect();          // {1, 2, 3, 4}
let intersection: HashSet<_> = a.intersection(&b).copied().collect(); // {2, 3}
```

### Java: `HashMap`, `TreeMap`, `LinkedHashMap`, `EnumMap`

Java's `HashMap<K, V>` uses an array of buckets with **separate chaining**. Since Java 8, when a bucket exceeds 8 entries, the linked list converts to a **balanced tree** (treeification) — this prevents O(n) worst-case lookup from adversarial hash collisions.

```java
Map<String, Integer> scores = new HashMap<>();
scores.put("Alice", 95);
scores.put("Bob", 87);

// computeIfAbsent — atomic insert-if-missing
scores.computeIfAbsent("Charlie", k -> 0);

// merge — atomic update-or-insert
scores.merge("Alice", 5, Integer::sum);   // Alice: 100

// Iteration (order not guaranteed)
for (Map.Entry<String, Integer> entry : scores.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// Immutable map (Java 9+)
Map<String, Integer> imm = Map.of("x", 1, "y", 2);
```

**`TreeMap<K, V>`** uses a **red-black tree** for O(log n) operations in sorted order. Keys must implement `Comparable` or a `Comparator` must be provided.

**`LinkedHashMap<K, V>`** maintains **insertion order** (or optionally access order, useful for LRU caches).

**`EnumMap<K extends Enum<K>, V>`** is backed by an array indexed by the enum's `ordinal()` — extremely fast and compact, no hashing needed. **`EnumSet`** uses a bit vector internally — set operations are single machine word AND/OR.

The `equals`/`hashCode` contract is critical: if `a.equals(b)` then `a.hashCode() == b.hashCode()`. Violating this breaks all hash-based collections.

### Python: `dict`, `set`, `frozenset`, `defaultdict`, `Counter`

Python's `dict` uses **open addressing** with a compact layout. Since Python 3.6, dicts preserve **insertion order** (formalized in 3.7). The hash table stores indices separately from key-value pairs for cache efficiency. Resize triggers when the table is 2/3 full.

```python
scores = {"Alice": 95, "Bob": 87}
scores["Charlie"] = 0

# Dict comprehension
squared = {x: x * x for x in range(5)}

# Merge operators (Python 3.9+)
merged = scores | {"Diana": 92}          # new dict
scores |= {"Alice": 100}                 # in-place update

# Iteration preserves insertion order
for name, score in scores.items():
    print(f"{name}: {score}")
```

Keys must be **hashable** (implement `__hash__` and `__eq__`). Mutable objects like `list` are unhashable. The contract mirrors Rust and Java: equal objects must have equal hashes.

**`collections.defaultdict`** calls a factory function for missing keys:

```python
from collections import defaultdict
word_counts = defaultdict(int)            # missing keys default to 0
for word in words:
    word_counts[word] += 1
```

**`Counter`** is a multiset — it counts hashable objects and supports arithmetic (`+`, `-`, `&`, `|`) and `most_common(n)`.

**`ChainMap`** chains multiple dicts for layered lookups (useful for variable scoping, template contexts).

**`OrderedDict`** preserves insertion order with additional features (e.g., `move_to_end()`), mostly superseded by regular `dict` since Python 3.7.

**`frozenset`** is an immutable, hashable set — it can be used as a dict key or set element.

**`set`** operations use standard mathematical notation:

```python
a = {1, 2, 3}
b = {2, 3, 4}
a | b    # union: {1, 2, 3, 4}
a & b    # intersection: {2, 3}
a - b    # difference: {1}
a ^ b    # symmetric difference: {1, 4}
```

### Hashing Contract Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Required traits/interfaces** | `Eq + Hash` | `equals()` + `hashCode()` | `__eq__` + `__hash__` |
| **Contract** | `a == b` → `hash(a) == hash(b)` | `a.equals(b)` → `a.hashCode() == b.hashCode()` | `a == b` → `hash(a) == hash(b)` |
| **Collision resolution** | Open addressing (SwissTable probing) | Separate chaining with treeification (Java 8+) | Open addressing (perturbation-based probing) |
| **Default hash function** | SipHash-1-3 (DoS-resistant) | `Object.hashCode()` (identity-based) | Type-dependent (ints hash to themselves) |
| **Sorted map** | `BTreeMap` (B-tree) | `TreeMap` (red-black tree) | No built-in (use `sortedcontainers` third-party) |
| **Enum-specialized** | None (use `HashMap` with enum keys) | `EnumSet` (bit vector), `EnumMap` (array) | None (use `dict` with enum keys) |

---

## 3. Iterator Protocols

The iterator protocol defines how a language traverses collections. All three languages use the "external iterator" pattern — the caller drives iteration — but the mechanisms differ: Rust uses traits and `Option`, Java uses interfaces and exceptions, Python uses dunder methods and `StopIteration`.

### Rust: `Iterator`, `IntoIterator`, and Three Iteration Modes

Rust's iterator system is built on two traits:

- **`Iterator`**: has one required method, `next(&mut self) -> Option<Self::Item>`. Returns `Some(value)` for each element, then `None` when exhausted. ~75 provided adaptor methods (all lazy).
- **`IntoIterator`**: has one method, `into_iter(self)`, returning an `Iterator`. Any type implementing `IntoIterator` can be used in a `for` loop.

The critical Rust-specific concept: **three ways to iterate** a collection:

```rust
let v = vec![1, 2, 3];

// 1. iter() — borrows immutably, yields &T
for val in v.iter() {           // val: &i32
    println!("{val}");
}

// 2. iter_mut() — borrows mutably, yields &mut T
let mut v = vec![1, 2, 3];
for val in v.iter_mut() {       // val: &mut i32
    *val *= 2;
}

// 3. into_iter() — consumes the collection, yields T
let v = vec![String::from("a"), String::from("b")];
for val in v.into_iter() {      // val: String (owned)
    println!("{val}");
}
// v is no longer accessible here — it was consumed
```

A `for` loop desugars to `IntoIterator::into_iter()` followed by repeated `Iterator::next()` calls:

```rust
// This:
for x in &collection { /* ... */ }

// Desugars to:
let mut iter = (&collection).into_iter();
loop {
    match iter.next() {
        Some(x) => { /* ... */ }
        None => break,
    }
}
```

`IntoIterator` is implemented for `&Vec<T>` (calls `iter()`), `&mut Vec<T>` (calls `iter_mut()`), and `Vec<T>` (calls `into_iter()`). This means `for x in &v` borrows, while `for x in v` consumes.

**`drain(range)`** removes elements from a collection and yields them as owned values — useful for transferring elements between collections without cloning.

### Java: `Iterable`, `Iterator`, `ListIterator`

Java separates the collection from its iterator through two interfaces:

- **`Iterable<T>`**: one method — `iterator()` returning an `Iterator<T>`.
- **`Iterator<E>`**: three methods — `hasNext()`, `next()`, and `remove()`.

```java
List<String> names = List.of("Alice", "Bob", "Charlie");

// Enhanced for loop desugars to iterator
for (String name : names) {
    System.out.println(name);
}

// Explicit iterator usage
Iterator<String> it = names.iterator();
while (it.hasNext()) {
    String name = it.next();
    System.out.println(name);
}
```

The enhanced `for` loop (`for (var x : collection)`) desugars to `iterator()` + `hasNext()`/`next()` calls (JLS 14.14.2).

**`ListIterator<E>`** extends `Iterator` with bidirectional traversal (`hasPrevious()`, `previous()`), plus `add()` and `set()` for modification during iteration.

Java iterators are **fail-fast**: modifying the collection during iteration (except through the iterator's own `remove()`) throws `ConcurrentModificationException`. This is detected via an internal modification counter — a runtime check, not a compile-time guarantee.

Key difference from Rust: Java's `Iterator` is a **separate object** from the collection. It does not own or borrow the collection — it just holds a cursor position. This means Java cannot prevent concurrent modification at compile time.

### Python: `__iter__`, `__next__`, and the Iterator Protocol

Python's iterator protocol uses two dunder methods:

- An **iterable** has `__iter__()` returning an iterator.
- An **iterator** has `__next__()` returning the next value or raising `StopIteration`.

```python
names = ["Alice", "Bob", "Charlie"]

# for loop desugars to iter() + next() + StopIteration handling
for name in names:
    print(name)

# Explicit iterator usage
it = iter(names)
print(next(it))    # "Alice"
print(next(it))    # "Bob"
print(next(it))    # "Charlie"
# next(it) would raise StopIteration
```

**Iterables vs iterators** are distinct: a `list` is an iterable (can produce multiple independent iterators); a file object is its own iterator (single-pass). Passing an iterator where an iterable is expected is a common bug — the iterator is exhausted after one pass.

The `iter()` built-in also has a two-argument sentinel form: `iter(callable, sentinel)` — calls the callable repeatedly until the sentinel value is returned.

```python
# Read lines until empty string
import functools
lines = list(iter(functools.partial(input, "Enter: "), ""))
```

### Protocol Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **"Give me an iterator"** | `IntoIterator::into_iter()` | `Iterable::iterator()` | `__iter__()` |
| **"Next element"** | `Iterator::next() -> Option<T>` | `Iterator::hasNext()` + `next()` | `__next__()` raises `StopIteration` |
| **End-of-iteration signal** | `None` (no exception) | `NoSuchElementException` if `next()` without `hasNext()` | `StopIteration` exception |
| **Compile-time safety** | Borrow checker prevents invalidation | None — runtime `ConcurrentModificationException` | None — runtime `RuntimeError` (dicts) or silent bugs (lists) |
| **Separate check needed?** | No — `Option<T>` combines check and value | Yes — `hasNext()` before `next()` | No — `StopIteration` handles both |
| **Modification during iteration** | Prevented by borrow checker | `ConcurrentModificationException` | `RuntimeError` for dicts; silent bugs for lists |

---

## 4. Lazy Evaluation: Rust Iterators, Java Streams, Python Generators

All three languages support lazy evaluation — deferring computation until results are actually needed — but through fundamentally different mechanisms.

### Rust: Iterator Adaptors Are Zero-Cost

Every Rust iterator adaptor returns a new iterator struct that wraps the previous one. No work happens until a consumer calls `next()`.

```rust
let v = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// This builds a nested struct: Filter<Map<Iter<i32>>>
// No computation happens yet
let pipeline = v.iter()
    .map(|x| x * x)
    .filter(|x| x % 2 == 0);

// Only now does computation happen, driven by collect()
let result: Vec<i32> = pipeline.collect();  // [4, 16, 36, 64, 100]
```

The compiler inlines the entire chain, producing code as fast as a hand-written loop — this is the **zero-cost abstraction** principle. The type `Filter<Map<Iter<'_, i32>>>` is never allocated on the heap; it lives on the stack.

Key adaptors:

```rust
let v = vec![1, 2, 3, 4, 5];

v.iter().map(|x| x * 2);                     // transform each element
v.iter().filter(|&&x| x > 2);                // keep elements matching predicate
v.iter().chain([6, 7].iter());                // concatenate two iterators
v.iter().zip(v.iter().rev());                 // pair elements: (1,5), (2,4), ...
v.iter().enumerate();                         // add index: (0,1), (1,2), ...
v.iter().take(3);                             // first 3 elements
v.iter().skip(2);                             // skip first 2 elements
v.iter().peekable();                          // allow peeking at next without consuming
v.iter().flat_map(|x| vec![*x, x * 10]);     // map and flatten
v.iter().cloned();                            // clone each &T to T
v.iter().cycle();                             // repeat infinitely
```

Key consumers:

```rust
v.iter().count();                             // number of elements
v.iter().sum::<i32>();                        // sum all elements
v.iter().product::<i32>();                    // multiply all elements
v.iter().fold(0, |acc, x| acc + x);          // general reduction
v.iter().collect::<Vec<_>>();                 // build a collection
v.iter().any(|x| *x > 3);                    // true if any matches
v.iter().all(|x| *x > 0);                    // true if all match
v.iter().find(|&&x| x > 3);                  // first matching element
v.iter().position(|&x| x > 3);              // index of first match
v.iter().partition::<Vec<_>, _>(|&&x| x > 3); // split into two collections
```

`collect()` is the most versatile consumer — it uses the `FromIterator` trait and can build `Vec`, `HashMap`, `HashSet`, `String`, `BTreeMap`, and any type implementing `FromIterator`. The turbofish syntax (`collect::<Vec<_>>()`) or a type annotation tells `collect` what to build.

Unlike Java streams, Rust iterator adaptor chains are **reusable types** — you can store them in variables and pass them around (though each iterator instance is single-pass).

### Java: Streams as Lazy Pipelines

Java streams are a **separate abstraction** from collections. You create a stream, apply intermediate operations (lazy), and terminate with a terminal operation (eager). Streams are **single-use**: after a terminal operation, the stream is consumed.

```java
List<String> names = List.of("Alice", "Bob", "Charlie", "Diana");

List<String> result = names.stream()          // create stream
    .filter(n -> n.length() > 3)              // intermediate (lazy)
    .map(String::toUpperCase)                 // intermediate (lazy)
    .sorted()                                 // intermediate (lazy, stateful)
    .collect(Collectors.toList());            // terminal (eager)
// result: ["ALICE", "CHARLIE", "DIANA"]
```

**Intermediate operations** (lazy): `filter`, `map`, `flatMap`, `sorted`, `distinct`, `limit`, `skip`, `peek`.

**Terminal operations** (eager): `collect`, `forEach`, `reduce`, `count`, `findFirst`, `findAny`, `anyMatch`, `allMatch`, `noneMatch`, `min`, `max`, `toArray`.

Streams can be **parallelized** with `.parallelStream()` or `.parallel()`:

```java
long count = names.parallelStream()
    .filter(n -> n.length() > 3)
    .count();
```

This uses the common `ForkJoinPool`. Bloch warns (Item 48): parallel streams can cause bugs or slowdowns if used carelessly — they are effective only for large, CPU-bound, splittable workloads.

`Collectors` provides a rich terminal vocabulary:

```java
// Group by length
Map<Integer, List<String>> byLength = names.stream()
    .collect(Collectors.groupingBy(String::length));

// Partition into two groups
Map<Boolean, List<String>> partitioned = names.stream()
    .collect(Collectors.partitioningBy(n -> n.length() > 3));

// Downstream collectors compose
Map<Integer, Long> countByLength = names.stream()
    .collect(Collectors.groupingBy(String::length, Collectors.counting()));
```

**`Optional<T>`** replaces null returns in stream operations — `findFirst()`, `findAny()`, `min()`, `max()` all return `Optional`.

**Primitive streams** (`IntStream`, `LongStream`, `DoubleStream`) avoid boxing overhead:

```java
int sum = IntStream.rangeClosed(1, 100).sum();           // 5050
OptionalDouble avg = IntStream.of(1, 2, 3).average();    // 2.0
```

### Python: Generators and Generator Expressions

A Python function containing `yield` becomes a **generator function** — calling it returns a generator object (a lazy iterator). Each `yield` suspends the function, preserving its local state on the stack frame.

```python
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

# Take first 10 Fibonacci numbers
from itertools import islice
fibs = list(islice(fibonacci(), 10))      # [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

**Generator expressions** are the lazy equivalent of list comprehensions:

```python
# List comprehension — materializes entire list in memory
squares_list = [x * x for x in range(1_000_000)]

# Generator expression — computes one value at a time, O(1) memory
squares_gen = (x * x for x in range(1_000_000))
total = sum(squares_gen)                   # no intermediate list
```

**`yield from`** delegates to a sub-generator, flattening nested iteration:

```python
def flatten(nested):
    for sublist in nested:
        yield from sublist

list(flatten([[1, 2], [3, 4], [5]]))      # [1, 2, 3, 4, 5]
```

Generators are **single-use** — once exhausted, they cannot be restarted.

The **`itertools`** module provides composable lazy building blocks:

```python
from itertools import chain, islice, takewhile, dropwhile, groupby
from itertools import product, permutations, combinations, starmap, tee

# chain — concatenate iterables
list(chain([1, 2], [3, 4]))               # [1, 2, 3, 4]

# islice — lazy slicing
list(islice(range(100), 5, 10))           # [5, 6, 7, 8, 9]

# takewhile / dropwhile
list(takewhile(lambda x: x < 5, [1, 3, 5, 2]))  # [1, 3]

# groupby (requires sorted input)
data = sorted(["apple", "banana", "avocado", "cherry"], key=lambda x: x[0])
for key, group in groupby(data, key=lambda x: x[0]):
    print(key, list(group))
```

### Laziness Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Mechanism** | Struct composition (`Filter<Map<Iter>>`) | Pipeline object (records operations) | Suspended stack frame (`yield`) |
| **Type** | Each chain has a unique type (static dispatch) | `Stream<T>` (dynamic dispatch to lambdas) | `generator` object |
| **Reusable?** | Type is reusable, each instance is single-pass | Single-use (stream consumed after terminal op) | Single-use (exhausted after iteration) |
| **Parallelism** | External: `rayon` crate (`par_iter()`) | Built-in: `.parallel()` / `.parallelStream()` | External: `multiprocessing`, `concurrent.futures` |
| **Overhead** | Zero-cost (inlined by compiler) | Lambda + stream object allocation (JIT can optimize) | Interpreter overhead (stack frame suspension) |
| **Pull/push** | Pull-based (caller drives `next()`) | Can be push-based internally (`Spliterator`) | Pull-based (caller drives `next()`) |

---

## 5. Functional Combinators: map/filter/fold vs Streams vs Comprehensions

Each language has an idiomatic style for transforming, filtering, and reducing collections. Rust uses iterator method chains, Java uses the Stream API, and Python prefers comprehensions.

### Rust: Closures and Iterator Chains

Rust closures are anonymous structs implementing `Fn`, `FnMut`, or `FnOnce` traits. The compiler infers which variant based on how captured variables are used.

```rust
// Transform + filter + collect
let names = vec!["Alice", "Bob", "Charlie", "Diana"];
let long_upper: Vec<String> = names.iter()
    .filter(|n| n.len() > 3)
    .map(|n| n.to_uppercase())
    .collect();
// ["ALICE", "CHARLIE", "DIANA"]

// Group and count
use std::collections::HashMap;
let words = vec!["apple", "banana", "apple", "cherry", "banana", "apple"];
let counts: HashMap<&&str, usize> = words.iter()
    .fold(HashMap::new(), |mut acc, word| {
        *acc.entry(word).or_insert(0) += 1;
        acc
    });

// Find maximum by derived key
let longest = names.iter().max_by_key(|n| n.len());  // Some("Charlie")
```

`fold` is the most general consumer — `sum`, `product`, `count` are specializations. `collect()` with turbofish can build any `FromIterator` type.

### Java: Stream API and Collectors

```java
List<String> names = List.of("Alice", "Bob", "Charlie", "Diana");

// Transform + filter + collect
List<String> longUpper = names.stream()
    .filter(n -> n.length() > 3)
    .map(String::toUpperCase)
    .collect(Collectors.toList());
// ["ALICE", "CHARLIE", "DIANA"]

// Group and count
Map<String, Long> counts = words.stream()
    .collect(Collectors.groupingBy(w -> w, Collectors.counting()));

// Find maximum by derived key
Optional<String> longest = names.stream()
    .max(Comparator.comparingInt(String::length));   // Optional["Charlie"]
```

`Collectors` composition enables complex aggregations:

```java
// Group by first letter, collect names into sorted list
Map<Character, List<String>> byLetter = names.stream()
    .collect(Collectors.groupingBy(
        n -> n.charAt(0),
        Collectors.collectingAndThen(Collectors.toList(), list -> {
            list.sort(Comparator.naturalOrder());
            return list;
        })
    ));
```

### Python: Comprehensions and Built-in Functionals

Python's idiomatic style strongly prefers comprehensions over `map`/`filter`:

```python
names = ["Alice", "Bob", "Charlie", "Diana"]

# Transform + filter (comprehension — preferred)
long_upper = [n.upper() for n in names if len(n) > 3]
# ["ALICE", "CHARLIE", "DIANA"]

# Equivalent with map/filter (less idiomatic)
long_upper = list(map(str.upper, filter(lambda n: len(n) > 3, names)))

# Group and count
from collections import Counter
counts = Counter(words)                   # Counter({'apple': 3, 'banana': 2, 'cherry': 1})

# Find maximum by derived key
longest = max(names, key=len)             # "Charlie"

# Dict comprehension
name_lengths = {n: len(n) for n in names}

# Set comprehension
first_letters = {n[0] for n in names}    # {'A', 'B', 'C', 'D'}
```

Generator expressions integrate seamlessly with aggregation functions:

```python
# Sum of squares — no intermediate list
total = sum(x * x for x in range(1000))

# Any/all for short-circuit evaluation
has_long = any(len(n) > 5 for n in names)     # True (Charlie)
all_long = all(len(n) > 2 for n in names)     # True
```

`functools.reduce` is Python's fold, but is considered less idiomatic than explicit loops or built-ins:

```python
from functools import reduce
product = reduce(lambda a, b: a * b, [1, 2, 3, 4, 5])  # 120
```

The **walrus operator** (`:=`, Python 3.8+) enables assignment inside comprehensions:

```python
# Filter and transform, reusing intermediate value
results = [upper for n in names if len(upper := n.upper()) > 3]
```

**PEP 709** (Python 3.12+) inlines comprehension scoping — comprehensions no longer create a new stack frame, giving a performance boost.

### Idiom Comparison: Same Problem, Three Styles

**Problem:** Filter strings longer than 3 characters, uppercase them, sort, and collect.

```rust
// Rust: iterator chain
let result: Vec<String> = names.iter()
    .filter(|n| n.len() > 3)
    .map(|n| n.to_uppercase())
    .sorted()    // from itertools crate, or collect + sort
    .collect();
```

```java
// Java: stream pipeline
List<String> result = names.stream()
    .filter(n -> n.length() > 3)
    .map(String::toUpperCase)
    .sorted()
    .collect(Collectors.toList());
```

```python
# Python: comprehension + sorted
result = sorted(n.upper() for n in names if len(n) > 3)
```

Python is the most concise. Java is the most explicitly typed and self-documenting. Rust strikes a balance — concise with type inference but explicit about ownership.

---

## 6. Ownership in Collections: Borrow, Consume, Drain

How does each language handle the interaction between ownership/mutability and iteration? Rust enforces safety at compile time, Java detects violations at runtime, and Python provides minimal protection.

### Rust: The Borrow Checker Prevents Iterator Invalidation

Rust's borrow checker guarantees at compile time that you cannot modify a collection while iterating over it:

```rust
let mut v = vec![1, 2, 3, 4, 5];

// This will NOT compile — immutable borrow (iter) conflicts with mutable borrow (push)
// for x in &v {
//     v.push(*x * 2);  // ERROR: cannot borrow `v` as mutable
// }

// Solution 1: collect results first, then extend
let doubled: Vec<i32> = v.iter().map(|x| x * 2).collect();
v.extend(doubled);

// Solution 2: use drain to transfer elements
let mut v1 = vec![1, 2, 3];
let mut v2 = Vec::new();
v2.extend(v1.drain(..));   // v1 is now empty, v2 has [1, 2, 3]
```

**`drain(range)`** removes elements and yields them as owned values — no cloning needed:

```rust
let mut v = vec![10, 20, 30, 40, 50];
let middle: Vec<i32> = v.drain(1..4).collect();  // middle = [20, 30, 40]
// v is now [10, 50]
```

**`retain`** filters a collection in place:

```rust
let mut v = vec![1, 2, 3, 4, 5];
v.retain(|&x| x % 2 == 0);               // v = [2, 4]
```

The **Entry API** avoids the "check-then-insert" double lookup:

```rust
use std::collections::HashMap;

let mut map = HashMap::new();
// Without Entry: two lookups
if !map.contains_key("key") {
    map.insert("key", vec![]);
}
map.get_mut("key").unwrap().push(1);

// With Entry: one lookup
map.entry("key").or_insert_with(Vec::new).push(1);
```

**`Cow<T>`** (clone-on-write) defers cloning until mutation is needed — useful when you sometimes need to modify borrowed data but often can return it unchanged:

```rust
use std::borrow::Cow;

fn process(input: &str) -> Cow<str> {
    if input.contains(' ') {
        Cow::Owned(input.replace(' ', "_"))   // allocates only when needed
    } else {
        Cow::Borrowed(input)                  // no allocation
    }
}
```

### Java: ConcurrentModificationException and Defensive Copies

Java's fail-fast iterators detect modification via an internal modification counter:

```java
List<String> names = new ArrayList<>(List.of("Alice", "Bob", "Charlie"));

// This throws ConcurrentModificationException
// for (String name : names) {
//     if (name.equals("Bob")) {
//         names.remove(name);  // modifies collection during iteration
//     }
// }

// Solution 1: use Iterator.remove()
Iterator<String> it = names.iterator();
while (it.hasNext()) {
    if (it.next().equals("Bob")) {
        it.remove();            // safe removal through iterator
    }
}

// Solution 2: use removeIf (Java 8+)
names.removeIf(n -> n.equals("Bob"));
```

**Immutable collections** prevent modification entirely:

```java
// Unmodifiable view (Java 2+) — backed by original, throws on modification
List<String> view = Collections.unmodifiableList(names);

// Truly immutable copy (Java 10+) — independent of original
List<String> copy = List.copyOf(names);

// Factory methods (Java 9+) — structurally immutable
List<String> imm = List.of("a", "b", "c");
```

All unmodifiable collections throw `UnsupportedOperationException` on mutation attempts.

Stream operations must be **side-effect-free** — the pipeline should not modify the underlying collection.

### Python: Mutation During Iteration

Python provides minimal protection. Modifying a `dict` during iteration raises `RuntimeError`, but modifying a `list` during iteration silently produces wrong results:

```python
# Dict: RuntimeError
d = {"a": 1, "b": 2}
# for k in d:
#     d["c"] = 3   # RuntimeError: dictionary changed size during iteration

# List: silent bug — elements are skipped
nums = [1, 2, 3, 4, 5]
for x in nums:
    if x % 2 == 0:
        nums.remove(x)
# nums is [1, 3, 5]? No — nums is [1, 3, 5] only by luck.
# The actual behavior depends on implementation details.

# Solution: iterate over a copy
for x in list(nums):               # list() creates a copy
    if x % 2 == 0:
        nums.remove(x)

# Better solution: build a new list
nums = [x for x in nums if x % 2 != 0]
```

**Shallow vs deep copy:**

```python
import copy
original = [[1, 2], [3, 4]]
shallow = copy.copy(original)      # new list, same inner lists
deep = copy.deepcopy(original)     # new list, new inner lists
```

`tuple` and `frozenset` are immutable — they guarantee no mutation, but only at the top level (a tuple of lists can have its lists mutated).

### Ownership Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Iterator invalidation prevention** | Compile-time (borrow checker) | Runtime (`ConcurrentModificationException`) | Partial runtime (dicts throw; lists don't) |
| **Cost of prevention** | Zero runtime cost | Modification counter check per operation | Varies |
| **In-place filtering** | `retain()` | `removeIf()` | Comprehension reassignment |
| **Transfer elements** | `drain()` | `Iterator.remove()` + manual | `pop()` loop or comprehension |
| **Immutable collections** | `&[T]` (slice borrow) | `List.of()`, `List.copyOf()`, `Collections.unmodifiable*` | `tuple`, `frozenset` |
| **Clone-on-write** | `Cow<T>` | No built-in equivalent | No built-in equivalent |

---

## 7. Specialized and Concurrent Collections

Beyond the standard map/list/set, each language provides (or delegates to the ecosystem) specialized collections for priority queues, concurrent access, and enum-optimized storage.

### Rust: `BinaryHeap`, B-Tree Collections, and Crate Ecosystem

**`BinaryHeap<T>`** is a max-heap. For a min-heap, use `std::cmp::Reverse`:

```rust
use std::collections::BinaryHeap;
use std::cmp::Reverse;

// Max-heap (default)
let mut max_heap = BinaryHeap::new();
max_heap.push(3);
max_heap.push(1);
max_heap.push(4);
assert_eq!(max_heap.pop(), Some(4));  // largest first

// Min-heap (using Reverse wrapper)
let mut min_heap = BinaryHeap::new();
min_heap.push(Reverse(3));
min_heap.push(Reverse(1));
min_heap.push(Reverse(4));
assert_eq!(min_heap.pop(), Some(Reverse(1)));  // smallest first
```

**`BTreeMap`/`BTreeSet`** provide ordered iteration and efficient range queries — use them when you need sorted keys or range scans:

```rust
use std::collections::BTreeMap;
let mut map = BTreeMap::new();
map.insert("banana", 2);
map.insert("apple", 5);
map.insert("cherry", 1);

// Range query
for (k, v) in map.range("apple"..="cherry") {
    println!("{k}: {v}");
}
```

Rust's standard library **deliberately excludes** concurrent collections — this is delegated to the crate ecosystem. The `Send`/`Sync` marker traits ensure that non-thread-safe collections cannot be shared across threads.

- **`dashmap`**: concurrent `HashMap` using sharded locking.
- **`crossbeam`**: lock-free queues, deques, and epoch-based memory reclamation.
- **`rayon`**: parallel iterators (`par_iter()`) that automatically split work across threads.

```rust
// rayon example — parallel iteration
use rayon::prelude::*;

let sum: i32 = (0..1_000_000)
    .into_par_iter()
    .map(|x| x * x)
    .sum();
```

### Java: `ConcurrentHashMap`, Blocking Queues, `EnumSet`/`EnumMap`

Java has a rich `java.util.concurrent` package:

**`ConcurrentHashMap`** uses segmented (striped) locking — concurrent reads require no locking, writes lock only the affected segment. It supports atomic compound operations:

```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
map.computeIfAbsent("key", k -> expensiveComputation());
map.merge("key", 1, Integer::sum);        // atomic increment
```

**`CopyOnWriteArrayList`** is optimized for read-heavy, write-rare workloads — every write creates a new internal array copy. Iteration never throws `ConcurrentModificationException`.

**`BlockingQueue`** implementations are the backbone of producer-consumer patterns:

```java
BlockingQueue<String> queue = new LinkedBlockingQueue<>(100);
queue.put("task");                         // blocks if full
String task = queue.take();                // blocks if empty
```

Implementations: `ArrayBlockingQueue` (bounded), `LinkedBlockingQueue` (optionally bounded), `PriorityBlockingQueue` (priority ordering).

**`PriorityQueue`** is a min-heap:

```java
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.offer(3);
pq.offer(1);
pq.offer(4);
pq.poll();                                // 1 (smallest first)
```

**`EnumSet`** uses a bit vector internally — set operations are single machine word AND/OR. **`EnumMap`** uses an array indexed by enum ordinal — no hashing overhead.

```java
enum Day { MON, TUE, WED, THU, FRI, SAT, SUN }

EnumSet<Day> weekend = EnumSet.of(Day.SAT, Day.SUN);
EnumSet<Day> weekdays = EnumSet.complementOf(weekend);

EnumMap<Day, String> schedule = new EnumMap<>(Day.class);
schedule.put(Day.MON, "meeting");
```

**`ConcurrentSkipListMap`** is a concurrent sorted map based on skip lists — the concurrent equivalent of `TreeMap`.

### Python: `heapq`, `bisect`, `queue.Queue`, `collections` Specialties

Python has no built-in concurrent dict. The GIL makes many dict operations effectively atomic in CPython, but this is an implementation detail, not a guarantee.

**`heapq`** provides heap operations on a plain `list` (not a separate type):

```python
import heapq

heap = []
heapq.heappush(heap, 3)
heapq.heappush(heap, 1)
heapq.heappush(heap, 4)
smallest = heapq.heappop(heap)            # 1

# Find N largest/smallest efficiently
top3 = heapq.nlargest(3, data)
bottom3 = heapq.nsmallest(3, data)
```

**`bisect`** provides binary search for sorted lists:

```python
import bisect

sorted_list = [1, 3, 5, 7, 9]
bisect.insort(sorted_list, 4)             # [1, 3, 4, 5, 7, 9]
idx = bisect.bisect_left(sorted_list, 5)  # 3 (index where 5 is)
```

**`queue.Queue`** is thread-safe (uses locks internally) for producer-consumer patterns:

```python
from queue import Queue, PriorityQueue

q = Queue(maxsize=100)
q.put("task")                             # blocks if full
task = q.get()                            # blocks if empty

pq = PriorityQueue()
pq.put((2, "low"))
pq.put((1, "high"))
pq.get()                                  # (1, "high")
```

**`Counter`** supports multiset arithmetic:

```python
from collections import Counter
a = Counter("aabbc")
b = Counter("abbcc")
a + b    # Counter({'b': 4, 'a': 3, 'c': 3})
a & b    # Counter({'b': 2, 'a': 1, 'c': 1})  — intersection (min)
a | b    # Counter({'b': 3, 'a': 2, 'c': 2})  — union (max)
```

**`ChainMap`** enables layered lookup (useful for variable scoping):

```python
from collections import ChainMap
defaults = {"color": "red", "size": "medium"}
overrides = {"color": "blue"}
config = ChainMap(overrides, defaults)
config["color"]     # "blue" (from overrides)
config["size"]      # "medium" (from defaults)
```

### Specialized Collections Comparison

| Type | Rust | Java | Python |
|------|------|------|--------|
| **Priority queue** | `BinaryHeap` (max-heap) | `PriorityQueue` (min-heap) | `heapq` (min-heap, functions on list) |
| **Concurrent hash map** | `dashmap` (crate) | `ConcurrentHashMap` | `dict` + GIL (informal) |
| **Blocking queue** | `crossbeam` channels | `BlockingQueue` implementations | `queue.Queue` |
| **Concurrent sorted map** | `crossbeam-skiplist` (crate) | `ConcurrentSkipListMap` | No built-in |
| **Enum-optimized** | None built-in | `EnumSet` (bit vector), `EnumMap` (array) | None built-in |
| **Thread safety guarantee** | `Send`/`Sync` traits (compile-time) | `java.util.concurrent` contracts | GIL (CPython implementation detail) |
| **Sorted list maintenance** | N/A (use `BTreeSet`) | N/A (use `TreeSet`) | `bisect.insort` |

---

## 8. Custom Collections and Iterator Implementations

Each language provides mechanisms to create custom collection types that integrate with the language's iteration infrastructure.

### Rust: Implementing `Iterator`, `IntoIterator`, `FromIterator`

To make a custom type iterable, you need a separate iterator struct and implement `Iterator` on it, then implement `IntoIterator` on the collection:

```rust
struct Counter {
    start: u32,
    end: u32,
}

struct CounterIter {
    current: u32,
    end: u32,
}

impl Counter {
    fn new(start: u32, end: u32) -> Self {
        Counter { start, end }
    }
}

// IntoIterator enables `for x in counter { ... }`
impl IntoIterator for Counter {
    type Item = u32;
    type IntoIter = CounterIter;

    fn into_iter(self) -> CounterIter {
        CounterIter { current: self.start, end: self.end }
    }
}

// Iterator produces the actual values
impl Iterator for CounterIter {
    type Item = u32;

    fn next(&mut self) -> Option<u32> {
        if self.current < self.end {
            let val = self.current;
            self.current += 1;
            Some(val)
        } else {
            None
        }
    }
}

// Usage
for x in Counter::new(1, 5) {
    println!("{x}");                      // 1, 2, 3, 4
}

// Works with all iterator adaptors
let sum: u32 = Counter::new(1, 101).into_iter().sum();  // 5050
```

For full integration, implement additional traits:

- **`DoubleEndedIterator`**: enables `rev()` and `next_back()`.
- **`ExactSizeIterator`**: enables `len()` on iterators, and helps `collect()` pre-allocate.
- **`FromIterator`**: enables `collect()` into your custom type.
- **`Index`/`IndexMut`**: enables `collection[index]` syntax.

A common pattern: implement `IntoIterator` for `&MyCollection` (yields `&T`), `&mut MyCollection` (yields `&mut T`), and `MyCollection` (yields `T`) — mirroring how standard collections work.

### Java: Skeletal Implementations and `Iterable`

Java's skeletal implementations (`AbstractList`, `AbstractSet`, `AbstractMap`) minimize the work for custom collections:

```java
public class Range implements Iterable<Integer> {
    private final int start;
    private final int end;

    public Range(int start, int end) {
        this.start = start;
        this.end = end;
    }

    @Override
    public Iterator<Integer> iterator() {
        return new Iterator<>() {
            private int current = start;

            @Override
            public boolean hasNext() {
                return current < end;
            }

            @Override
            public Integer next() {
                if (!hasNext()) throw new NoSuchElementException();
                return current++;
            }
        };
    }
}

// Usage — works with enhanced for loop
for (int x : new Range(1, 5)) {
    System.out.println(x);               // 1, 2, 3, 4
}

// Works with streams
int sum = StreamSupport.stream(new Range(1, 101).spliterator(), false)
    .mapToInt(Integer::intValue)
    .sum();                               // 5050
```

For `AbstractList`, implement `get(int)` and `size()` for a read-only list; add `set(int, E)` for mutability; add `add(int, E)` and `remove(int)` for full mutability. For `AbstractMap`, implement `entrySet()`.

Implementing `Spliterator` (for parallel stream support) requires `tryAdvance()` and `trySplit()`.

### Python: `collections.abc` and Container Emulation

Python's `collections.abc` provides abstract base classes with mixin methods:

```python
from collections.abc import Sequence

class Range:
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def __iter__(self):
        current = self.start
        while current < self.end:
            yield current
            current += 1

    def __len__(self):
        return max(0, self.end - self.start)

    def __contains__(self, value):
        return isinstance(value, int) and self.start <= value < self.end

    def __getitem__(self, index):
        if index < 0:
            index += len(self)
        if 0 <= index < len(self):
            return self.start + index
        raise IndexError("index out of range")

# Usage
r = Range(1, 5)
for x in r:
    print(x)                              # 1, 2, 3, 4

print(3 in r)                             # True
print(len(r))                             # 4
print(r[2])                               # 3
print(sum(r))                             # 10
```

Inheriting from `collections.abc` ABCs provides mixin methods for free:

- `Sequence` (`__getitem__` + `__len__`) gives you `__contains__`, `__iter__`, `__reversed__`, `index`, `count`.
- `MutableSequence` adds `__setitem__`, `__delitem__`, `insert`.
- `Mapping` (`__getitem__` + `__len__` + `__iter__`) gives you `__contains__`, `keys`, `items`, `values`, `get`, `__eq__`, `__ne__`.

**`UserDict`**, **`UserList`**, **`UserString`** are recommended over subclassing `dict`/`list`/`str` — built-ins sometimes bypass custom `__getitem__`/`__setitem__` in C-level code.

### Custom Collection Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Minimal iterable** | `impl IntoIterator` | `implements Iterable<T>` | `__iter__()` method |
| **Iterator state** | Separate struct (borrow rules enforce it) | Separate class (interface design) | Can use generator (`yield`), or separate class |
| **Skeletal helpers** | None needed (traits are composable) | `AbstractList`, `AbstractMap`, `AbstractSet` | `collections.abc` ABCs with mixins |
| **Indexing support** | `impl Index<usize>` | `get(int)` in `List` | `__getitem__` |
| **Parallel iteration** | `impl rayon::ParallelIterator` | `impl Spliterator` | No standard equivalent |
| **Custom `collect`** | `impl FromIterator` | N/A (use `Collectors.toCollection`) | N/A (use constructor from iterable) |

---

## 9. Performance Characteristics and Optimization

Understanding time complexity, memory layout, and constant factors is essential for choosing the right collection and writing efficient code.

### Time Complexity Summary

| Operation | `Vec`/`ArrayList`/`list` | `VecDeque`/`ArrayDeque`/`deque` | `HashMap`/`HashMap`/`dict` | `BTreeMap`/`TreeMap`/— | `BinaryHeap`/`PriorityQueue`/`heapq` |
|-----------|--------------------------|----------------------------------|----------------------------|-----------------------|--------------------------------------|
| **Append (back)** | O(1) amortized | O(1) amortized | — | — | O(log n) |
| **Prepend (front)** | O(n) | O(1) amortized | — | — | — |
| **Random access** | O(1) | O(1) | — | — | — |
| **Search (unsorted)** | O(n) | O(n) | — | — | — |
| **Insert/remove at index** | O(n) | O(n) | — | — | — |
| **Lookup by key** | — | — | O(1) average | O(log n) | — |
| **Insert by key** | — | — | O(1) average | O(log n) | — |
| **Delete by key** | — | — | O(1) average | O(log n) | — |
| **Pop min/max** | — | — | — | O(log n) | O(log n) |
| **Iteration (all)** | O(n) | O(n) | O(n) | O(n) | O(n log n) sorted |

### Rust: Zero-Cost Iteration and Inline Storage

Rust iterators compile to the same machine code as hand-written loops. The `Filter<Map<Iter<T>>>` struct chain is fully inlined and optimized away by the compiler.

Key optimizations:

- **`Vec::with_capacity(n)`** avoids reallocations when size is known.
- **`extend()`** is faster than repeated `push()` — it bulk-allocates using `size_hint()`.
- **`collect()`** uses `ExactSizeIterator::size_hint()` to pre-allocate the destination.
- **Inline storage**: `Vec<u64>` is a contiguous array of `u64` values — no pointer indirection, optimal cache locality.
- **`drain()` + `extend()`** is faster than clone-and-filter.
- **`BTreeMap`** has better cache locality than pointer-heavy trees because B-tree nodes store multiple keys per node.

```rust
// Pre-allocate when size is known
let mut v = Vec::with_capacity(1000);
for i in 0..1000 {
    v.push(i);  // no reallocation
}

// extend is faster than repeated push
let mut v = Vec::new();
v.extend(0..1000);  // single allocation + bulk copy
```

### Java: Boxing Overhead and JIT Optimization

Java's biggest performance issue with collections is **autoboxing** — `ArrayList<Integer>` stores boxed `Integer` objects:

| Storage | Bytes per `int` |
|---------|----------------|
| Primitive `int[]` | 4 |
| `ArrayList<Integer>` | ~24 (16 header + 4 value + 4 alignment) |
| `IntStream` operations | 4 (primitive) |

Primitive streams (`IntStream`, `LongStream`, `DoubleStream`) avoid boxing with `mapToInt()`, `sum()`, `average()`.

JIT optimization can **eliminate iterator object allocation** via escape analysis — if the iterator never escapes the loop, it is allocated on the stack or eliminated entirely.

**`HashMap`**'s load factor is 0.75 — resize triggers when 75% full. `ArrayList`'s growth factor is 1.5x.

Parallel streams are effective only for **large datasets** (>10K elements) with CPU-bound operations. I/O-bound or small collections are slower with parallelism due to ForkJoinPool overhead.

### Python: CPython Internals and Memory Efficiency

Python objects carry significant overhead — every `int` is a full Python object:

| Type | Bytes per element (approximate) |
|------|-------------------------------|
| `list` of `int` | ~36 (28 for `int` object + 8 for pointer) |
| `array.array('q')` | 8 (C `long long`, no Python object) |
| `tuple` of `int` | ~36 (same as list, but no over-allocation) |
| NumPy `int64` array | 8 (C `int64_t`, no Python object) |

Key performance facts:

- **`list`** over-allocates by ~12.5% for large lists (growth pattern: 0, 4, 8, 16, 24, 32, 40, 52, 64, ...).
- **`tuple`** has no over-allocation and CPython caches small tuples (length 0–20).
- **`dict`** resizes at 2/3 load — hash table size is always a power of 2.
- **Generator expressions** use O(1) memory vs list comprehension O(n) — critical for large datasets.
- **`sorted()`** uses TimSort — O(n log n) worst case, O(n) for partially sorted data.
- **`set`** operations (`intersection`, `union`) are faster than manual loops.
- Use `dict` or `set` (O(1) lookup) instead of `list` (O(n) linear scan) for membership testing.

```python
# Bad: O(n) membership test
if item in large_list:  # linear scan
    pass

# Good: O(1) membership test
large_set = set(large_list)
if item in large_set:   # hash lookup
    pass
```

### Memory Per Element Comparison

| Collection | Rust | Java | Python |
|------------|------|------|--------|
| **Dynamic array of 64-bit integers** | 8 bytes/elem (`Vec<i64>`) | ~24 bytes/elem (`ArrayList<Long>`) | ~36 bytes/elem (`list` of `int`) |
| **Hash map (key + value)** | Key+Value inline (SwissTable) | Key+Value boxed + Entry object | Key+Value as `PyObject*` pointers |
| **Iterator overhead** | Zero (inlined structs) | Object allocation (JIT may eliminate) | Generator stack frame |

### Qualitative Performance Differences

- **Rust** is predictable — no GC pauses, no JIT warmup, inline storage, zero-cost iteration.
- **Java** is fast after warmup — JIT optimizes hot paths, escape analysis eliminates allocations, but boxing and GC pauses add variance.
- **Python** is the slowest in raw throughput but the most productive for prototyping — interpreter overhead is unavoidable, but C extensions (NumPy, etc.) can close the gap for numerical work.

---

## 10. Cross-Language Synthesis

### When to Use Which Collection

| Need | Rust | Java | Python |
|------|------|------|--------|
| **Ordered, growable array** | `Vec<T>` | `ArrayList<E>` | `list` |
| **Immutable sequence** | `&[T]` (slice) | `List.of()` | `tuple` |
| **Double-ended queue** | `VecDeque<T>` | `ArrayDeque<E>` | `collections.deque` |
| **O(1) key lookup** | `HashMap<K, V>` | `HashMap<K, V>` | `dict` |
| **Sorted keys** | `BTreeMap<K, V>` | `TreeMap<K, V>` | `sortedcontainers.SortedDict` (third-party) |
| **Unique elements** | `HashSet<T>` | `HashSet<E>` | `set` |
| **Sorted unique elements** | `BTreeSet<T>` | `TreeSet<E>` | `sortedcontainers.SortedSet` (third-party) |
| **Priority queue** | `BinaryHeap<T>` (max) | `PriorityQueue<E>` (min) | `heapq` (min, on list) |
| **Concurrent hash map** | `dashmap` (crate) | `ConcurrentHashMap` | `dict` + GIL (informal) |
| **Enum-indexed map** | `HashMap` (or array) | `EnumMap` | `dict` |
| **Counting/multiset** | `HashMap<T, usize>` | `HashMap<T, Integer>` | `collections.Counter` |
| **FIFO producer-consumer** | `crossbeam` channel | `BlockingQueue` | `queue.Queue` |
| **LRU cache** | `lru` crate | `LinkedHashMap` (access order) | `functools.lru_cache` |

### Iterator Model Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Primary mechanism** | `Iterator` trait + adaptors | `Stream` API | Generators + comprehensions |
| **Laziness** | Structural (nested structs) | Behavioral (pipeline records ops) | Coroutine-based (`yield` suspends frame) |
| **Performance** | Zero-cost (compiler inlines) | Low-cost (JIT optimizes) | Interpreter overhead |
| **Parallelism** | `rayon::par_iter()` | `.parallel()` / `.parallelStream()` | `multiprocessing` / `concurrent.futures` |
| **Type of each adaptor** | Unique type (static dispatch) | `Stream<T>` (dynamic dispatch) | `generator` object |
| **Reusability** | Type reusable, instance single-pass | Single-use | Single-use |
| **Idiom for transform** | `.iter().map().filter().collect()` | `.stream().map().filter().collect()` | `[expr for x in xs if cond]` |

### Comprehensive Reference Table

| Concept | Rust | Java | Python | Key Difference |
|---------|------|------|--------|----------------|
| Dynamic array | `Vec<T>` | `ArrayList<E>` | `list` | Rust stores inline; Java/Python store pointers |
| Linked list | `LinkedList<T>` (rarely used) | `LinkedList<E>` | N/A (use `deque`) | All discourage linked lists for general use |
| Hash map | `HashMap<K,V>` (SwissTable) | `HashMap<K,V>` (chaining + treeify) | `dict` (open addressing) | Different collision strategies |
| Sorted map | `BTreeMap<K,V>` (B-tree) | `TreeMap<K,V>` (red-black tree) | No built-in | Rust B-tree has better cache locality |
| Hash set | `HashSet<T>` | `HashSet<E>` | `set` | All are wrappers around hash map |
| Sorted set | `BTreeSet<T>` | `TreeSet<E>` | No built-in | Same backing as sorted maps |
| Priority queue | `BinaryHeap<T>` (max) | `PriorityQueue<E>` (min) | `heapq` (min, functions on list) | Rust max-heap vs Java/Python min-heap |
| Double-ended queue | `VecDeque<T>` (ring buffer) | `ArrayDeque<E>` (ring buffer) | `deque` (block-linked) | Different internal structures |
| Iterator protocol | `Iterator::next() -> Option<T>` | `hasNext()` + `next()` | `__next__()` raises `StopIteration` | Rust: Option; Java: two methods; Python: exception |
| Lazy evaluation | Iterator adaptors (zero-cost) | Stream pipeline (single-use) | Generators (`yield`) | Rust: inlined structs; Java: pipeline object; Python: suspended frame |
| Functional combinators | `map`/`filter`/`fold`/`collect` | `map`/`filter`/`reduce`/`collect` | Comprehensions preferred over `map`/`filter` | Python favors comprehensions over method chains |
| Parallel iteration | `rayon` crate | `.parallelStream()` | `multiprocessing` | Only Java has built-in parallelism |
| Concurrent collections | Crates (`dashmap`, `crossbeam`) | `java.util.concurrent` package | GIL + `queue.Queue` | Rust: compile-time safety; Java: rich stdlib; Python: GIL |
| Custom collections | `IntoIterator` + `Iterator` traits | `AbstractList`/`AbstractMap` | `collections.abc` ABCs | Rust: separate iterator struct; Java: skeletal impls; Python: mixins + `yield` |
| Ownership during iteration | Borrow checker (compile-time) | `ConcurrentModificationException` (runtime) | `RuntimeError` for dicts; silent for lists | Rust prevents; Java detects; Python partially detects |
| Collection immutability | `&[T]` borrows | `List.of()`, `List.copyOf()` | `tuple`, `frozenset` | Rust: zero-cost borrow; Java/Python: separate types |

### Idiomatic Data Processing Pipeline

**Problem:** Parse log entries, group by severity, count occurrences, find top N most frequent.

```rust
// Rust
use std::collections::HashMap;

let counts: Vec<(&str, usize)> = lines.iter()
    .filter_map(|line| parse_severity(line))
    .fold(HashMap::new(), |mut acc, sev| {
        *acc.entry(sev).or_insert(0usize) += 1;
        acc
    })
    .into_iter()
    .sorted_by(|a, b| b.1.cmp(&a.1))     // itertools crate
    .take(n)
    .collect();
```

```java
// Java
List<Map.Entry<String, Long>> topN = lines.stream()
    .map(this::parseSeverity)
    .flatMap(Optional::stream)
    .collect(Collectors.groupingBy(s -> s, Collectors.counting()))
    .entrySet().stream()
    .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
    .limit(n)
    .collect(Collectors.toList());
```

```python
# Python
from collections import Counter

top_n = Counter(
    sev for line in lines if (sev := parse_severity(line))
).most_common(n)
```

Python is the most concise (built-in `Counter.most_common`). Java is the most explicit. Rust offers the best performance — the entire pipeline compiles to a tight loop with no heap allocation for intermediate results.

---

## Sources

### Books

**Rust**
- Klabnik & Nichols (2023) — *The Rust Programming Language*: Ch.8 (common collections), Ch.13 (closures and iterators)
- Blandy & Orendorff (2017) — *Programming Rust*: Ch.15 (iterators), Ch.16 (collections)
- Gjengset (2022) — *Rust for Rustaceans*: Ch.2 (types in memory, trait bounds)
- McNamara (2021) — *Rust in Action*: Ch.2 (arrays, slices, vectors), Ch.7 (HashMap, BTreeMap)
- Matthews (2024) — *Code Like a Pro in Rust*: Ch.4 (slices, arrays, Vec, HashMap), Ch.11 (vector optimization)

**Java**
- Horstmann (2024) — *Core Java, Vol. I*: Ch.8 (generics), Ch.9 (collections framework)
- Horstmann (2024) — *Core Java, Vol. II*: Ch.1 (streams)
- Bloch (2018) — *Effective Java*: Ch.5 (generics), Ch.6 Items 36–37 (EnumSet/EnumMap), Ch.7 (lambdas and streams)
- Naftalin & Wadler (2024) — *Java Generics and Collections*: Part 2 (collections implementations)
- Evans et al (2022) — *The Well-Grounded Java Developer*: Ch.6 (concurrent collections), Ch.16 (Fork/Join, parallel streams)

**Python**
- Ramalho (2022) — *Fluent Python*: Ch.2 (sequences), Ch.3 (dicts and sets), Ch.17 (iterators and generators)
- Slatkin (2025) — *Effective Python*: Ch.3 (loops and iterators), Ch.4 (dictionaries), Ch.6 (comprehensions and generators), Ch.7 Item 57 (collections.abc), Ch.12 (data structures)
- Martelli et al (2023) — *Python in a Nutshell*: Ch.3 (data types), Ch.8 (built-in functions, collections, itertools)
- Gorelick & Ozsvald (2020) — *High Performance Python*: Ch.3 (lists/tuples), Ch.4 (dicts/sets), Ch.5 (iterators/generators)
- Viafore (2021) — *Robust Python*: Ch.5 (collection type annotations, custom collections)

### External Resources

**Rust**
- [Rust std — `Vec<T>`](https://doc.rust-lang.org/std/vec/struct.Vec.html)
- [Rust std — `VecDeque<T>`](https://doc.rust-lang.org/std/collections/struct.VecDeque.html)
- [Rust std — Slice primitives](https://doc.rust-lang.org/std/primitive.slice.html)
- [Rust std — `std::collections` module overview](https://doc.rust-lang.org/std/collections/index.html)
- [Rust std — `HashMap<K,V>`](https://doc.rust-lang.org/std/collections/struct.HashMap.html)
- [Rust std — `BTreeMap<K,V>`](https://doc.rust-lang.org/std/collections/struct.BTreeMap.html)
- [Rust std — `HashSet<T>`](https://doc.rust-lang.org/std/collections/struct.HashSet.html)
- [Rust std — `BinaryHeap<T>`](https://doc.rust-lang.org/std/collections/struct.BinaryHeap.html)
- [Rust std — `LinkedList<T>`](https://doc.rust-lang.org/std/collections/struct.LinkedList.html)
- [Rust std — `Iterator` trait](https://doc.rust-lang.org/std/iter/trait.Iterator.html)
- [Rust std — `IntoIterator` trait](https://doc.rust-lang.org/std/iter/trait.IntoIterator.html)
- [Rust std — `std::iter` module](https://doc.rust-lang.org/std/iter/index.html)
- [Rust std — `FromIterator` trait](https://doc.rust-lang.org/std/iter/trait.FromIterator.html)
- [Rust std — `DoubleEndedIterator`](https://doc.rust-lang.org/std/iter/trait.DoubleEndedIterator.html)
- [Rust std — `ExactSizeIterator`](https://doc.rust-lang.org/std/iter/trait.ExactSizeIterator.html)
- [Rust std — `Index` and `IndexMut` traits](https://doc.rust-lang.org/std/ops/trait.Index.html)
- [Rust std — `Cow<T>`](https://doc.rust-lang.org/std/borrow/enum.Cow.html)
- [Rust std — `Vec::drain`](https://doc.rust-lang.org/std/vec/struct.Vec.html#method.drain)
- [Rust std — `HashMap::entry`](https://doc.rust-lang.org/std/collections/struct.HashMap.html#method.entry)
- [Rust std — `std::collections` performance guarantees](https://doc.rust-lang.org/std/collections/index.html#performance)
- [Rust std — Iterator adaptors (provided methods)](https://doc.rust-lang.org/std/iter/trait.Iterator.html#provided-methods)
- [Rust std — Implementing `Iterator`](https://doc.rust-lang.org/std/iter/index.html#implementing-iterator)
- [Rust By Example — Iterators](https://doc.rust-lang.org/rust-by-example/trait/iter.html)
- [Rust By Example — Ownership](https://doc.rust-lang.org/rust-by-example/scope/move.html)
- [Rust Reference — Iterator loops](https://doc.rust-lang.org/reference/expressions/loop-expr.html#iterator-loops)
- [Rustonomicon — Ownership and lifetimes](https://doc.rust-lang.org/nomicon/ownership.html)
- [hashbrown crate (SwissTable implementation)](https://docs.rs/hashbrown/latest/hashbrown/)
- [rayon crate (parallel iterators)](https://docs.rs/rayon/latest/rayon/)
- [crossbeam crate (concurrent data structures)](https://docs.rs/crossbeam/latest/crossbeam/)
- [dashmap crate (concurrent HashMap)](https://docs.rs/dashmap/latest/dashmap/)

**Java**
- [Java SE API — `ArrayList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ArrayList.html)
- [Java SE API — `LinkedList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/LinkedList.html)
- [Java SE API — `HashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/HashMap.html)
- [Java SE API — `TreeMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/TreeMap.html)
- [Java SE API — `EnumMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumMap.html)
- [Java SE API — `EnumSet`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/EnumSet.html)
- [Java SE API — `Iterable<T>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Iterable.html)
- [Java SE API — `Iterator<E>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Iterator.html)
- [Java SE API — `ListIterator<E>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ListIterator.html)
- [Java SE API — `Stream<T>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html)
- [Java SE API — `java.util.stream` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/package-summary.html)
- [Java SE API — `Spliterator<T>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Spliterator.html)
- [Java SE API — `Collectors`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Collectors.html)
- [Java SE API — `Optional<T>`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html)
- [Java SE API — `java.util.function` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/package-summary.html)
- [Java SE API — `Collections.unmodifiableList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html#unmodifiableList(java.util.List))
- [Java SE API — `List.copyOf`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#copyOf(java.util.Collection))
- [Java SE API — `ConcurrentHashMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentHashMap.html)
- [Java SE API — `CopyOnWriteArrayList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/CopyOnWriteArrayList.html)
- [Java SE API — `BlockingQueue`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html)
- [Java SE API — `ConcurrentSkipListMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ConcurrentSkipListMap.html)
- [Java SE API — `java.util.concurrent` package](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/package-summary.html)
- [Java SE API — `AbstractList`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/AbstractList.html)
- [Java SE API — `AbstractMap`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/AbstractMap.html)
- [JEP 431 — Sequenced Collections](https://openjdk.org/jeps/431)
- [JLS 14.14.2 — Enhanced `for` statement](https://docs.oracle.com/javase/specs/jls/se21/html/jls-14.html#jls-14.14.2)
- [Dev.java — Collections Framework overview](https://dev.java/learn/api/collections-framework/)
- [Dev.java — Streams tutorial](https://dev.java/learn/api/streams/)
- [Dev.java — Implementing custom collections](https://dev.java/learn/api/collections-framework/implementing-a-collection/)
- [Aleksey Shipilev — JVM Anatomy Quarks](https://shipilev.net/jvm/anatomy-quarks/)

**Python**
- [Python docs — `list`](https://docs.python.org/3/library/stdtypes.html#list)
- [Python docs — `dict`](https://docs.python.org/3/library/stdtypes.html#dict)
- [Python docs — `set` / `frozenset`](https://docs.python.org/3/library/stdtypes.html#set)
- [Python docs — `array` module](https://docs.python.org/3/library/array.html)
- [Python docs — `collections` module](https://docs.python.org/3/library/collections.html)
- [Python docs — `collections.deque`](https://docs.python.org/3/library/collections.html#collections.deque)
- [Python docs — `collections.abc`](https://docs.python.org/3/library/collections.abc.html)
- [Python docs — Iterator types](https://docs.python.org/3/library/stdtypes.html#iterator-types)
- [Python docs — `__iter__` and `__next__`](https://docs.python.org/3/reference/datamodel.html#object.__iter__)
- [Python docs — `__hash__` data model](https://docs.python.org/3/reference/datamodel.html#object.__hash__)
- [Python docs — Emulating container types](https://docs.python.org/3/reference/datamodel.html#emulating-container-types)
- [Python docs — `iter()` built-in](https://docs.python.org/3/library/functions.html#iter)
- [Python docs — Generator expressions](https://docs.python.org/3/reference/expressions.html#generator-expressions)
- [Python docs — `yield` expressions](https://docs.python.org/3/reference/expressions.html#yield-expressions)
- [Python docs — List comprehensions](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions)
- [Python docs — `map`, `filter`, `zip`, `enumerate` built-ins](https://docs.python.org/3/library/functions.html)
- [Python docs — `functools.reduce`](https://docs.python.org/3/library/functools.html#functools.reduce)
- [Python docs — `itertools` module](https://docs.python.org/3/library/itertools.html)
- [Python docs — `heapq` module](https://docs.python.org/3/library/heapq.html)
- [Python docs — `bisect` module](https://docs.python.org/3/library/bisect.html)
- [Python docs — `queue` module](https://docs.python.org/3/library/queue.html)
- [Python docs — `multiprocessing.Queue`](https://docs.python.org/3/library/multiprocessing.html#multiprocessing.Queue)
- [Python docs — `copy` module](https://docs.python.org/3/library/copy.html)
- [Python docs — Mutable sequence operations](https://docs.python.org/3/library/stdtypes.html#mutable-sequence-types)
- [Python docs — `sys.getsizeof`](https://docs.python.org/3/library/sys.html#sys.getsizeof)
- [Python docs — Iterator glossary](https://docs.python.org/3/glossary.html#term-iterator)
- [Python Wiki — TimeComplexity](https://wiki.python.org/moin/TimeComplexity)
- [PEP 255 — Simple Generators](https://peps.python.org/pep-0255/)
- [PEP 289 — Generator Expressions](https://peps.python.org/pep-0289/)
- [PEP 380 — Syntax for Delegating to a Subgenerator (`yield from`)](https://peps.python.org/pep-0380/)
- [PEP 709 — Inlined Comprehensions (Python 3.12+)](https://peps.python.org/pep-0709/)

**General**
- [Wikipedia — Amortized analysis](https://en.wikipedia.org/wiki/Amortized_analysis)
- [Wikipedia — Hash table](https://en.wikipedia.org/wiki/Hash_table)
- [Wikipedia — Red-black tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)
- [Wikipedia — B-tree](https://en.wikipedia.org/wiki/B-tree)

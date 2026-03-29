# 100 Java Mistakes and How to Avoid Them

## Book Metadata
- **Title:** 100 Java Mistakes and How to Avoid Them
- **Author:** Tagir Valeev
- **Publisher:** Manning Publications
- **Year:** 2024
- **Pages:** 353
- **ISBN:** 9781633437968
- **Foreword by:** Cay Horstmann

## Target Audience and Prerequisites
- Primary: middle-level Java developers with solid language knowledge but limited practical experience
- Secondary: senior developers learning unfamiliar bug patterns; advanced students
- Requires working knowledge of Java fundamentals
- Covers Java up to JDK 21

## Overall Focus
A catalogue of the most common repetitive mistakes in Java programs, focusing on "miscommunication between developer and machine" -- where developers understand the problem but write incorrect code. Emphasizes prevention through code review, static analysis (IntelliJ IDEA, SonarLint, Error Prone, SpotBugs), testing, and assertions. Author is a Technical Lead at JetBrains responsible for Java support in IntelliJ IDEA with 15 years of Java experience.

---

## Table of Contents

### Chapter 1: Managing Code Quality (pp. 1-18)
- 1.1 Code review and pair programming
- 1.2 Code style
- 1.3 Static analysis tools and limitations
- 1.4 Automated testing
- 1.5 Mutation coverage
- 1.6 Dynamic analysis
- 1.7 Code assertions

**Summary:** Foundational chapter on quality assurance techniques. Covers the role of static analysis in preventing bugs, tools (IntelliJ IDEA, SonarLint, Error Prone, PVS-Studio, PMD, SpotBugs, CodeQL), false positive handling, and when to suppress warnings.

### Chapter 2: Expressions (pp. 19-60)
| # | Mistake | Page |
|---|---------|------|
| 1 | Incorrect numeric operator precedence | 20 |
| 2 | Missing parentheses in conditions | 23 |
| 3 | Accidental concatenation instead of addition | 29 |
| 4 | Multiline string literals | 30 |
| 5 | Unary plus | 32 |
| 6 | Implicit type conversion in conditional expressions | 33 |
| 7 | Using non-short-circuit logic operators | 37 |
| 8 | Confusing && and \|\| | 41 |
| 9 | Incorrectly using variable arity calls | 43 |
| 10 | Conditional operators and variable arity calls | 47 |
| 11 | Ignoring an important return value | 49 |
| 12 | Not using a newly created object | 53 |
| 13 | Binding a method reference to the wrong method | 54 |
| 14 | Using the wrong method in a method reference | 58 |

**Summary:** Mistakes within individual expressions: operator precedence, type conversions, varargs ambiguity, and method reference resolution. Covers boxed primitive pitfalls and the difference between short-circuit and non-short-circuit logic.

### Chapter 3: Program Structure (pp. 61-95)
| # | Mistake | Page |
|---|---------|------|
| 15 | Malformed if-else chain | 62 |
| 16 | Condition dominated by a previous condition | 66 |
| 17 | Accidental pass through in switch statement | 69 |
| 18 | Malformed classic for loop | 71 |
| 19 | Not using the loop variable | 73 |
| 20 | Wrong loop direction | 74 |
| 21 | Loop overflow | 75 |
| 22 | Idempotent loop body | 76 |
| 23 | Incorrect initialization order | 80 |
| 24 | Missing superclass method call | 90 |
| 25 | Accidental static field declaration | 91 |

**Summary:** Control flow and structural mistakes: unreachable conditions, switch fallthrough (recommends Java 14+ arrow syntax), loop variable errors, initialization order problems, and missing super() calls.

### Chapter 4: Numbers (pp. 96-123)
| # | Mistake | Page |
|---|---------|------|
| 26 | Accidental use of octal literal | 97 |
| 27 | Numeric overflow | 97 |
| 28 | Rounding during integer division | 105 |
| 29 | Absolute value of Integer.MIN_VALUE | 106 |
| 30 | Oddness check and negative numbers | 108 |
| 31 | Widening with precision loss | 109 |
| 32 | Unconditional narrowing | 110 |
| 33 | Negative hexadecimal values | 111 |
| 34 | Implicit type conversion in compound assignments | 112 |
| 35 | Division and compound assignment | 113 |
| 36 | Using the short type | 114 |
| 37 | Manually writing bit-manipulating algorithms | 115 |
| 38 | Forgetting about negative byte values | 117 |
| 39 | Incorrect clamping order | 118 |
| 40 | Misusing special floating-point numbers | 119 |

**Summary:** Integer and floating-point arithmetic pitfalls: silent overflow, rounding, precision loss, two's complement issues, and NaN/Infinity behavior. Recommends Math.*Exact methods for overflow detection.

### Chapter 5: Common Exceptions (pp. 124-154)
| # | Mistake | Page |
|---|---------|------|
| 41 | NullPointerException | 129 |
| 42 | IndexOutOfBoundsException | 136 |
| 43 | ClassCastException | 138 |
| 44 | StackOverflowError | 147 |

**Summary:** Most frequent runtime exceptions and defensive programming. Covers null handling strategies (Optional, @Nullable/@NotNull annotations, defensive checks), type erasure pitfalls, and infinite recursion scenarios.

### Chapter 6: Strings (pp. 155-176)
| # | Mistake | Page |
|---|---------|------|
| 45 | Assuming char value is a character | 155 |
| 46 | Unexpected case conversions | 159 |
| 47 | Using String.format with default locale | 160 |
| 48 | Mismatched format arguments | 162 |
| 49 | Using plain strings instead of regular expressions | 164 |
| 50 | Accidental use of replaceAll | 167 |
| 51 | Accidental use of escape sequences | 168 |
| 52 | Comparing strings in different case | 171 |
| 53 | Not checking result of indexOf | 172 |
| 54 | Mixing arguments of indexOf | 174 |

**Summary:** Character encoding, localization, and string processing pitfalls. Covers surrogate pairs (emoji), locale-dependent case conversion (Turkish 'i'), regex vs literal string operations, and text blocks (Java 15+).

### Chapter 7: Comparing Objects (pp. 177-212)
| # | Mistake | Page |
|---|---------|------|
| 55 | Reference equality instead of equals() | 179 |
| 56 | Assuming equals() compares content | 181 |
| 57 | Using URL.equals() | 183 |
| 58 | Comparing BigDecimals with different scales | 184 |
| 59 | Using equals() on unrelated types | 185 |
| 60 | Malformed equals() implementation | 187 |
| 61 | Wrong hashCode() with array fields | 191 |
| 62 | Mismatch between equals() and hashCode() | 193 |
| 63 | Relying on particular return value of compare() | 196 |
| 64 | Failing to return 0 when comparing equal objects | 198 |
| 65 | Using subtraction when comparing numbers | 199 |
| 66 | Ignoring possible NaN values in comparison | 202 |
| 67 | Failing to represent object as sequence of bytes | 204 |
| 68 | Returning random numbers from compareTo() | 206 |
| 69 | Searching for object of unrelated type | 207 |

**Summary:** equals(), hashCode(), compareTo() pitfalls. Recommends IDE generation, Java 16+ records (automatic implementations), Objects.equals() for null-safe equality, and EqualsVerifier library for testing.

### Chapter 8: Collections and Maps (pp. 213-248)
| # | Mistake | Page |
|---|---------|------|
| 70 | Mixing up single object and collection | 216 |
| 71 | Searching for null in null-hostile collections | 219 |
| 72 | Using null values in maps | 221 |
| 73 | Trying to modify unmodifiable collection | 223 |
| 74 | Using mutable objects as keys | 227 |
| 75 | Relying on HashMap/HashSet encounter order | 230 |
| 76 | Concurrent modification during iteration | 231 |
| 77 | Mixing List.remove() overloads | 234 |
| 78 | Jumping over next element after List.remove() | 236 |
| 79 | Reading collection inside lambda | 237 |
| 80 | Concurrent modification in Stream.forEach | 241 |
| 81 | Violating Iterator contracts | 243 |

**Summary:** Collection mutability (not in type system), concurrent modification, null handling differences across Map methods, and Iterator contract violations. Key classification: fully mutable (ArrayList), partially mutable (Arrays.asList), immutable (List.of).

### Chapter 9: Library Methods (pp. 249-272)
| # | Mistake | Page |
|---|---------|------|
| 82 | Passing char to StringBuilder constructor | 249 |
| 83 | Side effects in Stream API chain | 251 |
| 84 | Consuming stream twice | 254 |
| 85 | Using null values in streams | 257 |
| 86 | Violating Stream API contract | 258 |
| 87 | Using getClass() instead of instanceof | 261 |
| 88 | Using getClass() on enums/annotations/classes | 262 |
| 89 | Incorrect conversion of string to boolean | 264 |
| 90 | Incorrect format specifiers in date formatting | 266 |
| 91 | Accidental invalidation of weak/soft references | 267 |
| 92 | Assuming the world is stable | 268 |
| 93 | Non-atomic access to concurrent data structures | 270 |

**Summary:** Misuse of library methods: StringBuilder overloads, Stream API contract (associativity, non-interference, statelessness), weak references, and race conditions in compound operations on concurrent collections.

### Chapter 10: Unit Testing (pp. 274-310)
| # | Mistake | Page |
|---|---------|------|
| 94 | Side effect in assert statement | 274 |
| 95 | Malformed assertion method calls | 276 |
| 96 | Malformed exception test | 278 |
| 97 | Premature exit from test method | 279 |
| 98 | Ignoring AssertionError in unit tests | 280 |
| 99 | Using assertNotEquals() for equality contract | 282 |
| 100 | Malformed test methods | 285 |

**Summary:** Common test writing mistakes: wrong assertion argument order, try-catch instead of assertThrows(), unreachable assertions, and catching AssertionError. Recommends EqualsVerifier for testing equals/hashCode contracts.

### Appendices
- **Appendix A:** Nullity and Other Annotations
- **Appendix B:** Extending Static Analysis Tools (IntelliJ IDEA, SonarQube, Error Prone plugin APIs)

---

## Key Topics and Concepts

### Static Analysis & Tooling
- IntelliJ IDEA, SonarLint, Error Prone, SpotBugs, PMD, CodeQL
- Quick-fix cautions; suppression strategies
- External annotations for standard library

### Type System & Generics
- Type erasure consequences
- Boxing/unboxing pitfalls
- Java records (16+) automatic equals/hashCode

### Null Safety
- Optional (return types only, not parameters)
- @Nullable, @NotNull, @NonNullByDefault annotations
- Contract annotations for method behavior

### Modern Java Features
- Java 14+ switch expressions (arrow syntax)
- Java 15+ text blocks
- Java 16+ records
- Java 21 improvements

### Collections Taxonomy
- Mutability not in type system
- Arrays.asList() vs List.of() vs Collections.unmodifiable*
- Null handling differences across Map methods

### Stream API
- Stateless functions in intermediate operations
- Non-reusable after terminal operation
- Parallel stream contract compliance

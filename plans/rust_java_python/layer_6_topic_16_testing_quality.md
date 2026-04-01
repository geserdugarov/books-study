# Layer 6 · Topic 16 — Testing & Quality

> Comparative study of Rust, Java, and Python: how each language approaches software testing and quality assurance — from Rust's built-in `#[test]` harness with compile-time guarantees that reduce the need for certain test categories, through Java's mature JUnit/TestNG ecosystem with deep IDE integration, to Python's flexible `pytest` framework with runtime dynamism that enables powerful but unchecked mocking — and the surrounding tools for property-based testing, benchmarking, fuzzing, static analysis, and code coverage.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.11 pp. 215–242 | Test anatomy: `#[test]` attribute, `assert!`/`assert_eq!`/`assert_ne!` macros, custom failure messages, `should_panic` attribute, `Result<T, E>` in tests, controlling test execution (`--test-threads`, `--show-output`, running by name, `#[ignore]`), test organization (unit tests in `#[cfg(test)]` modules, integration tests in `tests/` directory, testing private functions) |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.6 pp. 85–100 | Advanced testing: the test harness, `#[cfg(test)]` and conditional compilation, doctests and `#[doc(hidden)]`, Clippy lints for code quality, test generation strategies, Miri for detecting undefined behavior, sanitizers (AddressSanitizer, ThreadSanitizer), `criterion` for benchmarking, `proptest`/`quickcheck` for property-based testing |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.3 pp. 43–62 | Rust tooling: Clippy lints and configuration (`clippy.toml`, lint groups, allowing/denying lints), CI/CD integration, `cargo-fuzz` for fuzz testing |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.6 pp. 121–140 | Unit testing: built-in testing idioms, what not to test, parallel test execution, code coverage with `cargo-tarpaulin` |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.7 pp. 141–154 | Integration testing: unit vs integration test boundaries, `assert_cmd` for testing CLI binaries, `proptest` for property-based testing, fuzz testing with `cargo-fuzz` |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.8 pp. 161–191 | Integration tests in `tests/` directory, doc-tests with `///` examples, test organization patterns |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.1 pp. 1–18 | Managing code quality with static analysis: SpotBugs, Error Prone, PMD, SonarLint, CodeQL; mutation testing and coverage strategies |
| Java | Valeev (2024) — *100 Java Mistakes* | Ch.10 pp. 274–310 | Common unit testing mistakes, `EqualsVerifier` for testing `equals`/`hashCode` contracts, test organization pitfalls |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.13 pp. 437–465 | Testing fundamentals: TDD workflow, test doubles taxonomy (dummy, stub, fake, mock, spy), JUnit 5 architecture (JUnit Platform, JUnit Jupiter, JUnit Vintage), annotations (`@Test`, `@BeforeEach`, `@AfterEach`, `@DisplayName`, `@Nested`), assertions, assumptions |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.14 pp. 466–493 | Testing beyond JUnit: Testcontainers for integration testing, BDD with Spek, property-based testing concepts (covers `test.check` in Clojure context — principles transfer to `jqwik`) |
| Java | Goetz et al (2006) — *Java Concurrency in Practice* | Ch.12 pp. 247–272 | Testing concurrent programs: testing for correctness (safety tests using concurrent put/take, testing with barriers), testing for liveness, performance tests (bounded buffer throughput, comparing timer granularity), avoiding performance testing pitfalls (garbage collection, dynamic compilation, unrealistic contention, dead code elimination) |
| Java | Oaks (2020) — *Java Performance* | Ch.2 pp. 15–48 | Performance testing approach: micro/macro/mesobenchmarks, understanding variability, test early/test often, JMH introduction and usage |
| Java | Oaks (2020) — *Java Performance* | Ch.3 pp. 49–88 | Java performance toolbox: profiling tools, Java Flight Recorder (JFR), JFR event types, enabling JFR |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.5 pp. 115–175 | JMH deep dive: writing benchmarks, benchmark modes (throughput, average time, sample time, single shot), state objects, `@Setup`/`@TearDown`, `@Param`, `Blackhole` to prevent dead code elimination, profiling JMH with perfasm, JMH Gradle/Maven integration |
| Python | Viafore (2021) — *Robust Python* | Ch.20 pp. 285–296 | Static analysis: Pylint rules and categories, writing custom Pylint plugins, security analyzers (Bandit), complexity checkers |
| Python | Viafore (2021) — *Robust Python* | Ch.21 pp. 297–313 | Testing strategy: test categorization (unit, integration, acceptance, performance), the testing pyramid, Arrange-Act-Assert (AAA) pattern, testing behavior not implementation |
| Python | Viafore (2021) — *Robust Python* | Ch.22 pp. 315–325 | Acceptance testing with BDD: Gherkin syntax, `behave` framework, step definitions, feature files |
| Python | Viafore (2021) — *Robust Python* | Ch.23 pp. 327–345 | Property-based testing with Hypothesis: strategies, `@given` decorator, `@example`, shrinking, stateful testing, integration with pytest |
| Python | Viafore (2021) — *Robust Python* | Ch.24 pp. 347–365 | Mutation testing with `mutmut`: what mutations are, running and analyzing mutation results, improving test suite quality |
| Python | Slatkin (2025) — *Effective Python* | Ch.13 pp. 533–574 | Testing and debugging: subclassing `TestCase` for test isolation, integration tests for verifying related behaviors, mocking with `unittest.mock` (`Mock`, `patch`, `spec`), debugging with `pdb` and `breakpoint()` |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.17 pp. 513–561 | Testing, debugging, and optimizing: `unittest` module (TestCase, assertions, test discovery), `doctest` module (embedding tests in docstrings), `pytest` (test discovery, assertions, fixtures, parametrize), `timeit` for microbenchmarks, `cProfile` for profiling |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.2 pp. 21–64 | Profiling to find bottlenecks: `cProfile` and visualizing with SnakeViz, `line_profiler` for line-by-line analysis, `memory_profiler` for memory consumption, `PySpy` for sampling profiler without code modification |
| Python | Shaw (2021) — *CPython Internals* | Ch.15 pp. 346–363 | Benchmarking CPython: `timeit` for microbenchmarks (command-line and API), `pyperformance` for macro-benchmarks, `cProfile` for function-level profiling |

### Coverage Gaps

The owned books **do not** cover:

- **Rust mocking strategies (`mockall`, `mockito`, trait-based mocking)** — no owned Rust book covers mocking crates in depth; Klabnik's and Gjengset's testing chapters focus on assertions and property testing but do not address how to mock dependencies; the trait-based dependency injection pattern that enables mocking in Rust (requiring trait bounds rather than concrete types) needs to be learned from the `mockall` documentation and community guides
- **Java `jqwik` property-based testing** — Evans Ch.14 covers property-based testing concepts using Clojure's `test.check`, but no owned book covers `jqwik`, the leading property-based testing framework for Java that integrates with JUnit 5; the `jqwik` documentation and user guide are needed
- **Java Jazzer (fuzzing for Java)** — no owned book covers Jazzer (the JVM fuzzing tool based on libFuzzer); this requires the Jazzer GitHub repository documentation and Code Intelligence blog posts
- **Python Atheris (fuzzing for Python)** — no owned book covers Atheris (Google's Python fuzzing engine based on libFuzzer); this requires the Atheris GitHub repository and Google's OSS-Fuzz documentation
- **Ruff (modern Python linter/formatter)** — Viafore covers Pylint (2021), but Ruff (released 2022, written in Rust) has become the dominant Python linting tool; the Ruff documentation and configuration guide are needed
- **Java code coverage with JaCoCo** — no owned book covers JaCoCo (the standard Java code coverage tool) in depth: agent instrumentation, report generation, branch vs line coverage, integration with Maven/Gradle; the JaCoCo documentation is needed
- **Rust code coverage with `cargo-tarpaulin` and `llvm-cov`** — Matthews Ch.6 mentions `cargo-tarpaulin` briefly, but no owned book provides comprehensive coverage of Rust coverage tools (`cargo-tarpaulin`, `cargo-llvm-cov`, source-based coverage via LLVM instrumentation); the respective tool documentation is needed
- **Python `pytest` in depth (fixtures, parametrize, plugins, conftest.py)** — Martelli covers `pytest` basics, but no owned book covers the fixture system (dependency injection, scope, autouse), `@pytest.mark.parametrize`, `conftest.py` for shared fixtures, the plugin ecosystem (`pytest-cov`, `pytest-xdist`, `pytest-asyncio`), or custom plugins; Brian Okken's *Python Testing with pytest* is the definitive resource
- **Comparative mocking strategies and how type systems affect mocking** — no owned book compares how Rust's trait system, Java's interface/class hierarchy, and Python's duck typing lead to fundamentally different mocking approaches: Rust requires trait-based DI (no monkey-patching), Java uses proxy-based mocking (Mockito) enabled by runtime reflection, Python uses `unittest.mock.patch` to replace any attribute at runtime; this requires synthesis from multiple sources
- **Python `pytest-benchmark` for benchmarking** — no owned book covers `pytest-benchmark` (integrating benchmarks into the pytest workflow with statistical analysis, histograms, and comparison between runs); the `pytest-benchmark` documentation is needed
- **Snapshot testing / approval testing** — no owned book covers snapshot testing for any language: `insta` (Rust), `ApprovalTests` (Java), `syrupy`/`pytest-snapshot` (Python); these require their respective documentation
- **Mockito (Java mocking framework)** — Evans Ch.13 covers test doubles conceptually and mentions Mockito briefly, but no owned book provides depth on Mockito API (`when`/`thenReturn`, `verify`, argument matchers, `@InjectMocks`, `@Mock`, `@Spy`), Mockito inline/static mocking, or Mockito vs other frameworks; the Mockito documentation and Baeldung tutorials are needed

---

## External Resources

### Sub-topic 1 — Built-in Test Frameworks

**Rust**
- The Rust Book — Writing Automated Tests: `https://doc.rust-lang.org/book/ch11-00-testing.html`
- Rust By Example — Testing: `https://doc.rust-lang.org/rust-by-example/testing.html`
- Rust Reference — Testing attributes (`#[test]`, `#[bench]`, `#[cfg(test)]`): `https://doc.rust-lang.org/reference/attributes/testing.html`
- `cargo test` documentation: `https://doc.rust-lang.org/cargo/commands/cargo-test.html`
- Rust docs — Doc-tests: `https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html`

**Java**
- JUnit 5 User Guide: `https://junit.org/junit5/docs/current/user-guide/`
- JUnit 5 GitHub repository: `https://github.com/junit-team/junit5`
- Baeldung — JUnit 5 Tutorial: `https://www.baeldung.com/junit-5`
- TestNG documentation: `https://testng.org/doc/documentation-main.html`
- Baeldung — JUnit 5 vs TestNG: `https://www.baeldung.com/junit-vs-testng`

**Python**
- Python docs — `unittest` module: `https://docs.python.org/3/library/unittest.html`
- Python docs — `doctest` module: `https://docs.python.org/3/library/doctest.html`
- pytest documentation: `https://docs.pytest.org/en/stable/`
- pytest — Fixtures reference: `https://docs.pytest.org/en/stable/reference/fixtures.html`
- pytest — Parametrizing tests: `https://docs.pytest.org/en/stable/how-to/parametrize.html`
- Real Python — Effective Python Testing with Pytest: `https://realpython.com/pytest-python-testing/`

### Sub-topic 2 — Property-Based Testing

**Rust**
- `proptest` crate documentation: `https://docs.rs/proptest/latest/proptest/`
- `proptest` GitHub repository: `https://github.com/proptest-rs/proptest`
- `proptest` book: `https://proptest-rs.github.io/proptest/intro.html`
- `quickcheck` crate documentation: `https://docs.rs/quickcheck/latest/quickcheck/`
- `quickcheck` GitHub repository: `https://github.com/BurntSushi/quickcheck`

**Java**
- jqwik user guide: `https://jqwik.net/docs/current/user-guide.html`
- jqwik GitHub repository: `https://github.com/jqwik-team/jqwik`
- Baeldung — Property-Based Testing with jqwik: `https://www.baeldung.com/java-jqwik-property-based-testing`
- Johannes Link — "Property-based Testing in Java" (jqwik author's blog): `https://blog.johanneslink.net/2018/03/24/property-based-testing-in-java-introduction/`

**Python**
- Hypothesis documentation: `https://hypothesis.readthedocs.io/en/latest/`
- Hypothesis GitHub repository: `https://github.com/HypothesisWorks/hypothesis`
- Hypothesis — Quick start guide: `https://hypothesis.readthedocs.io/en/latest/quickstart.html`
- Hypothesis — Available strategies: `https://hypothesis.readthedocs.io/en/latest/data.html`
- David MacIver — "In praise of property-based testing" (Hypothesis author): `https://increment.com/testing/in-praise-of-property-based-testing/`

### Sub-topic 3 — Benchmarking

**Rust**
- `criterion` crate documentation: `https://docs.rs/criterion/latest/criterion/`
- `criterion` GitHub repository: `https://github.com/bheisler/criterion.rs`
- `criterion` user guide: `https://bheisler.github.io/criterion.rs/book/`
- `divan` crate (modern alternative): `https://github.com/nvzqz/divan`
- Rust unstable book — `#[bench]` and `test::Bencher`: `https://doc.rust-lang.org/unstable-book/library-features/test.html`

**Java**
- OpenJDK JMH project: `https://openjdk.org/projects/code-tools/jmh/`
- JMH samples (annotated examples): `https://github.com/openjdk/jmh/tree/master/jmh-samples/src/main/java/org/openjdk/jmh/samples`
- Baeldung — Microbenchmarking with JMH: `https://www.baeldung.com/java-microbenchmark-harness`
- Aleksey Shipilev — "JMH: Java Microbenchmark Harness" (JMH author's talks and blog): `https://shipilev.net/`

**Python**
- Python docs — `timeit` module: `https://docs.python.org/3/library/timeit.html`
- `pytest-benchmark` documentation: `https://pytest-benchmark.readthedocs.io/en/latest/`
- `pytest-benchmark` GitHub repository: `https://github.com/ionelmc/pytest-benchmark`
- Python docs — `cProfile` module: `https://docs.python.org/3/library/profile.html`
- `pyperformance` benchmark suite: `https://github.com/python/pyperformance`

### Sub-topic 4 — Mocking Strategies

**Rust**
- `mockall` crate documentation: `https://docs.rs/mockall/latest/mockall/`
- `mockall` GitHub repository: `https://github.com/asomers/mockall`
- `mockall` — Getting Started guide: `https://docs.rs/mockall/latest/mockall/#getting-started`
- Alan Somers — "Rust Mock Shootout" (comparison of mocking crates): `https://asomers.github.io/mock_shootout/`

**Java**
- Mockito documentation: `https://site.mockito.org/`
- Mockito GitHub repository: `https://github.com/mockito/mockito`
- Mockito Javadoc (comprehensive usage guide): `https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html`
- Baeldung — Mockito Tutorial: `https://www.baeldung.com/mockito-series`
- Baeldung — Mockito vs EasyMock vs JMockit: `https://www.baeldung.com/mockito-vs-easymock-vs-jmockit`

**Python**
- Python docs — `unittest.mock`: `https://docs.python.org/3/library/unittest.mock.html`
- Python docs — `unittest.mock` — getting started: `https://docs.python.org/3/library/unittest.mock-examples.html`
- `pytest-mock` (thin Mockito-style wrapper around `unittest.mock`): `https://github.com/pytest-dev/pytest-mock`
- Real Python — Understanding the Python Mock Object Library: `https://realpython.com/python-mock-library/`

### Sub-topic 5 — Fuzzing

**Rust**
- `cargo-fuzz` documentation: `https://rust-fuzz.github.io/book/cargo-fuzz.html`
- `cargo-fuzz` GitHub repository: `https://github.com/rust-fuzz/cargo-fuzz`
- Rust Fuzz Book: `https://rust-fuzz.github.io/book/`
- `libfuzzer-sys` crate: `https://docs.rs/libfuzzer-sys/latest/libfuzzer_sys/`
- `afl.rs` (American Fuzzy Lop for Rust): `https://github.com/rust-fuzz/afl.rs`
- `arbitrary` crate (structured fuzzing): `https://docs.rs/arbitrary/latest/arbitrary/`

**Java**
- Jazzer GitHub repository: `https://github.com/CodeIntelligenceTesting/jazzer`
- Jazzer documentation: `https://github.com/CodeIntelligenceTesting/jazzer/blob/main/README.md`
- Code Intelligence — "Fuzzing Java with Jazzer" blog: `https://www.code-intelligence.com/blog/java-fuzzing-with-jazzer`
- Google OSS-Fuzz — Java fuzzing documentation: `https://google.github.io/oss-fuzz/getting-started/new-project-guide/jvm-lang/`

**Python**
- Atheris GitHub repository: `https://github.com/google/atheris`
- Atheris — Getting Started: `https://github.com/google/atheris/blob/master/README.md`
- Google Security Blog — "Atheris: A Coverage-Guided Python Fuzzing Engine": `https://security.googleblog.com/2020/12/how-atheris-python-fuzzer-works.html`
- Google OSS-Fuzz — Python fuzzing: `https://google.github.io/oss-fuzz/getting-started/new-project-guide/python-lang/`

### Sub-topic 6 — Static Analysis

**Rust**
- Clippy documentation: `https://doc.rust-lang.org/clippy/`
- Clippy lint list (all lints with explanations): `https://rust-lang.github.io/rust-clippy/master/`
- Clippy GitHub repository: `https://github.com/rust-lang/rust-clippy`
- Clippy — Configuring lints: `https://doc.rust-lang.org/clippy/configuration.html`
- Miri (undefined behavior detector): `https://github.com/rust-lang/miri`

**Java**
- SpotBugs documentation: `https://spotbugs.readthedocs.io/en/stable/`
- SpotBugs GitHub repository: `https://github.com/spotbugs/spotbugs`
- Error Prone documentation: `https://errorprone.info/`
- Error Prone — Bug patterns: `https://errorprone.info/bugpatterns`
- Error Prone GitHub repository: `https://github.com/google/error-prone`
- PMD documentation: `https://pmd.github.io/`
- SonarQube for Java: `https://www.sonarsource.com/products/sonarqube/`

**Python**
- Ruff documentation: `https://docs.astral.sh/ruff/`
- Ruff GitHub repository: `https://github.com/astral-sh/ruff`
- Ruff — Rule reference: `https://docs.astral.sh/ruff/rules/`
- Pylint documentation: `https://pylint.readthedocs.io/en/stable/`
- Pylint GitHub repository: `https://github.com/pylint-dev/pylint`
- mypy (static type checker): `https://mypy.readthedocs.io/en/stable/`
- Bandit (security linter): `https://bandit.readthedocs.io/en/latest/`

### Sub-topic 7 — Code Coverage

**Rust**
- `cargo-tarpaulin` GitHub repository: `https://github.com/xd009642/tarpaulin`
- `cargo-tarpaulin` documentation: `https://docs.rs/cargo-tarpaulin/`
- `cargo-llvm-cov` GitHub repository: `https://github.com/taiki-e/cargo-llvm-cov`
- Rust source-based code coverage guide: `https://doc.rust-lang.org/rustc/instrument-coverage.html`

**Java**
- JaCoCo documentation: `https://www.jacoco.org/jacoco/trunk/doc/`
- JaCoCo GitHub repository: `https://github.com/jacoco/jacoco`
- JaCoCo Maven plugin: `https://www.jacoco.org/jacoco/trunk/doc/maven.html`
- Baeldung — JaCoCo Tutorial: `https://www.baeldung.com/jacoco`
- JaCoCo — Coverage counters (line, branch, instruction, method, class, complexity): `https://www.jacoco.org/jacoco/trunk/doc/counters.html`

**Python**
- `coverage.py` documentation: `https://coverage.readthedocs.io/en/latest/`
- `coverage.py` GitHub repository: `https://github.com/nedbat/coveragepy`
- `pytest-cov` plugin: `https://pytest-cov.readthedocs.io/en/latest/`
- `pytest-cov` GitHub repository: `https://github.com/pytest-dev/pytest-cov`
- Ned Batchelder — "Coverage.py: The Under-Covered Python Tool" (PyCon talk): `https://nedbatchelder.com/text/coveragepy.html`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| General | Gerard Meszaros — *xUnit Test Patterns: Refactoring Test Code* (Addison-Wesley, 2007) | The definitive reference on test patterns (test doubles taxonomy, test smells, fixture management, result verification strategies); language-agnostic concepts that apply to all three ecosystems; the test doubles taxonomy (dummy, stub, spy, mock, fake) used in this plan originates from this book |
| General | Steve Freeman & Nat Pryce — *Growing Object-Oriented Software, Guided by Tests* (Addison-Wesley, 2009) | TDD from the outside in: walking skeleton, acceptance tests driving development, mock-based interaction testing; while Java-focused, the design philosophy applies to Rust (trait-based design for testability) and Python (protocol-based testing); particularly relevant for the mocking session |
| General | Kent Beck — *Test Driven Development: By Example* (Addison-Wesley, 2002) | The foundational TDD book: red-green-refactor cycle, money example, xUnit example; establishes the testing philosophy that underlies modern test frameworks in all three languages |
| Python | Brian Okken — *Python Testing with pytest* (Pragmatic Bookshelf, 2nd ed., 2022) | Comprehensive pytest coverage: fixtures, parametrization, plugins, `conftest.py`, test configuration, marks, `pytest-xdist` for parallel execution, `pytest-cov` for coverage — fills the significant pytest gap in owned books |
| Java | Catalin Tudose — *JUnit in Action* (Manning, 3rd ed., 2021) | Deep JUnit 5 coverage: extensions model, parameterized tests, dynamic tests, nested tests, `@TempDir`, integration with Mockito, Testcontainers, and build tools — fills the gap beyond Evans's introduction |

---

## Study Plan — 7 Sessions

Estimated total: **16–21 hours**. One session per sub-topic. Sessions are ordered sequentially — built-in frameworks first (the foundation), then progressively more specialized testing techniques, ending with the cross-cutting tools (static analysis, code coverage) that integrate with everything else.

---

### Session 1 — Built-in Test Frameworks

**Goal:** understand how each language's standard test infrastructure works — Rust's `#[test]` attribute with `cargo test`, Java's JUnit 5 architecture, and Python's `unittest` and `pytest` — including test discovery, assertions, fixtures, and the unit-vs-integration test boundary.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 35 min | **Rust: `#[test]`, `cargo test`, and test organization.** Read Klabnik & Nichols Ch.11 pp. 215–242 (complete chapter: writing a test function, `assert!`/`assert_eq!`/`assert_ne!`, custom messages, `should_panic`, `Result<T,E>` in tests, controlling execution, test organization). Key insight: Rust's testing is built into the language and toolchain — no external framework needed. `#[test]` marks a function as a test, `#[cfg(test)]` compiles the test module only during `cargo test`. Unit tests live alongside source code in a `mod tests` block within each file (with access to private functions). Integration tests live in a top-level `tests/` directory and can only use the crate's public API. Doc-tests (code examples in `///` comments) are compiled and run as tests — ensuring documentation stays in sync with code. Tests run in parallel by default (`--test-threads=1` for serial). There is no built-in fixture system — setup/teardown is done with regular Rust functions and RAII (constructors/destructors). |
| 1.2 | 20 min | **Rust: doc-tests and advanced harness.** Read Blandy & Orendorff Ch.8 pp. 161–191 (integration tests, doc-tests). Read Gjengset Ch.6 pp. 85–90 (test harness, `#[cfg(test)]`, doctests). Key insight: doc-tests are unique to Rust — they serve as both documentation and tests. Code blocks in doc comments are extracted and compiled as integration tests. The `#[doc(hidden)]` attribute hides items from documentation while still allowing doc-tests. The test harness can be replaced (`harness = false` in `Cargo.toml`) for custom test runners like `libtest-mimic` or `datatest`. Gjengset discusses the distinction between `#[test]` functions (which the harness discovers and runs) and the harness itself (the `main` function generated by `cargo test`). |
| 1.3 | 35 min | **Java: JUnit 5 architecture and TDD.** Read Evans et al Ch.13 pp. 437–465 (testing fundamentals: TDD, test doubles taxonomy, JUnit 5 architecture). Key insight: JUnit 5 is modular — JUnit Platform (test discovery and execution engine), JUnit Jupiter (programming model: `@Test`, `@BeforeEach`, `@AfterEach`, `@BeforeAll`, `@AfterAll`, `@DisplayName`, `@Nested`, `@ParameterizedTest`, `@ExtendWith`), JUnit Vintage (backward compatibility with JUnit 4). The extension model replaces JUnit 4's `@Rule` and `@RunWith`. Test classes are ordinary Java classes — JUnit discovers them via classpath scanning. Assertions include `assertEquals`, `assertTrue`, `assertThrows`, `assertTimeout`, `assertAll` (for grouped assertions). `@Nested` inner classes create hierarchical test structures. Compare with Rust: Java tests are in separate `src/test/java` directory (by convention), while Rust unit tests sit alongside source code; Java has rich lifecycle hooks (`@BeforeEach`), while Rust relies on constructor functions. |
| 1.4 | 10 min | **Java: testing concurrent programs.** Skim Goetz et al Ch.12 pp. 247–255 (testing for correctness: BoundedBuffer test, testing blocking operations, testing safety with barriers). Key insight: testing concurrent code is uniquely challenging — tests must exercise timing-dependent behaviors. Goetz introduces techniques: using barriers to synchronize test threads, testing blocking operations with timed joins, interleaving assertions with concurrent execution. This is relevant because Java's threading model makes concurrent testing a significant concern that Rust's type system (Send/Sync) partially addresses at compile time. |
| 1.5 | 35 min | **Python: `unittest`, `doctest`, and `pytest`.** Read Martelli et al Ch.17 pp. 513–540 (unittest, doctest, pytest basics). Read Viafore Ch.21 pp. 297–313 (testing strategy, test categorization, AAA pattern). Key insight: Python has three testing approaches. `unittest` (stdlib) uses class-based tests extending `TestCase` — `setUp`/`tearDown` lifecycle, `self.assertEqual`/`self.assertRaises`, test discovery. `doctest` extracts and runs examples from docstrings (similar concept to Rust's doc-tests but less powerful — doctest simply compares output strings). `pytest` (third-party but de facto standard) uses plain functions and `assert` statements — no test classes needed, parametrization with `@pytest.mark.parametrize`, fixtures for dependency injection (powerful: scope control, autouse, conftest.py sharing), plugins ecosystem. Read the pytest fixtures and parametrize documentation online for depth beyond what Martelli covers. Compare with Rust: `pytest` fixtures are analogous to what Rust achieves via constructor functions + RAII, but with explicit dependency injection; Python's dynamic nature means test discovery is name-based (`test_*.py`), while Rust uses the `#[test]` attribute. |
| 1.6 | 15 min | **Python: `unittest.TestCase` in depth.** Read Slatkin Ch.13 pp. 533–545 (subclassing `TestCase`, setUp/tearDown, integration tests). Key insight: while `pytest` is dominant, `unittest.TestCase` remains important — many large codebases and the standard library itself use it. Slatkin covers practical patterns: using `TestCase` for test isolation, setUp/tearDown for fixture management, subTest for parameterized-like behavior, and integration tests that verify component interactions. |
| 1.7 | 20 min | **Cross-language comparison.** Build a comparison table of built-in testing: Rust — `#[test]` + `cargo test`, tests alongside source code, doc-tests, no external framework needed, parallel by default, RAII for fixtures; Java — JUnit 5, tests in separate directory, rich lifecycle annotations, extension model, requires build tool integration (Maven/Gradle); Python — `unittest` (stdlib, class-based) + `pytest` (third-party, function-based), doctest, fixtures via DI, test discovery by naming convention. Note the philosophical differences: Rust integrates testing into the compiler toolchain (testing is a first-class language concern), Java separates testing into a mature framework ecosystem (JUnit's modular architecture), Python provides a stdlib baseline (`unittest`) but the community converged on a third-party tool (`pytest`) that leverages Python's dynamic nature for simpler syntax. |

---

### Session 2 — Property-Based Testing

**Goal:** understand how property-based testing (PBT) works — generating random inputs to verify universal properties rather than specific examples — and compare `proptest` (Rust), `jqwik` (Java), and `hypothesis` (Python).

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **Rust: `proptest` and `quickcheck`.** Read Gjengset Ch.6 pp. 95–98 (proptest/quickcheck overview, test generation strategies). Read Matthews Ch.7 pp. 147–150 (proptest usage in integration tests). Key insight: Rust has two PBT frameworks. `quickcheck` (older, inspired by Haskell's QuickCheck) uses the `Arbitrary` trait — types that implement `Arbitrary` can be randomly generated. `proptest` (newer, more flexible) uses a strategy-based API: `prop_compose!` to build complex generators, `proptest!` macro to define property tests, automatic shrinking (finding minimal failing input). `proptest` strategies compose: `any::<String>()`, `0..100i32`, `prop::collection::vec(any::<u8>(), 0..256)`. Shrinking in `proptest` is value-based (shrinks the random seed), while `quickcheck` shrinks the generated value directly. `proptest` integrates with `#[test]` — no special test runner needed, just a `proptest!` block inside a test function. Read the `proptest` book online for comprehensive strategy documentation and the regression file mechanism (`.proptest-regressions`). |
| 2.2 | 30 min | **Java: `jqwik` for property-based testing.** Read Evans et al Ch.14 pp. 480–488 (property-based testing concepts — the principles apply even though Evans uses Clojure examples). Read the jqwik user guide online (Getting Started, Properties, Providers, Arbitraries, Combinators sections). Key insight: `jqwik` is a JUnit 5 test engine — property tests are annotated with `@Property` instead of `@Test`, and jqwik provides the JUnit Platform engine to discover and run them. Parameters annotated with `@ForAll` are automatically generated. Built-in providers cover all Java types; custom `Arbitrary<T>` implementations handle domain types. `Arbitraries.integers().between(1, 100)`, `Arbitraries.strings().alpha().ofLength(5)`. Combinators: `Combinators.combine(arb1, arb2).as((a, b) -> new Pair(a, b))`. Shrinking is automatic — jqwik finds the smallest failing example. Statistical checking with `@Property(tries = 10000)`. Compare with `proptest`: similar strategy/arbitrary concepts, but jqwik leverages Java annotations and JUnit 5 integration, while proptest uses Rust macros. |
| 2.3 | 30 min | **Python: Hypothesis.** Read Viafore Ch.23 pp. 327–345 (Hypothesis: strategies, `@given`, `@example`, shrinking, stateful testing). Key insight: Hypothesis is the most mature PBT library across all three languages. `@given(st.integers(), st.text())` generates random inputs for test parameters. Strategies compose: `st.lists(st.integers(), min_size=1, max_size=100)`. `@example(0, "")` pins specific edge cases alongside random generation. Shrinking is automatic and aggressive — Hypothesis finds the smallest/simplest failing input. Stateful testing (`RuleBasedStateMachine`) generates sequences of operations to test state machine invariants — more powerful than simple property tests. The Hypothesis database (`.hypothesis/`) caches failing examples across runs. Hypothesis integrates with `pytest` (and `unittest`). Profile settings control thoroughness: `settings(max_examples=1000)`. Read the Hypothesis documentation online for strategy reference and the stateful testing guide. Compare with proptest: both are strategy-based with automatic shrinking; Hypothesis is more mature (richer strategy library, stateful testing, settings profiles), while proptest has tighter Rust type system integration. |
| 2.4 | 15 min | **Cross-language comparison: PBT strategies.** Build a comparison: Rust `proptest` — macro-based (`proptest!`), strategy composition via `prop_compose!`, seed-based shrinking, regression files; Java `jqwik` — annotation-based (`@Property`, `@ForAll`), JUnit 5 engine integration, `Arbitrary<T>` providers, value-based shrinking; Python Hypothesis — decorator-based (`@given`), strategy composition via `st.*`, aggressive shrinking, stateful testing, database persistence. The key insight: all three share the same underlying idea (generate random inputs, check properties, shrink failures) but express it idiomatically — Rust uses macros and type inference, Java uses annotations and generics, Python uses decorators and dynamic typing. Python's Hypothesis is the most feature-rich, Java's jqwik has the best IDE integration (via JUnit 5), and Rust's proptest has the strongest type-safety (strategies are parameterized by output type). Consider which properties to test in each language: Rust's type system already prevents many classes of bugs (null, data races), so PBT focuses on logic/algorithm correctness; Java and Python PBT must also cover type-related edge cases (null inputs, wrong types). |

---

### Session 3 — Benchmarking

**Goal:** understand how to write reliable benchmarks in each language — `criterion` for Rust, JMH for Java, `timeit`/`pytest-benchmark` for Python — including the pitfalls that each runtime introduces (compiler optimizations, JIT warmup, GIL effects).

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 30 min | **Rust: `criterion` benchmarking.** Read Gjengset Ch.6 pp. 98–100 (criterion overview, setup, interpreting results). Read the `criterion` user guide online (Getting Started, Comparing Functions, Custom Measurements). Key insight: Rust's built-in `#[bench]` is unstable (nightly only); `criterion` is the standard alternative for stable Rust. `criterion` runs benchmarks in a separate process, applies statistical analysis (confidence intervals, outlier detection), generates HTML reports with iteration time distributions, and compares against previous runs for regression detection. Usage: `Criterion::default().bench_function("name", \|b\| b.iter(\|\| function_under_test()))`. `black_box()` prevents compiler optimization from eliminating dead code. Groups allow comparing multiple implementations. `criterion` also supports async benchmarks with `bench_function(\|b\| b.to_async(&runtime).iter(\|\| async_fn()))`. Compare with JMH: criterion runs out-of-process and uses wall-clock statistical analysis, while JMH uses in-process measurement with JVM warmup handling; both address dead code elimination (criterion's `black_box` vs JMH's `Blackhole`). Also note `divan` as a newer alternative with inline benchmarks. |
| 3.2 | 45 min | **Java: JMH (Java Microbenchmark Harness).** Read Oaks Ch.2 pp. 15–48 (performance testing approach, microbenchmarks, JMH introduction). Read Beckwith Ch.5 pp. 115–175 (JMH deep dive: benchmark modes, state objects, `@Setup`/`@TearDown`, `@Param`, `Blackhole`, profiling with perfasm). Key insight: JMH is essential for Java because the JVM's runtime behavior (JIT compilation, garbage collection, class loading) makes naive timing unreliable. JMH handles warmup iterations (allowing HotSpot to optimize), fork modes (isolating JVM state between benchmarks), dead code elimination prevention (`Blackhole.consume()`), and constant folding prevention. Benchmark modes: `Throughput` (ops/time), `AverageTime` (time/op), `SampleTime` (distribution), `SingleShotTime` (cold start). State objects with `@State(Scope.Thread)` or `@State(Scope.Benchmark)` manage shared/per-thread data. `@Param` enables parameterized benchmarks (e.g., different collection sizes). `@Setup(Level.Trial/Iteration/Invocation)` controls when setup runs. JMH is the gold standard for JVM microbenchmarking — understanding why each feature exists teaches deep lessons about JVM behavior. Read Goetz Ch.12 pp. 265–272 (performance testing pitfalls: GC, dynamic compilation, unrealistic contention, dead code elimination) for the underlying reasons JMH's design is necessary. |
| 3.3 | 10 min | **Java: JFR for performance profiling.** Skim Oaks Ch.3 pp. 49–70 (Java Flight Recorder: enabling, event types, analyzing recordings). Key insight: JFR is a built-in, low-overhead profiling tool that complements JMH — JMH measures benchmark throughput/latency, JFR explains why (which methods are hot, where GC pauses occur, which locks contend). JFR produces recordings that can be analyzed with JDK Mission Control. This is unique to Java — neither Rust nor Python has a comparable built-in always-on profiler. |
| 3.4 | 30 min | **Python: `timeit`, `cProfile`, and `pytest-benchmark`.** Read Martelli et al Ch.17 pp. 540–561 (timeit, cProfile). Read Shaw Ch.15 pp. 346–363 (timeit microbenchmarks, pyperformance, cProfile). Read Gorelick & Ozsvald Ch.2 pp. 21–64 (cProfile, SnakeViz, line_profiler, memory_profiler, PySpy). Key insight: Python benchmarking must account for the GIL, interpreter overhead, and the lack of JIT (in CPython). `timeit` provides basic microbenchmarking: `timeit.timeit(stmt, setup, number=1000000)` — it disables GC during measurement and takes the best-of-N approach. `cProfile` provides function-level profiling (cumulative time, call counts). `pytest-benchmark` (read documentation online) integrates benchmarking into the pytest workflow: `benchmark(func, *args)` fixture, statistical analysis (mean, median, stddev, IQR), comparison between runs, histogram generation, grouping. For memory profiling: `memory_profiler` tracks line-by-line memory usage. For production profiling: PySpy is a sampling profiler that attaches to running processes without code modification. Compare with Rust/Java: Python has the simplest benchmarking tools (reflecting its interpreted nature), but also the most variance in results (GIL, interpreter overhead). |
| 3.5 | 15 min | **Cross-language comparison: benchmarking philosophies.** Compare: Rust `criterion` — statistical analysis, out-of-process, regression detection, `black_box` for dead code, HTML reports; Java JMH — warmup handling (critical for JIT), fork modes (JVM isolation), `Blackhole`, state management, the most complex setup reflecting the most complex runtime; Python `timeit`/`pytest-benchmark` — simplest tools, GC-disabled measurement, statistical analysis in pytest-benchmark. The key insight: the sophistication of each language's benchmarking tools mirrors the complexity of its runtime. Rust's AOT compilation means benchmarks are stable after the first run; Java's JIT means results change during warmup (requiring explicit warmup phases); Python's interpreter means results are consistent but slow (requiring large iteration counts for precision). All three must address dead code elimination: Rust at compile time (LLVM optimization), Java at runtime (JIT optimization), Python rarely (interpreter does minimal optimization). |

---

### Session 4 — Mocking Strategies and Type System Effects

**Goal:** understand how each language's type system fundamentally shapes its mocking approach — Rust requires trait-based dependency injection because the compiler prevents monkey-patching, Java uses proxy-based runtime mocking enabled by reflection, and Python can replace any object attribute at runtime with `unittest.mock` — and the quality trade-offs each approach creates.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: trait-based mocking with `mockall`.** Read the `mockall` documentation online (Getting Started, Mocking Traits, Expectations, Return Values, Argument Matching). Read Alan Somers's "Rust Mock Shootout" blog post online. Key insight: Rust's type system prevents monkey-patching — you cannot replace a function or method at runtime. Mocking in Rust requires designing code for testability from the start: define behavior as traits, depend on traits rather than concrete types, and use `mockall` to generate mock implementations. `#[automock]` on a trait generates a `MockMyTrait` struct with expectation-setting methods: `mock.expect_method().with(eq(42)).returning(\|x\| x * 2)`. The mock is generic — it can be used anywhere the trait is expected. This forces better architecture: code naturally follows dependency inversion. The trade-off: Rust mocking is more verbose (must define traits for mockable boundaries) but catches mock misconfiguration at compile time (type mismatches, wrong argument types). Somers's "Rust Mock Shootout" compares alternatives: `mockall` (full-featured, auto-generated), `mock_derive`, `double` (manual trait-based), `faux` (attribute macros). Compare with Java: Rust cannot mock concrete types (no runtime reflection), while Java's Mockito can mock any non-final class. |
| 4.2 | 30 min | **Java: Mockito and proxy-based mocking.** Read Evans et al Ch.13 pp. 450–465 (test doubles: dummy, stub, fake, mock, spy — taxonomy and when to use each). Read the Mockito Javadoc online (the class-level Javadoc is a comprehensive usage guide with 40+ numbered examples). Read Baeldung "Mockito Tutorial" online. Key insight: Java's runtime reflection and dynamic proxy mechanism (or byte-buddy code generation for classes) enables Mockito to mock any interface or non-final class without requiring the target code to be designed for mocking. `Mockito.mock(UserService.class)` creates a mock at runtime. `when(mock.getUser(1L)).thenReturn(user)` sets up stubbing. `verify(mock, times(1)).getUser(1L)` verifies interactions. `@InjectMocks` auto-injects `@Mock` fields. Since Mockito 3.4+, `mockStatic(MyClass.class)` enables static method mocking (via `mockito-inline`). Mockito's `@Spy` creates a partial mock (real implementation with selective overrides). The trade-off: Java mocking is powerful and convenient (mock anything without redesigning code) but can enable poor design (testing implementation details via excessive `verify`, mocking concrete classes instead of interfaces). Compare with Rust: Java's approach is fundamentally different — runtime proxy generation vs compile-time trait-based generation. |
| 4.3 | 30 min | **Python: `unittest.mock` and monkey-patching.** Read Slatkin Ch.13 pp. 551–574 (mocking with `unittest.mock`: `Mock`, `MagicMock`, `patch`, `spec`, mocking dependencies, testing interactions). Read the Python `unittest.mock` documentation online. Key insight: Python's dynamic nature makes mocking trivial — any attribute of any object can be replaced at runtime. `unittest.mock.patch('module.ClassName')` replaces a class/function for the test's duration. `MagicMock` auto-creates attributes and return values on access — `mock.any_method()` just works (returns another `MagicMock`). `spec=RealClass` constrains the mock to the real class's interface (prevents typos in mock attribute access). `patch.object(instance, 'method')` patches a specific instance. `mock.assert_called_once_with(arg)` verifies interactions. The trade-off: Python mocking is the most flexible (mock anything, anywhere) but also the most dangerous — misspelled method names on mocks silently succeed (unless `spec` is used), and tests can pass even when the real interface changes (unless `autospec=True`). `autospec=True` is the Python equivalent of Java's type-checked mocking — it creates a mock that matches the real object's signature. Compare with Rust: Python mocking is the polar opposite — no design changes needed, maximum flexibility, minimum compile-time safety. |
| 4.4 | 25 min | **Cross-language comparison: type system effects on mocking.** Build a comparison showing how the type system drives mocking strategy. **Rust** (static, no reflection, no runtime modification): must design for testability (trait bounds), `mockall` generates code at compile time, type errors caught before test runs, mocking is verbose but safe, forces dependency inversion principle. **Java** (static + reflection + dynamic proxies): can mock almost anything at runtime (Mockito), no code redesign needed, type errors caught at runtime (test failure), convenient but can enable poor design, `final` classes block mocking (without byte-buddy inline agent). **Python** (dynamic, everything mutable at runtime): can replace literally anything (`patch`), no code redesign needed, no type checking on mocks unless `spec`/`autospec` used, maximum flexibility with maximum risk of test-production divergence. The meta-insight: the spectrum of mocking power is inversely correlated with compile-time safety. Rust forces good design but makes mocking harder; Python makes mocking trivial but provides no guardrails; Java sits in the middle. This is a microcosm of each language's overall philosophy. |

---

### Session 5 — Fuzzing

**Goal:** understand fuzz testing — feeding random, malformed, or unexpected inputs to find crashes, panics, and security vulnerabilities — using `cargo-fuzz`/libFuzzer (Rust), Jazzer (Java), and Atheris (Python), and how each language's safety guarantees affect what fuzzing can find.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: `cargo-fuzz` and structured fuzzing.** Read Matthews Ch.3 pp. 55–58 (cargo-fuzz setup, CI/CD integration). Read Matthews Ch.7 pp. 150–154 (fuzz testing in practice). Read the Rust Fuzz Book online (Introduction, `cargo-fuzz` Tutorial, Trophy Case). Key insight: `cargo-fuzz` wraps LLVM's libFuzzer — it instruments the compiled code to track coverage and evolves inputs toward uncovered code paths. `cargo fuzz init` creates a `fuzz/` directory; `cargo fuzz add target_name` creates a fuzz target: `fuzz_target!(|data: &[u8]| { /* exercise code with data */ })`. The `arbitrary` crate enables structured fuzzing — instead of raw bytes, generate structured types: `fuzz_target!(|input: MyStruct| { ... })` where `MyStruct` derives `Arbitrary`. Fuzzing in Rust finds: panics (`unwrap()` on `None`/`Err`), integer overflows (in debug mode), logic errors, and (with `unsafe`) memory safety bugs. Unlike C/C++ fuzzing (which finds undefined behavior), Rust fuzzing primarily finds logic errors because safe Rust prevents memory corruption. The corpus (set of interesting inputs) is maintained across runs, enabling continuous fuzzing. OSS-Fuzz integrates `cargo-fuzz` for continuous fuzzing of open-source Rust projects. |
| 5.2 | 25 min | **Java: Jazzer.** Read the Jazzer GitHub repository documentation online (Getting Started, Writing Fuzz Tests, JUnit integration). Key insight: Jazzer brings libFuzzer-style coverage-guided fuzzing to the JVM. Jazzer instruments JVM bytecode at runtime to track coverage. Two modes: (1) standalone mode — `public static void fuzzerTestOneInput(byte[] data)` entry point, (2) JUnit integration — `@FuzzTest void myFuzz(byte[] data)` annotated methods run as JUnit tests (with a seed corpus for regression). Jazzer can detect: uncaught exceptions, `OutOfMemoryError`, security policy violations, and (via sanitizers) SQL injection, OS command injection, LDAP injection, deserialization gadget chains. The "autofuzz" mode automatically generates fuzz targets for public API methods — no manual fuzz harness needed. Jazzer's JUnit integration means fuzz tests can run as regular unit tests in CI (with the corpus as test inputs) and as real fuzzing sessions locally. Compare with Rust: Java fuzzing must account for JVM startup overhead, exception handling (not just crashes), and the broader attack surface (deserialization, injection); Rust fuzzing is faster (native code) and finds different bug classes (panics vs exceptions). |
| 5.3 | 25 min | **Python: Atheris.** Read the Atheris GitHub repository documentation online (Installation, Usage, Coverage Guidance). Read the Google Security Blog post "Atheris: A Coverage-Guided Python Fuzzing Engine." Key insight: Atheris instruments CPython bytecode to track coverage and uses libFuzzer's mutation engine. Usage: `atheris.Setup(sys.argv, fuzz_target)` + `atheris.Fuzz()` where `fuzz_target(data: bytes)` exercises the code. Atheris can be combined with Hypothesis: `@given(st.from_type(bytes))` generates structured inputs with property-based testing, while Atheris provides coverage-guided mutation for finding deeper bugs. Atheris finds: uncaught exceptions, assertion errors, and (when fuzzing C extensions via `atheris.instrument_func`) memory safety bugs in native code. The key challenge: Python's interpreter overhead means fuzzing is slower than Rust/Java (10–100x fewer executions per second). Mitigation: fuzz the C extension layer directly (where most security-critical code lives in CPython). OSS-Fuzz supports Python via Atheris. Compare with Rust: Atheris is structurally similar (both wrap libFuzzer) but much slower; Rust fuzzing is primarily about finding logic errors in safe code, while Python fuzzing is often about finding crashes in C extensions. |
| 5.4 | 15 min | **Cross-language comparison: what fuzzing finds.** Build a comparison table. **Rust**: `cargo-fuzz`/libFuzzer, native speed, finds panics/logic errors in safe code and memory bugs in unsafe code, structured fuzzing via `arbitrary` crate, continuous fuzzing via OSS-Fuzz. **Java**: Jazzer, JVM-speed (slower than native, faster than interpreted), finds exceptions/injection vulnerabilities/deserialization issues, JUnit integration for CI, autofuzz for API coverage. **Python**: Atheris, interpreter-speed (slowest), finds exceptions in Python code and memory bugs in C extensions, can combine with Hypothesis for structured fuzzing. The meta-insight: each language's safety guarantees determine what fuzzing can find. In safe Rust, fuzzing cannot find memory corruption (the compiler prevents it) — it finds logic errors. In Java, fuzzing cannot find buffer overflows (the JVM prevents them) — it finds exception paths and injection vulnerabilities. In Python, fuzzing the Python layer finds exception paths, but fuzzing C extensions (the performance-critical code) can find real memory corruption. The value of fuzzing is inversely related to the language's safety guarantees at each layer. |

---

### Session 6 — Static Analysis

**Goal:** understand how each language's static analysis tools work — Clippy for Rust, SpotBugs/Error Prone for Java, Ruff/Pylint for Python — and how the type system determines how much the analyzer can catch before runtime.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **Rust: Clippy and Miri.** Read Matthews Ch.3 pp. 43–55 (Clippy lints, configuration, lint groups). Read Gjengset Ch.6 pp. 90–95 (Clippy, Miri, sanitizers). Key insight: Clippy is Rust's official linter — it has 700+ lints organized into groups: `clippy::correctness` (definite bugs), `clippy::suspicious` (likely bugs), `clippy::style` (non-idiomatic code), `clippy::complexity` (unnecessarily complex code), `clippy::perf` (performance improvements), `clippy::pedantic` (stricter but opinionated). Configure via `#![allow(clippy::lint_name)]` or `clippy.toml`. Clippy leverages the Rust compiler's type information — it can reason about ownership, lifetimes, and generics in ways that external linters for Java/Python cannot. Miri is a separate tool: an interpreter for Rust's Mid-level Intermediate Representation (MIR) that detects undefined behavior in `unsafe` code — memory leaks, data races, invalid pointer dereferences, uninitialized memory use. Miri runs code symbolically, which is slow but thorough. AddressSanitizer (ASan) and ThreadSanitizer (TSan) provide runtime instrumentation for detecting memory and threading errors in `unsafe` code and FFI. Read the Clippy lint list online and the Miri GitHub README for comprehensive understanding. |
| 6.2 | 30 min | **Java: SpotBugs, Error Prone, and PMD.** Read Valeev Ch.1 pp. 1–18 (static analysis landscape: SpotBugs, Error Prone, PMD, SonarLint, CodeQL, mutation coverage). Key insight: Java has multiple overlapping static analysis tools. **SpotBugs** (successor to FindBugs) analyzes bytecode — it finds null dereferences, infinite loops, threading issues, performance problems, and security vulnerabilities without needing source code. **Error Prone** (by Google) is a compiler plugin — it runs during `javac` compilation and produces compile errors/warnings for common bug patterns (e.g., `String.equals()` argument order, `@Override` missing, incorrect `DateFormat` usage). Error Prone's advantage: it can be made a hard build failure (treating bugs as compile errors). **PMD** analyzes source code for style violations, dead code, overcomplicated expressions, and copy-paste detection (CPD). **SonarQube** aggregates multiple analyzers into a quality dashboard with quality gates for CI/CD. Read the SpotBugs bug descriptions and Error Prone bug patterns online. Compare with Rust: Java's static analysis tools compensate for what the type system misses (null safety, threading issues) — Clippy has fewer bug-finding lints because the Rust compiler already prevents many bug categories. |
| 6.3 | 30 min | **Python: Ruff, Pylint, and type checkers.** Read Viafore Ch.20 pp. 285–296 (Pylint, custom plugins, security analyzers). Read the Ruff documentation online (Getting Started, Rules, Configuration). Key insight: Python's dynamic typing creates a much larger space for static analysis to explore. **Ruff** (written in Rust, released 2022) has become the dominant Python linter — it reimplements rules from Pylint, pyflakes, pycodestyle, isort, pydocstyle, and dozens of other tools in a single fast binary (10–100x faster than Pylint). Ruff configuration in `pyproject.toml`: `[tool.ruff]` section, `select`/`ignore` rules, per-file-ignores. **Pylint** (older, comprehensive) performs deep analysis: type inference (limited), unreachable code, wrong-import-order, too-many-arguments, plus custom plugins for domain-specific rules. **mypy/pyright** are type checkers (not linters) — they verify type annotations (PEP 484) at analysis time, catching type errors before runtime. **Bandit** scans for security issues (hardcoded passwords, SQL injection, insecure random number generation). Read the Ruff rules reference online. Compare with Rust/Java: Python needs more static analysis tools because the language provides fewer compile-time guarantees — type checkers (mypy) approximate what Rust/Java compilers provide for free; Ruff/Pylint catch issues that Clippy catches plus issues that Rust's compiler prevents entirely. |
| 6.4 | 15 min | **Cross-language comparison: static analysis spectrum.** Build a comparison. **Rust**: Clippy (700+ lints, type-aware), Miri (UB detection for unsafe), ASan/TSan (runtime sanitizers); the compiler itself is the primary static analyzer — Clippy extends it. **Java**: SpotBugs (bytecode analysis), Error Prone (compiler plugin), PMD (source analysis), SonarQube (dashboard aggregation); multiple tools compensate for what `javac` misses (null safety, threading). **Python**: Ruff (fast, multi-rule linter), Pylint (deep analysis, custom plugins), mypy/pyright (type checking), Bandit (security); the most tools needed because the interpreter provides the fewest compile-time guarantees. The meta-insight: the number and power of static analysis tools in a language's ecosystem is inversely proportional to the power of its type system. Rust needs the least external static analysis (the compiler catches the most), Python needs the most (the interpreter catches the least), Java is in between. However, even Rust benefits from Clippy's idiomatic-code lints — static analysis is not just about bug-finding but also about code quality and consistency. |

---

### Session 7 — Code Coverage Tools and Integration

**Goal:** understand code coverage measurement in each language — what it means (line, branch, instruction, condition coverage), how to measure it (`cargo-tarpaulin`/`llvm-cov` for Rust, JaCoCo for Java, `coverage.py`/`pytest-cov` for Python), and how to integrate coverage with CI/CD without falling into the coverage-as-a-goal trap.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 25 min | **Rust: `cargo-tarpaulin` and `cargo-llvm-cov`.** Read Matthews Ch.6 pp. 135–140 (code coverage with cargo-tarpaulin). Read the `cargo-tarpaulin` and `cargo-llvm-cov` GitHub READMEs online. Read the Rust source-based code coverage documentation online. Key insight: Rust has two coverage approaches. **`cargo-tarpaulin`** — Linux-specific, uses ptrace or LLVM instrumentation, generates lcov/HTML/Coveralls reports; simpler to set up but Linux-only and can be less accurate with complex generic code. **`cargo-llvm-cov`** — wraps LLVM's source-based code coverage instrumentation (`-C instrument-coverage` flag); works on all platforms, provides precise line and region coverage, integrates with `llvm-cov` for report generation. LLVM source-based coverage inserts counters at compile time and records which code regions execute — this is the same technology used by LLVM-based C/C++ coverage. Coverage reports can be generated in lcov, HTML, or Cobertura format for CI integration. Limitations: coverage of generic code depends on which monomorphizations are exercised; macro-generated code coverage can be misleading (shows macro expansion, not source). Compare with Java: Rust coverage measures the actual compiled machine code, while JaCoCo instruments JVM bytecode — both are accurate but operate at different abstraction levels. |
| 7.2 | 30 min | **Java: JaCoCo.** Read the JaCoCo documentation online (Coverage Counters, Agent, Maven Plugin, Report). Read Baeldung "JaCoCo Tutorial" online. Read Valeev Ch.1 pp. 14–18 (mutation coverage as a complement to line coverage). Key insight: JaCoCo is the standard Java code coverage tool. It uses a Java agent (`-javaagent:jacocoagent.jar`) to instrument bytecode at class-load time — no source modification needed. JaCoCo measures six types of coverage: (1) instruction coverage (JVM bytecode instructions), (2) branch coverage (if/switch decisions), (3) line coverage, (4) method coverage, (5) class coverage, (6) cyclomatic complexity. Reports are generated in HTML, XML (for CI/CD), or CSV. Maven integration: `jacoco-maven-plugin` with `prepare-agent` and `report` goals. Minimum coverage enforcement: `check` goal with rules (e.g., `BUNDLE` element, `LINE` counter, `COVEREDRATIO` minimum of 0.80). JaCoCo's agent-based approach means it works with any JVM language (Kotlin, Scala, Groovy) and any test framework. Limitation: JaCoCo cannot measure coverage of native methods, and JIT-optimized paths may behave differently than instrumented paths. Mutation testing (`pitest`) complements coverage by asking "do tests detect changes?" rather than "do tests exercise code?" — Valeev discusses this distinction. |
| 7.3 | 25 min | **Python: `coverage.py` and `pytest-cov`.** Read Martelli et al Ch.17 pp. 555–561 (coverage basics). Read the `coverage.py` documentation online (Quick Start, Configuration, Branch Coverage). Read the `pytest-cov` documentation online. Key insight: `coverage.py` (by Ned Batchelder) is the standard Python coverage tool. It instruments Python bytecode execution by setting a trace function (`sys.settrace`) or using `sys.monitoring` (Python 3.12+). `coverage run -m pytest` runs tests with coverage. `coverage report` shows line coverage. `coverage html` generates an HTML report. Branch coverage (`--branch` flag) tracks which branches of `if`/`for`/`while`/`try` are taken. `.coveragerc` or `pyproject.toml` `[tool.coverage]` configures source directories, omissions, and minimum thresholds. `pytest-cov` integrates coverage into pytest: `pytest --cov=mypackage --cov-report=html`. `--cov-fail-under=80` enforces minimum coverage. Plugins: `coverage-conditional-plugin` for platform-specific code, `diff-cover` for measuring coverage of only changed lines (useful for PRs). Python 3.12+'s `sys.monitoring` provides lower-overhead coverage instrumentation. Compare with Rust/Java: Python coverage is purely runtime (trace function), while Rust uses compile-time instrumentation and JaCoCo uses bytecode instrumentation at class-load time — Python's approach is the slowest but works without any build system integration. |
| 7.4 | 20 min | **Mutation testing as coverage complement.** Read Viafore Ch.24 pp. 347–365 (mutation testing with `mutmut`). Read Valeev Ch.1 pp. 14–18 (mutation coverage for Java). Key insight: code coverage tells you "which code was executed during tests" but NOT "whether the tests would fail if the code were wrong." Mutation testing addresses this by making small changes (mutations) to the source code and checking whether the test suite catches them. `mutmut` (Python) — modifies Python AST (replaces `+` with `-`, `True` with `False`, etc.) and runs the test suite for each mutation; surviving mutations indicate weak tests. `pitest` (Java) — bytecode-level mutations, integrates with Maven/Gradle, generates HTML reports showing which mutations survived. Rust mutation testing: `cargo-mutants` (newer tool) applies source-level mutations. Mutation testing is slow (runs the full test suite per mutation) but provides the highest-quality signal about test effectiveness. Compare across languages: the concept is identical, but implementation differs — Python mutates AST, Java mutates bytecode, Rust mutates source. |
| 7.5 | 15 min | **CI/CD integration and coverage best practices.** Read Matthews Ch.3 pp. 58–62 (CI/CD integration). Key insight: coverage tools across all three languages produce standardized report formats (lcov, Cobertura XML) that integrate with CI services (GitHub Actions, GitLab CI, Codecov, Coveralls). Best practices: (1) set minimum coverage thresholds as quality gates (but 100% coverage is not a goal — some code is not worth testing), (2) track coverage trends over time (alert on coverage decreases, not absolute numbers), (3) use branch coverage, not just line coverage (line coverage misses untested branches), (4) combine with mutation testing periodically for higher-quality signal, (5) exclude generated code and test code from coverage calculations. Coverage anti-patterns: writing tests solely to increase coverage numbers (tests that exercise code but don't assert anything meaningful), chasing 100% coverage on error-handling code that is difficult to trigger, and using coverage as a quality metric rather than a diagnostic tool. |
| 7.6 | 15 min | **Cross-language comparison: coverage tools.** Build a comparison. **Rust**: `cargo-tarpaulin` (Linux, ptrace/LLVM), `cargo-llvm-cov` (all platforms, LLVM instrumentation), `cargo-mutants` (mutation testing); compile-time instrumentation, precise but monomorphization-dependent. **Java**: JaCoCo (bytecode agent, six coverage types, Maven/Gradle integration), `pitest` (mutation testing, bytecode-level); runtime agent instrumentation, works across JVM languages. **Python**: `coverage.py` + `pytest-cov` (trace function / sys.monitoring), `mutmut` (mutation testing, AST-level); runtime trace, slowest but simplest setup. The key insight: all three ecosystems have converged on similar workflows (measure coverage → generate reports → enforce thresholds in CI → complement with mutation testing) despite radically different implementation mechanisms. The coverage tools reflect each language's execution model: compile-time instrumentation for Rust, class-load-time instrumentation for Java, runtime tracing for Python. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Built-in test frameworks | Klabnik 215–242; Blandy 161–191; Gjengset 85–90; Evans 437–465; Goetz 247–255; Martelli 513–540; Viafore 297–313; Slatkin 533–545 | Rust Book Ch.11, JUnit 5 User Guide, pytest docs (fixtures, parametrize) |
| 2 | Property-based testing | Gjengset 95–98; Matthews 147–150; Evans 480–488; Viafore 327–345 | `proptest` book, jqwik user guide, Hypothesis docs |
| 3 | Benchmarking | Gjengset 98–100; Oaks 15–88; Beckwith 115–175; Goetz 265–272; Martelli 540–561; Shaw 346–363; Gorelick 21–64 | `criterion` user guide, JMH samples, `pytest-benchmark` docs |
| 4 | Mocking strategies | Evans 450–465; Slatkin 551–574 | `mockall` docs, Somers "Mock Shootout", Mockito Javadoc, `unittest.mock` docs |
| 5 | Fuzzing | Matthews 55–58, 150–154 | Rust Fuzz Book, Jazzer GitHub, Atheris GitHub, OSS-Fuzz docs |
| 6 | Static analysis | Matthews 43–55; Gjengset 90–95; Valeev 1–18; Viafore 285–296 | Clippy lint list, Miri GitHub, Error Prone bug patterns, Ruff rules reference |
| 7 | Code coverage and integration | Matthews 135–140, 58–62; Valeev 14–18; Viafore 347–365; Martelli 555–561 | `cargo-llvm-cov` GitHub, JaCoCo docs, `coverage.py` docs, `pytest-cov` docs |

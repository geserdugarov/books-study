# Layer 3 · Topic 10 — Module System & Code Organization

> Comparative study of Rust, Java, and Python: how each language organizes code into modules and packages, controls visibility and encapsulation boundaries, manages external dependencies, enforces API compatibility through semantic versioning, and uses conditional compilation and feature flags to shape the public API surface.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.7 pp. 119–140 | Packages and crates, defining modules to control scope and privacy, paths for referring to items in the module tree, `pub` keyword, `super`, making structs and enums public, `use` keyword, idiomatic `use` paths, `as` keyword, re-exporting with `pub use`, external packages, nested paths, glob operator, separating modules into different files |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.14 pp. 295–313 | Customizing builds with release profiles, publishing a crate to crates.io (documentation comments, `pub use` for re-exports, setting up account, adding metadata, publishing, deprecating), Cargo workspaces, `cargo install`, extending Cargo with custom commands |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.8 pp. 161–191 | Crates, build profiles, modules, paths and imports, standard prelude, turning programs into libraries, `src/bin` directory, tests and documentation (integration tests, doc-tests), dependencies (versions, Cargo.lock), publishing, workspaces |
| Rust | Gjengset (2022) — *Rust for Rustaceans* | Ch.5 pp. 67–84 | Features (defining, including, using features in your crate), workspaces, project configuration (crate metadata, build configuration), conditional compilation with `#[cfg]`, versioning (minimum supported Rust version, minimal dependency versions, changelogs, unreleased versions) |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.2 pp. 11–42 | Cargo tour (creating projects, building/running/testing, toolchains), dependency management (Cargo.lock), feature flags, patching dependencies, publishing crates (CI/CD integration), linking to C libraries, binary distribution (cross-compilation, static linking), documenting Rust projects, modules, workspaces, custom build scripts |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.4 pp. 55–68 (partial: §4.8 pp. 63, §4.9 pp. 64) | Packages (declaring packages, static imports, package scope), JAR files (creating, manifest, executable JARs, multi-release JARs) |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.12 pp. 150–166 | The Java Platform Module System (JPMS): module concept, naming modules, modular "Hello World", requiring modules, exporting packages, modular JARs, modules and reflective access, automatic modules, unnamed module, command-line flags for migration, transitive and static requirements, qualified exporting and opening, service loading, tools for working with modules |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.2 pp. 26–54 | Project Jigsaw, module graph, access control, basic module syntax (exporting, requiring, transitivity), platform modules, application modules, unnamed module, building a first modular app, command-line switches, reflection, split packages, multi-release JARs |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.3 pp. 69–97 | Evolution from monolithic to modular Java, JPMS compilation and run details, implementing modular services with JDK 17, JAR hell versioning problem and Jigsaw layers, OSGi comparison, jdeps/jlink/jdeprscan/jmod tools, performance implications |
| Java | Bloch (2018) — *Effective Java* | Ch.4 pp. 73–115 (partial: Items 15, 16, 24, 25) | Item 15: Minimize the accessibility of classes and members (pp. 73–77); Item 16: In public classes, use accessor methods, not public fields (pp. 78–79); Item 24: Favor static member classes over nonstatic (pp. 112–114); Item 25: Limit source files to a single top-level class (pp. 115) |
| Python | Slatkin (2025) — *Effective Python* | Ch.14 pp. 575–626 | Item 116: Know where to find community-built modules (pp. 575); Item 117: Use virtual environments for isolated and reproducible dependencies (pp. 576–581); Item 118: Write docstrings for every function, class, and module (pp. 582–587); Item 119: Use packages to organize modules and provide stable APIs (pp. 588–592); Item 120: Consider module-scoped code to configure deployment environments (pp. 593–594); Item 121: Define a root exception to insulate callers from APIs (pp. 595–599); Item 122: Know how to break circular dependencies (pp. 600–604); Item 123: Consider warnings to refactor and migrate usage (pp. 605–612); Item 124: Consider static analysis via typing to obviate bugs (pp. 613–620); Item 125: Prefer open source projects for bundling Python programs over zipimport and zipapp (pp. 621–626) |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.7 pp. 221–245 | Module objects, module loading (finders, loaders, sys.path), packages (regular and namespace packages), `__init__.py`, distribution utilities (distutils/setuptools), pip, wheels, pyproject.toml, virtual environments |
| Python | Viafore (2021) — *Robust Python* | Ch.16 pp. 225–241 | Relationships between code units, types of dependencies (physical, logical, temporal), visualizing dependency graphs (packages, imports, function calls), interpreting dependency graphs to identify problematic coupling |

### Coverage Gaps

The owned books **do not** cover:

- **Rust's fine-grained visibility modifiers beyond `pub`** — Klabnik and Blandy cover `pub` and private (default), but the intermediate visibility levels `pub(crate)`, `pub(super)`, and `pub(in path)` are only briefly mentioned; the full semantics and design rationale for choosing among these modifiers requires the Rust Reference and the Cargo Book
- **Python modern dependency management tooling (uv, poetry, PDM)** — Martelli covers pip/setuptools/wheels, and Slatkin covers virtual environments and PyPI, but none of the owned books cover modern tools like `uv` (Astral), `poetry`, `PDM`, or `hatch` that have become the preferred tooling for dependency management and lockfile generation in the Python ecosystem; the packaging landscape has shifted substantially since these books were published
- **Semantic versioning enforcement and API compatibility checking across all three languages** — Gjengset discusses versioning strategy and MSRV policy for Rust, but automated semver checking (`cargo-semver-checks`), Java's binary compatibility rules (JLS Chapter 13), and Python's approach to API deprecation beyond Slatkin's Item 123 (`warnings`) require external tooling documentation and language specification references
- **Conditional compilation in Java and Python** — Gjengset covers Rust's `#[cfg]` attributes and Cargo features thoroughly, but there is no equivalent coverage of Java's conditional compilation mechanisms (annotation processing, build-time code generation, Maven/Gradle profiles) or Python's platform-conditional code (`sys.platform`, optional imports, build backends with platform-specific dependencies) in the owned books
- **Maven and Gradle dependency management** — the owned books focus on JPMS and package-level organization but do not cover Maven POM structure, Gradle build scripts, dependency resolution algorithms, or the Maven Central/Gradle Plugin Portal ecosystems; Evans Ch.11 (pp. 345–399) covers this but is in the build systems topic, not repeated here; dedicated Maven/Gradle resources are needed for the dependency management session
- **Python namespace packages (PEP 420) and import system internals** — Martelli briefly covers namespace packages but the full mechanics of `importlib`, custom finders/loaders, the import hook system, and namespace packages without `__init__.py` require the Python importlib documentation and PEP 302/PEP 451
- **Cross-language comparison of API surface management** — no owned book provides a systematic comparison of how Rust's `pub use` re-exports, Java's `exports` directive in `module-info.java`, and Python's `__all__` variable control the public API surface; this requires synthesis from individual language references

---

## External Resources

### Sub-topic 1 — Module System Fundamentals

**Rust**
- The Rust Reference — Modules: `https://doc.rust-lang.org/reference/items/modules.html`
- The Rust Reference — Crates and Source Files: `https://doc.rust-lang.org/reference/crates-and-source-files.html`
- Rust By Example — Modules: `https://doc.rust-lang.org/rust-by-example/mod.html`
- The Cargo Book — Package Layout: `https://doc.rust-lang.org/cargo/guide/project-layout.html`

**Java**
- Java Language Specification — Packages and Modules (JLS Ch.7): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-7.html`
- Oracle Java Tutorial — Creating and Using Packages: `https://docs.oracle.com/javase/tutorial/java/package/packages.html`
- Baeldung — Guide to Java Packages: `https://www.baeldung.com/java-packages`

**Python**
- Python docs — The Import System: `https://docs.python.org/3/reference/import.html`
- Python docs — Modules tutorial: `https://docs.python.org/3/tutorial/modules.html`
- PEP 328 — Imports: Multi-Line and Absolute/Relative: `https://peps.python.org/pep-0328/`
- Real Python — Python Modules and Packages: An Introduction: `https://realpython.com/python-modules-packages/`

### Sub-topic 2 — Visibility and Access Control

**Rust**
- The Rust Reference — Visibility and Privacy: `https://doc.rust-lang.org/reference/visibility-and-privacy.html`
- Rust By Example — Visibility: `https://doc.rust-lang.org/rust-by-example/mod/visibility.html`
- The Cargo Book — Cargo Targets (lib, bin, example, test, bench): `https://doc.rust-lang.org/cargo/reference/cargo-targets.html`

**Java**
- Java Language Specification — Access Control (JLS 6.6): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-6.html#jls-6.6`
- Oracle Java Tutorial — Controlling Access to Members of a Class: `https://docs.oracle.com/javase/tutorial/java/javaOO/accesscontrol.html`
- Baeldung — Access Modifiers in Java: `https://www.baeldung.com/java-access-modifiers`

**Python**
- Python docs — Private Variables (name mangling): `https://docs.python.org/3/tutorial/classes.html#private-variables`
- PEP 8 — Naming Conventions: `https://peps.python.org/pep-0008/#naming-conventions`
- Real Python — Python's Property Attribute and Encapsulation: `https://realpython.com/python-property/`

### Sub-topic 3 — Code Organization Patterns and Project Structure

**Rust**
- The Cargo Book — Project Layout: `https://doc.rust-lang.org/cargo/guide/project-layout.html`
- The Cargo Book — Workspaces: `https://doc.rust-lang.org/cargo/reference/workspaces.html`
- Rust API Guidelines — Organization: `https://rust-lang.github.io/api-guidelines/organization.html`

**Java**
- Oracle Java Tutorial — Module System Quick-Start Guide: `https://openjdk.org/projects/jigsaw/quick-start`
- Baeldung — A Guide to Java 9 Modularity: `https://www.baeldung.com/java-9-modularity`
- Maven — Standard Directory Layout: `https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html`

**Python**
- Python Packaging User Guide — Packaging Python Projects: `https://packaging.python.org/en/latest/tutorials/packaging-projects/`
- Python docs — `__init__.py` and regular packages: `https://docs.python.org/3/reference/import.html#regular-packages`
- PEP 420 — Implicit Namespace Packages: `https://peps.python.org/pep-0420/`
- Real Python — Python Application Layouts: `https://realpython.com/python-application-layouts/`

### Sub-topic 4 — Dependency Management

**Rust**
- The Cargo Book — Specifying Dependencies: `https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html`
- The Cargo Book — The Manifest Format (Cargo.toml): `https://doc.rust-lang.org/cargo/reference/manifest.html`
- The Cargo Book — Dependency Resolution: `https://doc.rust-lang.org/cargo/reference/resolver.html`
- The Cargo Book — Cargo.lock: `https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html`

**Java**
- Maven — Introduction to the Dependency Mechanism: `https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html`
- Gradle — Dependency Management: `https://docs.gradle.org/current/userguide/dependency_management.html`
- Gradle — Dependency Resolution: `https://docs.gradle.org/current/userguide/dependency_resolution.html`
- Baeldung — Maven vs Gradle: `https://www.baeldung.com/ant-maven-gradle`

**Python**
- Python Packaging User Guide (PyPA): `https://packaging.python.org/`
- PEP 621 — Storing project metadata in pyproject.toml: `https://peps.python.org/pep-0621/`
- PEP 665 — A file format to list Python dependencies for reproducibility of an application: `https://peps.python.org/pep-0665/`
- uv documentation: `https://docs.astral.sh/uv/`
- Poetry documentation: `https://python-poetry.org/docs/`

### Sub-topic 5 — Java Platform Module System (JPMS) Deep Dive

**Java**
- JEP 261 — Module System: `https://openjdk.org/jeps/261`
- JEP 200 — The Modular JDK: `https://openjdk.org/jeps/200`
- JEP 220 — Modular Run-Time Images: `https://openjdk.org/jeps/220`
- Oracle — Understanding Java 9 Modules: `https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/module/ModuleDescriptor.html`
- Baeldung — Java 9 Module System: `https://www.baeldung.com/java-9-modularity`
- Baeldung — Java 9 ServiceLoader: `https://www.baeldung.com/java-spi`

### Sub-topic 6 — Conditional Compilation and Feature Flags

**Rust**
- The Rust Reference — Conditional Compilation: `https://doc.rust-lang.org/reference/conditional-compilation.html`
- The Cargo Book — Features: `https://doc.rust-lang.org/cargo/reference/features.html`
- The Cargo Book — Build Scripts: `https://doc.rust-lang.org/cargo/reference/build-scripts.html`
- Rust By Example — cfg: `https://doc.rust-lang.org/rust-by-example/attribute/cfg.html`

**Java**
- Baeldung — Maven Profiles: `https://www.baeldung.com/maven-profiles`
- Gradle — Build Variants: `https://docs.gradle.org/current/userguide/variant_model.html`

**Python**
- Python docs — sys.platform: `https://docs.python.org/3/library/sys.html#sys.platform`
- Python docs — platform module: `https://docs.python.org/3/library/platform.html`
- packaging.python.org — Platform-specific dependencies: `https://packaging.python.org/en/latest/specifications/dependency-specifiers/`

### Sub-topic 7 — Semantic Versioning and API Compatibility

**Rust**
- Semantic Versioning specification: `https://semver.org/`
- The Cargo Book — SemVer Compatibility: `https://doc.rust-lang.org/cargo/reference/semver.html`
- cargo-semver-checks documentation: `https://docs.rs/cargo-semver-checks/latest/cargo_semver_checks/`
- Rust API Guidelines — Necessities (C-STABLE): `https://rust-lang.github.io/api-guidelines/necessities.html`

**Java**
- Java Language Specification — Binary Compatibility (JLS Ch.13): `https://docs.oracle.com/javase/specs/jls/se21/html/jls-13.html`
- Oracle — Java SE Compatibility Guide: `https://docs.oracle.com/en/java/javase/21/migrate/`
- Baeldung — Backward Compatibility in Java: `https://www.baeldung.com/java-backward-compatibility`

**Python**
- PEP 387 — Backwards Compatibility Policy: `https://peps.python.org/pep-0387/`
- Python docs — warnings module: `https://docs.python.org/3/library/warnings.html`
- packaging.python.org — Version Specifiers: `https://packaging.python.org/en/latest/specifications/version-specifiers/`
- PEP 440 — Version Identification and Dependency Specification: `https://peps.python.org/pep-0440/`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Java | Benjamin J. Evans, Jason R. Clark, Martijn Verburg — *The Well-Grounded Java Developer* (Manning, 2022), Ch.11 pp. 345–399 | Covers Maven lifecycle, POM, dependency management, plugins, and Gradle tasks, plugins, dependencies, Kotlin DSL — essential for Session 4 on dependency management; already owned but indexed under Topic 2, so the relevant chapter should be revisited here |
| General | Dustin Boswell, Trevor Foucher — *The Art of Readable Code* (O'Reilly, 2011) | Practical guidance on code organization, naming, and module decomposition that applies across all three languages; complements the structural/mechanical aspects of module systems with the human readability dimension |
| Python | Dane Hillard — *Publishing Python Packages* (Manning, 2023) | Comprehensive coverage of modern Python packaging: pyproject.toml, build backends (setuptools, flit, hatch), publishing to PyPI, versioning strategies, CI/CD for package releases — fills the gap in owned books regarding modern Python packaging practices |
| Rust | Eric Smith — *Programming Rust, 2nd Edition* (O'Reilly, 2021) by Jim Blandy, Jason Orendorff, Leonora F.S. Tindall | The second edition (2021) updates the crates and modules chapter for the 2021 edition conventions (dropping `mod.rs` requirement), and covers workspace improvements not in the 2017 first edition |

---

## Study Plan — 7 Sessions

Estimated total: **14–18 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from fundamental module concepts through visibility and project structure to dependency management, JPMS, conditional compilation, and finally semantic versioning with real-world project organization.

---

### Session 1 — Module System Fundamentals

**Goal:** understand what a "module" means in each language — Rust's crate/module hierarchy, Java's packages and the class-file-to-directory mapping, Python's module objects and the import system — and how each language maps source files to organizational units.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 35 min | **Rust: crates, modules, and the module tree.** Read Klabnik Ch.7 pp. 119–140 (the complete chapter). Read Blandy Ch.8 pp. 161–175 (crates, build profiles, modules, paths and imports, standard prelude). Key insight: Rust has a two-level hierarchy — the *crate* is the compilation unit and the *module* is the organizational unit within a crate. A crate has a single root file (`src/lib.rs` for libraries, `src/main.rs` for binaries) that defines the root of the module tree. Modules are declared with `mod name;` and can be defined inline (in the same file) or in separate files (`name.rs` or `name/mod.rs`; since the 2018 edition, `name.rs` with a `name/` directory for submodules is preferred over `mod.rs`). The module tree is explicit — a module does not exist unless declared from its parent. Everything is private by default; `pub` makes items visible outside the module. The `use` keyword imports paths into scope; `pub use` re-exports items, which is critical for creating clean public APIs. |
| 1.2 | 30 min | **Java: packages, classes, and the classpath.** Read Horstmann Ch.4 §4.8–4.9 pp. 63–64 (packages, JAR files). Read Bloch Ch.4 Item 25 pp. 115 (limit source files to a single top-level class). Read the Oracle tutorial on packages online. Key insight: Java's module system operates at three levels. (1) The *package* is the fundamental organizational unit — a reverse-domain-name namespace (`com.example.app.util`) that maps directly to the directory structure. (2) The *class* or *interface* is the unit of compilation — each public class must reside in a file named after it (`MyClass.java` produces `MyClass.class`). (3) The *JAR* is the distribution unit — a ZIP archive of `.class` files with a manifest. Packages provide package-private (default) access — classes in the same package can see each other's package-private members without any modifier keyword. Import statements are purely syntactic conveniences (they do not load anything — unlike Python's `import`). Java packages are open namespaces: any JAR can contribute classes to any package, which is both a strength (extensibility) and a source of "JAR hell" that JPMS was designed to fix. |
| 1.3 | 30 min | **Python: modules, packages, and the import system.** Read Martelli Ch.7 pp. 221–245 (complete chapter: module objects, module loading, packages, distribution utilities, environments). Read Slatkin Ch.14 Item 119 pp. 588–592 (use packages to organize modules and provide stable APIs). Key insight: In Python, a *module* is any `.py` file — importing it executes the file and creates a module object in `sys.modules`. A *package* is a directory containing `__init__.py` (regular package) or without it (namespace package, PEP 420). `__init__.py` executes when the package is first imported and can define the package's public API by importing selected names and setting `__all__`. The import system is highly dynamic: `sys.path` determines where modules are found, `importlib` provides the finder/loader protocol, and modules can be created dynamically. Unlike Rust and Java, Python's import executes code at import time — importing a module has side effects. Circular imports are a common pitfall because partially-loaded modules can expose incomplete namespaces. |
| 1.4 | 15 min | **Cross-language comparison.** Map the three-level hierarchy across languages: Rust (crate → module → item) vs Java (module (JPMS) → package → class) vs Python (package → module → name). Note the fundamental differences: Rust modules are explicit declarations (you must `mod` them); Java packages are implicit from directory structure; Python packages depend on `__init__.py` (or namespace package convention). Compare how each resolves names: Rust uses paths (`crate::module::item`, `super::`, `self::`); Java uses fully qualified names (`com.example.Class`) with `import` for shorthand; Python uses dot-notation (`package.module.name`) with `from ... import ...` for selective import. Create a parallel example: a simple project with two submodules (`math_utils` and `string_utils`) in each language. |

---

### Session 2 — Visibility and Access Control

**Goal:** master the visibility/access control mechanisms in each language — Rust's granular `pub`/`pub(crate)`/`pub(super)`/private system, Java's four access modifiers plus JPMS module-level control, Python's convention-based encapsulation with name mangling — and understand the philosophical differences in how each language enforces encapsulation.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 35 min | **Rust: visibility modifiers and privacy rules.** Read Klabnik Ch.7 pp. 126–133 (paths, `pub` keyword, making structs and enums public). Read the Rust Reference "Visibility and Privacy" section online. Read Rust By Example "Visibility" page online. Key insight: Rust has five visibility levels: (1) private (default) — visible only within the defining module and its descendants; (2) `pub(self)` — same as private (explicit form); (3) `pub(super)` — visible to the parent module; (4) `pub(crate)` — visible anywhere within the crate but not to external crates; (5) `pub` — visible to anyone who can access the module it is in. Struct fields have independent visibility from the struct itself — a `pub struct` can have private fields, which means external code cannot construct it directly (must use a constructor function). Enum variants, however, inherit the visibility of the enum — if the enum is `pub`, all variants are `pub`. This asymmetry is deliberate: struct fields are implementation details; enum variants are part of the type's definition. `pub(crate)` is the "sweet spot" for internal APIs that multiple modules within a crate need to share without exposing them to crate consumers. |
| 2.2 | 30 min | **Java: access modifiers and module boundaries.** Read Bloch Ch.4 Item 15 pp. 73–77 (minimize accessibility of classes and members) and Item 16 pp. 78–79 (accessor methods, not public fields). Read Bloch Ch.4 Item 24 pp. 112–114 (favor static member classes over nonstatic). Key insight: Java has four access levels for class members: (1) `private` — accessible only within the declaring class; (2) package-private (no modifier) — accessible to all classes in the same package; (3) `protected` — package-private plus accessible to subclasses in other packages; (4) `public` — accessible everywhere. For top-level classes, only `public` and package-private are available. Bloch's Item 15 states the fundamental rule: "make each class or member as inaccessible as possible." With JPMS (Java 9+), a new layer exists: the `module-info.java` `exports` directive controls which packages are visible to other modules — a `public` class in a non-exported package is effectively module-private. This creates a two-tier access control: member-level modifiers within packages, and module-level `exports` across module boundaries. JPMS `opens` provides a separate pathway for reflective access (required by frameworks like Spring and Hibernate). |
| 2.3 | 25 min | **Python: convention-based privacy and name mangling.** Read Slatkin Ch.7 Item 55 pp. 245–249 (prefer public attributes over private ones). Read the Python docs on private variables and name mangling online. Read PEP 8 naming conventions online. Key insight: Python has no enforced access control — "we are all consenting adults." Conventions signal intent: (1) `name` — public; (2) `_name` — "private by convention" (not enforced, but signals internal use; not imported by `from module import *`); (3) `__name` — triggers name mangling (the interpreter rewrites it to `_ClassName__name` to avoid accidental override in subclasses — it is *not* about security or privacy but about preventing name collisions in inheritance hierarchies); (4) `__name__` — dunder/magic methods reserved for the language. Slatkin's Item 55 argues against using `__name` (double-underscore/name-mangled attributes) for privacy — it creates problems for subclassing and testing. Instead, `_name` is sufficient to communicate "internal" intent. Python's `__all__` list in a module controls what `from module import *` exports, serving as the closest analog to explicit API surface control. The lack of enforced privacy is consistent with Python's philosophy of preferring runtime flexibility and developer trust over compiler-enforced encapsulation. |
| 2.4 | 20 min | **Three-way comparison.** Create a mapping table: Rust `pub` = Java `public` (with exported package) = Python public name; Rust `pub(crate)` = Java package-private (within module) = Python `_name` convention; Rust private = Java `private` = Python `__name` (mangled, but not truly private). Note the key differences: (1) Rust enforces privacy at compile time with module-level granularity; Java enforces at compile time with class-level granularity plus module-level for JPMS; Python does not enforce at all. (2) Struct field visibility in Rust has no direct analog in Java (Java fields can be `private` independently, but constructors are not restricted by field visibility the same way). (3) Python's `__all__` is similar in purpose to Rust's `pub use` re-exports and Java's JPMS `exports` — all three control what the public API surface looks like. Design a small library with internal utilities and a public API in each language to demonstrate the different encapsulation mechanisms. |

---

### Session 3 — Code Organization Patterns (Project Structure, File Layout)

**Goal:** understand idiomatic project structures in each language — Rust's Cargo conventions with `src/lib.rs`, `src/main.rs`, and workspace layouts; Java's Maven/Gradle standard directory layout with source sets; Python's `src/` layout vs flat layout with `pyproject.toml` — and the patterns for organizing multi-module/multi-package projects.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 30 min | **Rust: Cargo project layout, workspaces, and re-exports.** Read Blandy Ch.8 pp. 175–191 (turning programs into libraries, `src/bin`, tests, documentation, dependencies, publishing, workspaces). Read Klabnik Ch.14 pp. 295–313 (release profiles, publishing, `pub use` re-exports, workspaces, `cargo install`, custom commands). Read the Cargo Book "Project Layout" and "Workspaces" pages online. Key insight: Cargo enforces a conventional directory layout: `src/lib.rs` (library root), `src/main.rs` (binary root), `src/bin/` (additional binaries), `tests/` (integration tests), `benches/` (benchmarks), `examples/` (example programs). A *workspace* groups multiple crates under a single `Cargo.toml` with shared `Cargo.lock` and `target/` directory — essential for large projects like Tokio, Serde, and rustc itself. The `pub use` mechanism is critical for API design: internal modules can have a deep hierarchy (`crate::internal::parser::ast::Node`), while `pub use` in `lib.rs` creates a flat, user-friendly re-export (`mycrate::Node`). The Rust API Guidelines recommend re-exporting commonly used items at the crate root. Workspace members can depend on each other with `path` dependencies that convert to `version` dependencies when published. |
| 3.2 | 25 min | **Java: standard directory layout and multi-module projects.** Read Horstmann Ch.4 §4.9 pp. 64 (JAR files, manifest, executable JARs). Read Evans Ch.2 pp. 40–54 (building modular apps, split packages, multi-release JARs). Read the Maven Standard Directory Layout documentation online. Key insight: Java has a well-established directory convention: `src/main/java/` (source), `src/main/resources/` (non-code files), `src/test/java/` (tests), `src/test/resources/` (test resources). Maven/Gradle multi-module projects use a parent POM/build script with child modules, each following the same structure. The `module-info.java` file (placed in the source root of each module) declares module boundaries: `requires` lists dependencies, `exports` controls which packages are visible, and `provides ... with ...` declares service implementations. Multi-release JARs (`META-INF/versions/`) allow a single JAR to contain version-specific classes for different Java runtimes. The standard directory layout is not enforced by the language but by the build tool — however, it is so universally adopted that deviating from it causes significant friction. |
| 3.3 | 25 min | **Python: package layouts and `__init__.py` patterns.** Read Slatkin Ch.14 Item 119 pp. 588–592 (use packages to organize modules and provide stable APIs). Read Slatkin Ch.14 Item 122 pp. 600–604 (know how to break circular dependencies). Read the Python Packaging User Guide "Packaging Python Projects" page online. Read the Real Python "Python Application Layouts" article online. Key insight: Python has two dominant layout conventions: the *flat layout* (package directory at project root: `mypackage/`) and the *src layout* (package under `src/`: `src/mypackage/`). The `src` layout is increasingly recommended because it prevents accidental imports from the project root during development. `__init__.py` serves multiple roles: it marks a directory as a package, executes initialization code, and defines the package's public API via selective imports and `__all__`. Circular dependencies are a common structural problem — Slatkin's Item 122 offers three solutions: restructure imports, use import-time-only imports inside functions, or use late binding. Namespace packages (without `__init__.py`) enable splitting a package across multiple directories/distributions — used by large organizations to distribute a shared namespace (`google.*`, `azure.*`). |
| 3.4 | 15 min | **Comparison: project structure archetypes.** Compare a medium-sized project structure in each language: Rust workspace with 3 crates (core, cli, server), Java multi-module Maven project with 3 modules (core, cli, server), Python monorepo with 3 packages (core, cli, server). Note the parallel patterns: Rust workspace `Cargo.toml` = Maven parent `pom.xml` = Python monorepo with shared `pyproject.toml` (or individual ones). Compare how each manages internal dependencies between modules: Rust uses `path` dependencies with `workspace = true`; Java uses Maven/Gradle inter-module dependencies; Python uses editable installs (`pip install -e .`) or workspace tools (`uv workspace`). Note that Rust's `pub use` re-export pattern has analogs in Python's `__init__.py` imports and Java's facade packages. |

---

### Session 4 — Dependency Management (Cargo, Maven/Gradle, pip/uv/poetry)

**Goal:** understand how each ecosystem handles external dependencies — Cargo's semver-aware resolver with `Cargo.lock`, Maven's dependency mediation with `pom.xml` and Gradle's conflict resolution, pip/uv/poetry's requirements files and lockfiles — including resolution algorithms, lockfile semantics, and dependency vendoring.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 35 min | **Rust: Cargo dependency management.** Read Matthews Ch.2 pp. 20–32 (dependency management, Cargo.lock, feature flags, patching dependencies). Read the Cargo Book "Specifying Dependencies", "Dependency Resolution", and "Cargo.toml vs Cargo.lock" pages online. Key insight: Cargo uses semantic versioning by default — `foo = "1.2.3"` means `>=1.2.3, <2.0.0` (compatible versions per semver). The resolver produces a `Cargo.lock` that pins exact versions for reproducible builds. Libraries should not check in `Cargo.lock` (to allow downstream consumers to resolve freely); binaries should check it in (for reproducibility). Cargo resolves dependencies globally within a workspace — it produces a single dependency graph where each semver-compatible range resolves to one version. When two crates require incompatible versions of the same dependency (e.g., `serde 1.x` and `serde 2.x`), Cargo can include both, linked with different symbols. `[patch]` overrides a dependency's source globally across the dependency graph — useful for testing local fixes to upstream crates. Feature flags allow compile-time optional dependencies: `serde = { version = "1", features = ["derive"] }` enables the `derive` feature. |
| 4.2 | 30 min | **Java: Maven and Gradle dependency management.** Read the Maven "Introduction to the Dependency Mechanism" and the Gradle "Dependency Management" documentation online. Read Baeldung "Maven vs Gradle" article online. Key insight: Maven uses `pom.xml` with `<dependency>` declarations specifying `groupId`, `artifactId`, `version`, and `scope` (compile, test, runtime, provided). Maven's dependency mediation uses the "nearest definition" strategy — the version closest to the project root in the dependency tree wins; ties are broken by declaration order. Maven does not support lockfiles natively (though plugins exist). Gradle uses a Groovy or Kotlin DSL with `implementation`, `api`, `testImplementation` configurations. Gradle's resolution strategy is more sophisticated: it picks the highest compatible version by default (optimistic resolution) and supports strict versions, rich version declarations, and dependency locking. Both tools use Maven Central as the primary repository. BOM (Bill of Materials) declarations (`<dependencyManagement>` in Maven, `platform()` in Gradle) centralize version management across multi-module projects. Unlike Cargo, neither Maven nor Gradle can include two incompatible versions of the same library — only one version wins, which can cause binary compatibility problems. |
| 4.3 | 30 min | **Python: pip, uv, poetry, and the packaging ecosystem.** Read Slatkin Ch.14 Item 116 pp. 575 (finding community-built modules) and Item 117 pp. 576–581 (virtual environments). Read Viafore Ch.16 pp. 225–241 (dependency types, visualizing dependency graphs). Read the Python Packaging User Guide online. Read the uv documentation and Poetry documentation online. Key insight: Python's dependency management has historically been fragmented. `pip` is the standard installer that reads `requirements.txt` (pinned versions) or `pyproject.toml` (version ranges). `pip` does not guarantee reproducible resolution (no lockfile). Modern tools fill this gap: `poetry` uses `poetry.lock` with a SAT-solver-based resolver and `pyproject.toml` for project metadata; `uv` (from Astral, written in Rust) provides extremely fast resolution and installation with `uv.lock`. `pyproject.toml` (PEP 621) is the standard for declaring project metadata and dependencies, replacing `setup.py`/`setup.cfg`. Virtual environments (`venv`, `virtualenv`, `uv venv`) isolate project dependencies — unlike Cargo and Maven where isolation is structural (per-project dependency trees), Python requires explicit environment management. Dependency specifiers use PEP 440 syntax: `>=1.0,<2.0`, `~=1.4` (compatible release), `==1.4.*` (prefix matching). Platform markers (`; sys_platform == "win32"`) enable conditional dependencies. |
| 4.4 | 15 min | **Comparison: dependency management philosophy.** Compare resolution strategies: Cargo uses semver-aware minimal-version-compatible resolution (single graph, allows multiple semver-incompatible versions); Maven uses nearest-wins (single version per artifact); Gradle uses highest-compatible-wins; pip uses first-found (non-deterministic without constraints); poetry/uv use SAT-solver-based resolution. Compare lockfile semantics: `Cargo.lock` (complete transitive graph), `poetry.lock`/`uv.lock` (complete transitive graph), Maven (no native lockfile), Gradle (optional dependency locking). Compare repository models: crates.io (immutable publishes, yanking, no namespaces), Maven Central (immutable, group ID namespacing), PyPI (mutable metadata, account-based namespacing). Note the trust model differences: Cargo and Maven Central require verified ownership; PyPI has historically had weaker verification (improving with Trusted Publishers). |

---

### Session 5 — Java Platform Module System (JPMS) Deep Dive

**Goal:** deeply understand JPMS as the most complex module system among the three languages — module declarations, the module graph, strong encapsulation, qualified exports, service loading, migration strategies from classpath to module path, and the practical implications for large Java projects.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 35 min | **JPMS fundamentals: module-info.java and the module graph.** Read Horstmann Ch.12 pp. 150–160 (module concept, naming, modular Hello World, requiring modules, exporting packages, modular JARs). Read Evans Ch.2 pp. 26–40 (Project Jigsaw, module graph, access control, basic syntax). Key insight: JPMS introduces a new compilation and runtime entity — the *module*. A module is declared in `module-info.java` at the source root with directives: `requires` declares dependencies on other modules (checked at both compile time and runtime); `exports` makes a package accessible to other modules; `opens` makes a package available for reflection (deep reflection). The module graph is a directed acyclic graph where edges represent `requires` relationships. `java.base` is the root module that every module implicitly requires. Strong encapsulation means that even `public` classes in non-exported packages are inaccessible from other modules — this is the fundamental difference from the pre-JPMS classpath model where all `public` classes were globally visible. The JDK itself is modularized into ~70 modules (`java.base`, `java.sql`, `java.logging`, etc.), enabling the `jlink` tool to create custom minimal runtime images. |
| 5.2 | 30 min | **Advanced JPMS: transitive dependencies, qualified exports, and services.** Read Horstmann Ch.12 pp. 160–166 (transitive and static requirements, qualified exporting and opening, service loading, tools). Read Evans Ch.2 pp. 40–54 (architecting for modules, split packages). Key insight: `requires transitive` exposes a dependency to the module's consumers (if module A `requires transitive` B, then any module that `requires` A also implicitly `requires` B). `requires static` declares a compile-time-only dependency (useful for optional annotations like `@Nullable`). `exports ... to` (qualified export) exports a package only to specific named modules — enabling internal APIs shared between cooperating modules without global exposure. `opens ... to` does the same for reflective access. The `provides ... with ...` and `uses` directives integrate with `ServiceLoader` for runtime service discovery — the module system version of the Service Provider Interface (SPI) pattern. This replaces the fragile `META-INF/services/` mechanism. Split packages (two modules contributing classes to the same package) are forbidden — a deliberate constraint that prevents the chaos of pre-JPMS classpath conflicts. |
| 5.3 | 25 min | **JPMS migration and performance implications.** Read Beckwith Ch.3 pp. 69–97 (monolithic to modular Java, JAR hell, Jigsaw layers, OSGi comparison, jdeps/jlink/jdeprscan/jmod, performance implications). Key insight: Migration from classpath to module path involves three strategies: (1) the *unnamed module* — all JARs on the classpath are placed in a single unnamed module that `exports` everything and can `require` all named modules (backward compatibility); (2) *automatic modules* — JARs placed on the module path without `module-info.java` get an automatic module name derived from the JAR filename or `Automatic-Module-Name` manifest attribute; (3) *explicit modules* — JARs with `module-info.java`. The migration path is: unnamed → automatic → explicit. `jdeps` analyzes dependencies and suggests `module-info.java` content. `jlink` creates custom runtime images containing only required modules — reducing Docker image sizes from ~300MB to ~30MB. Performance implications: stronger encapsulation enables more aggressive JIT inlining across module boundaries; custom runtimes reduce startup time and memory footprint. Jigsaw layers enable running multiple module configurations in the same JVM — useful for plugin systems and application servers. |
| 5.4 | 15 min | **JPMS vs Rust modules vs Python packages.** Compare: JPMS modules are declared in `module-info.java` with explicit `exports`/`requires`; Rust crates have `Cargo.toml` for dependencies and `pub`/`pub(crate)` for visibility; Python packages have `__init__.py` for API definition and `pyproject.toml` for dependencies. Note that JPMS is unique in providing both dependency declaration AND visibility control in a single mechanism (`module-info.java`), while Rust separates these into `Cargo.toml` (dependencies) and visibility modifiers (access control), and Python separates them into `pyproject.toml` (dependencies) and conventions (access control). Also note the different motivations: JPMS was designed to fix JAR hell in the existing Java ecosystem (a massive backward-compatibility challenge); Rust's module system was designed from scratch with strong encapsulation from day one; Python's package system evolved incrementally with backward compatibility as a primary constraint. |

---

### Session 6 — Conditional Compilation, Feature Flags, and API Surface Management

**Goal:** understand how each language supports compile-time configuration and optional functionality — Rust's `#[cfg]` attributes and Cargo features as the most sophisticated system, Java's build profiles and annotation processing as build-tool-mediated alternatives, Python's runtime conditional imports and platform detection — and how each manages the public API surface through re-exports, export lists, and documentation.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 35 min | **Rust: `#[cfg]`, Cargo features, and conditional compilation.** Read Gjengset Ch.5 pp. 67–78 (features: defining, including, using features in your crate; conditional compilation). Read Matthews Ch.2 pp. 26–30 (feature flags). Read the Rust Reference "Conditional Compilation" and the Cargo Book "Features" pages online. Key insight: Rust has a first-class conditional compilation system. `#[cfg(feature = "serde")]` includes code only when the `serde` feature is enabled. Features are defined in `Cargo.toml` under `[features]` and can depend on other features or optional dependencies. Feature unification means all features requested across the dependency graph are combined — features are additive (enabling a feature never removes functionality). `#[cfg(target_os = "linux")]`, `#[cfg(test)]`, `#[cfg(debug_assertions)]` provide platform, test, and build-profile conditionals. The `cfg!()` macro evaluates at compile time but returns a `bool` for use in runtime expressions. `cfg_if!` (from the `cfg-if` crate) provides a cleaner syntax for complex conditional blocks. Best practice: features should be additive and never break compilation when enabled or disabled in any combination. Non-additive features are a semver hazard because they can cause compilation failures in downstream crates. |
| 6.2 | 25 min | **Java: build profiles, annotation processing, and conditional behavior.** Read Baeldung "Maven Profiles" article online. Read the Gradle "Build Variants" documentation online. Key insight: Java has no language-level conditional compilation (no preprocessor, no `#ifdef`). Instead, conditional behavior is achieved through: (1) build-tool profiles — Maven `<profiles>` and Gradle build variants select different source sets, resources, or dependencies based on activation criteria (OS, JDK version, environment variables); (2) annotation processing — compile-time code generation that can produce different code based on processor configuration; (3) runtime checks — `System.getProperty()`, `java.lang.Runtime.version()`, and reflection-based feature detection; (4) the `ServiceLoader` pattern — different implementations loaded at runtime based on available providers. Multi-release JARs (`META-INF/versions/9/`, etc.) provide a version-specific override mechanism at the class level. Java's approach is fundamentally different from Rust's: instead of compile-time code elimination, Java relies on the JIT compiler to optimize away dead code paths at runtime (which it does very effectively). |
| 6.3 | 25 min | **Python: runtime conditional imports and API surface control.** Read Slatkin Ch.14 Item 120 pp. 593–594 (module-scoped code to configure deployment environments). Read Slatkin Ch.14 Item 119 pp. 588–592 (use packages to organize modules and provide stable APIs). Read the Python docs `sys.platform` and `platform` module pages online. Key insight: Python has no compile-time conditional compilation — everything happens at runtime. Conditional functionality uses: (1) `try/except ImportError` — attempting to import optional dependencies and falling back to alternatives; (2) `sys.platform` / `platform.system()` checks — branching on OS at runtime; (3) `__all__` in `__init__.py` — controlling what `from package import *` exposes, which is the primary mechanism for API surface management; (4) `typing.TYPE_CHECKING` — code inside `if TYPE_CHECKING:` blocks runs only during static analysis, never at runtime (used for circular import avoidance in type annotations). Python's `pyproject.toml` supports optional dependency groups (`[project.optional-dependencies]`: `dev = ["pytest"]`, `docs = ["sphinx"]`) analogous to Cargo features. Platform-conditional dependencies use environment markers: `pywin32; sys_platform == "win32"`. |
| 6.4 | 20 min | **API surface management comparison.** Compare the mechanisms for controlling what users of a library see: Rust uses `pub use` re-exports in `lib.rs` to create a curated public API from a complex internal module structure — combined with `#[doc(hidden)]` to hide items from documentation while keeping them technically public. Java uses JPMS `exports` to control package-level visibility, plus Javadoc `@hidden` (since Java 15) and `@apiNote`/`@implNote` for documentation-level API communication. Python uses `__all__` in `__init__.py`, the `_prefix` convention, and docstrings to define the public API. Note: Rust's approach is the most rigorous (compile-time enforced, documentation-integrated); Java's JPMS is compile-time enforced but operates at the package granularity (you cannot export individual classes from a package); Python's is entirely convention-based but sufficient for the ecosystem's needs. Compare feature flags: Rust's Cargo features are unique — neither Java nor Python has an equivalent compile-time feature system integrated into the build tool and dependency resolver. |

---

### Session 7 — Semantic Versioning, API Compatibility, and Real-World Project Organization

**Goal:** understand how each ecosystem enforces (or encourages) semantic versioning and API compatibility — Rust's strict semver enforcement via Cargo with `cargo-semver-checks`, Java's binary compatibility rules (JLS Ch.13) and module versioning, Python's PEP 440 versioning and deprecation workflows — and synthesize all sessions into a comprehensive understanding of how real-world projects organize code.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 30 min | **Rust: semver enforcement and API compatibility.** Read Gjengset Ch.5 pp. 78–84 (versioning: MSRV, minimal dependency versions, changelogs, unreleased versions). Read the Cargo Book "SemVer Compatibility" page online. Read the Rust API Guidelines "Necessities" section online. Key insight: Cargo treats semver as a first-class concept — version requirements in `Cargo.toml` are interpreted according to semver rules. The Cargo Book documents an extensive list of what constitutes a breaking change (major version bump required): adding a required field to a public struct, removing a `pub` item, changing function signatures, removing trait implementations. `cargo-semver-checks` (a community tool) automates detection of semver violations by comparing the current API against a baseline. The Rust API Guidelines provide a checklist of semver-relevant changes. MSRV (Minimum Supported Rust Version) policy determines the oldest compiler version a crate supports — this is declared in `Cargo.toml` as `rust-version = "1.70"` and verified by CI. The combination of strict semver in Cargo + `pub` visibility control + `pub use` re-exports creates a robust system where API surface changes are deliberate and versioned. |
| 7.2 | 25 min | **Java: binary compatibility and module versioning.** Read the Java Language Specification Chapter 13 "Binary Compatibility" online. Read the Oracle Java SE Compatibility Guide online. Read Baeldung "Backward Compatibility in Java" article online. Key insight: Java defines *binary compatibility* in JLS Chapter 13 — a detailed specification of which changes to a class or interface preserve compatibility with pre-existing binaries (compiled `.class` files) without recompilation. Adding a method to an interface is NOT binary compatible (it breaks existing implementations unless it is a default method). Adding a non-abstract method to a class IS binary compatible. Removing a public method is NEVER binary compatible. JPMS does not include version information in module declarations — there is no equivalent of Cargo's semver-aware resolution for modules. Version management in Java is entirely delegated to build tools (Maven/Gradle version ranges, BOM management). Java's six-month release cadence with LTS releases (11, 17, 21) creates a different versioning rhythm: libraries must decide which Java versions to support, similar to Rust's MSRV. Deprecation uses `@Deprecated(since = "9", forRemoval = true)` — a structured annotation that tools can detect and report. |
| 7.3 | 25 min | **Python: versioning, deprecation, and API evolution.** Read Slatkin Ch.14 Item 121 pp. 595–599 (define a root exception to insulate callers from APIs). Read Slatkin Ch.14 Item 123 pp. 605–612 (consider warnings to refactor and migrate usage). Read PEP 440 (version identification) and PEP 387 (backwards compatibility policy) online. Key insight: Python uses PEP 440 for version identification — versions follow a scheme of `MAJOR.MINOR.MICRO` with optional pre-release (`.dev0`, `a1`, `b2`, `rc1`), post-release (`.post1`), and epoch segments. Unlike Rust, Python does not enforce semver at the package manager level — pip/poetry/uv use PEP 440 version specifiers for resolution but do not distinguish between major and minor bumps semantically. API deprecation follows a structured pattern: (1) emit `DeprecationWarning` via the `warnings` module (Item 123); (2) document the deprecation and the replacement; (3) remove after a defined period (typically two minor versions). `FutureWarning` signals changes in behavior rather than API removal. Slatkin's Item 121 introduces the root exception pattern: define a base exception class for your library (`class MyLibError(Exception): pass`) so callers can catch all library errors without depending on internal exception hierarchy details — this insulates the public API from internal refactoring. |
| 7.4 | 25 min | **Synthesis: real-world project organization patterns.** Examine the organizational patterns of notable projects in each ecosystem: Rust (Tokio: workspace with tokio, tokio-macros, tokio-util, tokio-test; extensive use of feature flags for optional runtime components); Java (Spring Boot: multi-module Maven project with BOM for version management, auto-configuration via service loading); Python (Django: flat package layout with deep subpackage hierarchy, `__init__.py`-based API surface). Create a comprehensive comparison table mapping all concepts across the three languages. Key synthesis points: (1) Rust has the most integrated system — Cargo unifies dependency management, build configuration, feature flags, and semver enforcement; (2) Java has the most layers — build tools (Maven/Gradle) handle dependencies, JPMS handles module encapsulation, and JLS defines binary compatibility; (3) Python has the most convention-driven approach — packaging tools handle dependencies, naming conventions handle privacy, and community norms handle API compatibility. All three are converging on similar principles (explicit dependency declaration, controlled API surfaces, reproducible builds) but from very different starting points. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Module system fundamentals | Klabnik 119–140, Blandy 161–175, Horstmann 63–64, Bloch 115, Martelli 221–245, Slatkin 588–592 | Rust Reference modules, JLS Ch.7, Python import system docs, Real Python modules |
| 2 | Visibility and access control | Klabnik 126–133, Bloch 73–79 + 112–114, Slatkin 245–249 | Rust Reference visibility/privacy, JLS 6.6, PEP 8 naming conventions |
| 3 | Code organization patterns | Blandy 175–191, Klabnik 295–313, Horstmann 64, Evans 40–54, Slatkin 588–604 | Cargo Book project layout/workspaces, Maven standard directory layout, Python Packaging User Guide |
| 4 | Dependency management | Matthews 20–32, Viafore 225–241, Slatkin 575–581 | Cargo Book dependencies/resolver, Maven dependency mechanism, Gradle dependency management, uv docs, Poetry docs |
| 5 | JPMS deep dive | Horstmann 150–166, Evans 26–54, Beckwith 69–97 | JEP 261, Baeldung Java 9 modularity, openjdk.org Jigsaw quick-start |
| 6 | Conditional compilation and API surface | Gjengset 67–78, Matthews 26–30, Slatkin 588–594 | Rust Reference conditional compilation, Cargo Book features, Baeldung Maven profiles, Python sys.platform/platform docs |
| 7 | Semantic versioning and API compatibility | Gjengset 78–84, Slatkin 595–612 | Cargo Book SemVer compatibility, JLS Ch.13 binary compatibility, PEP 440, PEP 387, cargo-semver-checks docs, Rust API Guidelines |

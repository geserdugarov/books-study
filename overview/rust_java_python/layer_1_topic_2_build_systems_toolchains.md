# Layer 1 · Topic 2 — Build Systems & Toolchains

> Comparative study of Rust, Java, and Python: how each language builds, manages dependencies, and ships software — from `cargo new` to production CI/CD.

---

## 1. Tool Overview & Project Scaffolding

### Rust: Cargo — The All-in-One Tool

Rust's build story is remarkably unified. **Cargo** serves as build system, package manager, test runner, documentation generator, and benchmark harness — all in one tool. It ships with every Rust installation via **rustup**, the toolchain manager.

**Installation and toolchain management:**

```bash
# Install Rust (Linux/macOS)
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

# Key rustup commands
rustup update                     # Update to latest stable
rustup toolchain install nightly  # Install nightly channel
rustup component add clippy rustfmt rust-analyzer  # Add components
rustup target add aarch64-apple-darwin             # Add cross-compilation target
rustup doc                        # Open local documentation
```

Rustup manages **toolchains**, each being a combination of architecture + platform + channel. Three channels exist: **stable** (production-ready, every 6 weeks), **beta** (next stable candidate), and **nightly** (bleeding edge, unreleased features). You can switch per-command with `cargo +nightly test` or pin a project-specific toolchain via `rust-toolchain.toml`:

```toml
[toolchain]
channel = "nightly-2024-01-15"
components = ["rustfmt", "clippy"]
targets = ["x86_64-unknown-linux-gnu"]
```

**Project scaffolding:**

```bash
cargo new hello-rust          # Binary project (src/main.rs)
cargo new hello-lib --lib     # Library project (src/lib.rs)
cargo init                    # Initialize in existing directory
```

`cargo new` creates a directory containing `Cargo.toml` (the manifest), `src/main.rs` (or `src/lib.rs`), and initializes a Git repository with `.gitignore`. The generated `Cargo.toml` is in TOML format:

```toml
[package]
name = "hello-rust"
version = "0.1.0"
edition = "2021"

[dependencies]
```

The `edition` field specifies which Rust edition the code uses (2015, 2018, 2021, 2024). The `[dependencies]` section lists crate dependencies.

**Core Cargo commands:**

| Command | Purpose |
|---------|---------|
| `cargo build` | Compile to `target/debug/` |
| `cargo build --release` | Compile with optimizations to `target/release/` |
| `cargo run` | Compile and run |
| `cargo check` | Type-check without producing a binary (faster than build) |
| `cargo test` | Compile and run all tests |
| `cargo bench` | Run benchmarks |
| `cargo doc --open` | Generate and open HTML documentation |
| `cargo clean` | Remove the `target/` directory |
| `cargo search <query>` | Search crates.io |

`cargo check` is notably faster than `cargo build` because it skips code generation and linking — it only runs the front-end of the compiler (parsing, type-checking, borrow-checking). For large projects, the time savings are substantial.

Cargo follows strict conventions: source goes in `src/`, the top-level directory holds configuration files, READMEs, licenses. The binary entry point is `src/main.rs`; the library entry point is `src/lib.rs`. Tests go in `#[cfg(test)]` modules or in a `tests/` directory for integration tests.

> **Sources:** Klabnik & Nichols (2023) Ch.1 pp. 1–11 · Matthews (2024) Ch.2 pp. 11–16 · Blandy & Orendorff (2017) Ch.8 pp. 161–165 · [The Cargo Book](https://doc.rust-lang.org/cargo/) · [Rustup documentation](https://rust-lang.github.io/rustup/)

---

### Java: Maven & Gradle — Two Mature Build Systems

Java's build ecosystem is split between two major tools: **Maven** (2004, Apache) and **Gradle** (2012, Gradle Inc.). Both coexist in the ecosystem, with Maven dominant in enterprise and Gradle dominant for Android and Kotlin projects.

**JDK installation and version management:**

The JDK is the prerequisite for all Java development. Since Java 11, there is no separate JRE — the JDK is all you need. Key environment setup:
- Set `JAVA_HOME` to the JDK installation directory
- Add `$JAVA_HOME/bin` to `PATH`
- Verify with `java -version` and `javac -version`

**SDKMAN** (`https://sdkman.io/`) is the community-standard JDK version manager, analogous to rustup:

```bash
sdk install java 21.0.2-tem   # Install a specific JDK distribution
sdk use java 21.0.2-tem       # Switch active JDK
sdk list java                  # List available distributions
```

**Core command-line tools:**

| Tool | Purpose |
|------|---------|
| `javac` | Compile `.java` to `.class` bytecode |
| `java` | Run bytecode on the JVM |
| `jar` | Package `.class` files into JAR archives |
| `javadoc` | Generate HTML API documentation |
| `jshell` | Interactive REPL (since Java 9) |
| `jlink` | Create custom runtime images |
| `jdeps` | Analyze class/module dependencies |

The compiler has built-in make-like functionality: `javac EmployeeTest.java` automatically finds and compiles `Employee.java` if `Employee.class` is missing or outdated.

**Maven — Convention over Configuration:**

Maven's philosophy is strict convention: source code in `src/main/java/`, tests in `src/test/java/`, resources in `src/main/resources/`, output in `target/`. The central configuration file is `pom.xml` (Project Object Model), written in XML:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
            <version>31.1-jre</version>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-api</artifactId>
            <version>5.8.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

Every Maven artifact is uniquely identified by **GAV coordinates**: GroupId (organizational identifier, reverse domain), ArtifactId (project name), Version. The `-SNAPSHOT` suffix marks development versions.

Scaffolding a new Maven project:

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app \
    -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

**Maven build lifecycle** — the default lifecycle phases run in order:

1. **validate** — validates project structure
2. **compile** — compiles source code to `target/classes/`
3. **test** — runs unit tests
4. **package** — packages into JAR/WAR
5. **verify** — runs integration tests
6. **install** — installs to local repository (`~/.m2/repository/`)
7. **deploy** — copies to remote repository

Invoking a phase automatically runs all preceding phases: `mvn package` runs validate, compile, test, then package.

**Gradle — Flexibility with Convention:**

Gradle uses a Groovy or Kotlin DSL instead of XML, supporting conditional logic, custom tasks, and programmable build logic. It follows the same directory conventions as Maven by default.

`build.gradle.kts` (Kotlin DSL):

```kotlin
plugins {
    java
    application
}

group = "com.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.google.guava:guava:31.1-jre")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.8.2")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.8.2")
}

application {
    mainClass.set("com.example.Main")
}

tasks.test {
    useJUnitPlatform()
}
```

Scaffolding: `gradle init` creates a project with `build.gradle`, `settings.gradle`, and the Gradle Wrapper files.

Gradle's build model is based on **tasks** organized in a **Directed Acyclic Graph (DAG)**. Built-in tasks from the `java` plugin: `compileJava`, `test`, `jar`, `build`, `clean`.

| Command | Purpose |
|---------|---------|
| `./gradlew build` | Full build (compile + test + jar) |
| `./gradlew test` | Compile and run tests |
| `./gradlew clean` | Delete `build/` directory |
| `./gradlew tasks` | List all available tasks |
| `./gradlew run` | Run the application |

The Kotlin DSL offers better IDE support (type-safe, auto-complete) compared to the Groovy DSL.

> **Sources:** Horstmann (2024) Ch.2 · Evans et al (2022) Ch.11 pp. 345–399 · [Maven in 5 Minutes](https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html) · [Gradle Getting Started](https://docs.gradle.org/current/userguide/getting_started_eng.html) · [SDKMAN](https://sdkman.io/)

---

### Python: A Fragmented Ecosystem, Now Converging

Python's packaging story has been notoriously fragmented, evolving through multiple generations of tools. The ecosystem is now converging around **pyproject.toml** as the universal configuration format and **uv** as the modern all-in-one tool.

**Historical evolution:**

1. **distutils** (stdlib, deprecated in Python 3.10, removed in 3.12) — the original packaging tool
2. **setuptools** + **easy_install** — third-party extension; added the "egg" format
3. **pip** (2008) — installed from source trees rather than eggs; could install AND uninstall
4. **virtualenv** / **venv** — isolated per-project environments
5. **wheels** (PEP 427) — binary distribution format replacing eggs
6. **pyproject.toml** (PEP 517 + PEP 518) — build-system-independent configuration
7. **poetry** (2018) — dependency management + lockfiles + publishing
8. **uv** (2024, Astral) — Rust-based, 10–100x faster than pip, replaces pip + pip-tools + pipx + poetry + pyenv + virtualenv

**Virtual environments — the foundational isolation mechanism:**

Python assumes per-project virtual environments. A virtualenv is a self-contained Python environment with its own `site-packages/`:

```bash
python -m venv myenv            # Create a virtualenv
source myenv/bin/activate       # Activate (Linux/macOS)
pip install requests            # Install into the virtualenv
pip freeze > requirements.txt   # Record installed versions
pip install -r requirements.txt # Reproduce environment
deactivate                      # Deactivate
```

The virtualenv works by adjusting `sys.prefix` so pip installs into the virtualenv's own directory. `pip freeze` outputs `package==version` lines — the traditional (manual) approach to reproducibility.

**Modern scaffolding with uv:**

uv is an extremely fast Python package and project manager written in Rust (by Astral, the creators of Ruff). It consolidates functionality from pip, pip-tools, pipx, poetry, pyenv, and virtualenv:

```bash
uv init hello-python            # Create a new project with pyproject.toml
uv add requests                 # Add a dependency
uv sync                         # Install all dependencies from lockfile
uv run python main.py           # Run in the project environment
uv python install 3.12          # Install a Python version
uv python pin 3.12              # Pin Python version per-directory
```

`uv init` creates a `pyproject.toml`:

```toml
[project]
name = "hello-python"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

This format is standardized by **PEP 518** (build-system specification) and **PEP 621** (project metadata specification). The `[build-system]` table declares what tool builds the package; the `[project]` table contains metadata.

**Poetry scaffolding:**

```bash
poetry new hello-poetry         # Create project with pyproject.toml
poetry add requests             # Add a dependency
poetry install                  # Install from poetry.lock
poetry run python main.py       # Run in the project environment
```

Poetry uses its own sections in `pyproject.toml` (`[tool.poetry]`) alongside the standard tables.

> **Sources:** Martelli et al (2023) Ch.7 pp. 221–245, Ch.24 pp. 655–658 · [Python Packaging User Guide](https://packaging.python.org/) · [uv documentation](https://docs.astral.sh/uv/) · [Poetry documentation](https://python-poetry.org/docs/) · [PEP 518](https://peps.python.org/pep-0518/) · [PEP 621](https://peps.python.org/pep-0621/)

---

### Cross-Language Comparison

| Aspect | Cargo (Rust) | Maven (Java) | Gradle (Java) | uv (Python) | Poetry (Python) |
|--------|-------------|--------------|---------------|-------------|-----------------|
| **Config format** | TOML (`Cargo.toml`) | XML (`pom.xml`) | Groovy/Kotlin DSL | TOML (`pyproject.toml`) | TOML (`pyproject.toml`) |
| **Scaffolding** | `cargo new` | `mvn archetype:generate` | `gradle init` | `uv init` | `poetry new` |
| **Build command** | `cargo build` | `mvn package` | `./gradlew build` | `uv build` | `poetry build` |
| **Test location** | `src/` (inline) + `tests/` | `src/test/java/` | `src/test/java/` | `tests/` (convention) | `tests/` (convention) |
| **Doc generation** | `cargo doc` | `mvn javadoc:javadoc` | `./gradlew javadoc` | Sphinx (external) | Sphinx (external) |
| **REPL** | No (but `evcxr_repl` exists) | `jshell` (since Java 9) | `jshell` | `python` / `ipython` | `python` |
| **Year introduced** | 2014 | 2004 | 2012 | 2024 | 2018 |

---

## 2. Dependency Management & Resolution

### Rust: Backtracking Resolver with SemVer

Cargo's dependency management is built on three pillars: `Cargo.toml` (what you want), `Cargo.lock` (what you got), and crates.io (where packages live).

**Specifying dependencies in Cargo.toml:**

```toml
[dependencies]
# From crates.io (default)
serde = "1.0"                    # Caret requirement: >=1.0.0, <2.0.0
rand = "0.8.5"                   # >=0.8.5, <0.9.0

# With features
serde = { version = "1.0", features = ["derive"] }

# Optional dependency (for feature flags)
base64 = { version = "0.13", optional = true }

# From Git
image = { git = "https://github.com/image-rs/image.git", rev = "528f19c" }

# From local path
mylib = { path = "../mylib" }
```

**Version requirement syntax (SemVer-based):**

| Syntax | Example | Meaning |
|--------|---------|---------|
| Caret (default) | `^1.2.3` or `"1.2.3"` | `>=1.2.3, <2.0.0` |
| Tilde | `~1.2.3` | `>=1.2.3, <1.3.0` |
| Wildcard | `1.2.*` | `>=1.2.0, <1.3.0` |
| Exact | `=1.2.3` | Exactly `1.2.3` |
| Comparison | `>=1.2.3, <2.0.0` | Range |

For pre-1.0 crates, the rules shift: `^0.2.3` means `>=0.2.3, <0.3.0` (the leftmost non-zero digit is treated as the "major" version).

**Cargo's resolution algorithm** uses a **backtracking solver**:

1. Pick the next unresolved dependency
2. Try to unify with already-resolved packages (prefer reusing existing versions)
3. Look up available versions matching the requirement, **preferring the highest**
4. Recurse into transitive dependencies
5. Backtrack if no valid solution exists

**Version unification** is a key optimization: if package A requires `bitflags "1.0"` and package B requires `bitflags "1.1"`, Cargo resolves to a single version (e.g., `1.2.1`) that satisfies both. But if the ranges are incompatible (e.g., `0.6` vs `0.7`), Cargo builds **both versions** — types from different major versions are considered distinct.

**Resolver versions:**

| Version | Default for | Key feature |
|---------|------------|-------------|
| `"1"` | Legacy | Basic feature unification |
| `"2"` | `edition = "2021"` | Feature isolation: target-specific, build-deps, and dev-deps don't unify features |
| `"3"` | `edition = "2024"` | Rust version fallback (prefers versions compatible with declared `rust-version`) |

**Feature flags** allow conditional compilation and optional dependencies:

```toml
[features]
default = ["std"]
std = []
serde = ["dep:serde"]       # Enable optional dependency
simd = ["dep:packed_simd"]

[dependencies]
serde = { version = "1.0", optional = true }
```

In code: `#[cfg(feature = "serde")] mod serde_support;`

Features are additive — enabling a feature on a crate in one part of the dependency graph enables it everywhere that crate is used (this is "feature unification"). Resolver v2 mitigates this for build-deps and target-specific deps.

**Patching transitive dependencies:**

```toml
[patch.crates-io]
libc = { git = "https://github.com/rust-lang/libc", tag = "0.2.88" }
```

This replaces the registry version of `libc` everywhere in the dependency graph — useful for bug fixes before upstream publishes.

> **Sources:** Matthews (2024) Ch.2 pp. 17–25 · Blandy & Orendorff (2017) Ch.8 pp. 178–185 · [Cargo — Specifying Dependencies](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html) · [Cargo — Resolver](https://doc.rust-lang.org/cargo/reference/resolver.html) · [Cargo — Features](https://doc.rust-lang.org/cargo/reference/features.html)

---

### Java: Coordinate-Based Resolution

Both Maven and Gradle resolve dependencies from **Maven Central** (and other repositories) using **GAV coordinates** (`groupId:artifactId:version`).

**Maven dependency management:**

```xml
<dependencies>
    <dependency>
        <groupId>com.google.guava</groupId>
        <artifactId>guava</artifactId>
        <version>31.1-jre</version>
    </dependency>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-api</artifactId>
        <version>5.8.2</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

**Dependency scopes** control when a dependency is available:

| Scope | Compile | Test | Runtime | Packaged |
|-------|---------|------|---------|----------|
| `compile` (default) | Yes | Yes | Yes | Yes |
| `test` | No | Yes | No | No |
| `provided` | Yes | Yes | No | No |
| `runtime` | No | Yes | Yes | Yes |
| `system` | Yes | Yes | No | No |

Maven uses **interval notation** for version ranges: `[1.0,2.0)` means `>=1.0.0, <2.0.0`. But in practice, most Maven projects pin exact versions.

**Maven conflict resolution: "nearest wins."** When two paths in the dependency tree lead to different versions of the same artifact, Maven picks the version declared closest to the root. If both are at the same depth, the first declaration wins. This is deterministic but can lead to surprising results — a deeply-nested library might get an older version than it expects.

**Excluding transitive dependencies:**

```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>library</artifactId>
    <version>1.0</version>
    <exclusions>
        <exclusion>
            <groupId>org.unwanted</groupId>
            <artifactId>transitive-dep</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

**`<dependencyManagement>`** centralizes version declarations in a parent POM without actually adding the dependencies:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
            <version>31.1-jre</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

Child modules then declare `<dependency>` without a `<version>`, inheriting from the parent.

**Gradle dependency configurations** are finer-grained than Maven scopes:

| Configuration | Visible to consumers? | Available at |
|--------------|----------------------|-------------|
| `implementation` | No | Compile + runtime |
| `api` | Yes | Compile + runtime |
| `compileOnly` | No | Compile only |
| `runtimeOnly` | No | Runtime only |
| `testImplementation` | No | Test compile + runtime |

The key distinction: `implementation` keeps dependencies off the compile classpath of downstream consumers, reducing unnecessary recompilation. Use `api` only when your public API exposes types from the dependency.

**Gradle conflict resolution: "newest wins"** by default — when multiple versions of the same library appear, Gradle picks the highest version. This can be customized with resolution strategies.

> **Sources:** Evans et al (2022) Ch.11 pp. 360–380 · [Maven — Dependency Mechanism](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html) · [Gradle — Dependency Management](https://docs.gradle.org/current/userguide/dependency_management.html) · [Maven Central](https://central.sonatype.com/)

---

### Python: From No Resolver to SAT Solvers

Python's dependency resolution has evolved dramatically:

**pip** historically had no resolver — it simply installed the latest version of each package. In 2020, pip introduced a **backtracking resolver** that correctly handles conflicts, but it can be slow on complex dependency graphs.

**Version specifiers (PEP 440):**

| Syntax | Example | Meaning |
|--------|---------|---------|
| Compatible release | `~=1.2.3` | `>=1.2.3, <1.3.0` |
| Exact | `==1.2.3` | Exactly 1.2.3 |
| Not equal | `!=1.2.3` | Anything except 1.2.3 |
| Greater/less | `>=1.2, <2.0` | Range |
| Wildcard | `==1.2.*` | Any 1.2.x |

**Poetry's version constraint syntax** mirrors Cargo's:
- Caret: `^1.2.3` means `>=1.2.3, <2.0.0`
- Tilde: `~1.2.3` means `>=1.2.3, <1.3.0`
- Wildcard: `1.*` means `>=1.0.0, <2.0.0`

**uv's resolver** is written in Rust and uses **universal resolution**: it produces a single lockfile that works across all platforms and Python versions. The resolver:
- Creates platform-independent lockfiles
- May include multiple versions of a package with environment markers for different platforms
- Supports resolution strategies: `--resolution lowest` (oldest compatible), `--resolution lowest-direct` (oldest for direct deps, latest for transitive)
- Handles pre-releases only when explicitly opted in or when all versions are pre-releases

**Registry: PyPI** (Python Package Index, `https://pypi.org/`) hosts 500,000+ packages.

### Comparative Analysis

| Aspect | Cargo (Rust) | Maven (Java) | Gradle (Java) | pip (Python) | uv (Python) | Poetry (Python) |
|--------|-------------|--------------|---------------|-------------|------------|-----------------|
| **Algorithm** | Backtracking | Nearest wins | Newest wins | Backtracking | SAT-based | SAT-based |
| **Version syntax** | `^1.2`, `~1.2`, `=1.2` | `[1.2,2.0)`, exact | Same as Maven | `>=1.2,<2.0`, `~=1.2` | PEP 440 | `^1.2`, `~1.2` |
| **Registry** | crates.io | Maven Central | Maven Central | PyPI | PyPI | PyPI |
| **Transitive** | Automatic | Automatic | Automatic | Automatic | Automatic | Automatic |
| **Feature flags** | Yes (first-class) | Via profiles/classifiers | Via capabilities | Extras | Extras | Extras |

> **Sources:** [pip — Dependency Resolution](https://pip.pypa.io/en/stable/topics/dependency-resolution/) · [uv — Resolution](https://docs.astral.sh/uv/concepts/resolution/) · [Poetry — Dependency specification](https://python-poetry.org/docs/dependency-specification/) · [PEP 440](https://peps.python.org/pep-0440/)

---

## 3. Reproducible Builds, Lockfiles & Vendoring

### Rust: Cargo.lock — Precision by Design

Cargo's approach to reproducibility is straightforward and well-defined.

**Cargo.lock** records the exact version, source, and checksum of every dependency (direct and transitive). When `Cargo.lock` exists, Cargo uses those exact versions regardless of what newer versions are available on crates.io. Only `cargo update` refreshes the lockfile.

Example `Cargo.lock` entry:

```toml
[[package]]
name = "regex"
version = "1.5.0"
source = "git+https://github.com/rust-lang/regex.git#9f9f693768c584971a4d53bc3c586c33ed3a6831"
```

**When to commit Cargo.lock:**

The current recommendation is: **commit `Cargo.lock` by default for all projects** (both applications and libraries). The rationale:
- For applications: ensures all developers and CI build identical binaries.
- For libraries: records a known-good set of dependency versions for CI and testing. Downstream consumers resolve their own versions anyway — a library's `Cargo.lock` is ignored when the library is used as a dependency.

(Historically, the advice was to gitignore `Cargo.lock` for libraries, but the Cargo team updated this recommendation.)

**Vendoring with `cargo vendor`:**

```bash
cargo vendor                   # Copies all dependency source code to vendor/
cargo vendor vendor-dir        # Custom directory
```

This creates a local copy of all dependencies. A `.cargo/config.toml` snippet is printed that you add to redirect Cargo to the vendored sources:

```toml
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
```

Vendoring is used for offline builds, auditing, and environments where network access is restricted.

**Build reproducibility flags:**

```bash
cargo build --locked    # Fail if Cargo.lock is out of date (CI use)
cargo build --frozen    # Don't update Cargo.lock or access the network
```

> **Sources:** Matthews (2024) Ch.2 pp. 19–21 · Blandy & Orendorff (2017) Ch.8 pp. 178–185 · [Cargo.toml vs Cargo.lock](https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html) · [cargo vendor](https://doc.rust-lang.org/cargo/commands/cargo-vendor.html)

---

### Java: Wrappers, Locking, and BOMs

Java's reproducibility story differs between Maven and Gradle.

**Maven Wrapper (mvnw):**

The Maven Wrapper pins the Maven version itself. `mvnw` / `mvnw.cmd` scripts are committed to the repository, along with `maven-wrapper.properties`:

```bash
./mvnw clean install   # Uses the pinned Maven version
```

This ensures all developers and CI use the same Maven version — analogous to committing a specific Cargo or Gradle version.

**Maven has no native lockfile.** Reproducibility is achieved through:
- Pinning exact versions in `pom.xml` (no ranges)
- `<dependencyManagement>` in parent POMs to centralize version declarations
- **Bill of Materials (BOM)** pattern — a POM with `<packaging>pom</packaging>` that declares a coordinated set of dependency versions, imported via `<scope>import</scope>`

**Gradle Wrapper (gradlew):**

Like Maven, Gradle provides a wrapper. `gradle/wrapper/gradle-wrapper.properties` specifies the Gradle distribution URL and version:

```bash
./gradlew build        # Downloads and uses the pinned Gradle version
```

**Gradle dependency locking:**

Gradle supports lockfiles natively:

```bash
./gradlew dependencies --write-locks   # Generate lockfiles
```

This creates `gradle.lockfile` per project, recording exact resolved versions. When lockfiles exist, Gradle fails if resolution would produce different versions.

**Gradle dependency verification:**

Gradle can verify dependency integrity via checksums:

```bash
./gradlew --write-verification-metadata sha256   # Generate verification metadata
```

This creates `gradle/verification-metadata.xml` with SHA checksums for every artifact.

**Gradle Build Cache:**

Gradle caches task outputs and reuses them when inputs haven't changed. The cache can be shared across machines (CI nodes) for faster builds. The **Gradle Daemon** (long-lived background process) avoids JVM startup costs on repeated builds.

> **Sources:** Evans et al (2022) Ch.11 pp. 345–399 · [Gradle — Dependency Locking](https://docs.gradle.org/current/userguide/dependency_locking.html) · [Gradle — Dependency Verification](https://docs.gradle.org/current/userguide/dependency_verification.html) · [Maven Wrapper](https://maven.apache.org/wrapper/) · [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html)

---

### Python: Lockfiles — The Long Road

Python historically lacked lockfiles entirely. `requirements.txt` with `==` pins was the manual workaround — you ran `pip freeze > requirements.txt` and committed the output. But `pip freeze` captures only the exact state of one environment, without checksums or platform markers.

**Modern lockfile tools:**

**uv.lock** — uv generates a universal lockfile:

```bash
uv lock                 # Generate/update uv.lock
uv sync                 # Install exactly what uv.lock specifies
```

The `uv.lock` file is cross-platform: it records versions for all platforms and Python versions the project supports, using environment markers to differentiate. It includes checksums for integrity verification. Existing lockfile versions are preferred during re-resolution (stability).

**poetry.lock** — Poetry generates a detailed lockfile:

```bash
poetry lock             # Generate/update poetry.lock
poetry install          # Install exactly what poetry.lock specifies
```

`poetry.lock` includes exact versions, hashes, and Python version markers.

**pip-tools (pip-compile):**

```bash
pip-compile requirements.in    # Generate pinned requirements.txt from loose specs
pip-sync requirements.txt      # Install exactly what's listed
```

`pip-compile` takes a `requirements.in` file with loose version specifications and produces a fully-pinned `requirements.txt` with hashes. This bridges the gap between pip's simplicity and lockfile precision.

**PEP 665** attempted to standardize a lockfile format for Python but was **rejected** — the ecosystem hasn't yet agreed on a universal format. In practice, `uv.lock` and `poetry.lock` are the most widely used.

**Reproducibility with uv:**

```bash
uv sync --frozen        # Don't update uv.lock
uv sync --locked        # Fail if uv.lock is out of date
uv lock --exclude-newer 2024-01-01  # Only use packages published before this date
```

> **Sources:** Martelli et al (2023) Ch.7 pp. 221–245 · [uv — Resolution](https://docs.astral.sh/uv/concepts/resolution/) · [Poetry — poetry.lock](https://python-poetry.org/docs/basic-usage/#installing-with-poetrylock) · [pip-tools](https://pip-tools.readthedocs.io/) · [PEP 665](https://peps.python.org/pep-0665/)

---

### Comparative Summary

| Aspect | Cargo (Rust) | Maven (Java) | Gradle (Java) | uv (Python) | Poetry (Python) |
|--------|-------------|--------------|---------------|-------------|-----------------|
| **Lockfile** | `Cargo.lock` (automatic) | None (pin manually) | `gradle.lockfile` (opt-in) | `uv.lock` (automatic) | `poetry.lock` (automatic) |
| **Checksums** | Yes (in lockfile) | No (use verification plugin) | Yes (verification-metadata.xml) | Yes (in lockfile) | Yes (in lockfile) |
| **Vendoring** | `cargo vendor` | `mvn dependency:go-offline` | Gradle offline mode | Not built-in | Not built-in |
| **Tool version pinning** | `rust-toolchain.toml` | `mvnw` (Maven Wrapper) | `gradlew` (Gradle Wrapper) | Built-in Python management | Requires pyenv/uv |
| **Cross-platform** | Via target triple | JVM portability | JVM portability | Universal lockfile | Platform markers |

---

## 4. Workspaces & Mono-repo Tooling

### Rust: Cargo Workspaces

Cargo workspaces allow multiple crates to share a single `Cargo.lock` and output directory (`target/`). This is Cargo's native mono-repo solution.

**Workspace root `Cargo.toml`:**

```toml
[workspace]
members = [
    "crates/core",
    "crates/api",
    "crates/cli",
]

[workspace.dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
```

The workspace root may be a **virtual manifest** (no `[package]` section — only organizes subprojects) or a regular crate that also serves as the workspace root.

**Member crate `Cargo.toml`:**

```toml
[package]
name = "my-api"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { workspace = true }            # Inherit version from workspace
core = { path = "../core" }             # Depend on sibling crate
```

**Key workspace properties:**
- **Shared `Cargo.lock`** at the workspace root — ensures all crates use compatible dependency versions
- **Shared `target/` directory** — compile once, share artifacts across crates
- **Workspace dependency inheritance** (`[workspace.dependencies]`) — declare a version once, inherit it in members with `{ workspace = true }`
- **Shared `[profile.*]` and `[patch.*]` sections** — configured once at the root
- **Independent publishing** — each crate is published separately to crates.io; there is no `cargo publish --all`

**Common commands:**

```bash
cargo build                     # Build all workspace members
cargo test -p my-api            # Test a specific member
cargo run -p my-cli             # Run a specific binary
```

Virtual manifests (workspace-only roots with no `[package]`) are used by major projects like `rand`, `Rocket`, and `Tokio`.

> **Sources:** Klabnik & Nichols (2023) Ch.14 pp. 303–310 · Matthews (2024) Ch.2 pp. 38–39 · Blandy & Orendorff (2017) Ch.8 pp. 188–190 · [Cargo — Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html)

---

### Java: Multi-Module Maven & Multi-Project Gradle

**Maven multi-module builds:**

A parent POM with `<packaging>pom</packaging>` aggregates child modules:

```xml
<!-- parent pom.xml -->
<project>
    <groupId>com.example</groupId>
    <artifactId>parent</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <modules>
        <module>core</module>
        <module>api</module>
        <module>web</module>
    </modules>

    <dependencyManagement>
        <dependencies>
            <!-- Centralized version management -->
        </dependencies>
    </dependencyManagement>
</project>
```

Each child module declares a `<parent>` reference:

```xml
<parent>
    <groupId>com.example</groupId>
    <artifactId>parent</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
<artifactId>core</artifactId>
```

Maven's **reactor** builds all modules in dependency order automatically.

**Gradle multi-project builds:**

`settings.gradle`:

```groovy
rootProject.name = 'my-project'
include 'core', 'api', 'web'
```

Root `build.gradle`:

```groovy
subprojects {
    apply plugin: 'java'
    repositories { mavenCentral() }
}
```

Subproject dependency on a sibling:

```groovy
dependencies {
    implementation project(':core')
}
```

**Gradle composite builds** go further — they allow repository-independent project composition. A build can substitute a binary dependency with a locally-built project:

```groovy
// settings.gradle
includeBuild '../my-library'
```

This is useful when developing a library and its consumer simultaneously.

**Gradle performance advantages in multi-project builds:**
- **Parallel execution**: `--parallel` builds independent subprojects concurrently
- **Incremental compilation**: only recompiles files whose inputs changed
- **Build cache**: reuses task outputs across subprojects and machines
- **Configuration cache**: caches the task graph to skip configuration on subsequent builds

> **Sources:** Evans et al (2022) Ch.11 pp. 380–399 · [Gradle — Multi-project Builds](https://docs.gradle.org/current/userguide/multi_project_builds.html) · [Gradle — Composite Builds](https://docs.gradle.org/current/userguide/composite_builds.html) · [Maven — Multi-Module Projects](https://maven.apache.org/guides/mini/guide-multiple-modules.html)

---

### Python: Emerging Workspace Support

Python workspace support is nascent compared to Rust and Java.

**uv workspaces** (inspired by Cargo):

uv supports Cargo-style workspaces with a shared lockfile. Configuration in the root `pyproject.toml`:

```toml
[tool.uv.workspace]
members = ["packages/*"]
```

Workspace members share a single `uv.lock` and can depend on each other as path dependencies. This is a recent addition — uv workspaces bring Python closer to the Cargo model.

**Poetry** does not support workspaces natively. Multi-package Python projects using Poetry typically use separate `pyproject.toml` files with path dependencies, but without a shared lockfile.

**External mono-repo tools:**
- **Pants** (`https://www.pantsbuild.org/`) — a polyglot build system supporting Python, Java, Go, and more. Fine-grained dependency tracking and caching.
- **Bazel** — Google's polyglot build system, used for very large mono-repos
- **Nx** — JavaScript-origin mono-repo tool with Python support

> **Sources:** [uv — Workspaces](https://docs.astral.sh/uv/concepts/workspaces/) · [Hatch — Environments](https://hatch.pypa.io/latest/config/environment/overview/) · [Pants](https://www.pantsbuild.org/)

---

### Comparison Matrix

| Feature | Cargo Workspaces | Maven Multi-Module | Gradle Multi-Project | uv Workspaces |
|---------|-----------------|-------------------|---------------------|---------------|
| **Shared lockfile** | Yes | No (pin in parent POM) | Opt-in (`gradle.lockfile`) | Yes |
| **Shared build cache** | Yes (`target/`) | No | Yes (build cache) | Yes |
| **Cross-package refs** | `{ path = "../core" }` | `<module>core</module>` | `project(':core')` | Path dependencies |
| **Version alignment** | `[workspace.dependencies]` | `<dependencyManagement>` | `allprojects {}` | Shared lockfile |
| **Incremental builds** | Yes | No (rebuilds from scratch) | Yes | Yes |
| **Maturity** | Mature | Mature | Mature | Emerging |

---

## 5. Cross-Compilation & Target Platforms

### Rust: First-Class Cross-Compilation

Rust has the most comprehensive cross-compilation story of the three languages. Because Cargo and `rustc` are built on LLVM, any LLVM-supported platform is a potential target.

**Adding and building for targets:**

```bash
rustup target list                          # Show all available targets
rustup target add aarch64-apple-darwin      # Add ARM macOS target
cargo build --target aarch64-apple-darwin   # Cross-compile
```

Output goes to `target/<target-triple>/debug/` (or `release/`).

Rust supports **80+ well-supported target triples** (200+ including experimental) covering Linux (x86_64, ARM, RISC-V), macOS (x86_64, aarch64), Windows (MSVC, GNU), WebAssembly, embedded (Cortex-M, RISC-V bare metal), and more.

**Static linking for maximum portability:**

By default, Rust dynamically links the C runtime. For fully self-contained binaries on Linux, link against musl:

```bash
rustup target add x86_64-unknown-linux-musl
RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl
```

The resulting binary has zero runtime dependencies — it can run on any Linux system regardless of glibc version.

Persistent configuration in `~/.cargo/config.toml`:

```toml
[target.x86_64-pc-windows-msvc]
rustflags = ["-Ctarget-feature=+crt-static"]
```

**The `cross` tool** uses Docker containers to provide the correct linker and sysroot for each target:

```bash
cargo install cross
cross build --target aarch64-unknown-linux-gnu
```

This is particularly useful when the target requires a different linker (e.g., building for ARM Linux from an x86 host).

**Build scripts (`build.rs`)** handle platform-specific build logic:

```rust
// build.rs
fn main() {
    println!("cargo:rerun-if-changed=src/hello_world.c");
    cc::Build::new()
        .file("src/hello_world.c")
        .compile("hello_world");
}
```

Build scripts run before the crate is compiled. They can compile C code, generate Rust code, detect platform features, and communicate with Cargo via `println!("cargo:...")` directives. Build dependencies go in `[build-dependencies]`.

> **Sources:** Matthews (2024) Ch.2 pp. 33–42 · [Rust Platform Support](https://doc.rust-lang.org/rustc/platform-support.html) · [Rustup — Cross-compilation](https://rust-lang.github.io/rustup/cross-compilation.html) · [cross](https://github.com/cross-rs/cross) · [Cargo — Build Scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)

---

### Java: JVM Portability + Native Image

Java's motto "Write Once, Run Anywhere" means cross-compilation is usually unnecessary — compiled `.class` files and JARs run on any JVM. The platform-specific work happens at the JVM level, not at build time.

**The Java Platform Module System (JPMS):**

Since Java 9, the module system (Project Jigsaw) provides strong encapsulation and reliable dependency configuration. A module is defined by `module-info.java`:

```java
module com.example.myapp {
    requires java.sql;
    requires transitive java.logging;
    exports com.example.myapp.api;
    opens com.example.myapp.internal to com.fasterxml.jackson.databind;
}
```

Key directives: `requires` (declares dependency), `exports` (makes a package visible), `opens` (allows reflection access — needed for Spring, Hibernate). Non-exported packages are strongly encapsulated.

**jlink — Custom Runtime Images:**

`jlink` creates a stripped-down JRE containing only the modules your application needs:

```bash
jlink --module-path $JAVA_HOME/jmods:out \
      --add-modules com.example.myapp \
      --output custom-runtime \
      --launcher myapp=com.example.myapp/com.example.myapp.Main
```

The result is hundreds of megabytes smaller than the full JDK — useful for Docker images and embedded deployment.

**GraalVM Native Image — AOT Compilation for Java:**

GraalVM Native Image compiles Java code ahead-of-time into a standalone binary executable:

```bash
# With Maven
mvn -Pnative package

# With Gradle
./gradlew nativeCompile

# Directly
javac HelloWorld.java && native-image HelloWorld
```

**Key characteristics:**
- Produces platform-specific binaries (Linux/macOS/Windows)
- Startup time measured in **milliseconds** (vs seconds for JVM)
- Immediate peak performance without warmup
- Dramatically reduced memory footprint
- No JVM required at runtime

**Key limitation — the Closed World Assumption**: Native Image performs static analysis at build time. Dynamic features (reflection, JNI, dynamic proxies, runtime class loading) require explicit metadata configuration. Frameworks like Spring and Quarkus provide this metadata automatically.

**Multi-release JARs (JEP 238):**

A single JAR can contain version-specific class files:

```
META-INF/
  versions/
    9/
      com/example/Util.class    # Java 9+ version
    21/
      com/example/Util.class    # Java 21+ version
com/example/Util.class          # Base version (Java 8 compatible)
```

The JVM automatically picks the most appropriate version at runtime.

> **Sources:** Evans et al (2022) Ch.2 pp. 26–54 · Horstmann (2024) Ch.12 · [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/) · [JLink](https://docs.oracle.com/en/java/javase/21/docs/specs/man/jlink.html) · [JEP 238 — Multi-Release JARs](https://openjdk.org/jeps/238)

---

### Python: Pure Python is Portable, Extensions Are Not

Pure Python code is platform-independent by design. The challenge arises with **C extensions** — compiled native code that must be built separately for each platform.

**Distribution formats:**

| Format | Description | Platform |
|--------|-------------|----------|
| **sdist** (source distribution) | `.tar.gz` of source code | Any (requires compilation) |
| **wheel** (binary distribution) | `.whl` archive with compiled code | Platform-specific |
| **Pure Python wheel** | `.whl` with only `.py` files | Any |

Wheel filenames encode compatibility: `numpy-1.24.0-cp311-cp311-manylinux_2_17_x86_64.whl` specifies CPython 3.11, Linux x86_64.

**cibuildwheel — Multi-Platform Wheel Building:**

```bash
pip install cibuildwheel
cibuildwheel --platform linux    # Build wheels for Linux
```

`cibuildwheel` automates building wheels for Linux (`manylinux`), macOS, and Windows in CI. It uses Docker containers for Linux builds and native runners for macOS/Windows.

**manylinux** is a specification defining a portable Linux ABI baseline. Wheels tagged `manylinux_2_17` work on any Linux distribution with glibc >= 2.17 (CentOS 7+).

**Bundling Python into standalone executables:**
- **PyInstaller** — bundles Python interpreter + code + dependencies into a single executable
- **Nuitka** — compiles Python to C, then to a native executable (sometimes with speedups)

**Compiling C extensions (from Gorelick & Ozsvald):**

**Cython** — the most widely used AOT compiler for Python. Converts type-annotated Python (`.pyx` files) to C extension modules:

```python
# setup.py for Cython
from distutils.core import setup
from Cython.Build import cythonize

setup(ext_modules=cythonize("cythonfn.pyx",
                            compiler_directives={"language_level": "3"}))
```

Build: `python setup.py build_ext --inplace`. Progressive optimization is possible by adding `cdef` type annotations — pure Python: 8s, Cython no annotations: 4.7s, Cython + types: 0.49s, with expanded math: 0.19s (40x speedup).

**Numba** — JIT compiler for numpy code via LLVM, requiring only a decorator:

```python
from numba import jit

@jit(nopython=True)
def calculate(maxiter, zs, cs, output):
    # normal Python/numpy code
```

Near-Cython performance with far less effort. Supports `parallel=True` with `prange` for automatic parallelization.

**FFI tools for calling existing native code:**
- **ctypes** (stdlib) — low-level, verbose, but always available
- **cffi** — higher-level with an internal C parser
- **f2py** — Fortran-to-Python bridge (part of numpy)
- **CPython C API** — maximum control, maximum complexity

> **Sources:** Gorelick & Ozsvald (2020) Ch.7 pp. 161–211 · [cibuildwheel](https://cibuildwheel.pypa.io/) · [manylinux](https://github.com/pypa/manylinux) · [PyInstaller](https://pyinstaller.org/) · [Nuitka](https://nuitka.net/)

---

### Comparative Summary

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Portability model** | Compile per-target | JVM (WORA) | Interpreter (pure) / wheels (extensions) |
| **Cross-compilation** | First-class (`--target`) | Usually unnecessary (JVM) | `cibuildwheel` for C extensions |
| **Static binary** | `musl` target | GraalVM Native Image | PyInstaller / Nuitka |
| **Number of targets** | 80+ (200+ with experimental) | Everywhere JVM runs | Everywhere Python runs |
| **Native performance** | Always native | GraalVM (limited) / JIT | Cython / Numba (partial) |
| **Build scripts** | `build.rs` | Maven/Gradle plugins | `setup.py` / build backends |

---

## 6. Toolchain Ecosystem (Linters, Formatters, LSPs)

### Rust: Official, Unified Tooling

Rust's tooling philosophy is **official and unified** — the core tools are maintained by the Rust project and distributed via `rustup component add`.

**rustfmt — Code Formatter:**

```bash
rustup component add rustfmt
cargo fmt                      # Format all files
cargo fmt -- --check           # CI: check without modifying
```

Configuration in `rustfmt.toml`:

```toml
edition = "2021"
max_width = 100
tab_spaces = 4
use_small_heuristics = "Max"
```

Skip formatting a block: `#[rustfmt::skip]`. Many configuration options require the nightly channel.

**Clippy — Linter:**

```bash
rustup component add clippy
cargo clippy                   # Run lints
cargo clippy -- -D warnings    # CI: fail on any warning
cargo clippy --fix             # Auto-apply fixes
```

Clippy has hundreds of lint rules across categories: correctness, style, complexity, performance, pedantic, nursery. Configuration in `Cargo.toml`:

```toml
[lints.clippy]
enum_glob_use = "deny"
pedantic = { level = "warn", priority = -1 }
```

Per-item: `#[allow(clippy::needless_return)]` or `#[deny(clippy::enum_glob_use)]`.

**rust-analyzer — LSP:**

The official Language Server Protocol implementation. Provides code completion, go-to-definition, find references, hover info, inline errors, code actions, and refactoring. Works with VS Code (primary), Emacs, Vim/Neovim, Sublime Text. Install via editor extension or `rustup component add rust-analyzer`.

**rustfix — Automatic Migration:**

```bash
cargo fix                      # Apply compiler suggestions
cargo fix --edition            # Migrate to a new Rust edition
```

**sccache — Compilation Cache:**

```bash
cargo install sccache
export RUSTC_WRAPPER=sccache   # Or configure in ~/.cargo/config.toml
```

Caches compilation artifacts to avoid redundant work. Supports local disk and cloud storage (S3, GCS, Azure). Created by Mozilla. Significant speedups on CI where many builds share dependencies.

**Cargo extensions:**

| Extension | Purpose |
|-----------|---------|
| `cargo-watch` | Re-runs commands on file changes: `cargo watch -x check -x test` |
| `cargo-expand` | Shows macro-expanded code |
| `cargo-audit` | Checks for known security vulnerabilities |
| `cargo-outdated` | Shows outdated dependencies |
| `cargo-tarpaulin` | Code coverage |
| `cargo-deny` | Configurable lint for dependencies (licenses, bans, advisories) |
| `cargo-release` | Automates release workflow (version bump, tag, publish) |
| `cargo-nextest` | Modern test runner with better output and parallel execution |
| `cargo-bloat` | Analyzes binary size |

Any binary in PATH named `cargo-something` becomes `cargo something`.

> **Sources:** Matthews (2024) Ch.3 pp. 43–62 · Klabnik & Nichols (2023) Appendix D pp. 511–514 · [Clippy lints](https://rust-lang.github.io/rust-clippy/master/) · [rustfmt](https://rust-lang.github.io/rustfmt/) · [rust-analyzer](https://rust-analyzer.github.io/manual.html)

---

### Java: IDE-Centric Ecosystem

Java's tooling philosophy is **IDE-centric** — IntelliJ IDEA (and to a lesser extent Eclipse) provides built-in formatting, linting, refactoring, and analysis that most Java developers rely on. CLI tools exist but are typically integrated as Maven/Gradle plugins rather than used standalone.

**Formatting:**
- **Google Java Format** — opinionated formatter (like Black for Python). Can be run as a CLI tool or integrated as a Maven/Gradle plugin.
- **IDE formatters** — IntelliJ IDEA and Eclipse have built-in formatters with configurable style rules.

**Static analysis / linting:**
- **Checkstyle** — style checker ensuring code follows conventions (naming, whitespace, Javadoc). Configured via XML rules file, integrated as Maven/Gradle plugin.
- **SpotBugs** — static analysis finding bugs (null dereferences, resource leaks, concurrency issues). Successor to FindBugs.
- **Error Prone** — Google's compile-time bug detector. Operates as a javac plugin (annotation processor), catching bugs at compile time rather than as a separate linting step.

**IDE / LSP:**
- **IntelliJ IDEA** — the de facto standard Java IDE. Provides code completion, refactoring, debugging, built-in Git, Maven/Gradle integration, and analysis features that rival dedicated tools.
- **Eclipse IDE** — open-source alternative with similar features.
- **Eclipse JDT Language Server** — LSP implementation used by VS Code's Java extension.

**Documentation:**
- **Javadoc** — standard documentation tool. Extracts `/** ... */` comments with tags (`@param`, `@return`, `@throws`, `@since`, `@see`) and generates HTML:

```java
/**
 * Constructs the bank.
 * @param n the number of accounts
 * @param initialBalance the initial balance for each account
 */
public Bank(int n, double initialBalance) { ... }
```

```bash
javadoc -d docs com.example.myapp     # Generate HTML docs
mvn javadoc:javadoc                   # Via Maven
./gradlew javadoc                     # Via Gradle
```

> **Sources:** Horstmann (2024) Ch.4 §4.10 · [Checkstyle](https://checkstyle.org/) · [SpotBugs](https://spotbugs.github.io/) · [Error Prone](https://errorprone.info/) · [Google Java Format](https://github.com/google/google-java-format)

---

### Python: Community-Driven, Recently Consolidating

Python's tooling was historically fragmented across many competing tools. The ecosystem is now rapidly consolidating, led by Astral (the company behind Ruff and uv).

**Ruff — Linter + Formatter (Rust-based):**

Ruff replaces pylint, flake8, isort, pyupgrade, and more with 10–100x speed improvement (written in Rust). It also includes a formatter (replacing Black):

```bash
ruff check .                   # Lint
ruff check --fix .             # Lint with auto-fix
ruff format .                  # Format
ruff format --check .          # CI: check without modifying
```

Configuration in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
```

**Black — Opinionated Formatter:**

"Any color you like, as long as it's black." Black enforces a single code style with minimal configuration:

```bash
black .                        # Format
black --check .                # CI: check without modifying
```

(Ruff's formatter is Black-compatible and faster, so many projects are migrating to Ruff.)

**Type checkers:**
- **mypy** — the original Python static type checker (by Jukka Lehtosalo, Dropbox). Checks type annotations (PEP 484+) without affecting runtime:

```bash
mypy .                         # Type-check the project
```

- **pyright** — Microsoft's type checker (faster, stricter). Powers Pylance in VS Code.

**LSP / IDE:**
- **Pylance** — VS Code's proprietary Python language server (based on pyright). Provides code completion, type checking, hover info, refactoring.
- **pyright** (open source) — the open-source core of Pylance, usable in any LSP-capable editor.

**pylint** — the traditional Python linter (slower than Ruff, more configurable). Being replaced by Ruff in many projects.

> **Sources:** [Ruff](https://docs.astral.sh/ruff/) · [mypy](https://mypy.readthedocs.io/) · [pyright](https://microsoft.github.io/pyright/) · [Black](https://black.readthedocs.io/) · [pylint](https://pylint.readthedocs.io/)

---

### Comparison Matrix

| Tool Category | Rust | Java | Python |
|--------------|------|------|--------|
| **Formatter** | `rustfmt` (official) | Google Java Format / IDE | Ruff format / Black |
| **Linter** | Clippy (official) | Checkstyle, SpotBugs, Error Prone | Ruff / pylint |
| **Type checker** | Compiler (built-in) | Compiler (built-in) | mypy / pyright |
| **LSP** | rust-analyzer (official) | IntelliJ / JDT LS | Pylance / pyright |
| **Build cache** | sccache | Gradle Build Cache | uv cache |
| **REPL** | None (evcxr_repl) | JShell | python / ipython |
| **Philosophy** | Official, unified, CLI-first | IDE-centric, plugin ecosystem | Community-driven, consolidating via Astral |

---

## 7. CI/CD Integration Patterns

### Rust: Cargo-Native Pipelines

A typical Rust CI pipeline leverages Cargo's all-in-one nature:

```yaml
# GitHub Actions example
name: CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - run: cargo fmt --all -- --check
      - run: cargo clippy -- -D warnings
      - run: cargo test
      - run: cargo build --release
```

**Key patterns:**
- **`dtolnay/rust-toolchain`** — the standard GitHub Action for installing Rust toolchains
- **Build matrix** across channels (stable, beta, nightly), OS (ubuntu, macos, windows), and features
- **`cargo fmt --check`** ensures formatting compliance
- **`cargo clippy -- -D warnings`** fails on any lint warning
- **`--locked`** flag ensures `Cargo.lock` is up to date

**Publishing to crates.io:**

```bash
cargo login <API_TOKEN>        # Store API token
cargo publish                  # Upload to crates.io
```

Publishing is **permanent** — versions cannot be deleted or overwritten. **Yanking** prevents new projects from depending on a version but doesn't break existing builds: `cargo yank --vers 1.0.1`.

**`cargo-release`** automates the release workflow: version bump in `Cargo.toml`, git tag, commit, publish to crates.io.

**Required metadata for publishing:**

```toml
[package]
name = "my-crate"
version = "1.0.0"
edition = "2021"
description = "A brief description"
license = "MIT OR Apache-2.0"
repository = "https://github.com/user/repo"
```

`name` must be unique on crates.io (first-come, first-served). `license` uses SPDX identifiers.

**docs.rs** automatically generates and hosts documentation for every published crate.

> **Sources:** Matthews (2024) Ch.2 pp. 28–31, Ch.3 pp. 55–56 · Klabnik & Nichols (2023) Ch.14 pp. 295–313 · [Cargo — Publishing](https://doc.rust-lang.org/cargo/reference/publishing.html) · [dtolnay/rust-toolchain](https://github.com/dtolnay/rust-toolchain) · [cargo-release](https://github.com/crate-ci/cargo-release)

---

### Java: Wrapper-Based Pipelines

Java CI/CD relies on Maven/Gradle wrappers to pin the build tool version:

```yaml
# GitHub Actions example (Gradle)
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'
          cache: 'gradle'
      - run: ./gradlew build
      - run: ./gradlew test
```

**Maven publishing to Maven Central:**

Maven Central publishing requires:
1. GPG signing of artifacts
2. Staging in Sonatype's OSSRH (Open Source Software Repository Hosting)
3. Release from staging repository
4. Metadata: POM with valid coordinates, license, developer info, SCM info

The **Maven Release Plugin** automates versioning:

```bash
mvn release:prepare   # Bump version, tag, commit
mvn release:perform   # Build and deploy to Maven Central
```

**Gradle publishing:**

```kotlin
plugins {
    `maven-publish`
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
        }
    }
    repositories {
        maven {
            url = uri("https://s01.oss.sonatype.org/...")
        }
    }
}
```

**Gradle Build Cache** can be shared across CI runs for faster builds. The `--build-cache` flag (enabled by default) reuses outputs from previous builds.

**Jib — Container Images Without Docker:**

```kotlin
plugins {
    id("com.google.cloud.tools.jib") version "3.4.0"
}

jib {
    to { image = "gcr.io/my-project/my-app" }
}
```

```bash
./gradlew jibDockerBuild       # Build Docker image locally
./gradlew jib                  # Build and push to registry
```

Jib builds optimized, layered Docker images without requiring a Docker daemon or Dockerfile. It separates dependencies, resources, and classes into layers for efficient caching.

> **Sources:** Evans et al (2022) Ch.11 pp. 390–399 · [Maven Release Plugin](https://maven.apache.org/maven-release/maven-release-plugin/) · [Gradle — Publishing](https://docs.gradle.org/current/userguide/publishing_setup.html) · [Jib](https://github.com/GoogleContainerTools/jib)

---

### Python: Trusted Publishers and uv

Python CI/CD has been modernized by Trusted Publishers (OIDC-based PyPI authentication) and uv's fast CI setup:

```yaml
# GitHub Actions example
name: CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - run: uv sync
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run mypy .
      - run: uv run pytest
```

**Trusted Publishers on PyPI:**

PyPI supports **OIDC-based authentication** — GitHub Actions can publish packages without storing API tokens. You configure a Trusted Publisher on PyPI linking your GitHub repository, then:

```yaml
# Publishing workflow
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - run: uv build
      - uses: pypa/gh-action-pypi-publish@release/v1
```

No secrets needed — the OIDC token proves the workflow's identity.

**cibuildwheel for multi-platform wheels:**

```yaml
jobs:
  build-wheels:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: pypa/cibuildwheel@v2
```

`cibuildwheel` builds wheels for Linux (`manylinux`), macOS, and Windows automatically. For Linux, it uses Docker containers with the manylinux base image.

**uv CI advantages:**
- **Global cache** — `uv cache` deduplicates across projects
- **`--frozen` / `--locked` flags** — ensure lockfile is respected
- **Fast installation** — uv is 10–100x faster than pip, reducing CI time significantly

> **Sources:** [PyPA — Publishing Tutorial](https://packaging.python.org/en/latest/tutorials/packaging-projects/) · [Trusted Publishers](https://docs.pypi.org/trusted-publishers/) · [uv — CI Guide](https://docs.astral.sh/uv/guides/integration/github/) · [cibuildwheel](https://cibuildwheel.pypa.io/)

---

### Cross-Language CI/CD Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Typical pipeline** | fmt check → clippy → test → build | compile → test → package | sync → ruff → mypy → pytest → build |
| **Registry** | crates.io | Maven Central | PyPI |
| **Auth model** | API token | GPG signing + Sonatype staging | Trusted Publishers (OIDC) / API token |
| **Build tool pinning** | `rust-toolchain.toml` | `mvnw` / `gradlew` | `uv` (self-contained) |
| **Build caching** | sccache | Gradle Build Cache | uv cache |
| **Release automation** | `cargo-release` | Maven Release Plugin | Trusted Publishers workflow |
| **Container images** | Multi-stage Dockerfile | Jib (no Docker needed) | Multi-stage Dockerfile |
| **Publishing permanence** | Permanent (yank only) | Permanent | Mutable (can delete, but discouraged) |

---

## Sources

### Books (local)

| Book | Relevant Sections | Path |
|------|-------------------|------|
| Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.1 pp. 1–11, Ch.14 pp. 295–313, App.D pp. 511–514 | `books/Rust/Klabnik Nichols 2023 The Rust programming language.pdf` |
| Blandy & Orendorff (2017) — *Programming Rust* | Ch.8 pp. 161–191 | `books/Rust/Blandy Orendorff 2017 Programming Rust.pdf` |
| Matthews (2024) — *Code Like a Pro in Rust* | Ch.2 pp. 11–42, Ch.3 pp. 43–62 | `books/Rust/Matthews 2024 Code like a pro in Rust.pdf` |
| Horstmann (2024) — *Core Java, Vol. I* | Ch.2, Ch.4 §4.8–4.10, Ch.12 | `books/Java/Horstmann 2024 Core Java. I Fundamentals.pdf` |
| Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.2 pp. 26–54, Ch.11 pp. 345–399 | `books/Java/Evans et al 2022 The well-grounded Java developer.pdf` |
| Martelli et al (2023) — *Python in a Nutshell* | Ch.7 pp. 221–245, Ch.24 pp. 655–658 | `books/Python/Martelli et al 2023 Python in a nutshell.pdf` |
| Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.7 pp. 161–211 | `books/Python/Gorelick, Ozsvald 2020 High performance Python.pdf` |

### External Resources

**Rust**
- [The Cargo Book](https://doc.rust-lang.org/cargo/)
- [Rustup documentation](https://rust-lang.github.io/rustup/)
- [Cargo — Resolver](https://doc.rust-lang.org/cargo/reference/resolver.html)
- [Cargo — Features](https://doc.rust-lang.org/cargo/reference/features.html)
- [Cargo — Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html)
- [Cargo — Build Scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)
- [Cargo — Publishing](https://doc.rust-lang.org/cargo/reference/publishing.html)
- [Rust Platform Support](https://doc.rust-lang.org/rustc/platform-support.html)
- [cross](https://github.com/cross-rs/cross)
- [Clippy lints](https://rust-lang.github.io/rust-clippy/master/)
- [rustfmt configuration](https://rust-lang.github.io/rustfmt/)
- [rust-analyzer](https://rust-analyzer.github.io/manual.html)
- [dtolnay/rust-toolchain](https://github.com/dtolnay/rust-toolchain)
- [cargo-release](https://github.com/crate-ci/cargo-release)

**Java**
- [Maven in 5 Minutes](https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html)
- [Maven — Dependency Mechanism](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html)
- [Maven — Multi-Module Projects](https://maven.apache.org/guides/mini/guide-multiple-modules.html)
- [Maven Release Plugin](https://maven.apache.org/maven-release/maven-release-plugin/)
- [Gradle — Getting Started](https://docs.gradle.org/current/userguide/getting_started_eng.html)
- [Gradle — Dependency Management](https://docs.gradle.org/current/userguide/dependency_management.html)
- [Gradle — Dependency Locking](https://docs.gradle.org/current/userguide/dependency_locking.html)
- [Gradle — Multi-project Builds](https://docs.gradle.org/current/userguide/multi_project_builds.html)
- [Gradle — Composite Builds](https://docs.gradle.org/current/userguide/composite_builds.html)
- [Gradle — Publishing](https://docs.gradle.org/current/userguide/publishing_setup.html)
- [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)
- [JEP 238 — Multi-Release JARs](https://openjdk.org/jeps/238)
- [SDKMAN](https://sdkman.io/)
- [Checkstyle](https://checkstyle.org/)
- [SpotBugs](https://spotbugs.github.io/)
- [Error Prone](https://errorprone.info/)
- [Jib](https://github.com/GoogleContainerTools/jib)

**Python**
- [Python Packaging User Guide](https://packaging.python.org/)
- [uv documentation](https://docs.astral.sh/uv/)
- [Poetry documentation](https://python-poetry.org/docs/)
- [Hatch documentation](https://hatch.pypa.io/latest/)
- [PEP 440 — Version Identification](https://peps.python.org/pep-0440/)
- [PEP 518 — pyproject.toml](https://peps.python.org/pep-0518/)
- [PEP 621 — Project Metadata](https://peps.python.org/pep-0621/)
- [pip documentation](https://pip.pypa.io/en/stable/)
- [pip-tools](https://pip-tools.readthedocs.io/)
- [PyPI](https://pypi.org/)
- [Trusted Publishers](https://docs.pypi.org/trusted-publishers/)
- [cibuildwheel](https://cibuildwheel.pypa.io/)
- [manylinux](https://github.com/pypa/manylinux)
- [Ruff](https://docs.astral.sh/ruff/)
- [mypy](https://mypy.readthedocs.io/)
- [pyright](https://microsoft.github.io/pyright/)
- [Black](https://black.readthedocs.io/)
- [PyInstaller](https://pyinstaller.org/)
- [Nuitka](https://nuitka.net/)
- [Pants](https://www.pantsbuild.org/)

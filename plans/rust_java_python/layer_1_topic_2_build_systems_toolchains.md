# Layer 1 · Topic 2 — Build Systems & Toolchains

> Comparative study of Rust, Java, and Python: how each language builds, manages dependencies, and ships software — from `cargo new` to production CI/CD.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.1 "Getting Started" pp. 1–11 | Installing Rust via rustup, Hello Cargo!, creating a Cargo project, building and running |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Ch.14 "More About Cargo and Crates.io" pp. 295–313 | Release profiles, publishing crates, documentation comments, `pub use` re-exports, workspaces, `cargo install`, custom commands |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Appendix D "Useful Development Tools" pp. 511–514 | rustfmt, rustfix, Clippy, rust-analyzer |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.8 "Crates and Modules" pp. 161–191 | Crate structure, build profiles, modules, paths/imports, tests, documentation, dependencies/Cargo.lock, publishing, workspaces |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.2 "Project Management with Cargo" pp. 11–42 | Creating projects, toolchains (stable/nightly), dependency management, Cargo.lock, feature flags, patching dependencies, publishing with CI/CD, linking to C libraries, cross-compilation, static linking, documentation, modules, workspaces, custom build scripts, embedded |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.3 "Rust Tooling" pp. 43–62 | rust-analyzer, rustfmt, Clippy, sccache, stable vs nightly, cargo-update, cargo-expand, cargo-fuzz, cargo-watch, cargo-tree, compilation time reduction |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.2 "The Java Programming Environment" | JDK installation, command-line tools (javac, java, jar), IDE setup, JShell |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.4 §4.8–4.10 "Packages", "JAR Files", "Documentation Comments" | Package organization, JAR file creation, manifest, executable JARs, Javadoc generation |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.12 "The Java Platform Module System" | JPMS, module-info.java, requires/exports, modular JARs, automatic/unnamed modules, jlink |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.2 "Java Modules" pp. 26–54 | Project Jigsaw, module graph, access control, building modular apps, multi-release JARs |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.11 "Building with Gradle and Maven" pp. 345–399 | Maven lifecycle, POM, dependency management, plugins; Gradle tasks, plugins, dependencies, Kotlin DSL, customization; testing integration; Maven module integration; Gradle-with-modules (JPMS integration) |
| Java | Oaks (2020) — *Java Performance* | Ch.4 pp. 115–120 | "The GraalVM" and "GraalVM Native Compilation" — JIT-vs-AOT tradeoffs, native-image startup/memory footprint, and peak-throughput comparison vs HotSpot C2 |
| Java | Beckwith (2024) — *JVM Performance Engineering* | Ch.8 pp. 290–298 | "GraalVM: Revolutionizing Java's Time to Steady State" — native-image generation, closed-world AOT, serverless start-up |
| Java | Evans & Gough (2024) — *Optimizing Cloud Native Java* | Ch.6 pp. 163–167 (AOT pp. 163–164, Quarkus pp. 164–166, GraalVM p. 167) | Ahead-of-time compilation, Quarkus native mode, GraalVM native-image build constraints (reflection configuration) |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.7 "Modules and Packages" pp. 221–245 | Module loading, import system, packages, distutils/setuptools, pip, wheels, virtual environments |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.24 "Packaging Programs and Extensions" pp. 655–658 | Brief history of Python packaging, PEP 517/518 and the pyproject.toml build-definition format, mentions of PyInstaller / PyOxidizer / cx_Freeze as out-of-scope distribution options and the standard-library `zipapp` module, pointers to online resources for the evolving ecosystem |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.7 "Compiling to C" pp. 161–211 | Cython compilation, Numba JIT (with a brief Nuitka mention on p. 189), PyPy, FFI tools (ctypes, cffi), build pipelines for C extensions |
| Python | Slatkin (2025) — *Effective Python* | Item 125 pp. 621–627 | "Prefer Open Source Projects for Bundling Python Programs over zipimport and zipapp" — `zipimport`/`zipapp`, Pex, and PyInstaller for executable bundling |

### Coverage Gaps

The owned books **do not** cover:

- **Python modern tooling** — Martelli Ch.24 pp. 655–658 covers PEP 517/518 and the pyproject.toml format and mentions poetry, flit, and hatch at a high level, but uv and PDM are not covered, and modern-workflow depth (lockfiles, workspace integrations, day-to-day usage of poetry/hatch/uv) is absent; the packaging landscape has shifted dramatically since these books were published
- **Dependency resolution algorithms** — Evans Ch.11 documents Maven's nearest-wins and Gradle's newest-version conflict-resolution rules at the policy level, but no owned book explains the underlying algorithms (PubGrub, Cargo's backtracking heuristics, pip's backtracking resolver) or version-resolution strategies at an algorithmic level
- **Reproducible builds** in a cross-language sense — Matthews covers Cargo.lock; Evans covers Maven/Gradle dependency management but not dependency locking or verification; Martelli Ch.7 mentions `pip freeze` → `requirements.txt` (no hashes by default) and pipenv's `Pipfile.lock` (which records and verifies package hashes per the pipenv docs), but the modern Python lockfile ecosystem (pip-compile, poetry.lock, uv.lock) is not covered at any depth
- **Mono-repo tooling beyond Cargo workspaces** — Maven multi-module aggregator projects (`<modules>` POM inheritance), Gradle multi-project builds, Gradle composite builds, and the polyglot mono-repo tools (Bazel, Pants, Turborepo, Nx) are not covered in any owned book
- **Cross-compilation for Java and Python** — Matthews covers Rust cross-compilation; Evans Ch.2 pp. 49–52 covers multi-release JARs; Oaks Ch.4 pp. 116–120, Beckwith Ch.8 pp. 290–298, and Evans/Gough Ch.6 pp. 163–167 cover GraalVM native-image. For Python: Martelli Ch.24 pp. 657–658 mentions PyInstaller, PyOxidizer, and cx_Freeze as out-of-scope distribution options and covers the standard-library `zipapp` module; Gorelick Ch.7 p. 189 briefly describes Nuitka as a Python compiler; Slatkin Item 125 pp. 621–627 surveys `zipimport`/`zipapp`, Pex, and PyInstaller for bundling. The multi-platform wheel CI side (cibuildwheel, the manylinux ABI spec) is not covered, and the in-depth treatment of PyInstaller / Nuitka / PyOxidizer (configuration, packaging C extensions, signing) is also absent — these are distinct concerns from wheel distribution (wheels ship a CPython-loadable artifact; PyInstaller/Nuitka produce stand-alone executables)
- **CI/CD integration patterns** — Matthews briefly touches on CI for crate publishing; comprehensive CI/CD pipeline design across all three is not addressed
- **Dependency vendoring** — `cargo vendor`, Maven offline mode, pip vendor/vendored wheels are not discussed

---

## External Resources

### Sub-topic 1 — Tool Overview & Project Scaffolding

**Rust**
- The Cargo Book (official, comprehensive): `https://doc.rust-lang.org/cargo/`
- The Cargo Book — "Creating a New Package": `https://doc.rust-lang.org/cargo/guide/creating-a-new-project.html`
- Rustup documentation (toolchain management): `https://rust-lang.github.io/rustup/`
- Rust edition guide (toolchain versions): `https://doc.rust-lang.org/edition-guide/`

**Java**
- Maven in 5 Minutes (official quickstart): `https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html`
- Maven — Introduction to Archetypes: `https://maven.apache.org/guides/introduction/introduction-to-archetypes.html`
- Gradle — Getting Started: `https://docs.gradle.org/current/userguide/getting_started_eng.html`
- Gradle — Build Init Plugin: `https://docs.gradle.org/current/userguide/build_init_plugin.html`
- SDKMAN — JDK version manager: `https://sdkman.io/`

**Python**
- Python Packaging User Guide (authoritative, PyPA): `https://packaging.python.org/`
- uv documentation (Astral): `https://docs.astral.sh/uv/`
- Poetry documentation: `https://python-poetry.org/docs/`
- Hatchling & Hatch documentation: `https://hatch.pypa.io/latest/`
- PEP 518 — pyproject.toml build-system specification: `https://peps.python.org/pep-0518/`
- PEP 621 — pyproject.toml project metadata: `https://peps.python.org/pep-0621/`

### Sub-topic 2 — Dependency Management & Resolution

**Rust**
- The Cargo Book — "Specifying Dependencies": `https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html`
- The Cargo Book — "The Manifest Format" (Cargo.toml): `https://doc.rust-lang.org/cargo/reference/manifest.html`
- Cargo's dependency resolution algorithm: `https://doc.rust-lang.org/cargo/reference/resolver.html`
- Cargo — Feature flags: `https://doc.rust-lang.org/cargo/reference/features.html`

**Java**
- Maven — Introduction to the Dependency Mechanism: `https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html`
- Maven — Dependency Mediation and Conflict Resolution: `https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#dependency-mediation`
- Gradle — Dependency Management: `https://docs.gradle.org/current/userguide/dependency_management.html`
- Gradle — Dependency Resolution: `https://docs.gradle.org/current/userguide/dependency_resolution.html`
- Maven Central Repository: `https://central.sonatype.com/`

**Python**
- pip documentation — Requirements files: `https://pip.pypa.io/en/stable/reference/requirements-file-format/`
- pip documentation — Dependency Resolution: `https://pip.pypa.io/en/stable/topics/dependency-resolution/`
- uv — Dependency management: `https://docs.astral.sh/uv/concepts/dependencies/`
- Poetry — Dependency specification: `https://python-poetry.org/docs/dependency-specification/`
- PEP 440 — Version Identification and Dependency Specification: `https://peps.python.org/pep-0440/`
- PyPI (Python Package Index): `https://pypi.org/`

### Sub-topic 3 — Reproducible Builds, Lockfiles & Vendoring

**Rust**
- The Cargo Book — "Cargo.toml vs Cargo.lock": `https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html`
- The Cargo Book — "cargo vendor": `https://doc.rust-lang.org/cargo/commands/cargo-vendor.html`
- Reproducible Builds project: `https://reproducible-builds.org/`

**Java**
- Gradle — Dependency Locking: `https://docs.gradle.org/current/userguide/dependency_locking.html`
- Gradle — Dependency Verification: `https://docs.gradle.org/current/userguide/dependency_verification.html`
- Maven — Bill of Materials (BOM): `https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#bill-of-materials-bom-poms`
- Maven Wrapper: `https://maven.apache.org/wrapper/`
- Gradle Wrapper: `https://docs.gradle.org/current/userguide/gradle_wrapper.html`

**Python**
- uv — Resolution and lockfile (uv.lock): `https://docs.astral.sh/uv/concepts/resolution/`
- Poetry — poetry.lock: `https://python-poetry.org/docs/basic-usage/#installing-with-poetrylock`
- pip-tools (pip-compile for lockfiles): `https://pip-tools.readthedocs.io/`
- PEP 665 — A file format to list Python dependencies for reproducibility (rejected, but informative): `https://peps.python.org/pep-0665/`

### Sub-topic 4 — Workspaces & Mono-repo Tooling

**Rust**
- The Cargo Book — Workspaces: `https://doc.rust-lang.org/cargo/reference/workspaces.html`

**Java**
- Gradle — Multi-project Builds: `https://docs.gradle.org/current/userguide/multi_project_builds.html`
- Gradle — Composite Builds: `https://docs.gradle.org/current/userguide/composite_builds.html`
- Maven — Multi-Module Projects: `https://maven.apache.org/guides/mini/guide-multiple-modules.html`

**Python**
- uv — Workspaces: `https://docs.astral.sh/uv/concepts/workspaces/`
- Hatch — Multi-environment projects: `https://hatch.pypa.io/latest/config/environment/overview/`
- Pants build system (polyglot mono-repo): `https://www.pantsbuild.org/`

### Sub-topic 5 — Cross-compilation & Target Platforms

**Rust**
- Rustup — Cross-compilation: `https://rust-lang.github.io/rustup/cross-compilation.html`
- The Cargo Book — Build scripts: `https://doc.rust-lang.org/cargo/reference/build-scripts.html`
- cross (Docker-based cross-compilation tool): `https://github.com/cross-rs/cross`
- Rust Platform Support: `https://doc.rust-lang.org/rustc/platform-support.html`

**Java**
- GraalVM Native Image: `https://www.graalvm.org/latest/reference-manual/native-image/`
- JLink — Custom runtime images: `https://docs.oracle.com/en/java/javase/21/docs/specs/man/jlink.html`
- Multi-release JAR files (JEP 238): `https://openjdk.org/jeps/238`

**Python**
- cibuildwheel — Build wheels across platforms in CI: `https://cibuildwheel.pypa.io/`
- manylinux specification: `https://github.com/pypa/manylinux`
- PyInstaller (bundling into executables): `https://pyinstaller.org/`
- Nuitka (Python compiler): `https://nuitka.net/`

### Sub-topic 6 — Toolchain Ecosystem (Linters, Formatters, LSPs)

**Rust**
- Clippy lints list: `https://rust-lang.github.io/rust-clippy/master/`
- rustfmt configuration: `https://rust-lang.github.io/rustfmt/`
- rust-analyzer manual: `https://rust-analyzer.github.io/manual.html`

**Java**
- Checkstyle: `https://checkstyle.org/`
- SpotBugs (static analysis): `https://spotbugs.github.io/`
- Google Java Format: `https://github.com/google/google-java-format`
- Error Prone (compile-time bug detection): `https://errorprone.info/`
- JetBrains IntelliJ IDEA: `https://www.jetbrains.com/idea/`

**Python**
- Ruff (linter + formatter, Rust-based): `https://docs.astral.sh/ruff/`
- mypy (static type checker): `https://mypy.readthedocs.io/`
- pyright (Microsoft type checker): `https://microsoft.github.io/pyright/`
- Black (code formatter): `https://black.readthedocs.io/`
- pylint: `https://pylint.readthedocs.io/`

### Sub-topic 7 — CI/CD Integration Patterns

**Rust**
- GitHub Actions — Rust toolchain action: `https://github.com/dtolnay/rust-toolchain`
- The Cargo Book — Publishing: `https://doc.rust-lang.org/cargo/reference/publishing.html`
- cargo-release (automated versioning): `https://github.com/crate-ci/cargo-release`

**Java**
- Maven Release Plugin: `https://maven.apache.org/maven-release/maven-release-plugin/`
- Gradle — Publishing: `https://docs.gradle.org/current/userguide/publishing_setup.html`
- Jib (container image building without Docker): `https://github.com/GoogleContainerTools/jib`

**Python**
- PyPA — Publishing packages tutorial: `https://packaging.python.org/en/latest/tutorials/packaging-projects/`
- Trusted Publishers on PyPI (OIDC): `https://docs.pypi.org/trusted-publishers/`
- uv — CI usage: `https://docs.astral.sh/uv/guides/integration/github/`

---

## Suggested Additional Books

| Language | Book | Why |
|----------|------|-----|
| Java | Koshuke Kawaguchi et al — *Maven: The Definitive Guide* (O'Reilly, 2008) | The canonical Maven reference; outdated in places but foundational for understanding Maven lifecycle, POM inheritance, and plugin architecture |
| Java | Benjamin Muschko — *Gradle in Action* (Manning, 2014) | Deep Gradle coverage: task model, dependency management, multi-project builds, custom plugins, migration from Maven |
| Python | Dane Hillard — *Publishing Python Packages* (Manning, 2023) | Modern Python packaging end-to-end: pyproject.toml, building wheels, CI/CD with GitHub Actions, publishing to PyPI, documentation, testing, versioning |

---

## Study Plan — 7 Sessions

Estimated total: **11–15 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous, progressing from basic scaffolding through dependency management to advanced CI/CD workflows.

---

### Session 1 — Tool Overview & Project Scaffolding

**Goal:** set up all three toolchains and scaffold a new project in each language; understand the role and philosophy of each build system.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 25 min | **Rust: Cargo.** Read Klabnik Ch.1 pp. 1–11 (Hello Cargo!, creating/building/running). Then read Matthews Ch.2 pp. 11–16 (Cargo tour: creating projects, building, running, testing, toolchains). Note: Cargo is an all-in-one build system, package manager, test runner, and documentation generator. Run `cargo new hello-rust`, examine `Cargo.toml` and `src/main.rs`, build and run. |
| 1.2 | 25 min | **Java: Maven & Gradle.** Read Evans Ch.11 pp. 345–360 (Maven lifecycle, POM structure, basic project). Read Horstmann Ch.2 (JDK installation, command-line tools). Note: Java has two major build tools — Maven (convention-over-configuration, XML-based, 2004) and Gradle (flexible, Groovy/Kotlin DSL, 2012). Run `mvn archetype:generate` to scaffold a Maven project, then `gradle init` for a Gradle project. Compare the generated directory structures. |
| 1.3 | 25 min | **Python: pip, uv, poetry.** Read Martelli Ch.7 pp. 221–245 (modules, packages, pip/setuptools, virtual environments). Then read Martelli Ch.24 pp. 655–658 (packaging history). Read the uv documentation quickstart online. Note: Python's packaging has been fragmented — `distutils` (deprecated) → `setuptools` → `pip` → `poetry`/`hatch`/`uv` (modern). Run `uv init hello-python`, examine `pyproject.toml`, and compare with `poetry new hello-poetry`. |
| 1.4 | 15 min | **Cross-language comparison.** Create a comparison table: rows = {config file format, project structure convention, default test location, documentation generation, REPL/interactive mode}, columns = {Cargo, Maven, Gradle, pip/uv, poetry}. Note how Cargo and uv converge on TOML while Maven uses XML and Gradle uses a DSL. |

---

### Session 2 — Dependency Management & Resolution

**Goal:** understand how each ecosystem discovers, resolves, and pins dependencies; explore version constraint syntax and conflict resolution strategies.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **Rust: Cargo dependencies.** Read Matthews Ch.2 pp. 17–25 (dependency management, Cargo.lock, feature flags, patching dependencies). Then read Blandy Ch.8 pp. 178–185 (dependencies, versions, Cargo.lock). Read "Specifying Dependencies" and "Resolver" in The Cargo Book online. Key insight (per the Cargo resolver docs): Cargo's resolver prefers the highest semver-compatible version of each dependency and uses heuristics + backtracking (not a SAT solver) to satisfy constraints. `Cargo.toml` specifies semver ranges, `Cargo.lock` pins exact versions. Feature flags allow conditional compilation of dependency features. |
| 2.2 | 30 min | **Java: Maven & Gradle dependencies.** Read Evans Ch.11 pp. 360–376 (Maven dependency management §11.2.7, scopes, transitive dependencies). Then read Evans Ch.11 pp. 382–387 (Gradle §11.3.7 "Dependencies in Gradle" — configurations, conflict resolution). Read "Introduction to the Dependency Mechanism" on maven.apache.org online. Key insight: Maven uses "nearest wins" for conflict resolution (shortest path in dependency tree); Gradle defaults to "newest version wins." Both use coordinate triples (groupId:artifactId:version). |
| 2.3 | 25 min | **Python: pip, uv, poetry dependencies.** Read the pip documentation on dependency resolution online. Then read the uv documentation on dependency management and resolution. Read PEP 440 (version specifiers) online. Key insight: pip historically had no resolver (just installed latest), then added a backtracking resolver in 2020. Per their own docs, uv uses the PubGrub algorithm and poetry uses a PubGrub-style backtracking resolver — both are conflict-driven backtracking solvers (not raw SAT solvers). Python uses `~=`, `>=`, `==`, `!=` version specifiers per PEP 440. |
| 2.4 | 15 min | **Comparative analysis.** Compare: (1) version constraint syntax (`^1.2`, `~1.2` in Cargo vs `[1.2,2.0)` in Maven vs `>=1.2,<2.0` in Python); (2) conflict resolution strategy (Cargo's highest-version-preference backtracking vs Maven's nearest-wins vs Gradle's newest-wins vs pip's backtracking vs uv/poetry's PubGrub); (3) registry model (crates.io vs Maven Central vs PyPI). Note: Cargo and uv are both written in Rust and share similar design philosophy around resolution. |

---

### Session 3 — Reproducible Builds, Lockfiles & Vendoring

**Goal:** understand how each ecosystem achieves reproducible builds through lockfiles, checksums, vendoring, and build wrappers.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 25 min | **Rust: Cargo.lock and vendoring.** Re-read Matthews Ch.2 pp. 18–19 (Cargo.lock in depth). Read "Cargo.toml vs Cargo.lock" in The Cargo Book online. Then read the `cargo vendor` documentation online. Key insight: `Cargo.lock` is committed for binaries, not for libraries. `cargo vendor` copies all dependency source code locally. Checksums in `Cargo.lock` verify integrity. |
| 3.2 | 25 min | **Java: dependency locking and verification.** Read "Dependency Locking" and "Dependency Verification" in the Gradle docs online. Read about Maven Wrapper and Gradle Wrapper online. Key insight: Gradle supports dependency locking (`--write-locks`) and verification via SHA checksums. Maven has no native lockfile but achieves reproducibility through exact version pinning and the BOM (Bill of Materials) pattern. Both provide wrappers (mvnw/gradlew) to pin the build tool version itself. |
| 3.3 | 25 min | **Python: lockfiles and pinning.** Read Martelli Ch.7 pp. 242–243 ("Managing Dependency Requirements" on p. 242 and "Other Environment Management Solutions" on p. 243) on `pip freeze` → `requirements.txt` and pipenv's `Pipfile.lock`. Then read about poetry.lock on poetry docs, uv.lock on uv docs, and pip-tools (pip-compile) online. Key insight: Martelli documents the original recreate-an-environment pattern (`pip freeze` to capture exact versions, `pip install -r requirements.txt` to restore — which does not include hashes by default) and pipenv's `Pipfile.lock` (per the pipenv docs, `Pipfile.lock` records exact versions plus package hashes and verifies them on install). poetry.lock and uv.lock continue the hash-verified lockfile model; `pip-compile` (pip-tools) generates pinned requirements (with `--generate-hashes` for hash verification) from loose specifications. The ecosystem is converging but not yet standardized (PEP 665 was rejected). |
| 3.4 | 15 min | **Comparison and hands-on.** In your three sample projects: (1) add a dependency to each, (2) observe the lockfile generated, (3) vendor dependencies in Rust (`cargo vendor`), (4) compare the information captured in each lockfile format (versions, checksums, sources, platform markers). Document which ecosystems achieve true reproducibility out of the box versus requiring extra tooling. |

---

### Session 4 — Workspaces & Mono-repo Tooling

**Goal:** understand how each ecosystem supports multi-package projects and mono-repo development patterns.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 30 min | **Rust: Cargo workspaces.** Read Klabnik Ch.14 pp. 307–311 (Cargo Workspaces — creating a workspace, adding packages, depending between workspace members). Read Matthews Ch.2 pp. 38–39 (workspaces). Read Blandy Ch.8 pp. 188–190 (workspaces). Then read "Workspaces" in The Cargo Book online. Key insight: A Cargo workspace shares a single `Cargo.lock` and `target/` directory across multiple crates. Members can depend on each other by path. Workspace-level dependency inheritance (`[workspace.dependencies]`) reduces duplication. |
| 4.2 | 30 min | **Java: multi-module projects.** Note: the owned books do not cover Maven multi-module / Gradle multi-project / composite builds — Evans Ch.11 covers JPMS-module integration in Maven and Gradle, which is a different concept. Read "Multi-project Builds" and "Composite Builds" in the Gradle docs online, and read the "Guide to Working with Multiple Modules" page on maven.apache.org. Key insight: Maven uses parent POM inheritance with `<modules>` aggregation. Gradle uses `settings.gradle` with `include` directives and supports composite builds for repository-independent project composition. Both support Bill of Materials for dependency version alignment. |
| 4.3 | 20 min | **Python: workspaces and mono-repos.** Read uv documentation on workspaces online. Read about Hatch multi-environment projects online. Read about Pants build system (polyglot mono-repo) online. Key insight: Python workspace support is nascent — uv workspaces (inspired by Cargo) landed recently. Historically, Python mono-repos relied on external tools like Pants, Bazel, or Nx. Poetry does not support workspaces natively. |
| 4.4 | 10 min | **Comparison.** Create a feature matrix: rows = {shared lockfile, shared build cache, cross-package references, dependency version alignment, incremental builds}, columns = {Cargo workspaces, Maven multi-module, Gradle multi-project, uv workspaces}. Note maturity levels: Cargo (mature), Maven/Gradle (mature), Python (emerging). |

---

### Session 5 — Cross-compilation & Target Platforms

**Goal:** understand how each language targets multiple platforms, architectures, and deployment formats.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust: cross-compilation.** Read Matthews Ch.2 pp. 27–31 (linking to C libraries, binary distribution, cross-compilation, static linking). Then read Rust Platform Support page and `rustup` cross-compilation docs online. Browse the `cross` tool on GitHub. Key insight: Rust has first-class cross-compilation — `rustup target add` installs a target, `cargo build --target` compiles for it. The `cross` tool uses Docker containers for linker/sysroot management. Rust supports 80+ targets (Linux, macOS, Windows, WASM, embedded, no-std). Static linking with musl produces fully self-contained binaries. |
| 5.2 | 25 min | **Java: platform targeting.** Read Horstmann Ch.12 on the module system (modular JARs, jlink for custom runtimes). Read Evans Ch.2 pp. 49–52 (multi-release JARs). Read Oaks Ch.4 pp. 116–120 (GraalVM and native compilation tradeoffs) and Beckwith Ch.8 pp. 290–298 ("GraalVM: Revolutionizing Java's Time to Steady State" — native-image generation, closed-world AOT). Optionally read Evans/Gough Ch.6 pp. 163–167 (AOT pp. 163–164, Quarkus pp. 164–166, GraalVM p. 167) for additional GraalVM/Quarkus context. Read JEP 238 (multi-release JARs) online. Key insight: Java's "write once, run anywhere" means cross-compilation is usually unnecessary — JARs run anywhere a JVM exists. But for native deployment: GraalVM Native Image compiles to platform-specific binaries (Oaks documents the AOT tradeoff vs HotSpot C2 peak throughput; Beckwith Ch.8 covers closed-world AOT and native-image startup behavior; Evans/Gough Ch.6 documents the build-time reflection-configuration requirement — reflective code must be enumerated in a config file when the static analysis can't infer it), jlink creates custom JRE images, and multi-release JARs package version-specific class files. |
| 5.3 | 25 min | **Python: platform-specific distribution.** Read Martelli Ch.24 pp. 657–658 (PyInstaller, PyOxidizer, cx_Freeze, and `zipapp` introductions), Gorelick Ch.7 p. 189 (brief Nuitka description), and Slatkin Item 125 pp. 621–627 ("Prefer Open Source Projects for Bundling Python Programs over zipimport and zipapp" — `zipapp`, Pex, PyInstaller). Then read Gorelick Ch.7 pp. 161–170 (compilation overview — JIT vs AOT, Cython intro). Read about cibuildwheel and manylinux online (those are not in the owned books). Key insight: Pure Python code is platform-independent, but C extensions require platform-specific wheels. `cibuildwheel` automates building wheels for Linux (manylinux), macOS, and Windows in CI. `PyInstaller` and `Nuitka` bundle Python + interpreter into standalone executables. The `manylinux` spec defines a portable Linux ABI baseline. |
| 5.4 | 10 min | **Comparison.** Document: Rust (native cross-compilation, many targets, static linking) vs Java (JVM portability, GraalVM for native) vs Python (pure Python portable, C extensions need per-platform builds). Consider: which approach is simplest for CLI tools? For libraries? For embedded? |

---

### Session 6 — Toolchain Ecosystem (Linters, Formatters, LSPs)

**Goal:** survey the developer experience tooling for each language — formatting, linting, IDE support, and auxiliary tools that improve daily workflow.

| Step | Time | Activity |
|------|------|----------|
| 6.1 | 30 min | **Rust tooling.** Read Matthews Ch.3 pp. 43–62 (full chapter: rust-analyzer, rustfmt, Clippy, sccache, stable vs nightly, cargo-update, cargo-expand, cargo-fuzz, cargo-watch, cargo-tree). Read Klabnik Appendix D pp. 511–514 (rustfmt, rustfix, Clippy, rust-analyzer). Browse Clippy lints list online. Key insight: Rust's tooling is unified and official — `rustfmt`, `clippy`, and `rust-analyzer` are all maintained by the Rust project. `cargo` serves as the single entry point. `sccache` enables distributed compilation caching. |
| 6.2 | 25 min | **Java tooling.** Read about Checkstyle, SpotBugs, Error Prone, and Google Java Format online. Note IDE dominance: IntelliJ IDEA (JetBrains) is the de facto standard, with built-in formatting, refactoring, and analysis. Key insight: Java tooling is IDE-centric rather than CLI-centric. IntelliJ and Eclipse provide LSP-equivalent features natively. CLI linters (Checkstyle, SpotBugs) are typically integrated as Maven/Gradle plugins. Error Prone operates at compile time via javac annotation processing. |
| 6.3 | 25 min | **Python tooling.** Read about Ruff, mypy, pyright, Black online. Key insight: Python tooling has undergone a revolution — Ruff (written in Rust) replaces pylint + flake8 + isort + pyupgrade with 10–100x speed improvement. Black is the opinionated formatter ("any color you like"). mypy and pyright provide static type checking for gradual typing. The LSP is provided by Pylance (VS Code, proprietary) or pyright (open source). |
| 6.4 | 10 min | **Comparison table.** Create a matrix: rows = {official formatter, linter, type checker, LSP, build cache, REPL}, columns = {Rust, Java, Python}. Note philosophy differences: Rust (official, unified), Java (IDE-centric, plugin ecosystem), Python (community-driven, recently consolidating via Astral/Ruff/uv). |

---

### Session 7 — CI/CD Integration Patterns

**Goal:** understand how each ecosystem integrates with CI/CD pipelines for automated testing, building, and publishing.

| Step | Time | Activity |
|------|------|----------|
| 7.1 | 25 min | **Rust CI/CD.** Read Matthews Ch.2 pp. 24–27 (publishing crates, CI/CD integration). Read Matthews Ch.3 pp. 54–55 (Clippy in CI/CD). Read about `dtolnay/rust-toolchain` GitHub Action and `cargo-release` online. Then read "Publishing" in The Cargo Book online. Key insight: A typical Rust CI pipeline: `cargo fmt --check` → `cargo clippy -- -D warnings` → `cargo test` → `cargo build --release`. Publishing to crates.io uses API tokens. `cargo-release` automates version bumps, git tags, and publishing. |
| 7.2 | 25 min | **Java CI/CD.** Read Evans Ch.11 pp. 387–399 (Gradle multi-language with Kotlin, testing, static analysis, beyond Java 8, modules, customization). Read about Maven Release Plugin and Gradle Publishing online. Read about Jib online. Key insight: Maven/Gradle integrate with CI via wrapper scripts (mvnw/gradlew) that pin the build tool version. Maven Central publishing requires GPG signing and staging. Gradle Build Cache can be shared across CI runs. Jib builds optimized Docker images without a Docker daemon. |
| 7.3 | 25 min | **Python CI/CD.** Read about PyPA publishing tutorial, Trusted Publishers, and uv CI integration online. Key insight: PyPI now supports Trusted Publishers via OIDC — GitHub Actions can publish without storing API tokens. `uv` provides fast CI setup (caching, lockfile installation). A typical Python CI pipeline: `uv sync` → `ruff check` → `ruff format --check` → `mypy .` → `pytest` → `uv build` → publish. `cibuildwheel` handles building platform-specific wheels in CI. |
| 7.4 | 15 min | **Cross-language synthesis.** Compare: (1) package registry security models (crates.io vs Maven Central vs PyPI — who can publish, how are packages verified); (2) build caching strategies (Cargo incremental + sccache, Gradle Build Cache, uv cache); (3) release automation (cargo-release, Maven Release Plugin, trusted publishers). Write a template CI/CD pipeline for each language that covers lint → format → test → build → publish. |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | Tool overview & scaffolding | Klabnik 1–11, Matthews 11–16, Evans 345–360, Horstmann Ch.2, Martelli 221–245 + 655–658 | Cargo Book, Maven quickstart, Gradle getting started, uv docs, packaging.python.org |
| 2 | Dependency management & resolution | Matthews 17–25, Blandy 178–185, Evans 360–376 + 382–387 | Cargo resolver docs, Maven dependency mechanism, Gradle dependency management, pip/uv resolution, PEP 440 |
| 3 | Reproducible builds & lockfiles | Matthews 18–19, Martelli 242–243 | Cargo.lock guide, Gradle dependency locking/verification, poetry.lock, uv.lock, pip-tools |
| 4 | Workspaces & mono-repos | Klabnik 307–311, Matthews 38–39, Blandy 188–190 (Java multi-module/multi-project/composite builds are external-only — see Gradle/Maven docs) | Cargo workspaces, Gradle multi-project/composite builds, Maven multi-module, uv workspaces, Pants |
| 5 | Cross-compilation & targets | Matthews 27–31, Gorelick 161–170 + 189, Horstmann Ch.12, Evans 49–52, Oaks 116–120, Beckwith 290–298, Evans/Gough 163–167, Martelli 657–658, Slatkin Item 125 (pp. 621–627) | Rust platform support, cross tool, GraalVM native image, jlink, cibuildwheel, manylinux |
| 6 | Toolchain ecosystem | Matthews 43–62, Klabnik App.D 511–514 | Clippy lints, rustfmt, rust-analyzer, Checkstyle, SpotBugs, Error Prone, Ruff, mypy, pyright, Black |
| 7 | CI/CD integration | Matthews 24–27 + 54–55, Evans 387–399 | rust-toolchain Action, cargo-release, Maven Release Plugin, Gradle publishing, Jib, PyPA publishing, Trusted Publishers, uv CI guide |

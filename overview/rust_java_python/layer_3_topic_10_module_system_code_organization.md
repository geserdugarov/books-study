# Layer 3 · Topic 10 — Module System & Code Organization

> Comparative study of Rust, Java, and Python: how each language organizes code into modules and packages, controls visibility and encapsulation boundaries, manages external dependencies, enforces API compatibility through semantic versioning, and uses conditional compilation and feature flags to shape the public API surface.

---

## 1. Module System Fundamentals

Every language needs a way to split code into manageable units, name those units, and compose them into larger programs. The fundamental question is: what is the unit of organization, and how does source code map to it? Rust answers with a two-level crate/module hierarchy where every module must be explicitly declared. Java answers with packages that map to directory structure and classes that map to files. Python answers with modules (any `.py` file) and packages (directories), where importing a module executes it. These choices ripple through everything — how names are resolved, how compilation works, and how large projects are structured.

### Rust: Crates, Modules, and the Module Tree

Rust has a two-level hierarchy. The **crate** is the compilation unit — the smallest amount of code the Rust compiler considers at a time. The **module** is the organizational unit within a crate, forming a tree rooted at the crate root file.

A crate comes in two forms: a **binary crate** (with a `main` function, compiles to an executable) and a **library crate** (no `main`, compiles to a `.rlib` for use by other crates). A **package** is a Cargo concept — one or more crates bundled with a `Cargo.toml` manifest. A package can contain at most one library crate and any number of binary crates.

The crate root file (`src/lib.rs` for libraries, `src/main.rs` for binaries) defines the root of the module tree. Modules are declared with `mod name;` and can be defined inline or in separate files:

```rust
// src/lib.rs — the crate root
mod math_utils;      // Loads from src/math_utils.rs or src/math_utils/mod.rs
mod string_utils;    // Loads from src/string_utils.rs or src/string_utils/mod.rs

pub use math_utils::add;  // Re-export for a flat public API
```

```rust
// src/math_utils.rs
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn internal_helper() -> i32 {  // Private — only visible within this module
    42
}
```

Since the 2018 edition, the preferred file layout uses `name.rs` with a `name/` directory for submodules (rather than the older `name/mod.rs` convention). A module `crate::util::config` maps to the file `src/util/config.rs`:

```rust
// src/util.rs — declares submodules
pub mod config;   // Loads from src/util/config.rs
pub mod logging;  // Loads from src/util/logging.rs
```

The module tree is **explicit** — a module does not exist unless declared from its parent. This is unlike Java and Python where the file system implicitly defines the structure. The `#[path]` attribute can override the default file location: `#[path = "foo.rs"] mod bar;`.

Name resolution uses paths with three anchors:
- `crate::` — absolute path from the crate root
- `super::` — relative path to the parent module
- `self::` — relative path to the current module

```rust
mod outer {
    pub mod inner {
        pub fn greet() { println!("hello"); }
    }

    pub fn call_inner() {
        // All three paths reach the same function:
        crate::outer::inner::greet();  // Absolute
        self::inner::greet();          // Relative to current module
        inner::greet();                // Shortened (same as self::)
    }
}

mod sibling {
    pub fn call_outer() {
        super::outer::inner::greet();  // Up one level, then down
    }
}
```

The `use` keyword brings paths into scope. `pub use` re-exports items, which is critical for creating clean public APIs from complex internal module hierarchies:

```rust
// src/lib.rs
mod internal {
    pub mod parser {
        pub mod ast {
            pub struct Node { /* ... */ }
        }
    }
}

// Users see mycrate::Node instead of mycrate::internal::parser::ast::Node
pub use internal::parser::ast::Node;
```

Every crate implicitly imports the **standard prelude** — a set of commonly used types and traits (`Option`, `Result`, `Vec`, `String`, `Clone`, `Copy`, `Iterator`, etc.) that are available without explicit `use` statements.

> **Sources:** Klabnik & Nichols (2023) Ch.7 pp. 119–140 · Blandy & Orendorff (2017) Ch.8 pp. 161–175 · [Rust Reference — Modules](https://doc.rust-lang.org/reference/items/modules.html) · [Rust Reference — Crates and Source Files](https://doc.rust-lang.org/reference/crates-and-source-files.html) · [Rust By Example — Modules](https://doc.rust-lang.org/rust-by-example/mod.html) · [Cargo Book — Project Layout](https://doc.rust-lang.org/cargo/guide/project-layout.html)

### Java: Packages, Classes, and the Classpath

Java's module system operates at three levels: the **package** is the fundamental organizational unit, the **class** (or interface) is the unit of compilation, and the **JAR** is the distribution unit.

A package is a reverse-domain-name namespace (`com.example.app.util`) that maps directly to the directory structure. Each public class must reside in a file named after it (`MyClass.java` compiles to `MyClass.class`). The package declaration must be the first statement in every source file:

```java
// File: src/main/java/com/example/mathutils/MathUtils.java
package com.example.mathutils;

public class MathUtils {
    public static int add(int a, int b) {
        return a + b;
    }

    // Package-private — visible only within com.example.mathutils
    static int internalHelper() {
        return 42;
    }
}
```

```java
// File: src/main/java/com/example/app/Main.java
package com.example.app;

import com.example.mathutils.MathUtils;        // Single-type import
// import com.example.mathutils.*;              // Type-import-on-demand (all public types)
// import static com.example.mathutils.MathUtils.add;  // Static import

public class Main {
    public static void main(String[] args) {
        System.out.println(MathUtils.add(2, 3));
    }
}
```

Import statements in Java are purely **syntactic conveniences** — they do not load anything (unlike Python's `import`). `import com.example.MathUtils;` simply allows you to write `MathUtils` instead of `com.example.MathUtils`. Every compilation unit automatically imports `java.lang.*`.

Java has four import forms:
- **Single-type import:** `import java.util.List;`
- **Type-import-on-demand:** `import java.util.*;`
- **Single-static import:** `import static java.lang.Math.PI;`
- **Static-import-on-demand:** `import static java.lang.Math.*;`

Packages are **open namespaces** — any JAR can contribute classes to any package. This is both a strength (extensibility) and a source of "JAR hell" where multiple JARs provide conflicting versions of the same class. The Java Platform Module System (JPMS, Java 9+) was designed to fix this by introducing explicit module boundaries (covered in Section 5).

A JAR file is a ZIP archive of `.class` files with a `META-INF/MANIFEST.MF` manifest. It is the standard distribution format. Multi-release JARs (Java 9+) can contain version-specific classes under `META-INF/versions/N/` for different Java runtimes.

Bloch's Item 25 states a practical rule: **limit source files to a single top-level class**. While Java technically allows multiple non-public top-level classes in one file, this creates fragile coupling to compilation order and makes code harder to find.

> **Sources:** Horstmann (2024) Ch.4 §4.8–4.9 pp. 63–64 · Bloch (2018) Ch.4 Item 25 pp. 115 · [JLS Ch.7 — Packages and Modules](https://docs.oracle.com/javase/specs/jls/se21/html/jls-7.html) · [Oracle Java Tutorial — Creating and Using Packages](https://docs.oracle.com/javase/tutorial/java/package/packages.html) · [Baeldung — Guide to Java Packages](https://www.baeldung.com/java-packages)

### Python: Modules, Packages, and the Import System

In Python, a **module** is any `.py` file. Importing it executes the file and creates a module object stored in `sys.modules`. A **package** is a directory — either a **regular package** (containing `__init__.py`) or a **namespace package** (without `__init__.py`, PEP 420).

```python
# mypackage/__init__.py — executed when the package is first imported
from .math_utils import add        # Selective re-export
from .string_utils import capitalize

__all__ = ["add", "capitalize"]    # Controls "from mypackage import *"
```

```python
# mypackage/math_utils.py
def add(a: int, b: int) -> int:
    return a + b

def _internal_helper() -> int:    # Private by convention (leading underscore)
    return 42
```

```python
# main.py
from mypackage import add                     # Uses __init__.py re-export
from mypackage.math_utils import add          # Direct module access
import mypackage.string_utils as su           # Aliased import
```

The import system is **highly dynamic**. When Python encounters `import foo`, it:
1. Checks `sys.modules` cache — if already imported, returns the cached module
2. Runs **finders** (meta path finders in `sys.meta_path`) to locate the module
3. Uses **loaders** to execute the module code and create the module object
4. Binds the result to the local name

`sys.path` determines where modules are found — a list of directories and ZIP archives searched in order: the script's directory, `PYTHONPATH` entries, then installation defaults. Bytecode is cached in `__pycache__/` for faster subsequent loads.

Python supports both absolute and relative imports (PEP 328):

```python
# Absolute import — searches sys.path
from mypackage.math_utils import add

# Relative imports — use leading dots
from . import math_utils          # Same package
from .math_utils import add       # Same package, specific name
from .. import other_package      # Parent package
from ...sibling import module     # Grandparent's sibling
```

Relative imports must use the `from ... import ...` syntax — `import .foo` is not valid.

A critical difference from Rust and Java: **importing a module executes code**. This means imports have side effects, and circular imports are a common pitfall. If module A imports module B, and B imports A, the second import sees a partially-loaded module because A hasn't finished executing. Slatkin offers three solutions: restructure the code, move imports inside functions (deferred imports), or use late binding.

The `__name__ == "__main__"` pattern distinguishes between a module being imported and being run as a script:

```python
def main():
    print("Running as script")

if __name__ == "__main__":
    main()
```

**Namespace packages** (PEP 420) enable splitting a package across multiple directories or distributions without `__init__.py`. This is used by large organizations to distribute a shared namespace (`google.*`, `azure.*`). Namespace packages have no `__file__` attribute and their `__path__` is computed dynamically.

> **Sources:** Martelli et al (2023) Ch.7 pp. 221–245 · Slatkin (2025) Ch.14 Item 119 pp. 588–592, Item 122 pp. 600–604 · [Python docs — The Import System](https://docs.python.org/3/reference/import.html) · [Python docs — Modules tutorial](https://docs.python.org/3/tutorial/modules.html) · [PEP 328 — Imports: Multi-Line and Absolute/Relative](https://peps.python.org/pep-0328/) · [Real Python — Python Modules and Packages](https://realpython.com/python-modules-packages/) · [PEP 420 — Implicit Namespace Packages](https://peps.python.org/pep-0420/)

### Cross-Language Comparison

| Concept | Rust | Java | Python |
|---------|------|------|--------|
| **Compilation unit** | Crate | Class (`.java` → `.class`) | Module (`.py` file) |
| **Organizational unit** | Module (within crate) | Package (directory namespace) | Package (directory with `__init__.py`) |
| **Distribution unit** | Crate (on crates.io) | JAR file | Distribution package (on PyPI) |
| **Hierarchy** | crate → module → item | module (JPMS) → package → class | package → module → name |
| **Module existence** | Explicit (`mod` declaration) | Implicit (file = class) | Implicit (file = module, dir + `__init__.py` = package) |
| **Name resolution** | Paths: `crate::`, `super::`, `self::` | Fully qualified: `com.example.Class` | Dot notation: `package.module.name` |
| **Import semantics** | `use` binds a path to local name | `import` is syntactic shorthand only | `import` executes module code |
| **Side effects on import** | None (compile-time only) | None (class loading is lazy) | Yes (module code executes) |
| **Circular imports** | Not possible (compile-time tree) | Allowed (classes loaded on demand) | Possible but fragile (partial modules) |
| **Implicit imports** | Standard prelude | `java.lang.*` | `builtins` module |

---

## 2. Visibility and Access Control

Encapsulation — hiding implementation details behind a public API — is a fundamental principle, but each language enforces it differently. Rust uses compiler-enforced visibility modifiers with module-level granularity. Java uses four access modifiers at the class member level plus JPMS module boundaries. Python relies entirely on naming conventions and developer trust. These differences reflect deep philosophical choices about the role of the compiler versus the community.

### Rust: Visibility Modifiers and Privacy Rules

Rust has five visibility levels, all enforced at compile time:

| Modifier | Visibility |
|----------|-----------|
| *(none)* — private | Current module and its descendants only |
| `pub(self)` | Same as private (explicit form) |
| `pub(super)` | Parent module and its descendants |
| `pub(crate)` | Anywhere within the current crate |
| `pub(in path)` | Within the specified ancestor module |
| `pub` | Anyone who can access the containing module |

Everything is **private by default**. Items in a module can access all other items in the same module (even private ones), and child modules can access private items of their ancestors.

```rust
pub mod api {
    // Public — visible to crate consumers
    pub fn public_function() {
        internal_helper();  // Can call private items in same module
    }

    // Private — only visible within api module and descendants
    fn internal_helper() {}

    // Visible to parent module (and its descendants) but not outside the crate
    pub(super) fn parent_visible() {}

    // Visible anywhere within this crate but not to external consumers
    pub(crate) fn crate_internal() {}

    pub mod nested {
        // Visible only within crate::api and its children
        pub(in crate::api) fn scoped_to_api() {}

        pub fn uses_parent() {
            super::internal_helper();  // Child can access parent's private items
        }
    }
}
```

Struct fields have **independent visibility** from the struct itself. A `pub struct` can have private fields, which means external code cannot construct it directly — it must use a constructor function:

```rust
pub struct Config {
    pub name: String,           // Public field
    max_retries: u32,           // Private field — external code can't set this
    pub(crate) timeout_ms: u64, // Crate-internal field
}

impl Config {
    // Constructor required because max_retries is private
    pub fn new(name: String) -> Self {
        Config {
            name,
            max_retries: 3,
            timeout_ms: 5000,
        }
    }
}
```

Enum variants, however, **inherit the visibility of the enum**. If the enum is `pub`, all its variants and their fields are `pub`. This asymmetry is deliberate: struct fields are implementation details that may change; enum variants are part of the type's definition and must be matchable.

`pub(crate)` is the "sweet spot" for internal APIs — it allows multiple modules within a crate to share functionality without exposing it to crate consumers. It is Rust's closest equivalent to Java's package-private access.

Re-exporting with `pub use` is the primary mechanism for API surface management:

```rust
// Internal structure can be deep and complex
mod internal {
    pub mod parser { pub struct Ast { /* ... */ } }
    pub mod eval { pub fn evaluate(ast: &parser::Ast) -> i32 { 0 } }
}

// Public API is flat and curated
pub use internal::parser::Ast;
pub use internal::eval::evaluate;
```

> **Sources:** Klabnik & Nichols (2023) Ch.7 pp. 126–133 · [Rust Reference — Visibility and Privacy](https://doc.rust-lang.org/reference/visibility-and-privacy.html) · [Rust By Example — Visibility](https://doc.rust-lang.org/rust-by-example/mod/visibility.html) · [Cargo Book — Cargo Targets](https://doc.rust-lang.org/cargo/reference/cargo-targets.html)

### Java: Access Modifiers and Module Boundaries

Java has four access levels for class members, enforced at compile time and by the JVM at runtime:

| Modifier | Same Class | Same Package | Subclass (different package) | Other Classes |
|----------|:---------:|:------------:|:---------------------------:|:------------:|
| `private` | Y | N | N | N |
| *(none)* — package-private | Y | Y | N | N |
| `protected` | Y | Y | Y | N |
| `public` | Y | Y | Y | Y |

For top-level classes, only two levels are available: `public` (visible everywhere) and package-private (visible only within the package).

```java
package com.example.library;

public class Library {
    private int secretField;               // Same class only
    int packageField;                      // Same package only (package-private)
    protected int subclassField;           // Same package + subclasses
    public int publicField;                // Everywhere

    private void secretMethod() {}
    void packageMethod() {}
    protected void subclassMethod() {}
    public void publicMethod() {}
}
```

Bloch's Item 15 states the fundamental rule: **"make each class or member as inaccessible as possible."** The reasoning: every public API element becomes a commitment. Once published, it is extremely difficult to change without breaking clients. Bloch's Item 16 extends this: **in public classes, use accessor methods, not public fields** — exposing fields directly prevents future changes to the internal representation.

With JPMS (Java 9+), a new layer of access control exists. The `module-info.java` `exports` directive controls which packages are visible to other modules. A `public` class in a non-exported package is effectively **module-private**:

```java
// module-info.java
module com.example.library {
    exports com.example.library.api;       // Visible to other modules
    // com.example.library.internal is NOT exported — module-private
}
```

```java
// In com.example.library.api — accessible from other modules
package com.example.library.api;
public class PublicApi { /* ... */ }

// In com.example.library.internal — NOT accessible from other modules
// even though the class is public
package com.example.library.internal;
public class InternalHelper { /* ... */ }
```

This creates a two-tier access control: member-level modifiers within packages, and module-level `exports` across module boundaries. The `opens` directive provides a separate pathway for reflective access (required by frameworks like Spring, Hibernate, and Jackson).

Bloch's Item 24 recommends **favoring static member classes over nonstatic** — a nonstatic member class holds an implicit reference to its enclosing instance, which wastes memory and can prevent garbage collection. Static member classes are effectively just classes scoped to their enclosing class's namespace.

> **Sources:** Bloch (2018) Ch.4 Item 15 pp. 73–77, Item 16 pp. 78–79, Item 24 pp. 112–114 · [JLS 6.6 — Access Control](https://docs.oracle.com/javase/specs/jls/se21/html/jls-6.html#jls-6.6) · [Oracle Java Tutorial — Controlling Access to Members of a Class](https://docs.oracle.com/javase/tutorial/java/javaOO/accesscontrol.html) · [Baeldung — Access Modifiers in Java](https://www.baeldung.com/java-access-modifiers)

### Python: Convention-Based Privacy and Name Mangling

Python has **no enforced access control** — the philosophy is "we are all consenting adults." Conventions signal intent:

| Convention | Meaning | Enforcement |
|-----------|---------|-------------|
| `name` | Public | None — fully accessible |
| `_name` | Private by convention | Not imported by `from module import *`; tools may warn |
| `__name` | Name mangling | Rewritten to `_ClassName__name` by interpreter |
| `__name__` | Dunder / magic method | Reserved for the language; not for user privacy |

```python
class Account:
    def __init__(self, owner: str, balance: float):
        self.owner = owner          # Public
        self._balance = balance     # Private by convention
        self.__id = id(self)        # Name-mangled to _Account__id

    def deposit(self, amount: float) -> None:
        self._balance += amount     # Internal use of _balance

    def _validate(self) -> bool:    # Internal method
        return self._balance >= 0

# External code:
acc = Account("Alice", 100.0)
print(acc.owner)         # Fine — public
print(acc._balance)      # Works but violates convention
print(acc._Account__id)  # Works — name mangling is not security
# print(acc.__id)        # AttributeError — mangled name not found
```

Name mangling (`__name`) is **not about security or privacy**. Its purpose is to prevent accidental name collisions in inheritance hierarchies. A parent class's `__update` and a child class's `__update` won't collide because they're mangled to `_Parent__update` and `_Child__update` respectively. Slatkin's Item 55 argues against using double-underscore attributes for privacy — it creates problems for subclassing and testing. Single underscore (`_name`) is sufficient.

Python's `__all__` list controls what `from module import *` exports — it serves as the closest analog to explicit API surface control:

```python
# mypackage/__init__.py
from .core import Engine, Config
from .utils import format_output

__all__ = ["Engine", "Config", "format_output"]
# Other names (internal modules, helper functions) won't be exported by import *
```

The `_name` convention also has a practical effect: names starting with underscore are **not imported** by `from module import *` even without `__all__`. This means `_name` has a soft enforcement mechanism, even though direct access (`module._name`) still works.

> **Sources:** Slatkin (2025) Ch.14 Item 119 pp. 588–592 · [Python docs — Private Variables](https://docs.python.org/3/tutorial/classes.html#private-variables) · [PEP 8 — Naming Conventions](https://peps.python.org/pep-0008/#naming-conventions) · [Real Python — Python's Property Attribute and Encapsulation](https://realpython.com/python-property/)

### Cross-Language Visibility Mapping

| Purpose | Rust | Java | Python |
|---------|------|------|--------|
| **Fully public** | `pub` | `public` (+ exported package) | Public name |
| **Crate/module internal** | `pub(crate)` | Package-private (within JPMS module) | `_name` convention |
| **Parent-visible** | `pub(super)` | `protected` (approximate) | No equivalent |
| **Strictly private** | Private (default) | `private` | `__name` (mangled, not enforced) |
| **API surface control** | `pub use` re-exports | JPMS `exports` directive | `__all__` in `__init__.py` |
| **Reflective access** | No reflection | JPMS `opens` directive | Everything accessible at runtime |
| **Enforcement** | Compile-time, absolute | Compile-time + JVM runtime | Convention only |

---

## 3. Code Organization Patterns

Beyond modules and visibility, every language has conventions for how to lay out a project on disk — where source code goes, how tests are organized, and how multi-component projects are structured. Rust's Cargo enforces a conventional layout. Java's Maven/Gradle establish a standard directory structure. Python has competing conventions (flat vs src layout) that are converging toward `pyproject.toml` standardization.

### Rust: Cargo Project Layout and Workspaces

Cargo enforces a conventional directory layout:

```
my-project/
├── Cargo.toml           # Package manifest
├── Cargo.lock           # Exact dependency versions (commit for binaries)
├── src/
│   ├── lib.rs           # Library crate root
│   ├── main.rs          # Default binary crate root
│   └── bin/
│       ├── tool.rs      # Additional binary: cargo run --bin tool
│       └── server/
│           └── main.rs  # Multi-file binary
├── tests/
│   └── integration.rs   # Integration tests (access public API only)
├── benches/
│   └── benchmark.rs     # Benchmarks (cargo bench)
└── examples/
    └── demo.rs          # Example programs (cargo run --example demo)
```

A package can have at most one library crate (`src/lib.rs`) and any number of binary crates (`src/main.rs`, `src/bin/*.rs`). The `[[bin]]` table in `Cargo.toml` configures additional binaries:

```toml
[[bin]]
name = "cool-tool"
path = "src/bin/tool.rs"
```

The five **target types** — library, binary, example, test, benchmark — each have common configuration fields: `name`, `path`, `test` (include in `cargo test`), `bench` (include in `cargo bench`), `doc` (include in docs), `harness` (use libtest), and `required-features`.

A **workspace** groups multiple crates under a shared `Cargo.lock` and `target/` directory. This is essential for large projects:

```toml
# Cargo.toml (workspace root — "virtual manifest")
[workspace]
members = ["core", "cli", "server"]
resolver = "3"

[workspace.package]
version = "0.1.0"
edition = "2024"
license = "MIT"

[workspace.dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
```

```toml
# core/Cargo.toml
[package]
name = "myproject-core"
version.workspace = true
edition.workspace = true

[dependencies]
serde.workspace = true
```

```toml
# cli/Cargo.toml
[package]
name = "myproject-cli"
version.workspace = true

[dependencies]
myproject-core = { path = "../core" }
tokio.workspace = true
```

Workspace members share `[workspace.package]` metadata (version, authors, license), `[workspace.dependencies]` (centralized dependency versions), and `[workspace.lints]` (shared lint configuration). When published, `path` dependencies automatically convert to `version` dependencies.

The `pub use` re-export pattern is critical for API design. Internal modules can have a deep hierarchy while `pub use` in `lib.rs` creates a flat, user-friendly surface:

```rust
// src/lib.rs
mod connection;
mod protocol;
mod error;

// Users see: mylib::Connection, mylib::Error, mylib::connect
pub use connection::Connection;
pub use error::Error;
pub use protocol::connect;
```

The Rust API Guidelines recommend re-exporting commonly used items at the crate root.

> **Sources:** Blandy & Orendorff (2017) Ch.8 pp. 175–191 · Klabnik & Nichols (2023) Ch.14 pp. 295–313 · [Cargo Book — Project Layout](https://doc.rust-lang.org/cargo/guide/project-layout.html) · [Cargo Book — Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html) · [Rust API Guidelines — Organization](https://rust-lang.github.io/api-guidelines/organization.html)

### Java: Standard Directory Layout and Multi-Module Projects

Java's standard directory structure is established by Maven and universally adopted:

```
my-project/
├── pom.xml                           # Maven project descriptor
├── src/
│   ├── main/
│   │   ├── java/                     # Application sources
│   │   │   └── com/example/app/
│   │   │       ├── Main.java
│   │   │       └── util/
│   │   │           └── Helper.java
│   │   └── resources/                # Non-code files (configs, templates)
│   │       └── application.properties
│   └── test/
│       ├── java/                     # Test sources
│       │   └── com/example/app/
│       │       └── MainTest.java
│       └── resources/                # Test resources
│           └── test-data.json
└── target/                           # Build output (generated)
```

This layout is not enforced by the language but by the build tool. Deviating from it causes significant friction — virtually every Java IDE, CI system, and tool assumes this structure.

For **multi-module Maven projects**, a parent POM coordinates child modules:

```xml
<!-- parent pom.xml -->
<project>
    <groupId>com.example</groupId>
    <artifactId>myproject-parent</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>

    <modules>
        <module>core</module>
        <module>cli</module>
        <module>server</module>
    </modules>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.example</groupId>
                <artifactId>myproject-core</artifactId>
                <version>${project.version}</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

```xml
<!-- core/pom.xml -->
<project>
    <parent>
        <groupId>com.example</groupId>
        <artifactId>myproject-parent</artifactId>
        <version>1.0.0</version>
    </parent>
    <artifactId>myproject-core</artifactId>
</project>
```

Gradle provides the same multi-module structure with a more concise DSL. `settings.gradle.kts` lists modules and `build.gradle.kts` defines dependencies:

```kotlin
// settings.gradle.kts
rootProject.name = "myproject"
include("core", "cli", "server")

// cli/build.gradle.kts
dependencies {
    implementation(project(":core"))
}
```

With JPMS, each module also includes a `module-info.java` at its source root:

```java
// core/src/main/java/module-info.java
module com.example.core {
    exports com.example.core.api;
    // com.example.core.internal is not exported
}

// cli/src/main/java/module-info.java
module com.example.cli {
    requires com.example.core;
}
```

Multi-release JARs (`META-INF/versions/N/`) allow a single JAR to contain version-specific classes for different Java runtimes — enabling library authors to use new Java features while maintaining backward compatibility.

> **Sources:** Horstmann (2024) Ch.4 §4.9 pp. 64 · Evans et al (2022) Ch.2 pp. 40–54 · [Maven — Standard Directory Layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html) · [Baeldung — A Guide to Java 9 Modularity](https://www.baeldung.com/java-9-modularity) · [Jigsaw Quick-Start Guide](https://openjdk.org/projects/jigsaw/quick-start)

### Python: Package Layouts and `__init__.py` Patterns

Python has two dominant layout conventions:

**Flat layout** — package directory at project root:
```
myproject/
├── pyproject.toml
├── mypackage/
│   ├── __init__.py
│   ├── core.py
│   ├── utils.py
│   └── cli/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── test_core.py
│   └── test_utils.py
└── README.md
```

**Src layout** — package under `src/` (increasingly recommended):
```
myproject/
├── pyproject.toml
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── core.py
│       └── utils.py
├── tests/
│   ├── test_core.py
│   └── test_utils.py
└── README.md
```

The `src` layout is preferred because it **prevents accidental imports** from the project root during development. Without it, running tests from the project root can import the local directory copy instead of the installed package, masking packaging bugs.

`__init__.py` serves multiple roles: it marks a directory as a package, executes initialization code, and defines the package's public API:

```python
# mypackage/__init__.py
"""MyPackage — a demonstration library."""

# Re-export the public API from internal modules
from .core import Engine, Config
from .utils import format_output

# This controls "from mypackage import *"
__all__ = ["Engine", "Config", "format_output"]

# Package-level initialization
_default_config = Config()
```

For Python monorepos with multiple packages, modern tools support workspace configurations. With `uv`:

```toml
# pyproject.toml (workspace root)
[tool.uv.workspace]
members = ["packages/*"]
```

With individual packages using editable installs:

```bash
pip install -e ./core
pip install -e ./cli   # cli can import from core
```

Circular dependencies are a structural problem in Python. Slatkin's Item 122 offers three solutions:
1. **Restructure** — move shared code to a third module both can import
2. **Deferred imports** — import inside functions instead of at module level
3. **Late binding** — use `importlib.import_module()` at the point of use

> **Sources:** Slatkin (2025) Ch.14 Item 119 pp. 588–592, Item 122 pp. 600–604 · [Python Packaging User Guide — Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/) · [Python docs — Regular Packages](https://docs.python.org/3/reference/import.html#regular-packages) · [Real Python — Python Application Layouts](https://realpython.com/python-application-layouts/)

### Cross-Language Project Structure Comparison

| Concept | Rust | Java | Python |
|---------|------|------|--------|
| **Project manifest** | `Cargo.toml` | `pom.xml` / `build.gradle.kts` | `pyproject.toml` |
| **Source location** | `src/` | `src/main/java/` | `src/mypackage/` or `mypackage/` |
| **Test location** | `tests/` (integration), inline `#[test]` (unit) | `src/test/java/` | `tests/` |
| **Multi-project** | Workspace (`[workspace]`) | Parent POM / `settings.gradle.kts` | Workspace tools (uv, poetry) |
| **Internal dep** | `path = "../core"` | `<module>core</module>` | `pip install -e ./core` |
| **API facade** | `pub use` in `lib.rs` | Facade packages / JPMS exports | `__init__.py` re-exports |
| **Lock file** | `Cargo.lock` | None natively (plugins) / Gradle lock | `poetry.lock` / `uv.lock` |

---

## 4. Dependency Management

External dependencies are essential to modern software — no project exists in isolation. Each ecosystem has evolved its own approach to declaring, resolving, and locking dependencies. Cargo uses semver-aware resolution with a lockfile. Maven uses nearest-wins mediation. Gradle uses highest-compatible-wins. Python's tooling has historically been fragmented but is converging around `pyproject.toml` with modern tools like uv and poetry.

### Rust: Cargo Dependency Management

Cargo uses **semantic versioning** by default. A version requirement `"1.2.3"` means `>=1.2.3, <2.0.0` (the default "caret" requirement — compatible versions per semver):

```toml
[dependencies]
serde = "1.0"                          # >=1.0.0, <2.0.0
serde_json = "~1.0.96"                 # >=1.0.96, <1.1.0 (tilde)
regex = "1.9.*"                        # >=1.9.0, <1.10.0 (wildcard)
log = ">=0.4, <0.5"                    # Explicit range

# Dependencies from other sources
my-lib = { path = "../my-lib" }        # Local path
git-dep = { git = "https://github.com/user/repo.git", branch = "main" }

# Optional dependencies and features
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"], optional = true }

# Platform-specific dependencies
[target.'cfg(windows)'.dependencies]
winapi = "0.3"
```

The **resolver** produces a `Cargo.lock` that pins exact versions for reproducible builds. Libraries should not check in `Cargo.lock` (to allow downstream consumers to resolve freely); binaries should check it in for reproducibility.

Dependency resolution heuristics:
- **Prefers highest available version** matching requirements
- **SemVer unification** — if two crates require `serde "1.0"` and `serde "1.2"`, Cargo resolves to a single version satisfying both (e.g., `1.2.5`)
- **Multiple semver-incompatible versions** — if crates require `serde 1.x` and `serde 2.x`, Cargo includes both, linked as separate crates with different symbols
- **Lockfile priority** — once locked, versions are preserved until `cargo update`

```bash
cargo update              # Update all dependencies within semver ranges
cargo update serde        # Update only serde
cargo build --locked      # Fail if Cargo.lock would change
```

Dependency **sections** control when dependencies are available:

```toml
[dependencies]              # Available in library/binary code
[dev-dependencies]          # Test and benchmark code only
[build-dependencies]        # Build scripts (build.rs) only
```

The `[patch]` table overrides a dependency's source globally across the dependency graph — useful for testing local fixes:

```toml
[patch.crates-io]
serde = { path = "../serde" }  # Use local copy instead of crates.io
```

Feature flags enable compile-time optional dependencies:

```toml
[features]
default = ["json"]
json = ["dep:serde_json"]    # Enables serde_json as optional dependency
full = ["json", "logging"]
logging = ["dep:tracing"]
```

> **Sources:** Matthews (2024) Ch.2 pp. 20–32 · [Cargo Book — Specifying Dependencies](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html) · [Cargo Book — Dependency Resolution](https://doc.rust-lang.org/cargo/reference/resolver.html) · [Cargo Book — Cargo.toml vs Cargo.lock](https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html)

### Java: Maven and Gradle Dependency Management

Maven declares dependencies in `pom.xml` with coordinates: `groupId`, `artifactId`, `version`, and `scope`:

```xml
<dependencies>
    <dependency>
        <groupId>com.google.guava</groupId>
        <artifactId>guava</artifactId>
        <version>33.0.0-jre</version>
    </dependency>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.1</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

Maven's dependency **scopes** control classpath inclusion:

| Scope | Compile | Runtime | Test | Transitive? |
|-------|:-------:|:-------:|:----:|:-----------:|
| `compile` (default) | Y | Y | Y | Yes |
| `provided` | Y | N | Y | No |
| `runtime` | N | Y | Y | Yes |
| `test` | N | N | Y | No |
| `system` | Y | Y | N | No |
| `import` | N/A — imports BOM | N/A | N/A | No |

Maven's resolution uses the **"nearest definition"** strategy — the version closest to the project root in the dependency tree wins. If equidistant, first declaration order wins:

```
MyProject
├── A 1.0
│   └── C 2.0    ← depth 2
└── B 1.0
    └── C 1.0    ← depth 2, but declared after A

Result: C 2.0 wins (same depth, A declared first)
```

**Dependency Management** centralizes version control, especially useful with BOMs (Bill of Materials):

```xml
<dependencyManagement>
    <dependencies>
        <!-- Import Spring Boot BOM -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>3.2.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <!-- No version needed — inherited from BOM -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

Gradle uses a Groovy or Kotlin DSL with configurations instead of scopes:

```kotlin
dependencies {
    implementation("com.google.guava:guava:33.0.0-jre")  // Compile + runtime
    api("org.apache.commons:commons-lang3:3.14.0")        // Exposed to consumers
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.1")
    runtimeOnly("org.postgresql:postgresql:42.7.1")
}
```

Gradle's resolution is more sophisticated: it picks the **highest compatible version** by default and supports strict versions, rich version declarations, and dependency locking.

A critical difference from Cargo: **neither Maven nor Gradle can include two incompatible versions of the same library** — only one version wins, which can cause binary compatibility problems at runtime.

> **Sources:** [Maven — Introduction to the Dependency Mechanism](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html) · [Baeldung — Maven vs Gradle](https://www.baeldung.com/ant-maven-gradle)

### Python: pip, uv, poetry, and the Packaging Ecosystem

Python's dependency management has historically been fragmented. `pyproject.toml` (PEP 621) is now the standard for declaring project metadata and dependencies:

```toml
[project]
name = "mypackage"
version = "1.0.0"
description = "A demonstration package"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.28.0",
    "click>=8.0",
]

[project.optional-dependencies]
dev = ["pytest>=7.0", "black", "mypy"]
docs = ["sphinx>=5.0", "sphinx-rtd-theme"]

[project.scripts]
my-cli = "mypackage.cli:main"
```

Dependency specifiers use **PEP 440** syntax:

| Specifier | Meaning |
|-----------|---------|
| `>=1.0,<2.0` | Range |
| `~=1.4` | Compatible release (`>=1.4, <2.0`) |
| `==1.4.*` | Prefix matching |
| `!=1.5.0` | Exclusion |

**Platform markers** enable conditional dependencies:

```toml
dependencies = [
    "pywin32; sys_platform == 'win32'",
    "uvloop>=0.17; sys_platform != 'win32'",
]
```

**pip** is the standard installer but does **not** guarantee reproducible resolution (no lockfile). Modern tools fill this gap:

**uv** (Astral, written in Rust) — 10–100x faster than pip:
- Universal lockfile (`uv.lock`)
- Workspace support for monorepos
- Python version management
- `pip`-compatible interface

**poetry** — dependency management with automatic lockfile:
- `poetry.lock` with SAT-solver-based resolver
- Environment isolation as a core feature
- Packaging and distribution capabilities

**Virtual environments** isolate project dependencies. Unlike Cargo (where isolation is structural — each project has its own `target/`) or Maven (per-project local repository), Python requires explicit environment creation:

```bash
python -m venv .venv          # Standard library
uv venv                       # Much faster
source .venv/bin/activate     # Activate the environment
```

> **Sources:** Slatkin (2025) Ch.14 Item 116 pp. 575, Item 117 pp. 576–581 · Viafore (2021) Ch.16 pp. 225–241 · [PEP 621 — Project metadata in pyproject.toml](https://peps.python.org/pep-0621/) · [uv documentation](https://docs.astral.sh/uv/) · [Poetry documentation](https://python-poetry.org/docs/) · [Python Packaging User Guide](https://packaging.python.org/)

### Cross-Language Dependency Management Comparison

| Aspect | Rust (Cargo) | Java (Maven/Gradle) | Python (pip/uv/poetry) |
|--------|-------------|--------------------|-----------------------|
| **Manifest** | `Cargo.toml` | `pom.xml` / `build.gradle.kts` | `pyproject.toml` |
| **Resolution strategy** | Highest compatible per semver | Nearest-wins (Maven) / Highest (Gradle) | First-found (pip) / SAT solver (uv/poetry) |
| **Lockfile** | `Cargo.lock` (built-in) | None native (Maven) / Optional (Gradle) | `uv.lock` / `poetry.lock` |
| **Multiple versions** | Yes (different semver-major) | No — one version wins | No — one version wins |
| **Repository** | crates.io (immutable) | Maven Central (immutable) | PyPI (mutable metadata) |
| **Version syntax** | `"1.2.3"` = `>=1.2.3, <2.0.0` | Exact version (ranges via syntax) | PEP 440 specifiers |
| **Isolation** | Structural (per-project `target/`) | Structural (per-project classpath) | Virtual environments (explicit) |
| **Feature flags** | `[features]` in Cargo.toml | Maven profiles / Gradle variants | `[project.optional-dependencies]` |

---

## 5. Java Platform Module System (JPMS) Deep Dive

JPMS (Project Jigsaw, Java 9) is the most complex module system among the three languages. It introduces a new compilation and runtime entity — the module — that provides both dependency declaration and visibility control in a single mechanism. The motivation was to fix "JAR hell" — the pre-Java-9 classpath model where all public classes were globally visible and there was no reliable way to declare or enforce dependencies between JARs.

### JPMS Fundamentals: `module-info.java` and the Module Graph

A module is declared in `module-info.java` at the source root with four categories of directives:

```java
module com.example.app {
    // Dependencies
    requires java.sql;                          // Compile-time and runtime dependency
    requires transitive java.logging;           // Re-exported to consumers
    requires static java.management;            // Optional at runtime (compile-time only)

    // Visibility
    exports com.example.app.api;                // Package visible to all modules
    exports com.example.app.spi to              // Qualified export — only named modules
        com.example.plugin.core,
        com.example.plugin.ext;

    // Reflective access
    opens com.example.app.model;                // Open to all for reflection
    opens com.example.app.internal to           // Qualified open
        com.fasterxml.jackson.databind;

    // Service loading
    uses com.example.app.spi.Plugin;            // This module consumes Plugin service
    provides com.example.app.spi.Plugin with    // This module provides implementations
        com.example.app.plugins.DefaultPlugin,
        com.example.app.plugins.AdvancedPlugin;
}
```

The **module graph** is a directed acyclic graph where edges represent `requires` relationships. `java.base` is the root module — every module implicitly requires it (like Rust's standard prelude). Strong encapsulation means that even `public` classes in non-exported packages are **inaccessible** from other modules.

Key directive semantics:

- **`requires`** — declares a dependency, checked at both compile time and runtime. Without it, the module's code cannot reference any type from the required module's exported packages.
- **`requires transitive`** — if module A `requires transitive` B, then any module that `requires` A also implicitly `requires` B. This is essential when your public API uses types from the transitive dependency.
- **`requires static`** — compile-time-only dependency. The module may or may not be present at runtime (useful for optional annotations like `@Nullable`).
- **`exports`** — makes a package accessible to other modules. Only `public` and `protected` types in exported packages are visible.
- **`exports ... to`** — qualified export: restricts visibility to named modules only. This enables internal APIs shared between cooperating modules.
- **`opens`** — makes a package available for deep reflection (`setAccessible(true)`). Required by frameworks like Spring, Hibernate, and Jackson that use reflection to access private fields.
- **`opens ... to`** — qualified open: reflection access restricted to named modules.
- **`uses`/`provides ... with`** — integrates with `ServiceLoader` for runtime service discovery. Replaces the fragile `META-INF/services/` mechanism.

An **open module** (`open module ...`) opens all its packages for reflection while still controlling compile-time access with `exports`:

```java
open module com.example.model {
    exports com.example.model.api;
    // All packages are open for reflection, but only api is exported for compile-time use
}
```

**Split packages** — two modules contributing classes to the same package — are **forbidden**. This is a deliberate constraint that prevents the chaos of pre-JPMS classpath conflicts where multiple JARs could contribute classes to the same package.

> **Sources:** Horstmann (2024) Ch.12 pp. 150–166 · Evans et al (2022) Ch.2 pp. 26–54 · [JEP 261 — Module System](https://openjdk.org/jeps/261) · [JLS Ch.7 — Packages and Modules](https://docs.oracle.com/javase/specs/jls/se21/html/jls-7.html) · [Jigsaw Quick-Start Guide](https://openjdk.org/projects/jigsaw/quick-start) · [Baeldung — A Guide to Java 9 Modularity](https://www.baeldung.com/java-9-modularity)

### JPMS Migration: Unnamed Modules, Automatic Modules, and jlink

Migration from the classpath to the module path involves three module types:

| Type | Source | Has `module-info.java`? | Exports | Access |
|------|--------|:-----------------------:|---------|--------|
| **Explicit module** | Module path | Yes | Only declared packages | Strong encapsulation |
| **Automatic module** | Module path | No | All packages | Reads all modules |
| **Unnamed module** | Classpath | No | All packages | Reads all modules |

The migration path is: **unnamed → automatic → explicit**.

- **Unnamed module** — all JARs on the classpath belong to a single unnamed module that exports everything and can require all named modules. This preserves backward compatibility: existing code works without changes.
- **Automatic modules** — JARs placed on the module path without `module-info.java` get a module name derived from the JAR filename or `Automatic-Module-Name` manifest attribute. They export all packages and can read all other modules.
- **Explicit modules** — JARs with `module-info.java`. Full strong encapsulation.

`jdeps` analyzes dependencies and suggests `module-info.java` content:

```bash
jdeps --generate-module-info out/ mylib.jar
```

`jlink` creates custom runtime images containing only the required modules — reducing Docker image sizes dramatically:

```bash
jlink --module-path $JAVA_HOME/jmods:mods \
      --add-modules com.example.app \
      --output custom-runtime
# Result: minimal JRE with only needed modules (~30MB instead of ~300MB)
```

Performance implications of JPMS: stronger encapsulation enables more aggressive JIT inlining; custom runtimes reduce startup time and memory footprint. **Jigsaw layers** enable running multiple module configurations in the same JVM — useful for plugin systems.

Command-line flags for migration:

```bash
# Add exports at runtime (escape hatch)
--add-exports java.base/sun.nio.ch=ALL-UNNAMED

# Add opens at runtime (for reflection)
--add-opens java.base/java.lang=ALL-UNNAMED

# Add reads relationship
--add-reads com.example.app=com.example.plugin
```

> **Sources:** Beckwith (2024) Ch.3 pp. 69–97 · Evans et al (2022) Ch.2 pp. 40–54 · [JEP 261 — Module System](https://openjdk.org/jeps/261)

### JPMS vs Rust Modules vs Python Packages

| Aspect | JPMS | Rust Modules/Crates | Python Packages |
|--------|------|-------------------|-----------------|
| **Declaration** | `module-info.java` | `Cargo.toml` + `mod` in source | `__init__.py` + `pyproject.toml` |
| **Dependency + visibility** | Combined in `module-info.java` | Separated: `Cargo.toml` (deps) + `pub` (visibility) | Separated: `pyproject.toml` (deps) + conventions (visibility) |
| **Granularity** | Package-level exports | Item-level `pub` | Module-level `__all__` |
| **Enforcement** | Compile-time + runtime | Compile-time | Convention only |
| **Service loading** | `uses`/`provides` (built-in) | Trait objects / feature flags | Entry points in `pyproject.toml` |
| **Migration story** | Unnamed → automatic → explicit | N/A (designed from scratch) | N/A (evolved incrementally) |
| **Custom runtime** | `jlink` (minimal JRE) | Static linking | Bundlers (PyInstaller, Nuitka) |

---

## 6. Conditional Compilation, Feature Flags, and API Surface Management

Not all code should be included in every build. Platform-specific code, optional features, and test-only utilities all need mechanisms for conditional inclusion. Rust has a first-class compile-time system (`#[cfg]` and Cargo features). Java has no language-level conditional compilation, relying instead on build-tool profiles and runtime checks. Python does everything at runtime. Each approach reflects the language's philosophy about when decisions should be made.

### Rust: `#[cfg]`, Cargo Features, and Conditional Compilation

Rust's conditional compilation system operates at compile time — code that doesn't match is completely removed from the binary.

**Three forms of conditional compilation:**

1. **`#[cfg(...)]` attribute** — removes the annotated item entirely:

```rust
#[cfg(target_os = "linux")]
fn platform_specific() {
    println!("Linux-only code");
}

#[cfg(not(target_os = "linux"))]
fn platform_specific() {
    println!("Non-Linux fallback");
}

// Compound conditions
#[cfg(all(unix, target_pointer_width = "64"))]
fn unix_64bit_only() {}

#[cfg(any(target_os = "macos", target_os = "ios"))]
fn apple_only() {}
```

2. **`#[cfg_attr(...)]`** — conditionally applies other attributes:

```rust
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct Config {
    pub name: String,
}
```

3. **`cfg!()` macro** — evaluates to `bool` at compile time for use in expressions:

```rust
fn main() {
    let platform = if cfg!(unix) { "unix" } else { "other" };
    println!("Running on {}", platform);
}
```

Note: with `cfg!()`, all branches must be syntactically valid because code is not removed — only the condition is evaluated.

**Compiler-set configuration options** include:

| Option | Examples |
|--------|---------|
| `target_os` | `"linux"`, `"windows"`, `"macos"` |
| `target_arch` | `"x86_64"`, `"aarch64"`, `"arm"` |
| `target_family` | `"unix"`, `"windows"`, `"wasm"` |
| `target_env` | `"gnu"`, `"msvc"`, `"musl"` |
| `target_pointer_width` | `"32"`, `"64"` |
| `target_feature` | `"avx2"`, `"sse2"` |
| `test` | Set when running `cargo test` |
| `debug_assertions` | Set in debug builds |

**Cargo features** define named flags for compile-time optional functionality:

```toml
[features]
default = ["json"]
json = ["dep:serde_json"]      # Enables optional dependency
full = ["json", "logging"]
logging = ["dep:tracing"]

[dependencies]
serde_json = { version = "1", optional = true }
tracing = { version = "0.1", optional = true }
```

```rust
// Use in code
#[cfg(feature = "json")]
pub mod json {
    pub fn parse(input: &str) -> serde_json::Value {
        serde_json::from_str(input).unwrap()
    }
}

#[cfg(feature = "logging")]
pub fn init_logging() {
    tracing_subscriber::init();
}
```

Feature flags are **additive** — enabling a feature never removes functionality. This is a semver invariant: any combination of features must compile. **Feature unification** means all features requested across the dependency graph are combined into a single set. The `dep:` prefix (Rust 1.60+) prevents optional dependencies from implicitly creating features.

Build scripts (`build.rs`) can set custom `cfg` values:

```rust
// build.rs
fn main() {
    if std::env::var("SOME_LIB").is_ok() {
        println!("cargo::rustc-cfg=has_some_lib");
    }
}

// In source code
#[cfg(has_some_lib)]
mod some_lib_integration { /* ... */ }
```

> **Sources:** Gjengset (2022) Ch.5 pp. 67–78 · Matthews (2024) Ch.2 pp. 26–30 · [Rust Reference — Conditional Compilation](https://doc.rust-lang.org/reference/conditional-compilation.html) · [Cargo Book — Features](https://doc.rust-lang.org/cargo/reference/features.html) · [Cargo Book — Build Scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html) · [Rust By Example — cfg](https://doc.rust-lang.org/rust-by-example/attribute/cfg.html)

### Java: Build Profiles, Annotation Processing, and Runtime Checks

Java has **no language-level conditional compilation** (no preprocessor, no `#ifdef`). Conditional behavior is achieved through build tools and runtime mechanisms:

**1. Maven profiles** — select different configurations based on activation criteria:

```xml
<profiles>
    <profile>
        <id>dev</id>
        <properties>
            <db.url>jdbc:h2:mem:dev</db.url>
        </properties>
    </profile>
    <profile>
        <id>prod</id>
        <activation>
            <property>
                <name>env</name>
                <value>production</value>
            </property>
        </activation>
        <properties>
            <db.url>jdbc:postgresql://prod-server/mydb</db.url>
        </properties>
    </profile>
</profiles>
```

```bash
mvn package -Pdev          # Activate dev profile
mvn package -Denv=production  # Activate prod profile via property
```

**Gradle build variants** provide similar functionality:

```kotlin
// build.gradle.kts
sourceSets {
    create("integration") {
        java.srcDir("src/integration/java")
        compileClasspath += sourceSets["main"].output
    }
}
```

**2. Runtime checks** — the JIT compiler optimizes away dead code paths effectively:

```java
public class PlatformUtils {
    private static final String OS = System.getProperty("os.name").toLowerCase();

    public static boolean isWindows() { return OS.contains("win"); }
    public static boolean isLinux() { return OS.contains("nux"); }
    public static boolean isMac() { return OS.contains("mac"); }
}
```

**3. ServiceLoader** — runtime discovery of implementations:

```java
// Service interface
public interface Plugin {
    String name();
    void execute();
}

// module-info.java
module com.example.app {
    uses com.example.spi.Plugin;
}

// Loading at runtime
ServiceLoader<Plugin> plugins = ServiceLoader.load(Plugin.class);
for (Plugin p : plugins) {
    p.execute();
}
```

**4. Multi-release JARs** — version-specific class overrides:

```
META-INF/
    versions/
        17/
            com/example/util/RecordHelper.class   # Uses Java 17 records
        21/
            com/example/util/RecordHelper.class   # Uses Java 21 patterns
com/example/util/RecordHelper.class               # Fallback (Java 11+)
```

Java's approach differs fundamentally from Rust's: instead of compile-time code elimination, Java relies on the JIT compiler to optimize away unreachable branches at runtime, which it does very effectively.

> **Sources:** [Baeldung — Maven Profiles](https://www.baeldung.com/maven-profiles) · [Baeldung — Maven vs Gradle](https://www.baeldung.com/ant-maven-gradle)

### Python: Runtime Conditional Imports and API Surface Control

Python has **no compile-time conditional compilation** — everything happens at runtime.

**1. `try/except ImportError`** — optional dependencies:

```python
try:
    import ujson as json  # Faster JSON library
except ImportError:
    import json           # Fallback to stdlib

try:
    from functools import cache  # Python 3.9+
except ImportError:
    from functools import lru_cache
    cache = lru_cache(maxsize=None)
```

**2. `sys.platform` and `platform` module** — OS detection at runtime:

```python
import sys
import platform

if sys.platform == "win32":
    import winreg
elif sys.platform == "darwin":
    # macOS-specific code
    pass
elif sys.platform == "linux":
    # Linux-specific code
    pass

# More detailed information
print(platform.system())              # 'Linux', 'Darwin', 'Windows'
print(platform.machine())             # 'x86_64', 'arm64'
print(platform.python_version())      # '3.12.1'
print(platform.python_implementation())  # 'CPython', 'PyPy'
```

**3. `typing.TYPE_CHECKING`** — code that runs only during static analysis:

```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    # These imports exist only for type checkers, never at runtime
    # This avoids circular imports in type annotations
    from .heavy_module import HeavyClass

def process(item: "HeavyClass") -> None:
    pass
```

**4. `__all__` for API surface management:**

```python
# mypackage/__init__.py
from .core import Engine, Config
from .utils import format_output, validate_input
from ._internal import _setup_logging  # Internal, not in __all__

__all__ = [
    "Engine",
    "Config",
    "format_output",
    "validate_input",
]
# _setup_logging is accessible but won't be exported by "from mypackage import *"
```

**5. Optional dependency groups** in `pyproject.toml`:

```toml
[project.optional-dependencies]
fast = ["ujson>=5.0", "uvloop>=0.17"]
dev = ["pytest>=7.0", "mypy>=1.0"]

# Platform-conditional dependencies
[project]
dependencies = [
    "pywin32>=300; sys_platform == 'win32'",
    "uvloop>=0.17; sys_platform != 'win32'",
]
```

**6. Module-scoped deployment configuration** — Slatkin's Item 120:

```python
# config.py — module-level code configures the environment
import sys

if sys.platform == "win32":
    DB_HOST = "windows-server"
else:
    DB_HOST = "linux-server"

PRODUCTION = "--production" in sys.argv
DEBUG = not PRODUCTION
```

> **Sources:** Slatkin (2025) Ch.14 Item 119 pp. 588–592, Item 120 pp. 593–594 · [Python docs — sys.platform](https://docs.python.org/3/library/sys.html#sys.platform) · [Python docs — platform module](https://docs.python.org/3/library/platform.html)

### API Surface Management Comparison

| Mechanism | Rust | Java | Python |
|-----------|------|------|--------|
| **Re-exports** | `pub use` in `lib.rs` | JPMS `exports` (package-level) | `__init__.py` imports + `__all__` |
| **Hide from docs** | `#[doc(hidden)]` | `@hidden` (Javadoc, Java 15+) | Leading `_` by convention |
| **Feature flags** | Cargo `[features]` (compile-time) | Maven profiles (build-time) | `[project.optional-dependencies]` (install-time) |
| **Platform code** | `#[cfg(target_os = "...")]` | `System.getProperty("os.name")` | `sys.platform` / `platform.system()` |
| **Granularity** | Per-item | Per-package (JPMS) | Per-module |
| **When decided** | Compile time | Build time (profiles) / Runtime (checks) | Runtime |

---

## 7. Semantic Versioning and API Compatibility

How do you evolve a library without breaking consumers? Each ecosystem has developed mechanisms for versioning and compatibility — from Rust's strict semver enforcement to Java's binary compatibility rules to Python's deprecation workflows. The fundamental tension is between evolution (changing the API) and stability (not breaking existing users).

### Rust: Semver Enforcement and API Compatibility

Cargo treats semantic versioning as a **first-class concept**. Version requirements in `Cargo.toml` are interpreted according to semver rules — `"1.2.3"` means `>=1.2.3, <2.0.0`.

The Cargo Book documents an extensive list of what constitutes a breaking change:

**Breaking changes (major version bump required):**
- Removing or renaming a `pub` item
- Adding a required field to a public struct (if all fields were public)
- Adding an enum variant (without `#[non_exhaustive]`)
- Changing a function signature (parameters, return type)
- Removing a trait implementation
- Tightening generic bounds
- Removing a Cargo feature

**Compatible changes (minor version bump):**
- Adding new `pub` items
- Adding defaulted trait methods
- Loosening generic bounds
- Making `unsafe` functions safe
- Adding a Cargo feature

**Mitigation strategies:**

```rust
// #[non_exhaustive] allows adding variants/fields in future minor versions
#[non_exhaustive]
pub enum Error {
    NotFound,
    PermissionDenied,
    // Future versions can add variants without breaking matches
}

// Callers must include a wildcard arm:
match err {
    Error::NotFound => {},
    Error::PermissionDenied => {},
    _ => {},  // Required due to #[non_exhaustive]
}
```

```rust
// Constructor functions instead of struct literals prevent breakage
// when fields are added
pub struct Config {
    name: String,
    // Adding fields later won't break callers who use Config::new()
}

impl Config {
    pub fn new(name: String) -> Self {
        Config { name }
    }
}
```

**`cargo-semver-checks`** automates detection of semver violations by comparing the current API against a baseline:

```bash
cargo install cargo-semver-checks
cargo semver-checks check-release
```

**MSRV (Minimum Supported Rust Version)** policy declares the oldest compiler version a crate supports:

```toml
[package]
rust-version = "1.70"  # Verified by CI with cargo +1.70 check
```

Deprecation uses the `#[deprecated]` attribute:

```rust
#[deprecated(since = "0.5.0", note = "Use new_function() instead")]
pub fn old_function() {}
```

The combination of strict semver in Cargo + `pub` visibility control + `pub use` re-exports + `#[non_exhaustive]` creates a robust system where API surface changes are deliberate and versioned.

> **Sources:** Gjengset (2022) Ch.5 pp. 78–84 · [Cargo Book — SemVer Compatibility](https://doc.rust-lang.org/cargo/reference/semver.html) · [Rust API Guidelines — Necessities](https://rust-lang.github.io/api-guidelines/necessities.html) · [Semantic Versioning 2.0.0](https://semver.org/)

### Java: Binary Compatibility and Module Versioning

Java defines **binary compatibility** in JLS Chapter 13 — a detailed specification of which changes to a class or interface preserve compatibility with pre-existing binaries (compiled `.class` files) without recompilation.

Key binary compatibility rules:

| Change | Binary Compatible? | Notes |
|--------|:-----------------:|-------|
| Add method/constructor | Yes | Even if new overloads could cause compile errors |
| Remove public method | **No** | Throws `NoSuchMethodError` |
| Change method body | Yes | Implementation changes don't break binaries |
| Add field | Yes | Unless it shadows a superclass field |
| Make class `final` | **No** | Throws `IncompatibleClassChangeError` if subclassed |
| Make method `abstract` | **No** | Throws `AbstractMethodError` |
| Reduce access modifier | **No** | e.g., `public` → `protected` breaks binaries |
| Increase access modifier | Yes | Safe to make members more accessible |
| Add default method to interface | Yes | Binary compatible but may cause runtime `IncompatibleClassChangeError` if diamond problem arises |
| Add enum constant | Yes | May cause `MatchException` in exhaustive switches |
| Change `static` ↔ `instance` | **No** | Throws `IncompatibleClassChangeError` |

An important subtlety: **`static final` constants are inlined at compile time**:

```java
public static final int MAX_SIZE = 100;
// Value 100 is baked into every class that references MAX_SIZE
// Changing to 200 is binary compatible — but pre-compiled clients still see 100!
```

Recommendation: use accessor methods instead of public constants for values that may change.

JPMS does **not** include version information in module declarations — there is no equivalent of Cargo's semver-aware resolution. Version management is entirely delegated to build tools (Maven/Gradle).

Java's deprecation mechanism:

```java
@Deprecated(since = "17", forRemoval = true)
public void oldMethod() { /* ... */ }
```

The `forRemoval = true` flag signals that the method will be removed in a future release, not just that an alternative exists. `jdeprscan` scans code for uses of deprecated APIs.

Java's six-month release cadence with LTS releases (11, 17, 21, 25) creates a versioning rhythm where libraries must decide which Java versions to support — analogous to Rust's MSRV.

> **Sources:** Beckwith (2024) Ch.3 pp. 69–97 · [JLS Ch.13 — Binary Compatibility](https://docs.oracle.com/javase/specs/jls/se21/html/jls-13.html)

### Python: Versioning, Deprecation, and API Evolution

Python uses **PEP 440** for version identification:

```
Format: [N!]N(.N)*[{a|b|rc}N][.postN][.devN]

Examples:
1.0.0           # Final release
1.0.0a1         # Alpha
1.0.0b2         # Beta
1.0.0rc1        # Release candidate
1.0.0.post1     # Post-release (minor correction)
1.0.0.dev3      # Development release
2!1.0.0         # Epoch 2 (version reset)
```

Unlike Rust, Python does **not enforce semver at the package manager level** — pip/poetry/uv use PEP 440 specifiers for resolution but do not distinguish between major and minor bumps semantically. Whether a library follows semver is a social contract, not a tooling guarantee.

API deprecation follows a structured pattern using the `warnings` module:

```python
import warnings

def old_function():
    warnings.warn(
        "old_function() is deprecated, use new_function() instead",
        DeprecationWarning,
        stacklevel=2  # Points warning at the caller, not this function
    )
    return new_function()

def new_function():
    return "modern implementation"
```

Warning categories serve different audiences:
- **`DeprecationWarning`** — for developers using the library (ignored by default except in `__main__` and tests)
- **`FutureWarning`** — for end users (always shown)
- **`PendingDeprecationWarning`** — for future deprecation (ignored by default)

PEP 387 defines the **backwards compatibility policy** for CPython itself:
1. Discuss the proposed change publicly
2. Add `DeprecationWarning` to the main branch
3. Wait **at least 2 versions** (preferably 5 years) before removal
4. Gather community feedback
5. Remove after the deadline

**Soft deprecation** (newer approach) discourages API usage in documentation without warnings or removal timeline — balancing evolution with ecosystem stability.

Slatkin's Item 121 introduces the **root exception pattern** for API insulation:

```python
# mylib/exceptions.py
class MyLibError(Exception):
    """Base exception for mylib — callers can catch all library errors."""
    pass

class ConnectionError(MyLibError):
    pass

class ValidationError(MyLibError):
    pass

# Callers can catch MyLibError without knowing internal exception hierarchy
try:
    mylib.connect()
except mylib.MyLibError:
    # Catches any library error — insulated from internal refactoring
    pass
```

This pattern insulates the public API from internal exception hierarchy changes — adding, removing, or restructuring internal exceptions doesn't break callers who catch the base class.

> **Sources:** Slatkin (2025) Ch.14 Item 121 pp. 595–599, Item 123 pp. 605–612 · [PEP 440 — Version Identification](https://peps.python.org/pep-0440/) · [PEP 387 — Backwards Compatibility Policy](https://peps.python.org/pep-0387/) · [Python docs — warnings module](https://docs.python.org/3/library/warnings.html)

### Cross-Language Versioning and Compatibility Comparison

| Aspect | Rust | Java | Python |
|--------|------|------|--------|
| **Version format** | SemVer (MAJOR.MINOR.PATCH) | No standard (usually SemVer by convention) | PEP 440 (MAJOR.MINOR.MICRO + pre/post/dev) |
| **Tooling enforcement** | Cargo interprets semver | Build tools manage versions | pip/uv/poetry resolve PEP 440 ranges |
| **Breaking change detection** | `cargo-semver-checks` (automated) | Manual (JLS Ch.13 rules) | Manual |
| **Deprecation** | `#[deprecated(since, note)]` | `@Deprecated(since, forRemoval)` | `warnings.warn(DeprecationWarning)` |
| **Removal timeline** | Semver major bump | No standard (LTS-driven) | 2+ versions (PEP 387) |
| **Minimum version policy** | MSRV (`rust-version`) | Target Java version (source/target flags) | `requires-python = ">=3.10"` |
| **Non-exhaustive types** | `#[non_exhaustive]` | Sealed classes (approximate) | No equivalent |
| **Constant inlining risk** | No (constants not inlined across crates) | Yes (`static final` inlined) | No (everything runtime) |

---

## Sources

### Books

- Klabnik, S. & Nichols, C. (2023). *The Rust Programming Language*, 2nd ed. No Starch Press. Ch.7 pp. 119–140, Ch.14 pp. 295–313
- Blandy, J. & Orendorff, J. (2017). *Programming Rust*. O'Reilly. Ch.8 pp. 161–191
- Gjengset, J. (2022). *Rust for Rustaceans*. No Starch Press. Ch.5 pp. 67–84
- Matthews, B. (2024). *Code Like a Pro in Rust*. Manning. Ch.2 pp. 11–42
- Horstmann, C. (2024). *Core Java, Vol. I*, 13th ed. Pearson. Ch.4 pp. 55–68, Ch.12 pp. 150–166
- Evans, B., Clark, J. & Verburg, M. (2022). *The Well-Grounded Java Developer*, 2nd ed. Manning. Ch.2 pp. 26–54
- Beckwith, M. (2024). *JVM Performance Engineering*. Addison-Wesley. Ch.3 pp. 69–97
- Bloch, J. (2018). *Effective Java*, 3rd ed. Addison-Wesley. Ch.4 Items 15, 16, 24, 25 pp. 73–115
- Slatkin, B. (2025). *Effective Python*, 3rd ed. Addison-Wesley. Ch.14 Items 116–125 pp. 575–626
- Martelli, A. et al. (2023). *Python in a Nutshell*, 4th ed. O'Reilly. Ch.7 pp. 221–245
- Viafore, P. (2021). *Robust Python*. O'Reilly. Ch.16 pp. 225–241

### External Resources

**Rust**
- [Rust Reference — Modules](https://doc.rust-lang.org/reference/items/modules.html)
- [Rust Reference — Crates and Source Files](https://doc.rust-lang.org/reference/crates-and-source-files.html)
- [Rust Reference — Visibility and Privacy](https://doc.rust-lang.org/reference/visibility-and-privacy.html)
- [Rust Reference — Conditional Compilation](https://doc.rust-lang.org/reference/conditional-compilation.html)
- [Rust By Example — Modules](https://doc.rust-lang.org/rust-by-example/mod.html)
- [Rust By Example — Visibility](https://doc.rust-lang.org/rust-by-example/mod/visibility.html)
- [Rust By Example — cfg](https://doc.rust-lang.org/rust-by-example/attribute/cfg.html)
- [Cargo Book — Project Layout](https://doc.rust-lang.org/cargo/guide/project-layout.html)
- [Cargo Book — Workspaces](https://doc.rust-lang.org/cargo/reference/workspaces.html)
- [Cargo Book — Specifying Dependencies](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html)
- [Cargo Book — Dependency Resolution](https://doc.rust-lang.org/cargo/reference/resolver.html)
- [Cargo Book — Cargo.toml vs Cargo.lock](https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html)
- [Cargo Book — Cargo Targets](https://doc.rust-lang.org/cargo/reference/cargo-targets.html)
- [Cargo Book — Features](https://doc.rust-lang.org/cargo/reference/features.html)
- [Cargo Book — Build Scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)
- [Cargo Book — SemVer Compatibility](https://doc.rust-lang.org/cargo/reference/semver.html)
- [Cargo Book — The Manifest Format](https://doc.rust-lang.org/cargo/reference/manifest.html)
- [Rust API Guidelines — Organization](https://rust-lang.github.io/api-guidelines/organization.html)
- [Rust API Guidelines — Necessities (C-STABLE)](https://rust-lang.github.io/api-guidelines/necessities.html)
- [cargo-semver-checks documentation](https://docs.rs/cargo-semver-checks/latest/cargo_semver_checks/)

**Java**
- [JLS Ch.7 — Packages and Modules](https://docs.oracle.com/javase/specs/jls/se21/html/jls-7.html)
- [JLS 6.6 — Access Control](https://docs.oracle.com/javase/specs/jls/se21/html/jls-6.html#jls-6.6)
- [JLS Ch.13 — Binary Compatibility](https://docs.oracle.com/javase/specs/jls/se21/html/jls-13.html)
- [Oracle Java Tutorial — Creating and Using Packages](https://docs.oracle.com/javase/tutorial/java/package/packages.html)
- [Oracle Java Tutorial — Controlling Access to Members of a Class](https://docs.oracle.com/javase/tutorial/java/javaOO/accesscontrol.html)
- [Baeldung — Guide to Java Packages](https://www.baeldung.com/java-packages)
- [Baeldung — Access Modifiers in Java](https://www.baeldung.com/java-access-modifiers)
- [Baeldung — A Guide to Java 9 Modularity](https://www.baeldung.com/java-9-modularity)
- [Baeldung — Java 9 ServiceLoader](https://www.baeldung.com/java-spi)
- [Baeldung — Maven Profiles](https://www.baeldung.com/maven-profiles)
- [Baeldung — Maven vs Gradle](https://www.baeldung.com/ant-maven-gradle)
- [Baeldung — Backward Compatibility in Java](https://www.baeldung.com/java-backward-compatibility)
- [JEP 261 — Module System](https://openjdk.org/jeps/261)
- [JEP 200 — The Modular JDK](https://openjdk.org/jeps/200)
- [JEP 220 — Modular Run-Time Images](https://openjdk.org/jeps/220)
- [Jigsaw Quick-Start Guide](https://openjdk.org/projects/jigsaw/quick-start)
- [Maven — Standard Directory Layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html)
- [Maven — Introduction to the Dependency Mechanism](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html)
- [Gradle — Dependency Management](https://docs.gradle.org/current/userguide/dependency_management.html)
- [Gradle — Dependency Resolution](https://docs.gradle.org/current/userguide/dependency_resolution.html)
- [Gradle — Build Variants](https://docs.gradle.org/current/userguide/variant_model.html)
- [Oracle — Java SE Compatibility Guide](https://docs.oracle.com/en/java/javase/21/migrate/)
- [Oracle — ModuleDescriptor API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/module/ModuleDescriptor.html)

**Python**
- [Python docs — The Import System](https://docs.python.org/3/reference/import.html)
- [Python docs — Modules tutorial](https://docs.python.org/3/tutorial/modules.html)
- [Python docs — Regular Packages](https://docs.python.org/3/reference/import.html#regular-packages)
- [Python docs — Private Variables](https://docs.python.org/3/tutorial/classes.html#private-variables)
- [Python docs — sys.platform](https://docs.python.org/3/library/sys.html#sys.platform)
- [Python docs — platform module](https://docs.python.org/3/library/platform.html)
- [Python docs — warnings module](https://docs.python.org/3/library/warnings.html)
- [PEP 8 — Naming Conventions](https://peps.python.org/pep-0008/#naming-conventions)
- [PEP 328 — Imports: Multi-Line and Absolute/Relative](https://peps.python.org/pep-0328/)
- [PEP 387 — Backwards Compatibility Policy](https://peps.python.org/pep-0387/)
- [PEP 420 — Implicit Namespace Packages](https://peps.python.org/pep-0420/)
- [PEP 440 — Version Identification and Dependency Specification](https://peps.python.org/pep-0440/)
- [PEP 621 — Storing project metadata in pyproject.toml](https://peps.python.org/pep-0621/)
- [PEP 665 — A file format to list Python dependencies](https://peps.python.org/pep-0665/)
- [Python Packaging User Guide](https://packaging.python.org/)
- [Python Packaging — Dependency Specifiers](https://packaging.python.org/en/latest/specifications/dependency-specifiers/)
- [Python Packaging — Version Specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/)
- [Real Python — Python Modules and Packages](https://realpython.com/python-modules-packages/)
- [Real Python — Python Application Layouts](https://realpython.com/python-application-layouts/)
- [Real Python — Python's Property Attribute and Encapsulation](https://realpython.com/python-property/)
- [uv documentation](https://docs.astral.sh/uv/)
- [Poetry documentation](https://python-poetry.org/docs/)

**Cross-Language**
- [Semantic Versioning 2.0.0](https://semver.org/)

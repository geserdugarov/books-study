# Layer 1 · Topic 1 — Philosophy & Design Goals

> Comparative study of Rust, Java, and Python: why each language exists, what tradeoffs it makes, and how it evolves.

---

## Owned Books — Relevant Chapters

| Language | Book | Chapter / Pages | Covers |
|----------|------|-----------------|--------|
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Introduction pp. xxv–xxix | Who Rust is for, how the book is structured, community |
| Rust | Klabnik & Nichols (2023) — *The Rust Programming Language* | Appendix E "Editions" pp. 515–516 | Rust editions (2015, 2018, 2021) and their role in evolution |
| Rust | Blandy & Orendorff (2017) — *Programming Rust* | Ch.1 "Why Rust?" pp. 1–5 | Memory safety motivation, ownership concept, zero-cost abstractions |
| Rust | Matthews (2024) — *Code Like a Pro in Rust* | Ch.1 "Feelin' Rusty" pp. 1–8 | Uniqueness of Rust, when to use it, positioning vs other languages |
| Java | Horstmann (2024) — *Core Java, Vol. I* | Ch.1 "An Introduction to Java" (§1.1–1.5) | Design goals (White Paper buzzwords), history from Green Project through Java 21, applets era, common misconceptions |
| Java | Bloch (2018) — *Effective Java* | Ch.1 "Introduction" p. 1 | Brief philosophical tone-setting |
| Java | Evans et al (2022) — *The Well-Grounded Java Developer* | Ch.1 "Introducing Modern Java" pp. 3–25 | Java evolution, release model, JEPs, JSRs, incubating features |
| Python | Martelli et al (2023) — *Python in a Nutshell* | Ch.1 "Introduction to Python" pp. 1–19 | Python history, philosophy, implementations (CPython, PyPy), development process and versioning, PEP culture |
| Python | Ramalho (2022) — *Fluent Python* | Ch.1 "The Python Data Model" pp. 3–20 | Python consistency philosophy through dunder methods |
| Python | Gorelick & Ozsvald (2020) — *High Performance Python* | Ch.1 "Understanding Performant Python" pp. 1–20 | Why use Python despite performance costs, expressiveness tradeoff |

### Coverage Gaps

The owned books **do not** cover:
- Rust governance (RFC process) in detail — Klabnik's Appendix E covers editions but not the RFC process or team structure
- A three-way comparative perspective — no single book compares all three
- Backwards-compatibility philosophy in depth for Java and Python (Evans covers the release model; Martelli Ch.26 covers migration but not the policy rationale)

---

## External Resources

### Sub-topic 1 — Historical Context and Creation Motivation

**Rust**
- Rust official FAQ — "Why Rust?": `https://prev.rust-lang.org/en-US/faq.html`
- The Rust Blog — early announcements: `https://blog.rust-lang.org/`
- Search YouTube: "Graydon Hoare Rust" for interviews/retrospectives by the creator

**Java**
- "The Java Language Environment" white paper (1996) by Gosling & McGilton — the founding document describing Java's design goals (simple, object-oriented, robust, secure, portable, high-performance, multithreaded, dynamic): `https://www.oracle.com/java/technologies/language-environment.html`
- Search YouTube: "James Gosling Java history" for keynotes by the creator

**Python**
- Guido van Rossum's "The History of Python" blog (series of posts on design decisions): `https://python-history.blogspot.com/`
- Python general FAQ — "Why was Python created?": `https://docs.python.org/3/faq/general.html`
- PEP 20 — The Zen of Python: `https://peps.python.org/pep-0020/`
- Foreword to Python docs by Guido: `https://docs.python.org/3/foreword.html`

### Sub-topic 2 — Core Design Tradeoffs

**Rust**
- "Fearless Concurrency" blog post: `https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html`
- Rust Reference — Influences: `https://doc.rust-lang.org/reference/influences.html`
- Search YouTube: "Carol Nichols Rust Language for the Next 40 Years"

**Java**
- Search YouTube: "Brian Goetz Stewardship Sobering Parts" (Devoxx 2019) — Java's conservative design philosophy
- Search YouTube: "Brian Goetz Java design" for talks on readability-vs-performance tradeoffs

**Python**
- PEP 20 — The Zen of Python (central to tradeoffs): `https://peps.python.org/pep-0020/`
- Search YouTube: "Raymond Hettinger What Makes Python Awesome" (PyCon talk)
- CPython Developer Guide: `https://devguide.python.org/`

### Sub-topic 3 — Target Domains and Sweet Spots

**Rust**
- Production users page: `https://www.rust-lang.org/production`
- Annual Rust survey results on the Rust Blog: `https://blog.rust-lang.org/`

**Java**
- JetBrains Developer Ecosystem Survey (annual): `https://www.jetbrains.com/lp/devecosystem/`

**Python**
- Python applications page: `https://www.python.org/about/apps/`
- Python Developers Survey (annual, JetBrains + PSF): `https://lp.jetbrains.com/python-developers-survey/`

### Sub-topic 4 — Language Specification Governance

**Rust**
- Governance structure: `https://www.rust-lang.org/governance`
- RFC repository and process: `https://github.com/rust-lang/rfcs`
- RFC 0002 (the RFC that defines the RFC process): `https://rust-lang.github.io/rfcs/0002-rfc-process.html`

**Java**
- Java Community Process overview: `https://jcp.org/en/introduction/overview`
- JEP process: `https://openjdk.org/jeps/0`
- JSR list: `https://jcp.org/en/jsr/all`
- OpenJDK bylaws: `https://openjdk.org/bylaws`

**Python**
- PEP 1 — PEP Purpose and Guidelines: `https://peps.python.org/pep-0001/`
- PEP 13 — Python Language Governance: `https://peps.python.org/pep-0013/`
- PEP 8016 — The Steering Council Model: `https://peps.python.org/pep-8016/`
- Full PEP index: `https://peps.python.org/`

### Sub-topic 5 — Backwards Compatibility and Versioning

**Rust**
- Edition Guide: `https://doc.rust-lang.org/edition-guide/`
- "Stability as a Deliverable" (2014 blog post): `https://blog.rust-lang.org/2014/10/30/Stability.html`

**Java**
- Oracle Java SE support roadmap: `https://www.oracle.com/java/technologies/java-se-support-roadmap.html`
- JEP 12 — Preview Features: `https://openjdk.org/jeps/12`
- JLS Chapter 13 — Binary Compatibility: `https://docs.oracle.com/javase/specs/jls/se21/html/jls-13.html`

**Python**
- PEP 387 — Backwards Compatibility Policy: `https://peps.python.org/pep-0387/`
- PEP 404 — Python 2.8 Un-release (2→3 transition cautionary tale): `https://peps.python.org/pep-0404/`
- Python versions and release schedule: `https://devguide.python.org/versions/`

---

## Study Plan — 5 Sessions

Estimated total: **8–12 hours**. One session per sub-topic. Sessions are ordered sequentially — each builds on the previous.

---

### Session 1 — Historical Context and Creation Motivation

**Goal:** understand *why* each language was created and what problem it solved.

| Step | Time | Activity |
|------|------|----------|
| 1.1 | 30 min | **Rust origins.** Read Klabnik Introduction pp. xxv–xxix ("Who Rust Is For"), then Blandy Ch.1 pp. 1–5, then Matthews Ch.1 pp. 1–8. Note: Rust began as Graydon Hoare's side project at Mozilla (2006) to fix C/C++ memory-safety vulnerabilities in Firefox. First stable release: 2015. Optionally skim the Rust FAQ online. |
| 1.2 | 30 min | **Java origins.** Read Horstmann Ch.1 §1.1–1.4 (Java as a platform, White Paper buzzwords, applets, short history). Then read Evans Ch.1 pp. 3–10 (first half). Note: Java emerged from the Green Project (1991) at Sun Microsystems. Originally "Oak" for embedded devices, pivoted to the web applet era. Optionally skim the Gosling & McGilton white paper online for the original framing. |
| 1.3 | 30 min | **Python origins.** Read Martelli Ch.1 pp. 1–19 (the Python language, implementations, development and versions). Then read Ramalho Ch.1 pp. 3–6. Note: Python created by Guido van Rossum at CWI Netherlands (1989) as a successor to ABC. First public release: 1991. Optionally read Guido's "History of Python" blog (first 3–4 posts) and the Python FAQ online. |
| 1.4 | 15 min | **Compare.** Write notes: what crisis or frustration motivated each? What existing languages were they reacting against? (Rust → C/C++ safety bugs; Java → C/C++ portability and complexity; Python → ABC's limitations and C's difficulty for non-programmers) |

---

### Session 2 — Core Design Tradeoffs

**Goal:** understand the fundamental tradeoff each language makes between safety, performance, and expressiveness.

| Step | Time | Activity |
|------|------|----------|
| 2.1 | 30 min | **Rust: safety + performance, no GC.** Re-read Blandy Ch.1 pp. 1–5 with fresh eyes. Read Matthews Ch.1 pp. 3–6 ("What's unique?"). Read the "Fearless Concurrency" blog post online. Key insight: compile-time ownership checks trade learning-curve pain for runtime safety without GC overhead. |
| 2.2 | 30 min | **Java: managed runtime, WORA.** Read Horstmann Ch.1 §1.2 "The Java White Paper Buzzwords" and §1.5 "Common Misconceptions" carefully. Read Evans Ch.1 pp. 3–15. Key insight: JVM + GC trade startup/memory overhead for developer productivity and portability. Extreme backwards compatibility is itself a design choice. |
| 2.3 | 30 min | **Python: expressiveness first.** Read Gorelick Ch.1 pp. 1–20 (the "why use Python?" argument). Read Ramalho Ch.1 pp. 3–20 (data model as expressiveness design). Read PEP 20 online. Key insight: Python trades raw performance for readability and rapid development. The GIL is a conscious simplicity tradeoff. |
| 2.4 | 15 min | **Comparison matrix.** Create a table: rows = {compile-time safety, runtime performance, developer productivity, learning curve, memory model, concurrency model}, columns = {Rust, Java, Python}. Fill in one sentence per cell. |

---

### Session 3 — Target Domains and Sweet Spots

**Goal:** understand where each language excels in production and why.

| Step | Time | Activity |
|------|------|----------|
| 3.1 | 20 min | **Rust domains.** Read Matthews Ch.1 pp. 5–8 ("When should you use Rust?"). Browse `rust-lang.org/production` online. Sweet spots: systems programming, WebAssembly, CLI tools, performance-critical Python library backends (Polars, Pydantic v2, Ruff), embedded. |
| 3.2 | 20 min | **Java domains.** Read Horstmann Ch.1 §1.1 "Java as a Programming Platform". Read Evans Ch.1 pp. 3–7. Browse the JetBrains Developer Ecosystem Survey online. Sweet spots: enterprise backends (Spring), big data (Spark/Kafka/Hadoop), financial systems, Android (historically), large-scale distributed systems. |
| 3.3 | 20 min | **Python domains.** Read Gorelick Ch.1 pp. 15–20. Read Martelli Ch.1 pp. 1–3 ("The Python Language"). Browse `python.org/about/apps` online. Sweet spots: data science / ML / AI (PyTorch, TensorFlow, pandas), scripting/automation, web (Django, FastAPI), scientific computing, prototyping. The "glue language". |
| 3.4 | 15 min | **Overlap and divergence.** Note where domains overlap (web backends — all three) vs where one dominates (ML → Python, OS-level → Rust, enterprise middleware → Java). Note the trend: Rust as backend engine for Python libraries. |

---

### Session 4 — Language Specification Governance

**Goal:** understand how each language evolves — who decides, what process, how fast.

| Step | Time | Activity |
|------|------|----------|
| 4.1 | 30 min | **Rust: RFC process.** Read Klabnik Appendix E "Editions" pp. 515–516 for the editions mechanism. Then read the governance page at `rust-lang.org/governance` and RFC 0002 online. Browse the RFC repo on GitHub. Key points: community-driven, Rust Foundation (since 2021), teams (Lang, Compiler, Library, etc.), RFCs → FCP → merge. |
| 4.2 | 30 min | **Java: JCP / JSR / JEP.** Read Evans Ch.1 pp. 15–25 (section 1.4). Read the JCP overview and JEP 0 online. Key points: formal spec (JLS + JVMS), JEPs for OpenJDK implementation, JSRs for spec changes, Oracle stewardship. More corporate-governed. |
| 4.3 | 30 min | **Python: PEPs and Steering Council.** Read Martelli Ch.1 pp. 10–11 ("Python Development and Versions"). Then read PEP 1 (how PEPs work), PEP 13 (governance), and PEP 8016 (Steering Council model) online. Key points: Guido was BDFL until 2018. Now 5-member Steering Council elected by core developers. Three PEP types: Standards Track, Informational, Process. |
| 4.4 | 15 min | **Compare.** Foundation + community teams (Rust) vs corporate stewardship + JCP (Java) vs BDFL-turned-Steering-Council (Python). How does governance structure affect evolution pace and character? |

---

### Session 5 — Backwards Compatibility and Versioning Model

**Goal:** understand how each language handles breaking changes and long-term stability.

| Step | Time | Activity |
|------|------|----------|
| 5.1 | 30 min | **Rust editions.** Re-read Klabnik Appendix E pp. 515–516. Then read the Edition Guide (intro + "What are Editions?") and the "Stability as a Deliverable" blog post online. Key insight: editions (2015, 2018, 2021, 2024) allow breaking syntax changes while maintaining cross-edition interoperability. "Stability without stagnation." |
| 5.2 | 30 min | **Java versioning.** Read Horstmann Ch.1 §1.4 "A Short History of Java" (covers the release timeline). Read Evans Ch.1 pp. 10–15 (release model). Read the Oracle roadmap and JEP 12 online. Key insight: 6-month cadence since Java 10 (2018), LTS every 2 years (11, 17, 21, 25). Preview features allow experimentation. Binary compatibility since 1996 — extreme backwards compat. |
| 5.3 | 30 min | **Python versioning.** Read Martelli Ch.26 "v3.7 to v3.n Migration" pp. 661–668 (significant changes, planning upgrades). Then read PEP 387 (backwards compatibility policy) and PEP 404 (the 2.8 un-release) online. Key insight: the Python 2→3 transition (a decade of pain) shaped current policy — deprecation-first, no edition system, annual release cycle. |
| 5.4 | 20 min | **Comparative synthesis.** Rust's edition system (elegant, interoperable) vs Java's extreme binary compat (decades of trust) vs Python's "once bitten, twice shy" deprecation-first policy. Which approach best serves each language's ecosystem? |

---

## Summary Table

| Session | Theme | Owned-Book Pages | Key External Resources |
|---------|-------|-----------------|----------------------|
| 1 | History & motivation | Klabnik xxv–xxix, Blandy 1–5, Matthews 1–8, Horstmann Ch.1 §1.1–1.4, Evans 3–10, Martelli 1–19, Ramalho 3–6 | Rust FAQ, Gosling white paper, Guido's blog, Python FAQ |
| 2 | Design tradeoffs | Blandy 1–5, Matthews 3–6, Horstmann Ch.1 §1.2+§1.5, Evans 3–15, Gorelick 1–20, Ramalho 3–20 | Fearless Concurrency post, PEP 20 |
| 3 | Target domains | Matthews 5–8, Horstmann Ch.1 §1.1, Evans 3–7, Gorelick 15–20, Martelli 1–3 | rust-lang.org/production, python.org/apps, JetBrains surveys |
| 4 | Governance | Klabnik App.E 515–516, Evans 15–25, Martelli 10–11 | Rust governance page, RFC 0002, JCP overview, JEP 0, PEP 1/13/8016 |
| 5 | Compatibility & versioning | Klabnik App.E 515–516, Horstmann Ch.1 §1.4, Evans 10–15, Martelli 661–668 | Edition Guide, Stability blog post, Oracle roadmap, JEP 12, PEP 387/404 |

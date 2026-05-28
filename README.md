# `books-study` project

Study planning of computer science and programming languages utilizing analysis by LLM agents.

# Structure

```text
books/                   # PDF books organized by language/topic
├── Rust/
├── Java/
├── Python/
└── distributed-systems/

books_md/                # Generated Markdown of books/ (checked in, see scripts/)

index/                   # Book indices: metadata, TOC, chapter summaries, key topics
├── Rust/
├── Java/
├── Python/
└── distributed-systems/

plans/                   # Study plans: topic breakdowns, session schedules, reading lists
└── rust_java_python/

overview/                # Compiled overviews synthesizing content from multiple sources
└── rust_java_python/

scripts/                 # Helper scripts (e.g. PDF → Markdown conversion)
```


# Tools

For reading of pdf-files `poppler-utils` is used. To install it in WSL:

```bash
sudo apt -o Acquire::http::Proxy="DIRECT" install poppler-utils
```

## PDF → Markdown conversion

Full-text Markdown extraction from books in `books/` is done with
[opendataloader-pdf](https://github.com/opendataloader-project/opendataloader-pdf).

Prerequisites: Java 11+ and Python 3.10+. Set up a project-local virtual
environment and install the tool into it:

```bash
python3 -m venv venv
./venv/bin/pip install -U opendataloader-pdf
```

The `venv/` directory is gitignored. Run the wrapper script to convert
every PDF under `books/` into Markdown under `books_md/` (both paths can
be overridden); it invokes `opendataloader-pdf` from `./venv/bin`:

```bash
scripts/convert_pdf_to_md.sh                       # books/ -> books_md/
scripts/convert_pdf_to_md.sh books/Rust            # only the Rust subtree
scripts/convert_pdf_to_md.sh books/Rust out/Rust   # custom output directory
```

Converted Markdown under `books_md/` is checked into the repository.

# Index


Analysis of chosen index structure:

```text
 Token Budget Analysis

 Current index sizes

 - 20 index files across Rust (5), Java (9), Python (5), distributed-systems (1)
 - 4,217 total lines, average 210 lines/file
 - Estimated ~50,000–60,000 tokens to read all 20 files
 - For a typical 3-language plan: ~15 books → ~40,000–45,000 tokens

 What percentage of context does this consume?

 - With 1M context window: ~4–6% — negligible
 - Leaves 940K+ tokens for plan generation, external resources, and conversation

 What the plan actually extracts from each index

 Looking at the error handling plan (layer_2_topic_7_error_handling.md), each book entry in the
 "Owned Books" table uses exactly 3 data points:
 1. Book title + author + year (from metadata)
 2. Chapter + page range (from TOC)
 3. One-line description of what the chapter covers (derived from TOC items + summary)

 Out of ~210 lines per index file, the plan uses ~2-5 lines of output per book. But the model needs
  the surrounding context (chapter summaries, sub-item listings) to correctly identify which
 chapters are relevant.

 Verdict: The Current Format Is a Good Fit

 Why it works well

 1. Chapter summaries are the key signal — they let the model match topics like "error handling" to
  the correct chapters even when titles are ambiguous (e.g., Fluent Python Ch.18 "with, match, and
 else Blocks" covers context managers relevant to error handling, but this is only clear from the
 summary)
 2. Sub-item detail adds precision — Effective Java's 90 items listed individually let the model
 reference "Items 69–77" rather than just "Ch.10". This produces better plans.
 3. Token cost is modest — 40K–60K tokens is 4–6% of the 1M context. This is a small price for
 accurate chapter identification.
 4. Plan quality is excellent — the error handling plan demonstrates precise page references across
  15+ book entries, suggesting the index provides the right level of detail
```


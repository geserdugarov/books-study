# `books-study` project

Study planning of computer science and programming languages utilizing analysis by LLM agents.

# Structure

```text
books/                   # PDF books organized by language/topic
├── Rust/
├── Java/
├── Python/
└── distributed-systems/

index/                   # Book indices: metadata, TOC, chapter summaries, key topics
├── Rust/
├── Java/
├── Python/
└── distributed-systems/

plans/                   # Study plans: topic breakdowns, session schedules, reading lists
└── rust_java_python/

overview/                # Compiled overviews synthesizing content from multiple sources
└── rust_java_python/
```


# Tools

For reading of pdf-files `poppler-utils` is used. To install it in WSL:
```bash
sudo apt -o Acquire::http::Proxy="DIRECT" install poppler-utils
```


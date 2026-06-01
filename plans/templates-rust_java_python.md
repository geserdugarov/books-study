# First iteration of planning

```text
I want to study three different programming languages: Rust, Java and Python in parallel, from topic to topic comparing different implementations.
The whole plan is presented in `./plans/rust_java_python/rust_java_python_topics_list.md`
The current topic for this session is:
  "Layer *: *", "*. *"
and should start from detailed studying plan preparation with direct links to resources.
There are some books about those programming languages in `./books/` folder,
their content is indexed in `./index/` folder,
and full-text Markdown extracts are available in `./books_md/`
(generated via `scripts/convert_pdf_to_md.sh`; gitignored — regenerate locally if absent).
Use `./index/` for fast chapter/topic lookup,
and `./books_md/` to verify chapter titles, section headings, and page ranges before citing them.
The content of presented books will be not enough for the full study plan. 
I need a list of external sources, like documentation, specifications, blogs, etc. 
Maybe you could suggest another books, that I will find and buy manually. 
Provide me a list of those external sources, or suggest some books for full coverage of the current topic.
And then prepare detailed plan for studying of the current topic, 
and save it in a separate md-file named as:
  layer_<i>_topic_<j>_<couple_of_words_to_describe>.md
in `./plans/rust_java_python/` folder.
```

# Update index

```text
I've added some new books in `./books/` folder.
Add index for newly added books,
check index examples for already indexed books in `./index/` folder.
```

# Update plan with added literature

```text
I've added some suggested books, their index is added by commit *
Regenerate `./books_md/` for the newly added books via `scripts/convert_pdf_to_md.sh`
so chapter titles and page ranges can be verified against the extracted Markdown.
Rewrite the plan correspondingly. 
Use local books with higher priority.
```

# Review plan against extracted source text

```text
Review the per-topic plan:
  ./plans/rust_java_python/layer_<i>_topic_<j>_*.md
against the full-text Markdown corpus in `./books_md/<Language>/<Book>.md`.
Verify that every "Owned Books" entry has correct chapter title, section headings,
and page range; reclassify entries to "Coverage Gaps" only when the cited material
is genuinely absent from the owned corpus.
The committed `./index/<Language>/` files cover chapter titles and major-section
page boundaries — sufficient for chapter-level cross-checks but not for granular
sub-section page ranges. If `./books_md/` is unavailable, do not silently invent
citations; flag affected entries as unverifiable and stop.
Apply targeted fixes in-place; do not rewrite unrelated sections.
```

# Write about the current topic using corresponding plan

```text
Use the plan:
  ./plans/rust_java_python/*.md 
and collect all the data in one formatted md-file in ./overview/rust_java_python/, 
which will have content from all mentioned resources combined, 
ready for read, and with link to initial sources.
```

# Proofreading

```text
Made a proofreading of:
  ./overview/rust_java_python/*.md
the content should be:
  - correct,
  - without any hallucinations,
  - cover all major nuances of the topic.
Verify every citation against `./books_md/<Language>/<Book>.md` for chapter
titles and page ranges, and against the linked external sources for quoted
claims; correct anything that does not match the source.
```


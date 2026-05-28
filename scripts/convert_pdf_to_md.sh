#!/usr/bin/env bash
# Convert PDF files to Markdown using opendataloader-pdf.
# See: https://github.com/opendataloader-project/opendataloader-pdf
#
# Prerequisites:
#   - Java 11+      (java -version)
#   - Python 3.10+  (python3 --version)
#   - Project virtualenv at ./venv with opendataloader-pdf installed:
#         python3 -m venv venv
#         ./venv/bin/pip install -U opendataloader-pdf
#
# Usage:
#   scripts/convert_pdf_to_md.sh [INPUT] [OUTPUT_DIR]
#
# Defaults:
#   INPUT       = ./books
#   OUTPUT_DIR  = ./books_md
#
# INPUT may be a single PDF file or a directory; directories are processed
# recursively. The output directory is created if it does not exist.

set -euo pipefail

INPUT="${1:-./books}"
OUTPUT_DIR="${2:-./books_md}"

VENV_BIN="./venv/bin/opendataloader-pdf"

if [[ ! -x "$VENV_BIN" ]]; then
    echo "error: '$VENV_BIN' not found." >&2
    echo "       create the project virtualenv first:" >&2
    echo "           python3 -m venv venv" >&2
    echo "           ./venv/bin/pip install -U opendataloader-pdf" >&2
    exit 127
fi

if [[ ! -e "$INPUT" ]]; then
    echo "error: input path '$INPUT' does not exist." >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

exec "$VENV_BIN" \
    --format markdown \
    --output-dir "$OUTPUT_DIR" \
    "$INPUT"

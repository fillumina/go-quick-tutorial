#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/go-quick-tutorial.pdf"

# Collect chapter files in order
CHAPTERS=$(ls "$SCRIPT_DIR"/[0-9][0-9]-*.md 2>/dev/null | sort)

if [ -z "$CHAPTERS" ]; then
  echo "No chapter files found."
  exit 1
fi

# Build input list: preamble first, then chapters
INPUT_FILES=("$SCRIPT_DIR/00-preamble.md")
for ch in $CHAPTERS; do
  INPUT_FILES+=("$ch")
done

# Create a temporary directory for preprocessed files
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Preprocess files and concatenate into one
first=true
for f in "${INPUT_FILES[@]}"; do
  bname=$(basename "$f")
  perl -CSD -pe '
    s/\x{FFFD}/\\textquestiondown/g;
    s/\x{2075}/\\textsuperscript\{5\}/g;
    s/\x{2073}/\\textsuperscript\{3\}/g;
  ' "$f" > "$TMPDIR/$bname"

  # Add YAML frontmatter to README for title page
  if [ "$first" = true ]; then
    cat > "$TMPDIR/$bname.tmp" <<'EOF'
---
title: "Go Quick Tutorial"
subtitle: "A 2-hour complete Go course"
author: "Francesco Illuminati"
date: "2026"
rights: "Copyright © 2026 Francesco Illuminati. Licensed under the MIT License."
titlepage: true
titlepage-color: "FFFFFF"
titlepage-text-color: "333333"
titlepage-rule-color: "333333"
documentclass: article
classoption:
  - 11pt
  - a4paper
---

EOF
    cat "$TMPDIR/$bname" >> "$TMPDIR/$bname.tmp"
    mv "$TMPDIR/$bname.tmp" "$TMPDIR/$bname"
    first=false
  fi

  # Add page break marker
  echo '%%NEWPAGE%%' >> "$TMPDIR/$bname"
done

# Concatenate all files and replace markers with raw LaTeX page break
cat "$TMPDIR"/*.md | sed 's/%%NEWPAGE%%/\n\\newpage\n/' > "$TMPDIR/combined.md"

# Generate PDF with Pandoc using pdflatex
pandoc \
  --pdf-engine=pdflatex \
  --highlight-style=tango \
  --toc \
  --toc-depth=3 \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -V fontsize=11pt \
  -V linestretch=1.2 \
  -V geometry:margin=2.5cm \
  -o "$OUTPUT" \
  "$TMPDIR/combined.md"

echo "PDF generated: $OUTPUT"

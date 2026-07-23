#!/usr/bin/env sh
# Regenerates adr/INDEX.md from the headers of all ADR files.
# Run from the root of a project that uses the ADR pattern.
# Usage: update-adr-index.sh [adr-dir]
#
# Reads the first 25 lines of each ADR file to extract:
#   Title, Category, Summary
# Writes adr/INDEX.md with a full table.

set -e

ADR_DIR="${1:-adr}"

if [ ! -d "$ADR_DIR" ]; then
  echo "Error: ADR directory not found: $ADR_DIR" >&2
  exit 1
fi

INDEX_FILE="$ADR_DIR/INDEX.md"

# Header
cat > "$INDEX_FILE" <<'EOF'
# ADR Index

| ADR  | Category | Title | Summary |
|------|----------|-------|---------|
EOF

# Find all ADR markdown files, sorted numerically
find "$ADR_DIR" -name "*.md" ! -name "INDEX.md" | sort | while read -r file; do
  # Extract ADR number from filename (e.g. 0021-qdrant.md → 0021)
  filename="$(basename "$file" .md)"
  adr_number="$(echo "$filename" | grep -oE '^[0-9]+')"
  [ -z "$adr_number" ] && continue

  # Read first 25 lines for header fields
  header="$(head -25 "$file")"

  title="$(echo "$header" | grep -i '^Title:' | sed 's/^[Tt]itle: *//')"
  category="$(echo "$header" | grep -i '^Category:' | sed 's/^[Cc]ategory: *//')"
  summary="$(echo "$header" | grep -i '^Summary:' | sed 's/^[Ss]ummary: *//')"

  [ -z "$title" ] && title="(no title)"
  [ -z "$category" ] && category="(no category)"
  [ -z "$summary" ] && summary="(no summary)"

  echo "| $adr_number | $category | $title | $summary |" >> "$INDEX_FILE"
done

echo "INDEX.md regenerated at $INDEX_FILE"

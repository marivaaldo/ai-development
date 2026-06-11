#!/usr/bin/env sh
# Copies the example/ project structure into a target directory.
# Usage: ./scripts/init.sh /path/to/target

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/example"

TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target-directory>" >&2
  exit 1
fi

if [ ! -d "$EXAMPLE_DIR" ]; then
  echo "Error: example/ directory not found at $EXAMPLE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET"

rsync -a --exclude="README.md" --exclude=".gitkeep" "$EXAMPLE_DIR/" "$TARGET/"

echo "Project structure initialized at: $TARGET"
echo ""
echo "Next steps:"
echo "  1. Review docs/guide.md for the maturity roadmap"
echo "  2. Install skills: ./scripts/install.sh"
echo "  3. Start with Phase 0 — don't create structure you don't need yet"

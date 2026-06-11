#!/usr/bin/env sh
# Copies the example/ project structure into a target directory and appends
# provider fragments into the project's agent config file.
# Usage: ./scripts/init.sh /path/to/target

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/example"
FRAGMENTS_DIR="$REPO_ROOT/kit/fragments"

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

# Append all available fragments for each detected provider
append_provider_fragments() {
  provider="$1"
  case "$provider" in
    claude)   config_file="$TARGET/CLAUDE.md" ;;
    gemini)   config_file="$TARGET/GEMINI.md" ;;
    windsurf) config_file="$TARGET/.windsurfrules" ;;
    codex)    config_file="$TARGET/AGENTS.md" ;;
    *) return 0 ;;
  esac

  for fragment in "$FRAGMENTS_DIR"/*."$provider".md; do
    [ -f "$fragment" ] || continue

    marker="$(grep -m1 '^#' "$fragment" | sed 's/^#* *//')"
    [ -z "$marker" ] && marker="$(head -2 "$fragment" | tail -1 | tr -d ' ')"

    if grep -qF "$marker" "$config_file" 2>/dev/null; then
      echo "  ↳ Fragment already present in $(basename "$config_file"), skipping"
      continue
    fi

    cat "$fragment" >> "$config_file"
    echo "  ✓ Appended $(basename "$fragment") to $(basename "$config_file")"
  done
}

echo ""
echo "Appending fragments..."
for provider in claude gemini codex windsurf; do
  command -v "$provider" >/dev/null 2>&1 || continue
  echo "  Provider: $provider"
  append_provider_fragments "$provider"
done

echo ""
echo "Next steps:"
echo "  1. Review docs/guide.md for the maturity roadmap"
echo "  2. Run install.sh to install skills: ./scripts/install.sh --scope project"
echo "  3. Start with Phase 0 — don't create structure you don't need yet"

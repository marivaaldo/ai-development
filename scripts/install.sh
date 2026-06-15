#!/usr/bin/env sh
# Installs skills from kit/skills/ into the appropriate location for a given AI provider.
# Usage: ./scripts/install.sh [--provider <claude|gemini|codex|windsurf>] [--skill <name>]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/kit/skills"
FRAGMENTS_DIR="$REPO_ROOT/kit/fragments"

# ── helpers ──────────────────────────────────────────────────────────────────

# Print prompt to stderr, read answer from stdin
prompt_ask() {
  printf '%s ' "$1" >&2
  read -r REPLY
  echo "$REPLY"
}

prompt_choice() {
  # prompt_choice "label" opt1 opt2 ... → prints chosen value
  label="$1"; shift
  options="$*"
  while true; do
    printf '%s [%s]: ' "$label" "$(echo "$options" | tr ' ' '/')" >&2
    read -r REPLY
    for opt in $options; do
      [ "$REPLY" = "$opt" ] && echo "$REPLY" && return 0
    done
    printf '  Please enter one of: %s\n' "$options" >&2
  done
}

list_skills() {
  find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | xargs -I{} basename {} | sort
}

# ── detect installed providers ────────────────────────────────────────────────

detect_providers() {
  detected=""
  command -v claude  >/dev/null 2>&1 && detected="$detected claude"
  command -v gemini  >/dev/null 2>&1 && detected="$detected gemini"
  command -v codex   >/dev/null 2>&1 && detected="$detected codex"
  # Windsurf is an IDE and does not install a CLI binary — cannot be auto-detected
  echo "$detected"
}

# ── provider install functions ────────────────────────────────────────────────

install_claude() {
  skill_name="$1"
  scope="$2"
  skill_src="$SKILLS_DIR/$skill_name/skill.md"

  if [ "$scope" = "global" ]; then
    base="$HOME/.claude"
  else
    base="$(pwd)/.claude"
  fi

  # commands/ → native slash command (works without superpowers)
  cmd_dest="$base/commands/${skill_name}.md"
  mkdir -p "$(dirname "$cmd_dest")"
  cp "$skill_src" "$cmd_dest"

  # skills/ → discovery via superpowers Skill tool
  skill_dest="$base/skills/$skill_name/skill.md"
  mkdir -p "$(dirname "$skill_dest")"
  cp "$skill_src" "$skill_dest"

  echo "  ✓ Installed to $cmd_dest" >&2
  echo "  ✓ Installed to $skill_dest" >&2
}

install_gemini() {
  skill_name="$1"
  scope="$2"
  skill_src="$SKILLS_DIR/$skill_name"

  if [ "$scope" = "global" ]; then
    dest="$HOME/.gemini/skills/$skill_name"
  else
    dest="$(pwd)/.gemini/skills/$skill_name"
  fi

  mkdir -p "$dest"
  cp -r "$skill_src/." "$dest/"
  echo "  ✓ Copied skill files to $dest" >&2
  echo "" >&2
  echo "  Manual step required for Gemini CLI:" >&2
  echo "  Reference the skill in your GEMINI.md:" >&2
  echo "" >&2
  echo "    @$dest/skill.md" >&2
  echo "" >&2
  echo "  See kit/references/gemini.md for details." >&2
}

install_windsurf() {
  skill_name="$1"
  scope="$2"
  skill_src="$SKILLS_DIR/$skill_name"

  if [ "$scope" = "global" ]; then
    dest="$HOME/.codeium/windsurf/skills/$skill_name"
  else
    dest="$(pwd)/.windsurf/skills/$skill_name"
  fi

  mkdir -p "$dest"
  cp -r "$skill_src/." "$dest/"
  echo "  ✓ Installed to $dest" >&2
}

install_codex() {
  skill_name="$1"
  scope="$2"
  skill_src="$SKILLS_DIR/$skill_name"

  if [ "$scope" = "global" ]; then
    dest="$HOME/.codex/skills/$skill_name"
  else
    dest="$(pwd)/.codex/skills/$skill_name"
  fi

  mkdir -p "$dest"
  cp -r "$skill_src/." "$dest/"
  echo "  ✓ Copied skill files to $dest" >&2
  echo "" >&2
  echo "  Manual step required for Codex/Copilot:" >&2
  echo "  Register the skill in your plugin configuration." >&2
  echo "  See kit/references/codex.md for details." >&2
}

# ── fragment append ───────────────────────────────────────────────────────────

# Map a skill name to its fragment group (e.g. ddd-aggregate → ddd)
skill_to_fragment_group() {
  case "$1" in
    adr-*|architecture-review) echo "adr" ;;
    ddd-*)                     echo "ddd" ;;
    ca-*)                      echo "clean-architecture" ;;
    eng-*)                     echo "engineering" ;;
    code-review)               echo "engineering" ;;
    *)                         echo "$1" ;;
  esac
}

# Append provider-specific fragments for a skill into the project's agent config file.
# Idempotent: skips if the fragment marker (first heading text) is already present.
# Limitation: if a fragment is updated and its first heading changes, re-running install
# will append the new version without removing the old one. Resolve manually by editing
# the config file to remove the outdated fragment block before re-running.
append_fragments() {
  skill_name="$1"
  provider="$2"
  scope="$3"

  # fragments only make sense for project scope
  [ "$scope" = "project" ] || return 0

  fragment_group="$(skill_to_fragment_group "$skill_name")"
  fragment="$FRAGMENTS_DIR/${fragment_group}.${provider}.md"
  [ -f "$fragment" ] || return 0

  case "$provider" in
    claude)   config_file="$(pwd)/CLAUDE.md" ;;
    gemini)   config_file="$(pwd)/GEMINI.md" ;;
    windsurf) config_file="$(pwd)/.windsurfrules" ;;
    codex)    config_file="$(pwd)/AGENTS.md" ;;
    *)        return 0 ;;
  esac

  # Use a unique marker from the fragment's first heading as idempotency key
  marker="$(grep -m1 '^#' "$fragment" | sed 's/^#* *//')"
  if [ -z "$marker" ]; then
    marker="$(head -2 "$fragment" | tail -1 | tr -d ' ')"
  fi

  if grep -qF "$marker" "$config_file" 2>/dev/null; then
    echo "  ↳ Fragment already present in $(basename "$config_file"), skipping" >&2
    return 0
  fi

  cat "$fragment" >> "$config_file"
  echo "  ✓ Appended fragment to $(basename "$config_file")" >&2
}

# ── main ──────────────────────────────────────────────────────────────────────

PROVIDER=""
SKILL_ARG=""
SCOPE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --provider) PROVIDER="$2"; shift 2 ;;
    --skill)    SKILL_ARG="$2"; shift 2 ;;
    --scope)    SCOPE="$2";    shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

echo "" >&2
echo "=== ai-development skill installer ===" >&2
echo "" >&2

# Detect or ask provider
if [ -z "$PROVIDER" ]; then
  detected="$(detect_providers)"
  if [ -n "$detected" ]; then
    echo "Detected providers:$detected" >&2
    echo "" >&2
  fi
  PROVIDER="$(prompt_choice "Provider" claude gemini codex windsurf)"
fi

# Ask scope if not supplied via --scope
echo "" >&2
if [ -z "$SCOPE" ]; then
  SCOPE="$(prompt_choice "Install scope" global project)"
fi
if [ "$PROVIDER" = "windsurf" ]; then
  echo "  global = ~/.codeium/windsurf/skills  |  project = ./.windsurf/skills" >&2
else
  echo "  global = ~/.$PROVIDER/skills  |  project = ./.${PROVIDER}/skills" >&2
fi

# Select skill(s)
echo "" >&2
if [ -n "$SKILL_ARG" ]; then
  skills_to_install="$SKILL_ARG"
else
  echo "Available skills:" >&2
  list_skills | while read -r s; do printf '  - %s\n' "$s" >&2; done
  echo "  - all" >&2
  echo "" >&2
  SKILL_INPUT="$(prompt_ask "Skill to install (name or 'all'):")"
  skills_to_install="$SKILL_INPUT"
fi

# Resolve "all" regardless of whether it came from --skill flag or interactive input
if [ "$skills_to_install" = "all" ]; then
  skills_to_install="$(list_skills)"
fi

# Install
echo "" >&2
for skill in $skills_to_install; do
  if [ ! -d "$SKILLS_DIR/$skill" ]; then
    printf '  ✗ Skill not found: %s\n' "$skill" >&2
    continue
  fi
  printf 'Installing %s for %s (%s)...\n' "$skill" "$PROVIDER" "$SCOPE" >&2
  case "$PROVIDER" in
    claude)    install_claude    "$skill" "$SCOPE" ;;
    gemini)    install_gemini    "$skill" "$SCOPE" ;;
    codex)     install_codex     "$skill" "$SCOPE" ;;
    windsurf)  install_windsurf  "$skill" "$SCOPE" ;;
    *)      printf '  ✗ Unknown provider: %s\n' "$PROVIDER" >&2 ;;
  esac
  append_fragments "$skill" "$PROVIDER" "$SCOPE"
done

echo "" >&2
echo "Done." >&2

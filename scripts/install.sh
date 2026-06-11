#!/usr/bin/env sh
# Installs skills from kit/skills/ into the appropriate location for a given AI provider.
# Usage: ./scripts/install.sh [--provider <claude|gemini|codex|windsurf>] [--skill <name>]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/kit/skills"

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
  command -v claude    >/dev/null 2>&1 && detected="$detected claude"
  command -v gemini    >/dev/null 2>&1 && detected="$detected gemini"
  command -v codex     >/dev/null 2>&1 && detected="$detected codex"
  command -v windsurf  >/dev/null 2>&1 && detected="$detected windsurf"
  echo "$detected"
}

# ── provider install functions ────────────────────────────────────────────────

install_claude() {
  skill_name="$1"
  scope="$2"
  skill_src="$SKILLS_DIR/$skill_name"

  if [ "$scope" = "global" ]; then
    dest="$HOME/.claude/skills/$skill_name"
  else
    dest="$(pwd)/.claude/skills/$skill_name"
  fi

  mkdir -p "$dest"
  cp -r "$skill_src/." "$dest/"
  echo "  ✓ Installed to $dest"
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
  echo "  ✓ Copied skill files to $dest"
  echo ""
  echo "  Manual step required for Gemini CLI:"
  echo "  Reference the skill in your GEMINI.md:"
  echo ""
  echo "    @$dest/skill.md"
  echo ""
  echo "  See kit/references/gemini.md for details."
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
  echo "  ✓ Installed to $dest"
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
  echo "  ✓ Copied skill files to $dest"
  echo ""
  echo "  Manual step required for Codex/Copilot:"
  echo "  Register the skill in your plugin configuration."
  echo "  See kit/references/codex.md for details."
}

# ── main ──────────────────────────────────────────────────────────────────────

PROVIDER=""
SKILL_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --provider) PROVIDER="$2"; shift 2 ;;
    --skill)    SKILL_ARG="$2"; shift 2 ;;
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

# Ask scope
echo "" >&2
SCOPE="$(prompt_choice "Install scope" global project)"
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
  if [ "$SKILL_INPUT" = "all" ]; then
    skills_to_install="$(list_skills)"
  else
    skills_to_install="$SKILL_INPUT"
  fi
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
done

echo "" >&2
echo "Done." >&2

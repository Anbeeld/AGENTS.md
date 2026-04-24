#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE="$REPO_DIR/AGENTS.md"

AGENTS_TARGETS=()
CLAUDE_TARGETS=()
DRY_RUN=false

ensure_source_exists() {
    if [ ! -f "$SOURCE" ]; then
        echo "Source file not found: $SOURCE" >&2
        exit 1
    fi
}

ensure_target_parent_exists() {
    local target="$1"
    local parent
    parent="$(dirname "$target")"

    if [ ! -d "$parent" ]; then
        echo "Target directory not found: $parent" >&2
        exit 1
    fi
}

require_target_args() {
    local flag="$1"

    if [ $# -lt 2 ] || [[ "$2" == --* ]]; then
        echo "Missing path after $flag" >&2
        exit 1
    fi
}

detect_targets() {
    local os="$(uname -s 2>/dev/null || echo unknown)"
    local home=""

    case "$os" in
        Darwin|Linux)
            home="${HOME:?}"
            [ -d "$home/.config/opencode" ] && AGENTS_TARGETS+=("$home/.config/opencode/AGENTS.md")
            [ -d "$home/.codex" ]          && AGENTS_TARGETS+=("$home/.codex/AGENTS.md")
            [ -d "$home/.claude" ]         && CLAUDE_TARGETS+=("$home/.claude/CLAUDE.md")
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            home="${USERPROFILE:-${HOME:?}}"
            local appdata="${APPDATA:-$home/AppData/Roaming}"
            [ -d "$home/.config/opencode" ] && AGENTS_TARGETS+=("$home/.config/opencode/AGENTS.md")
            [ -d "$appdata/codex" ]         && AGENTS_TARGETS+=("$appdata/codex/AGENTS.md")
            [ -d "$appdata/claude" ]        && CLAUDE_TARGETS+=("$appdata/claude/CLAUDE.md")
            ;;
        *)
            echo "Unknown OS: $os. Specify targets with --targets-opencode/--targets-codex/--targets-claude." >&2
            ;;
    esac
}

sync() {
    ensure_source_exists

    if [ ${#AGENTS_TARGETS[@]} -eq 0 ] && [ ${#CLAUDE_TARGETS[@]} -eq 0 ]; then
        echo "No agent config directories found. Create them first or use --targets-* flags." >&2
        exit 1
    fi

    local total=0

    for target in "${AGENTS_TARGETS[@]}"; do
        ensure_target_parent_exists "$target"
        if [[ "$target" == *"/opencode/"* ]]; then
            echo "  -> $target (OpenCode)"
        else
            echo "  -> $target (Codex)"
        fi
        cp "$SOURCE" "$target"
        total=$((total + 1))
    done

    for target in "${CLAUDE_TARGETS[@]}"; do
        ensure_target_parent_exists "$target"
        echo "  -> $target (Claude Code)"
        cp "$SOURCE" "$target"
        total=$((total + 1))
    done

    echo "Synced to $total target(s)."
}

dry_run_sync() {
    ensure_source_exists

    if [ ${#AGENTS_TARGETS[@]} -eq 0 ] && [ ${#CLAUDE_TARGETS[@]} -eq 0 ]; then
        echo "No agent config directories found." >&2
        exit 1
    fi

    echo "Would write to:"

    for target in "${AGENTS_TARGETS[@]}"; do
        ensure_target_parent_exists "$target"
        if [[ "$target" == *"/opencode/"* ]]; then
            echo "  -> $target (OpenCode)"
        else
            echo "  -> $target (Codex)"
        fi
    done

    for target in "${CLAUDE_TARGETS[@]}"; do
        ensure_target_parent_exists "$target"
        echo "  -> $target (Claude Code)"
    done
}

while [ $# -gt 0 ]; do
    case "$1" in
        --targets-opencode)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                AGENTS_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-codex)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                AGENTS_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-claude)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                CLAUDE_TARGETS+=("$1")
                shift
            done
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: sync.sh [OPTIONS]"
            echo ""
            echo "Sync the canonical AGENTS.md to all coding agent configs."
            echo ""
            echo "Options:"
            echo "  --targets-opencode PATH   OpenCode AGENTS.md location"
            echo "  --targets-codex PATH      Codex AGENTS.md location"
            echo "  --targets-claude PATH     Claude Code CLAUDE.md location"
            echo "  --dry-run                 Show what would be synced without making changes"
            echo "  --help                    Show this help message"
            echo ""
            echo "Auto-detected locations:"
            echo "  OpenCode:   ~/.config/opencode/AGENTS.md"
            echo "  Codex:      ~/.codex/AGENTS.md"
            echo "  Claude:     ~/.claude/CLAUDE.md"
            exit 0
            ;;
        *)
            echo "Unknown option: $1. Use --help for usage." >&2
            exit 1
            ;;
    esac
done

[ ${#AGENTS_TARGETS[@]} -eq 0 ] && [ ${#CLAUDE_TARGETS[@]} -eq 0 ] && detect_targets

if [ "$DRY_RUN" = true ]; then
    dry_run_sync
else
    sync
fi

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE="$REPO_DIR/AGENTS.md"

AGENTS_TARGETS=()
CLAUDE_TARGETS=()
GEMINI_TARGETS=()
RULES_DIR_TARGETS=()
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

ensure_target_dir_creatable() {
    local target="$1"
    local parent
    parent="$(dirname "$target")"

    if [ ! -d "$parent" ]; then
        mkdir -p "$parent"
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

            # Single-file AGENTS.md targets
            [ -d "$home/.config/opencode" ] && AGENTS_TARGETS+=("$home/.config/opencode/AGENTS.md")
            [ -d "$home/.codex" ]          && AGENTS_TARGETS+=("$home/.codex/AGENTS.md")
            [ -d "$home/.config/amp" ]     && AGENTS_TARGETS+=("$home/.config/amp/AGENTS.md")
            [ -d "$home/.config/goose" ]  && AGENTS_TARGETS+=("$home/.config/goose/AGENTS.md")

            # Renamed single-file targets
            [ -d "$home/.claude" ] && CLAUDE_TARGETS+=("$home/.claude/CLAUDE.md")
            [ -d "$home/.gemini" ] && GEMINI_TARGETS+=("$home/.gemini/GEMINI.md")

            # Directory-based rules targets
            [ -d "$home/.roo" ]          && RULES_DIR_TARGETS+=("$home/.roo/rules/AGENTS.md")
            [ -d "$home/.augment" ]      && RULES_DIR_TARGETS+=("$home/.augment/rules/AGENTS.md")
            [ -d "$home/Documents/Cline" ] && RULES_DIR_TARGETS+=("$home/Documents/Cline/Rules/AGENTS.md")
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            home="${USERPROFILE:-${HOME:?}}"

            # Single-file AGENTS.md targets
            [ -d "$home/.config/opencode" ] && AGENTS_TARGETS+=("$home/.config/opencode/AGENTS.md")
            [ -d "$home/.codex" ]          && AGENTS_TARGETS+=("$home/.codex/AGENTS.md")
            [ -d "$home/.config/amp" ]     && AGENTS_TARGETS+=("$home/.config/amp/AGENTS.md")
            [ -d "$home/.config/goose" ]  && AGENTS_TARGETS+=("$home/.config/goose/AGENTS.md")

            # Renamed single-file targets
            [ -d "$home/.claude" ] && CLAUDE_TARGETS+=("$home/.claude/CLAUDE.md")
            [ -d "$home/.gemini" ] && GEMINI_TARGETS+=("$home/.gemini/GEMINI.md")

            # Directory-based rules targets
            [ -d "$home/.roo" ]             && RULES_DIR_TARGETS+=("$home/.roo/rules/AGENTS.md")
            [ -d "$home/.augment" ]         && RULES_DIR_TARGETS+=("$home/.augment/rules/AGENTS.md")
            [ -d "$home/Documents/Cline" ]  && RULES_DIR_TARGETS+=("$home/Documents/Cline/Rules/AGENTS.md")
            ;;
        *)
            echo "Unknown OS: $os. Specify targets with --targets-* flags." >&2
            ;;
    esac

    return 0
}

label_for_target() {
    local target="$1"
    case "$target" in
        *"/opencode/"*|*"/opencode"*)   echo "OpenCode" ;;
        *"/.codex/"*|*"/.codex"*)       echo "Codex CLI" ;;
        *"/amp/"*|*"/amp"*)             echo "Amp" ;;
        *"/.config/goose/"*|*"/.config/goose"*) echo "Goose" ;;
        *"/.claude/"*|*"/.claude"*)     echo "Claude Code" ;;
        *"/.gemini/"*|*"/.gemini"*)     echo "Gemini CLI" ;;
        *"/Cline/"*|*"/Cline"*)         echo "Cline" ;;
        *"/.roo/"*|*"/.roo"*)           echo "Roo Code / Kilo Code" ;;
        *"/.augment/"*|*"/.augment"*)   echo "Augment Code" ;;
        *)                              echo "$target" ;;
    esac
}

no_targets_found() {
    if [ ${#AGENTS_TARGETS[@]} -eq 0 ] && [ ${#CLAUDE_TARGETS[@]} -eq 0 ] && \
       [ ${#GEMINI_TARGETS[@]} -eq 0 ] && [ ${#RULES_DIR_TARGETS[@]} -eq 0 ]; then
        return 0
    fi
    return 1
}

sync() {
    ensure_source_exists

    if no_targets_found; then
        echo "No agent config directories found. Create them first or use --targets-* flags." >&2
        exit 1
    fi

    local total=0

    if [ ${#AGENTS_TARGETS[@]} -gt 0 ]; then
        for target in "${AGENTS_TARGETS[@]}"; do
            ensure_target_parent_exists "$target"
            echo "  -> $target ($(label_for_target "$target"))"
            cp "$SOURCE" "$target"
            total=$((total + 1))
        done
    fi

    if [ ${#CLAUDE_TARGETS[@]} -gt 0 ]; then
        for target in "${CLAUDE_TARGETS[@]}"; do
            ensure_target_parent_exists "$target"
            echo "  -> $target ($(label_for_target "$target"))"
            cp "$SOURCE" "$target"
            total=$((total + 1))
        done
    fi

    if [ ${#GEMINI_TARGETS[@]} -gt 0 ]; then
        for target in "${GEMINI_TARGETS[@]}"; do
            ensure_target_parent_exists "$target"
            echo "  -> $target ($(label_for_target "$target"))"
            cp "$SOURCE" "$target"
            total=$((total + 1))
        done
    fi

    if [ ${#RULES_DIR_TARGETS[@]} -gt 0 ]; then
        for target in "${RULES_DIR_TARGETS[@]}"; do
            ensure_target_dir_creatable "$target"
            echo "  -> $target ($(label_for_target "$target"))"
            cp "$SOURCE" "$target"
            total=$((total + 1))
        done
    fi

    echo "Synced to $total target(s)."
}

dry_run_sync() {
    ensure_source_exists

    if no_targets_found; then
        echo "No agent config directories found." >&2
        exit 1
    fi

    echo "Would write to:"

    if [ ${#AGENTS_TARGETS[@]} -gt 0 ]; then
        for target in "${AGENTS_TARGETS[@]}"; do
            echo "  -> $target ($(label_for_target "$target"))"
        done
    fi

    if [ ${#CLAUDE_TARGETS[@]} -gt 0 ]; then
        for target in "${CLAUDE_TARGETS[@]}"; do
            echo "  -> $target ($(label_for_target "$target"))"
        done
    fi

    if [ ${#GEMINI_TARGETS[@]} -gt 0 ]; then
        for target in "${GEMINI_TARGETS[@]}"; do
            echo "  -> $target ($(label_for_target "$target"))"
        done
    fi

    if [ ${#RULES_DIR_TARGETS[@]} -gt 0 ]; then
        for target in "${RULES_DIR_TARGETS[@]}"; do
            echo "  -> $target ($(label_for_target "$target"))"
        done
    fi
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
        --targets-amp)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                AGENTS_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-goose)
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
        --targets-gemini)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                GEMINI_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-roocode)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                RULES_DIR_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-cline)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                RULES_DIR_TARGETS+=("$1")
                shift
            done
            ;;
        --targets-augment)
            require_target_args "$@"
            shift
            while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
                RULES_DIR_TARGETS+=("$1")
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
            echo "  --targets-codex PATH      Codex CLI AGENTS.md location"
            echo "  --targets-amp PATH        Amp AGENTS.md location"
            echo "  --targets-goose PATH      Goose AGENTS.md location"
            echo "  --targets-claude PATH     Claude Code CLAUDE.md location"
            echo "  --targets-gemini PATH     Gemini CLI GEMINI.md location"
            echo "  --targets-roocode PATH    Roo Code global rules path"
            echo "  --targets-cline PATH      Cline global rules path"
            echo "  --targets-augment PATH    Augment Code global rules path"
            echo "  --dry-run                 Show what would be synced without making changes"
            echo "  --help                    Show this help message"
            echo ""
            echo "Auto-detected locations:"
            echo "  OpenCode:       ~/.config/opencode/AGENTS.md"
            echo "  Codex CLI:      ~/.codex/AGENTS.md"
            echo "  Amp:            ~/.config/amp/AGENTS.md"
            echo "  Goose:          ~/.config/goose/AGENTS.md"
            echo "  Claude Code:    ~/.claude/CLAUDE.md"
            echo "  Gemini CLI:     ~/.gemini/GEMINI.md"
            echo "  Roo Code:       ~/.roo/rules/AGENTS.md"
            echo "  Cline:          ~/Documents/Cline/Rules/AGENTS.md"
            echo "  Augment Code:   ~/.augment/rules/AGENTS.md"
            exit 0
            ;;
        *)
            echo "Unknown option: $1. Use --help for usage." >&2
            exit 1
            ;;
    esac
done

if no_targets_found; then
    detect_targets
fi

if [ "$DRY_RUN" = true ]; then
    dry_run_sync
else
    sync
fi

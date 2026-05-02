#!/usr/bin/env bash

set -euo pipefail

CODEX_HOME="${1:-$HOME/.codex}"

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="$SOURCE_ROOT/hooks/codex_terminal_state.sh"
SOURCE_HOOKS_JSON="$SOURCE_ROOT/hooks.arch.json"
SOURCE_LAUNCHER="$SOURCE_ROOT/bin/codex-terminal-state"

HOOKS_DIR="$CODEX_HOME/hooks"
TARGET_HOOK="$HOOKS_DIR/codex_terminal_state.sh"
TARGET_HOOKS_JSON="$CODEX_HOME/hooks.json"
TARGET_CONFIG="$CODEX_HOME/config.toml"
TARGET_BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
TARGET_LAUNCHER="$TARGET_BIN_DIR/codex-terminal-state"
STAMP="$(date +%Y%m%d-%H%M%S)"

backup_if_exists() {
    local path="$1"
    if [[ -f "$path" ]]; then
        cp "$path" "$path.bak-$STAMP"
    fi
}

mkdir -p "$HOOKS_DIR"
mkdir -p "$TARGET_BIN_DIR"

backup_if_exists "$TARGET_HOOK"
cp "$SOURCE_HOOK" "$TARGET_HOOK"
chmod +x "$TARGET_HOOK"

backup_if_exists "$TARGET_HOOKS_JSON"
cp "$SOURCE_HOOKS_JSON" "$TARGET_HOOKS_JSON"

backup_if_exists "$TARGET_LAUNCHER"
cp "$SOURCE_LAUNCHER" "$TARGET_LAUNCHER"
chmod +x "$TARGET_LAUNCHER"

if [[ ! -f "$TARGET_CONFIG" ]]; then
    : > "$TARGET_CONFIG"
else
    backup_if_exists "$TARGET_CONFIG"
fi

TMP_CONFIG="$(mktemp)"

awk '
BEGIN {
    in_features = 0
    in_tui = 0
    saw_features = 0
    saw_tui = 0
    set_codex_hooks = 0
    set_alternate_screen = 0
    set_terminal_title = 0
}
function leave_section() {
    if (in_features && !set_codex_hooks) {
        print "codex_hooks = true"
    }
    if (in_tui) {
        if (!set_alternate_screen) {
            print "alternate_screen = \"never\""
        }
        if (!set_terminal_title) {
            print "terminal_title = [\"run-state\", \"project-name\"]"
        }
    }
    in_features = 0
    in_tui = 0
}
/^\[[^]]+\][[:space:]]*$/ {
    leave_section()

    if ($0 == "[features]") {
        in_features = 1
        saw_features = 1
    } else if ($0 == "[tui]") {
        in_tui = 1
        saw_tui = 1
    }

    print
    next
}
in_features && /^[[:space:]]*codex_hooks[[:space:]]*=/ {
    if (!set_codex_hooks) {
        print "codex_hooks = true"
        set_codex_hooks = 1
    }
    next
}
in_tui && /^[[:space:]]*alternate_screen[[:space:]]*=/ {
    if (!set_alternate_screen) {
        print "alternate_screen = \"never\""
        set_alternate_screen = 1
    }
    next
}
in_tui && /^[[:space:]]*terminal_title[[:space:]]*=/ {
    if (!set_terminal_title) {
        print "terminal_title = [\"run-state\", \"project-name\"]"
        set_terminal_title = 1
    }
    next
}
{
    print
}
END {
    leave_section()

    if (!saw_features) {
        if (NR > 0) {
            print ""
        }
        print "[features]"
        print "codex_hooks = true"
    }

    if (!saw_tui) {
        print ""
        print "[tui]"
        print "alternate_screen = \"never\""
        print "terminal_title = [\"run-state\", \"project-name\"]"
    }
}
' "$TARGET_CONFIG" > "$TMP_CONFIG"

mv "$TMP_CONFIG" "$TARGET_CONFIG"

printf 'Installed Codex terminal state hooks for Arch/Linux.\n'
printf 'Ready = blue, working = your default terminal colors.\n'
printf 'Terminal colors reset on exit when launched through the wrapper.\n'
printf 'Launch with: %s\n' "$TARGET_LAUNCHER"

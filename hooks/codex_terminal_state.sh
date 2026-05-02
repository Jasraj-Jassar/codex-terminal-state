#!/usr/bin/env bash

set -euo pipefail

STATE="${1:-ready}"

LOG_PATH="${CODEX_TERMINAL_STATE_LOG_PATH:-$HOME/.codex/hooks/codex_terminal_state.log}"

mkdir -p "$(dirname "$LOG_PATH")"

write_log() {
    local message="$1"
    {
        printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S.%3N')" "$STATE" "$message"
    } >> "$LOG_PATH" 2>/dev/null || true
}

case "$STATE" in
    start-ready|ready)
        title="CODEX READY - BLUE"
        sequence=$'\033]11;#002B7F\a\033]12;#FFFFFF\a\033]0;CODEX READY - BLUE\a\033]2;CODEX READY - BLUE\a\033[97;44m'
        ;;
    busy)
        title="CODEX WORKING - BLACK"
        sequence=$'\033]11;#000000\a\033]12;#FFFFFF\a\033]0;CODEX WORKING - BLACK\a\033]2;CODEX WORKING - BLACK\a\033[97;40m'
        ;;
    *)
        write_log "ignored invalid state"
        printf '{"continue":true}\n'
        exit 0
        ;;
esac

write_log "started"

if { exec 3>/dev/tty; } 2>/dev/null; then
    printf '%s' "$sequence" >&3 || true
    exec 3>&-
    write_log "wrote ANSI/OSC sequence to /dev/tty with title=$title"
else
    write_log "skipped terminal write because /dev/tty is unavailable"
fi

printf '{"continue":true}\n'

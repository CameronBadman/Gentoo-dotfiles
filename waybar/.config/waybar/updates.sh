#!/bin/bash

set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates"
CACHE_FILE="$CACHE_DIR/status.json"
LOG_FILE="$CACHE_DIR/emerge.log"
LOCK_DIR="$CACHE_DIR/refresh.lock"
MAX_AGE_SECONDS="${WAYBAR_UPDATES_MAX_AGE_SECONDS:-1800}"
EMERGE_ARGS=(--update --deep --newuse --with-bdeps=y --pretend @world)

json_escape() {
    local value=${1:-}
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/}
    value=${value//$'\t'/\\t}
    printf '%s' "$value"
}

emit_json() {
    local text=$1 tooltip=$2 class=$3
    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$(json_escape "$text")" \
        "$(json_escape "$tooltip")" \
        "$(json_escape "$class")"
}

notify() {
    if command -v notify-send >/dev/null; then
        notify-send "$@"
    fi
}

terminal() {
    if command -v kitty >/dev/null; then
        printf 'kitty'
    elif command -v foot >/dev/null; then
        printf 'foot'
    elif command -v alacritty >/dev/null; then
        printf 'alacritty'
    elif command -v xterm >/dev/null; then
        printf 'xterm'
    fi
}

cache_is_fresh() {
    local now mtime age

    [ -s "$CACHE_FILE" ] || return 1
    now=$(date +%s)
    mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    age=$((now - mtime))
    [ "$age" -lt "$MAX_AGE_SECONDS" ]
}

refresh_cache() {
    local output exit_code count

    mkdir -p "$CACHE_DIR"

    if ! command -v emerge >/dev/null; then
        emit_json "󰏗" "emerge is not installed" "missing" >"$CACHE_FILE"
        return
    fi

    output=$(timeout 120 emerge "${EMERGE_ARGS[@]}" 2>&1)
    exit_code=$?
    printf '%s\n' "$output" >"$LOG_FILE"

    if [ "$exit_code" -ne 0 ]; then
        emit_json "󰏗 !" "Could not check updates"$'\n'"See $LOG_FILE" "error" >"$CACHE_FILE"
        return
    fi

    count=$(printf '%s\n' "$output" | grep -Ec '^\[ebuild')
    if [ "$count" -gt 0 ]; then
        emit_json "󰏗 $count" "$count Gentoo package updates available"$'\n'"Left: refresh  Right: emerge update" "pending" >"$CACHE_FILE"
    else
        emit_json "󰏗 0" "System packages are up to date"$'\n'"Left: refresh" "updated" >"$CACHE_FILE"
    fi
}

start_background_refresh() {
    mkdir -p "$CACHE_DIR"

    if mkdir "$LOCK_DIR" 2>/dev/null; then
        (
            refresh_cache
            rmdir "$LOCK_DIR" 2>/dev/null || true
        ) >/dev/null 2>&1 &
    fi
}

status_json() {
    if cache_is_fresh; then
        cat "$CACHE_FILE"
        return
    fi

    start_background_refresh
    if [ -s "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    else
        emit_json "󰏗 ..." "Checking Gentoo package updates in the background" "checking"
    fi
}

manual_refresh() {
    notify "Gentoo updates" "Checking @world updates..."
    refresh_cache
    notify "Gentoo updates" "Update check finished"
}

upgrade() {
    local term command

    term=$(terminal)
    if [ -z "$term" ]; then
        notify "Gentoo updates" "No supported terminal found"
        return 1
    fi

    command='sudo emerge --ask --update --deep --newuse --with-bdeps=y @world'
    case "$term" in
    kitty)
        kitty --hold sh -lc "$command"
        ;;
    foot)
        foot sh -lc "$command; printf \"\\nPress enter to close...\"; read -r _"
        ;;
    alacritty)
        alacritty -e sh -lc "$command; printf \"\\nPress enter to close...\"; read -r _"
        ;;
    xterm)
        xterm -e sh -lc "$command; printf \"\\nPress enter to close...\"; read -r _"
        ;;
    esac
}

case "${1:-status}" in
status)
    status_json
    ;;
refresh)
    manual_refresh
    ;;
upgrade)
    upgrade
    ;;
*)
    echo "Usage: $0 {status|refresh|upgrade}" >&2
    exit 1
    ;;
esac

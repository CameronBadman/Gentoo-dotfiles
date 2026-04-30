#!/bin/bash

set -u

PLAYER="${SPOTIFY_PLAYER:-}"
MAX_TEXT_LENGTH="${SPOTIFY_MAX_TEXT_LENGTH:-64}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-spotify"

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
    local text=$1 tooltip=$2 class=$3 percentage=${4:-}

    if [[ "$percentage" =~ ^[0-9]+$ ]]; then
        printf '{"text": "%s", "tooltip": "%s", "class": "%s", "percentage": %s}\n' \
            "$(json_escape "$text")" \
            "$(json_escape "$tooltip")" \
            "$(json_escape "$class")" \
            "$percentage"
    else
        printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
            "$(json_escape "$text")" \
            "$(json_escape "$tooltip")" \
            "$(json_escape "$class")"
    fi
}

notify() {
    if command -v notify-send >/dev/null; then
        notify-send "$@"
    fi
}

spotify_player() {
    local player

    if [ -n "$PLAYER" ]; then
        printf '%s' "$PLAYER"
        return
    fi

    player=$(playerctl -l 2>/dev/null | grep -i -m 1 'spotify' || true)
    printf '%s' "${player:-spotify}"
}

playerctl_spotify() {
    playerctl --player="$(spotify_player)" "$@" 2>/dev/null
}

metadata() {
    playerctl_spotify metadata --format "$1" || true
}

truncate_text() {
    local value=$1 max_length=$2

    if [ "${#value}" -le "$max_length" ]; then
        printf '%s' "$value"
    else
        printf '%s...' "${value:0:$((max_length - 3))}"
    fi
}

format_duration() {
    local seconds=$1
    seconds=${seconds%.*}

    if ! [[ "$seconds" =~ ^[0-9]+$ ]]; then
        printf ''
        return
    fi

    printf '%d:%02d' "$((seconds / 60))" "$((seconds % 60))"
}

progress_chip() {
    local percentage=$1 segments=5 filled empty i output

    if ! [[ "$percentage" =~ ^[0-9]+$ ]]; then
        return
    fi

    filled=$(((percentage * segments + 99) / 100))
    if [ "$percentage" -eq 0 ]; then
        filled=0
    fi
    if [ "$filled" -gt "$segments" ]; then
        filled=$segments
    fi

    empty=$((segments - filled))
    output=""
    for ((i = 0; i < filled; i++)); do
        output="${output}●"
    done
    for ((i = 0; i < empty; i++)); do
        output="${output}·"
    done
    printf '%s' "$output"
}

cover_path() {
    local art_url=$1 cache_name cache_file

    if [ -z "$art_url" ]; then
        return 1
    fi

    case "$art_url" in
    file://*)
        printf '%s\n' "${art_url#file://}"
        ;;
    http://* | https://*)
        if ! command -v curl >/dev/null || ! command -v sha256sum >/dev/null; then
            return 1
        fi

        mkdir -p "$CACHE_DIR"
        cache_name=$(printf '%s' "$art_url" | sha256sum | cut -d ' ' -f 1)
        cache_file="$CACHE_DIR/$cache_name.jpg"

        if [ ! -s "$cache_file" ]; then
            curl -LsSf -o "$cache_file" "$art_url" || return 1
        fi

        printf '%s\n' "$cache_file"
        ;;
    *)
        return 1
        ;;
    esac
}

show_cover() {
    local status artist title album art_url icon message

    if ! command -v playerctl >/dev/null; then
        notify "Spotify" "playerctl is not installed"
        return
    fi

    status=$(playerctl_spotify status) || {
        notify "Spotify" "Spotify is not running"
        return
    }

    artist=$(metadata '{{artist}}')
    title=$(metadata '{{title}}')
    album=$(metadata '{{album}}')
    art_url=$(metadata '{{mpris:artUrl}}')
    icon=$(cover_path "$art_url" || true)

    if [ -z "$title" ]; then
        title="Spotify"
    fi

    message="${artist:-Unknown artist}"
    if [ -n "$album" ]; then
        message="$message"$'\n'"$album"
    fi
    message="$message"$'\n'"$status"

    if [ -n "$icon" ] && [ -f "$icon" ]; then
        notify -i "$icon" "$title" "$message"
    else
        notify "$title" "$message"
    fi
}

status_json() {
    local status artist title album position length_us length_seconds elapsed duration
    local track text tooltip class progress percentage chip position_seconds progress_label

    if ! command -v playerctl >/dev/null; then
        emit_json "" "playerctl is not installed" "missing"
        return
    fi

    status=$(playerctl_spotify status) || {
        emit_json "" "Spotify is not running" "stopped"
        return
    }

    artist=$(metadata '{{artist}}')
    title=$(metadata '{{title}}')
    album=$(metadata '{{album}}')
    position=$(playerctl_spotify position || true)
    length_us=$(playerctl_spotify metadata mpris:length || true)

    if [ -z "$title" ] && [ -z "$artist" ]; then
        emit_json " $status" "Spotify is $status" "$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
        return
    fi

    if [ -n "$artist" ] && [ -n "$title" ]; then
        track="$artist - $title"
    else
        track="${title:-$artist}"
    fi

    elapsed=$(format_duration "$position")
    duration=""
    if [[ "$length_us" =~ ^[0-9]+$ ]] && [ "$length_us" -gt 0 ]; then
        length_seconds=$((length_us / 1000000))
        duration=$(format_duration "$length_seconds")
        position_seconds=${position%.*}
        if [[ "$position_seconds" =~ ^[0-9]+$ ]] && [ "$length_seconds" -gt 0 ]; then
            percentage=$((position_seconds * 100 / length_seconds))
            if [ "$percentage" -gt 100 ]; then
                percentage=100
            fi
        fi
    fi

    progress=""
    if [ -n "$elapsed" ] && [ -n "$duration" ]; then
        progress="$elapsed / $duration"
    fi

    class=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')
    chip=$(progress_chip "${percentage:-}" || true)
    progress_label=""
    if [ -n "$elapsed" ] && [ -n "$chip" ]; then
        progress_label="  $elapsed $chip"
    elif [ -n "$elapsed" ]; then
        progress_label="  $elapsed"
    fi

    if [ "$class" = "paused" ]; then
        text=" 󰏤 $(truncate_text "$track" "$MAX_TEXT_LENGTH")$progress_label"
    else
        text=" 󰐊 $(truncate_text "$track" "$MAX_TEXT_LENGTH")$progress_label"
    fi
    tooltip="$track"

    if [ -n "$album" ]; then
        tooltip="$tooltip"$'\n'"$album"
    fi

    tooltip="$tooltip"$'\n'"$status"
    if [ -n "$progress" ]; then
        tooltip="$tooltip - $progress"
    fi
    tooltip="$tooltip"$'\n'"Left: play/pause  Middle: cover  Right/Scroll up: next  Scroll down: previous"

    emit_json "$text" "$tooltip" "$class" "${percentage:-}"
}

case "${1:-status}" in
status)
    status_json
    ;;
play-pause | toggle)
    playerctl_spotify play-pause
    ;;
next)
    playerctl_spotify next
    ;;
previous | prev)
    playerctl_spotify previous
    ;;
cover | art)
    show_cover
    ;;
*)
    echo "Usage: $0 {status|play-pause|next|previous|cover}" >&2
    exit 1
    ;;
esac

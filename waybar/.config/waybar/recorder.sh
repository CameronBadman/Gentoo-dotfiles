#!/bin/bash

set -u

VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/waybar-recorder"
LOG_FILE="$STATE_DIR/wf-recorder.log"
OUTPUT_EXT="mp4"
VIDEO_CODEC="libx264"
PIXEL_FORMAT="yuv420p"
MIN_SELECTION_SIZE=32
VIDEO_CODEC_PARAMS=(
    -p "preset=veryfast"
    -p "crf=23"
)

mkdir -p "$VIDEOS_DIR" "$STATE_DIR"

notify() {
    if command -v notify-send >/dev/null; then
        notify-send "$1" "$2" || echo "Notification failed: $1 - $2" >&2
    else
        echo "notify-send not found: $1 - $2" >&2
    fi
}

is_recording() {
    pgrep -x "wf-recorder" >/dev/null
}

recording_elapsed() {
    local pid elapsed

    pid=$(pgrep -xo "wf-recorder" || true)
    if [ -z "$pid" ]; then
        return
    fi

    elapsed=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
    if ! [[ "$elapsed" =~ ^[0-9]+$ ]]; then
        return
    fi

    if [ "$elapsed" -ge 3600 ]; then
        printf '%d:%02d:%02d' "$((elapsed / 3600))" "$(((elapsed % 3600) / 60))" "$((elapsed % 60))"
    else
        printf '%02d:%02d' "$((elapsed / 60))" "$((elapsed % 60))"
    fi
}

status_json() {
    local elapsed

    if is_recording; then
        elapsed=$(recording_elapsed)
        echo "{\"text\": \" ${elapsed:-00:00}\", \"tooltip\": \"Recording for ${elapsed:-00:00}\", \"class\": \"recording\"}"
    else
        echo '{"text": "", "tooltip": "Start Recording", "class": "stopped"}'
    fi
}

ensure_dependencies() {
    if ! command -v wf-recorder >/dev/null; then
        notify "Screen Recording" "wf-recorder not found. Please install it."
        exit 1
    fi

    if ! command -v ffmpeg >/dev/null; then
        notify "Screen Recording" "ffmpeg not found. Please install it."
        exit 1
    fi

    if ! ffmpeg -hide_banner -muxers 2>/dev/null | grep -Eq '^[[:space:]]*E[[:space:]]+mp4[[:space:]]'; then
        notify "Screen Recording" "ffmpeg is missing the mp4 muxer."
        exit 1
    fi
}

get_audio_source() {
    local configured_source default_source

    configured_source="${WF_RECORDER_AUDIO_SOURCE:-}"
    if [ -n "$configured_source" ]; then
        printf '%s\n' "$configured_source"
        return 0
    fi

    if command -v pactl >/dev/null; then
        default_source=$(pactl get-default-source 2>/dev/null || true)
        if [ -z "$default_source" ]; then
            default_source=$(
                pactl info 2>/dev/null |
                    sed -n 's/^Default Source: //p' |
                    head -n 1
            )
        fi

        if [ -n "$default_source" ]; then
            printf '%s\n' "$default_source"
            return 0
        fi
    fi

    return 1
}

start_recording() {
    local output_file geometry pid width height size audio_source
    output_file="$VIDEOS_DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).$OUTPUT_EXT"
    audio_source=$(get_audio_source) || {
        notify "Screen Recording" "Could not determine the default audio source."
        exit 1
    }

    if command -v slurp >/dev/null; then
        geometry=$(slurp 2>/dev/null)
        if [ -z "$geometry" ]; then
            notify "Screen Recording" "Cancelled"
            return 0
        fi

        size="${geometry##* }"
        width="${size%x*}"
        height="${size#*x}"

        if ! [[ "$width" =~ ^[0-9]+$ && "$height" =~ ^[0-9]+$ ]]; then
            notify "Screen Recording" "Invalid selection: $geometry"
            exit 1
        fi

        if [ "$width" -lt "$MIN_SELECTION_SIZE" ] || [ "$height" -lt "$MIN_SELECTION_SIZE" ]; then
            notify "Screen Recording" "Selection too small. Drag a larger area."
            exit 1
        fi

        wf-recorder --audio-backend=pipewire --no-dmabuf -c "$VIDEO_CODEC" -x "$PIXEL_FORMAT" \
            "${VIDEO_CODEC_PARAMS[@]}" --audio="$audio_source" -g "$geometry" -f "$output_file" \
            >"$LOG_FILE" 2>&1 &
    else
        wf-recorder --audio-backend=pipewire --no-dmabuf -c "$VIDEO_CODEC" -x "$PIXEL_FORMAT" \
            "${VIDEO_CODEC_PARAMS[@]}" --audio="$audio_source" -f "$output_file" \
            >"$LOG_FILE" 2>&1 &
    fi

    pid=$!
    sleep 1

    if kill -0 "$pid" 2>/dev/null; then
        notify "Screen Recording" "Started: $(basename "$output_file") using ${audio_source##*.}"
    else
        notify "Screen Recording" "Failed to start. See $LOG_FILE"
        tail -n 20 "$LOG_FILE" >&2
        exit 1
    fi
}

stop_recording() {
    if is_recording; then
        pkill -SIGINT -x wf-recorder
        notify "Screen Recording" "Stopped"
    else
        notify "Screen Recording" "No active recording"
    fi
}

case "${1:-status}" in
status)
    status_json
    ;;
toggle)
    ensure_dependencies
    if is_recording; then
        stop_recording
    else
        start_recording
    fi
    ;;
*)
    echo "Usage: $0 {status|toggle}" >&2
    exit 1
    ;;
esac

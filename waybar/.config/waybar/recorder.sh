#!/bin/bash

VIDEOS_DIR="$HOME/Videos"
mkdir -p "$VIDEOS_DIR"

notify() {
    if command -v notify-send >/dev/null; then
        notify-send "$1" "$2" || echo "Notification failed: $1 - $2" >&2
    else
        echo "notify-send not found: $1 - $2" >&2
    fi
}

case "$1" in
status)
    if pgrep -x "wf-recorder" >/dev/null; then
        echo '{"text": "", "tooltip": "Recording...", "class": "recording"}'
    else
        echo '{"text": "", "tooltip": "Start Recording", "class": "stopped"}'
    fi
    ;;
toggle)
    if ! command -v wf-recorder >/dev/null; then
        notify "Screen Recording" "wf-recorder not found. Please install."
        exit 1
    fi

    if pgrep -x "wf-recorder" >/dev/null; then
        pkill -SIGINT wf-recorder
        notify "Screen Recording" "Stopped"
    else
        # check if slurp is available
        if command -v slurp >/dev/null; then
            geometry=$(slurp)
            if [ -n "$geometry" ]; then
                wf-recorder -a -g "$geometry" -f "$VIDEOS_DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4" &
                notify "Screen Recording" "Started"
            else
                 notify "Screen Recording" "Cancelled"
            fi
        else
            wf-recorder -a -f "$VIDEOS_DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4" &
            notify "Screen Recording" "Started (Fullscreen)"
        fi
    fi
    ;;
esac

#!/bin/bash

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

notify() {
    if command -v notify-send >/dev/null; then
        notify-send "$1" "$2" || echo "Notification failed: $1 - $2" >&2
    else
        echo "notify-send not found: $1 - $2" >&2
    fi
}

case "$1" in
status)
    echo '{"text": "", "tooltip": "Take Screenshot", "class": "ready"}'
    ;;
capture)
    if ! command -v grim >/dev/null; then
        notify "Screenshot" "grim not found. Please install."
        exit 1
    fi

    screenshot_file="$SCREENSHOTS_DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

    if command -v slurp >/dev/null; then
        geometry=$(slurp)
        if [ -z "$geometry" ]; then
            notify "Screenshot" "Cancelled"
            exit 0
        fi
        if grim -g "$geometry" "$screenshot_file"; then
            notify "Screenshot" "Saved to $screenshot_file"
        else
            notify "Screenshot" "Capture failed"
            exit 1
        fi
    else
        if grim "$screenshot_file"; then
            notify "Screenshot" "Saved to $screenshot_file"
        else
            notify "Screenshot" "Capture failed"
            exit 1
        fi
    fi
    ;;
esac

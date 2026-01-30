#!/bin/bash

# Get battery info
capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

# Calculate time remaining
if [ -f /sys/class/power_supply/BAT0/power_now ] && [ -f /sys/class/power_supply/BAT0/energy_now ]; then
    power_now=$(cat /sys/class/power_supply/BAT0/power_now)
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)

    if [ "$power_now" -gt 0 ]; then
        # Calculate total minutes remaining
        total_minutes=$(( (energy_now * 60) / power_now ))
        hours=$(( total_minutes / 60 ))
        minutes=$(( total_minutes % 60 ))
        time_str="${hours}h ${minutes}m"
    else
        time_str="Calculating..."
    fi
else
    time_str="N/A"
fi

# Display with dunstify
if command -v dunstify &> /dev/null; then
    dunstify -u low -t 3000 "Battery Status" "$status: ${capacity}%\nTime: ${time_str}"
else
    echo "Battery: ${capacity}% - ${status} - ${time_str}"
fi

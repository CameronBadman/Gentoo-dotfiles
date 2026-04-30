#!/bin/bash

set -u

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

active_vpn() {
    nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null |
        awk -F: 'BEGIN{IGNORECASE=1} $2 ~ /vpn|wireguard/ || $1 ~ /proton|vpn/ {print $1; exit}'
}

saved_vpn() {
    nmcli -t -f NAME,TYPE connection show 2>/dev/null |
        awk -F: 'BEGIN{IGNORECASE=1} $2 ~ /vpn|wireguard/ || $1 ~ /proton|vpn/ {print $1; exit}'
}

status_json() {
    local active tooltip

    if ! command -v nmcli >/dev/null; then
        emit_json "󰖂" "nmcli is not installed" "missing"
        return
    fi

    if ! nmcli general status >/dev/null 2>&1; then
        emit_json "󰖂 !" "Could not query NetworkManager" "error"
        return
    fi

    active=$(active_vpn || true)
    if [ -n "$active" ]; then
        tooltip="VPN connected"$'\n'"$active"$'\n'"Left: disconnect  Right: NetworkManager"
        emit_json "󰖂 VPN" "$tooltip" "connected"
    else
        tooltip="VPN disconnected"$'\n'"Left: connect Proton/VPN profile  Right: NetworkManager"
        emit_json "󰖂 VPN" "$tooltip" "disconnected"
    fi
}

toggle_vpn() {
    local active saved

    if ! nmcli general status >/dev/null 2>&1; then
        notify "VPN" "Could not query NetworkManager"
        return 1
    fi

    active=$(active_vpn || true)
    if [ -n "$active" ]; then
        nmcli connection down "$active" && notify "VPN" "Disconnected $active"
        return
    fi

    saved=$(saved_vpn || true)
    if [ -z "$saved" ]; then
        notify "VPN" "No Proton/VPN NetworkManager profile found"
        return 1
    fi

    nmcli connection up "$saved" && notify "VPN" "Connected $saved"
}

open_manager() {
    if command -v nm-connection-editor >/dev/null; then
        nm-connection-editor
    else
        notify "VPN" "nm-connection-editor is not installed"
    fi
}

case "${1:-status}" in
status)
    status_json
    ;;
toggle)
    toggle_vpn
    ;;
manager)
    open_manager
    ;;
*)
    echo "Usage: $0 {status|toggle|manager}" >&2
    exit 1
    ;;
esac

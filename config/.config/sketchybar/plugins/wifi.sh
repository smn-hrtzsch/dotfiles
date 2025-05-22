#!/bin/bash

# Pfad zum airport-Tool
AIRPORT_PATH="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

# Dynamische Ermittlung des WLAN-Interfaces (oft en0)
WIFI_IF=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $NF}')

# Initialisierung der Variablen
ICON="􀙈" # Standard: WLAN getrennt / kein Adapter
LABEL="N/A"

# Prüfen, ob ein WLAN-Adapter gefunden wurde
if [ -z "$WIFI_IF" ]; then
    sketchybar --set "$NAME" icon="$ICON" label="No Wi-Fi"
    exit 0
fi

# WLAN-Informationen abrufen
# Die Ausgabe von airport -I enthält Details wie SSID und State
WIFI_INFO=$("$AIRPORT_PATH" -I 2>/dev/null) # 2>/dev/null unterdrückt Fehlermeldungen, falls airport nicht verfügbar ist

# SSID aus den Informationen extrahieren
SSID=$(echo "$WIFI_INFO" | grep 'SSID:' | awk '{print $NF}')

# Prüfen, ob eine SSID gefunden wurde (Indikator für verbundene Netzwerk)
if [ -n "$SSID" ]; then
    ICON="􀙇" # WLAN verbunden Icon (SF Symbol)
    LABEL="$SSID"
else
    # WLAN ist nicht verbunden oder ausgeschaltet
    # Wir können noch prüfen, ob der Adapter überhaupt aktiv ist (State: running)
    STATE=$(echo "$WIFI_INFO" | grep 'State:' | awk '{print $NF}')
    if [[ "$STATE" == "running" ]]; then
        LABEL="Not Connected" # Adapter ist an, aber nicht verbunden
    else
        LABEL="Wi-Fi Off" # Adapter ist aus
    fi
    ICON="􀙈" # WLAN getrennt Icon (SF Symbol)
fi

# SketchyBar aktualisieren
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
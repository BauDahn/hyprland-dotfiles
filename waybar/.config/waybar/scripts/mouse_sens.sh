#!/bin/bash

# Sensibilidad guardada por sens_slider.py (Hyprland no la expone por dispositivo)
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/mouse-sensitivity"
sens=$(cat "$STATE" 2>/dev/null)
if [[ -z "$sens" ]]; then sens=-0.2; fi

# Fórmula: ((sensibilidad + 1) / 2) * 100
percent=$(awk -v s="$sens" 'BEGIN { printf "%.0f", (s + 1) / 2 * 100 }')

# Imprime el resultado para Waybar
echo "{\"text\": \"$percent%\", \"tooltip\": \"Sensibilidad real: $sens\", \"percentage\": $percent}"

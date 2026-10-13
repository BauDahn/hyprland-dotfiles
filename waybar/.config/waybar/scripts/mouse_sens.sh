#!/bin/bash

DEVICE="logitech-usb-receiver"

# Obtiene el valor decimal del Logitech
sens=$(hyprctl getoption "device[$DEVICE]:sensitivity" -j 2>/dev/null | jq -r '.float')
if [[ -z "$sens" || "$sens" == "null" ]]; then sens=0; fi

# Fórmula: ((sensibilidad + 1) / 2) * 100
percent=$(echo "scale=0; (($sens + 1) / 2) * 100 / 1" | bc)

# Imprime el resultado para Waybar
echo "{\"text\": \"$percent%\", \"tooltip\": \"Sensibilidad real: $sens\", \"percentage\": $percent}"

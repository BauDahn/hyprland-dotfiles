#!/bin/bash

# Forzamos el uso del punto como separador decimal
export LC_NUMERIC=C

# Nombre exacto de tu ratón
DEVICE="logitech-usb-receiver"

# Leer sensibilidad actual del dispositivo específico
# (Si falla porque nunca se ha cambiado, asumimos que es 0 por defecto)
current=$(hyprctl getoption "device[$DEVICE]:sensitivity" -j 2>/dev/null | jq -r '.float')
if [[ -z "$current" || "$current" == "null" ]]; then
    current=0
fi

# Convertir el decimal a entero para el slider
current_int=$(awk -v c="$current" 'BEGIN { printf "%.0f", c*100 }')

# Lanzar el slider de YAD
yad --scale \
    --mouse \
    --width=250 \
    --title="Sensibilidad" \
    --on-top \
    --undecorated \
    --close-on-unfocus \
    --print-partial \
    --value="$current_int" \
    --min-value=-100 \
    --max-value=100 | while read -r val; do
        if [[ -n "$val" ]]; then
            # Convertimos el número de la barra a decimal
            new_sens=$(awk -v v="$val" 'BEGIN { printf "%.2f", v/100 }')
            # Aplicamos el cambio al dispositivo específico con la sintaxis correcta
            hyprctl keyword "device[$DEVICE]:sensitivity" "$new_sens"
        fi
done

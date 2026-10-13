#!/usr/bin/env bash
# SUPER+TAB: abre/cierra el overview
pkill -f "overview/overview.py" && exit 0
exec python3 ~/.config/overview/overview.py

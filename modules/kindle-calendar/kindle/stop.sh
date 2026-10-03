#!/usr/bin/env sh
pkill -f dash.sh
lipc-set-prop com.lab126.pillow disableEnablePillow enable >/dev/null 2>&1 || true

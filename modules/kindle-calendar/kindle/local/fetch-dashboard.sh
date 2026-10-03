#!/usr/bin/env sh
# Fetch a new dashboard image, make sure to output it to "$1".
"$(dirname "$0")/../xh" -d -q -o "$1" get http://192.168.1.236:8088/calendar.png

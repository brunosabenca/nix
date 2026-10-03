#!/usr/bin/env sh

# Export environment variables here
export WIFI_TEST_IP=${WIFI_TEST_IP:-192.168.1.1}
# Every 30 minutes, 06:00-22:30.
export REFRESH_SCHEDULE=${REFRESH_SCHEDULE:-"0,30 6-22 * * *"}
export TIMEZONE=${TIMEZONE:-"Europe/London"}

# Full e-ink refresh every Nth update to clear ghosting.
export FULL_DISPLAY_REFRESH_RATE=${FULL_DISPLAY_REFRESH_RATE:-4}

# Keep showing the calendar overnight instead of kindle-dash's "sleeping"
# screen (it appears when the next wakeup is at least this many seconds away).
export SLEEP_SCREEN_INTERVAL=86400

export LOW_BATTERY_REPORTING=false

#!/usr/bin/env sh
DEBUG=${DEBUG:-false}
[ "$DEBUG" = true ] && set -x

DIR="$(dirname "$0")"
DASH_PNG="$DIR/dash.png"
FETCH_DASHBOARD_CMD="$DIR/local/fetch-dashboard.sh"
LOW_BATTERY_CMD="$DIR/local/low-battery.sh"

REFRESH_SCHEDULE=${REFRESH_SCHEDULE:-"2,32 8-17 * * MON-FRI"}
FULL_DISPLAY_REFRESH_RATE=${FULL_DISPLAY_REFRESH_RATE:-0}
SLEEP_SCREEN_INTERVAL=${SLEEP_SCREEN_INTERVAL:-3600}
RTC=/sys/devices/platform/mxc_rtc.0/wakeup_enable

LOW_BATTERY_REPORTING=${LOW_BATTERY_REPORTING:-false}
LOW_BATTERY_THRESHOLD_PERCENT=${LOW_BATTERY_THRESHOLD_PERCENT:-10}

num_refresh=0

# Stop the Kindle UI so nothing (status bar, clock) draws over the image.
# Firmware 5.x on a Paperwhite 3 uses Upstart, where the UI is the lab126_gui
# job; there is no /etc/init.d/framework. Stopping pillow alone is not enough
# since FW 5.7.2: the clock keeps refreshing (see koreader.sh).
stop_gui() {
  if [ -x /etc/init.d/framework ]; then
    /etc/init.d/framework stop
  else
    # The job sends SIGTERM to its children on stop; ignore it so we are not
    # killed when launched from KUAL.
    trap "" TERM
    stop lab126_gui
    usleep 1250000 # let the teardown finish
    trap - TERM
  fi
}

# The Paperwhite 3 cannot turn its frontlight fully off through lipc: setting
# flIntensity to 0 only drops it to the dimmest "on" step, and the light comes
# back at that step on every resume (KOReader: canTurnFrontlightOff = no). Do
# both, like KOReader does, and write 0 to the backlight sysfs file(s) directly.
light_off() {
  lipc-set-prop com.lab126.powerd flIntensity 0 >/dev/null 2>&1 || true
  for f in /sys/class/backlight/*/brightness; do
    [ -e "$f" ] && echo 0 >"$f" 2>/dev/null
  done
  return 0
}

backlight_level() {
  cat /sys/class/backlight/*/brightness 2>/dev/null | tr '\n' ' '
}

init() {
  if [ -z "$TIMEZONE" ] || [ -z "$REFRESH_SCHEDULE" ]; then
    echo "Missing required configuration."
    echo "Timezone: ${TIMEZONE:-(not set)}."
    echo "Schedule: ${REFRESH_SCHEDULE:-(not set)}."
    exit 1
  fi

  echo "Starting dashboard with $REFRESH_SCHEDULE refresh..."

  stop_gui
  initctl stop webreader >/dev/null 2>&1
  echo powersave >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  lipc-set-prop com.lab126.powerd preventScreenSaver 1
  light_off
}

prepare_sleep() {
  echo "Preparing sleep"

  /usr/sbin/eips -f -g "$DIR/sleeping.png"

  # Give screen time to refresh
  sleep 2

  # Ensure a full screen refresh is triggered after wake from sleep
  num_refresh=$FULL_DISPLAY_REFRESH_RATE
}

refresh_dashboard() {
  echo "Refreshing dashboard"
  "$DIR/wait-for-wifi.sh" "$WIFI_TEST_IP"

  "$FETCH_DASHBOARD_CMD" "$DASH_PNG"
  fetch_status=$?

  if [ "$fetch_status" -ne 0 ]; then
    echo "Not updating screen, fetch-dashboard returned $fetch_status"
    return 1
  fi

  if [ "$num_refresh" -eq "$FULL_DISPLAY_REFRESH_RATE" ]; then
    num_refresh=0

    # trigger a full refresh once in every 4 refreshes, to keep the screen clean
    echo "Full screen refresh"
    /usr/sbin/eips -f -g "$DASH_PNG"
  else
    echo "Partial screen refresh"
    /usr/sbin/eips -g "$DASH_PNG"
  fi

  num_refresh=$((num_refresh + 1))
}

log_battery_stats() {
  battery_level=$(gasgauge-info -c)
  echo "$(date) Battery level: $battery_level."

  if [ "$LOW_BATTERY_REPORTING" = true ]; then
    battery_level_numeric=${battery_level%?}
    if [ "$battery_level_numeric" -le "$LOW_BATTERY_THRESHOLD_PERCENT" ]; then
      "$LOW_BATTERY_CMD" "$battery_level_numeric"
    fi
  fi
}

# This Kindle (i.MX6) exposes the standard Linux RTC wakealarm interface, not
# the old mxc_rtc wakeup_enable file kindle-dash was written for.
find_rtc() {
  for d in /sys/class/rtc/rtc*; do
    if grep -qi snvs "$d/name" 2>/dev/null; then
      echo "$d"
      return
    fi
  done
  echo /sys/class/rtc/rtc0
}

rtc_sleep() {
  duration=$1

  if [ "$DEBUG" = true ]; then
    sleep "$duration"
    return
  fi

  rtc=$(find_rtc)
  echo 0 >"$rtc/wakealarm"
  echo "+$duration" >"$rtc/wakealarm"

  # Only suspend when the wake alarm is really armed, otherwise the Kindle
  # would never wake up again.
  if [ -n "$(cat "$rtc/wakealarm" 2>/dev/null)" ]; then
    echo "mem" >/sys/power/state
  else
    echo "Could not arm $rtc/wakealarm, sleeping without suspend"
    sleep "$duration"
  fi
}

main_loop() {
  while true; do
    # Straight after a wake: log what the light was restored to, then kill it.
    echo "Backlight on wake: $(backlight_level)"
    light_off
    log_battery_stats

    next_wakeup_secs=$("$DIR/next-wakeup" --schedule="$REFRESH_SCHEDULE" --timezone="$TIMEZONE")

    if [ "$next_wakeup_secs" -gt "$SLEEP_SCREEN_INTERVAL" ]; then
      action="sleep"
      prepare_sleep
    else
      action="suspend"
      refresh_dashboard
    fi

    # take a bit of time before going to sleep, so this process can be aborted
    sleep 10

    echo "Going to $action, next wakeup in ${next_wakeup_secs}s"
    light_off

    rtc_sleep "$next_wakeup_secs"
  done
}

init
main_loop

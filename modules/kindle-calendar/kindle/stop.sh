#!/usr/bin/env sh
pkill -f dash.sh
# Bring the Kindle UI back (it was stopped by dash.sh).
if [ -x /etc/init.d/framework ]; then
  /etc/init.d/framework start
else
  start lab126_gui
fi

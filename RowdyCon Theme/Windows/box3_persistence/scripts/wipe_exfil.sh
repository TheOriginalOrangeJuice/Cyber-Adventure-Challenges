#!/bin/sh
EXFIL_DIR="/home/windowsRCC3/Exfiltrate"
STATE_DIR="/opt/task_flags"

if [ -f "$STATE_DIR/wipe_exfil.disabled" ] || [ -f "$STATE_DIR/wipe_exfil.removed" ]; then
  exit 0
fi

if [ -d "$EXFIL_DIR" ]; then
  find "$EXFIL_DIR" -mindepth 1 -delete
fi

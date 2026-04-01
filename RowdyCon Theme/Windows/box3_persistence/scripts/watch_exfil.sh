#!/bin/sh
EXFIL_DIR="/home/windowsRCC3/Exfiltrate"
STATE_DIR="/opt/task_flags"
FLAG_MESSAGE="RCC{persistence_task_defused}"
TARGET_FILE="$EXFIL_DIR/fad2v0be-5p0b-29c8-bh60-1f82ccb94abb.bin"

if [ -d "$EXFIL_DIR" ] && [ -f "$TARGET_FILE" ]; then
  echo "Flag: $FLAG_MESSAGE" | tee "/home/windowsRCC3/flag.txt" | wall
fi

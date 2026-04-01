#!/bin/bash
set -e

EVIDENCE_DIR="/home/linuxRCC2/evidence"
TARGET_FILE="${EVIDENCE_DIR}/log_067_2025-12-17_proxy.log"
FLAG_VALUE="RCC{seaching_through_files_just_got_a_lot_easier}"
TARGET_HASH="38c52efc34dde052ed9abae002fa5361"

check_and_echo() {
    if [ -f "${TARGET_FILE}" ]; then
        current_hash=$(md5sum "${TARGET_FILE}" | awk '{print $1}')
        if [ "${current_hash}" = "${TARGET_HASH}" ]; then
            if [ -w "/dev/pts/0" ]; then
                echo "${FLAG_VALUE}" > "/dev/pts/0" && echo "${FLAG_VALUE}" > "/dev/pts/1" 
            fi
        fi
    fi
}

# Run checks every 5 seconds for one minute (cron will restart this each minute).
for _ in {1..12}; do
    check_and_echo
    sleep 5
done

#Needs to use Md5sum  testing

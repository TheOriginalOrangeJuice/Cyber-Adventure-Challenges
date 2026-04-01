#!/bin/bash
EXPECTED_OWNER="mahi_mohashin"
SCRIPT_PATH="$(readlink -f "$0")"

current_owner="$(stat -c %U "${SCRIPT_PATH}")"
if [ "${current_owner}" != "${EXPECTED_OWNER}" ]; then
    echo "Access denied: script must be owned by ${EXPECTED_OWNER} (current: ${current_owner})."
    exit 1
fi

if [ ! -x "${SCRIPT_PATH}" ]; then
    echo "Execution blocked: script is not executable."
    exit 1
fi

cat /opt/encoded_payload.txt

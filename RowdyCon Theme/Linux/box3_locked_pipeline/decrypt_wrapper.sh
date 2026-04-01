#!/bin/bash
SCRIPT_PATH="$(readlink -f "$0")"
exec /usr/local/lib/.hidden_pipeline/getsecret "${SCRIPT_PATH}"

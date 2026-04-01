#!/bin/sh
# Wrapper to mimic execution policy enforcement; sets a flag only when -ExecutionPolicy Bypass is supplied.

BYPASS=0
UNRESTRICTED=0
EXPECT_POLICY=0

for ARG in "$@"; do
    case "$ARG" in
        -ExecutionPolicy=*)
            POLICY="${ARG#*=}"
            ;;
        -ExecutionPolicy)
            EXPECT_POLICY=1
            POLICY=""
            continue
            ;;
        *)
            if [ "$EXPECT_POLICY" -eq 1 ]; then
                POLICY="$ARG"
                EXPECT_POLICY=0
            else
                POLICY=""
            fi
            ;;
    esac

    case "$POLICY" in
        [Bb][Yy][Pp][Aa][Ss][Ss])
            BYPASS=1
            ;;
        [Uu][Nn][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ee][Dd])
            UNRESTRICTED=1
            ;;
    esac
done

if [ "$BYPASS" -eq 1 ]; then
    export EXEC_POLICY="Bypass"
elif [ "$UNRESTRICTED" -eq 1 ]; then
    export EXEC_POLICY="Unrestricted"
fi

exec /usr/bin/pwsh "$@"

#!/bin/sh
# Usage: name-of-this-file program arg1 arg2 argN
if [ -n "$1" ]; then
    # if there are arguments, put the contents in a file since arguments with spaces could be messed up
    if [ $# -gt 1 ]; then
        export IAMTEMPFILE=1
        export EXECUTEMEPLOX=$(mktemp)
        echo "$@" > "$EXECUTEMEPLOX"
    else
        unset IAMTEMPFILE
        export EXECUTEMEPLOX="$1"
    fi
    x-terminal-emulator -e "$0"
else
    if [ -n "$EXECUTEMEPLOX" ]; then
        if [ -n "$IAMTEMPFILE" ]; then
            unset IAMTEMPFILE
            # note: make sure the executed program does not change $EXECUTEMEPLOX
            . "$EXECUTEMEPLOX"
            # and remove the file with the command
            rm -f "$EXECUTEMEPLOX"
        else
            # no temp file, just execute the command
            "$EXECUTEMEPLOX"
        fi
    fi
    # and replace the current shell with bash
    exec bash
fi

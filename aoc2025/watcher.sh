#!/usr/bin/env bash

DAY=$1
PRACTICE=$2

[[ -z $DAY ]] && exit 1
[[ -z $PRACTICE ]] && PRACTICE=0 || PRACTICE=practice

while true; do
    sleep 0.1
    clear
    ./run.jl "$DAY" "$PRACTICE" &
    PID=$!

    inotifywait -qq days/*.jl res/* *.jl -e MODIFY -e MOVE_SELF
    pkill -TERM $PID &> /dev/null
    kill -SIGTERM $PID &> /dev/null
done

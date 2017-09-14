#!/bin/bash
# Используя информацию из /proc/<PID>/stack, посчитать глубину 
# стека вызовов для каждого процесса и вывести список процессов 
# сгруппированный по глубине
# stack level : 4
# 1433
# 3422
# stack level : 6
# 544
# 12433

USAGE="Usage: $0

Задание: Используя информацию из /proc/<PID>/stack, посчитать глубину 
стека вызовов для каждого процесса и вывести список процессов 
сгруппированный по глубине"

function save_stack {
    DIR="$1"
    for PID in `ls /proc | grep "^[0-9]\+$" | sort -V`; do
        STACK="/proc/$PID/stack"
        if [ -f $STACK ]; then
            DEPTH=`sudo cat "$STACK" | wc -l`
            echo "$PID" >> $DIR/$DEPTH
        fi
    done
}

function print_stack {
    DIR="$1"
    for DEPTH in `ls $DIR`; do
        echo "stack level : $DEPTH"
        cat $DIR/$DEPTH
        echo ""
    done;
}

if [ "$1" == "-h" ]; then
    echo "$USAGE"
    exit 0
fi

DIR=`mktemp -d`
save_stack $DIR
print_stack $DIR
rm -rf $DIR

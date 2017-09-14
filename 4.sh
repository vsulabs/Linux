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

USAGE="Usage: $0 output

Задание: Используя информацию из /proc/<PID>/stack, посчитать глубину 
стека вызовов для каждого процесса и вывести список процессов 
сгруппированный по глубине"

HEADER="
\\documentclass{article}
\\usepackage[english]{babel}
\\usepackage{longtable}
\\begin{document}
\\begin{longtable}{ |l|l| }

\\hline 
\\multicolumn{1}{|c|}{Depth} &
\\multicolumn{1}{c|}{PID} \\\\
\\endfirsthead

\\hline
\\endhead

\\hline
\\endfoot
"

AWK_CODE='
{
  depth[NR] = $1
  nfs[NR] = NF
  for (i = 2; i <= NF; i++)
    a[NR, i - 1] = $i
}

END {
  for (i = 1; i <= NR; i++) {
    printf "\\hline " depth[i] "\n"
    for (j = 1; j < nfs[i]; j++) {
      printf " & " a[i, j] " \\\\ \n"
    }
  }
}
'

TAIL="
\\end{longtable}
\\end{document}
"

function save_stack {
    DIR="$1"
    for PID in `ls /proc | grep "^[0-9]\+$" | sort -V`; do
        STACK="/proc/$PID/stack"
        if [ -f $STACK ]; then
            DEPTH=`sudo /usr/bin/cat "$STACK" | wc -l`
            echo -n "$PID " >> $DIR/$DEPTH
        fi
    done
}

function save_stack_without_grep {
    DIR="$1"
    for PID in `ls /proc | sort -V`; do
        if [ ! -d /proc/$PID ]; then
            continue
        fi

        STACK="/proc/$PID/stack"
        if [ ! -f $STACK ]; then
            continue
        fi

        DEPTH=`sudo /usr/bin/cat "$STACK" | wc -l`
        echo -n "$PID " >> $DIR/$DEPTH
    done
}

function merge_stack {
    DIR="$1"
    FILE="$2"
    for DEPTH in `ls $DIR`; do
        echo -n "$DEPTH " >> "$FILE"
        cat "$DIR/$DEPTH" >> "$FILE"
        echo "" >> "$FILE"
    done;
}

function make_pdf {
    IN="$1"
    OUT="$2"
    TMP=`mktemp`
    echo "$HEADER" > "$TMP"
    awk "$AWK_CODE" "$IN" >> "$TMP"
    echo "$TAIL" >> "$TMP"
    pdflatex "$TMP" > /dev/null
    rm "$TMP"
    rm tmp.log tmp.aux
    mv "tmp.pdf" "$OUT"
}

if [ "$1" == "-h" ] || [[ $# != 1 ]]; then
    echo "$USAGE"
    exit 0
fi

DIR=`mktemp -d`
MERGED=`mktemp`
OUT="res.pdf"

save_stack $DIR
merge_stack $DIR $MERGED
make_pdf $MERGED $OUT

rm -rf $DIR
rm $MERGED

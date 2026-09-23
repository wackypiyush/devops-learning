#!/bin/bash

# Check if file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

file=$1

echo "========================================"
echo "LOG ANALYZER"
echo "========================================"
echo "File: $file"

if [ -f "$file" ]; then
    echo "File exists"
    echo
    echo "Total Lines : $(wc -l < "$file")"
    echo "INFO  : $(grep -ci 'info' "$file")"
    echo "WARN  : $(grep -ci 'warn' "$file")"
    echo "ERROR : $(grep -ci 'error' "$file")"

    echo
    echo "Recent Logs:"
    echo "-------------------------"
    tail -n 5 "$file"
    echo "-------------------------"
    echo "Analysis Complete"
else
    echo "File does not exist!"
fi

echo "========================================"


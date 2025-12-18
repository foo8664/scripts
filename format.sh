#!/usr/bin/env bash

# $1 is the name of the directory where C code should be formatted

for f in $(find -O3 "$1" -type f -and -name "*.c" -or -name '*.h'); do
	indent --linux-style "$f"
	rm "$f"~
done

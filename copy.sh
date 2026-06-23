#!/usr/bin/env bash

if [[ "$1" = "-p" ]]; then
	wl-copy --trim-newline --primary <"$2"
elif [[ "$2" = "-p" ]]; then
	wl-copy --trim-newline --primary <"$1"
else
	wl-copy --trim-newline <"$1"
fi

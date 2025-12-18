#!/usr/bin/env bash

# Copies file "$1" to the clipboard
cat "$1" | xclip -selection clipboard

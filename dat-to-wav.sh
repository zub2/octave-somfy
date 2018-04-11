#!/bin/bash
set -e

if [ $# -ne 2 ]; then
	echo "Usage: $0 input.dat output.wav"
	exit
fi

IN_FILE="$1"
if [ ! -f "$IN_FILE" ]; then
	echo "Source file '$IN_FILE' does no exist!"
	exit 2
fi

OUT_FILE="$2"

sox \
	-t raw \
	-r 2600000 \
	-e unsigned-integer \
	-b 8 \
	-c 2 \
	"$IN_FILE" \
	"$OUT_FILE"

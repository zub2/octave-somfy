#!/bin/bash
set -e

if [ $# -ne 1 ]; then
	echo "Usage: $0 output.dat"
	exit
fi

OUT_FILE="$1"

RTLSDR_ROOT="$HOME/rtlsdr"
LD_LIBRARY_PATH="$RTLSDR_ROOT/lib:$LD_LIBRARY_PATH" "$RTLSDR_ROOT/bin/rtl_sdr" \
	-f 433420000 \
	-s 2600000 \
	-g 1 \
	"$OUT_FILE"

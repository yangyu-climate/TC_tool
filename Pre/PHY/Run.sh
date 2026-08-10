#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"
. "$SCRIPT_DIR/../TC_pre_config.sh"
sh "$SCRIPT_DIR/link_wrf_data.sh"
ncl "filename=\"$filename\"" NCL_WRF_DATA.ncl > running.out 2>&1

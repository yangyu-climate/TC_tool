#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONFIG_FILE="$SCRIPT_DIR/../TC_pre_config.sh"
. "$CONFIG_FILE"
SOURCE_DIR=$source_dir
FILE_PATTERN=$filename
if [ -z "$SOURCE_DIR" ] || [ "$SOURCE_DIR" = "/path/to/your/WRF/output/" ]; then
    echo "Set source_dir in $CONFIG_FILE before running this helper." >&2
    exit 1
fi
if [ -z "$FILE_PATTERN" ]; then
    echo "Set filename in $CONFIG_FILE before running this helper." >&2
    exit 1
fi

SAVE_DIR="$SCRIPT_DIR/DATA"
mkdir -p "$SAVE_DIR"

found=0
for source_file in "$SOURCE_DIR"/$FILE_PATTERN; do
    [ -f "$source_file" ] || [ -L "$source_file" ] || continue
    found=1
    target="$SAVE_DIR/$(basename "$source_file")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Refusing to replace regular file: $target" >&2
        exit 1
    fi
    ln -sfn "$source_file" "$target"
done

if [ "$found" -eq 0 ]; then
    echo "No files matching $SOURCE_DIR/$FILE_PATTERN" >&2
    exit 1
fi

echo "Linked WRF inputs into $SAVE_DIR"

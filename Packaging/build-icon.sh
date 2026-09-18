#!/bin/sh
set -eu

SOURCE="$1"
OUTPUT="$2"
ICONSET="${OUTPUT%.icns}.iconset"

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

resize() {
    size="$1"
    name="$2"
    sips -z "$size" "$size" "$SOURCE" --out "$ICONSET/$name" >/dev/null
}

resize 16 icon_16x16.png
resize 32 icon_16x16@2x.png
resize 32 icon_32x32.png
resize 64 icon_32x32@2x.png
resize 128 icon_128x128.png
resize 256 icon_128x128@2x.png
resize 256 icon_256x256.png
resize 512 icon_256x256@2x.png
resize 512 icon_512x512.png
resize 1024 icon_512x512@2x.png

iconutil --convert icns --output "$OUTPUT" "$ICONSET"

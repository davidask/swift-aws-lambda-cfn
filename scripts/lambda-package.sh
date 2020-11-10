#!/usr/bin/env bash

. "${SCRIPT_PATH:="$(dirname ${BASH_SOURCE[0]:-$0})"}/common.sh"

SWIFT_EXECUTABLE=$1

run_in_docker $SWIFT_EXECUTABLE

TARGET="$PROJECT_DIR/.build/lambda/$SWIFT_EXECUTABLE"
rm -rf "$TARGET"
mkdir -p "$TARGET"
cp ".build/release/$SWIFT_EXECUTABLE" "$TARGET/"
# add the target deps based on ldd
ldd ".build/release/$SWIFT_EXECUTABLE" | grep swift | awk '{print $3}' | xargs cp -Lv -t "$TARGET"
cd "$TARGET"
ln -s "$SWIFT_EXECUTABLE" "bootstrap"
zip --symlinks lambda.zip *
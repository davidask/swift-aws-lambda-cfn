#!/usr/bin/env bash

. "${SCRIPT_PATH:="$(dirname ${BASH_SOURCE[0]:-$0})"}/common.sh"

SWIFT_EXECUTABLE=$1

run_in_docker $SWIFT_EXECUTABLE

swift build --target "$SWIFT_EXECUTABLE" -c release
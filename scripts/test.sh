#!/usr/bin/env bash

. "${SCRIPT_PATH:="$(dirname ${BASH_SOURCE[0]:-$0})"}/common.sh"

run_in_docker
swift test
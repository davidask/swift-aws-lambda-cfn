#!/usr/bin/env bash
#
set -eux -o pipefail
#
# Define a variable returning the absolute path of the source directory
PROJECT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && cd .. && pwd -P
)"

DOCKER_WORKSPACE_DIR=/"workspace"

DOCKER_TAG="swift-lambda-builder"

function docker_build() {
    docker build -t "$DOCKER_TAG" "$PROJECT_DIR"
}

function docker_run() {
    docker run -it --rm -v "$PROJECT_DIR":"$DOCKER_WORKSPACE_DIR" -w "$DOCKER_WORKSPACE_DIR" "$DOCKER_TAG" bash -c "$*"
}

function run_in_docker() {
    if [ ! -f /.dockerenv ]; then
        docker_build
        docker_run $DOCKER_WORKSPACE_DIR/$0 $*
        exit $?
    fi
}

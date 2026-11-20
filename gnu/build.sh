#!/bin/bash
# Build the dflowfm executable in Docker from this repository (run from the repository root).
# PLATFORM=linux/amd64 (default) or linux/arm64. Result: /build/dflowfm/dflowfm_cli_exe/dflowfm in the volume dflowfm-build.
set -euo pipefail
PLATFORM=${PLATFORM:-linux/amd64}; JOBS=${JOBS:-8}
docker build --platform "$PLATFORM" -t dflowfm-gnu-deps:base -f gnu/deps.Dockerfile gnu
docker build --platform "$PLATFORM" --build-arg BASE=dflowfm-gnu-deps:base -t dflowfm-gnu-deps:petsc -f gnu/petsc.Dockerfile gnu
docker run --rm --platform "$PLATFORM" -v "$PWD":/delft3d:ro -v dflowfm-build:/build dflowfm-gnu-deps:petsc bash -c \
  "rm -rf /build/src && cp -a /delft3d /build/src && /build/src/gnu/configure.sh && ninja -C /build/dflowfm -j $JOBS dflowfm_cli_exe/dflowfm"

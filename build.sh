#!/usr/bin/env bash

set -e

echo ""
echo "Start setting up docker build."
echo ""

if [ -z ${1} ]; then
  echo "Missing parameter, Name."
  exit -1
fi

NAME="${1:-}"
IMAGE_NAME="${2:-debian-12-kas}"
IMAGE_TAG="${3:-latest}"
FULL_IMAGE="${NAME}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t ${FULL_IMAGE} .

echo ""
echo "Build completed successfully!"
echo ""
echo "Image: ${FULL_IMAGE}"
echo ""

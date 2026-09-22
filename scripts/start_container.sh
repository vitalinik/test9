#!/bin/bash
set -e

CONTAINER_NAME="cmtr-5bf61784-north-pole"
IMAGE_URI=$(cat /opt/cmtr-5bf61784/image_uri.txt)

echo "Starting container ${CONTAINER_NAME} from ${IMAGE_URI} on port 8080..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p 8080:8080 \
  "${IMAGE_URI}"

echo "Container started:"
docker ps -f name="${CONTAINER_NAME}"

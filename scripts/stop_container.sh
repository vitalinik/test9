#!/bin/bash
set -e

CONTAINER_NAME="cmtr-5bf61784-north-pole"

if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
  echo "Stopping and removing existing container ${CONTAINER_NAME}..."
  docker stop "${CONTAINER_NAME}" || true
  docker rm "${CONTAINER_NAME}" || true
else
  echo "No existing container named ${CONTAINER_NAME} found. Nothing to stop."
fi

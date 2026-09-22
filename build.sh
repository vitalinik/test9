#!/bin/bash
# Build Docker image for ARM64 (or multi-arch) using buildx
# Requires: docker buildx (available in Docker Desktop or installed separately)

set -e

IMAGE_NAME="cmtr-north-pole"
TAG="local"
PLATFORM="${PLATFORM:-linux/arm64}"
PUSH="${PUSH:-false}"
BUILDER="${BUILDER:-cmtr-builder}"

if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
  docker buildx create --name "$BUILDER" --use >/dev/null
else
  docker buildx use "$BUILDER" >/dev/null
fi

echo "Building $IMAGE_NAME:$TAG for platform(s): $PLATFORM"

# Use --load for single-arch local runs, --push for multi-arch registry use.
if [ "$PUSH" = "true" ]; then
  docker buildx build \
    --platform "$PLATFORM" \
    -t "$IMAGE_NAME:$TAG" \
    -f Dockerfile \
    --push \
    .
else
  docker buildx build \
    --platform "$PLATFORM" \
    -t "$IMAGE_NAME:$TAG" \
    -f Dockerfile \
    --load \
    .
fi

echo "✓ Build complete: $IMAGE_NAME:$TAG"
echo "To run: docker run --rm -p 8080:8080 -e RELEASE_NAME=green $IMAGE_NAME:$TAG"
echo "Tip: set PLATFORM=linux/amd64,linux/arm64 PUSH=true to publish multi-arch"
